<%@ Page Title="" Language="C#" MasterPageFile="~/MasterContabilidadRT.master" AutoEventWireup="true" CodeFile="CalcularDepreciaciones.aspx.cs" Inherits="CalcularDepreciaciones" %>

<%@ Register Assembly="DevExpress.Web.v23.1, Version=23.1.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
<style>
    /* ==================================================================== */
    /* Paleta y tokens                                                      */
    /* ==================================================================== */
    .dep {
        --dep-navy:     #1e3a5f;
        --dep-navy-2:   #2c5282;
        --dep-gen:      #334155;
        --dep-gen-soft: #e2e8f0;
        --dep-con:      #2563eb;
        --dep-con-soft: #dbeafe;
        --dep-con-ink:  #1e40af;
        --dep-fis:      #0d9488;
        --dep-fis-soft: #ccfbf1;
        --dep-fis-ink:  #115e59;
        --dep-accent:   #f97316;
        --dep-line:     #e5e7eb;
        --dep-muted:    #64748b;
        --dep-bg:       #f8fafc;
        font-family: "Segoe UI", system-ui, -apple-system, Arial, sans-serif;
        color: #1f2937;
    }

    /* ==================================================================== */
    /* Cinta superior (fecha, reprocesar, vista, Excel)                     */
    /* ==================================================================== */
    .dep-ribbon {
        display: flex; flex-wrap: wrap; align-items: stretch; gap: 0;
        margin: 8px 0 14px 0;
        background: linear-gradient(135deg, var(--dep-navy) 0%, var(--dep-navy-2) 100%);
        border-radius: 10px;
        box-shadow: 0 4px 14px rgba(30, 58, 95, .25);
        color: #fff; overflow: hidden;
    }
    .dep-ribbon .rb-title {
        display: flex; flex-direction: column; justify-content: center;
        padding: 14px 22px; min-width: 190px;
        background: rgba(0, 0, 0, .15);
    }
    .dep-ribbon .rb-title h1 { margin: 0; font-size: 20px; font-weight: 600; letter-spacing: .2px; }
    .dep-ribbon .rb-title span { font-size: 12px; opacity: .75; }
    .dep-ribbon .rb-group {
        display: flex; flex-direction: column; justify-content: center; gap: 6px;
        padding: 12px 20px;
        border-left: 1px solid rgba(255, 255, 255, .12);
    }
    .dep-ribbon .rb-label {
        font-size: 11px; text-transform: uppercase; letter-spacing: .8px; opacity: .7;
    }
    .dep-ribbon .rb-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
    .dep-ribbon .rb-spacer { flex: 1 1 auto; }

    /* Botón Reprocesar (ASPxButton) */
    .dep-ribbon .dxbButton.rb-primary {
        background: var(--dep-accent) !important; border: 1px solid var(--dep-accent) !important;
        color: #fff !important; border-radius: 6px !important; font-weight: 600;
        box-shadow: 0 2px 6px rgba(249, 115, 22, .35);
    }
    .dep-ribbon .dxbButton.rb-primary:hover { filter: brightness(1.07); }
    .dep-ribbon .dxbButton.rb-primary.dxbDisabled,
    .dep-ribbon .dxbButton.rb-primary.dxbDisabled_Office365 {
        background: rgba(255, 255, 255, .18) !important; border-color: transparent !important;
        color: rgba(255, 255, 255, .6) !important; box-shadow: none;
    }
    .dep-ribbon .dxbButton.rb-primary .dxb { padding: 7px 18px !important; }
    .dep-ribbon .dxeButtonEditSys { border-radius: 6px; overflow: hidden; }

    /* Botones HTML de la cinta */
    .rb-btn {
        display: inline-flex; align-items: center; gap: 7px;
        padding: 7px 14px; border-radius: 6px; cursor: pointer;
        font: inherit; font-size: 13px; font-weight: 500; color: #fff;
        background: rgba(255, 255, 255, .10); border: 1px solid rgba(255, 255, 255, .25);
        transition: background .15s;
    }
    .rb-btn:hover { background: rgba(255, 255, 255, .22); }
    .rb-btn svg { width: 16px; height: 16px; flex: none; }
    .rb-btn .rb-caret { font-size: 9px; opacity: .8; }

    /* Selector de vista Contable / Fiscal / Ambos */
    .seg { display: inline-flex; background: rgba(0, 0, 0, .2); border-radius: 8px; padding: 3px; }
    .seg button {
        border: 0; background: transparent; color: rgba(255, 255, 255, .8);
        font: inherit; font-size: 13px; font-weight: 500;
        padding: 6px 14px; border-radius: 6px; cursor: pointer;
        display: inline-flex; align-items: center; gap: 6px;
    }
    .seg button .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
    .seg button[aria-pressed="true"] { background: #fff; color: var(--dep-navy); box-shadow: 0 1px 3px rgba(0,0,0,.2); }

    /* ==================================================================== */
    /* Banner INPC anterior                                                 */
    /* ==================================================================== */
    .dep-alert {
        margin: 6px 0 10px 0; padding: 12px 18px; border-radius: 8px;
        background: #fff7ed; border: 1px solid #fdba74; border-left: 5px solid var(--dep-accent);
        display: flex; align-items: center; gap: 12px;
        color: #9a3412; font-weight: 600; font-size: 14px;
    }
    .dep-alert .ico { font-size: 20px; line-height: 1; }

    /* ==================================================================== */
    /* Cards de resumen                                                     */
    /* ==================================================================== */
    .kpi-set { margin: 6px 0 20px 0; }
    .kpi-rows { display: flex; flex-wrap: wrap; gap: 14px; }
    .kpi-block { flex: 1 1 260px; min-width: 0; }
    .kpi-block-title {
        font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .8px;
        margin: 0 0 6px 2px; color: var(--dep-muted);
    }
    .kpi-block.gen .kpi-block-title { color: var(--dep-gen); }
    .kpi-block.con .kpi-block-title { color: var(--dep-con-ink); }
    .kpi-block.fis .kpi-block-title { color: var(--dep-fis-ink); }
    .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 10px; }
    .kpi {
        background: #fff; border: 1px solid var(--dep-line); border-radius: 10px;
        padding: 12px 14px; border-top: 4px solid var(--dep-gen);
        box-shadow: 0 1px 3px rgba(15, 23, 42, .06);
        display: flex; flex-direction: column; gap: 4px; min-width: 0;
    }
    .kpi-block.con .kpi { border-top-color: var(--dep-con); }
    .kpi-block.fis .kpi { border-top-color: var(--dep-fis); }
    .kpi-lbl { font-size: 12px; color: var(--dep-muted); }
    .kpi-val {
        font-size: 19px; font-weight: 700; color: #0f172a;
        font-variant-numeric: tabular-nums; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .kpi-sub { font-size: 11px; color: #94a3b8; }

    /* ==================================================================== */
    /* Secciones y grids                                                    */
    /* ==================================================================== */
    .dep-section {
        background: #fff; border: 1px solid var(--dep-line); border-radius: 10px;
        margin-bottom: 18px; box-shadow: 0 1px 3px rgba(15, 23, 42, .05); overflow: hidden;
    }
    .dep-section-head {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        padding: 12px 16px; border-bottom: 1px solid var(--dep-line); background: var(--dep-bg);
    }
    .dep-section-head h2 { margin: 0; font-size: 16px; font-weight: 600; color: var(--dep-navy); }
    .dep-section-head .tag {
        font-size: 11px; font-weight: 600; padding: 2px 8px; border-radius: 999px;
        background: var(--dep-gen-soft); color: var(--dep-gen);
    }
    .dep-section-head .hint { font-size: 12px; color: var(--dep-muted); margin-left: auto; }
    .dep-section-body { overflow-x: auto; }
    .dep-note { font-size: 12.5px; color: var(--dep-muted); margin: 4px 2px 12px 2px; }

    .dep .dep-grid { border: 0 !important; }
    .dep .dep-grid td, .dep .dep-grid th { font-size: 12.5px; font-variant-numeric: tabular-nums; }

    /* Encabezados de columna */
    .dep .dep-grid .dxgvHeader, .dep .dep-grid .dxgvHeader_Office365 {
        background: var(--dep-gen) !important; color: #fff !important; font-weight: 600;
        border-color: rgba(255, 255, 255, .15) !important; vertical-align: middle;
    }
    .dep .dep-grid td.c-con.dxgvHeader, .dep .dep-grid td.c-con.dxgvHeader_Office365,
    .dep .dep-grid th.c-con { background: var(--dep-con-soft) !important; color: var(--dep-con-ink) !important; }
    .dep .dep-grid td.c-fis.dxgvHeader, .dep .dep-grid td.c-fis.dxgvHeader_Office365,
    .dep .dep-grid th.c-fis { background: var(--dep-fis-soft) !important; color: var(--dep-fis-ink) !important; }

    /* Cintas (bandas) Contable / Fiscal */
    .dep .dep-grid .b-con {
        background: var(--dep-con) !important; color: #fff !important;
        text-transform: uppercase; letter-spacing: 1.5px; font-weight: 700 !important; text-align: center;
    }
    .dep .dep-grid .b-fis {
        background: var(--dep-fis) !important; color: #fff !important;
        text-transform: uppercase; letter-spacing: 1.5px; font-weight: 700 !important; text-align: center;
    }

    /* Celdas */
    .dep .dep-grid td.c-con.dxgv { background-color: rgba(37, 99, 235, .03); }
    .dep .dep-grid td.c-fis.dxgv { background-color: rgba(13, 148, 136, .03); }
    .dep .dep-grid .dxgvDataRowHover td, .dep .dep-grid .dxgvDataRowHover_Office365 td { background-color: #eff6ff !important; }
    .dep .dep-grid .dxgvFooter td, .dep .dep-grid .dxgvFooter_Office365 td {
        background: #f1f5f9 !important; font-weight: 700; color: #0f172a; border-top: 2px solid #cbd5e1;
    }

    /* Mostrar solo Contable / solo Fiscal */
    .dep.vista-con .c-fis, .dep.vista-con .b-fis,
    .dep.vista-fis .c-con, .dep.vista-fis .b-con { display: none !important; }
    .dep.vista-con .kpi-block.fis, .dep.vista-fis .kpi-block.con { opacity: .45; }

    /* Botón de desglose en la descripción */
    .btn-desglose {
        background: none; border: none; padding: 0; cursor: pointer;
        font: inherit; font-weight: 600; text-align: left; color: var(--dep-navy-2);
        border-bottom: 1px dashed currentColor;
    }
    .btn-desglose:hover { color: var(--dep-accent); }

    /* Detalle (child) por grupo */
    .child-wrap { padding: 10px 12px 12px 12px; background: #f8fafc; border-left: 4px solid var(--dep-accent); }
    .child-title { font-size: 13px; color: var(--dep-muted); margin-bottom: 8px; }
    .child-title b { color: var(--dep-navy); }

    /* Popup */
    .dep-pop-title { font-size: 14px; font-weight: 600; color: var(--dep-navy); margin: 14px 0 6px 0; }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" Runat="Server">

<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%-- Botón oculto: sirve como destino del __doPostBack que dispara SweetAlert
     cuando el usuario acepta calcular con INPC de mes anterior. --%>
<asp:Button ID="BConfirmarInpcAnterior" runat="server"
            style="display:none"
            OnClick="BConfirmarInpcAnterior_Click"
            CausesValidation="false" />

<%-- Botón oculto: limpia los grids cuando el usuario cancela el Swal de INPC anterior. --%>
<asp:Button ID="BLimpiarGrids" runat="server"
            style="display:none"
            OnClick="BLimpiarGrids_Click"
            CausesValidation="false" />

<div id="depWrap" class="dep vista-con">

    <%-- ================================================================ --%>
    <%-- CINTA SUPERIOR: fecha, reprocesar, vista y acciones de Excel     --%>
    <%-- ================================================================ --%>
    <div class="dep-ribbon">

        <div class="rb-title">
            <h1>Depreciaciones</h1>
            <span>Cálculo contable y fiscal de activos fijos</span>
        </div>

        <div class="rb-group">
            <span class="rb-label">Periodo de cálculo</span>
            <div class="rb-row">
                <dx:ASPxDateEdit ID="deFecha" AutoPostBack="true" runat="server" Width="150px" Theme="Office365" PickerType="Months" EditFormat="Custom" OnDateChanged="deFecha_DateChanged" />
                <dx:ASPxButton ID="BRecalcular" runat="server" Text="Reprocesar" AutoPostBack="false" Theme="Office365" Enabled="False" CssClass="rb-primary" OnClick="BRecalcular_Click" />
            </div>
        </div>

        <div class="rb-group">
            <span class="rb-label">Columnas visibles</span>
            <div class="seg" role="group" aria-label="Columnas visibles">
                <button type="button" data-vista="con" aria-pressed="true"  onclick="DepSetVista('con');"><span class="dot" style="background:#60a5fa"></span>Contable</button>
                <button type="button" data-vista="fis" aria-pressed="false" onclick="DepSetVista('fis');"><span class="dot" style="background:#2dd4bf"></span>Fiscal</button>
                <button type="button" data-vista="all" aria-pressed="false" onclick="DepSetVista('all');">Ambos</button>
            </div>
        </div>

        <div class="rb-spacer"></div>

        <div class="rb-group">
            <span class="rb-label">Excel</span>
            <div class="rb-row">
                <button type="button" class="rb-btn" onclick="VistaMenuExportar.ShowAtElement(this); return false;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12"/><path d="m7 10 5 5 5-5"/><path d="M5 21h14"/></svg>
                    Exportar <span class="rb-caret">&#9660;</span>
                </button>
                <button type="button" class="rb-btn" onclick="DepProximamente('Layout Excel'); return false;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M3 15h18M9 3v18"/></svg>
                    Layout Excel
                </button>
                <button type="button" class="rb-btn" onclick="DepProximamente('Cargar Excel'); return false;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 21V9"/><path d="m7 14 5-5 5 5"/><path d="M5 3h14"/></svg>
                    Cargar Excel
                </button>
            </div>
        </div>
    </div>

    <%-- Menú del botón Exportar --%>
    <dx:ASPxPopupMenu ID="PmExportar" ClientInstanceName="VistaMenuExportar" runat="server" Theme="Office365" PopupAction="None"
        PopupHorizontalAlign="LeftSides" PopupVerticalAlign="Below">
        <Items>
            <dx:MenuItem Name="VistaCalculo"    Text="Resumen - Convencionales" />
            <dx:MenuItem Name="VistaCalculoNoC" Text="Resumen - Aceleradas" />
            <dx:MenuItem Name="VistaActivos"    Text="Detalle por activo" BeginGroup="true" />
            <dx:MenuItem Name="VistaVigentes"   Text="Vigentes - Convencionales" BeginGroup="true" />
        </Items>
        <ClientSideEvents ItemClick="function(s, e) { DepExportar(e.item.name); }" />
    </dx:ASPxPopupMenu>

    <%-- Banner de advertencia: visible cuando el cálculo se realizó con INPC de un mes anterior --%>
    <asp:Panel ID="PanelInpcAnterior" runat="server" Visible="false" CssClass="dep-alert">
        <span class="ico">&#9888;&#65039;</span>
        <span><asp:Literal ID="LitMensajeInpc" runat="server" /></span>
    </asp:Panel>

    <dx:ASPxPageControl ID="Calculos" Width="100%" runat="server" CssClass="dxtcFixed" ActiveTabIndex="0" EnableHierarchyRecreation="True" Theme="Office365">

        <TabPages>

            <%-- ================================================================ --%>
            <%-- TAB 1: RESUMEN CALCULO                                           --%>
            <%-- ================================================================ --%>
            <dx:TabPage Text="Resumen Cálculo">

                <ContentCollection>
                <dx:ContentControl ID="CalculoGeneral" runat="server">

                    <%-- CARDS DE RESUMEN (se llenan en cliente con los totales de ambos grids) --%>
                    <div class="kpi-set" data-grids="VistaCalculo,VistaCalculoNoC">
                        <div class="kpi-rows">
                            <div class="kpi-block gen">
                                <div class="kpi-block-title">General</div>
                                <div class="kpi-grid">
                                    <div class="kpi"><span class="kpi-lbl">MOI total</span><span class="kpi-val" data-field="Moi">—</span><span class="kpi-sub">Convencionales + aceleradas</span></div>
                                    <div class="kpi"><span class="kpi-lbl">Bajas</span><span class="kpi-val" data-field="Baja">—</span><span class="kpi-sub">MOI dado de baja</span></div>
                                </div>
                            </div>
                            <div class="kpi-block con">
                                <div class="kpi-block-title">Contable</div>
                                <div class="kpi-grid">
                                    <div class="kpi"><span class="kpi-lbl">Depreciación del ejercicio</span><span class="kpi-val" data-field="DepreciacionContableAcumuladoEjercicio">—</span><span class="kpi-sub">Acumulada al mes de corte</span></div>
                                    <div class="kpi"><span class="kpi-lbl">Saldo MOI por deducir</span><span class="kpi-val" data-field="SaldoContableMoiDeducir">—</span><span class="kpi-sub">Pendiente de depreciar</span></div>
                                </div>
                            </div>
                            <div class="kpi-block fis">
                                <div class="kpi-block-title">Fiscal</div>
                                <div class="kpi-grid">
                                    <div class="kpi"><span class="kpi-lbl">Depreciación del ejercicio</span><span class="kpi-val" data-field="DepreciacionFiscalAcumuladoEjercicio">—</span><span class="kpi-sub">Acumulada al mes de corte</span></div>
                                    <div class="kpi"><span class="kpi-lbl">Saldo MOI por deducir</span><span class="kpi-val" data-field="SaldoFiscalMoiDeducir">—</span><span class="kpi-sub">Pendiente de deducir</span></div>
                                    <div class="kpi"><span class="kpi-lbl">Deducción actualizada</span><span class="kpi-val" data-field="DeduccionFiscalActualizadoAnual">—</span><span class="kpi-sub">Actualizada anual (INPC)</span></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- GRID CONVENCIONAL --%>
                    <div class="dep-section">
                        <div class="dep-section-head">
                            <h2>Depreciaciones convencionales</h2>
                            <span class="tag">Por grupo</span>
                            <span class="hint">Expanda un grupo para ver sus activos &middot; clic en la descripción para el desglose</span>
                        </div>
                        <div class="dep-section-body">

                        <dx:ASPxGridView ID="GvCalculo" ClientInstanceName="VistaCalculo" runat="server" Theme="Office365" AutoGenerateColumns="False" KeyFieldName="Descripcion" Width="100%" CssClass="dep-grid">

                            <Settings ShowFooter="True" />
                            <SettingsDetail ShowDetailRow="true" AllowOnlyOneMasterRowExpanded="true" />
                            <SettingsExport EnableClientSideExportAPI="true" />
                            <SettingsText EmptyDataRow="Sin información. Seleccione un periodo y presione Reprocesar." />
                            <ClientSideEvents Init="function(s, e) { if (window.DepActualizarCards) DepActualizarCards(); }" EndCallback="function(s, e) { DepActualizarCards(); }" />

                            <Styles>
                                <Header Wrap="True" />
                            </Styles>

                            <Templates>
                                <DetailRow>
                                    <div class="child-wrap">
                                        <div class="child-title">Activos del grupo <b><%# Eval("Descripcion") %></b></div>
                                        <dx:ASPxGridView ID="GvHijoGrupo" runat="server" Theme="Office365" AutoGenerateColumns="False" KeyFieldName="IdActivo" Width="100%" CssClass="dep-grid">
                                            <Settings ShowFooter="True" />
                                            <SettingsPager PageSize="10" />
                                            <SettingsText EmptyDataRow="Detalle por grupo aún no disponible." />
                                            <Styles><Header Wrap="True" /></Styles>
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Activo" Width="260px" />
                                                <dx:GridViewDataDateColumn FieldName="FechaAdquisicion" Caption="Fecha adquisición" PropertiesDateEdit-DisplayFormatString="dd/MM/yyyy" />
                                                <dx:GridViewDataTextColumn FieldName="Moi" Caption="MOI" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                                <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="SaldoContablePorDeducir"       Caption="Saldo por deducir" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con" />
                                                        <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumulado" Caption="Dep. acumulada"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con" />
                                                    </Columns>
                                                </dx:GridViewBandColumn>
                                                <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="SaldoFiscalPorDeducir"       Caption="Saldo por deducir" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis" />
                                                        <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumulado" Caption="Dep. acumulada"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis" />
                                                    </Columns>
                                                </dx:GridViewBandColumn>
                                            </Columns>
                                            <TotalSummary>
                                                <dx:ASPxSummaryItem FieldName="Moi"                           SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="SaldoContablePorDeducir"       SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="DepreciacionContableAcumulado" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="SaldoFiscalPorDeducir"         SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="DepreciacionFiscalAcumulado"   SummaryType="Sum" DisplayFormat="{0:c2}" />
                                            </TotalSummary>
                                        </dx:ASPxGridView>
                                    </div>
                                </DetailRow>
                            </Templates>

                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Descripción" Width="230px">
                                    <DataItemTemplate>
                                        <button type="button" class="btn-desglose"
                                                data-grupo="<%# Eval("Descripcion") %>"
                                                data-vista="PRINCIPAL"
                                                onclick="return AbrirDesglose(this);"><%# Eval("Descripcion") %></button>
                                    </DataItemTemplate>
                                </dx:GridViewDataTextColumn>
                                <dx:GridViewDataTextColumn FieldName="Moi"  Caption="MOI"  PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="ft-Moi" />
                                <dx:GridViewDataTextColumn FieldName="Baja" Caption="Baja" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="ft-Baja" />

                                <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="DeduccionContableHistorica"             Caption="Deducción histórica"            ToolTip="Deducción contable histórica"                PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DeduccionContableHistorica" />
                                        <dx:GridViewDataTextColumn FieldName="SaldoContableMoiDeducir"                Caption="Saldo MOI por deducir"          ToolTip="Saldo contable MOI por deducir"              PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-SaldoContableMoiDeducir" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionContableInversionAnual"     Caption="Depreciación inversión anual"   ToolTip="Depreciación contable inversión anual"       PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DepreciacionContableInversionAnual" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumuladoEjercicio" Caption="Depreciación acumulada ejercicio" ToolTip="Depreciación contable acumulado ejercicio" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DepreciacionContableAcumuladoEjercicio" />
                                    </Columns>
                                </dx:GridViewBandColumn>

                                <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="DeduccionFiscalHistorica"             Caption="Deducción histórica"              ToolTip="Deducción fiscal histórica"               PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DeduccionFiscalHistorica" />
                                        <dx:GridViewDataTextColumn FieldName="SaldoFiscalMoiDeducir"                Caption="Saldo MOI por deducir"            ToolTip="Saldo fiscal MOI por deducir"             PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-SaldoFiscalMoiDeducir" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalInversionAnual"     Caption="Depreciación inversión anual"     ToolTip="Depreciación fiscal inversión anual"      PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DepreciacionFiscalInversionAnual" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumuladoEjercicio" Caption="Depreciación acumulada ejercicio" ToolTip="Depreciación fiscal acumulado ejercicio"  PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DepreciacionFiscalAcumuladoEjercicio" />
                                        <dx:GridViewDataTextColumn FieldName="DeduccionFiscalActualizadoAnual"      Caption="Deducción actualizada anual"      ToolTip="Deducción fiscal actualizado anual"       PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DeduccionFiscalActualizadoAnual" />
                                    </Columns>
                                </dx:GridViewBandColumn>
                            </Columns>

                            <TotalSummary>
                                <dx:ASPxSummaryItem FieldName="Descripcion" SummaryType="Count" DisplayFormat="Total ({0} grupos)" />
                                <dx:ASPxSummaryItem FieldName="Moi" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="Baja" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DeduccionContableHistorica" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="SaldoContableMoiDeducir" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionContableInversionAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionContableAcumuladoEjercicio" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DeduccionFiscalHistorica" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="SaldoFiscalMoiDeducir" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionFiscalInversionAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionFiscalAcumuladoEjercicio" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DeduccionFiscalActualizadoAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                            </TotalSummary>

                        </dx:ASPxGridView>
                        </div>
                    </div>

                    <%-- GRID ACELERADA --%>
                    <div class="dep-section">
                        <div class="dep-section-head">
                            <h2>Depreciaciones aceleradas</h2>
                            <span class="tag">Por grupo</span>
                        </div>
                        <div class="dep-section-body">

                        <dx:ASPxGridView ID="GvCalculoNoC" ClientInstanceName="VistaCalculoNoC" runat="server" Theme="Office365" AutoGenerateColumns="False" KeyFieldName="Descripcion" Width="100%" CssClass="dep-grid">

                            <Settings ShowFooter="True" />
                            <SettingsDetail ShowDetailRow="true" AllowOnlyOneMasterRowExpanded="true" />
                            <SettingsExport EnableClientSideExportAPI="true" />
                            <SettingsText EmptyDataRow="Sin depreciaciones aceleradas en el periodo." />
                            <ClientSideEvents Init="function(s, e) { if (window.DepActualizarCards) DepActualizarCards(); }" EndCallback="function(s, e) { DepActualizarCards(); }" />

                            <Styles>
                                <Header Wrap="True" />
                            </Styles>

                            <Templates>
                                <DetailRow>
                                    <div class="child-wrap">
                                        <div class="child-title">Activos del grupo <b><%# Eval("Descripcion") %></b></div>
                                        <dx:ASPxGridView ID="GvHijoGrupo" runat="server" Theme="Office365" AutoGenerateColumns="False" KeyFieldName="IdActivo" Width="100%" CssClass="dep-grid">
                                            <Settings ShowFooter="True" />
                                            <SettingsPager PageSize="10" />
                                            <SettingsText EmptyDataRow="Detalle por grupo aún no disponible." />
                                            <Styles><Header Wrap="True" /></Styles>
                                            <Columns>
                                                <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Activo" Width="260px" />
                                                <dx:GridViewDataDateColumn FieldName="FechaAdquisicion" Caption="Fecha adquisición" PropertiesDateEdit-DisplayFormatString="dd/MM/yyyy" />
                                                <dx:GridViewDataTextColumn FieldName="Moi" Caption="MOI" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                                <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="SaldoContablePorDeducir"       Caption="Saldo por deducir" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con" />
                                                        <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumulado" Caption="Dep. acumulada"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con" />
                                                    </Columns>
                                                </dx:GridViewBandColumn>
                                                <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                                    <Columns>
                                                        <dx:GridViewDataTextColumn FieldName="SaldoFiscalPorDeducir"       Caption="Saldo por deducir" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis" />
                                                        <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumulado" Caption="Dep. acumulada"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis" />
                                                    </Columns>
                                                </dx:GridViewBandColumn>
                                            </Columns>
                                            <TotalSummary>
                                                <dx:ASPxSummaryItem FieldName="Moi"                           SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="SaldoContablePorDeducir"       SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="DepreciacionContableAcumulado" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="SaldoFiscalPorDeducir"         SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                <dx:ASPxSummaryItem FieldName="DepreciacionFiscalAcumulado"   SummaryType="Sum" DisplayFormat="{0:c2}" />
                                            </TotalSummary>
                                        </dx:ASPxGridView>
                                    </div>
                                </DetailRow>
                            </Templates>

                            <Columns>
                                <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Descripción" Width="230px" CellStyle-Font-Bold="true" />
                                <dx:GridViewDataTextColumn FieldName="Moi"  Caption="MOI"  PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="ft-Moi" />
                                <dx:GridViewDataTextColumn FieldName="Baja" Caption="Baja" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="ft-Baja" />

                                <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="DeduccionContableHistorica"             Caption="Deducción histórica"            ToolTip="Deducción contable histórica"                PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DeduccionContableHistorica" />
                                        <dx:GridViewDataTextColumn FieldName="SaldoContableMoiDeducir"                Caption="Saldo MOI por deducir"          ToolTip="Saldo contable MOI por deducir"              PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-SaldoContableMoiDeducir" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionContableInversionAnual"     Caption="Depreciación inversión anual"   ToolTip="Depreciación contable inversión anual"       PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DepreciacionContableInversionAnual" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumuladoEjercicio" Caption="Depreciación acumulada ejercicio" ToolTip="Depreciación contable acumulado ejercicio" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DepreciacionContableAcumuladoEjercicio" />
                                    </Columns>
                                </dx:GridViewBandColumn>

                                <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="DeduccionFiscalHistorica"             Caption="Deducción histórica"              ToolTip="Deducción fiscal histórica"               PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DeduccionFiscalHistorica" />
                                        <dx:GridViewDataTextColumn FieldName="SaldoFiscalMoiDeducir"                Caption="Saldo MOI por deducir"            ToolTip="Saldo fiscal MOI por deducir"             PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-SaldoFiscalMoiDeducir" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalInversionAnual"     Caption="Depreciación inversión anual"     ToolTip="Depreciación fiscal inversión anual"      PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DepreciacionFiscalInversionAnual" />
                                        <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumuladoEjercicio" Caption="Depreciación acumulada ejercicio" ToolTip="Depreciación fiscal acumulado ejercicio"  PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DepreciacionFiscalAcumuladoEjercicio" />
                                        <dx:GridViewDataTextColumn FieldName="DeduccionFiscalActualizadoAnual"      Caption="Deducción actualizada anual"      ToolTip="Deducción fiscal actualizado anual"       PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DeduccionFiscalActualizadoAnual" />
                                    </Columns>
                                </dx:GridViewBandColumn>
                            </Columns>

                            <TotalSummary>
                                <dx:ASPxSummaryItem FieldName="Descripcion" SummaryType="Count" DisplayFormat="Total ({0} grupos)" />
                                <dx:ASPxSummaryItem FieldName="Moi" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="Baja" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DeduccionContableHistorica" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="SaldoContableMoiDeducir" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionContableInversionAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionContableAcumuladoEjercicio" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DeduccionFiscalHistorica" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="SaldoFiscalMoiDeducir" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionFiscalInversionAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DepreciacionFiscalAcumuladoEjercicio" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                <dx:ASPxSummaryItem FieldName="DeduccionFiscalActualizadoAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                            </TotalSummary>

                        </dx:ASPxGridView>
                        </div>
                    </div>

                </dx:ContentControl>
                </ContentCollection>

            </dx:TabPage>

            <%-- ================================================================ --%>
            <%-- TAB 2: DETALLE CALCULO                                           --%>
            <%-- ================================================================ --%>
            <dx:TabPage Text="Detalle Cálculo">

                <ContentCollection>
                <dx:ContentControl ID="DetalleCalculo" runat="server">

                    <div class="dep-section">
                        <div class="dep-section-head">
                            <h2>Detalle por activo</h2>
                            <span class="tag">Por activo</span>
                            <span class="hint">Arrastre una columna al panel de agrupación &middot; expanda un activo para ver su detalle mensual</span>
                        </div>
                        <div class="dep-section-body">

                    <dx:ASPxGridView ID="gvActivos" ClientInstanceName="VistaActivos" runat="server" Theme="Office365" AutoGenerateColumns="False" KeyFieldName="IdActivo" Width="100%" CssClass="dep-grid">

                        <SettingsDetail ShowDetailRow="true" />

                        <Styles>
                            <Header Wrap="True" />
                        </Styles>

                        <Templates>
                            <DetailRow>
                                <div class="child-wrap">
                                <dx:ASPxGridView runat="server" ID="GvDetalleActivo" ClientInstanceName="VistaDetalleActivo"
                                    Width="100%" KeyFieldName="IdActivo" Theme="Office365" AutoGenerateColumns="False" CssClass="dep-grid"
                                    OnBeforePerformDataSelect="GvDetalleActivo_BeforePerformDataSelect">

                                    <Styles>
                                        <Header Wrap="True" />
                                    </Styles>

                                    <Columns>
                                        <dx:GridViewDataTextColumn FieldName="IdActivo" Caption="Id Activo" Visible="False" />
                                        <dx:GridViewDataTextColumn FieldName="Tipo" Caption="Tipo" CellStyle-Font-Bold="true" />
                                        <dx:GridViewDataTextColumn FieldName="Enero"      Caption="Enero"      PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Febrero"    Caption="Febrero"    PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Marzo"      Caption="Marzo"      PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Abril"      Caption="Abril"      PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Mayo"       Caption="Mayo"       PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Junio"      Caption="Junio"      PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Julio"      Caption="Julio"      PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Agosto"     Caption="Agosto"     PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Septiembre" Caption="Septiembre" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Octubre"    Caption="Octubre"    PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Noviembre"  Caption="Noviembre"  PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                        <dx:GridViewDataTextColumn FieldName="Diciembre"  Caption="Diciembre"  PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                    </Columns>

                                    <Settings ShowFooter="True" />
                                </dx:ASPxGridView>
                                </div>
                            </DetailRow>
                        </Templates>

                        <Columns>
                            <dx:GridViewDataTextColumn FieldName="ClaveUnica" Visible="false" />
                            <dx:GridViewDataTextColumn FieldName="Grupo" Caption="Grupo" />
                            <dx:GridViewDataDateColumn FieldName="FechaAdquisicion" Caption="Fecha adquisición" PropertiesDateEdit-DisplayFormatString="dd/MM/yyyy" />
                            <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Descripción" Width="220px" />
                            <dx:GridViewDataTextColumn FieldName="Meses_Transcurridos" Caption="Meses transcurridos" CellStyle-HorizontalAlign="Center" />
                            <dx:GridViewDataTextColumn FieldName="Moi" Caption="MOI" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                            <dx:GridViewDataDateColumn FieldName="FechaBaja" Caption="Fecha baja" PropertiesDateEdit-DisplayFormatString="dd/MM/yyyy" />

                            <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="PorcentajeDepContableAnual"     Caption="% Dep. anual"             ToolTip="% depreciación contable anual"            PropertiesTextEdit-DisplayFormatString="{0:p2}" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" FilterCellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="Meses_Efectivos_Contables"      Caption="Meses efectivos"          ToolTip="Meses efectivos contables"                HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" FilterCellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Center" />
                                    <dx:GridViewDataTextColumn FieldName="DeduccionContableInvHistorico"  Caption="Deducción inv. histórico" ToolTip="Deducción contable inversión histórico"   PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" FilterCellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="SaldoContablePorDeducir"        Caption="Saldo por deducir"        ToolTip="Saldo contable por deducir"               PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" FilterCellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="DepreciacionContableInversionAnual" Caption="Dep. inversión anual" ToolTip="Depreciación contable inversión anual"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" FilterCellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumulado"  Caption="Dep. acumulada"           ToolTip="Depreciación contable acumulado"          PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" FilterCellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" />
                                </Columns>
                            </dx:GridViewBandColumn>

                            <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="MoiFiscal"                        Caption="MOI"                        ToolTip="MOI fiscal"                              PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="PorcentajeDepFiscalAnual"         Caption="% Dep. anual"               ToolTip="% depreciación fiscal anual"             PropertiesTextEdit-DisplayFormatString="{0:p2}" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="Meses_Efectivos_Fiscales"         Caption="Meses efectivos"            ToolTip="Meses efectivos fiscales"                HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Center" />
                                    <dx:GridViewDataTextColumn FieldName="DeduccionFiscalInvHistorico"      Caption="Deducción inv. histórico"   ToolTip="Deducción fiscal inversión histórico"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="SaldoFiscalPorDeducir"            Caption="Saldo por deducir"          ToolTip="Saldo fiscal por deducir"                PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalInversionAnual" Caption="Dep. inversión anual"       ToolTip="Depreciación fiscal inversión anual"     PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumulado"      Caption="Dep. acumulada"             ToolTip="Depreciación fiscal acumulado"           PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="InpcMitadPeriodo"                 Caption="INPC mitad periodo"         HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="InpcFechaAdquisicion"             Caption="INPC fecha adquisición"     HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="Factor_Ajuste"                    Caption="Factor ajuste"              HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                    <dx:GridViewDataTextColumn FieldName="Deduccion_Fiscal_Inv_Actualizado" Caption="Deducción inv. actualizado" ToolTip="Deducción fiscal inversión actualizado" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" FilterCellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" />
                                </Columns>
                            </dx:GridViewBandColumn>
                        </Columns>

                        <Settings ShowGroupPanel="True" ShowFilterRow="True" />
                        <SettingsPager PageSize="20" />
                        <SettingsBehavior AllowSelectByRowClick="True" AllowSelectSingleRowOnly="True" />
                        <SettingsDataSecurity AllowDelete="False" AllowEdit="False" AllowInsert="False" />
                        <SettingsExport EnableClientSideExportAPI="true" />
                        <SettingsText GroupPanel="Arrastre aquí una columna para agrupar" EmptyDataRow="Sin información. Seleccione un periodo y presione Reprocesar." />

                    </dx:ASPxGridView>
                        </div>
                    </div>

                </dx:ContentControl>
                </ContentCollection>

            </dx:TabPage>

            <%-- ================================================================ --%>
            <%-- TAB 3: SOLO ACTIVOS VIGENTES (v11)                               --%>
            <%-- ================================================================ --%>
            <dx:TabPage Text="Vigentes">
                <ContentCollection>
                    <dx:ContentControl ID="CalculoVigentes" runat="server">

                        <p class="dep-note">
                            Muestra únicamente los activos vigentes al mes de corte. Los activos dados de baja se excluyen de todas las columnas
                            de valor desde su mes de baja; su MOI se informa en la columna Baja. Use la fecha y el botón Reprocesar de la barra superior.
                        </p>

                        <%-- CARDS DE RESUMEN VIGENTES --%>
                        <div class="kpi-set" data-grids="VistaVigentes">
                            <div class="kpi-rows">
                                <div class="kpi-block gen">
                                    <div class="kpi-block-title">General</div>
                                    <div class="kpi-grid">
                                        <div class="kpi"><span class="kpi-lbl">MOI vigente</span><span class="kpi-val" data-field="Moi">—</span><span class="kpi-sub">Activos vigentes</span></div>
                                        <div class="kpi"><span class="kpi-lbl">Bajas</span><span class="kpi-val" data-field="Baja">—</span><span class="kpi-sub">MOI dado de baja</span></div>
                                    </div>
                                </div>
                                <div class="kpi-block con">
                                    <div class="kpi-block-title">Contable</div>
                                    <div class="kpi-grid">
                                        <div class="kpi"><span class="kpi-lbl">Depreciación del ejercicio</span><span class="kpi-val" data-field="DepreciacionContableAcumuladoEjercicio">—</span><span class="kpi-sub">Acumulada al mes de corte</span></div>
                                        <div class="kpi"><span class="kpi-lbl">Saldo MOI por deducir</span><span class="kpi-val" data-field="SaldoContableMoiDeducir">—</span><span class="kpi-sub">Pendiente de depreciar</span></div>
                                    </div>
                                </div>
                                <div class="kpi-block fis">
                                    <div class="kpi-block-title">Fiscal</div>
                                    <div class="kpi-grid">
                                        <div class="kpi"><span class="kpi-lbl">Depreciación del ejercicio</span><span class="kpi-val" data-field="DepreciacionFiscalAcumuladoEjercicio">—</span><span class="kpi-sub">Acumulada al mes de corte</span></div>
                                        <div class="kpi"><span class="kpi-lbl">Saldo MOI por deducir</span><span class="kpi-val" data-field="SaldoFiscalMoiDeducir">—</span><span class="kpi-sub">Pendiente de deducir</span></div>
                                        <div class="kpi"><span class="kpi-lbl">Deducción actualizada</span><span class="kpi-val" data-field="DeduccionFiscalActualizadoAnual">—</span><span class="kpi-sub">Actualizada anual (INPC)</span></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="dep-section">
                            <div class="dep-section-head">
                                <h2>Vigentes - convencionales</h2>
                                <span class="tag">Por grupo</span>
                                <span class="hint">Clic en la descripción para el desglose</span>
                            </div>
                            <div class="dep-section-body">

                            <dx:ASPxGridView ID="GvVigentes" ClientInstanceName="VistaVigentes" runat="server"
                                Theme="Office365" AutoGenerateColumns="False" KeyFieldName="Descripcion" Width="100%" CssClass="dep-grid">

                                <Settings ShowFooter="True" />
                                <SettingsDetail ShowDetailRow="true" AllowOnlyOneMasterRowExpanded="true" />
                                <SettingsExport EnableClientSideExportAPI="true" />
                                <SettingsText EmptyDataRow="Sin información. Seleccione un periodo y presione Reprocesar." />
                                <ClientSideEvents Init="function(s, e) { if (window.DepActualizarCards) DepActualizarCards(); }" EndCallback="function(s, e) { DepActualizarCards(); }" />

                                <Styles>
                                    <Header Wrap="True" />
                                </Styles>

                                <Templates>
                                    <DetailRow>
                                        <div class="child-wrap">
                                            <div class="child-title">Activos vigentes del grupo <b><%# Eval("Descripcion") %></b></div>
                                            <dx:ASPxGridView ID="GvHijoGrupo" runat="server" Theme="Office365" AutoGenerateColumns="False" KeyFieldName="IdActivo" Width="100%" CssClass="dep-grid">
                                                <Settings ShowFooter="True" />
                                                <SettingsPager PageSize="10" />
                                                <SettingsText EmptyDataRow="Detalle por grupo aún no disponible." />
                                                <Styles><Header Wrap="True" /></Styles>
                                                <Columns>
                                                    <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Activo" Width="260px" />
                                                    <dx:GridViewDataDateColumn FieldName="FechaAdquisicion" Caption="Fecha adquisición" PropertiesDateEdit-DisplayFormatString="dd/MM/yyyy" />
                                                    <dx:GridViewDataTextColumn FieldName="Moi" Caption="MOI" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                                                    <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn FieldName="SaldoContablePorDeducir"       Caption="Saldo por deducir" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con" />
                                                            <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumulado" Caption="Dep. acumulada"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con" />
                                                        </Columns>
                                                    </dx:GridViewBandColumn>
                                                    <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                                        <Columns>
                                                            <dx:GridViewDataTextColumn FieldName="SaldoFiscalPorDeducir"       Caption="Saldo por deducir" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis" />
                                                            <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumulado" Caption="Dep. acumulada"    PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis" />
                                                        </Columns>
                                                    </dx:GridViewBandColumn>
                                                </Columns>
                                                <TotalSummary>
                                                    <dx:ASPxSummaryItem FieldName="Moi"                           SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                    <dx:ASPxSummaryItem FieldName="SaldoContablePorDeducir"       SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                    <dx:ASPxSummaryItem FieldName="DepreciacionContableAcumulado" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                    <dx:ASPxSummaryItem FieldName="SaldoFiscalPorDeducir"         SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                    <dx:ASPxSummaryItem FieldName="DepreciacionFiscalAcumulado"   SummaryType="Sum" DisplayFormat="{0:c2}" />
                                                </TotalSummary>
                                            </dx:ASPxGridView>
                                        </div>
                                    </DetailRow>
                                </Templates>

                                <Columns>
                                    <dx:GridViewDataTextColumn FieldName="Descripcion" Caption="Descripción" Width="230px">
                                        <DataItemTemplate>
                                            <button type="button" class="btn-desglose"
                                                    data-grupo="<%# Eval("Descripcion") %>"
                                                    data-vista="VIGENTES"
                                                    onclick="return AbrirDesglose(this);"><%# Eval("Descripcion") %></button>
                                        </DataItemTemplate>
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn FieldName="Moi"  Caption="MOI vigente" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="ft-Moi" />
                                    <dx:GridViewDataTextColumn FieldName="Baja" Caption="Baja"        PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="ft-Baja" />

                                    <dx:GridViewBandColumn Caption="Contable" HeaderStyle-CssClass="b-con">
                                        <Columns>
                                            <dx:GridViewDataTextColumn FieldName="DeduccionContableHistorica"             Caption="Deducción histórica"            ToolTip="Deducción contable histórica"                PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DeduccionContableHistorica" />
                                            <dx:GridViewDataTextColumn FieldName="SaldoContableMoiDeducir"                Caption="Saldo MOI por deducir"          ToolTip="Saldo contable MOI por deducir"              PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-SaldoContableMoiDeducir" />
                                            <dx:GridViewDataTextColumn FieldName="DepreciacionContableInversionAnual"     Caption="Depreciación inversión anual"   ToolTip="Depreciación contable inversión anual"       PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DepreciacionContableInversionAnual" />
                                            <dx:GridViewDataTextColumn FieldName="DepreciacionContableAcumuladoEjercicio" Caption="Depreciación acumulada ejercicio" ToolTip="Depreciación contable acumulado ejercicio" PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-con" CellStyle-CssClass="c-con" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-con ft-DepreciacionContableAcumuladoEjercicio" />
                                        </Columns>
                                    </dx:GridViewBandColumn>

                                    <dx:GridViewBandColumn Caption="Fiscal" HeaderStyle-CssClass="b-fis">
                                        <Columns>
                                            <dx:GridViewDataTextColumn FieldName="DeduccionFiscalHistorica"             Caption="Deducción histórica"              ToolTip="Deducción fiscal histórica"               PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DeduccionFiscalHistorica" />
                                            <dx:GridViewDataTextColumn FieldName="SaldoFiscalMoiDeducir"                Caption="Saldo MOI por deducir"            ToolTip="Saldo fiscal MOI por deducir"             PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-SaldoFiscalMoiDeducir" />
                                            <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalInversionAnual"     Caption="Depreciación inversión anual"     ToolTip="Depreciación fiscal inversión anual"      PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DepreciacionFiscalInversionAnual" />
                                            <dx:GridViewDataTextColumn FieldName="DepreciacionFiscalAcumuladoEjercicio" Caption="Depreciación acumulada ejercicio" ToolTip="Depreciación fiscal acumulado ejercicio"  PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DepreciacionFiscalAcumuladoEjercicio" />
                                            <dx:GridViewDataTextColumn FieldName="DeduccionFiscalActualizadoAnual"      Caption="Deducción actualizada anual"      ToolTip="Deducción fiscal actualizado anual"       PropertiesTextEdit-DisplayFormatString="c2" HeaderStyle-CssClass="c-fis" CellStyle-CssClass="c-fis" CellStyle-HorizontalAlign="Right" FooterCellStyle-HorizontalAlign="Right" FooterCellStyle-CssClass="c-fis ft-DeduccionFiscalActualizadoAnual" />
                                        </Columns>
                                    </dx:GridViewBandColumn>
                                </Columns>

                                <TotalSummary>
                                    <dx:ASPxSummaryItem FieldName="Descripcion" SummaryType="Count" DisplayFormat="Total ({0} grupos)" />
                                    <dx:ASPxSummaryItem FieldName="Moi" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="Baja" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DeduccionContableHistorica" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="SaldoContableMoiDeducir" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DepreciacionContableInversionAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DepreciacionContableAcumuladoEjercicio" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DeduccionFiscalHistorica" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="SaldoFiscalMoiDeducir" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DepreciacionFiscalInversionAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DepreciacionFiscalAcumuladoEjercicio" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                    <dx:ASPxSummaryItem FieldName="DeduccionFiscalActualizadoAnual" SummaryType="Sum" DisplayFormat="{0:c2}" />
                                </TotalSummary>

                            </dx:ASPxGridView>
                            </div>
                        </div>

                    </dx:ContentControl>
                </ContentCollection>
            </dx:TabPage>

        </TabPages>

    </dx:ASPxPageControl>

</div>

<%-- ==================================================================== --%>
<%-- POPUP DE DESGLOSE (compartido por los TABs)                          --%>
<%-- ==================================================================== --%>
<dx:ASPxPopupControl ID="PopDesglose" ClientInstanceName="VistaPopDesglose" runat="server"
    Theme="Office365" Modal="True" Width="1100px" CssClass="dep"
    CloseAction="CloseButton" PopupHorizontalAlign="WindowCenter"
    PopupVerticalAlign="WindowCenter" AllowDragging="True"
    HeaderText="Desglose del grupo" EnableViewState="False">

    <ContentCollection>
        <dx:PopupControlContentControl runat="server">

            <dx:ASPxLabel ID="LbDesgloseCtx" ClientInstanceName="VistaLbCtx" runat="server"
                Font-Size="Small" ForeColor="#64748b" Text="" />

            <div class="dep-pop-title">Resumen</div>
            <dx:ASPxGridView ID="GvDesgloseResumen" ClientInstanceName="VistaDesgResumen"
                runat="server" Theme="Office365" AutoGenerateColumns="False" Width="100%" CssClass="dep-grid"
                OnCustomCallback="GvDesgloseResumen_CustomCallback" EnableViewState="False">
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="Concepto"  Caption="Concepto" Width="320px" />
                    <dx:GridViewDataTextColumn FieldName="Signo"     Caption="" Width="50px">
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                    <dx:GridViewDataTextColumn FieldName="Moi"       Caption="MOI"       PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Historico" Caption="Histórico" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Anual"     Caption="Anual"     PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Acumulado" Caption="Acumulado" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                </Columns>
                <SettingsBehavior AllowSort="false" AllowFocusedRow="false" />
                <Settings ShowColumnHeaders="True" />
            </dx:ASPxGridView>

            <div class="dep-pop-title">Detalle por activo</div>
            <dx:ASPxGridView ID="GvDesgloseDetalle" ClientInstanceName="VistaDesgDetalle"
                runat="server" Theme="Office365" AutoGenerateColumns="False" Width="100%" CssClass="dep-grid"
                KeyFieldName="IdActivo"
                OnCustomCallback="GvDesgloseDetalle_CustomCallback"
                OnHtmlRowPrepared="GvDesgloseDetalle_HtmlRowPrepared" EnableViewState="False">
                <Settings ShowFooter="True" VerticalScrollableHeight="260" VerticalScrollBarMode="Auto" />
                <SettingsExport EnableClientSideExportAPI="true" />
                <Toolbars>
                    <dx:GridViewToolbar>
                        <Items>
                            <dx:GridViewToolbarItem Command="ExportToXlsx" Text="Exportar a Excel" />
                        </Items>
                    </dx:GridViewToolbar>
                </Toolbars>
                <Columns>
                    <dx:GridViewDataTextColumn FieldName="IdActivo"          Caption="Id"      Width="60px" />
                    <dx:GridViewDataTextColumn FieldName="Identificador"     Caption="Ident."  Width="70px" />
                    <dx:GridViewDataTextColumn FieldName="DescripcionActivo" Caption="Descripción" Width="300px" />
                    <dx:GridViewDataTextColumn FieldName="Estado"            Caption="Estado"  Width="100px" />
                    <dx:GridViewDataDateColumn FieldName="FechaBaja"         Caption="F. Baja" Width="90px"
                        PropertiesDateEdit-DisplayFormatString="dd/MM/yyyy" />
                    <dx:GridViewDataTextColumn FieldName="Moi"       Caption="MOI"       PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Historico" Caption="Histórico" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Anual"     Caption="Anual"     PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Acumulado" Caption="Acumulado" PropertiesTextEdit-DisplayFormatString="c2" CellStyle-HorizontalAlign="Right" />
                    <dx:GridViewDataTextColumn FieldName="Suma"      Caption="¿Suma?"    Width="70px">
                        <CellStyle HorizontalAlign="Center" Font-Bold="true" />
                    </dx:GridViewDataTextColumn>
                </Columns>
                <TotalSummary>
                    <dx:ASPxSummaryItem FieldName="Moi"       SummaryType="Sum" DisplayFormat="{0:c2}" />
                    <dx:ASPxSummaryItem FieldName="Historico" SummaryType="Sum" DisplayFormat="{0:c2}" />
                    <dx:ASPxSummaryItem FieldName="Anual"     SummaryType="Sum" DisplayFormat="{0:c2}" />
                    <dx:ASPxSummaryItem FieldName="Acumulado" SummaryType="Sum" DisplayFormat="{0:c2}" />
                </TotalSummary>
            </dx:ASPxGridView>

        </dx:PopupControlContentControl>
    </ContentCollection>
</dx:ASPxPopupControl>

<%-- ==================================================================== --%>
<%-- JAVASCRIPT                                                           --%>
<%-- ==================================================================== --%>
<script type="text/javascript">
    // ---------------------------------------------------------------- Desglose
    function AbrirDesglose(btn) {
        var grupo = btn.getAttribute('data-grupo');
        var vista = btn.getAttribute('data-vista');
        var param = vista + '|' + grupo;

        VistaPopDesglose.SetHeaderText('Desglose - ' + grupo);
        VistaPopDesglose.Show();

        VistaDesgResumen.PerformCallback(param);
        VistaDesgDetalle.PerformCallback(param);

        return false;
    }

    // ---------------------------------------------- Vista Contable/Fiscal/Ambos
    var DEP_VISTA_KEY = 'dep.vistaColumnas';

    function DepSetVista(v) {
        var wrap = document.getElementById('depWrap');
        if (!wrap) return;
        wrap.classList.remove('vista-con', 'vista-fis', 'vista-all');
        wrap.classList.add('vista-' + v);

        var botones = wrap.querySelectorAll('.seg button');
        for (var i = 0; i < botones.length; i++)
            botones[i].setAttribute('aria-pressed', botones[i].getAttribute('data-vista') === v ? 'true' : 'false');

        try { sessionStorage.setItem(DEP_VISTA_KEY, v); } catch (e) { }

        // Recalcula anchos de los grids tras mostrar/ocultar columnas
        ['VistaCalculo', 'VistaCalculoNoC', 'VistaActivos', 'VistaVigentes'].forEach(function (n) {
            var g = window[n];
            if (g && g.AdjustControl) g.AdjustControl();
        });
    }

    (function () {
        var v = 'con';
        try { v = sessionStorage.getItem(DEP_VISTA_KEY) || 'con'; } catch (e) { }
        DepSetVista(v);
    })();

    // ------------------------------------------------------- Cards de resumen
    var DEP_MONEDA = new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' });

    // Convierte el texto de un footer ("$1,234.56", "-$10.00", "($10.00)") a número
    function DepParse(texto) {
        if (!texto) return 0;
        var t = texto.replace(/\s/g, '');
        var negativo = /^\(.*\)$/.test(t) || t.indexOf('-') >= 0;
        t = t.replace(/[^0-9.,]/g, '');
        if (!t) return 0;
        var d = Math.max(t.lastIndexOf('.'), t.lastIndexOf(','));
        var n = (d >= 0 && t.length - d - 1 <= 2)
            ? parseFloat(t.slice(0, d).replace(/[.,]/g, '') + '.' + t.slice(d + 1))
            : parseFloat(t.replace(/[.,]/g, ''));
        if (isNaN(n)) return 0;
        return negativo ? -n : n;
    }

    function DepActualizarCards() {
        var sets = document.querySelectorAll('.kpi-set');
        for (var i = 0; i < sets.length; i++) {
            var grids = sets[i].getAttribute('data-grids').split(',');
            var vals = sets[i].querySelectorAll('[data-field]');
            for (var j = 0; j < vals.length; j++) {
                var campo = vals[j].getAttribute('data-field');
                var total = 0, hay = false;
                for (var k = 0; k < grids.length; k++) {
                    var g = window[grids[k]];
                    if (!g || !g.GetMainElement) continue;
                    var celda = g.GetMainElement().querySelector('.ft-' + campo);
                    if (celda) { hay = true; total += DepParse(celda.textContent); }
                }
                vals[j].textContent = hay ? DEP_MONEDA.format(total) : '—';
            }
        }
    }

    if (window.addEventListener) window.addEventListener('load', DepActualizarCards);

    // ------------------------------------------------------ Acciones de Excel
    function DepExportar(nombreGrid) {
        var g = window[nombreGrid];
        if (g && g.ExportTo) g.ExportTo(ASPxClientGridViewExportFormat.Xlsx);
    }

    function DepProximamente(accion) {
        Swal.fire({
            icon: 'info',
            title: accion,
            text: 'Esta funcionalidad estará disponible próximamente.',
            confirmButtonColor: '#1e3a5f'
        });
    }
</script>

</asp:Content>
