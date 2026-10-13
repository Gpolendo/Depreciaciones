using DevExpress.Web;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

public partial class CalcularDepreciaciones : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    #region Controles

    //Recalcular Depreciacion
    protected void BRecalcular_Click(object sender, EventArgs e)
    {
        CalcularDepreciacion(true);
    }

    //Evento de cambio de fecha
    protected void deFecha_DateChanged(object sender, EventArgs e)
    {
        CalcularDepreciacion(false);
    }

    //El usuario canceló usar el INPC anterior -> limpiar los grids y recordar el mes rechazado
    protected void BLimpiarGrids_Click(object sender, EventArgs e)
    {
        // Limpiar flags de fallback
        Session["InpcFallbackPendiente"] = null;
        Session["InpcFallbackRecalculo"] = null;

        // Guardar la fecha del mes rechazado para que deFecha_DateChanged no vuelva a preguntar si el control sigue apuntando a ese mes.
        Session["InpcFallbackMesRechazado"] = deFecha.Text;

        LimpiarGrids();
    }

    //El usuario aceptó usar el INPC de un mes anterior
    protected void BConfirmarInpcAnterior_Click(object sender, EventArgs e)
    {
        if (Session["InpcFallbackPendiente"] != null && (bool)Session["InpcFallbackPendiente"])
        {
            bool recalculo = Session["InpcFallbackRecalculo"] != null && (bool)Session["InpcFallbackRecalculo"];

            // Limpiamos el estado pendiente para no reprocesar por error
            Session["InpcFallbackPendiente"] = null;
            Session["InpcFallbackRecalculo"] = null;

            EjecutarCalculoFallback(recalculo);
        }
    }

    #endregion

    #region Funciones

    public void CalcularDepreciacion(bool Recalculo)
    {
        // Limpiar siempre el flag de fallback al iniciar un nuevo intento de cálculo.
        // Esto evita que un postback posterior (cambio de mes, recarga) reactive el Swal.
        Session["InpcFallbackPendiente"] = null;
        Session["InpcFallbackRecalculo"] = null;

        DateTime FechaFinal;
        if (DateTime.TryParse(deFecha.Text, out FechaFinal))
        {
            // Si el usuario ya canceló el Swal para este mes exacto, no volver a preguntar.
            // Solo se libera el bloqueo si cambia a otro mes o presiona Reprocesar.
            string mesRechazado = Session["InpcFallbackMesRechazado"] as string;
            if (!Recalculo && !string.IsNullOrEmpty(mesRechazado) && mesRechazado == deFecha.Text)
                return;

            // Si la fecha cambió respecto al mes rechazado, liberar el bloqueo.
            if (!string.IsNullOrEmpty(mesRechazado) && mesRechazado != deFecha.Text)
                Session["InpcFallbackMesRechazado"] = null;
            // Formato original usado por ObtenerDetallePorId (NO modificar)
            string fechaparainpc = FechaFinal.ToString("yyyy/dd/MM");
            Session["FechasConsulta"] = fechaparainpc;

            string conexion = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;
            string RFC = MySession.Current.RFCEmpresaActual;

            using (SqlConnection con = new SqlConnection(conexion))
            {
                con.Open();

                // 1) Empresa
                SqlCommand com = con.CreateCommand();
                com.CommandText = @"SELECT TOP(1) Id FROM Deprecia.dbo.Empresas WHERE RFC = @RFC";
                com.Parameters.AddWithValue("@RFC", RFC);
                var resultadoEmpresa = com.ExecuteScalar();

                if (resultadoEmpresa == null)
                {
                    MostrarSweetAlert("Error", "No se encontró la empresa para el RFC actual.", "error");
                    return;
                }

                int IdEmpresa = (int)resultadoEmpresa;
                Session["IdEmpresa"] = IdEmpresa;

                int anio = FechaFinal.Year;
                int mes = FechaFinal.Month;

                // 2) Si ya existe cálculo para este mes y NO es un reproceso explícito,
                //    simplemente cargar el histórico sin tocar el INPC ni mostrar advertencias.
                if (!Recalculo)
                {
                    com = con.CreateCommand();
                    com.CommandText = @"SELECT COUNT(1)
                                        FROM CalculoDetalle_Historico CDH
                                        INNER JOIN CatalogoPeriodo CPE ON CDH.IdPeriodo = CPE.Id
                                        WHERE CDH.IdEmpresa = @IdEmpresa
                                          AND CPE.Periodo   = @Anio
                                          AND CDH.IdMes     = @Mes";
                    com.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
                    com.Parameters.Add(new SqlParameter("@Anio", SqlDbType.VarChar)).Value = anio.ToString();
                    com.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mes;
                    int countExistente = (int)com.ExecuteScalar();

                    if (countExistente > 0)
                    {
                        // Ya calculado: solo mostrar datos, habilitar reproceso y salir.
                        CargarCalculosActivosHistorico(1, anio.ToString(), mes);
                        CargarCalculosActivosHistorico(0, anio.ToString(), mes);
                        CargarVigentes(1, anio.ToString(), mes);
                        CargarDatosActivos(IdEmpresa, anio.ToString(), mes);
                        BRecalcular.Enabled = true;

                        // Banner al abrir un mes ya calculado (CORR-INPC-2, 06/10/2026):
                        //  a) sin INPC del mes -> el cálculo guardado usó el de un mes anterior;
                        //  b) con INPC del mes, pero capturado DESPUÉS del cálculo guardado ->
                        //     el cálculo se hizo sin él y hay que reprocesar;
                        //  c) activos que quedaron con INPC neutro (1.0000), igual que al calcular.
                        // La fecha en Inpc se codifica AAAA-01-MM (mes en posición del DÍA).
                        string fechaInpcMes = FechaFinal.ToString("yyyy/dd/MM");
                        string avisoInpc = AvisoInpcCalculoGuardado(con, FechaFinal, fechaInpcMes, IdEmpresa, anio.ToString(), mes);
                        MostrarBannerInpc(avisoInpc, ContarActivosSinInpc(con, IdEmpresa, anio, mes));

                        return;
                    }
                }

                // 3) ¿Existe INPC para el mes solicitado? (igualdad exacta, comportamiento original)
                com = con.CreateCommand();
                com.CommandText = @"SELECT TOP(1) Idnpc FROM Deprecia.dbo.Inpc WHERE Fecha = @Fecha";
                com.Parameters.AddWithValue("@Fecha", fechaparainpc);
                var inpcExacto = com.ExecuteScalar();

                if (inpcExacto != null)
                {
                    // Hay INPC del mes -> cálculo normal, sin advertencia
                    EjecutarConFecha(FechaFinal, IdEmpresa, Recalculo);
                }
                else
                {
                    // 4) No hay INPC del mes -> buscar el último INPC de un mes ANTERIOR.
                    //    OJO: en la tabla Inpc la fecha se guarda codificada como AAAA-01-MM
                    //    (el número de mes va en la posición del DÍA). Por eso comparamos contra
                    //    la fecha codificada del mes seleccionado y filtramos por el mismo año.
                    com = con.CreateCommand();
                    com.CommandText = @"SELECT TOP(1) Fecha
                                        FROM Deprecia.dbo.Inpc
                                        WHERE Fecha < @FechaInpcMes
                                        ORDER BY Fecha DESC";
                    com.Parameters.AddWithValue("@FechaInpcMes", fechaparainpc);
                    //com.Parameters.Add(new SqlParameter("@Anio", SqlDbType.Int)).Value = FechaFinal.Year;
                    var fechaInpcAnterior = com.ExecuteScalar();

                    if (fechaInpcAnterior != null)
                    {
                        // Hay un INPC anterior disponible -> pedir confirmación al usuario
                        ConfirmarInpcAnterior(Convert.ToDateTime(fechaInpcAnterior), Recalculo);
                    }
                    else
                    {
                        // No hay ningún INPC (ni del mes ni anterior)
                        MostrarSweetAlert("Error", "No existe ningún valor de INPC para realizar el cálculo.", "error");
                    }
                }
            }
        }
    }

    // Muestra la advertencia/confirmación y, si el usuario acepta, dispara el postback del botón oculto
    private void ConfirmarInpcAnterior(DateTime fechaInpcAnterior, bool Recalculo)
    {
        // Guardamos el estado para retomar el cálculo tras la confirmación
        Session["InpcFallbackPendiente"] = true;
        Session["InpcFallbackRecalculo"] = Recalculo;

        // La fecha viene codificada como AAAA-01-MM (el mes real está en la posición del DÍA).
        int mesReal = fechaInpcAnterior.Day;
        int anioReal = fechaInpcAnterior.Year;
        DateTime fechaReal = new DateTime(anioReal, mesReal, 1);
        string mesAnterior = fechaReal.ToString("MMMM 'de' yyyy", new CultureInfo("es-MX"));
        // Usamos __doPostBack con el UniqueID del botón oculto para disparar el postback
        // desde SweetAlert sin depender del ClientID generado por el naming container.
        string uniqueId = BConfirmarInpcAnterior.UniqueID;

        string uniqueIdLimpiar = BLimpiarGrids.UniqueID;

        string script = $@"
        Swal.fire({{
            title: 'INPC del mes no disponible',
            html: 'No existe INPC para el mes seleccionado.<br>Se utilizará el último INPC disponible, correspondiente a <b>{mesAnterior}</b> (mes anterior).<br><br>¿Desea continuar con el cálculo?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sí, continuar',
            cancelButtonText: 'Cancelar',
            reverseButtons: true
        }}).then(function (result) {{
            if (result.isConfirmed) {{
                __doPostBack('{uniqueId}', '');
            }} else {{
                __doPostBack('{uniqueIdLimpiar}', '');
            }}
        }});";

        ScriptManager.RegisterStartupScript(this, this.GetType(),
            Guid.NewGuid().ToString(), script, true);
    }

    // Reanuda el cálculo después de que el usuario aceptó usar el INPC anterior
    private void EjecutarCalculoFallback(bool Recalculo)
    {
        DateTime FechaFinal;
        if (!DateTime.TryParse(deFecha.Text, out FechaFinal))
            return;

        Session["FechasConsulta"] = FechaFinal.ToString("yyyy/dd/MM");

        string conexion = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;
        string RFC = MySession.Current.RFCEmpresaActual;

        using (SqlConnection con = new SqlConnection(conexion))
        {
            con.Open();

            // Recuperar el INPC anterior que se usará para mostrar el mes en el banner.
            // CORR-INPC-1 (06/10/2026): el aviso ya no se pinta aquí (EjecutarConFecha lo
            // borraba enseguida); se pasa al cálculo, que lo muestra al terminar.
            string fechaparainpc = FechaFinal.ToString("yyyy/dd/MM");
            string avisoInpc = AvisoInpcAnterior(con, FechaFinal, fechaparainpc, false);

            SqlCommand com = con.CreateCommand();
            com.CommandText = @"SELECT TOP(1) Id FROM Deprecia.dbo.Empresas WHERE RFC = @RFC";
            com.Parameters.AddWithValue("@RFC", RFC);
            var resultadoEmpresa = com.ExecuteScalar();

            if (resultadoEmpresa == null)
            {
                MostrarSweetAlert("Error", "No se encontró la empresa para el RFC actual.", "error");
                return;
            }

            EjecutarConFecha(FechaFinal, (int)resultadoEmpresa, Recalculo, avisoInpc);
        }
    }

    // Calcula el mes. avisoInpc = aviso de "se usó el INPC de un mes anterior" (null si el
    // mes tiene INPC propio). CORR-INPC-1: el banner ya no se oculta aquí; lo decide
    // EjecutarCalculoDepreciacion al terminar, con el aviso y el conteo de INPC neutro.
    private void EjecutarConFecha(DateTime FechaFinal, int IdEmpresa, bool Recalculo, string avisoInpc = null)
    {
        Session["IdEmpresa"] = IdEmpresa;
        int anio = deFecha.Date.Year;
        int mes = deFecha.Date.Month;
        DateTime fechaFinal = new DateTime(anio, mes, DateTime.DaysInMonth(anio, mes));
        string fechaFormateada = FechaFinal.ToString("yyyy/MM/dd");
        string AnioCalcular = FechaFinal.ToString("yyyy");
        EjecutarCalculoDepreciacion(fechaFormateada, IdEmpresa, AnioCalcular, mes, Recalculo, avisoInpc);
    }

    public void EjecutarCalculoDepreciacion(string fechaFinal, int IdEmpresa, string AnioCalcular, int mesx, bool Recalcular, string avisoInpc = null)
    {
        string ConexionCalcular = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;

        using (SqlConnection connection = new SqlConnection(ConexionCalcular))
        {
            try
            {
                connection.Open();

                string queryVerificacion = "SELECT COUNT(1) FROM CalculoDetalle_Historico CDH INNER JOIN CatalogoPeriodo CPE ON CDH.IdPeriodo= CPE.Id WHERE IdEmpresa =@IdEmpresa AND Periodo = @AnioCalcular AND IdMes = @Mes";
                using (SqlCommand cmdVerificacion = new SqlCommand(queryVerificacion, connection))
                {
                    cmdVerificacion.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
                    cmdVerificacion.Parameters.Add(new SqlParameter("@AnioCalcular", SqlDbType.VarChar)).Value = AnioCalcular;
                    cmdVerificacion.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mesx;

                    int count = (int)cmdVerificacion.ExecuteScalar();

                    if (count > 0 && Recalcular == false)
                    {
                        CargarCalculosActivosHistorico(1, AnioCalcular, mesx);
                        CargarCalculosActivosHistorico(0, AnioCalcular, mesx);
                        CargarVigentes(1, AnioCalcular, mesx);
                        CargarDatosActivos(IdEmpresa, AnioCalcular, mesx);
                        BRecalcular.Enabled = true;
                        MostrarBannerInpc(avisoInpc, ContarActivosSinInpc(connection, IdEmpresa, Convert.ToInt32(AnioCalcular), mesx));
                    }
                    else
                    //{
                    //    using (SqlCommand command = new SqlCommand("CalculoDepreciacionMensual", connection))
                    //    {
                    //        command.CommandType = CommandType.StoredProcedure;

                    //        command.Parameters.Add(new SqlParameter("@Fechafinal", SqlDbType.Date)).Value = fechaFinal;
                    //        command.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
                    //        command.Parameters.Add(new SqlParameter("@EjercicioVigente", SqlDbType.VarChar)).Value = AnioCalcular;

                    //        command.ExecuteNonQuery();
                    //    }
                    //    CargarCalculosActivos(1);
                    //    CargarCalculosActivos(0);
                    //    CargarDatosActivos(IdEmpresa, AnioCalcular, mesx);
                    //}


                    {
                        using (SqlCommand command = new SqlCommand("CalculoDepreciacionMensual", connection))
                        {
                            command.CommandType = CommandType.StoredProcedure;

                            command.Parameters.Add(new SqlParameter("@Fechafinal", SqlDbType.Date)).Value = fechaFinal;
                            command.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
                            command.Parameters.Add(new SqlParameter("@EjercicioVigente", SqlDbType.VarChar)).Value = AnioCalcular;

                            command.ExecuteNonQuery();
                        }
                        // AJUSTE-BANNER-INPC: el chequeo previo solo valida el INPC del mes
                        // de corte, que casi nunca es el mes que cada activo usa internamente
                        // (mitad de periodo utilizado, mes de adquisicion). Aqui se valida lo
                        // que el calculo REALMENTE uso (ContarActivosSinInpc).
                        // CORR-INPC-1: el aviso de INPC anterior (si lo hay) se conserva y se
                        // suma al de datos incompletos, en lugar de borrarse.
                        MostrarBannerInpc(avisoInpc, ContarActivosSinInpc(connection, IdEmpresa, Convert.ToInt32(AnioCalcular), mesx));

                        CargarCalculosActivos(1);
                        CargarCalculosActivos(0);
                        CargarDatosActivos(IdEmpresa, AnioCalcular, mesx);
                    }



                }
            }
            catch (Exception ex)
            {
                MostrarSweetAlert("Error", "Ocurrió un error al calcular la depreciación: " + ex.Message, "error");
            }
        }
    }

    private void CargarCalculosActivos(int convencional)
    {
        // Calculo VIVO (tabla CalculoDetalle). Se invoca el SP con
        // @Origen='VIVO'; el SP deriva periodo y mes de los datos.
        // Antes esto era SQL embebido y se desincronizo del SP.
        int IdEmpresa = (int)Session["IdEmpresa"];
        string ConexionDeprecia = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;

        using (SqlConnection connection = new SqlConnection(ConexionDeprecia))
        {
            connection.Open();
            SqlCommand comando = connection.CreateCommand();
            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "sp_ReporteDepreciacion";
            comando.CommandTimeout = 180;

            comando.Parameters.Add(new SqlParameter("@Periodo", SqlDbType.VarChar, 10)).Value = DBNull.Value;
            comando.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = DBNull.Value;
            comando.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
            comando.Parameters.Add(new SqlParameter("@Convencional", SqlDbType.TinyInt)).Value = convencional;
            comando.Parameters.Add(new SqlParameter("@Origen", SqlDbType.VarChar, 10)).Value = "VIVO";

            SqlDataAdapter sda = new SqlDataAdapter(comando);
            DataTable dt = new DataTable();
            sda.Fill(dt);

            if (convencional == 1)
            {
                GvCalculo.DataSource = dt;
                GvCalculo.DataBind();
            }
            else
            {
                GvCalculoNoC.DataSource = dt;
                GvCalculoNoC.DataBind();
            }
        }
    }

    private void CargarCalculosActivosHistorico(int convencional, string AnioCalcular, int mesx)
    {
        // Cierre guardado (CalculoDetalle_Historico). Se invoca el SP en
        // lugar de repetir la consulta: el SP aporta #BajasRecientes,
        // el filtro de universo con >=, la vigencia por fecha completa
        // y el criterio Excel (contable resta bajas, fiscal las suma).
        int IdEmpresa = (int)Session["IdEmpresa"];
        string ConexionDeprecia = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;

        using (SqlConnection connection = new SqlConnection(ConexionDeprecia))
        {
            connection.Open();
            SqlCommand comando = connection.CreateCommand();
            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "sp_ReporteDepreciacion";
            comando.CommandTimeout = 180;

            comando.Parameters.Add(new SqlParameter("@Periodo", SqlDbType.VarChar, 10)).Value = AnioCalcular;
            comando.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mesx;
            comando.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
            comando.Parameters.Add(new SqlParameter("@Convencional", SqlDbType.TinyInt)).Value = convencional;
            comando.Parameters.Add(new SqlParameter("@Origen", SqlDbType.VarChar, 10)).Value = "HISTORICO";

            SqlDataAdapter sda = new SqlDataAdapter(comando);
            DataTable dt = new DataTable();
            sda.Fill(dt);

            if (convencional == 1)
            {
                GvCalculo.DataSource = dt;
                GvCalculo.DataBind();
            }
            else
            {
                GvCalculoNoC.DataSource = dt;
                GvCalculoNoC.DataBind();
            }
        }
    }

    private void LimpiarGrids()
    {
        DataTable dtVacio = new DataTable();

        GvCalculo.DataSource = dtVacio;
        GvCalculo.DataBind();

        GvCalculoNoC.DataSource = dtVacio;
        GvCalculoNoC.DataBind();

        gvActivos.DataSource = dtVacio;
        gvActivos.DataBind();

        // CORR-INPC-4 (06/10/2026): la pestaña Vigentes también se limpia; antes se
        // quedaba con los datos del mes anterior al cancelar el INPC anterior.
        GvVigentes.DataSource = dtVacio;
        GvVigentes.DataBind();

        BRecalcular.Enabled = false;

        // Ocultar el banner de advertencia de INPC anterior
        PanelInpcAnterior.Visible = false;
        LitMensajeInpc.Text = string.Empty;
    }

    #region Banner de INPC (CORR-INPC, 06/10/2026)

    private static readonly CultureInfo CulturaMx = new CultureInfo("es-MX");

    // Muestra el banner con los avisos que apliquen, uno por renglón; si no hay ninguno, lo oculta.
    private void MostrarBannerInpc(string avisoInpc, int activosSinInpc)
    {
        var avisos = new System.Collections.Generic.List<string>();
        if (!string.IsNullOrEmpty(avisoInpc))
            avisos.Add(avisoInpc);
        if (activosSinInpc > 0)
            avisos.Add($"Cálculo con datos incompletos: {activosSinInpc} activo(s) no tienen "
                     + "el índice de inflación (INPC) necesario para su periodo de cálculo "
                     + "(mes de adquisición o mitad del periodo utilizado). Se usó un valor "
                     + "neutro para esos activos. Recalcule cuando se publique el INPC correspondiente.");

        PanelInpcAnterior.Visible = avisos.Count > 0;
        LitMensajeInpc.Text = string.Join("<br />", avisos);
    }

    // CORR-INPC-3 (06/10/2026): activos del mes calculado que quedaron con INPC neutro
    // (1.0000) cuando SÍ lo necesitaban. Según CalculoDepreciacionMensual, el SP también
    // pone 1.0000 a propósito cuando el INPC no aplica (fecha centinela 1910-01-01):
    //   - sin meses efectivos fiscales en el ejercicio, o
    //   - acelerada adquirida en otro ejercicio.
    // Esos casos no se cuentan. Antes solo se revisaban convencionales y sin excluir
    // los que no aplican (p. ej. activos ya deducidos en su totalidad).
    private static int ContarActivosSinInpc(SqlConnection con, int idEmpresa, int anio, int mes)
    {
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT COUNT(DISTINCT CDH.IdActivo)
            FROM CalculoDetalle_Historico CDH
            INNER JOIN CatalogoPeriodo CPE ON CDH.IdPeriodo = CPE.Id
            INNER JOIN Activos ACT ON ACT.Id = CDH.IdActivo
            WHERE CDH.IdEmpresa = @IdEmpresa AND CPE.Periodo = @Periodo AND CDH.IdMes = @Mes
              AND CDH.Meses_Efectivos_Fiscales > 0
              AND (CDH.Convencional = 1 OR YEAR(ACT.FechaAdquisicion) = @Anio)
              AND (CDH.InpcMitadPeriodo = 1.0000 OR CDH.InpcFechaAdquisicion = 1.0000)", con))
        {
            cmd.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = idEmpresa;
            cmd.Parameters.Add(new SqlParameter("@Periodo", SqlDbType.VarChar, 10)).Value = anio.ToString();
            cmd.Parameters.Add(new SqlParameter("@Anio", SqlDbType.Int)).Value = anio;
            cmd.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mes;
            return Convert.ToInt32(cmd.ExecuteScalar());
        }
    }

    // "Cálculo estimado: … Se utilizó el INPC de {mes}." a partir del último INPC anterior al
    // mes seleccionado. fechaInpcMes viene codificada AAAA-01-MM (mes en la posición del día).
    // generico = true: si no hay INPC anterior, regresa el aviso sin el mes usado; si no, null.
    private static string AvisoInpcAnterior(SqlConnection con, DateTime fechaSeleccionada, string fechaInpcMes, bool generico)
    {
        object fechaInpcAnterior;
        using (SqlCommand cmd = new SqlCommand(@"SELECT TOP(1) Fecha
                                                 FROM Deprecia.dbo.Inpc
                                                 WHERE Fecha < @FechaInpcMes
                                                 ORDER BY Fecha DESC", con))
        {
            cmd.Parameters.AddWithValue("@FechaInpcMes", fechaInpcMes);
            fechaInpcAnterior = cmd.ExecuteScalar();
        }


        string mesSeleccionado = fechaSeleccionada.ToString("MMMM 'de' yyyy", CulturaMx);
        if (fechaInpcAnterior != null && fechaInpcAnterior != DBNull.Value)
        {
            DateTime codificada = Convert.ToDateTime(fechaInpcAnterior);
            string mesInpc = new DateTime(codificada.Year, codificada.Day, 1).ToString("MMMM 'de' yyyy", CulturaMx);
            return $"Cálculo estimado: el INPC del mes seleccionado ({mesSeleccionado}) "
                 + $"aún no está disponible. Se utilizó el INPC de {mesInpc}. "
                 + "Recalcule cuando se publique el INPC oficial.";
        }

        return generico
            ? $"Cálculo estimado: el INPC del mes seleccionado ({mesSeleccionado}) no estaba disponible al calcular. "
              + "Recalcule cuando se publique el INPC oficial."
            : null;
    }

    // Aviso al abrir un mes ya calculado (CORR-INPC-2):
    //  - sin INPC del mes: el cálculo guardado usó uno anterior;
    //  - con INPC del mes capturado después del cálculo guardado: hay que reprocesar.
    private static string AvisoInpcCalculoGuardado(SqlConnection con, DateTime fechaSeleccionada, string fechaInpcMes,
                                                   int idEmpresa, string periodo, int mes)
    {
        object capturaInpc;
        using (SqlCommand cmd = new SqlCommand(@"SELECT TOP(1) FechaCaptura FROM Deprecia.dbo.Inpc WHERE Fecha = @Fecha", con))
        {
            cmd.Parameters.AddWithValue("@Fecha", fechaInpcMes);
            capturaInpc = cmd.ExecuteScalar();
        }

        if (capturaInpc == null || capturaInpc == DBNull.Value)
            return AvisoInpcAnterior(con, fechaSeleccionada, fechaInpcMes, true);

        object procesado;
        using (SqlCommand cmd = new SqlCommand(@"
            SELECT MAX(CDH.FechaProcesado)
            FROM CalculoDetalle_Historico CDH
            INNER JOIN CatalogoPeriodo CPE ON CDH.IdPeriodo = CPE.Id
            WHERE CDH.IdEmpresa = @IdEmpresa AND CPE.Periodo = @Periodo AND CDH.IdMes = @Mes", con))
        {
            cmd.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = idEmpresa;
            cmd.Parameters.Add(new SqlParameter("@Periodo", SqlDbType.VarChar, 10)).Value = periodo;
            cmd.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mes;
            procesado = cmd.ExecuteScalar();
        }

        if (procesado == null || procesado == DBNull.Value)
            return null;

        DateTime fechaCaptura = Convert.ToDateTime(capturaInpc);
        DateTime fechaCalculo = Convert.ToDateTime(procesado);
        if (fechaCaptura <= fechaCalculo)
            return null;

        return $"El INPC de {fechaSeleccionada.ToString("MMMM 'de' yyyy", CulturaMx)} se registró el "
             + $"{fechaCaptura:dd/MM/yyyy}, después del cálculo guardado ({fechaCalculo:dd/MM/yyyy}). "
             + "Presione Reprocesar para actualizar el cálculo con el INPC oficial.";
    }

    #endregion

    public void MostrarSweetAlert(string titulo, string mensaje, string tipo = "success")
    {
        string script = $@"
        Swal.fire({{
            title: '{titulo.Replace("'", "\\'")}',
            text: '{mensaje.Replace("'", "\\'")}',
            icon: '{tipo}',
            confirmButtonText: 'OK'
        }});";

        ScriptManager.RegisterStartupScript(this, this.GetType(),
            Guid.NewGuid().ToString(), script, true);
    }


    private DataSet ObtenerDesglose(string grupo, string vista, int convencional)
    {
        int IdEmpresa = (int)Session["IdEmpresa"];
        string ConexionDeprecia =
            ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;

        // Mismo criterio de fecha que usan los grids: se toma de deFecha.
        DateTime fecha = deFecha.Date == DateTime.MinValue ? DateTime.Today : deFecha.Date;
        string anio = fecha.Year.ToString();
        int mes = fecha.Month;

        DataSet ds = new DataSet();

        using (SqlConnection cn = new SqlConnection(ConexionDeprecia))
        {
            cn.Open();

            SqlCommand cmd = cn.CreateCommand();
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "sp_DesgloseDepreciacion";
            cmd.CommandTimeout = 120;

            cmd.Parameters.Add(new SqlParameter("@RFC", SqlDbType.VarChar, 20)).Value =
                ObtenerRfcEmpresa(IdEmpresa);
            cmd.Parameters.Add(new SqlParameter("@Periodo", SqlDbType.VarChar, 10)).Value = anio;
            cmd.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mes;
            cmd.Parameters.Add(new SqlParameter("@Grupo", SqlDbType.VarChar, 255)).Value = grupo;
            cmd.Parameters.Add(new SqlParameter("@Convencional", SqlDbType.TinyInt)).Value = convencional;
            cmd.Parameters.Add(new SqlParameter("@Vista", SqlDbType.VarChar, 20)).Value = vista;

            new SqlDataAdapter(cmd).Fill(ds);
        }

        return ds;
    }

    /// <summary>
    /// Parte el parametro "VISTA|Grupo". Si algo viene mal, cae a PRINCIPAL.
    /// </summary>
    private void ParsearParametroDesglose(string parametro, out string vista, out string grupo)
    {
        vista = "PRINCIPAL";
        grupo = string.Empty;

        if (string.IsNullOrEmpty(parametro))
            return;

        int sep = parametro.IndexOf('|');
        if (sep < 0)
        {
            grupo = parametro;
            return;
        }

        string v = parametro.Substring(0, sep).Trim().ToUpperInvariant();
        if (v == "VIGENTES" || v == "PRINCIPAL")
            vista = v;

        // El grupo puede contener espacios y acentos; se toma todo lo que sigue.
        grupo = parametro.Substring(sep + 1);

    }

    #endregion

    #region MasterDetail

    protected void GvDetalleActivo_BeforePerformDataSelect(object sender, EventArgs e)
    {
        ASPxGridView gvDetalleActivo = (ASPxGridView)sender;
        int id = Convert.ToInt32(gvDetalleActivo.GetMasterRowKeyValue());
        gvDetalleActivo.DataSource = ObtenerDetallePorId(id);
    }

    private void CargarDatosActivos(int IdEmp, string Anio, int Mes)
    {
        string connectionString = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;
        string query = @"
        SELECT 
            ACT.Id AS IdActivo,
            Grupo,
            FechaAdquisicion,
            Descripcion,
            Meses_Transcurridos,
            PorcentajeDepFiscalAnual,
            PorcentajeDepContableAnual,
            CDH.Moi,
            CDH.MoiFiscal,
            CDH.FechaBaja,
            Meses_Efectivos_Contables,
            DeduccionContableInvHistorico,
            SaldoContablePorDeducir,
            DepreciacionContableInversionAnual,
            DepreciacionContableAcumulado,
            Meses_Efectivos_Fiscales,
            DeduccionFiscalInvHistorico,
            SaldoFiscalPorDeducir,
            DepreciacionFiscalInversionAnual,
            DepreciacionFiscalAcumulado,
            InpcMitadPeriodo,
            InpcFechaAdquisicion,
            Factor_Ajuste,
            Deduccion_Fiscal_Inv_Actualizado
        FROM [dbo].[Activos] ACT
        INNER JOIN [dbo].[CalculoDetalle_Historico] CDH ON ACT.Id = CDH.IdActivo
        INNER JOIN [dbo].[CatalogoCuentas] CC ON ACT.IdCatalogo = CC.Id
        INNER JOIN [dbo].[Empresas] EMP ON ACT.IdEmpresa = EMP.Id
        INNER JOIN [dbo].[CatalogoPeriodo] CPE ON CDH.IdPeriodo = CPE.Id
        WHERE ACT.IdEmpresa = @IdEmpresa 
          AND Periodo = @Periodo 
          AND CDH.IdMes = @IdMes
          AND CDH.Convencional = 1
        ORDER BY Grupo, FechaAdquisicion DESC";

        try
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@IdEmpresa", IdEmp);
                    command.Parameters.AddWithValue("@Periodo", Anio);
                    command.Parameters.AddWithValue("@IdMes", Mes);

                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dt = new DataTable();

                    connection.Open();
                    adapter.Fill(dt);
                    connection.Close();

                    gvActivos.DataSource = dt;
                    gvActivos.DataBind();

                }
            }
        }
        catch (Exception ex)
        {
            MostrarSweetAlert("Error", ex.Message, "error");
        }
    }

    private DataTable ObtenerDetallePorId(int id)
    {
        DataTable dt = new DataTable();
        string connectionString = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;
        string fechaConsulta = Session["FechasConsulta"].ToString();
        DateTime fecha = DateTime.ParseExact(fechaConsulta, "yyyy/dd/MM", System.Globalization.CultureInfo.InvariantCulture);
        string anio = fecha.Year.ToString();
        string mes = fecha.Month.ToString("D1");


        string query = @"SELECT IdActivo, Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre,
	                    CASE WHEN TipoContabilidad = 0 THEN 'Fiscal'
                        ELSE 'Contable'
                        END AS Tipo
                        FROM
                            CalculoMensual_Historico CMH
	                        INNER JOIN CatalogoPeriodo CPE ON CMH.IdPeriodo=CPE.Id
                        WHERE Periodo=@anio AND IdMes=@mes AND IdActivo=@IdActivo";
        using (SqlConnection connection = new SqlConnection(connectionString))
        {
            try
            {
                connection.Open();
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@IdActivo", id);
                    command.Parameters.AddWithValue("@anio", anio);
                    command.Parameters.AddWithValue("@mes", mes);
                    using (SqlDataAdapter adapter = new SqlDataAdapter(command))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al obtener el detalle del activo: " + ex.Message);
            }
        }
        return dt;
    }

    private void CargarVigentes(int convencional, string AnioCalcular, int mesx)
    {
        int IdEmpresa = (int)Session["IdEmpresa"];
        string ConexionDeprecia = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;

        using (SqlConnection connection = new SqlConnection(ConexionDeprecia))
        {
            connection.Open();
            SqlCommand comando = connection.CreateCommand();
            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "sp_ReporteDepreciacion_Vigentes";
            comando.Parameters.Add(new SqlParameter("@Periodo", SqlDbType.VarChar, 10)).Value = AnioCalcular;
            comando.Parameters.Add(new SqlParameter("@Mes", SqlDbType.Int)).Value = mesx;
            comando.Parameters.Add(new SqlParameter("@IdEmpresa", SqlDbType.Int)).Value = IdEmpresa;
            comando.Parameters.Add(new SqlParameter("@Convencional", SqlDbType.TinyInt)).Value = convencional;
            comando.Parameters.Add(new SqlParameter("@Origen", SqlDbType.VarChar, 10)).Value = "HISTORICO";

            SqlDataAdapter sda = new SqlDataAdapter(comando);
            DataTable dt = new DataTable();
            sda.Fill(dt);

            if (convencional == 1)
            {
                GvVigentes.DataSource = dt;
                GvVigentes.DataBind();
            }
        }
    }
    
    private string ObtenerRfcEmpresa(int IdEmpresa)
    {
        string ConexionDeprecia = ConfigurationManager.ConnectionStrings["ConexionDeprecia"].ConnectionString;
        using (SqlConnection cn = new SqlConnection(ConexionDeprecia))
        {
            cn.Open();
            SqlCommand cmd = new SqlCommand("SELECT RFC FROM Empresas WHERE Id = @Id", cn);
            cmd.Parameters.AddWithValue("@Id", IdEmpresa);
            object r = cmd.ExecuteScalar();
            return r == null ? string.Empty : r.ToString();
        }
    }

    protected void GvDesgloseResumen_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
    {
        string vista, grupo;
        ParsearParametroDesglose(e.Parameters, out vista, out grupo);

        if (string.IsNullOrEmpty(grupo))
        {
            GvDesgloseResumen.DataSource = null;
            GvDesgloseResumen.DataBind();
            return;
        }

        DataSet ds = ObtenerDesglose(grupo, vista, 1);

        GvDesgloseResumen.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        GvDesgloseResumen.DataBind();

        // Guardamos el detalle para no ejecutar el SP dos veces.
        Session["DesgloseDetalle"] = ds.Tables.Count > 1 ? ds.Tables[1] : null;
        Session["DesgloseClave"] = vista + "|" + grupo;
    }

    protected void GvDesgloseDetalle_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
    {
        string vista, grupo;
        ParsearParametroDesglose(e.Parameters, out vista, out grupo);

        if (string.IsNullOrEmpty(grupo))
        {
            GvDesgloseDetalle.DataSource = null;
            GvDesgloseDetalle.DataBind();
            return;
        }

        DataTable dt = null;

        // Reusa lo que dejo el callback del resumen si corresponde al mismo grupo.
        string claveEsperada = vista + "|" + grupo;
        if (Session["DesgloseClave"] != null &&
            Session["DesgloseClave"].ToString() == claveEsperada &&
            Session["DesgloseDetalle"] != null)
        {
            dt = (DataTable)Session["DesgloseDetalle"];
        }
        else
        {
            DataSet ds = ObtenerDesglose(grupo, vista, 1);
            dt = ds.Tables.Count > 1 ? ds.Tables[1] : null;
        }

        GvDesgloseDetalle.DataSource = dt;
        GvDesgloseDetalle.DataBind();
    }

    /// <summary>
    /// Sombrea en gris los renglones que NO suman al total (Suma = 'NO'),
    /// para que se distinga a simple vista que son informativos.
    /// </summary>
    protected void GvDesgloseDetalle_HtmlRowPrepared(object sender, ASPxGridViewTableRowEventArgs e)
    {
        if (e.RowType != GridViewRowType.Data)
            return;

        object suma = e.GetValue("Suma");
        if (suma != null && suma.ToString() == "NO")
        {
            e.Row.BackColor = System.Drawing.ColorTranslator.FromHtml("#EFEFEF");
            e.Row.ForeColor = System.Drawing.ColorTranslator.FromHtml("#888888");
        }

        object estado = e.GetValue("Estado");
        if (estado != null && estado.ToString().StartsWith("Baja"))
        {
            e.Row.Font.Italic = true;
        }
    }




    #endregion


}
