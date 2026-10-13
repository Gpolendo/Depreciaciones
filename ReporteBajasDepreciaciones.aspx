<%@ Page Title="" Language="C#"
    MasterPageFile="~/MasterContabilidadRT.master"
    AutoEventWireup="true"
    CodeFile="ReporteBajasDepreciaciones.aspx.cs"
    Inherits="ReporteBajasDepreciaciones" %>

<%@ Register
    Assembly="DevExpress.Web.v23.1, Version=23.1.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a"
    Namespace="DevExpress.Web"
    TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
<style>
    .reporte-bajas-wrapper {
        padding: 24px 20px;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    .reporte-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
        border-bottom: 2px solid #d1d9e0;
        padding-bottom: 12px;
    }
    .reporte-header h2 {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 600;
        color: #3a4a5c;
    }
    #divToast {
        display: none;
        padding: 11px 18px;
        border-radius: 6px;
        font-size: 0.875rem;
        font-weight: 500;
        margin-bottom: 16px;
        max-width: 680px;
        border-left: 4px solid;
        line-height: 1.5;
    }
    #divToast.toast-ok   { background:#eef6f0; color:#2e6b45; border-color:#4caf50; }
    #divToast.toast-err  { background:#fdf2f2; color:#7b2020; border-color:#e57373; }
    #divToast.toast-warn { background:#fff8e6; color:#7a5a00; border-color:#f0b429; }

    .btn-revertir {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 4px 13px;
        font-size: 0.79rem;
        font-weight: 600;
        color: #fff;
        background-color: #5e7a96;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background-color 0.18s;
        white-space: nowrap;
    }
    .btn-revertir:hover { background-color: #47617a; }

    #modalOverlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(30,40,55,0.45);
        z-index: 9000;
        justify-content: center;
        align-items: center;
    }
    #modalOverlay.visible { display: flex; }
    #modalBox {
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.18);
        width: 480px;
        max-width: 95vw;
        overflow: hidden;
        animation: fadeInUp .18s ease;
    }
    @keyframes fadeInUp {
        from { opacity:0; transform:translateY(16px); }
        to   { opacity:1; transform:translateY(0);    }
    }
    .modal-header {
        background: #3a4a5c;
        color: #fff;
        padding: 14px 20px;
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 1rem;
        font-weight: 600;
    }
    .modal-body {
        padding: 20px 22px 10px;
        font-size: 0.88rem;
        color: #3d4f60;
        line-height: 1.6;
    }
    .activo-info {
        background: #f4f7fb;
        border: 1px solid #dce4ed;
        border-radius: 5px;
        padding: 10px 14px;
        margin: 12px 0;
        font-size: 0.83rem;
    }
    .activo-info b { color: #3a4a5c; }
    .modal-aviso {
        background: #fff8e6;
        border-left: 3px solid #f0b429;
        border-radius: 4px;
        padding: 9px 13px;
        margin-top: 10px;
        font-size: 0.82rem;
        color: #7a5a00;
        line-height: 1.55;
    }
    .modal-aviso strong { display:block; margin-bottom:3px; }
    .modal-footer {
        padding: 14px 22px 18px;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }
    .btn-modal-cancelar {
        padding: 7px 20px;
        border-radius: 5px;
        border: 1px solid #b0bec5;
        background: #f5f7fa;
        color: #3a4a5c;
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
    }
    .btn-modal-cancelar:hover { background: #e0e7ef; }
    .btn-modal-confirmar {
        padding: 7px 22px;
        border-radius: 5px;
        border: none;
        background: #5e7a96;
        color: #fff;
        font-size: 0.85rem;
        font-weight: 600;
        cursor: pointer;
    }
    .btn-modal-confirmar:hover    { background: #47617a; }
    .btn-modal-confirmar:disabled { background: #a0b4c4; cursor:not-allowed; }

    .dxgvHeader_Office365 td {
        background-color: #e8edf2 !important;
        color: #3a4a5c !important;
        font-size: 0.78rem !important;
        font-weight: 600 !important;
        padding: 8px 10px !important;
        border-bottom: 2px solid #c5cdd7 !important;
    }
    .dxgvDataRow_Office365 td,
    .dxgvDataRowAlt_Office365 td {
        font-size: 0.80rem !important;
        color: #3d4f60 !important;
        padding: 6px 10px !important;
        vertical-align: middle !important;
    }
    .dxgvDataRowAlt_Office365 td       { background-color: #f5f7fa !important; }
    .dxgvDataRow_Office365:hover td,
    .dxgvDataRowAlt_Office365:hover td { background-color: #eaf0f6 !important; }
    .dxgvFooter_Office365 td {
        background-color: #f0f3f7 !important;
        font-size: 0.78rem !important;
        color: #5a6a7a !important;
        padding: 6px 10px !important;
    }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">

<div class="reporte-bajas-wrapper">

    <div class="reporte-header">
        <h2>&#128203; Reporte de Bajas y Depreciaciones</h2>
    </div>

    <div id="divToast"></div>

    <div id="modalOverlay">
        <div id="modalBox">
            <div class="modal-header">
                &#9888; Confirmar reversión de baja
            </div>
            <div class="modal-body">
                <p>Está a punto de revertir la baja del siguiente activo:</p>
                <div class="activo-info">
                    <b>ID Activo:</b> <span id="mIdActivo"></span>&nbsp;&nbsp;
                    <b>Descripción:</b> <span id="mDescripcion"></span><br/>
                    <b>Fecha de baja/venta:</b> <span id="mFechaVenta"></span>
                </div>
                <div class="modal-aviso">
                    <strong>&#9432; Aviso importante antes de continuar:</strong>
                    Esta operación eliminará el registro de baja y su cálculo histórico asociado.
                    Los cálculos de depreciación <u>históricos y posteriores</u> a la fecha en que
                    se aplicó la baja <strong>serán afectados</strong> y deberán ser recalculados
                    manualmente una vez completada la reversión.
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-modal-cancelar" onclick="cerrarModal()">Cancelar</button>
                <button class="btn-modal-confirmar" id="btnConfirmarReversion" onclick="confirmarReversion()">
                    &#8635; Confirmar reversión
                </button>
            </div>
        </div>
    </div>

    <div style="overflow-x:auto;">
        <dx:ASPxGridView
            ID="GvBajas"
            runat="server"
            ClientInstanceName="GvBajas"
            Theme="Office365"
            AutoGenerateColumns="False"
            KeyFieldName="IdActivo"
            Width="100%"
            OnCustomCallback="GvBajas_CustomCallback">

            <ClientSideEvents
                EndCallback="function(s,e){
                    var msg = s.cpMensaje;
                    if (!msg) return;
                    var p = msg.split('|');
                    mostrarToast(p[0]==='OK' ? 'ok' : 'err', p[1] || '');
                    s.cpMensaje = null;
                    var bc = document.getElementById('btnConfirmarReversion');
                    if (bc) { bc.disabled = false; bc.innerHTML = '&#8635; Confirmar reversión'; }
                }" />

            <Columns>
                <dx:GridViewDataTextColumn Caption="Acción" Width="115px" FieldName="IdBaja">
                    <DataItemTemplate>
                        <button type="button" class="btn-revertir"
                            data-idbaja="<%# Eval("IdBaja") %>"
                            data-idactivo="<%# Eval("IdActivo") %>"
                            data-descripcion="<%# Eval("Descripcion") %>"
                            data-fechaventa="<%# Eval("FechaVentaTexto") %>"
                            data-anioventa="<%# Eval("AnioFechaVenta") %>"
                            onclick="onRevertirClick(this)">
                            &#8635; Revertir
                        </button>
                    </DataItemTemplate>
                    <HeaderTemplate>Acción</HeaderTemplate>
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn FieldName="IdActivo"                         Caption="ID Activo"                     Visible="True" />
                <dx:GridViewDataTextColumn FieldName="Grupo"                            Caption="Grupo"                         Visible="True" />
                <dx:GridViewDataTextColumn FieldName="FechaAdquisicion"                 Caption="Fecha Adquisición"             Visible="True" />
                <dx:GridViewDataTextColumn FieldName="Descripcion"                      Caption="Descripción"                   Visible="True" />
                <dx:GridViewDataTextColumn FieldName="FechaVentaTexto"                  Caption="Fecha Venta"                   Visible="True" />
                <dx:GridViewDataTextColumn FieldName="Moi"                              Caption="MOI"                           Visible="True" />
                <dx:GridViewDataTextColumn FieldName="MoiFiscal"                        Caption="MOI Fiscal"                    Visible="True" />
                <dx:GridViewDataTextColumn FieldName="NumFactura"                       Caption="Nº Factura"                    Visible="True" />
                <dx:GridViewDataTextColumn FieldName="PrecioVenta"                      Caption="Precio Venta"                  Visible="True" />
                <dx:GridViewDataTextColumn FieldName="ImporteContableDepreciado"        Caption="Imp. Contable Depreciado"      Visible="True" />
                <dx:GridViewDataTextColumn FieldName="RemanenteContableDepreciar"       Caption="Remanente Contable"            Visible="True" />
                <dx:GridViewDataTextColumn FieldName="UtilidadContable"                 Caption="Utilidad Contable"             Visible="True" />
                <dx:GridViewDataTextColumn FieldName="PerdidaContable"                  Caption="Pérdida Contable"              Visible="True" />
                <dx:GridViewDataTextColumn FieldName="ImporteFiscalDeducido"            Caption="Imp. Fiscal Deducido"          Visible="True" />
                <dx:GridViewDataTextColumn FieldName="AniosDepreciacionFiscalDI"        Caption="Años Depr. Fiscal DI"          Visible="True" />
                <dx:GridViewDataTextColumn FieldName="PorcentajeFiscalDI"               Caption="% Fiscal DI"                   Visible="True" />
                <dx:GridViewDataTextColumn FieldName="PorcentajeFiscalAplicarDI"        Caption="% Fiscal Aplicar DI"           Visible="True" />
                <dx:GridViewDataTextColumn FieldName="MoiPorcentajeFiscalAplicarDI"     Caption="MOI % Fiscal Aplicar DI"       Visible="True" />
                <dx:GridViewDataTextColumn FieldName="RemanentePendienteDeducir"        Caption="Remanente Pend. Deducir"       Visible="True" />
                <dx:GridViewDataTextColumn FieldName="InpcUltimoMesMitadPeriodo"        Caption="INPC Último Mes Mitad Periodo" Visible="True" />
                <dx:GridViewDataTextColumn FieldName="InpcFechaAdquisicion"             Caption="INPC Fecha Adquisición"        Visible="True" />
                <dx:GridViewDataTextColumn FieldName="FactoraAjuste"                    Caption="Factor de Ajuste"              Visible="True" />
                <dx:GridViewDataTextColumn FieldName="ValorActualizadoPendienteDeducir" Caption="Valor Actualiz. Pend. Deducir" Visible="True" />
                <dx:GridViewDataTextColumn FieldName="UtilidadFiscalVenta"              Caption="Utilidad Fiscal Venta"         Visible="True" />
                <dx:GridViewDataTextColumn FieldName="PerdidaFiscalVenta"               Caption="Pérdida Fiscal Venta"          Visible="True" />
            </Columns>

            <Settings ShowFooter="True" />

        </dx:ASPxGridView>
    </div>

</div>

<script type="text/javascript">
    function mostrarToast(tipo, html) {
        var toast = document.getElementById('divToast');
        var ico = tipo === 'ok' ? '&#10003; ' : tipo === 'warn' ? '&#9888; ' : '&#10007; ';
        toast.className = 'toast-' + tipo;
        toast.innerHTML = ico + html;
        toast.style.display = 'block';
        clearTimeout(toast._t);
        toast._t = setTimeout(function () { toast.style.display = 'none'; }, 7000);
    }

    function onRevertirClick(btn) {
        var idBaja = btn.getAttribute('data-idbaja');
        var idActivo = btn.getAttribute('data-idactivo');
        var descripcion = btn.getAttribute('data-descripcion');
        var fechaVenta = btn.getAttribute('data-fechaventa');
        var anioVenta = parseInt(btn.getAttribute('data-anioventa'), 10);
        var anioActual = new Date().getFullYear();

        // Fallback: extraer año del texto de la fecha si data-anioventa no está disponible
        if (!anioVenta || isNaN(anioVenta)) {
            var fv = String(fechaVenta || '').trim();
            var m = fv.match(/(\d{4})/g);
            if (m) {
                for (var i = 0; i < m.length; i++) {
                    var y = parseInt(m[i], 10);
                    if (y > 2000 && y < 2100) { anioVenta = y; break; }
                }
            }
        }

        if (!anioVenta || isNaN(anioVenta) || anioVenta !== anioActual) {
            var anioTexto = (anioVenta && !isNaN(anioVenta)) ? anioVenta : 'desconocido';
            mostrarToast('warn',
                'No es posible revertir esta baja. La fecha de baja/venta (' +
                (fechaVenta || 'sin fecha') + ') pertenece al año ' + anioTexto +
                ', y sólo se permiten reversiones del año en curso (' + anioActual + ').');
            return;
        }

        window._pendingIdBaja = idBaja;
        window._pendingIdActivo = idActivo;
        document.getElementById('mIdActivo').textContent = idActivo;
        document.getElementById('mDescripcion').textContent = descripcion;
        document.getElementById('mFechaVenta').textContent = fechaVenta;
        document.getElementById('modalOverlay').classList.add('visible');
    }

    function cerrarModal() {
        document.getElementById('modalOverlay').classList.remove('visible');
        window._pendingIdBaja = null;
        window._pendingIdActivo = null;
    }

    function confirmarReversion() {
        var idBaja = window._pendingIdBaja;
        var idActivo = window._pendingIdActivo;
        if (!idBaja || !idActivo) return;

        var btn = document.getElementById('btnConfirmarReversion');
        btn.disabled = true;
        btn.innerHTML = 'Procesando...';

        cerrarModal();
        GvBajas.PerformCallback('REVERTIR|' + idBaja + '|' + idActivo);
    }

    document.addEventListener('keydown', function (ev) {
        if (ev.key === 'Escape') cerrarModal();
    });
</script>

</asp:Content>
