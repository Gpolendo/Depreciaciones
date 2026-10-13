using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class ReporteBajasDepreciaciones : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            CargarBajas();
    }

    private void CargarBajas()
    {
        string RFC = MySession.Current.RFCEmpresaActual;
        string ConexionDeprecia = ConfigurationManager
                                    .ConnectionStrings["ConexionDeprecia"]
                                    .ConnectionString;

        using (SqlConnection connection = new SqlConnection(ConexionDeprecia))
        {
            connection.Open();
            SqlCommand cmd = connection.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    ABA.Id                                          AS IdBaja,
                    ABA.IdActivo,
                    CC.Grupo,
                    ACT.FechaAdquisicion,
                    ACT.Descripcion,
                    ABA.FechaVenta,
                    ACT.Moi,
                    ACT.MoiFiscal,
                    ABA.NumFactura,
                    ABA.PrecioVenta,
                    ABA.ImporteContableDepreciado,
                    ABA.RemanenteContableDepreciar,
                    ABA.UtilidadContable,
                    ABA.PerdidaContable,
                    ABA.ImporteFiscalDeducido,
                    ABA.AniosDepreciacionFiscalDI,
                    ABA.PorcentajeFiscalDI,
                    ABA.PorcentajeFiscalAplicarDI,
                    ABA.MoiPorcentajeFiscalAplicarDI,
                    ABA.RemanentePendienteDeducir,
                    ABA.InpcUltimoMesMitadPeriodo,
                    ABA.InpcFechaAdquisicion,
                    ABA.FactoraAjuste,
                    ABA.ValorActualizadoPendienteDeducir,
                    ABA.UtilidadFiscalVenta,
                    ABA.PerdidaFiscalVenta
                FROM  [dbo].[ActivosBaja]          ABA
                INNER JOIN [dbo].[Activos]          ACT ON ABA.IdActivo   = ACT.Id
                INNER JOIN [dbo].[CatalogoCuentas]  CC  ON ACT.IdCatalogo = CC.Id
                INNER JOIN [dbo].[Empresas]         EMP ON ACT.IdEmpresa  = EMP.Id
                WHERE EMP.RFC = @RFC";

            cmd.Parameters.AddWithValue("@RFC", RFC);

            SqlDataAdapter sda = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            sda.Fill(dt);

            // Columnas calculadas en C# para que Eval() las encuentre de forma fiable
            // sin depender de conversiones dentro del ASPX
            dt.Columns.Add("FechaVentaTexto", typeof(string));
            dt.Columns.Add("AnioFechaVenta", typeof(int));

            foreach (DataRow row in dt.Rows)
            {
                if (row["FechaVenta"] != DBNull.Value)
                {
                    DateTime fv = Convert.ToDateTime(row["FechaVenta"]);
                    row["FechaVentaTexto"] = fv.ToString("dd/MM/yyyy");
                    row["AnioFechaVenta"] = fv.Year;
                }
                else
                {
                    row["FechaVentaTexto"] = "";
                    row["AnioFechaVenta"] = 0;
                }
            }

            GvBajas.DataSource = dt;
            GvBajas.DataBind();
        }
    }

    // PerformCallback('REVERTIR|idBaja|idActivo') aterriza aquí
    protected void GvBajas_CustomCallback(object sender,
        DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
    {
        if (string.IsNullOrEmpty(e.Parameters)) return;

        string[] partes = e.Parameters.Split('|');
        if (partes.Length < 3 || partes[0] != "REVERTIR") return;

        int idBaja = Convert.ToInt32(partes[1]);
        int idActivo = Convert.ToInt32(partes[2]);

        // Validación de año en servidor — consulta directo a BD
        string connStr = ConfigurationManager
                           .ConnectionStrings["ConexionDeprecia"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            SqlCommand cmdFecha = conn.CreateCommand();
            cmdFecha.CommandText =
                "SELECT FechaVenta FROM [dbo].[ActivosBaja] WHERE Id=@Id AND IdActivo=@IdActivo";
            cmdFecha.Parameters.AddWithValue("@Id", idBaja);
            cmdFecha.Parameters.AddWithValue("@IdActivo", idActivo);

            object fvObj = cmdFecha.ExecuteScalar();
            if (fvObj != null && fvObj != DBNull.Value)
            {
                DateTime fechaVenta = Convert.ToDateTime(fvObj);
                if (fechaVenta.Year != DateTime.Now.Year)
                {
                    GvBajas.JSProperties["cpMensaje"] =
                        "ERR|No es posible revertir la baja. La fecha de baja/venta (" +
                        fechaVenta.ToString("dd/MM/yyyy") + ") pertenece al año " +
                        fechaVenta.Year + ", y sólo se permiten reversiones del año en curso (" +
                        DateTime.Now.Year + ").";
                    return;
                }
            }
        }

        string resultado = RevertirBaja(idBaja, idActivo);
        CargarBajas();
        GvBajas.JSProperties["cpMensaje"] = resultado;
    }

    private string RevertirBaja(int id, int idActivo)
    {
        string connStr = ConfigurationManager
                           .ConnectionStrings["ConexionDeprecia"].ConnectionString;
        try
        {
            using (SqlConnection connection = new SqlConnection(connStr))
            {
                connection.Open();
                using (SqlCommand cmd = new SqlCommand("SP_RevertirBajaActivo", connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Id", id);
                    cmd.Parameters.AddWithValue("@IdActivo", idActivo);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int resultado = Convert.ToInt32(reader["Resultado"]);
                            string mensaje = reader["Mensaje"].ToString();
                            return resultado == 1 ? "OK|" + mensaje : "ERR|" + mensaje;
                        }
                    }
                }
            }
            return "ERR|No se recibió respuesta del servidor.";
        }
        catch (Exception ex)
        {
            return "ERR|" + ex.Message;
        }
    }
}
