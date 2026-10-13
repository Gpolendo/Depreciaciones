using DevExpress.Web;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;


public partial class InventarioDepreciaciones : System.Web.UI.Page
{
    private static readonly CultureInfo CulturaMx = CultureInfo.GetCultureInfo("es-MX");

    private static readonly string[] NombresMes =
    {
        "enero", "febrero", "marzo", "abril", "mayo", "junio",
        "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
    };

    private int _idEmpresa;
    private string _rfc = string.Empty;
    private string _nombreEmpresa = string.Empty;
    private bool _permitirTransito;
    private DataTable _activos;
    private DataTable _resumen;
    private string _errorConsulta;
    private Filtros _filtros = Filtros.Vacios;
    private bool _inicializado;                   // true cuando Page_Load ya resolvió empresa y filtros

    private static string ConexionDeprecia
    {
        get { return ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        _permitirTransito = LeerBandera("Activos.PermitirTransito");
        ObtenerIdEmpresa();

        GvActivos.SettingsExport.FileName = string.Format("Activos_{0}_{1:yyyyMMdd}", _rfc, DateTime.Now);

        // Filtros vigentes: HfFiltros viaja con cada callback (orden, paginación)
        // y con la exportación. Un callback "filtrar" los reemplaza (CustomCallback).
        _filtros = Filtros.Desde(HfFiltros.Contains("f") ? Convert.ToString(HfFiltros["f"]) : null);
        // A partir de aquí la empresa y los filtros ya se conocen; una lectura
        // anterior (DevExpress enlaza el grid al restaurar su estado en callbacks)
        // no se guardó en memoria, así que esta sí consulta el SP.
        _inicializado = true;
        _activos = null;
        _resumen = null;

        PopTransito.ClientVisible = _permitirTransito;

        // Los callbacks de los popups (captura, conceptos LISR y baja) no necesitan el listado.
        if (EsCallbackDe(CbActivo) || EsCallbackDe(PopConcepto) || EsCallbackDe(CbBaja))
            return;

        // Sin caché de renglones: el grid se enlaza en cada petición y lee sp_ConsultaActivos.
        GvActivos.DataBind();

        if (!IsPostBack && !IsCallback)
        {
            CargarListasDeFiltro();
            RegistrarConfiguracionCliente();
        }

        LitEmpresa.Text = HttpUtility.HtmlEncode(
            string.IsNullOrEmpty(_nombreEmpresa) ? "Sin empresa seleccionada" : _nombreEmpresa);
        PintarEncabezado();

        if (!string.IsNullOrEmpty(_errorConsulta) && !IsCallback)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "errorConsulta",
                "Swal.fire({ icon: 'error', title: 'No se pudo consultar los activos', text: '" +
                HttpUtility.JavaScriptStringEncode(_errorConsulta) + "', confirmButtonColor: '#1e3a5f' });", true);
        }
    }

    #region Datos

    private static bool LeerBandera(string clave)
    {
        bool valor;
        return bool.TryParse(ConfigurationManager.AppSettings[clave], out valor) && valor;
    }

    private void ObtenerIdEmpresa()
    {
        _rfc = MySession.Current.RFCEmpresaActual ?? string.Empty;

        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        using (SqlCommand com = new SqlCommand("SELECT TOP (1) Id, Empresa FROM dbo.Empresas WHERE RFC = @RFC", con))
        {
            com.Parameters.Add("@RFC", SqlDbType.VarChar, 20).Value = _rfc;
            con.Open();
            using (SqlDataReader dr = com.ExecuteReader())
            {
                if (dr.Read())
                {
                    _idEmpresa = dr.GetInt32(0);
                    _nombreEmpresa = dr.IsDBNull(1) ? string.Empty : Convert.ToString(dr.GetValue(1));
                    Session["IdEmpresa"] = _idEmpresa;
                }
            }
        }
    }

    protected void GvActivos_DataBinding(object sender, EventArgs e)
    {
        GvActivos.DataSource = ObtenerActivos();
        GvActivos.JSProperties["cpError"] = _errorConsulta ?? string.Empty;
    }

    // Callback "filtrar|{json}" desde ActAplicar(): los filtros del parámetro mandan.
    // Si coinciden con los que ya llegaron en HfFiltros no se vuelve a consultar.
    protected void GvActivos_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
    {
        string parametro = e.Parameters ?? string.Empty;
        if (!parametro.StartsWith("filtrar|", StringComparison.Ordinal))
            return;

        Filtros nuevos = Filtros.Desde(parametro.Substring("filtrar|".Length));
        if (nuevos.Firma != _filtros.Firma)
        {
            _filtros = nuevos;
            _activos = null;
            _resumen = null;
        }

        GvActivos.PageIndex = 0;
        GvActivos.DataBind();
        PintarEncabezado();
    }

    // Una sola lectura por petición. No se guarda en Session: el SP responde
    // rápido y así cada callback ve los datos vigentes.
    private DataTable ObtenerActivos()
    {
        if (_activos != null)
            return _activos;

        // Antes de Page_Load (enlace temprano de DevExpress en callbacks) todavía no
        // hay empresa ni filtros: se regresa una tabla vacía SIN guardarla, para que
        // el enlace de Page_Load sí lea el SP.
        if (!_inicializado)
        {
            DataTable vacia = CrearEsquema();
            CompletarColumnas(vacia);
            if (_resumen == null) _resumen = CrearEsquemaResumen();
            return vacia;
        }

        DataTable dt = CrearEsquema();
        DataTable resumen = CrearEsquemaResumen();

        if (_idEmpresa > 0)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(ConexionDeprecia))
                using (SqlCommand cmd = new SqlCommand("dbo.sp_ConsultaActivos", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                    cmd.Parameters.Add("@PermitirTransito", SqlDbType.Bit).Value = _permitirTransito;
                    cmd.Parameters.Add("@Resultado", SqlDbType.TinyInt).Value = 0;   // detalle + resumen
                    _filtros.AgregarParametros(cmd);

                    // Los dos result sets llegan a "Table" y "Table1" del DataSet.
                    DataSet ds = new DataSet();
                    ds.Tables.Add(dt);
                    resumen.TableName = "Table1";
                    ds.Tables.Add(resumen);
                    dt.TableName = "Table";

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(ds);
                    }

                    ds.Tables.Remove(dt);
                    ds.Tables.Remove(resumen);
                    dt.TableName = "Activos";
                }
                CompletarColumnas(dt);
                AgregarDatosDeBaja(dt);
            }
            catch (SqlException ex)
            {
                dt = CrearEsquema();
                resumen = CrearEsquemaResumen();
                _errorConsulta = ex.Message;
            }
        }

        if (!dt.Columns.Contains("EstadoTexto"))
            CompletarColumnas(dt);
        _activos = dt;
        _resumen = resumen;
        return dt;
    }

    private static DataTable CrearEsquemaResumen()
    {
        DataTable dt = new DataTable("Resumen");
        dt.Columns.Add("Estado", typeof(string));
        dt.Columns.Add("Activos", typeof(int));
        dt.Columns.Add("MoiTotal", typeof(decimal));
        return dt;
    }

    // Total de activos de la empresa sin filtros (la "M" de "N de M activos").
    // Si no hay filtros se toma del propio resultado; si los hay, se pide solo el resumen.
    private int ContarUniverso()
    {
        if (_filtros.EsVacio)
            return ObtenerActivos().Rows.Count;

        if (_idEmpresa <= 0)
            return 0;

        try
        {
            using (SqlConnection con = new SqlConnection(ConexionDeprecia))
            using (SqlCommand cmd = new SqlCommand("dbo.sp_ConsultaActivos", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 60;
                cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                cmd.Parameters.Add("@PermitirTransito", SqlDbType.Bit).Value = _permitirTransito;
                cmd.Parameters.Add("@Resultado", SqlDbType.TinyInt).Value = 2;   // solo el resumen
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
                int total = 0;
                foreach (DataRow r in dt.Rows)
                    total += Convert.ToInt32(r["Activos"]);
                return total;
            }
        }
        catch (SqlException ex)
        {
            _errorConsulta = ex.Message;
            return 0;
        }
    }

    // Listas del panel, con el conteo sobre todos los activos de la empresa.
    // Solo en la carga inicial (sin filtros); en los callbacks conservan sus
    // elementos por ViewState.
    private void CargarListasDeFiltro()
    {
        DataTable universo = ObtenerActivos();

        Dictionary<int, int> porTipo = new Dictionary<int, int>();
        int convencionales = 0, aceleradas = 0;
        foreach (DataRow r in universo.Rows)
        {
            int idCat = r["IdCatalogo"] == DBNull.Value ? 0 : Convert.ToInt32(r["IdCatalogo"]);
            int n;
            porTipo.TryGetValue(idCat, out n);
            porTipo[idCat] = n + 1;

            if (Convert.ToInt32(r["Convencional"]) == 1) convencionales++;
            else aceleradas++;
        }

        CblConv.Items.Clear();
        CblConv.Items.Add(string.Format("Convencional ({0})", convencionales), 1);
        CblConv.Items.Add(string.Format("Acelerada ({0})", aceleradas), 0);

        CblTipo.Items.Clear();
        PopTipo.Items.Clear();
        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        using (SqlCommand cmd = new SqlCommand("SELECT Id, Grupo FROM dbo.CatalogoCuentas ORDER BY Grupo", con))
        {
            con.Open();
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    int id = dr.GetInt32(0);
                    string grupo = Convert.ToString(dr.GetValue(1));
                    int n;
                    porTipo.TryGetValue(id, out n);
                    // Filtro: solo los tipos que tienen activos en la empresa (un tipo en 0 no filtra nada y confunde).
                    if (n > 0)
                        CblTipo.Items.Add(string.Format("{0} ({1})", grupo, n), id);
                    // Captura: el catálogo completo.
                    PopTipo.Items.Add(grupo, id);
                }
            }
        }
    }

    // Esquema fijo: si el SP falla, el grid sigue teniendo sus columnas.
    private static DataTable CrearEsquema()
    {
        DataTable dt = new DataTable("Activos");
        dt.Columns.Add("Id", typeof(int));
        dt.Columns.Add("Descripcion", typeof(string));
        dt.Columns.Add("Identificador", typeof(string));
        dt.Columns.Add("IdCatalogo", typeof(int));
        dt.Columns.Add("TipoActivo", typeof(string));
        dt.Columns.Add("Convencional", typeof(byte));
        dt.Columns.Add("TipoDepreciacion", typeof(string));
        dt.Columns.Add("PorcentajeDepFIscalAnual", typeof(double));
        dt.Columns.Add("PorcentajeDepContableAnual", typeof(double));
        dt.Columns.Add("Moi", typeof(decimal));
        dt.Columns.Add("MoiFiscal", typeof(decimal));
        dt.Columns.Add("FechaAdquisicion", typeof(DateTime));
        dt.Columns.Add("FechaUso", typeof(DateTime));
        dt.Columns.Add("FechaUsoEfectiva", typeof(DateTime));
        dt.Columns.Add("SinFechaUso", typeof(bool));
        dt.Columns.Add("FechaBaja", typeof(DateTime));
        dt.Columns.Add("SaldoContable", typeof(decimal));
        dt.Columns.Add("PorcentajeSaldo", typeof(decimal));
        dt.Columns.Add("Estado", typeof(string));
        dt.Columns.Add("PeriodoSaldo", typeof(int));
        dt.Columns.Add("MesSaldo", typeof(int));
        dt.Columns.Add("PeriodoCongelado", typeof(int));
        dt.Columns.Add("MesCongelado", typeof(int));
        return dt;
    }

    // Columnas para ordenar y exportar: tasas en %, texto y orden del estado.
    private static void CompletarColumnas(DataTable dt)
    {
        dt.Columns.Add("TasaFiscalPct", typeof(decimal));
        dt.Columns.Add("TasaContablePct", typeof(decimal));
        dt.Columns.Add("EstadoTexto", typeof(string));
        dt.Columns.Add("EstadoOrden", typeof(int));
        // Datos de ActivosBaja (Etapa 5): botón "Ver baja" y columnas de Excel.
        dt.Columns.Add("RegistroBaja", typeof(bool));
        dt.Columns.Add("MotivoBajaTexto", typeof(string));
        dt.Columns.Add("PrecioVenta", typeof(decimal));

        foreach (DataRow r in dt.Rows)
        {
            r["TasaFiscalPct"] = APorcentaje(r["PorcentajeDepFIscalAnual"]);
            r["TasaContablePct"] = APorcentaje(r["PorcentajeDepContableAnual"]);

            string estado = Convert.ToString(r["Estado"]);
            r["EstadoTexto"] = TextoEstado(estado);
            r["EstadoOrden"] = OrdenEstado(estado);
            r["RegistroBaja"] = false;
        }
    }

    // Motivo y precio de ActivosBaja para los activos del resultado. Se lee aparte
    // para no modificar sp_ConsultaActivos; las bajas de una empresa son pocas.
    private void AgregarDatosDeBaja(DataTable dt)
    {
        if (dt.Rows.Count == 0)
            return;

        Dictionary<int, DataRow> porId = new Dictionary<int, DataRow>();
        foreach (DataRow r in dt.Rows)
            porId[Convert.ToInt32(r["Id"])] = r;

        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT AB.IdActivo, AB.MotivoBaja, AB.PrecioVenta " +
            "FROM dbo.ActivosBaja AB JOIN dbo.Activos A ON A.Id = AB.IdActivo " +
            "WHERE A.IdEmpresa = @IdEmpresa ORDER BY AB.Id", con))
        {
            cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
            con.Open();
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    DataRow r;
                    if (!porId.TryGetValue(dr.GetInt32(0), out r))
                        continue;
                    r["RegistroBaja"] = true;
                    r["MotivoBajaTexto"] = MotivoParaMostrar(dr.IsDBNull(1) ? null : Convert.ToString(dr.GetValue(1)));
                    r["PrecioVenta"] = dr.IsDBNull(2) ? (object)DBNull.Value : dr.GetDecimal(2);
                }
            }
        }
    }

    private static object APorcentaje(object fraccion)
    {
        if (fraccion == null || fraccion == DBNull.Value)
            return DBNull.Value;
        return Math.Round(Convert.ToDecimal(fraccion) * 100m, 4);
    }

    private static string TextoEstado(string estado)
    {
        switch (estado)
        {
            case "vigente":  return "Con saldo";
            case "agotado":  return "Vida útil agotada";
            case "sincalc":  return "Sin calcular";
            case "transito": return "En tránsito";
            case "baja":     return "Baja";
            default:         return estado;
        }
    }

    private static int OrdenEstado(string estado)
    {
        switch (estado)
        {
            case "vigente":  return 1;
            case "agotado":  return 2;
            case "sincalc":  return 3;
            case "transito": return 4;
            case "baja":     return 5;
            default:         return 9;
        }
    }

    // Encabezado del listado, en la carga completa y en cada callback:
    //   cpCorte    "Saldos al cierre de {mes} {año}"
    //   cpTotal    "N activos" (etiqueta junto al título)
    //   cpN        N (renglones con los filtros actuales)
    //   cpUniverso M (activos de la empresa sin filtros), solo en la carga completa
    //   cpResumen  JSON del segundo result set (barra de estados; no depende de @Estado)
    private void PintarEncabezado()
    {
        DataTable dt = ObtenerActivos();

        string corte = null;
        foreach (DataRow r in dt.Rows)
        {
            if (r["PeriodoSaldo"] != DBNull.Value && r["MesSaldo"] != DBNull.Value)
            {
                int mes = Convert.ToInt32(r["MesSaldo"]);
                if (mes >= 1 && mes <= 12)
                    corte = string.Format("Saldos al cierre de {0} {1}", NombresMes[mes - 1], r["PeriodoSaldo"]);
                break;
            }
        }
        // Con filtros que no traen renglones no se sabe el corte: se conserva el anterior.
        if (corte == null && (dt.Rows.Count > 0 || _filtros.EsVacio))
            corte = "Sin cálculos de depreciación para esta empresa";

        string total = dt.Rows.Count == 1 ? "1 activo" : dt.Rows.Count.ToString("N0", CulturaMx) + " activos";

        if (corte != null)
        {
            LitCorte.Text = HttpUtility.HtmlEncode(corte);
            GvActivos.JSProperties["cpCorte"] = corte;
        }
        LitTotal.Text = HttpUtility.HtmlEncode(total);
        GvActivos.JSProperties["cpTotal"] = total;
        GvActivos.JSProperties["cpN"] = dt.Rows.Count;

        if (!IsCallback)
            GvActivos.JSProperties["cpUniverso"] = ContarUniverso();

        List<Dictionary<string, object>> resumen = new List<Dictionary<string, object>>();
        if (_resumen != null)
        {
            foreach (DataRow r in _resumen.Rows)
            {
                resumen.Add(new Dictionary<string, object>
                {
                    { "e", Convert.ToString(r["Estado"]) },
                    { "n", r["Activos"] == DBNull.Value ? 0 : Convert.ToInt32(r["Activos"]) },
                    { "m", r["MoiTotal"] == DBNull.Value ? 0m : Convert.ToDecimal(r["MoiTotal"]) }
                });
            }
        }
        GvActivos.JSProperties["cpResumen"] = new JavaScriptSerializer().Serialize(resumen);

    }

    #endregion

    #region Plantillas de celda (todo texto de BD va codificado)

    // Container.DataItem es DataRowView cuando el grid guarda renglones en caché,
    // pero con EnableRowsCache="False" DevExpress entrega un WebDataRow.
    // Este lector acepta ambos y devuelve DBNull.Value en lugar de null.
    private sealed class Fila
    {
        private readonly object _item;

        public Fila(object item) { _item = item; }

        public object this[string campo]
        {
            get
            {
                DataRowView drv = _item as DataRowView;
                object valor = drv != null ? drv[campo] : DataBinder.Eval(_item, campo);
                return valor ?? DBNull.Value;
            }
        }
    }

    private static string H(object valor)
    {
        return valor == null || valor == DBNull.Value ? string.Empty : HttpUtility.HtmlEncode(Convert.ToString(valor));
    }

    private static string Moneda(object valor)
    {
        return Convert.ToDecimal(valor).ToString("C2", CulturaMx);
    }

    private static string Porcentaje(object valor)
    {
        if (valor == null || valor == DBNull.Value)
            return "—";
        return Convert.ToDecimal(valor).ToString("0.##", CulturaMx) + "%";
    }

    private static string Fecha(object valor)
    {
        return valor == null || valor == DBNull.Value ? string.Empty : Convert.ToDateTime(valor).ToString("dd/MM/yyyy");
    }

    protected string CeldaActivo(object item)
    {
        Fila r = new Fila(item);
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class=\"ac-desc\">").Append(Resaltar(Convert.ToString(r["Descripcion"]))).Append("</div>");
        sb.Append("<div class=\"ac-sub\">Folio ").Append(H(r["Id"]));
        string ident = Convert.ToString(r["Identificador"]);
        if (!string.IsNullOrWhiteSpace(ident))
            sb.Append(" &middot; ").Append(Resaltar(ident));
        sb.Append("</div>");
        return sb.ToString();
    }

    protected string CeldaTipo(object item)
    {
        Fila r = new Fila(item);
        return "<div>" + H(r["TipoActivo"]) + "</div><div class=\"ac-sub\">" + H(r["TipoDepreciacion"]) + "</div>";
    }

    protected string CeldaTasa(object item)
    {
        Fila r = new Fila(item);
        return Porcentaje(r["TasaFiscalPct"]) + " / " + Porcentaje(r["TasaContablePct"]);
    }

    protected string CeldaMoi(object item)
    {
        Fila r = new Fila(item);
        string html = "<div>" + Moneda(r["Moi"]) + "</div>";
        if (r["MoiFiscal"] != DBNull.Value && Convert.ToDecimal(r["MoiFiscal"]) != Convert.ToDecimal(r["Moi"]))
            html += "<div class=\"ac-sub\">Fiscal " + Moneda(r["MoiFiscal"]) + "</div>";
        return html;
    }

    protected string CeldaUso(object item)
    {
        Fila r = new Fila(item);
        bool sinFecha = r["SinFechaUso"] != DBNull.Value && Convert.ToBoolean(r["SinFechaUso"]);

        if (!sinFecha)
            return Fecha(r["FechaUso"]);

        // Bandera apagada: se muestra la adquisición y se marca que no hay fecha de uso.
        if (!_permitirTransito)
            return Fecha(r["FechaUsoEfectiva"]) + "<div class=\"ac-mark\">(sin fecha de uso)</div>";

        return "<span class=\"ac-mark\">Sin fecha</span>";
    }

    protected string CeldaSaldo(object item)
    {
        Fila r = new Fila(item);

        if (r["SaldoContable"] == DBNull.Value)
            return "<span class=\"sal-sc\">Sin calcular</span>";

        string monto = Moneda(r["SaldoContable"]);

        bool tasaCero = r["PorcentajeDepContableAnual"] == DBNull.Value
                        || Convert.ToDouble(r["PorcentajeDepContableAnual"]) == 0d;
        if (tasaCero)
            return "<div>" + monto + "</div><div class=\"sal-nd\">No se deprecia</div>";

        decimal pct = r["PorcentajeSaldo"] == DBNull.Value ? 0m : Convert.ToDecimal(r["PorcentajeSaldo"]);
        if (pct < 0m) pct = 0m;
        if (pct > 100m) pct = 100m;
        string ancho = pct.ToString("0.##", CultureInfo.InvariantCulture);

        return "<div>" + monto + "</div>" +
               "<div class=\"sal-bar\" role=\"img\" aria-label=\"" + ancho + "% por deducir\" title=\"" + ancho + "% por deducir\">" +
               "<i style=\"width:" + ancho + "%\"></i></div>";
    }

    protected string CeldaEstado(object item)
    {
        Fila r = new Fila(item);
        string estado = Convert.ToString(r["Estado"]);
        return "<span class=\"st st-" + H(estado) + "\">" + H(r["EstadoTexto"]) + "</span>";
    }

    private const string IcoEditar =
        "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M12 20h9\"/><path d=\"M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z\"/></svg>";
    private const string IcoDuplicar =
        "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><rect x=\"9\" y=\"9\" width=\"13\" height=\"13\" rx=\"2\"/><path d=\"M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1\"/></svg>";
    private const string IcoBaja =
        "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><circle cx=\"12\" cy=\"12\" r=\"9\"/><path d=\"M8 12h8\"/></svg>";

    private const string IcoVerBaja =
        "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" aria-hidden=\"true\"><path d=\"M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z\"/><path d=\"M14 2v6h6\"/><path d=\"M8 13h8\"/><path d=\"M8 17h5\"/></svg>";

    protected string CeldaAcciones(object item)
    {
        Fila r = new Fila(item);
        int id = Convert.ToInt32(r["Id"]);
        // Con baja: fecha de baja en Activos o renglón en ActivosBaja (una baja incompleta también se consulta).
        bool conBaja = r["FechaBaja"] != DBNull.Value
                       || (r["RegistroBaja"] != DBNull.Value && Convert.ToBoolean(r["RegistroBaja"]));
        // El saldo del renglón se muestra en el resumen de la ventana de baja.
        string saldo = r["SaldoContable"] == DBNull.Value
            ? "null" : Convert.ToDecimal(r["SaldoContable"]).ToString(CultureInfo.InvariantCulture);

        StringBuilder sb = new StringBuilder("<div class=\"ac-btns\">");
        sb.AppendFormat("<button type=\"button\" class=\"ac-btn\" title=\"Editar\" aria-label=\"Editar folio {0}\" onclick=\"event.stopPropagation(); ActEditar({0});\">{1}</button>", id, IcoEditar);
        sb.AppendFormat("<button type=\"button\" class=\"ac-btn\" title=\"Duplicar\" aria-label=\"Duplicar folio {0}\" onclick=\"event.stopPropagation(); ActDuplicar({0});\">{1}</button>", id, IcoDuplicar);
        if (conBaja)
            sb.AppendFormat("<button type=\"button\" class=\"ac-btn ac-verbaja\" title=\"Ver baja\" aria-label=\"Ver la baja del folio {0}\" onclick=\"event.stopPropagation(); ActVerBaja({0}, {2});\">{1}</button>", id, IcoVerBaja, saldo);
        else
            sb.AppendFormat("<button type=\"button\" class=\"ac-btn ac-baja\" title=\"Dar de baja\" aria-label=\"Dar de baja el folio {0}\" onclick=\"event.stopPropagation(); ActDarDeBaja({0}, {2});\">{1}</button>", id, IcoBaja, saldo);
        sb.Append("</div>");
        return sb.ToString();
    }

    #endregion

    #region Resaltado de la búsqueda

    // Marca con <mark> las palabras buscadas, sin distinguir acentos ni mayúsculas,
    // igual que el SP (COLLATE Modern_Spanish_CI_AI). Se compara sobre un texto
    // normalizado, pero cada carácter normalizado conserva la posición del original,
    // así que lo que se marca y se codifica es siempre el texto original.
    private string Resaltar(string texto)
    {
        if (string.IsNullOrEmpty(texto))
            return string.Empty;

        IList<string> palabras = _filtros.PalabrasNormalizadas;
        if (palabras.Count == 0)
            return HttpUtility.HtmlEncode(texto);

        StringBuilder normal = new StringBuilder(texto.Length);
        List<int> origen = new List<int>(texto.Length);
        for (int i = 0; i < texto.Length; i++)
        {
            string n = Normalizar(texto[i].ToString());
            for (int k = 0; k < n.Length; k++)
            {
                normal.Append(n[k]);
                origen.Add(i);
            }
        }

        string plano = normal.ToString();
        bool[] marcar = new bool[texto.Length];
        foreach (string p in palabras)
        {
            int desde = 0, pos;
            while ((pos = plano.IndexOf(p, desde, StringComparison.Ordinal)) >= 0)
            {
                for (int k = pos; k < pos + p.Length; k++)
                    marcar[origen[k]] = true;
                desde = pos + 1;
            }
        }

        StringBuilder sb = new StringBuilder();
        int j = 0;
        while (j < texto.Length)
        {
            int ini = j;
            bool m = marcar[j];
            while (j < texto.Length && marcar[j] == m) j++;
            string tramo = HttpUtility.HtmlEncode(texto.Substring(ini, j - ini));
            sb.Append(m ? "<mark>" + tramo + "</mark>" : tramo);
        }
        return sb.ToString();
    }

    // Minúsculas y sin acentos. La ñ se conserva: en Modern_Spanish es una letra propia.
    internal static string Normalizar(string s)
    {
        if (string.IsNullOrEmpty(s))
            return string.Empty;

        StringBuilder sb = new StringBuilder(s.Length);
        foreach (char c in s)
        {
            if (c == 'ñ' || c == 'Ñ') { sb.Append('ñ'); continue; }
            string d = c.ToString().Normalize(NormalizationForm.FormD);
            foreach (char x in d)
                if (CharUnicodeInfo.GetUnicodeCategory(x) != UnicodeCategory.NonSpacingMark)
                    sb.Append(char.ToLowerInvariant(x));
        }
        return sb.ToString();
    }

    #endregion

    #region Filtros (se validan y acotan antes de llegar al SP)

    private sealed class Filtros
    {
        private static readonly string[] Estados = { "vigente", "agotado", "transito", "sincalc", "baja" };
        private static readonly string[] Saldos  = { "cero", "pos", "sincalc" };
        private static readonly string[] Bajas   = { "solo", "sin" };

        public static readonly Filtros Vacios = new Filtros();

        public string Texto;
        public string Estado;
        public string Saldo;
        public string Baja;
        public List<int> Convencional = new List<int>();
        public List<int> Catalogos = new List<int>();
        public DateTime? AdqDesde, AdqHasta, UsoDesde, UsoHasta;
        public decimal? MoiMin, MoiMax;
        public List<string> PalabrasNormalizadas = new List<string>();

        public bool EsVacio { get { return Firma == Vacios.Firma; } }

        // Representación canónica, para saber si dos juegos de filtros son iguales.
        public string Firma
        {
            get
            {
                return string.Join("|", new[]
                {
                    Texto ?? "", Estado ?? "", Saldo ?? "", Baja ?? "",
                    string.Join(",", Convencional), string.Join(",", Catalogos),
                    F(AdqDesde), F(AdqHasta), F(UsoDesde), F(UsoHasta),
                    M(MoiMin), M(MoiMax)
                });
            }
        }

        private static string F(DateTime? d) { return d.HasValue ? d.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) : ""; }
        private static string M(decimal? m) { return m.HasValue ? m.Value.ToString(CultureInfo.InvariantCulture) : ""; }

        // JSON del cliente -> filtros válidos. Lo que no es válido se ignora.
        public static Filtros Desde(string json)
        {
            Filtros f = new Filtros();
            if (string.IsNullOrWhiteSpace(json) || json.Length > 20000)
                return f;

            Dictionary<string, object> d;
            try { d = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(json); }
            catch (ArgumentException) { return f; }
            catch (InvalidOperationException) { return f; }
            if (d == null)
                return f;

            string texto = Cadena(d, "t");
            if (texto != null)
            {
                texto = string.Join(" ", texto.Split((char[])null, StringSplitOptions.RemoveEmptyEntries));
                if (texto.Length > 200) texto = texto.Substring(0, 200);
                f.Texto = texto.Length == 0 ? null : texto;
            }

            f.Estado = Codigo(d, "e", Estados);
            f.Saldo  = Codigo(d, "s", Saldos);
            f.Baja   = Codigo(d, "b", Bajas);
            f.Convencional = Enteros(d, "c", 0, 1, 2);
            f.Catalogos    = Enteros(d, "k", 1, int.MaxValue, 500);

            f.AdqDesde = Fecha(d, "ad"); f.AdqHasta = Fecha(d, "ah");
            f.UsoDesde = Fecha(d, "ud"); f.UsoHasta = Fecha(d, "uh");
            Ordenar(ref f.AdqDesde, ref f.AdqHasta);
            Ordenar(ref f.UsoDesde, ref f.UsoHasta);

            f.MoiMin = Monto(d, "mn"); f.MoiMax = Monto(d, "mx");
            if (f.MoiMin.HasValue && f.MoiMax.HasValue && f.MoiMin > f.MoiMax)
            {
                decimal? t = f.MoiMin; f.MoiMin = f.MoiMax; f.MoiMax = t;
            }

            if (f.Texto != null)
                f.PalabrasNormalizadas = f.Texto.Split(' ')
                    .Select(p => Normalizar(p)).Where(p => p.Length > 0).Distinct().Take(10).ToList();

            return f;
        }

        public void AgregarParametros(SqlCommand cmd)
        {
            cmd.Parameters.Add("@Texto", SqlDbType.NVarChar, 200).Value = (object)Texto ?? DBNull.Value;
            cmd.Parameters.Add("@Estado", SqlDbType.VarChar, 20).Value = (object)Estado ?? DBNull.Value;
            cmd.Parameters.Add("@Saldo", SqlDbType.VarChar, 10).Value = (object)Saldo ?? DBNull.Value;
            cmd.Parameters.Add("@Bajas", SqlDbType.VarChar, 10).Value = (object)Baja ?? DBNull.Value;
            cmd.Parameters.Add("@Convencional", SqlDbType.VarChar, 10).Value =
                Convencional.Count > 0 ? (object)string.Join(",", Convencional) : DBNull.Value;
            cmd.Parameters.Add("@IdsCatalogo", SqlDbType.VarChar, -1).Value =
                Catalogos.Count > 0 ? (object)string.Join(",", Catalogos) : DBNull.Value;
            cmd.Parameters.Add("@AdqDesde", SqlDbType.Date).Value = (object)AdqDesde ?? DBNull.Value;
            cmd.Parameters.Add("@AdqHasta", SqlDbType.Date).Value = (object)AdqHasta ?? DBNull.Value;
            cmd.Parameters.Add("@UsoDesde", SqlDbType.Date).Value = (object)UsoDesde ?? DBNull.Value;
            cmd.Parameters.Add("@UsoHasta", SqlDbType.Date).Value = (object)UsoHasta ?? DBNull.Value;

            SqlParameter pMin = cmd.Parameters.Add("@MoiMin", SqlDbType.Decimal);
            pMin.Precision = 18; pMin.Scale = 2; pMin.Value = (object)MoiMin ?? DBNull.Value;
            SqlParameter pMax = cmd.Parameters.Add("@MoiMax", SqlDbType.Decimal);
            pMax.Precision = 18; pMax.Scale = 2; pMax.Value = (object)MoiMax ?? DBNull.Value;
        }

        private static string Cadena(Dictionary<string, object> d, string clave)
        {
            object v;
            return d.TryGetValue(clave, out v) && v is string ? ((string)v).Trim() : null;
        }

        private static string Codigo(Dictionary<string, object> d, string clave, string[] validos)
        {
            string v = Cadena(d, clave);
            return v != null && validos.Contains(v) ? v : null;
        }

        private static List<int> Enteros(Dictionary<string, object> d, string clave, int min, int max, int maxElementos)
        {
            List<int> lista = new List<int>();
            object v;
            if (!d.TryGetValue(clave, out v) || !(v is IEnumerable) || v is string)
                return lista;

            foreach (object o in (IEnumerable)v)
            {
                int n;
                if (o != null && int.TryParse(Convert.ToString(o, CultureInfo.InvariantCulture), NumberStyles.Integer, CultureInfo.InvariantCulture, out n)
                    && n >= min && n <= max && !lista.Contains(n))
                {
                    lista.Add(n);
                    if (lista.Count >= maxElementos) break;
                }
            }
            lista.Sort();
            return lista;
        }

        private static DateTime? Fecha(Dictionary<string, object> d, string clave)
        {
            DateTime f;
            string v = Cadena(d, clave);
            if (v != null && DateTime.TryParseExact(v, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out f)
                && f.Year >= 1900 && f.Year <= 2100)
                return f;
            return null;
        }

        private static void Ordenar(ref DateTime? desde, ref DateTime? hasta)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
            {
                DateTime? t = desde; desde = hasta; hasta = t;
            }
        }

        private static decimal? Monto(Dictionary<string, object> d, string clave)
        {
            object v;
            decimal m;
            if (d.TryGetValue(clave, out v) && v != null
                && decimal.TryParse(Convert.ToString(v, CultureInfo.InvariantCulture), NumberStyles.Number, CultureInfo.InvariantCulture, out m)
                && m >= 0m && m <= 999999999999m)
                return Math.Round(m, 2);
            return null;
        }
    }

    #endregion

    #region Exportación

    // La exportación del lado del cliente llega aquí antes de generar el archivo:
    // se ocultan las columnas de plantilla (vis_*) y se muestran las planas (exp_*).
    // El cambio solo vive en la petición de exportación.
    protected void GvActivos_BeforeExport(object sender, ASPxGridBeforeExportEventArgs e)
    {
        foreach (GridViewColumn col in GvActivos.Columns)
        {
            string nombre = col.Name ?? string.Empty;
            if (nombre.StartsWith("vis_", StringComparison.Ordinal))
                col.Visible = false;
            else if (nombre.StartsWith("exp_", StringComparison.Ordinal))
                col.Visible = true;
        }
    }

    #endregion

    #region Captura y edición (Etapa 4)

    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    private const decimal MoiMaximo = 999999999999.99m;

    // Tope fiscal de automóviles (decisión de Gabriel, 29/09/2026). Solo acota el MOI
    // fiscal capturado; el cálculo no cambia.
    private const decimal TopeAutoNormal = 175000m;
    private const decimal TopeAutoElectrico = 250000m;

    private bool EsCallbackDe(Control control)
    {
        return IsCallback && string.Equals(Request.Params["__CALLBACKID"], control.UniqueID, StringComparison.Ordinal);
    }

    // Tipos de activo a los que aplica la pregunta del tipo de vehículo (tope fiscal):
    // los grupos de "Equipo de transporte" del catálogo. Sin configuración: la persona
    // que captura confirma si es vehículo normal, híbrido o eléctrico.
    private static List<int> CatalogosTransporte()
    {
        List<int> ids = new List<int>();
        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT Id FROM dbo.CatalogoCuentas WHERE Grupo COLLATE Modern_Spanish_CI_AI LIKE '%transporte%'", con))
        {
            con.Open();
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                    ids.Add(dr.GetInt32(0));
            }
        }
        return ids;
    }

    // Configuración para el cliente: tipos de activo de transporte y bandera de tránsito.
    private void RegistrarConfiguracionCliente()
    {
        string js = "var ACT_CATALOGOS_TRANSPORTE = " + Json.Serialize(CatalogosTransporte()) + ";" +
                    "var ACT_PERMITIR_TRANSITO = " + (_permitirTransito ? "true" : "false") + ";";
        ClientScript.RegisterClientScriptBlock(GetType(), "actConfig", js, true);
    }

    // PeriodoFiscal con la misma regla que la pantalla anterior (OnTipoActivoChanged +
    // ObtenerTiposGrupos): convencional 0; acelerada 1, o 2 a partir de 2027.
    private static int PeriodoFiscal(int convencional)
    {
        if (convencional == 1)
            return 0;
        return DateTime.Now.Year > 2026 ? 2 : 1;
    }

    // Conceptos LISR del tipo de activo y tipo de depreciación. Misma consulta que
    // ObtenerTiposGrupos (CatalogoPorcentajes por grupo, TipoDepreciacion y PeriodoFiscal),
    // filtrando el grupo por su Id en lugar de por su nombre y trayendo además Porcentaje.
    private static DataTable ConsultarConceptos(int idCatalogo, int convencional)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("IdPorcentaje", typeof(int));
        dt.Columns.Add("Descripcion", typeof(string));
        dt.Columns.Add("Porcentaje", typeof(decimal));

        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT IdPorcentaje, Descripcion, Porcentaje FROM dbo.CatalogoPorcentajes " +
            "WHERE IdCatCuenta = @IdCatCuenta AND TipoDepreciacion = @TipoDepreciacion AND PeriodoFiscal = @PeriodoFiscal " +
            "ORDER BY Porcentaje DESC, Descripcion", con))
        {
            cmd.Parameters.Add("@IdCatCuenta", SqlDbType.Int).Value = idCatalogo;
            cmd.Parameters.Add("@TipoDepreciacion", SqlDbType.Int).Value = convencional;
            cmd.Parameters.Add("@PeriodoFiscal", SqlDbType.Int).Value = PeriodoFiscal(convencional);
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        return dt;
    }

    protected void PopConcepto_Callback(object sender, CallbackEventArgsBase e)
    {
        string[] partes = (e.Parameter ?? string.Empty).Split('|');
        int idCat, conv;
        DataTable dt = null;
        if (partes.Length == 2 && int.TryParse(partes[0], out idCat) && int.TryParse(partes[1], out conv)
            && idCat > 0 && (conv == 0 || conv == 1))
            dt = ConsultarConceptos(idCat, conv);

        PopConcepto.DataSource = dt ?? ConsultarConceptos(0, 1);
        PopConcepto.DataBind();
    }

    // "cargar|{id}" o "guardar|{json}". Siempre responde JSON: { accion, ok, ... }.
    protected void CbActivo_Callback(object source, CallbackEventArgs e)
    {
        string parametro = e.Parameter ?? string.Empty;
        Dictionary<string, object> r;

        try
        {
            if (parametro.StartsWith("cargar|", StringComparison.Ordinal))
            {
                int id;
                r = int.TryParse(parametro.Substring("cargar|".Length), out id) && id > 0
                    ? CargarActivo(id)
                    : Respuesta("cargar", false, "Folio no válido.");
            }
            else if (parametro.StartsWith("guardar|", StringComparison.Ordinal))
            {
                r = GuardarActivo(parametro.Substring("guardar|".Length));
            }
            else
            {
                r = Respuesta("", false, "Operación no válida.");
            }
        }
        catch (SqlException ex)
        {
            r = Respuesta(parametro.StartsWith("cargar|", StringComparison.Ordinal) ? "cargar" : "guardar", false,
                          "Error de base de datos: " + ex.Message);
        }

        e.Result = Json.Serialize(r);
    }

    private static Dictionary<string, object> Respuesta(string accion, bool ok, string mensaje)
    {
        return new Dictionary<string, object> { { "accion", accion }, { "ok", ok }, { "mensaje", mensaje } };
    }

    private Dictionary<string, object> CargarActivo(int id)
    {
        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT Id, IdCatalogo, Convencional, Descripcion, Identificador, FechaAdquisicion, FechaUso, FechaBaja, " +
            "       Moi, MoiFiscal, PorcentajeDepFIscalAnual, PorcentajeDepContableAnual " +
            "FROM dbo.Activos WHERE Id = @Id AND IdEmpresa = @IdEmpresa; " +
            "SELECT TOP (1) IdDetalle, Serie, Condicion, Color, ClaveVehicular, COUNT(*) OVER () AS Vigentes " +
            "FROM dbo.ActivosDetalle WHERE IdActivo = @Id AND Borrado IS NULL ORDER BY IdDetalle;", con))
        {
            cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
            cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
            con.Open();
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                if (!dr.Read())
                    return Respuesta("cargar", false, "El folio " + id + " no existe en la empresa actual.");

                Dictionary<string, object> a = new Dictionary<string, object>
                {
                    { "id", dr.GetInt32(0) },
                    { "cat", dr.GetInt32(1) },
                    { "conv", Convert.ToInt32(dr.GetValue(2)) },
                    { "desc", dr.IsDBNull(3) ? "" : dr.GetString(3) },
                    { "ident", dr.IsDBNull(4) ? "" : dr.GetString(4) },
                    { "fadq", dr.IsDBNull(5) ? null : dr.GetDateTime(5).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) },
                    { "fuso", dr.IsDBNull(6) ? null : dr.GetDateTime(6).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) },
                    { "fbaja", dr.IsDBNull(7) ? null : dr.GetDateTime(7).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) },
                    { "moi", dr.GetDecimal(8) },
                    { "moif", dr.GetDecimal(9) },
                    { "tf", dr.IsDBNull(10) ? (object)null : Math.Round(Convert.ToDecimal(dr.GetValue(10)) * 100m, 4) },
                    { "tc", dr.IsDBNull(11) ? (object)null : Math.Round(Convert.ToDecimal(dr.GetValue(11)) * 100m, 4) },
                    { "det", null }
                };

                if (dr.NextResult() && dr.Read())
                {
                    a["det"] = new Dictionary<string, object>
                    {
                        { "id", dr.GetInt32(0) },
                        { "serie", dr.IsDBNull(1) ? "" : dr.GetString(1) },
                        { "cond", dr.IsDBNull(2) ? "" : dr.GetString(2) },
                        { "color", dr.IsDBNull(3) ? "" : dr.GetString(3) },
                        { "clave", dr.IsDBNull(4) ? "" : dr.GetString(4) },
                        { "otros", Convert.ToInt32(dr.GetValue(5)) - 1 }
                    };
                }

                dr.Close();
                a["calc"] = InfoCalculo(con, id);

                Dictionary<string, object> r = Respuesta("cargar", true, "");
                r["activo"] = a;
                return r;
            }
        }
    }

    // Periodo que cubre el activo en CalculoDetalle_Historico y meses CERRADOS en ese
    // rango (aud.PeriodoEstado). null si el activo no tiene cálculos. Sirve para la
    // advertencia al editar (decisión de Gabriel, 29/09/2026); no bloquea nada.
    private Dictionary<string, object> InfoCalculo(SqlConnection con, int id)
    {
        int primer = 0, ultimo = 0;
        using (SqlCommand cmd = new SqlCommand(
            "SELECT MIN(CPE.Periodo * 100 + CDH.IdMes), MAX(CPE.Periodo * 100 + CDH.IdMes) " +
            "FROM dbo.CalculoDetalle_Historico CDH JOIN dbo.CatalogoPeriodo CPE ON CPE.Id = CDH.IdPeriodo " +
            "WHERE CDH.IdActivo = @Id AND CDH.IdEmpresa = @IdEmpresa", con))
        {
            cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
            cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                if (!dr.Read() || dr.IsDBNull(0))
                    return null;
                primer = Convert.ToInt32(dr.GetValue(0));
                ultimo = Convert.ToInt32(dr.GetValue(1));
            }
        }

        // aud.PeriodoEstado puede no ser legible para el usuario de la aplicación:
        // si falla, la advertencia sale sin el conteo de meses cerrados.
        int cerrados = 0;
        try
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM aud.PeriodoEstado " +
                "WHERE IdEmpresa = @IdEmpresa AND Estado = 'CERRADO' AND Periodo * 100 + Mes BETWEEN @Primer AND @Ultimo", con))
            {
                cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                cmd.Parameters.Add("@Primer", SqlDbType.Int).Value = primer;
                cmd.Parameters.Add("@Ultimo", SqlDbType.Int).Value = ultimo;
                cerrados = Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
        catch (SqlException)
        {
            cerrados = 0;
        }

        return new Dictionary<string, object>
        {
            { "primer", NombresMes[primer % 100 - 1] + " " + (primer / 100) },
            { "ultimo", NombresMes[ultimo % 100 - 1] + " " + (ultimo / 100) },
            { "desde", primer / 100 },
            { "cerrados", cerrados }
        };
    }

    // Alta / edición. Mismas reglas que ActPopValidar() en el cliente; los errores
    // regresan por campo. Reutiliza el INSERT y el UPDATE de la pantalla anterior,
    // corrigiendo sus defectos: el tipo se lee como int, se guarda FechaUso (H8) y la
    // tasa fiscal (H9), las tasas van con Math.Round(x/100, 6) y el MOI contable no
    // se modifica en edición.
    private Dictionary<string, object> GuardarActivo(string json)
    {
        Dictionary<string, object> d;
        try { d = Json.Deserialize<Dictionary<string, object>>(json); }
        catch (ArgumentException) { d = null; }
        catch (InvalidOperationException) { d = null; }
        if (d == null || _idEmpresa <= 0)
            return Respuesta("guardar", false, "No se recibieron datos válidos o no hay empresa seleccionada.");

        Dictionary<string, string> err = new Dictionary<string, string>();

        int id = Ent(d, "id") ?? 0;
        bool editar = id > 0;
        int? cat = Ent(d, "cat");
        int? conv = Ent(d, "conv");
        int? concepto = Ent(d, "concepto");
        string desc = Txt(d, "desc");
        string ident = Txt(d, "ident");
        DateTime? fadq = Fch(d, "fadq");
        DateTime? fuso = Fch(d, "fuso");
        bool transito = _permitirTransito && Bool(d, "transito");
        decimal? moi = Dec(d, "moi");
        decimal? moif = Dec(d, "moif");
        decimal? tf = Dec(d, "tf");
        decimal? tc = Dec(d, "tc");
        string veh = Txt(d, "veh");

        Dictionary<string, object> det = Sub(d, "det");
        int detId = det != null ? (Ent(det, "id") ?? 0) : 0;
        string serie = det != null ? Txt(det, "serie") : null;
        string cond = det != null ? Txt(det, "cond") : null;
        string color = det != null ? Txt(det, "color") : null;
        string clave = det != null ? Txt(det, "clave") : null;

        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        {
            con.Open();

            // Edición: el activo debe ser de la empresa; el MOI contable es el de la base.
            if (editar)
            {
                using (SqlCommand cmd = new SqlCommand("SELECT Moi FROM dbo.Activos WHERE Id = @Id AND IdEmpresa = @IdEmpresa", con))
                {
                    cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                    cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                    object v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value)
                        return Respuesta("guardar", false, "El folio " + id + " no existe en la empresa actual.");
                    moi = Convert.ToDecimal(v);
                }
            }

            // Tipo de activo
            if (!cat.HasValue || cat.Value <= 0)
                err["cat"] = "Elige el tipo de activo.";
            else
            {
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.CatalogoCuentas WHERE Id = @Id", con))
                {
                    cmd.Parameters.Add("@Id", SqlDbType.Int).Value = cat.Value;
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                        err["cat"] = "El tipo de activo no existe.";
                }
            }

            if (!conv.HasValue || (conv.Value != 0 && conv.Value != 1))
                err["conv"] = "Elige el tipo de depreciación.";

            // Concepto LISR y tope de la tasa fiscal
            decimal tope = 100m;
            if (!err.ContainsKey("cat") && !err.ContainsKey("conv"))
            {
                DataTable conceptos = ConsultarConceptos(cat.Value, conv.Value);
                if (conceptos.Rows.Count > 0)
                {
                    DataRow elegido = null;
                    if (concepto.HasValue)
                        foreach (DataRow c in conceptos.Rows)
                            if (Convert.ToInt32(c["IdPorcentaje"]) == concepto.Value) { elegido = c; break; }

                    if (elegido == null)
                        err["concepto"] = "Elige el concepto LISR.";
                    else
                        tope = Convert.ToDecimal(elegido["Porcentaje"]);
                }
            }

            if (string.IsNullOrEmpty(desc)) err["desc"] = "La descripción es obligatoria.";
            else if (desc.Length > 255) err["desc"] = "Máximo 255 caracteres.";
            if (ident != null && ident.Length > 255) err["ident"] = "Máximo 255 caracteres.";

            if (!fadq.HasValue) err["fadq"] = "La fecha de adquisición es obligatoria.";
            if (transito)
                fuso = null;
            else if (!fuso.HasValue)
                err["fuso"] = "La fecha de uso es obligatoria.";
            else if (fadq.HasValue && fuso.Value < fadq.Value)
                err["fuso"] = "La fecha de uso no puede ser anterior a la de adquisición.";

            if (!editar && (!moi.HasValue || moi.Value <= 0m)) err["moi"] = "El MOI contable debe ser mayor a 0.";
            else if (moi.HasValue && moi.Value > MoiMaximo) err["moi"] = "El MOI es demasiado grande.";

            if (!moif.HasValue || moif.Value < 0m) err["moif"] = "Captura el MOI fiscal (0 o más).";
            else if (moi.HasValue && moif.Value > moi.Value) err["moif"] = "El MOI fiscal no puede ser mayor que el contable.";

            // Equipo de transporte con MOI arriba de $175,000: el tipo de vehículo es obligatorio y fija el tope.
            if (cat.HasValue && !err.ContainsKey("cat") && moi.HasValue && moi.Value > TopeAutoNormal
                && CatalogosTransporte().Contains(cat.Value))
            {
                // "sintope" = mantener el valor capturado (camión, tractocamión, remolque...).
                decimal? topeVeh = veh == "normal" ? TopeAutoNormal
                                 : (veh == "hibrido" || veh == "electrico") ? TopeAutoElectrico
                                 : (decimal?)null;
                if (veh != "normal" && veh != "hibrido" && veh != "electrico" && veh != "sintope")
                    err["veh"] = "Elige una de las 4 opciones: normal, híbrido, eléctrico o mantener el valor capturado.";
                else if (topeVeh.HasValue && moif.HasValue && !err.ContainsKey("moif") && moif.Value > topeVeh.Value)
                    err["moif"] = "Para este tipo de vehículo el MOI fiscal máximo es " + topeVeh.Value.ToString("C2", CulturaMx) + ".";
            }

            if (!tf.HasValue) err["tf"] = "La tasa fiscal es obligatoria.";
            else if (tf.Value < 0m || tf.Value > 100m) err["tf"] = "Entre 0 y 100.";
            else if (tf.Value > tope) err["tf"] = "No puede ser mayor que la del concepto LISR (" + tope.ToString("0.####", CulturaMx) + "%).";

            if (!tc.HasValue) err["tc"] = "La tasa contable es obligatoria.";
            else if (tc.Value < 0m || tc.Value > 100m) err["tc"] = "Entre 0 y 100.";
            else if (tc.Value > tope) err["tc"] = "No puede ser mayor que el máximo fiscal del concepto LISR (" + tope.ToString("0.####", CulturaMx) + "%).";

            if (serie != null && serie.Length > 30) err["serie"] = "Máximo 30 caracteres.";
            if (cond != null && cond.Length > 15) err["cond"] = "Máximo 15 caracteres.";
            if (color != null && color.Length > 15) err["color"] = "Máximo 15 caracteres.";
            if (clave != null && clave.Length > 50) err["clave"] = "Máximo 50 caracteres.";

            if (err.Count > 0)
            {
                Dictionary<string, object> rErr = Respuesta("guardar", false, "Revisa los campos marcados.");
                rErr["errores"] = err;
                return rErr;
            }

            double tasaFiscal = (double)Math.Round(tf.Value / 100m, 6);
            double tasaContable = (double)Math.Round(tc.Value / 100m, 6);
            bool hayDetalle = !string.IsNullOrEmpty(serie) || !string.IsNullOrEmpty(cond)
                              || !string.IsNullOrEmpty(color) || !string.IsNullOrEmpty(clave);

            using (SqlTransaction tx = con.BeginTransaction())
            {
                try
                {
                    int idActivo;
                    if (editar)
                    {
                        // UPDATE de la pantalla anterior, sin Moi (inmutable) y sin columnas temporales.
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE dbo.Activos SET IdCatalogo = @IdCatalogo, Convencional = @Convencional, " +
                            "       Descripcion = @Descripcion, Identificador = @Identificador, " +
                            "       FechaAdquisicion = @FechaAdquisicion, FechaUso = @FechaUso, " +
                            "       PorcentajeDepFIscalAnual = @DFiscalAnual, PorcentajeDepContableAnual = @DContableAnual, " +
                            "       MoiFiscal = @MoiFiscal " +
                            "WHERE Id = @Id AND IdEmpresa = @IdEmpresa", con, tx))
                        {
                            ParametrosActivo(cmd, cat.Value, conv.Value, desc, ident, fadq.Value, fuso, tasaFiscal, tasaContable, moif.Value);
                            cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                            cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                            if (cmd.ExecuteNonQuery() != 1)
                                throw new InvalidOperationException("No se actualizó el folio " + id + ".");
                        }
                        idActivo = id;
                    }
                    else
                    {
                        // INSERT de la pantalla anterior, con FechaUso e Identificador.
                        using (SqlCommand cmd = new SqlCommand(
                            "INSERT INTO dbo.Activos (IdEmpresa, IdCatalogo, FechaAdquisicion, FechaUso, Descripcion, Identificador, " +
                            "       PorcentajeDepFIscalAnual, PorcentajeDepContableAnual, Moi, MoiFiscal, Convencional) " +
                            "OUTPUT INSERTED.Id " +
                            "VALUES (@IdEmpresa, @IdCatalogo, @FechaAdquisicion, @FechaUso, @Descripcion, @Identificador, " +
                            "       @DFiscalAnual, @DContableAnual, @Moi, @MoiFiscal, @Convencional)", con, tx))
                        {
                            ParametrosActivo(cmd, cat.Value, conv.Value, desc, ident, fadq.Value, fuso, tasaFiscal, tasaContable, moif.Value);
                            cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                            SqlParameter pMoi = cmd.Parameters.Add("@Moi", SqlDbType.Decimal);
                            pMoi.Precision = 18; pMoi.Scale = 2; pMoi.Value = moi.Value;
                            idActivo = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }

                    GuardarDetalle(con, tx, idActivo, editar ? detId : 0, hayDetalle, serie, cond, color, clave);

                    tx.Commit();

                    string mensaje = editar ? "Cambios guardados (folio " + idActivo + ")" : "Activo guardado (folio " + idActivo + ")";
                    if (editar)
                    {
                        Dictionary<string, object> calc = InfoCalculo(con, idActivo);
                        if (calc != null)
                            mensaje += ". Tiene cálculos: recalcula desde enero de " + calc["desde"];
                    }
                    Dictionary<string, object> ok = Respuesta("guardar", true, mensaje);
                    ok["id"] = idActivo;
                    return ok;
                }
                catch (SqlException ex)
                {
                    tx.Rollback();
                    Dictionary<string, object> rEx = Respuesta("guardar", false, "No se guardó: " + ex.Message);
                    if (ex.Number == 547 && ex.Message.IndexOf("CK_Activos_FechaUso", StringComparison.OrdinalIgnoreCase) >= 0)
                        rEx["errores"] = new Dictionary<string, string> { { "fuso", "La fecha de uso no puede ser anterior a la de adquisición." } };
                    return rEx;
                }
                catch (InvalidOperationException ex)
                {
                    tx.Rollback();
                    return Respuesta("guardar", false, "No se guardó: " + ex.Message);
                }
            }
        }
    }

    private static void ParametrosActivo(SqlCommand cmd, int idCatalogo, int convencional, string descripcion, string identificador,
                                         DateTime fechaAdquisicion, DateTime? fechaUso, double tasaFiscal, double tasaContable, decimal moiFiscal)
    {
        cmd.Parameters.Add("@IdCatalogo", SqlDbType.Int).Value = idCatalogo;
        cmd.Parameters.Add("@Convencional", SqlDbType.TinyInt).Value = (byte)convencional;
        cmd.Parameters.Add("@Descripcion", SqlDbType.VarChar, 255).Value = descripcion;
        cmd.Parameters.Add("@Identificador", SqlDbType.VarChar, 255).Value =
            string.IsNullOrEmpty(identificador) ? (object)DBNull.Value : identificador;
        cmd.Parameters.Add("@FechaAdquisicion", SqlDbType.Date).Value = fechaAdquisicion;
        cmd.Parameters.Add("@FechaUso", SqlDbType.Date).Value = fechaUso.HasValue ? (object)fechaUso.Value : DBNull.Value;
        cmd.Parameters.Add("@DFiscalAnual", SqlDbType.Float).Value = tasaFiscal;
        cmd.Parameters.Add("@DContableAnual", SqlDbType.Float).Value = tasaContable;
        SqlParameter pMoiF = cmd.Parameters.Add("@MoiFiscal", SqlDbType.Decimal);
        pMoiF.Precision = 18; pMoiF.Scale = 2; pMoiF.Value = moiFiscal;
    }

    // ActivosDetalle (decisión P5): vigente = Borrado IS NULL. El alta manda Borrado = NULL
    // explícito (el DEFAULT getdate() la haría nacer borrada); edición y borrado lógico por
    // IdDetalle, no por IdActivo. Vaciar todos los campos de un detalle existente lo borra.
    private static void GuardarDetalle(SqlConnection con, SqlTransaction tx, int idActivo, int idDetalle, bool hayDatos,
                                       string serie, string cond, string color, string clave)
    {
        string sql;
        if (idDetalle > 0 && hayDatos)
            sql = "UPDATE dbo.ActivosDetalle SET Serie = @Serie, Condicion = @Condicion, Color = @Color, ClaveVehicular = @ClaveVehicular " +
                  "WHERE IdDetalle = @IdDetalle AND IdActivo = @IdActivo AND Borrado IS NULL";
        else if (idDetalle > 0)
            sql = "UPDATE dbo.ActivosDetalle SET Borrado = GETDATE() " +
                  "WHERE IdDetalle = @IdDetalle AND IdActivo = @IdActivo AND Borrado IS NULL";
        else if (hayDatos)
            sql = "INSERT INTO dbo.ActivosDetalle (IdActivo, Serie, Condicion, Color, ClaveVehicular, Borrado) " +
                  "VALUES (@IdActivo, @Serie, @Condicion, @Color, @ClaveVehicular, NULL)";
        else
            return;

        using (SqlCommand cmd = new SqlCommand(sql, con, tx))
        {
            cmd.Parameters.Add("@IdActivo", SqlDbType.Int).Value = idActivo;
            cmd.Parameters.Add("@IdDetalle", SqlDbType.Int).Value = idDetalle;
            cmd.Parameters.Add("@Serie", SqlDbType.VarChar, 30).Value = string.IsNullOrEmpty(serie) ? (object)DBNull.Value : serie;
            cmd.Parameters.Add("@Condicion", SqlDbType.VarChar, 15).Value = string.IsNullOrEmpty(cond) ? (object)DBNull.Value : cond;
            cmd.Parameters.Add("@Color", SqlDbType.VarChar, 15).Value = string.IsNullOrEmpty(color) ? (object)DBNull.Value : color;
            cmd.Parameters.Add("@ClaveVehicular", SqlDbType.VarChar, 50).Value = string.IsNullOrEmpty(clave) ? (object)DBNull.Value : clave;
            cmd.ExecuteNonQuery();
        }
    }

    #endregion

    #region Baja: registrar, ver detalle y revertir (Etapa 5)

    // ActivosBaja.PrecioVenta es decimal(10,2).
    private const decimal PrecioVentaMaximo = 99999999.99m;
    private const int MotivoTextoMaximo = 240;     // + prefijo "INUTILIDAD: " cabe en varchar(255)

    // Estado de la baja de un activo, leído en una sola conexión.
    //   libre       sin fecha de baja, sin renglón en ActivosBaja y sin foto: se puede dar de baja
    //   completa    fecha de baja en Activos y exactamente un renglón en ActivosBaja
    //   incompleta  cualquier otra combinación: se avisa, sin detalle y sin reversión
    private sealed class EstadoBaja
    {
        public int Id;
        public string Descripcion, Identificador, Grupo;
        public int Convencional;
        public DateTime FechaAdquisicion;
        public DateTime? FechaUso, FechaBaja;
        public decimal Moi, MoiFiscal;
        public int Registros, Fotos;
        public DataRow Baja;          // renglón más reciente de ActivosBaja
        public string Situacion;
        public string Motivo;         // por qué está incompleta

        public DateTime FechaMinima
        {
            get { return FechaUso.HasValue && FechaUso.Value > FechaAdquisicion ? FechaUso.Value : FechaAdquisicion; }
        }
    }

    private EstadoBaja LeerEstadoBaja(SqlConnection con, int id)
    {
        DataSet ds = new DataSet();
        using (SqlCommand cmd = new SqlCommand(
            "SELECT A.Id, A.Descripcion, A.Identificador, CC.Grupo, A.Convencional, A.FechaAdquisicion, A.FechaUso, A.FechaBaja, A.Moi, A.MoiFiscal " +
            "FROM dbo.Activos A LEFT JOIN dbo.CatalogoCuentas CC ON CC.Id = A.IdCatalogo " +
            "WHERE A.Id = @Id AND A.IdEmpresa = @IdEmpresa; " +
            "SELECT COUNT(*) FROM dbo.ActivosBaja WHERE IdActivo = @Id; " +
            "SELECT COUNT(*) FROM dbo.CalculoDetalle_HistoricoBajas WHERE IdActivo = @Id; " +
            "SELECT TOP (1) Id, FechaVenta, NumFactura, PrecioVenta, MesesUso, FechaProcesado, " +
            "       ImporteContableDepreciado, RemanenteContableDepreciar, UtilidadContable, PerdidaContable, " +
            "       ImporteFiscalDeducido, AniosDepreciacionFiscalDI, PorcentajeFiscalDI, PorcentajeFiscalAplicarDI, " +
            "       MoiPorcentajeFiscalAplicarDI, RemanentePendienteDeducir, InpcUltimoMesMitadPeriodo, InpcFechaAdquisicion, " +
            "       FactoraAjuste, ValorActualizadoPendienteDeducir, UtilidadFiscalVenta, PerdidaFiscalVenta, MotivoBaja " +
            "FROM dbo.ActivosBaja WHERE IdActivo = @Id ORDER BY Id DESC;", con))
        {
            cmd.Parameters.Add("@Id", SqlDbType.Int).Value = id;
            cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                da.Fill(ds);
            }
        }

        if (ds.Tables.Count < 4 || ds.Tables[0].Rows.Count == 0)
            return null;

        DataRow a = ds.Tables[0].Rows[0];
        EstadoBaja s = new EstadoBaja
        {
            Id = Convert.ToInt32(a["Id"]),
            Descripcion = Convert.ToString(a["Descripcion"]),
            Identificador = Convert.ToString(a["Identificador"]),
            Grupo = Convert.ToString(a["Grupo"]),
            Convencional = Convert.ToInt32(a["Convencional"]),
            FechaAdquisicion = Convert.ToDateTime(a["FechaAdquisicion"]),
            FechaUso = a["FechaUso"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(a["FechaUso"]),
            FechaBaja = a["FechaBaja"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(a["FechaBaja"]),
            Moi = a["Moi"] == DBNull.Value ? 0m : Convert.ToDecimal(a["Moi"]),
            MoiFiscal = a["MoiFiscal"] == DBNull.Value ? 0m : Convert.ToDecimal(a["MoiFiscal"]),
            Registros = Convert.ToInt32(ds.Tables[1].Rows[0][0]),
            Fotos = Convert.ToInt32(ds.Tables[2].Rows[0][0]),
            Baja = ds.Tables[3].Rows.Count > 0 ? ds.Tables[3].Rows[0] : null
        };

        const string revision = " Requiere revisión del administrador.";
        if (s.Registros == 0 && !s.FechaBaja.HasValue)
        {
            if (s.Fotos == 0)
                s.Situacion = "libre";
            else
            {
                s.Situacion = "incompleta";
                s.Motivo = "Existe un cálculo de baja previo sin registro de baja; requiere revisión del administrador.";
            }
        }
        else if (s.Registros == 1 && s.FechaBaja.HasValue)
        {
            s.Situacion = "completa";
        }
        else
        {
            s.Situacion = "incompleta";
            if (s.Registros == 0)
                s.Motivo = "El activo tiene fecha de baja (" + Fecha(s.FechaBaja) + ") pero no tiene registro de baja." + revision;
            else if (!s.FechaBaja.HasValue)
                s.Motivo = "Hay un registro de baja del " + Fecha(s.Baja["FechaVenta"]) + " pero el activo no tiene fecha de baja." + revision;
            else
                s.Motivo = "El activo tiene " + s.Registros + " registros de baja." + revision;
        }
        return s;
    }

    // "VENTA: texto" / "INUTILIDAD: texto" (decisión P6, opción a). Las bajas anteriores
    // sin prefijo quedan como "Sin clasificar"; el DEFAULT 'NA' se trata como vacío.
    private static void PartirMotivo(string motivo, out string tipo, out string texto)
    {
        string m = (motivo ?? string.Empty).Trim();
        if (m.StartsWith("VENTA:", StringComparison.OrdinalIgnoreCase))
        {
            tipo = "Venta";
            texto = m.Substring("VENTA:".Length).Trim();
        }
        else if (m.StartsWith("INUTILIDAD:", StringComparison.OrdinalIgnoreCase))
        {
            tipo = "Inutilidad";
            texto = m.Substring("INUTILIDAD:".Length).Trim();
        }
        else
        {
            tipo = "Sin clasificar";
            texto = string.Equals(m, "NA", StringComparison.OrdinalIgnoreCase) ? string.Empty : m;
        }
    }

    private static string MotivoParaMostrar(string motivo)
    {
        string tipo, texto;
        PartirMotivo(motivo, out tipo, out texto);
        return texto.Length == 0 ? tipo : tipo + ": " + texto;
    }

    protected void CbBaja_Callback(object source, CallbackEventArgs e)
    {
        string parametro = e.Parameter ?? string.Empty;
        int corte = parametro.IndexOf('|');
        string accion = corte >= 0 ? parametro.Substring(0, corte) : parametro;
        string resto = corte >= 0 ? parametro.Substring(corte + 1) : string.Empty;
        Dictionary<string, object> r;

        try
        {
            int id;
            if (_idEmpresa <= 0)
                r = Respuesta(accion, false, "No hay empresa seleccionada.");
            else if (accion == "cargar")
                r = int.TryParse(resto, out id) && id > 0 ? CargarBaja(id) : Respuesta("cargar", false, "Folio no válido.");
            else if (accion == "registrar")
                r = RegistrarBaja(resto);
            else if (accion == "revertir")
                r = RevertirBaja(resto);
            else
                r = Respuesta("", false, "Operación no válida.");
        }
        catch (SqlException ex)
        {
            r = Respuesta(accion, false, "Error de base de datos: " + ex.Message);
        }

        e.Result = Json.Serialize(r);
    }

    private Dictionary<string, object> CargarBaja(int id)
    {
        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        {
            con.Open();
            EstadoBaja s = LeerEstadoBaja(con, id);
            if (s == null)
                return Respuesta("cargar", false, "El folio " + id + " no existe en la empresa actual.");

            Dictionary<string, object> r = Respuesta("cargar", true, "");
            r["situacion"] = s.Situacion;
            r["activo"] = new Dictionary<string, object>
            {
                { "id", s.Id },
                { "desc", s.Descripcion },
                { "ident", s.Identificador },
                { "grupo", s.Grupo },
                { "tipoDep", s.Convencional == 1 ? "Convencional" : "Acelerada" },
                { "fadq", Fecha(s.FechaAdquisicion) },
                { "fuso", s.FechaUso.HasValue ? Fecha(s.FechaUso) : null },
                { "fbaja", s.FechaBaja.HasValue ? Fecha(s.FechaBaja) : null },
                { "moi", s.Moi },
                { "moif", s.MoiFiscal }
            };

            if (s.Situacion == "libre")
            {
                r["min"] = s.FechaMinima.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            }
            else if (s.Situacion == "incompleta")
            {
                r["motivo"] = s.Motivo;
            }
            else
            {
                DateTime fechaVenta = Convert.ToDateTime(s.Baja["FechaVenta"]);
                string razon = RazonNoRevertir(con, fechaVenta);
                r["secciones"] = SeccionesBaja(s);
                r["revertir"] = new Dictionary<string, object>
                {
                    { "idBaja", Convert.ToInt32(s.Baja["Id"]) },
                    { "puede", razon == null },
                    { "razon", razon ?? string.Empty }
                };
            }
            return r;
        }
    }

    // Reglas para revertir (Gabriel, 29/09/2026): la baja debe ser del año en curso y ni
    // el mes de la baja ni los posteriores pueden estar CERRADOS en aud.PeriodoEstado.
    // Si no se puede leer aud.PeriodoEstado no se permite revertir.
    private string RazonNoRevertir(SqlConnection con, DateTime fechaVenta)
    {
        int anioActual = DateTime.Now.Year;
        if (fechaVenta.Year != anioActual)
            return "Solo se pueden revertir bajas del año en curso (" + anioActual + "); esta baja es de " + fechaVenta.Year + ".";

        int cerrados, primero = 0;
        try
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*), MIN(Periodo * 100 + Mes) FROM aud.PeriodoEstado " +
                "WHERE IdEmpresa = @IdEmpresa AND Estado = 'CERRADO' AND Periodo * 100 + Mes >= @Desde", con))
            {
                cmd.Parameters.Add("@IdEmpresa", SqlDbType.Int).Value = _idEmpresa;
                cmd.Parameters.Add("@Desde", SqlDbType.Int).Value = fechaVenta.Year * 100 + fechaVenta.Month;
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    dr.Read();
                    cerrados = Convert.ToInt32(dr.GetValue(0));
                    if (!dr.IsDBNull(1)) primero = Convert.ToInt32(dr.GetValue(1));
                }
            }
        }
        catch (SqlException)
        {
            return "No se pudo verificar si hay meses cerrados; no se permite revertir.";
        }

        if (cerrados > 0)
            return "El mes de la baja o uno posterior está cerrado (primero: " + NombresMes[primero % 100 - 1] + " " + (primero / 100) +
                   "). Solicita la reapertura antes de revertir.";
        return null;
    }

    // Campos de la baja por sección. Se muestran los que aplican al tipo de depreciación
    // (VentaBajaActivo): los de deducción inmediata (DI) solo en acelerada y el remanente
    // pendiente de deducir solo en convencional. Si uno que no aplica trae valor distinto
    // de 0, también se muestra para no ocultar datos.
    private static List<Dictionary<string, object>> SeccionesBaja(EstadoBaja s)
    {
        DataRow b = s.Baja;
        bool convencional = s.Convencional == 1;
        string tipo, texto;
        PartirMotivo(b["MotivoBaja"] == DBNull.Value ? null : Convert.ToString(b["MotivoBaja"]), out tipo, out texto);

        List<Dictionary<string, object>> datos = new List<Dictionary<string, object>>();
        Campo(datos, "Fecha de baja", Fecha(b["FechaVenta"]));
        Campo(datos, "Motivo", tipo);
        Campo(datos, "Descripción del motivo", texto.Length == 0 ? "—" : texto);
        Campo(datos, "Precio de venta", MontoBaja(b["PrecioVenta"]));
        Campo(datos, "Número de factura", b["NumFactura"] == DBNull.Value || Convert.ToString(b["NumFactura"]).Trim().Length == 0 ? "—" : Convert.ToString(b["NumFactura"]));
        Campo(datos, "Meses de uso en el ejercicio", b["MesesUso"] == DBNull.Value ? "—" : Convert.ToString(b["MesesUso"]));
        Campo(datos, "Registrada el", Fecha(b["FechaProcesado"]));

        List<Dictionary<string, object>> contable = new List<Dictionary<string, object>>();
        Campo(contable, "MOI contable", Moneda(s.Moi));
        Campo(contable, "Depreciación contable acumulada", MontoBaja(b["ImporteContableDepreciado"]));
        Campo(contable, "Remanente por depreciar", MontoBaja(b["RemanenteContableDepreciar"]));
        Campo(contable, "Utilidad contable", MontoBaja(b["UtilidadContable"]), true);
        Campo(contable, "Pérdida contable", MontoBaja(b["PerdidaContable"]), true);

        List<Dictionary<string, object>> fiscal = new List<Dictionary<string, object>>();
        Campo(fiscal, "MOI fiscal", Moneda(s.MoiFiscal));
        Campo(fiscal, "Importe fiscal deducido", MontoBaja(b["ImporteFiscalDeducido"]));
        if (convencional || NoCero(b["RemanentePendienteDeducir"]))
            Campo(fiscal, "Remanente pendiente de deducir", MontoBaja(b["RemanentePendienteDeducir"]));
        if (!convencional || NoCero(b["AniosDepreciacionFiscalDI"]) || NoCero(b["PorcentajeFiscalDI"])
            || NoCero(b["PorcentajeFiscalAplicarDI"]) || NoCero(b["MoiPorcentajeFiscalAplicarDI"]))
        {
            Campo(fiscal, "Años de depreciación fiscal (DI)", b["AniosDepreciacionFiscalDI"] == DBNull.Value ? "—" : Convert.ToString(b["AniosDepreciacionFiscalDI"]));
            Campo(fiscal, "Porcentaje fiscal (DI)", Numero(b["PorcentajeFiscalDI"], "0.######"));
            Campo(fiscal, "Porcentaje fiscal a aplicar (DI)", Numero(b["PorcentajeFiscalAplicarDI"], "0.######"));
            Campo(fiscal, "MOI por porcentaje a aplicar (DI)", MontoBaja(b["MoiPorcentajeFiscalAplicarDI"]));
        }
        Campo(fiscal, "INPC último mes de la mitad del periodo", Numero(b["InpcUltimoMesMitadPeriodo"], "#,##0.0000"));
        Campo(fiscal, "INPC de la fecha de adquisición", Numero(b["InpcFechaAdquisicion"], "#,##0.0000"));
        Campo(fiscal, "Factor de ajuste", Numero(b["FactoraAjuste"], "0.0000"));
        Campo(fiscal, "Valor actualizado pendiente de deducir", MontoBaja(b["ValorActualizadoPendienteDeducir"]));
        Campo(fiscal, "Utilidad fiscal en la venta", MontoBaja(b["UtilidadFiscalVenta"]), true);
        Campo(fiscal, "Pérdida fiscal en la venta", MontoBaja(b["PerdidaFiscalVenta"]), true);

        return new List<Dictionary<string, object>>
        {
            new Dictionary<string, object> { { "t", "Datos de la baja (registro " + Convert.ToInt32(b["Id"]) + ")" }, { "c", datos } },
            new Dictionary<string, object> { { "t", "Contable" }, { "c", contable } },
            new Dictionary<string, object> { { "t", "Fiscal · " + (convencional ? "convencional" : "acelerada") }, { "c", fiscal } }
        };
    }

    private static void Campo(List<Dictionary<string, object>> lista, string etiqueta, string valor, bool destacado = false)
    {
        Dictionary<string, object> c = new Dictionary<string, object> { { "k", etiqueta }, { "v", valor ?? "—" } };
        if (destacado) c["d"] = true;
        lista.Add(c);
    }

    private static string MontoBaja(object valor)
    {
        return valor == null || valor == DBNull.Value ? "—" : Moneda(valor);
    }

    private static string Numero(object valor, string formato)
    {
        return valor == null || valor == DBNull.Value ? "—" : Convert.ToDecimal(valor).ToString(formato, CulturaMx);
    }

    private static bool NoCero(object valor)
    {
        return valor != null && valor != DBNull.Value && Convert.ToDecimal(valor) != 0m;
    }

    // Bloqueo de aplicación (opcional de P6): evita que dos bajas o reversiones se
    // crucen entre sí. No protege contra un cálculo mensual en curso (H3).
    private static bool TomarBloqueoBaja(SqlConnection con)
    {
        using (SqlCommand cmd = new SqlCommand(
            "DECLARE @r int; EXEC @r = sp_getapplock @Resource = N'Deprecia_Baja', @LockMode = 'Exclusive', " +
            "@LockOwner = 'Session', @LockTimeout = 15000; SELECT @r;", con))
        {
            return Convert.ToInt32(cmd.ExecuteScalar()) >= 0;
        }
    }

    private static void SoltarBloqueoBaja(SqlConnection con)
    {
        try
        {
            using (SqlCommand cmd = new SqlCommand(
                "EXEC sp_releaseapplock @Resource = N'Deprecia_Baja', @LockOwner = 'Session';", con))
            {
                cmd.ExecuteNonQuery();
            }
        }
        catch (SqlException)
        {
            // El bloqueo de sesión se libera de todos modos al cerrar la conexión.
        }
    }

    // Registrar la baja con dbo.VentaBajaActivo sin cambios (un solo camino para venta
    // e inutilidad). Verificación antes (C#) y después (misma conexión), según P6.
    private Dictionary<string, object> RegistrarBaja(string json)
    {
        Dictionary<string, object> d;
        try { d = Json.Deserialize<Dictionary<string, object>>(json); }
        catch (ArgumentException) { d = null; }
        catch (InvalidOperationException) { d = null; }
        if (d == null)
            return Respuesta("registrar", false, "No se recibieron datos válidos.");

        int id = Ent(d, "id") ?? 0;
        string motivo = Txt(d, "motivo");
        DateTime? fecha = Fch(d, "fecha");
        decimal? precio = Dec(d, "precio");
        string factura = Txt(d, "factura");
        string texto = Txt(d, "texto");
        bool venta = motivo == "venta";

        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        {
            con.Open();

            EstadoBaja s = LeerEstadoBaja(con, id);
            if (s == null)
                return Respuesta("registrar", false, "El folio " + id + " no existe en la empresa actual.");
            if (s.Situacion != "libre")
                return Respuesta("registrar", false, s.Registros > 0 ? "El activo ya tiene baja registrada." : s.Motivo);

            Dictionary<string, string> err = new Dictionary<string, string>();
            if (motivo != "venta" && motivo != "inutilidad")
                err["motivo"] = "Elige el motivo: venta o inutilidad.";

            if (!fecha.HasValue)
                err["fecha"] = "La fecha de baja es obligatoria.";
            else if (fecha.Value < s.FechaMinima)
                err["fecha"] = "No puede ser anterior a la fecha de uso o de adquisición (" + Fecha(s.FechaMinima) + ").";
            else if (fecha.Value > DateTime.Today)
                err["fecha"] = "No puede ser posterior a hoy.";
            else
            {
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.CatalogoPeriodo WHERE Periodo = @Periodo", con))
                {
                    cmd.Parameters.Add("@Periodo", SqlDbType.Int).Value = fecha.Value.Year;
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                        err["fecha"] = "El ejercicio " + fecha.Value.Year + " no existe en el catálogo de periodos.";
                }
            }

            if (venta)
            {
                if (!precio.HasValue || precio.Value < 0m) err["precio"] = "Captura el precio de venta (0 o más).";
                else if (precio.Value > PrecioVentaMaximo) err["precio"] = "Máximo " + PrecioVentaMaximo.ToString("C2", CulturaMx) + ".";
                if (factura != null && factura.Length > 40) err["factura"] = "Máximo 40 caracteres.";
            }
            else
            {
                precio = 0m;          // inutilidad: sin precio ni factura
                factura = null;
            }
            if (texto != null && texto.Length > MotivoTextoMaximo)
                err["texto"] = "Máximo " + MotivoTextoMaximo + " caracteres.";

            if (err.Count > 0)
            {
                Dictionary<string, object> rErr = Respuesta("registrar", false, "Revisa los campos marcados.");
                rErr["errores"] = err;
                return rErr;
            }

            string mBaja = ((venta ? "VENTA: " : "INUTILIDAD: ") + (texto ?? string.Empty)).TrimEnd();
            if (mBaja.Length > 255) mBaja = mBaja.Substring(0, 255);

            if (!TomarBloqueoBaja(con))
                return Respuesta("registrar", false, "Hay otra baja en proceso; intenta de nuevo en unos segundos.");
            string errorSp = null;
            try
            {
                using (SqlCommand cmd = new SqlCommand("dbo.VentaBajaActivo", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 120;   // el SP encadena VentaBajaActivoCalculo
                    cmd.Parameters.Add("@IdActivo", SqlDbType.Int).Value = id;
                    cmd.Parameters.Add("@FechaVenta", SqlDbType.Date).Value = fecha.Value;
                    cmd.Parameters.Add("@NFactura", SqlDbType.NVarChar, 40).Value =
                        string.IsNullOrEmpty(factura) ? (object)DBNull.Value : factura;
                    SqlParameter pPrecio = cmd.Parameters.Add("@PrecioVenta", SqlDbType.Decimal);
                    pPrecio.Precision = 18; pPrecio.Scale = 2; pPrecio.Value = precio.Value;
                    cmd.Parameters.Add("@Mbaja", SqlDbType.VarChar, 255).Value = mBaja;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex)
            {
                errorSp = ex.Message;
            }
            finally
            {
                SoltarBloqueoBaja(con);
            }

            if (errorSp != null)
                return Respuesta("registrar", false, "No se registró la baja: " + errorSp);

            // VentaBajaActivo puede terminar sin error y sin hacer nada: se confirma en la base.
            EstadoBaja despues = LeerEstadoBaja(con, id);
            if (despues == null || despues.Situacion != "completa")
            {
                string detalle = despues == null ? "" :
                    " (fecha de baja: " + (despues.FechaBaja.HasValue ? Fecha(despues.FechaBaja) : "no") +
                    "; registros de baja: " + despues.Registros + "; cálculo de baja: " + despues.Fotos + ")";
                return Respuesta("registrar", false,
                    "El procedimiento terminó sin registrar la baja completa" + detalle +
                    ". Revisa que el activo tenga cálculo de depreciación del mes anterior a la baja." +
                    (despues != null && despues.Fotos > 0 && despues.Registros == 0 ? " Quedó un cálculo de baja sin registro: requiere revisión del administrador." : ""));
            }

            Dictionary<string, object> ok = Respuesta("registrar", true,
                "Baja registrada (folio " + id + ") el " + Fecha(fecha.Value) + ". La depreciación queda congelada al mes anterior.");
            ok["id"] = id;
            return ok;
        }
    }

    // Revertir con dbo.SP_RevertirBajaActivo sin cambios, después de validar la empresa y
    // las reglas; se confirma en la base que ya no quede nada de la baja.
    private Dictionary<string, object> RevertirBaja(string json)
    {
        Dictionary<string, object> d;
        try { d = Json.Deserialize<Dictionary<string, object>>(json); }
        catch (ArgumentException) { d = null; }
        catch (InvalidOperationException) { d = null; }
        if (d == null)
            return Respuesta("revertir", false, "No se recibieron datos válidos.");

        int id = Ent(d, "id") ?? 0;
        int idBajaCliente = Ent(d, "idBaja") ?? 0;

        using (SqlConnection con = new SqlConnection(ConexionDeprecia))
        {
            con.Open();

            EstadoBaja s = LeerEstadoBaja(con, id);
            if (s == null)
                return Respuesta("revertir", false, "El folio " + id + " no existe en la empresa actual.");
            if (s.Situacion != "completa")
                return Respuesta("revertir", false, s.Situacion == "libre" ? "El activo ya no tiene baja registrada." : s.Motivo);

            int idBaja = Convert.ToInt32(s.Baja["Id"]);
            if (idBaja != idBajaCliente)
                return Respuesta("revertir", false, "La baja cambió desde que abriste la ventana; ciérrala y vuelve a abrirla.");

            DateTime fechaVenta = Convert.ToDateTime(s.Baja["FechaVenta"]);
            string razon = RazonNoRevertir(con, fechaVenta);
            if (razon != null)
                return Respuesta("revertir", false, razon);

            if (!TomarBloqueoBaja(con))
                return Respuesta("revertir", false, "Hay otra baja en proceso; intenta de nuevo en unos segundos.");
            int resultado = 0;
            string mensajeSp = "No se recibió respuesta del procedimiento.";
            try
            {
                using (SqlCommand cmd = new SqlCommand("dbo.SP_RevertirBajaActivo", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.Add("@Id", SqlDbType.Int).Value = idBaja;
                    cmd.Parameters.Add("@IdActivo", SqlDbType.Int).Value = id;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            resultado = Convert.ToInt32(dr["Resultado"]);
                            mensajeSp = Convert.ToString(dr["Mensaje"]);
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                // Si el registro no existe el SP lanza RAISERROR antes de devolver su renglón.
                resultado = 0;
                mensajeSp = ex.Message;
            }
            finally
            {
                SoltarBloqueoBaja(con);
            }

            EstadoBaja despues = LeerEstadoBaja(con, id);
            bool limpio = despues != null && despues.Registros == 0 && !despues.FechaBaja.HasValue && despues.Fotos == 0;

            if (resultado != 1)
                return Respuesta("revertir", false, "No se revirtió la baja: " + mensajeSp);
            if (!limpio)
                return Respuesta("revertir", false,
                    "El procedimiento respondió con éxito pero la baja no quedó revertida por completo (registros de baja: " +
                    (despues == null ? "?" : despues.Registros.ToString()) + "; fecha de baja: " +
                    (despues != null && despues.FechaBaja.HasValue ? Fecha(despues.FechaBaja) : "no") + "; cálculo de baja: " +
                    (despues == null ? "?" : despues.Fotos.ToString()) + "). Requiere revisión del administrador.");

            Dictionary<string, object> ok = Respuesta("revertir", true,
                "Baja revertida (folio " + id + "). El activo vuelve a estar vigente: recalcula desde " +
                NombresMes[fechaVenta.Month - 1] + " " + fechaVenta.Year + " para actualizar su depreciación.");
            ok["id"] = id;
            return ok;
        }
    }

    #endregion

    #region Lectura segura del JSON del cliente

    private static string Txt(Dictionary<string, object> d, string k)
    {
        object v;
        if (!d.TryGetValue(k, out v) || v == null) return null;
        string s = Convert.ToString(v, CultureInfo.InvariantCulture).Trim();
        return s.Length == 0 ? null : s;
    }

    private static int? Ent(Dictionary<string, object> d, string k)
    {
        int n;
        string s = Txt(d, k);
        return s != null && int.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out n) ? n : (int?)null;
    }

    private static decimal? Dec(Dictionary<string, object> d, string k)
    {
        decimal n;
        string s = Txt(d, k);
        return s != null && decimal.TryParse(s, NumberStyles.Number | NumberStyles.AllowExponent, CultureInfo.InvariantCulture, out n)
            ? Math.Round(n, 4) : (decimal?)null;
    }

    private static DateTime? Fch(Dictionary<string, object> d, string k)
    {
        DateTime f;
        string s = Txt(d, k);
        return s != null && DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out f)
               && f.Year >= 1900 && f.Year <= 2100 ? f : (DateTime?)null;
    }

    private static bool Bool(Dictionary<string, object> d, string k)
    {
        object v;
        return d.TryGetValue(k, out v) && v is bool && (bool)v;
    }

    private static Dictionary<string, object> Sub(Dictionary<string, object> d, string k)
    {
        object v;
        return d.TryGetValue(k, out v) ? v as Dictionary<string, object> : null;
    }

    #endregion
}
