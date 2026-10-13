<%@ Page Title="" Language="C#" MasterPageFile="~/MasterContabilidadRT.master" AutoEventWireup="true" CodeFile="InventarioDepreciaciones.aspx.cs" Inherits="InventarioDepreciaciones" %>

<%@ Register Assembly="DevExpress.Web.v23.1, Version=23.1.5.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
<style>
    /* ==================================================================== */
    /* Paleta y tokens (mismos valores que CalcularDepreciaciones.aspx)     */
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

        /* Estados del activo (nuevos). El naranja --dep-accent es de acción. */
        --dep-st-vigente:       #15803d;
        --dep-st-vigente-soft:  #dcfce7;
        --dep-st-agotado:       #475569;
        --dep-st-agotado-soft:  #e2e8f0;
        --dep-st-transito:      #b45309;
        --dep-st-transito-soft: #fef3c7;
        --dep-st-baja:          #b91c1c;
        --dep-st-baja-soft:     #fee2e2;
        --dep-st-sincalc:       #64748b;

        font-family: "Segoe UI", system-ui, -apple-system, Arial, sans-serif;
        color: #1f2937;
    }

    /* ==================================================================== */
    /* Cinta superior                                                       */
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
    .dep-ribbon .rb-label { font-size: 11px; text-transform: uppercase; letter-spacing: .8px; opacity: .7; }
    .dep-ribbon .rb-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
    .dep-ribbon .rb-spacer { flex: 1 1 auto; }

    .dep-ribbon .dxbButton.rb-primary {
        background: var(--dep-accent) !important; border: 1px solid var(--dep-accent) !important;
        color: #fff !important; border-radius: 6px !important; font-weight: 600;
        box-shadow: 0 2px 6px rgba(249, 115, 22, .35);
    }
    .dep-ribbon .dxbButton.rb-primary:hover { filter: brightness(1.07); }
    .dep-ribbon .dxbButton.rb-primary .dxb { padding: 7px 18px !important; }

    .rb-btn {
        display: inline-flex; align-items: center; gap: 7px;
        padding: 7px 14px; border-radius: 6px; cursor: pointer;
        font: inherit; font-size: 13px; font-weight: 500; color: #fff;
        background: rgba(255, 255, 255, .10); border: 1px solid rgba(255, 255, 255, .25);
        transition: background .15s;
    }
    .rb-btn:hover { background: rgba(255, 255, 255, .22); }
    .rb-btn:focus-visible { outline: 2px solid #fff; outline-offset: 2px; }
    .rb-btn svg { width: 16px; height: 16px; flex: none; }

    /* ==================================================================== */
    /* Secciones y grid                                                     */
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

    .dep .dep-grid { border: 0 !important; }
    .dep .dep-grid td, .dep .dep-grid th { font-size: 12.5px; font-variant-numeric: tabular-nums; }
    .dep .dep-grid .dxgvHeader, .dep .dep-grid .dxgvHeader_Office365 {
        background: var(--dep-gen) !important; color: #fff !important; font-weight: 600;
        border-color: rgba(255, 255, 255, .15) !important; vertical-align: middle;
    }
    .dep .dep-grid .dxgvDataRowHover td, .dep .dep-grid .dxgvDataRowHover_Office365 td { background-color: #eff6ff !important; }
    .dep .dep-grid .dxgvFooter td, .dep .dep-grid .dxgvFooter_Office365 td {
        background: #f1f5f9 !important; font-weight: 700; color: #0f172a; border-top: 2px solid #cbd5e1;
    }
    .dep #actGrid .dxgvDataRow td, .dep #actGrid .dxgvDataRow_Office365 td { cursor: pointer; }

    /* Celdas compuestas */
    .ac-desc { font-weight: 600; color: #0f172a; }
    .ac-sub  { font-size: 11.5px; color: var(--dep-muted); margin-top: 1px; }
    .ac-num  { text-align: right; white-space: nowrap; }
    .ac-mark { font-size: 11px; color: var(--dep-st-transito); }

    .sal-bar { height: 4px; background: var(--dep-line); border-radius: 2px; margin-top: 4px; overflow: hidden; min-width: 70px; }
    .sal-bar i { display: block; height: 100%; background: var(--dep-con); }
    .sal-nd  { font-size: 11px; color: var(--dep-muted); font-style: italic; }
    .sal-sc  { color: var(--dep-st-sincalc); font-style: italic; }

    /* Pastilla de estado */
    .st {
        display: inline-flex; align-items: center; gap: 5px;
        padding: 2px 9px; border-radius: 999px; white-space: nowrap;
        font-size: 11.5px; font-weight: 600; border: 1px solid transparent;
    }
    .st::before { content: ""; width: 7px; height: 7px; border-radius: 50%; background: currentColor; }
    .st-vigente  { color: var(--dep-st-vigente);  background: var(--dep-st-vigente-soft); }
    .st-agotado  { color: var(--dep-st-agotado);  background: var(--dep-st-agotado-soft); }
    .st-transito { color: var(--dep-st-transito); background: var(--dep-st-transito-soft); }
    .st-baja     { color: var(--dep-st-baja);     background: var(--dep-st-baja-soft); }
    .st-sincalc  { color: var(--dep-st-sincalc);  background: #fff; border: 1px dashed #94a3b8; }

    /* Acciones por renglón */
    .ac-btns { display: inline-flex; gap: 4px; }
    .ac-btn {
        width: 28px; height: 28px; padding: 0; border-radius: 6px; cursor: pointer;
        display: inline-flex; align-items: center; justify-content: center;
        background: #fff; border: 1px solid var(--dep-line); color: var(--dep-navy);
    }
    .ac-btn:hover { background: #eff6ff; border-color: #bfdbfe; }
    .ac-btn:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 1px; }
    .ac-btn.ac-baja { color: var(--dep-st-baja); }
    .ac-btn:disabled { opacity: .35; cursor: not-allowed; background: #fff; }
    .ac-btn svg { width: 15px; height: 15px; }

    /* ==================================================================== */
    /* Etapa 3: barra de estados, buscador, panel de filtros y chips        */
    /* ==================================================================== */
    .st-bar-wrap { margin: 0 0 14px 0; }
    .st-bar {
        display: flex; height: 12px; border-radius: 6px; overflow: hidden;
        background: var(--dep-line);
    }
    .st-bar button { border: 0; padding: 0; cursor: pointer; min-width: 0; transition: opacity .15s, filter .15s; }
    .st-bar button:hover { filter: brightness(1.1); }
    .st-bar button:focus-visible { outline: 2px solid var(--dep-navy); outline-offset: -2px; }
    .st-bar.con-estado button:not([aria-pressed="true"]) { opacity: .3; }
    .st-leyenda { display: flex; flex-wrap: wrap; gap: 6px 14px; margin-top: 8px; }
    .st-leyenda button {
        display: inline-flex; align-items: center; gap: 7px; padding: 4px 8px;
        border: 1px solid transparent; border-radius: 6px; background: none; cursor: pointer;
        font: inherit; font-size: 12.5px; color: #1f2937;
    }
    .st-leyenda button:hover { background: var(--dep-bg); border-color: var(--dep-line); }
    .st-leyenda button[aria-pressed="true"] { background: #fff; border-color: var(--dep-navy); box-shadow: 0 1px 3px rgba(15,23,42,.12); }
    .st-leyenda button:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 1px; }
    .st-leyenda .dot { width: 10px; height: 10px; border-radius: 3px; flex: none; }
    .st-leyenda .num { color: var(--dep-muted); font-variant-numeric: tabular-nums; }
    .c-vigente  { background: var(--dep-st-vigente); }
    .c-agotado  { background: var(--dep-st-agotado); }
    .c-sincalc  { background: repeating-linear-gradient(45deg, #94a3b8 0 3px, #cbd5e1 3px 6px); }
    .c-transito { background: var(--dep-st-transito); }
    .c-baja     { background: var(--dep-st-baja); }

    .act-layout { display: grid; grid-template-columns: 260px minmax(0, 1fr); gap: 16px; align-items: start; }
    .act-panel {
        background: #fff; border: 1px solid var(--dep-line); border-radius: 10px;
        box-shadow: 0 1px 3px rgba(15, 23, 42, .05); padding: 4px 14px 14px 14px;
    }
    .act-panel-head { display: flex; align-items: center; justify-content: space-between; padding: 10px 0 4px 0; }
    .act-panel-head h2 { margin: 0; font-size: 15px; font-weight: 600; color: var(--dep-navy); }
    .f-grupo { padding: 10px 0; border-top: 1px solid var(--dep-line); }
    .f-grupo:first-of-type { border-top: 0; }
    .f-titulo { display: block; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .7px; color: var(--dep-muted); margin-bottom: 6px; }

    /* Acordeón (Tipo de activo) */
    .f-acordeon {
        display: flex; align-items: center; gap: 6px; width: 100%;
        background: none; border: 0; padding: 2px 0; margin: 0; cursor: pointer; text-align: left; font: inherit;
    }
    .f-acordeon .f-titulo { margin: 0; }
    .f-acordeon:hover .f-titulo { color: var(--dep-navy); }
    .f-acordeon:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 2px; border-radius: 4px; }
    .f-flecha { width: 14px; height: 14px; margin-left: auto; color: var(--dep-muted); transition: transform .15s; flex: none; }
    .f-acordeon[aria-expanded="true"] .f-flecha { transform: rotate(90deg); }
    .f-sel { font-size: 11px; font-weight: 600; color: var(--dep-con-ink); background: var(--dep-con-soft); border-radius: 999px; padding: 0 7px; }
    .f-sel:empty { display: none; }
    .f-acordeon-cuerpo { margin-top: 8px; max-height: 320px; overflow-y: auto; }
    .f-acordeon-cuerpo[hidden] { display: none; }
    .f-ninguno { margin-top: 6px; }
    .f-rango { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; }
    .f-rango label { font-size: 11px; color: var(--dep-muted); display: block; margin-bottom: 2px; }
    .f-atajos { display: flex; flex-wrap: wrap; gap: 4px; margin-top: 6px; }
    .f-atajos button, .lnk {
        border: 1px solid var(--dep-line); background: #fff; border-radius: 999px; cursor: pointer;
        font: inherit; font-size: 11.5px; padding: 2px 9px; color: var(--dep-navy-2);
    }
    .f-atajos button:hover, .lnk:hover { background: #eff6ff; border-color: #bfdbfe; }
    .f-atajos button:focus-visible, .lnk:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 1px; }

    /* Segmentado sobre fondo claro */
    .seg-claro { display: flex; flex-wrap: wrap; background: var(--dep-gen-soft); border-radius: 8px; padding: 3px; gap: 2px; }
    .seg-claro button {
        flex: 1 1 auto; border: 0; background: transparent; color: var(--dep-gen);
        font: inherit; font-size: 12px; font-weight: 500; padding: 5px 8px; border-radius: 6px; cursor: pointer;
    }
    .seg-claro button[aria-pressed="true"] { background: #fff; color: var(--dep-navy); box-shadow: 0 1px 3px rgba(0,0,0,.15); font-weight: 600; }
    .seg-claro button:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 1px; }

    .act-buscar { margin-bottom: 10px; }
    .act-buscar .dxeEditArea_Office365, .act-buscar input { font-size: 15px !important; }
    .act-buscar-ayuda { font-size: 11.5px; color: var(--dep-muted); margin-top: 4px; }
    .act-buscar-ayuda kbd {
        font: inherit; font-size: 11px; padding: 0 5px; border: 1px solid #cbd5e1; border-bottom-width: 2px;
        border-radius: 4px; background: #fff; color: var(--dep-gen);
    }

    .act-chips { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; margin-bottom: 10px; min-height: 26px; }
    .act-contador { font-size: 12.5px; color: var(--dep-muted); margin-right: 4px; }
    .act-contador b { color: #0f172a; }
    .chip {
        display: inline-flex; align-items: center; gap: 6px; padding: 3px 4px 3px 10px;
        background: var(--dep-con-soft); color: var(--dep-con-ink); border-radius: 999px; font-size: 12px; font-weight: 500;
    }
    .chip button {
        border: 0; background: transparent; color: inherit; cursor: pointer; font-size: 14px; line-height: 1;
        width: 20px; height: 20px; border-radius: 50%;
    }
    .chip button:hover { background: rgba(30, 64, 175, .12); }
    .chip button:focus-visible { outline: 2px solid var(--dep-con-ink); outline-offset: 0; }

    .act-vacio { padding: 28px 12px; text-align: center; color: var(--dep-muted); }
    .act-vacio b { display: block; font-size: 15px; color: #0f172a; margin-bottom: 6px; }
    .act-vacio .v-filtros { display: none; }
    .dep.con-filtros .act-vacio .v-filtros { display: block; }
    .dep.con-filtros .act-vacio .v-sin { display: none; }

    mark { background: #fef08a; color: inherit; padding: 0 1px; border-radius: 2px; }

    .act-toggle { display: none; }
    @media (max-width: 979px) {
        .act-layout { grid-template-columns: minmax(0, 1fr); }
        .act-toggle { display: inline-flex; margin-bottom: 10px; }
        .act-panel { display: none; }
        .dep.panel-abierto .act-panel { display: block; }
    }
    @media (prefers-reduced-motion: reduce) {
        .st-bar button, .rb-btn, .f-flecha { transition: none; }
    }

    /* ==================================================================== */
    /* Etapa 4: popup de captura y edición                                  */
    /* ==================================================================== */
    .pop { font-family: "Segoe UI", system-ui, -apple-system, Arial, sans-serif; color: #1f2937; }
    .pop-aviso-baja {
        margin: 0 0 12px 0; padding: 8px 12px; border-radius: 8px; font-size: 12.5px;
        background: var(--dep-st-baja-soft); color: var(--dep-st-baja); border: 1px solid #fecaca;
    }
    .pop-seccion { margin: 0 0 14px 0; }
    .pop-seccion > h3 {
        margin: 0 0 8px 0; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .7px; color: var(--dep-navy);
    }
    /* 6 columnas; en pantallas angostas colapsa a 2 */
    .pop-grid { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 10px 12px; }
    .pop-grid .c1 { grid-column: span 1; }
    .pop-grid .c2 { grid-column: span 2; }
    .pop-grid .c3 { grid-column: span 3; }
    .pop-grid .c4 { grid-column: span 4; }
    .pop-grid .c6 { grid-column: span 6; }
    @media (max-width: 760px) {
        .pop-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .pop-grid .c1, .pop-grid .c2, .pop-grid .c3, .pop-grid .c4, .pop-grid .c6 { grid-column: span 2; }
    }
    .pop-lbl { display: block; font-size: 12px; font-weight: 600; color: var(--dep-gen); margin-bottom: 3px; }
    .pop-lbl .req { color: var(--dep-st-baja); }
    .pop-ayuda { font-size: 11.5px; color: var(--dep-muted); margin-top: 3px; }
    .pop-tope { font-size: 11.5px; color: var(--dep-con-ink); margin-top: 3px; font-weight: 600; }
    .f-err { font-size: 11.5px; color: var(--dep-st-baja); margin-top: 3px; min-height: 0; }
    .f-err:empty { display: none; }
    .pop-chk { margin-top: 4px; font-size: 12px; }

    .pop-aviso {
        margin-top: 8px; padding: 8px 12px; border-radius: 8px; font-size: 12.5px;
        background: var(--dep-st-transito-soft); color: #78350f; border: 1px solid #fcd34d;
    }
    .pop-aviso .lnk { margin: 6px 6px 0 0; }
    .pop-veh { display: flex; flex-direction: column; gap: 4px; margin-top: 6px; }
    .pop-veh label { display: flex; align-items: center; gap: 6px; cursor: pointer; }
    .pop-veh input:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 2px; }
    .pop-aviso[hidden] { display: none; }

    .pop-prev {
        display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px;
        padding: 10px 12px; border-radius: 8px; background: var(--dep-bg); border: 1px dashed #cbd5e1;
    }
    @media (max-width: 760px) { .pop-prev { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
    .pop-prev .k { display: block; font-size: 11px; color: var(--dep-muted); }
    .pop-prev .v { display: block; font-size: 14px; font-weight: 700; color: #0f172a; font-variant-numeric: tabular-nums; }
    .pop-prev-tit { font-size: 11px; color: var(--dep-muted); margin: 0 0 6px 0; }

    .pop-pie {
        display: flex; flex-wrap: wrap; align-items: center; gap: 8px;
        margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--dep-line);
    }
    .pop-pie .pop-contador { font-size: 12px; color: var(--dep-muted); margin-right: auto; }
    .pop-pie .pop-atajos { font-size: 11px; color: var(--dep-muted); width: 100%; }
    .pop-pie kbd {
        font: inherit; font-size: 11px; padding: 0 5px; border: 1px solid #cbd5e1; border-bottom-width: 2px;
        border-radius: 4px; background: #fff; color: var(--dep-gen);
    }
    .btn {
        display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; border-radius: 6px; cursor: pointer;
        font: inherit; font-size: 13px; font-weight: 600; border: 1px solid var(--dep-line); background: #fff; color: var(--dep-gen);
    }
    .btn:hover { background: var(--dep-bg); }
    .btn:focus-visible { outline: 2px solid var(--dep-con); outline-offset: 2px; }
    .btn-primario { background: var(--dep-accent); border-color: var(--dep-accent); color: #fff; box-shadow: 0 2px 6px rgba(249, 115, 22, .3); }
    .btn-primario:hover { background: var(--dep-accent); filter: brightness(1.07); }
    .btn-sec { color: var(--dep-navy); border-color: #bfdbfe; background: #eff6ff; }
    .btn[disabled] { opacity: .5; cursor: wait; }
    .btn[hidden] { display: none; }

    /* ==================================================================== */
    /* Etapa 5: baja (registrar, ver detalle y revertir)                    */
    /* ==================================================================== */
    /* SweetAlert2 por encima de los popups modales de DevExpress */
    .swal2-container { z-index: 30000 !important; }
    .ac-btn.ac-verbaja { color: var(--dep-st-baja); background: var(--dep-st-baja-soft); border-color: #fecaca; }
    .ac-btn.ac-verbaja:hover { background: #fecaca; }
    .bj-resumen {
        padding: 10px 12px; margin: 0 0 14px 0; border-radius: 8px;
        background: var(--dep-bg); border: 1px solid var(--dep-line);
    }
    .bj-desc { font-weight: 600; color: #0f172a; margin-bottom: 8px; }
    .bj-cargando { color: var(--dep-muted); font-style: italic; }
    .bj-campos { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px 14px; }
    @media (max-width: 760px) { .bj-campos { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
    .bj-campo .k { display: block; font-size: 11px; color: var(--dep-muted); }
    .bj-campo .v { display: block; font-size: 13px; font-weight: 600; color: #0f172a; font-variant-numeric: tabular-nums; overflow-wrap: anywhere; }
    .bj-campo.bj-dest .v { color: var(--dep-navy); font-size: 14px; }
    .bj-nota { font-size: 12px; color: var(--dep-st-baja); margin-right: auto; }
    .btn-peligro { background: var(--dep-st-baja); border-color: var(--dep-st-baja); color: #fff; }
    .btn-peligro:hover { background: var(--dep-st-baja); filter: brightness(1.1); }
    .btn-peligro[disabled] { cursor: not-allowed; }

    /* Detalle (ActivosDetalle) */
    .child-wrap { padding: 10px 12px 12px 12px; background: var(--dep-bg); border-left: 4px solid var(--dep-navy-2); }
    .child-title { font-size: 13px; color: var(--dep-muted); margin-bottom: 8px; }
</style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="Server">

<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%-- El script va ANTES de los controles: sus eventos de cliente deben existir cuando DevExpress los crea. --%>
<%-- ==================================================================== --%>
<%-- JAVASCRIPT                                                           --%>
<%-- ==================================================================== --%>
<script type="text/javascript">
    // Este script corre ANTES de que el navegador cargue las librerías de DevExpress
    // (DXR.axd), así que nada aquí puede usar ASPxClientControl fuera de una función.
    // ActAlIniciar ejecuta fn una sola vez, cuando todos los controles ya existen:
    // en ControlsInitialized o, de respaldo, en window.load.
    function ActAlIniciar(fn) {
        var hecho = false;
        function correr() { if (!hecho) { hecho = true; fn(); } }
        function registrar() {
            if (window.ASPxClientControl) {
                ASPxClientControl.GetControlCollection().ControlsInitialized.AddHandler(function (s, e) {
                    if (!e || !e.isCallback) correr();
                });
            }
            window.addEventListener('load', function () { setTimeout(correr, 0); });
        }
        if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', registrar);
        else registrar();
    }

    // Clic en el renglón = Editar, salvo sobre botones, enlaces, el expansor del detalle o el propio detalle
    function ActRowClick(s, e) {
        var t = e.htmlEvent ? (e.htmlEvent.target || e.htmlEvent.srcElement) : null;
        if (t && t.closest && t.closest('button, a, input, [class*="DetailCollapsedButton"], [class*="DetailExpandedButton"], [class*="DetailButton"], [class*="DetailRow"]'))
            return;
        var id = s.GetRowKey(e.visibleIndex);
        if (id !== null && id !== undefined) ActEditar(id);
    }

    // Exportación del lado del cliente, como en CalcularDepreciaciones.
    // El servidor cambia a las columnas planas en BeforeExport.
    function ActExportar() {
        if (window.VistaActivos && VistaActivos.ExportTo) VistaActivos.ExportTo(ASPxClientGridViewExportFormat.Xlsx);
    }

    // =====================================================================
    // Etapa 3: filtros, buscador, chips y barra de estados
    // El estado de los filtros vive en un objeto JS; se guarda en HfFiltros
    // (viaja con paginación, orden y exportación) y se manda en el parámetro
    // de PerformCallback. El servidor lo valida y lo acota antes de llamar al SP.
    // =====================================================================
    var ACT_ESTADOS = { vigente: 'Con saldo', agotado: 'Vida útil agotada', sincalc: 'Sin calcular', transito: 'En tránsito', baja: 'Baja' };
    var ACT_SALDOS  = { cero: 'igual a 0', pos: 'mayor a 0', sincalc: 'sin calcular' };
    var ACT_MONEDA  = new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' });

    var actFiltro = { e: '', s: '', b: '' };   // estado (barra), saldo y bajas (segmentados)
    var actN = null, actUniverso = null;       // N de M activos
    var actTimer = null, actPendiente = false, actUltimoTexto = '';

    function ActPad(n)          { return (n < 10 ? '0' : '') + n; }
    function ActIso(d)          { return d ? d.getFullYear() + '-' + ActPad(d.getMonth() + 1) + '-' + ActPad(d.getDate()) : null; }
    function ActFechaTexto(d)   { return ActPad(d.getDate()) + '/' + ActPad(d.getMonth() + 1) + '/' + d.getFullYear(); }
    function ActTextoEstado(e)  { return ACT_ESTADOS[e] || e; }
    function ActSinConteo(t)    { return String(t).replace(/\s*\([\d,]+\)\s*$/, ''); }
    function ActEsc(s) {
        return String(s).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    function ActLeerFiltros() {
        var f = {};
        var t = (TxtBuscar.GetText() || '').replace(/\s+/g, ' ').trim();
        if (t) f.t = t.substring(0, 200);
        if (actFiltro.e) f.e = actFiltro.e;
        if (actFiltro.s) f.s = actFiltro.s;
        if (actFiltro.b) f.b = actFiltro.b;
        var c = CblConv.GetSelectedValues(); if (c.length) f.c = c;
        var k = CblTipo.GetSelectedValues(); if (k.length) f.k = k;
        var ad = ActIso(DeAdqDesde.GetDate()), ah = ActIso(DeAdqHasta.GetDate());
        var ud = ActIso(DeUsoDesde.GetDate()), uh = ActIso(DeUsoHasta.GetDate());
        if (ad) f.ad = ad;
        if (ah) f.ah = ah;
        if (ud) f.ud = ud;
        if (uh) f.uh = uh;
        var mn = SeMoiMin.GetValue(), mx = SeMoiMax.GetValue();
        if (mn !== null && mn !== '' && !isNaN(mn)) f.mn = Number(mn);
        if (mx !== null && mx !== '' && !isNaN(mx)) f.mx = Number(mx);
        return f;
    }

    function ActAplicar() {
        try {
            clearTimeout(actTimer);
            var f = ActLeerFiltros();
            var json = JSON.stringify(f);
            actUltimoTexto = f.t || '';
            HfFiltros.Set('f', json);
            ActPintarChips(f);
            if (VistaActivos.InCallback()) { actPendiente = true; return; }
            VistaActivos.PerformCallback('filtrar|' + json);
        } catch (x) {
            if (window.console) console.error('ActAplicar', x);
        }
    }

    // ------------------------------------------------------------ Buscador
    function ActBuscarKeyDown(s, e) {
        var k = e.htmlEvent.keyCode;
        if (k === 13) {                       // Enter: busca ya, sin enviar el formulario
            ASPxClientUtils.PreventEvent(e.htmlEvent);
            ActAplicar();
        } else if (k === 27) {                // Esc: limpia
            ASPxClientUtils.PreventEvent(e.htmlEvent);
            if (s.GetText()) { s.SetText(''); ActAplicar(); }
        }
    }

    function ActBuscarKeyUp(s, e) {           // espera 300 ms después de la última tecla
        clearTimeout(actTimer);
        actTimer = setTimeout(function () {
            var t = (TxtBuscar.GetText() || '').replace(/\s+/g, ' ').trim();
            if (t !== actUltimoTexto) ActAplicar();
        }, 300);
    }

    // "/" enfoca el buscador si no se está escribiendo en otro campo ni hay un aviso abierto
    document.addEventListener('keydown', function (ev) {
        if (ev.key !== '/' || ev.ctrlKey || ev.altKey || ev.metaKey) return;
        var a = document.activeElement, tag = a ? a.tagName : '';
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || (a && a.isContentEditable)) return;
        if (document.querySelector('.swal2-container')) return;
        if (ActHayPopupAbierto()) return;
        ev.preventDefault();
        TxtBuscar.Focus();
    });

    // ------------------------------------------------------------ Panel
    function ActSeg(btn) {
        var clave = btn.parentNode.getAttribute('data-filtro');
        actFiltro[clave] = btn.getAttribute('data-v');
        ActMarcarSeg(clave);
        ActAplicar();
    }

    function ActMarcarSeg(clave) {
        var grupo = document.querySelector('.seg-claro[data-filtro="' + clave + '"]');
        if (!grupo) return;
        var bs = grupo.querySelectorAll('button');
        for (var i = 0; i < bs.length; i++)
            bs[i].setAttribute('aria-pressed', bs[i].getAttribute('data-v') === (actFiltro[clave] || '') ? 'true' : 'false');
    }

    function ActAtajo(campo, cual) {
        var y = new Date().getFullYear(), desde = null, hasta = null;
        if (cual === 'actual')     { desde = new Date(y, 0, 1);     hasta = new Date(y, 11, 31); }
        if (cual === 'anterior')   { desde = new Date(y - 1, 0, 1); hasta = new Date(y - 1, 11, 31); }
        if (cual === 'anteriores') { hasta = new Date(y - 2, 11, 31); }
        (campo === 'adq' ? DeAdqDesde : DeUsoDesde).SetDate(desde);
        (campo === 'adq' ? DeAdqHasta : DeUsoHasta).SetDate(hasta);
        ActAplicar();
    }

    // Acordeón del panel: el estado abierto/cerrado se recuerda en la sesión del navegador.
    function ActAcordeon(nombre, abrir) {
        var btn = document.getElementById('btn' + nombre), pan = document.getElementById('pan' + nombre);
        if (!btn || !pan) return;
        var abierto = (abrir === undefined) ? btn.getAttribute('aria-expanded') !== 'true' : !!abrir;
        btn.setAttribute('aria-expanded', abierto ? 'true' : 'false');
        pan.hidden = !abierto;
        try { sessionStorage.setItem('act.acordeon.' + nombre, abierto ? '1' : '0'); } catch (x) { }
    }

    function ActTogglePanel() {
        var abierto = document.getElementById('actWrap').classList.toggle('panel-abierto');
        document.getElementById('actToggle').setAttribute('aria-expanded', abierto ? 'true' : 'false');
    }

    function ActDesmarcar(lista, valor) {
        for (var i = 0; i < lista.GetItemCount(); i++)
            if (String(lista.GetItem(i).value) === String(valor)) lista.UnselectIndices([i]);
    }

    function ActQuitar(clave, valor) {
        switch (clave) {
            case 't':  TxtBuscar.SetText(''); break;
            case 'e': case 's': case 'b': actFiltro[clave] = ''; ActMarcarSeg(clave); break;
            case 'c':  ActDesmarcar(CblConv, valor); break;
            case 'k':  ActDesmarcar(CblTipo, valor); break;
            case 'ad': DeAdqDesde.SetDate(null); DeAdqHasta.SetDate(null); break;
            case 'ud': DeUsoDesde.SetDate(null); DeUsoHasta.SetDate(null); break;
            case 'mn': SeMoiMin.SetValue(null); SeMoiMax.SetValue(null); break;
        }
        ActAplicar();
    }

    function ActLimpiarTodo() {
        TxtBuscar.SetText('');
        actFiltro = { e: '', s: '', b: '' };
        ActMarcarSeg('s'); ActMarcarSeg('b');
        CblConv.UnselectAll(); CblTipo.UnselectAll();
        DeAdqDesde.SetDate(null); DeAdqHasta.SetDate(null);
        DeUsoDesde.SetDate(null); DeUsoHasta.SetDate(null);
        SeMoiMin.SetValue(null); SeMoiMax.SetValue(null);
        ActAplicar();
    }

    // ------------------------------------------------------------ Chips
    function ActChip(texto, quitar) {
        return '<span class="chip">' + ActEsc(texto) +
               '<button type="button" aria-label="Quitar filtro: ' + ActEsc(texto) + '" onclick="' + quitar + '; return false;">&times;</button></span>';
    }

    function ActRango(a, b, fmt) {
        var hayA = a !== null && a !== undefined, hayB = b !== null && b !== undefined;
        if (hayA && hayB) return fmt(a) + ' – ' + fmt(b);
        if (hayA) return 'desde ' + fmt(a);
        return 'hasta ' + fmt(b);
    }

    function ActPintarChips(f) {
        var h = [], i, sel;
        if (f.t) h.push(ActChip('Búsqueda: "' + f.t + '"', "ActQuitar('t')"));
        if (f.e) h.push(ActChip('Estado: ' + ActTextoEstado(f.e), "ActQuitar('e')"));
        if (f.s) h.push(ActChip('Saldo ' + ACT_SALDOS[f.s], "ActQuitar('s')"));
        if (f.b) h.push(ActChip(f.b === 'solo' ? 'Solo bajas' : 'Sin bajas', "ActQuitar('b')"));
        sel = CblConv.GetSelectedItems();
        for (i = 0; i < sel.length; i++) h.push(ActChip(ActSinConteo(sel[i].text), "ActQuitar('c', " + Number(sel[i].value) + ")"));
        sel = CblTipo.GetSelectedItems();
        for (i = 0; i < sel.length; i++) h.push(ActChip(ActSinConteo(sel[i].text), "ActQuitar('k', " + Number(sel[i].value) + ")"));
        if (f.ad || f.ah) h.push(ActChip('Adquisición ' + ActRango(DeAdqDesde.GetDate(), DeAdqHasta.GetDate(), ActFechaTexto), "ActQuitar('ad')"));
        if (f.ud || f.uh) h.push(ActChip('Uso ' + ActRango(DeUsoDesde.GetDate(), DeUsoHasta.GetDate(), ActFechaTexto), "ActQuitar('ud')"));
        if (f.mn !== undefined || f.mx !== undefined)
            h.push(ActChip('MOI ' + ActRango(f.mn, f.mx, function (v) { return ACT_MONEDA.format(v); }), "ActQuitar('mn')"));

        var contador = '';
        if (actN !== null && actUniverso !== null)
            contador = '<span class="act-contador"><b>' + actN.toLocaleString('es-MX') + '</b> de ' + actUniverso.toLocaleString('es-MX') + ' activos</span>';

        document.getElementById('actChips').innerHTML = contador + h.join('');
        document.getElementById('actWrap').classList.toggle('con-filtros', h.length > 0);
        document.getElementById('actToggle').textContent = h.length ? 'Filtros (' + h.length + ')' : 'Filtros';

        // Con el acordeón cerrado, el encabezado dice cuántos tipos están elegidos.
        var nTipos = CblTipo.GetSelectedValues().length;
        document.getElementById('selTipo').textContent = nTipos ? nTipos + (nTipos === 1 ? ' elegido' : ' elegidos') : '';
    }

    // ------------------------------------------------------------ Barra de estados
    function ActEstado(e) {
        actFiltro.e = (actFiltro.e === e) ? '' : e;   // segundo clic lo quita
        ActAplicar();
    }

    function ActPintarBarra(resumen) {
        var totalMoi = 0, totalN = 0, i, bar = '', ley = '';
        for (i = 0; i < resumen.length; i++) { totalMoi += resumen[i].m; totalN += resumen[i].n; }
        for (i = 0; i < resumen.length; i++) {
            var r = resumen[i], t = ActTextoEstado(r.e);
            var pulsado = actFiltro.e === r.e ? 'true' : 'false';
            var peso = totalMoi > 0 ? r.m / totalMoi : (totalN > 0 ? r.n / totalN : 0);
            var detalle = r.n + (r.n === 1 ? ' activo · ' : ' activos · ') + ACT_MONEDA.format(r.m);
            if (peso > 0)
                bar += '<button type="button" class="c-' + r.e + '" style="flex:' + peso.toFixed(6) + ' 1 0" aria-pressed="' + pulsado +
                       '" title="' + ActEsc(t + ': ' + detalle) + '" aria-label="' + ActEsc('Filtrar ' + t + ': ' + detalle) +
                       '" onclick="ActEstado(\'' + r.e + '\'); return false;"></button>';
            ley += '<button type="button" aria-pressed="' + pulsado + '" onclick="ActEstado(\'' + r.e + '\'); return false;">' +
                   '<span class="dot c-' + r.e + '"></span>' + ActEsc(t) + ' <span class="num">' + ActEsc(detalle) + '</span></button>';
        }
        var elBar = document.getElementById('actBar');
        elBar.innerHTML = bar;
        elBar.classList.toggle('con-estado', !!actFiltro.e);
        document.getElementById('actLeyenda').innerHTML = ley;
    }

    // ------------------------------------------------------------ Después de cada carga de datos
    function ActDespuesDeDatos(s) {
        if (s.cpCorte !== undefined) document.getElementById('actCorte').textContent = s.cpCorte;
        if (s.cpTotal !== undefined) document.getElementById('actTotal').textContent = s.cpTotal;
        if (s.cpN !== undefined && s.cpN !== null) actN = s.cpN;
        if (s.cpUniverso !== undefined && s.cpUniverso !== null) actUniverso = s.cpUniverso;
        if (s.cpResumen) { try { ActPintarBarra(JSON.parse(s.cpResumen)); } catch (x) { if (window.console) console.error('ActPintarBarra', x); } }
        ActPintarChips(ActLeerFiltros());
        ActMostrarError(s);
    }

    function ActMostrarError(s) {
        if (s.cpError) {
            Swal.fire({ icon: 'error', title: 'No se pudo consultar los activos', text: s.cpError, confirmButtonColor: '#1e3a5f' });
            s.cpError = '';
        }
    }

    // ActInit corre antes de que existan los demás controles; la primera
    // pintura se hace cuando todos están inicializados.
    function ActInit(s, e) { }
    ActAlIniciar(function () {
        var abrirTipo = false;
        try { abrirTipo = sessionStorage.getItem('act.acordeon.Tipo') === '1'; } catch (x) { }
        ActAcordeon('Tipo', abrirTipo);
        if (window.VistaActivos) ActDespuesDeDatos(VistaActivos);
    });

    function ActEndCallback(s, e) {
        ActDespuesDeDatos(s);
        if (actPendiente) { actPendiente = false; ActAplicar(); }
    }

    function ActCallbackError(s, e) {
        e.handled = true;
        Swal.fire({ icon: 'error', title: 'Ocurrió un error', text: e.message, confirmButtonColor: '#1e3a5f' });
    }

    // =====================================================================
    // Etapa 4: captura y edición en ventana emergente
    // Configuración que manda el servidor (RegisterClientScriptBlock):
    //   ACT_CATALOGOS_TRANSPORTE ids de CatalogoCuentas de "Equipo de transporte"
    //   ACT_PERMITIR_TRANSITO appSettings["Activos.PermitirTransito"]
    // =====================================================================
    var actPop = {
        modo: 'alta', id: 0, detId: 0, tope: null,
        conceptoPendiente: null, tasaPendiente: null, conceptosPorUsuario: false,
        capturados: 0, guardarOtro: false, guardando: false, adqAnterior: null
    };
    var ACT_POP_ORDEN = ['PopTipo', 'PopConv', 'PopConcepto', 'PopDesc', 'PopIdent', 'PopFAdq', 'PopFUso',
                         'PopMoi', 'PopMoiF', 'PopTF', 'PopTC', 'PopSerie', 'PopCond', 'PopColor', 'PopClave'];
    var ACT_POP_ERRORES = ['cat', 'conv', 'concepto', 'desc', 'ident', 'fadq', 'fuso', 'moi', 'moif', 'veh', 'tf', 'tc',
                           'serie', 'cond', 'color', 'clave', 'general'];
    var ACT_POP_EDITOR_DE = {
        cat: 'PopTipo', conv: 'PopConv', concepto: 'PopConcepto', desc: 'PopDesc', ident: 'PopIdent',
        fadq: 'PopFAdq', fuso: 'PopFUso', moi: 'PopMoi', moif: 'PopMoiF', tf: 'PopTF', tc: 'PopTC',
        serie: 'PopSerie', cond: 'PopCond', color: 'PopColor', clave: 'PopClave'
    };
    var ACT_MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

    function ActNuevo()       { ActPopAbrir('alta', 0); }
    function ActEditar(id)    { ActPopAbrir('editar', id); }
    function ActDuplicar(id)  { ActPopAbrir('duplicar', id); }

    // Los atajos de teclado del listado no aplican con una ventana emergente abierta.
    function ActHayPopupAbierto() {
        return (window.PopActivo && PopActivo.IsVisible()) || (window.PopBaja && PopBaja.IsVisible());
    }

    function ActNum(ed) {
        var v = ed.GetValue();
        if (v === null || v === undefined || v === '') return null;
        var n = Number(v);
        return isNaN(n) ? null : n;
    }
    function ActTexto(ed) { return (ed.GetText() || '').trim(); }
    function ActFechaDeIso(s) {
        if (!s) return null;
        var p = s.split('-');
        return new Date(Number(p[0]), Number(p[1]) - 1, Number(p[2]));
    }
    function ActPct(n) { return (Math.round(n * 10000) / 10000).toLocaleString('es-MX', { maximumFractionDigits: 4 }); }

    // ------------------------------------------------------------ Abrir / limpiar
    function ActPopAbrir(modo, id) {
        try {
            ActPopAbrirInterno(modo, id);
        } catch (x) {
            // Cualquier falla al abrir se muestra; antes el clic "no hacía nada".
            actPop.guardando = false;
            var faltan = [];
            ['PopActivo', 'CbActivo'].concat(ACT_POP_ORDEN).concat(['PopTransito', 'PopMoiIgual']).forEach(function (n) {
                if (typeof window[n] === 'undefined') faltan.push(n);
            });
            Swal.fire({
                icon: 'error', title: 'No se pudo abrir la captura',
                html: ActEsc(x && x.message ? x.message : String(x)) +
                      (faltan.length ? '<br><br>Controles no creados: ' + ActEsc(faltan.join(', ')) : ''),
                confirmButtonColor: '#1e3a5f'
            });
        }
    }

    function ActPopAbrirInterno(modo, id) {
        // Si una carga anterior nunca respondió, no debe bloquear las siguientes aperturas.
        if (actPop.guardando && !PopActivo.IsVisible()) actPop.guardando = false;
        if (actPop.guardando) return;
        ActPopLimpiar(true);
        actPop.modo = modo;
        actPop.id = (modo === 'editar') ? id : 0;

        PopActivo.SetHeaderText(modo === 'alta' ? 'Nuevo activo'
                              : modo === 'editar' ? 'Editar folio ' + id
                              : 'Duplicar folio ' + id + ' (nuevo activo)');
        document.getElementById('btnGuardarOtro').hidden = (modo === 'editar');
        PopMoi.SetEnabled(modo !== 'editar');
        document.getElementById('popMoiAyuda').textContent =
            modo === 'editar' ? 'El MOI contable no se puede cambiar una vez creado el activo.' : '';
        ActPopContador();

        if (modo === 'alta') {
            PopActivo.Show();
        } else {
            ActPopOcupado(true);
            PopActivo.Show();
            CbActivo.PerformCallback('cargar|' + Number(id));
        }
    }

    // todo = true: vacía todo. todo = false ("Guardar y capturar otro"): conserva tipo,
    // tipo de depreciación, concepto, fechas y tasas; limpia descripción, identificador, MOI y detalle.
    function ActPopLimpiar(todo) {
        ActPopMostrarErrores({});
        PopDesc.SetText(''); PopIdent.SetText('');
        PopMoi.SetValue(null); PopMoiF.SetValue(null);
        PopMoiIgual.SetChecked(true); PopMoiF.SetEnabled(false);
        PopSerie.SetText(''); PopCond.SetText(''); PopColor.SetText(''); PopClave.SetText('');
        actPop.detId = 0;
        document.getElementById('popAvisoBaja').hidden = true;
        document.getElementById('popAvisoCalc').hidden = true;
        ActPopLimpiarVehiculo();
        document.getElementById('popDetAyuda').textContent =
            'Déjalo vacío si el activo no lleva estos datos. Al vaciar todos los campos de un detalle existente, se marca como borrado.';

        if (todo) {
            PopTipo.SetValue(null);
            PopConv.SetValue(1);
            PopConcepto.ClearItems(); PopConcepto.SetValue(null);
            actPop.tope = null; actPop.conceptoPendiente = null; actPop.tasaPendiente = null;
            document.getElementById('popTope').textContent = '';
            PopFAdq.SetDate(null); PopFUso.SetDate(null); actPop.adqAnterior = null;
            PopTransito.SetChecked(false); PopFUso.SetEnabled(true);
            PopTF.SetValue(null); PopTC.SetValue(null);
            ActAcordeon('Det', false);
        }
        ActPopPrevia();
    }

    function ActPopContador() {
        var n = actPop.capturados;
        document.getElementById('popContador').textContent =
            n ? n + (n === 1 ? ' activo capturado en esta sesión' : ' activos capturados en esta sesión') : '';
    }

    function ActPopOcupado(si) {
        actPop.guardando = si;
        document.getElementById('btnGuardar').disabled = si;
        document.getElementById('btnGuardarOtro').disabled = si;
    }

    function ActPopMostrado() {
        var ed = (actPop.modo === 'alta' && PopTipo.GetValue() === null) ? PopTipo : PopDesc;
        setTimeout(function () { ed.Focus(); }, 50);
    }
    function ActPopCerrado() { ActPopOcupado(false); }

    // ------------------------------------------------------------ Concepto LISR (lógica de ObtenerTiposGrupos)
    function ActPopCargarConceptos(porUsuario) {
        var cat = PopTipo.GetValue(), conv = PopConv.GetValue();
        PopConcepto.ClearItems(); PopConcepto.SetValue(null);
        actPop.tope = null;
        PopTF.SetMaxValue(100); PopTC.SetMaxValue(100);
        document.getElementById('popTope').textContent = '';
        actPop.conceptosPorUsuario = !!porUsuario;
        if (porUsuario) { actPop.conceptoPendiente = null; actPop.tasaPendiente = null; }
        if (cat === null || conv === null) { ActPopPrevia(); return; }
        PopConcepto.PerformCallback(Number(cat) + '|' + Number(conv));
    }

    function ActPopPorcentajeDe(item) {
        var t = item ? item.GetColumnText('Porcentaje') : null;
        if (t === null || t === undefined || t === '') return null;
        var n = parseFloat(String(t).replace(/,/g, '.').replace(/[^\d.\-]/g, ''));
        return isNaN(n) ? null : n;
    }

    function ActPopConceptosCargados() {
        var i, it, elegido = false;
        if (actPop.conceptoPendiente !== null) {
            PopConcepto.SetValue(actPop.conceptoPendiente);
            elegido = PopConcepto.GetSelectedIndex() >= 0;
        } else if (actPop.tasaPendiente !== null) {
            // Edición y duplicado: el concepto no se guarda; se propone el que coincide con la tasa fiscal.
            for (i = 0; i < PopConcepto.GetItemCount(); i++) {
                it = PopConcepto.GetItem(i);
                if (Math.abs((ActPopPorcentajeDe(it) || -1) - actPop.tasaPendiente) < 0.00005) { PopConcepto.SetSelectedIndex(i); elegido = true; break; }
            }
        } else if (actPop.conceptosPorUsuario && PopConcepto.GetItemCount() === 1) {
            PopConcepto.SetSelectedIndex(0);
            ActPopConceptoElegido(true);
            return;
        }
        actPop.conceptoPendiente = null; actPop.tasaPendiente = null;
        ActPopConceptoElegido(false);
        if (PopConcepto.GetItemCount() === 0 && PopTipo.GetValue() !== null)
            document.getElementById('popTope').textContent = 'Sin conceptos LISR para este tipo; la tasa fiscal se valida entre 0 y 100.';
    }

    function ActPopConceptoElegido(llenarTasas) {
        var pct = ActPopPorcentajeDe(PopConcepto.GetSelectedItem());
        actPop.tope = pct;
        // Ninguna tasa puede rebasar el máximo fiscal: los campos no aceptan más que el tope.
        var maximo = pct === null ? 100 : pct;
        PopTF.SetMaxValue(maximo);
        PopTC.SetMaxValue(maximo);
        document.getElementById('popTope').textContent = pct === null ? '' : 'Tasa máxima LISR: ' + ActPct(pct) + '%';
        if (llenarTasas && pct !== null) { PopTF.SetValue(pct); PopTC.SetValue(pct); }
        ActPopPrevia();
    }

    // ------------------------------------------------------------ Fechas y MOI
    function ActPopAdqCambio() {
        var adq = PopFAdq.GetDate(), uso = PopFUso.GetDate();
        // La fecha de uso sigue a la de adquisición mientras nadie la cambie a mano.
        if (!PopTransito.GetChecked() &&
            (uso === null || (actPop.adqAnterior && uso.getTime() === actPop.adqAnterior.getTime())))
            PopFUso.SetDate(adq);
        actPop.adqAnterior = adq;
        ActPopPrevia();
    }

    function ActPopTransito() {
        var t = PopTransito.GetChecked();
        PopFUso.SetEnabled(!t);
        if (t) PopFUso.SetDate(null);
        else if (!PopFUso.GetDate()) PopFUso.SetDate(PopFAdq.GetDate());
        ActPopPrevia();
    }

    function ActPopMoiIgual() {
        var igual = PopMoiIgual.GetChecked();
        PopMoiF.SetEnabled(!igual);
        if (igual) PopMoiF.SetValue(PopMoi.GetValue());
        ActPopAplicarTopeAuto();
        ActPopPrevia();
    }

    function ActPopMoiCambio() {
        if (PopMoiIgual.GetChecked()) PopMoiF.SetValue(PopMoi.GetValue());
        ActPopAplicarTopeAuto();
        ActPopPrevia();
    }

    // Tope fiscal de automóviles (decisión de Gabriel, 29/09/2026): si el MOI pasa de
    // $175,000.00 el usuario DEBE indicar el tipo de vehículo; normal topa el MOI fiscal
    // en $175,000.00 e híbrido (eléctrico y combustión) o eléctrico en $250,000.00.
    // Solo afecta el MOI fiscal capturado; no cambia el cálculo.
    var ACT_TOPE_AUTO_NORMAL = 175000, ACT_TOPE_AUTO_ELECTRICO = 250000;

    function ActPopVehiculo() {
        var r = document.querySelector('input[name="popVeh"]:checked');
        return r ? r.value : null;
    }

    function ActPopTopeVehiculo(veh) {
        return veh === 'normal' ? ACT_TOPE_AUTO_NORMAL : (veh === 'hibrido' || veh === 'electrico') ? ACT_TOPE_AUTO_ELECTRICO : null;
    }

    function ActPopRequiereVehiculo() {
        var moi = ActNum(PopMoi);
        return ActPopEsAutomovil() && moi !== null && moi > ACT_TOPE_AUTO_NORMAL;
    }

    function ActPopLimpiarVehiculo() {
        var rs = document.querySelectorAll('input[name="popVeh"]');
        for (var i = 0; i < rs.length; i++) rs[i].checked = false;
    }

    // Con tope (normal / híbrido / eléctrico): MOI fiscal = el menor entre el MOI y el tope, sin editar.
    // Sin tope ("mantener el valor capturado"): MOI fiscal editable, igual al contable si la casilla está marcada.
    function ActPopAplicarTopeAuto() {
        if (!ActPopRequiereVehiculo()) return;
        var veh = ActPopVehiculo(), tope = ActPopTopeVehiculo(veh), moi = ActNum(PopMoi);
        if (veh === 'sintope') {
            PopMoiF.SetEnabled(!PopMoiIgual.GetChecked());
            if (PopMoiIgual.GetChecked()) PopMoiF.SetValue(PopMoi.GetValue());
            return;
        }
        if (tope === null || moi === null) return;
        PopMoiIgual.SetChecked(moi <= tope);
        PopMoiF.SetEnabled(false);
        PopMoiF.SetValue(Math.min(moi, tope));
    }

    function ActPopVehiculoElegido() {
        document.getElementById('err_veh').textContent = '';
        // Al cambiar a "sin tope" se recupera el valor capturado (igual al contable).
        if (ActPopVehiculo() === 'sintope') { PopMoiIgual.SetChecked(true); PopMoiF.SetValue(PopMoi.GetValue()); }
        ActPopAplicarTopeAuto();
        ActPopPrevia();
    }

    function ActPopEsAutomovil() {
        var id = PopTipo.GetValue(), lista = window.ACT_CATALOGOS_TRANSPORTE || [];
        if (id === null) return false;
        for (var i = 0; i < lista.length; i++) if (Number(lista[i]) === Number(id)) return true;
        return false;
    }

    // ------------------------------------------------------------ Vista previa (estimación)
    function ActPopPrevia() {
        var tc = ActNum(PopTC), tf = ActNum(PopTF), moi = ActNum(PopMoi), moif = ActNum(PopMoiF);
        var transito = PopTransito.GetChecked(), uso = transito ? null : PopFUso.GetDate();

        document.getElementById('prevVida').textContent =
            tc === null ? '—' : tc === 0 ? 'No se deprecia' : ActPct(1200 / tc) + ' meses';
        document.getElementById('prevMensual').textContent =
            (tc === null || moi === null) ? '—' : ACT_MONEDA.format(moi * tc / 100 / 12);
        document.getElementById('prevAnual').textContent =
            (tf === null || moif === null) ? '—' : ACT_MONEDA.format(moif * tf / 100);

        // Igual que MesesEfectivosAnioActual: si el uso empieza el día 1 deprecia ese mes; si no, el siguiente.
        var primer = '—';
        if (transito) primer = 'Al registrar la fecha de uso';
        else if (uso && tc !== 0) {
            var d = new Date(uso.getFullYear(), uso.getMonth() + (uso.getDate() === 1 ? 0 : 1), 1);
            primer = ACT_MESES[d.getMonth()] + ' ' + d.getFullYear();
        } else if (tc === 0) primer = 'No se deprecia';
        document.getElementById('prevPrimer').textContent = primer;

        document.getElementById('popAvisoTasas').hidden = !(tf !== null && tc !== null && Math.abs(tf - tc) > 0.00005);
        var requiere = ActPopRequiereVehiculo();
        document.getElementById('popAvisoAuto').hidden = !requiere;
        if (!requiere) ActPopLimpiarVehiculo();
    }

    // ------------------------------------------------------------ Validación (mismas reglas que el servidor)
    function ActPopValidar() {
        var e = {};
        var cat = PopTipo.GetValue(), conv = PopConv.GetValue();
        var adq = PopFAdq.GetDate(), uso = PopFUso.GetDate(), transito = PopTransito.GetChecked();
        var moi = ActNum(PopMoi), moif = ActNum(PopMoiF), tf = ActNum(PopTF), tc = ActNum(PopTC);
        var desc = ActTexto(PopDesc);

        if (cat === null) e.cat = 'Elige el tipo de activo.';
        if (conv === null) e.conv = 'Elige el tipo de depreciación.';
        if (cat !== null && PopConcepto.GetItemCount() > 0 && PopConcepto.GetValue() === null) e.concepto = 'Elige el concepto LISR.';
        if (!desc) e.desc = 'La descripción es obligatoria.';
        else if (desc.length > 255) e.desc = 'Máximo 255 caracteres.';
        if (ActTexto(PopIdent).length > 255) e.ident = 'Máximo 255 caracteres.';

        if (!adq) e.fadq = 'La fecha de adquisición es obligatoria.';
        if (!transito) {
            if (!uso) e.fuso = 'La fecha de uso es obligatoria.';
            else if (adq && uso < adq) e.fuso = 'La fecha de uso no puede ser anterior a la de adquisición.';
        }

        if (actPop.modo !== 'editar' && (moi === null || moi <= 0)) e.moi = 'El MOI contable debe ser mayor a 0.';
        if (moif === null || moif < 0) e.moif = 'Captura el MOI fiscal (0 o más).';
        else if (moi !== null && moif > moi) e.moif = 'El MOI fiscal no puede ser mayor que el contable.';
        if (ActPopRequiereVehiculo()) {
            var veh = ActPopVehiculo(), topeVeh = ActPopTopeVehiculo(veh);
            if (!veh) e.veh = 'Elige una de las 4 opciones: normal, híbrido, eléctrico o mantener el valor capturado.';
            else if (topeVeh !== null && moif !== null && moif > topeVeh + 0.005)
                e.moif = 'Para este tipo de vehículo el MOI fiscal máximo es ' + ACT_MONEDA.format(topeVeh) + '.';
        }

        if (tf === null) e.tf = 'La tasa fiscal es obligatoria.';
        else if (tf < 0 || tf > 100) e.tf = 'Entre 0 y 100.';
        else if (actPop.tope !== null && tf > actPop.tope + 0.00005) e.tf = 'No puede ser mayor que la del concepto LISR (' + ActPct(actPop.tope) + '%).';
        if (tc === null) e.tc = 'La tasa contable es obligatoria.';
        else if (tc < 0 || tc > 100) e.tc = 'Entre 0 y 100.';
        else if (actPop.tope !== null && tc > actPop.tope + 0.00005) e.tc = 'No puede ser mayor que el máximo fiscal del concepto LISR (' + ActPct(actPop.tope) + '%).';
        return e;
    }

    function ActPopMostrarErrores(err) {
        for (var i = 0; i < ACT_POP_ERRORES.length; i++) {
            var el = document.getElementById('err_' + ACT_POP_ERRORES[i]);
            if (el) el.textContent = (err && err[ACT_POP_ERRORES[i]]) || '';
        }
        // Si el error está en el detalle, se abre la sección para que se vea.
        if (err && (err.serie || err.cond || err.color || err.clave)) ActAcordeon('Det', true);
    }

    function ActPopEnfocarError(err) {
        for (var i = 0; i < ACT_POP_ERRORES.length; i++) {
            var n = ACT_POP_EDITOR_DE[ACT_POP_ERRORES[i]];
            if (err[ACT_POP_ERRORES[i]] && n && window[n]) { window[n].Focus(); return; }
        }
    }

    function ActHayClaves(o) { for (var k in o) if (o.hasOwnProperty(k)) return true; return false; }

    // ------------------------------------------------------------ Guardar
    function ActPopGuardar(capturarOtro) {
        if (actPop.guardando) return;
        var err = ActPopValidar();
        ActPopMostrarErrores(err);
        if (ActHayClaves(err)) { ActPopEnfocarError(err); return; }

        var datos = {
            id: actPop.modo === 'editar' ? actPop.id : 0,
            cat: PopTipo.GetValue(), conv: PopConv.GetValue(), concepto: PopConcepto.GetValue(),
            desc: ActTexto(PopDesc), ident: ActTexto(PopIdent),
            fadq: ActIso(PopFAdq.GetDate()),
            fuso: PopTransito.GetChecked() ? null : ActIso(PopFUso.GetDate()),
            transito: PopTransito.GetChecked(),
            moi: ActNum(PopMoi), moif: ActNum(PopMoiF), tf: ActNum(PopTF), tc: ActNum(PopTC),
            veh: ActPopRequiereVehiculo() ? ActPopVehiculo() : null,
            det: { id: actPop.detId, serie: ActTexto(PopSerie), cond: ActTexto(PopCond), color: ActTexto(PopColor), clave: ActTexto(PopClave) }
        };
        actPop.guardarOtro = !!capturarOtro && actPop.modo !== 'editar';
        ActPopOcupado(true);
        CbActivo.PerformCallback('guardar|' + JSON.stringify(datos));
    }

    function ActPopRespuesta(texto) {
        var r;
        try { r = JSON.parse(texto); } catch (x) { r = { ok: false, mensaje: 'Respuesta no válida del servidor.' }; }
        ActPopOcupado(false);

        if (r.accion === 'cargar') {
            if (!r.ok) { PopActivo.Hide(); Swal.fire({ icon: 'error', title: 'No se pudo abrir el activo', text: r.mensaje, confirmButtonColor: '#1e3a5f' }); return; }
            ActPopLlenar(r.activo);
            return;
        }

        // accion === 'guardar'
        if (!r.ok) {
            ActPopMostrarErrores(r.errores || {});
            if (r.mensaje) document.getElementById('err_general').textContent = r.mensaje;
            if (r.errores) ActPopEnfocarError(r.errores);
            return;
        }

        if (window.VistaActivos) VistaActivos.Refresh();
        Swal.fire({ toast: true, position: 'top-end', icon: 'success', title: r.mensaje || 'Activo guardado',
                    showConfirmButton: false, timer: 2200, timerProgressBar: true });

        if (actPop.guardarOtro) {
            actPop.capturados++;
            ActPopContador();
            ActPopLimpiar(false);
            if (actPop.modo === 'duplicar') { actPop.modo = 'alta'; PopActivo.SetHeaderText('Nuevo activo'); }
            PopDesc.Focus();
        } else {
            if (actPop.modo !== 'editar') { actPop.capturados++; ActPopContador(); }
            PopActivo.Hide();
        }
    }

    function ActPopErrorCallback(mensaje) {
        ActPopOcupado(false);
        document.getElementById('err_general').textContent = 'Ocurrió un error: ' + mensaje;
    }

    // Llena el popup con el activo que regresa el servidor (editar / duplicar).
    function ActPopLlenar(a) {
        var editar = actPop.modo === 'editar';
        PopTipo.SetValue(a.cat);
        PopConv.SetValue(a.conv);
        actPop.tasaPendiente = a.tf;
        ActPopCargarConceptos(false);

        PopDesc.SetText(a.desc || '');
        PopIdent.SetText(editar ? (a.ident || '') : '');          // duplicar: sin identificador
        PopFAdq.SetDate(ActFechaDeIso(a.fadq)); actPop.adqAnterior = PopFAdq.GetDate();
        if (a.fuso) { PopTransito.SetChecked(false); PopFUso.SetEnabled(true); PopFUso.SetDate(ActFechaDeIso(a.fuso)); }
        else if (window.ACT_PERMITIR_TRANSITO) { PopTransito.SetChecked(true); PopFUso.SetEnabled(false); PopFUso.SetDate(null); }
        else PopFUso.SetDate(ActFechaDeIso(a.fadq));             // sin bandera: uso = adquisición

        PopMoi.SetValue(a.moi);
        var igual = a.moif !== null && a.moi !== null && Math.abs(a.moif - a.moi) < 0.005;
        PopMoiIgual.SetChecked(igual); PopMoiF.SetEnabled(!igual); PopMoiF.SetValue(a.moif);
        PopTF.SetValue(a.tf); PopTC.SetValue(a.tc);

        if (editar && a.det) {
            actPop.detId = a.det.id || 0;
            PopSerie.SetText(a.det.serie || ''); PopCond.SetText(a.det.cond || '');
            PopColor.SetText(a.det.color || ''); PopClave.SetText(a.det.clave || '');
            if (a.det.otros > 0)
                document.getElementById('popDetAyuda').textContent =
                    'Este activo tiene ' + (a.det.otros + 1) + ' detalles vigentes; aquí se edita el primero.';
            ActAcordeon('Det', true);
        }
        if (editar && a.calc) {
            var c = a.calc, av = document.getElementById('popAvisoCalc');
            av.innerHTML = '<b>Este activo ya tiene cálculos de depreciación</b> (' + ActEsc(c.primer) + ' a ' + ActEsc(c.ultimo) + '). ' +
                'Si cambias tipo, tasas, fechas o MOI fiscal, esos resultados dejan de coincidir y hay que recalcular desde enero de ' + ActEsc(String(c.desde)) + '.' +
                (c.cerrados > 0 ? ' <b>Hay ' + c.cerrados + (c.cerrados === 1 ? ' mes cerrado' : ' meses cerrados') + ' en ese rango: requieren reapertura.</b>' : '');
            av.hidden = false;
        }
        if (editar && a.fbaja) {
            var aviso = document.getElementById('popAvisoBaja');
            aviso.textContent = 'Este activo tiene baja registrada el ' + ActFechaTexto(ActFechaDeIso(a.fbaja)) + '.';
            aviso.hidden = false;
        }
        ActPopPrevia();
        ActPopMostrado();
    }

    // ------------------------------------------------------------ Teclado
    function ActPopKeyDown(s, e) {
        var ev = e.htmlEvent, k = ev.keyCode;
        if (k === 13 && (ev.ctrlKey || ev.metaKey)) { ASPxClientUtils.PreventEvent(ev); ActPopGuardar(false); return; }
        if (k === 13) { ASPxClientUtils.PreventEvent(ev); ActPopSiguiente(s); return; }
        if (k === 27) { ASPxClientUtils.PreventEvent(ev); PopActivo.Hide(); }
    }

    function ActPopSiguiente(s) {
        var i, idx = -1;
        for (i = 0; i < ACT_POP_ORDEN.length; i++) if (window[ACT_POP_ORDEN[i]] === s) { idx = i; break; }
        var detOculto = document.getElementById('panDet').hidden;
        for (i = idx + 1; i < ACT_POP_ORDEN.length; i++) {
            var n = ACT_POP_ORDEN[i], ed = window[n];
            if (!ed) continue;
            if (detOculto && (n === 'PopSerie' || n === 'PopCond' || n === 'PopColor' || n === 'PopClave')) continue;
            if (ed.GetEnabled && !ed.GetEnabled()) continue;
            ed.Focus();
            return;
        }
        document.getElementById('btnGuardar').focus();
    }

    // Ctrl+Enter y Esc también funcionan con el foco en botones o enlaces del popup.
    document.addEventListener('keydown', function (ev) {
        if (!window.PopActivo || !PopActivo.IsVisible() || document.querySelector('.swal2-container')) return;
        if (ev.key === 'Enter' && (ev.ctrlKey || ev.metaKey)) { ev.preventDefault(); ActPopGuardar(false); }
        else if (ev.key === 'Escape') { ev.preventDefault(); PopActivo.Hide(); }
    });

    // "N" abre el alta desde el listado cuando no se está escribiendo.
    document.addEventListener('keydown', function (ev) {
        if ((ev.key !== 'n' && ev.key !== 'N') || ev.ctrlKey || ev.altKey || ev.metaKey) return;
        var a = document.activeElement, tag = a ? a.tagName : '';
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || (a && a.isContentEditable)) return;
        if (document.querySelector('.swal2-container')) return;
        if (ActHayPopupAbierto()) return;
        ev.preventDefault();
        ActNuevo();
    });

    ActAlIniciar(function () {
        for (var i = 0; i < ACT_POP_ORDEN.length; i++) {
            var ed = window[ACT_POP_ORDEN[i]];
            if (ed && ed.KeyDown) ed.KeyDown.AddHandler(ActPopKeyDown);
        }
    });

    // =====================================================================
    // Etapa 5: baja en ventana emergente
    // Un solo popup (PopBaja) con dos vistas: "registrar" para un activo sin baja y
    // "ver" para uno con baja (detalle y Revertir). La vista la decide el servidor
    // según el estado real de la baja, no el botón que se pulsó.
    // CbBaja responde JSON { accion: cargar | registrar | revertir, ok, mensaje, ... }.
    // =====================================================================
    var actBaja = { id: 0, idBaja: 0, saldo: null, min: null, puede: false, ocupado: false, motivoPrevio: null };
    var ACT_BAJA_ERRORES = ['motivo', 'fecha', 'precio', 'factura', 'texto', 'general'];
    var ACT_BAJA_EDITORES = ['PopBFecha', 'PopBPrecio', 'PopBFactura', 'PopBTexto'];

    function ActDarDeBaja(id, saldo) { ActBajaAbrir(id, saldo); }
    function ActVerBaja(id, saldo)   { ActBajaAbrir(id, saldo); }

    function ActBajaAbrir(id, saldo) {
        try {
            // Si una carga anterior nunca respondió, no debe bloquear las siguientes aperturas.
            if (actBaja.ocupado && !PopBaja.IsVisible()) actBaja.ocupado = false;
            if (actBaja.ocupado) return;
            actBaja.id = Number(id); actBaja.idBaja = 0; actBaja.puede = false;
            actBaja.saldo = (saldo === undefined) ? null : saldo;
            ActBajaVista('');
            document.getElementById('bjResumen').innerHTML = '<div class="bj-cargando">Cargando el folio ' + actBaja.id + '…</div>';
            PopBaja.SetHeaderText('Folio ' + actBaja.id);
            ActBajaOcupado(true);
            PopBaja.Show();
            CbBaja.PerformCallback('cargar|' + actBaja.id);
        } catch (x) {
            actBaja.ocupado = false;
            Swal.fire({ icon: 'error', title: 'No se pudo abrir la baja', text: x && x.message ? x.message : String(x), confirmButtonColor: '#1e3a5f' });
        }
    }

    function ActBajaVista(v) {
        document.getElementById('bjRegistrar').hidden = v !== 'registrar';
        document.getElementById('bjVer').hidden = v !== 'ver';
    }

    function ActBajaOcupado(si) {
        actBaja.ocupado = si;
        document.getElementById('btnBajaRegistrar').disabled = si;
        document.getElementById('btnBajaRevertir').disabled = si || !actBaja.puede;
    }

    function ActBajaCerrado() { actBaja.ocupado = false; }

    function ActBajaCampos(lista) {
        var h = '';
        for (var i = 0; i < lista.length; i++)
            h += '<div class="bj-campo' + (lista[i].d ? ' bj-dest' : '') + '"><span class="k">' + ActEsc(lista[i].k) +
                 '</span><span class="v">' + ActEsc(lista[i].v) + '</span></div>';
        return h;
    }

    function ActBajaResumen(a) {
        var saldo = actBaja.saldo === null ? 'Sin calcular' : ACT_MONEDA.format(actBaja.saldo);
        var campos = [
            { k: 'Folio', v: String(a.id) },
            { k: 'Tipo de activo', v: a.grupo || '—' },
            { k: 'Depreciación', v: a.tipoDep },
            { k: 'Adquisición', v: a.fadq },
            { k: 'MOI contable', v: ACT_MONEDA.format(a.moi) },
            { k: 'MOI fiscal', v: ACT_MONEDA.format(a.moif) },
            { k: 'Uso', v: a.fuso || '—' },
            { k: a.fbaja ? 'Saldo contable congelado' : 'Saldo contable actual', v: saldo }
        ];
        document.getElementById('bjResumen').innerHTML =
            '<div class="bj-desc">' + ActEsc(a.desc || '') + (a.ident ? ' <span class="ac-sub">· ' + ActEsc(a.ident) + '</span>' : '') + '</div>' +
            '<div class="bj-campos">' + ActBajaCampos(campos) + '</div>';
    }

    function ActBajaLlenar(r) {
        var a = r.activo;
        ActBajaResumen(a);

        if (r.situacion === 'libre') {
            PopBaja.SetHeaderText('Dar de baja el folio ' + a.id);
            ActBajaLimpiarRegistro(r.min);
            ActBajaVista('registrar');
            ActBajaOcupado(false);
            setTimeout(function () { var m = document.querySelector('input[name="bjMotivo"]'); if (m) m.focus(); }, 50);
            return;
        }

        PopBaja.SetHeaderText('Baja del folio ' + a.id);
        var inc = document.getElementById('bjIncompleta'), det = document.getElementById('bjDetalle');
        var btn = document.getElementById('btnBajaRevertir'), nota = document.getElementById('bjRevertirNota');
        if (r.situacion === 'incompleta') {
            // Decisión de Gabriel (29/09/2026): se avisa, sin detalle y sin revertir.
            inc.innerHTML = '<b>Baja incompleta.</b> ' + ActEsc(r.motivo || '');
            inc.hidden = false;
            det.innerHTML = '';
            actBaja.puede = false;
            btn.hidden = true;
            nota.textContent = '';
        } else {
            inc.hidden = true;
            var h = '';
            for (var i = 0; i < r.secciones.length; i++)
                h += '<div class="pop-seccion"><h3>' + ActEsc(r.secciones[i].t) + '</h3><div class="bj-campos">' +
                     ActBajaCampos(r.secciones[i].c) + '</div></div>';
            det.innerHTML = h;
            actBaja.idBaja = r.revertir.idBaja;
            actBaja.puede = !!r.revertir.puede;
            btn.hidden = false;
            nota.textContent = r.revertir.puede ? '' : r.revertir.razon;
        }
        ActBajaVista('ver');
        ActBajaOcupado(false);
        setTimeout(function () { (actBaja.puede ? btn : document.getElementById('btnBajaCerrar')).focus(); }, 50);
    }

    // ------------------------------------------------------------ Registrar
    function ActBajaLimpiarRegistro(minIso) {
        var rs = document.querySelectorAll('input[name="bjMotivo"]');
        for (var i = 0; i < rs.length; i++) rs[i].checked = false;
        actBaja.motivoPrevio = null;
        var hoy = new Date(); hoy.setHours(0, 0, 0, 0);
        actBaja.min = ActFechaDeIso(minIso);
        PopBFecha.SetMinDate(actBaja.min);
        PopBFecha.SetMaxDate(hoy);
        PopBFecha.SetDate(null);
        PopBPrecio.SetValue(null);
        PopBFactura.SetText('');
        PopBTexto.SetText('');
        document.getElementById('bjFechaAyuda').textContent =
            actBaja.min ? 'Del ' + ActFechaTexto(actBaja.min) + ' (uso o adquisición) a hoy.' : '';
        ActBajaErrores({});
        ActBajaMostrarVenta();
    }

    function ActBajaMotivoElegido() {
        var r = document.querySelector('input[name="bjMotivo"]:checked');
        return r ? r.value : null;
    }

    function ActBajaMostrarVenta() {
        var venta = ActBajaMotivoElegido() === 'venta';
        var cs = document.querySelectorAll('.bj-venta');
        for (var i = 0; i < cs.length; i++) cs[i].hidden = !venta;
    }

    // Venta: precio obligatorio y factura opcional. Inutilidad: precio 0 y sin factura (campos ocultos).
    function ActBajaMotivo() {
        var m = ActBajaMotivoElegido();
        if (m === 'inutilidad') { PopBPrecio.SetValue(0); PopBFactura.SetText(''); }
        else if (m === 'venta' && actBaja.motivoPrevio === 'inutilidad') PopBPrecio.SetValue(null);
        actBaja.motivoPrevio = m;
        document.getElementById('err_bj_motivo').textContent = '';
        ActBajaMostrarVenta();
    }

    function ActBajaErrores(err) {
        for (var i = 0; i < ACT_BAJA_ERRORES.length; i++) {
            var el = document.getElementById('err_bj_' + ACT_BAJA_ERRORES[i]);
            if (el) el.textContent = (err && err[ACT_BAJA_ERRORES[i]]) || '';
        }
    }

    // Mismas reglas que RegistrarBaja() en el servidor.
    function ActBajaValidar() {
        var e = {}, m = ActBajaMotivoElegido(), f = PopBFecha.GetDate();
        var hoy = new Date(); hoy.setHours(0, 0, 0, 0);
        if (!m) e.motivo = 'Elige el motivo: venta o inutilidad.';
        if (!f) e.fecha = 'La fecha de baja es obligatoria.';
        else if (actBaja.min && f < actBaja.min) e.fecha = 'No puede ser anterior a la fecha de uso o de adquisición (' + ActFechaTexto(actBaja.min) + ').';
        else if (f > hoy) e.fecha = 'No puede ser posterior a hoy.';
        if (m === 'venta') {
            var p = ActNum(PopBPrecio);
            if (p === null || p < 0) e.precio = 'Captura el precio de venta (0 o más).';
            else if (p > 99999999.99) e.precio = 'Máximo $99,999,999.99.';
            if (ActTexto(PopBFactura).length > 40) e.factura = 'Máximo 40 caracteres.';
        }
        if (ActTexto(PopBTexto).length > 240) e.texto = 'Máximo 240 caracteres.';
        return e;
    }

    function ActBajaRegistrar() {
        if (actBaja.ocupado) return;
        var err = ActBajaValidar();
        ActBajaErrores(err);
        if (ActHayClaves(err)) {
            if (err.fecha) PopBFecha.Focus(); else if (err.precio) PopBPrecio.Focus(); else if (err.factura) PopBFactura.Focus(); else if (err.texto) PopBTexto.Focus();
            return;
        }

        var m = ActBajaMotivoElegido(), f = PopBFecha.GetDate();
        var p = m === 'venta' ? ActNum(PopBPrecio) : 0;
        var cero = m === 'venta' && p === 0;
        var html = (cero ? '<b>El precio de venta es $0.00.</b> Si no hubo venta, usa el motivo Inutilidad.<br><br>' : '') +
                   'Folio <b>' + actBaja.id + '</b> · ' + (m === 'venta' ? 'Venta por ' + ACT_MONEDA.format(p) : 'Inutilidad') +
                   ' · ' + ActFechaTexto(f) + '<br><br>La depreciación se congela en el mes anterior a la baja. ' +
                   'Una baja solo se puede revertir dentro del año en curso y con los meses abiertos.';
        Swal.fire({
            icon: cero ? 'warning' : 'question', title: '¿Registrar la baja?', html: html,
            showCancelButton: true, confirmButtonText: 'Registrar baja', cancelButtonText: 'Volver',
            confirmButtonColor: '#b91c1c', focusCancel: true
        }).then(function (res) {
            if (!res.isConfirmed) return;
            var datos = {
                id: actBaja.id, motivo: m, fecha: ActIso(f), precio: p,
                factura: m === 'venta' ? ActTexto(PopBFactura) : '', texto: ActTexto(PopBTexto)
            };
            ActBajaOcupado(true);
            CbBaja.PerformCallback('registrar|' + JSON.stringify(datos));
        });
    }

    // ------------------------------------------------------------ Revertir
    function ActBajaRevertir() {
        if (actBaja.ocupado || !actBaja.puede) return;
        Swal.fire({
            icon: 'warning', title: '¿Revertir la baja del folio ' + actBaja.id + '?',
            html: 'Se eliminan el registro de baja y su cálculo congelado, y el activo vuelve a quedar vigente.<br><br>' +
                  '<b>Los cálculos de depreciación desde el mes de la baja dejan de coincidir</b> y hay que recalcularlos después de revertir.',
            showCancelButton: true, confirmButtonText: 'Revertir baja', cancelButtonText: 'Cancelar',
            confirmButtonColor: '#b91c1c', focusCancel: true
        }).then(function (res) {
            if (!res.isConfirmed) return;
            ActBajaOcupado(true);
            CbBaja.PerformCallback('revertir|' + JSON.stringify({ id: actBaja.id, idBaja: actBaja.idBaja }));
        });
    }

    // ------------------------------------------------------------ Respuesta del servidor
    function ActBajaRespuesta(texto) {
        var r;
        try { r = JSON.parse(texto); } catch (x) { r = { ok: false, mensaje: 'Respuesta no válida del servidor.' }; }
        actBaja.ocupado = false;

        if (r.accion === 'cargar') {
            if (!r.ok) {
                PopBaja.Hide();
                Swal.fire({ icon: 'error', title: 'No se pudo abrir la baja', text: r.mensaje, confirmButtonColor: '#1e3a5f' });
                return;
            }
            ActBajaLlenar(r);
            return;
        }

        ActBajaOcupado(false);
        if (!r.ok) {
            if (r.accion === 'registrar' && !document.getElementById('bjRegistrar').hidden) {
                ActBajaErrores(r.errores || {});
                if (r.mensaje) document.getElementById('err_bj_general').textContent = r.mensaje;
            } else {
                Swal.fire({ icon: 'error', title: r.accion === 'revertir' ? 'No se revirtió la baja' : 'No se registró la baja',
                            text: r.mensaje, confirmButtonColor: '#1e3a5f' });
            }
            return;
        }

        PopBaja.Hide();
        if (window.VistaActivos) VistaActivos.Refresh();   // conserva los filtros (HfFiltros)
        Swal.fire({ icon: 'success', title: r.accion === 'revertir' ? 'Baja revertida' : 'Baja registrada',
                    text: r.mensaje, confirmButtonColor: '#1e3a5f' });
    }

    function ActBajaErrorCallback(mensaje) {
        actBaja.ocupado = false;
        ActBajaOcupado(false);
        if (!document.getElementById('bjRegistrar').hidden)
            document.getElementById('err_bj_general').textContent = 'Ocurrió un error: ' + mensaje;
        else
            Swal.fire({ icon: 'error', title: 'Ocurrió un error', text: mensaje, confirmButtonColor: '#1e3a5f' });
    }

    // Enter no envía el formulario; Ctrl+Enter registra.
    function ActBajaKeyDown(s, e) {
        var ev = e.htmlEvent, k = ev.keyCode;
        if (k !== 13) return;
        ASPxClientUtils.PreventEvent(ev);
        if (ev.ctrlKey || ev.metaKey) ActBajaRegistrar();
    }

    // Esc cierra y Ctrl+Enter registra también con el foco fuera de los editores
    // (no mientras hay un aviso de SweetAlert2 abierto).
    document.addEventListener('keydown', function (ev) {
        if (!window.PopBaja || !PopBaja.IsVisible() || document.querySelector('.swal2-container')) return;
        if (ev.key === 'Escape') { ev.preventDefault(); PopBaja.Hide(); }
        else if (ev.key === 'Enter' && (ev.ctrlKey || ev.metaKey) && !document.getElementById('bjRegistrar').hidden) {
            ev.preventDefault(); ActBajaRegistrar();
        }
    });

    ActAlIniciar(function () {
        for (var i = 0; i < ACT_BAJA_EDITORES.length; i++) {
            var ed = window[ACT_BAJA_EDITORES[i]];
            if (ed && ed.KeyDown) ed.KeyDown.AddHandler(ActBajaKeyDown);
        }
    });

</script>

<div id="actWrap" class="dep">

    <%-- ================================================================ --%>
    <%-- CINTA SUPERIOR                                                   --%>
    <%-- ================================================================ --%>
    <div class="dep-ribbon">
        <div class="rb-title">
            <h1>Activos fijos</h1>
            <span><asp:Literal ID="LitEmpresa" runat="server" /></span>
        </div>

        <div class="rb-group">
            <span class="rb-label">Captura</span>
            <div class="rb-row">
                <dx:ASPxButton ID="BNuevo" runat="server" Text="Nuevo activo" AutoPostBack="False" UseSubmitBehavior="False"
                    Theme="Office365" CssClass="rb-primary">
                    <ClientSideEvents Click="function(s, e) { ActNuevo(); }" />
                </dx:ASPxButton>
            </div>
        </div>

        <div class="rb-spacer"></div>

        <div class="rb-group">
            <span class="rb-label">Excel</span>
            <div class="rb-row">
                <button type="button" class="rb-btn" onclick="ActExportar(); return false;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12"/><path d="m7 10 5 5 5-5"/><path d="M5 21h14"/></svg>
                    Exportar a Excel
                </button>
            </div>
        </div>
    </div>

    <%-- Estado de los filtros; viaja con cada callback, la exportación y la paginación --%>
    <dx:ASPxHiddenField ID="HfFiltros" ClientInstanceName="HfFiltros" runat="server" />

    <%-- ================================================================ --%>
    <%-- BARRA DE DISTRIBUCIÓN POR ESTADO (se pinta con cpResumen)        --%>
    <%-- ================================================================ --%>
    <div class="st-bar-wrap" aria-label="Distribución del MOI por estado">
        <div class="st-bar" id="actBar"></div>
        <div class="st-leyenda" id="actLeyenda" role="group" aria-label="Filtrar por estado"></div>
    </div>

    <button type="button" class="lnk act-toggle" id="actToggle" aria-expanded="false" aria-controls="actPanel"
        onclick="ActTogglePanel(); return false;">Filtros</button>

    <div class="act-layout">

        <%-- ============================================================ --%>
        <%-- PANEL LATERAL DE FILTROS                                     --%>
        <%-- ============================================================ --%>
        <aside class="act-panel" id="actPanel" aria-label="Filtros">
            <div class="act-panel-head">
                <h2>Filtros</h2>
                <button type="button" class="lnk" onclick="ActLimpiarTodo(); return false;">Limpiar todo</button>
            </div>

            <div class="f-grupo">
                <span class="f-titulo" id="lblSaldo">Saldo contable</span>
                <div class="seg-claro" role="group" aria-labelledby="lblSaldo" data-filtro="s">
                    <button type="button" data-v=""        aria-pressed="true"  onclick="ActSeg(this);">Todos</button>
                    <button type="button" data-v="cero"    aria-pressed="false" onclick="ActSeg(this);">Igual a 0</button>
                    <button type="button" data-v="pos"     aria-pressed="false" onclick="ActSeg(this);">Mayor a 0</button>
                    <button type="button" data-v="sincalc" aria-pressed="false" onclick="ActSeg(this);">Sin calcular</button>
                </div>
            </div>

            <div class="f-grupo">
                <span class="f-titulo" id="lblBajas">Bajas</span>
                <div class="seg-claro" role="group" aria-labelledby="lblBajas" data-filtro="b">
                    <button type="button" data-v=""     aria-pressed="true"  onclick="ActSeg(this);">Todas</button>
                    <button type="button" data-v="solo" aria-pressed="false" onclick="ActSeg(this);">Solo bajas</button>
                    <button type="button" data-v="sin"  aria-pressed="false" onclick="ActSeg(this);">Sin bajas</button>
                </div>
            </div>

            <div class="f-grupo">
                <span class="f-titulo">Tipo de depreciación</span>
                <dx:ASPxCheckBoxList ID="CblConv" ClientInstanceName="CblConv" runat="server" Theme="Office365"
                    RepeatColumns="1" Width="100%" ValueType="System.Int32" Border-BorderWidth="0" Paddings-Padding="0">
                    <ClientSideEvents SelectedIndexChanged="function(s, e) { ActAplicar(); }" />
                </dx:ASPxCheckBoxList>
            </div>

            <%-- Acordeón: el catálogo de tipos es largo; se muestra al expandirlo --%>
            <div class="f-grupo">
                <button type="button" class="f-acordeon" id="btnTipo" aria-expanded="false" aria-controls="panTipo"
                    onclick="ActAcordeon('Tipo'); return false;">
                    <span class="f-titulo">Tipo de activo</span>
                    <span class="f-sel" id="selTipo"></span>
                    <svg class="f-flecha" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"/></svg>
                </button>
                <div class="f-acordeon-cuerpo" id="panTipo" hidden>
                    <dx:ASPxCheckBoxList ID="CblTipo" ClientInstanceName="CblTipo" runat="server" Theme="Office365"
                        RepeatColumns="1" Width="100%" ValueType="System.Int32" Border-BorderWidth="0" Paddings-Padding="0">
                        <ClientSideEvents SelectedIndexChanged="function(s, e) { ActAplicar(); }" />
                    </dx:ASPxCheckBoxList>
                    <button type="button" class="lnk f-ninguno" onclick="CblTipo.UnselectAll(); ActAplicar(); return false;">Quitar selección</button>
                </div>
            </div>

            <div class="f-grupo">
                <span class="f-titulo">Fecha de adquisición</span>
                <div class="f-rango">
                    <div><label>Desde</label>
                        <dx:ASPxDateEdit ID="DeAdqDesde" ClientInstanceName="DeAdqDesde" runat="server" Theme="Office365" Width="100%"
                            DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                            <CalendarProperties FirstDayOfWeek="Monday" />
                            <ClientSideEvents DateChanged="function(s, e) { ActAplicar(); }" />
                        </dx:ASPxDateEdit></div>
                    <div><label>Hasta</label>
                        <dx:ASPxDateEdit ID="DeAdqHasta" ClientInstanceName="DeAdqHasta" runat="server" Theme="Office365" Width="100%"
                            DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                            <CalendarProperties FirstDayOfWeek="Monday" />
                            <ClientSideEvents DateChanged="function(s, e) { ActAplicar(); }" />
                        </dx:ASPxDateEdit></div>
                </div>
                <div class="f-atajos" aria-label="Atajos de fecha de adquisición">
                    <button type="button" onclick="ActAtajo('adq', 'actual'); return false;" id="btnAdqActual">Año actual</button>
                    <button type="button" onclick="ActAtajo('adq', 'anterior'); return false;" id="btnAdqAnterior">Año anterior</button>
                    <button type="button" onclick="ActAtajo('adq', 'anteriores'); return false;">Anteriores</button>
                </div>
            </div>

            <div class="f-grupo">
                <span class="f-titulo">Fecha de uso</span>
                <div class="f-rango">
                    <div><label>Desde</label>
                        <dx:ASPxDateEdit ID="DeUsoDesde" ClientInstanceName="DeUsoDesde" runat="server" Theme="Office365" Width="100%"
                            DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                            <CalendarProperties FirstDayOfWeek="Monday" />
                            <ClientSideEvents DateChanged="function(s, e) { ActAplicar(); }" />
                        </dx:ASPxDateEdit></div>
                    <div><label>Hasta</label>
                        <dx:ASPxDateEdit ID="DeUsoHasta" ClientInstanceName="DeUsoHasta" runat="server" Theme="Office365" Width="100%"
                            DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                            <CalendarProperties FirstDayOfWeek="Monday" />
                            <ClientSideEvents DateChanged="function(s, e) { ActAplicar(); }" />
                        </dx:ASPxDateEdit></div>
                </div>
                <div class="f-atajos" aria-label="Atajos de fecha de uso">
                    <button type="button" onclick="ActAtajo('uso', 'actual'); return false;">Año actual</button>
                    <button type="button" onclick="ActAtajo('uso', 'anterior'); return false;">Año anterior</button>
                    <button type="button" onclick="ActAtajo('uso', 'anteriores'); return false;">Anteriores</button>
                </div>
            </div>

            <div class="f-grupo">
                <span class="f-titulo">MOI</span>
                <div class="f-rango">
                    <div><label>Mínimo</label>
                        <dx:ASPxSpinEdit ID="SeMoiMin" ClientInstanceName="SeMoiMin" runat="server" Theme="Office365" Width="100%"
                            NumberType="Float" MinValue="0" MaxValue="999999999999" DecimalPlaces="2" AllowNull="True"
                            DisplayFormatString="N2" SpinButtons-ShowIncrementButtons="False">
                            <ClientSideEvents ValueChanged="function(s, e) { ActAplicar(); }" />
                        </dx:ASPxSpinEdit></div>
                    <div><label>Máximo</label>
                        <dx:ASPxSpinEdit ID="SeMoiMax" ClientInstanceName="SeMoiMax" runat="server" Theme="Office365" Width="100%"
                            NumberType="Float" MinValue="0" MaxValue="999999999999" DecimalPlaces="2" AllowNull="True"
                            DisplayFormatString="N2" SpinButtons-ShowIncrementButtons="False">
                            <ClientSideEvents ValueChanged="function(s, e) { ActAplicar(); }" />
                        </dx:ASPxSpinEdit></div>
                </div>
            </div>
        </aside>

        <%-- ============================================================ --%>
        <%-- LISTADO                                                      --%>
        <%-- ============================================================ --%>
        <div>
            <div class="act-buscar">
                <dx:ASPxTextBox ID="TxtBuscar" ClientInstanceName="TxtBuscar" runat="server" Theme="Office365" Width="100%" Height="40px"
                    MaxLength="200" NullText="Busca por descripción, número de serie, tipo, folio o monto">
                    <ClientSideEvents KeyDown="function(s, e) { ActBuscarKeyDown(s, e); }" KeyUp="function(s, e) { ActBuscarKeyUp(s, e); }" />
                </dx:ASPxTextBox>
                <div class="act-buscar-ayuda">Todas las palabras deben aparecer; no distingue acentos ni mayúsculas. <kbd>/</kbd> para buscar, <kbd>Esc</kbd> para limpiar.</div>
            </div>

            <div class="act-chips" id="actChips" aria-live="polite"></div>


    <div class="dep-section">
        <div class="dep-section-head">
            <h2>Activos</h2>
            <span class="tag" id="actTotal"><asp:Literal ID="LitTotal" runat="server" /></span>
            <span class="hint" id="actCorte"><asp:Literal ID="LitCorte" runat="server" /></span>
        </div>
        <div class="dep-section-body" id="actGrid">

        <dx:ASPxGridView ID="GvActivos" ClientInstanceName="VistaActivos" runat="server" Theme="Office365"
            AutoGenerateColumns="False" KeyFieldName="Id" Width="100%" CssClass="dep-grid"
            EnableRowsCache="False" EnableViewState="False"
            OnDataBinding="GvActivos_DataBinding" OnBeforeExport="GvActivos_BeforeExport"
            OnCustomCallback="GvActivos_CustomCallback">

            <SettingsPager PageSize="25">
                <PageSizeItemSettings Visible="True" Items="12, 25, 50, 100" Caption="Filas por página:" ShowAllItem="False" />
            </SettingsPager>
            <Settings ShowFooter="True" />
            <SettingsBehavior AllowSort="True" AllowFocusedRow="False" AllowSelectByRowClick="False" />
            <SettingsExport EnableClientSideExportAPI="True" />
            <ClientSideEvents Init="function(s, e) { ActInit(s, e); }" RowClick="function(s, e) { ActRowClick(s, e); }" EndCallback="function(s, e) { ActEndCallback(s, e); }" CallbackError="function(s, e) { ActCallbackError(s, e); }" />

            <%-- Detalle (ActivosDetalle): mismo comportamiento y código que la pantalla anterior --%>
            <Templates>
                <EmptyDataRow>
                    <div class="act-vacio">
                        <div class="v-filtros">
                            <b>Ningún activo coincide</b>
                            Prueba con otras palabras o quita algunos filtros.<br /><br />
                            <button type="button" class="lnk" onclick="ActLimpiarTodo(); return false;">Quitar filtros</button>
                        </div>
                        <div class="v-sin"><b>No hay activos registrados para esta empresa.</b></div>
                    </div>
                </EmptyDataRow>
            </Templates>

            <Columns>
                <%-- ---------------- Columnas de pantalla (Name vis_*: se ocultan al exportar) ---------------- --%>
                <dx:GridViewDataTextColumn Name="vis_Activo" FieldName="Descripcion" Caption="Activo" VisibleIndex="0" Width="24%">
                    <DataItemTemplate><%# CeldaActivo(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn Name="vis_Tipo" FieldName="TipoActivo" Caption="Tipo de activo" VisibleIndex="1" Width="15%">
                    <DataItemTemplate><%# CeldaTipo(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn Name="vis_Tasa" FieldName="TasaFiscalPct" Caption="Tasa F / C" VisibleIndex="2">
                    <HeaderStyle HorizontalAlign="Right" />
                    <CellStyle HorizontalAlign="Right" Wrap="False" />
                    <DataItemTemplate><%# CeldaTasa(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn Name="vis_Moi" FieldName="Moi" Caption="MOI" VisibleIndex="3">
                    <HeaderStyle HorizontalAlign="Right" />
                    <CellStyle HorizontalAlign="Right" />
                    <FooterCellStyle HorizontalAlign="Right" />
                    <DataItemTemplate><%# CeldaMoi(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataDateColumn Name="ambos_Adquisicion" FieldName="FechaAdquisicion" Caption="Adquisición" VisibleIndex="4">
                    <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy" />
                    <CellStyle Wrap="False" />
                </dx:GridViewDataDateColumn>

                <dx:GridViewDataDateColumn Name="vis_Uso" FieldName="FechaUsoEfectiva" Caption="Uso" VisibleIndex="5">
                    <CellStyle Wrap="False" />
                    <DataItemTemplate><%# CeldaUso(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataDateColumn>

                <dx:GridViewDataDateColumn Name="ambos_Baja" FieldName="FechaBaja" Caption="Baja" VisibleIndex="6">
                    <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy" />
                    <CellStyle Wrap="False" />
                </dx:GridViewDataDateColumn>

                <dx:GridViewDataTextColumn Name="vis_Saldo" FieldName="SaldoContable" Caption="Saldo contable" VisibleIndex="7" Width="130px">
                    <HeaderStyle HorizontalAlign="Right" />
                    <CellStyle HorizontalAlign="Right" />
                    <FooterCellStyle HorizontalAlign="Right" />
                    <DataItemTemplate><%# CeldaSaldo(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn Name="vis_Estado" FieldName="EstadoOrden" Caption="Estado" VisibleIndex="8">
                    <DataItemTemplate><%# CeldaEstado(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <dx:GridViewDataTextColumn Name="vis_Acciones" FieldName="Id" Caption="Acciones" VisibleIndex="9" Width="108px">
                    <Settings AllowSort="False" />
                    <DataItemTemplate><%# CeldaAcciones(Container.DataItem) %></DataItemTemplate>
                </dx:GridViewDataTextColumn>

                <%-- ---------------- Columnas planas para Excel (Name exp_*: solo visibles al exportar) ---------------- --%>
                <dx:GridViewDataTextColumn Name="exp_Folio"         FieldName="Id"               Caption="Folio"                Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_Descripcion"   FieldName="Descripcion"      Caption="Descripción"          Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_Identificador" FieldName="Identificador"    Caption="Identificador"        Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_Tipo"          FieldName="TipoActivo"       Caption="Tipo de activo"       Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_TipoDep"       FieldName="TipoDepreciacion" Caption="Tipo de depreciación" Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_TasaFiscal"    FieldName="TasaFiscalPct"    Caption="Tasa fiscal %"        Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_TasaContable"  FieldName="TasaContablePct"  Caption="Tasa contable %"      Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_Moi"           FieldName="Moi"              Caption="MOI"                  Visible="False" ShowInCustomizationForm="False">
                    <PropertiesTextEdit DisplayFormatString="c2" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn Name="exp_MoiFiscal"     FieldName="MoiFiscal"        Caption="MOI fiscal"           Visible="False" ShowInCustomizationForm="False">
                    <PropertiesTextEdit DisplayFormatString="c2" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataDateColumn Name="exp_FechaUso"      FieldName="FechaUso"         Caption="Fecha de uso"         Visible="False" ShowInCustomizationForm="False">
                    <PropertiesDateEdit DisplayFormatString="dd/MM/yyyy" />
                </dx:GridViewDataDateColumn>
                <dx:GridViewDataTextColumn Name="exp_Saldo"         FieldName="SaldoContable"    Caption="Saldo contable"       Visible="False" ShowInCustomizationForm="False">
                    <PropertiesTextEdit DisplayFormatString="c2" />
                </dx:GridViewDataTextColumn>
                <dx:GridViewDataTextColumn Name="exp_Estado"        FieldName="EstadoTexto"      Caption="Estado"               Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_MotivoBaja"    FieldName="MotivoBajaTexto"  Caption="Motivo de baja"       Visible="False" ShowInCustomizationForm="False" />
                <dx:GridViewDataTextColumn Name="exp_PrecioVenta"   FieldName="PrecioVenta"      Caption="Precio de venta"      Visible="False" ShowInCustomizationForm="False">
                    <PropertiesTextEdit DisplayFormatString="c2" />
                </dx:GridViewDataTextColumn>
            </Columns>

            <TotalSummary>
                <dx:ASPxSummaryItem FieldName="Id"            SummaryType="Count" ShowInColumn="vis_Activo" DisplayFormat="{0} activos" />
                <dx:ASPxSummaryItem FieldName="Moi"           SummaryType="Sum"   ShowInColumn="vis_Moi"    DisplayFormat="{0:c2}" />
                <dx:ASPxSummaryItem FieldName="SaldoContable" SummaryType="Sum"   ShowInColumn="vis_Saldo"  DisplayFormat="{0:c2}" />
                <dx:ASPxSummaryItem FieldName="Moi"           SummaryType="Sum"   ShowInColumn="exp_Moi"    DisplayFormat="{0:c2}" />
                <dx:ASPxSummaryItem FieldName="SaldoContable" SummaryType="Sum"   ShowInColumn="exp_Saldo"  DisplayFormat="{0:c2}" />
            </TotalSummary>
        </dx:ASPxGridView>

        </div>
    </div>
        </div>
    </div>
</div>




<%-- ==================================================================== --%>
<%-- POPUP DE CAPTURA Y EDICIÓN (Etapa 4)                                 --%>
<%-- ==================================================================== --%>
<dx:ASPxPopupControl ID="PopActivo" ClientInstanceName="PopActivo" runat="server"
    Theme="Office365" Modal="True" Width="920px" CssClass="dep pop"
    CloseAction="CloseButton" CloseOnEscape="False" PopupHorizontalAlign="WindowCenter"
    PopupVerticalAlign="WindowCenter" AllowDragging="True" ShowFooter="False"
    HeaderText="Nuevo activo" EnableViewState="False">
    <SettingsAdaptivity Mode="OnWindowInnerWidth" SwitchAtWindowInnerWidth="960" />
    <ClientSideEvents Shown="function(s, e) { ActPopMostrado(); }" CloseUp="function(s, e) { ActPopCerrado(); }" />
    <ContentCollection>
        <dx:PopupControlContentControl runat="server">

            <div class="pop-aviso-baja" id="popAvisoBaja" hidden></div>
            <div class="pop-aviso" id="popAvisoCalc" role="note" hidden style="margin:0 0 12px 0;"></div>

            <%-- ---------------- Clasificación ---------------- --%>
            <div class="pop-seccion">
                <h3>Clasificación</h3>
                <div class="pop-grid">
                    <div class="c2">
                        <label class="pop-lbl">Tipo de activo <span class="req">*</span></label>
                        <dx:ASPxComboBox ID="PopTipo" ClientInstanceName="PopTipo" runat="server" Theme="Office365" Width="100%"
                            ValueType="System.Int32" DropDownStyle="DropDownList" IncrementalFilteringMode="Contains">
                            <ClientSideEvents SelectedIndexChanged="function(s, e) { ActPopCargarConceptos(true); }" />
                        </dx:ASPxComboBox>
                        <div class="f-err" id="err_cat"></div>
                    </div>
                    <div class="c1">
                        <label class="pop-lbl">Depreciación <span class="req">*</span></label>
                        <dx:ASPxComboBox ID="PopConv" ClientInstanceName="PopConv" runat="server" Theme="Office365" Width="100%"
                            ValueType="System.Int32" DropDownStyle="DropDownList" SelectedIndex="0">
                            <Items>
                                <dx:ListEditItem Text="Convencional" Value="1" />
                                <dx:ListEditItem Text="Acelerada" Value="0" />
                            </Items>
                            <ClientSideEvents SelectedIndexChanged="function(s, e) { ActPopCargarConceptos(true); }" />
                        </dx:ASPxComboBox>
                        <div class="f-err" id="err_conv"></div>
                    </div>
                    <div class="c3">
                        <label class="pop-lbl">Concepto LISR <span class="req">*</span></label>
                        <dx:ASPxComboBox ID="PopConcepto" ClientInstanceName="PopConcepto" runat="server" Theme="Office365" Width="100%"
                            ValueType="System.Int32" ValueField="IdPorcentaje" TextField="Descripcion" TextFormatString="{0}"
                            DropDownStyle="DropDownList" OnCallback="PopConcepto_Callback" NullText="Elige primero el tipo de activo">
                            <Columns>
                                <dx:ListBoxColumn FieldName="Descripcion" Caption="Concepto" Width="85%" />
                                <dx:ListBoxColumn FieldName="Porcentaje" Caption="%" Width="15%" />
                            </Columns>
                            <ClientSideEvents SelectedIndexChanged="function(s, e) { ActPopConceptoElegido(true); }"
                                              EndCallback="function(s, e) { ActPopConceptosCargados(); }" />
                        </dx:ASPxComboBox>
                        <div class="pop-tope" id="popTope"></div>
                        <div class="f-err" id="err_concepto"></div>
                    </div>
                </div>
            </div>

            <%-- ---------------- Identificación ---------------- --%>
            <div class="pop-seccion">
                <h3>Identificación</h3>
                <div class="pop-grid">
                    <div class="c4">
                        <label class="pop-lbl">Descripción <span class="req">*</span></label>
                        <dx:ASPxTextBox ID="PopDesc" ClientInstanceName="PopDesc" runat="server" Theme="Office365" Width="100%" MaxLength="255" />
                        <div class="f-err" id="err_desc"></div>
                    </div>
                    <div class="c2">
                        <label class="pop-lbl">Identificador</label>
                        <dx:ASPxTextBox ID="PopIdent" ClientInstanceName="PopIdent" runat="server" Theme="Office365" Width="100%" MaxLength="255"
                            NullText="Placa, número de motor..." />
                        <div class="f-err" id="err_ident"></div>
                    </div>
                </div>
            </div>

            <%-- ---------------- Fechas e importes ---------------- --%>
            <div class="pop-seccion">
                <h3>Fechas e importes</h3>
                <div class="pop-grid">
                    <div class="c2">
                        <label class="pop-lbl">Fecha de adquisición <span class="req">*</span></label>
                        <dx:ASPxDateEdit ID="PopFAdq" ClientInstanceName="PopFAdq" runat="server" Theme="Office365" Width="100%"
                            DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                            <CalendarProperties FirstDayOfWeek="Monday" />
                            <ClientSideEvents DateChanged="function(s, e) { ActPopAdqCambio(); }" />
                        </dx:ASPxDateEdit>
                        <div class="f-err" id="err_fadq"></div>
                    </div>
                    <div class="c2">
                        <label class="pop-lbl">Fecha de uso <span class="req">*</span></label>
                        <dx:ASPxDateEdit ID="PopFUso" ClientInstanceName="PopFUso" runat="server" Theme="Office365" Width="100%"
                            DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                            <CalendarProperties FirstDayOfWeek="Monday" />
                            <ClientSideEvents DateChanged="function(s, e) { ActPopPrevia(); }" />
                        </dx:ASPxDateEdit>
                        <dx:ASPxCheckBox ID="PopTransito" ClientInstanceName="PopTransito" runat="server" Theme="Office365"
                            Text="Aún no se usa (en tránsito)" CssClass="pop-chk" ClientVisible="False">
                            <ClientSideEvents CheckedChanged="function(s, e) { ActPopTransito(); }" />
                        </dx:ASPxCheckBox>
                        <div class="f-err" id="err_fuso"></div>
                    </div>
                    <div class="c2"></div>

                    <div class="c2">
                        <label class="pop-lbl">MOI contable <span class="req">*</span></label>
                        <dx:ASPxSpinEdit ID="PopMoi" ClientInstanceName="PopMoi" runat="server" Theme="Office365" Width="100%"
                            NumberType="Float" DecimalPlaces="2" MinValue="0" MaxValue="999999999999.99" AllowNull="True"
                            DisplayFormatString="N2" SpinButtons-ShowIncrementButtons="False">
                            <ClientSideEvents ValueChanged="function(s, e) { ActPopMoiCambio(); }" />
                        </dx:ASPxSpinEdit>
                        <div class="pop-ayuda" id="popMoiAyuda"></div>
                        <div class="f-err" id="err_moi"></div>
                    </div>
                    <div class="c2">
                        <label class="pop-lbl">MOI fiscal <span class="req">*</span></label>
                        <dx:ASPxSpinEdit ID="PopMoiF" ClientInstanceName="PopMoiF" runat="server" Theme="Office365" Width="100%"
                            NumberType="Float" DecimalPlaces="2" MinValue="0" MaxValue="999999999999.99" AllowNull="True"
                            DisplayFormatString="N2" SpinButtons-ShowIncrementButtons="False" ClientEnabled="False">
                            <ClientSideEvents ValueChanged="function(s, e) { ActPopPrevia(); }" />
                        </dx:ASPxSpinEdit>
                        <dx:ASPxCheckBox ID="PopMoiIgual" ClientInstanceName="PopMoiIgual" runat="server" Theme="Office365"
                            Text="Igual al MOI contable" CssClass="pop-chk" Checked="True">
                            <ClientSideEvents CheckedChanged="function(s, e) { ActPopMoiIgual(); }" />
                        </dx:ASPxCheckBox>
                        <div class="f-err" id="err_moif"></div>
                    </div>
                    <div class="c1">
                        <label class="pop-lbl">Tasa fiscal % <span class="req">*</span></label>
                        <dx:ASPxSpinEdit ID="PopTF" ClientInstanceName="PopTF" runat="server" Theme="Office365" Width="100%"
                            NumberType="Float" DecimalPlaces="4" MinValue="0" MaxValue="100" AllowNull="True"
                            DisplayFormatString="0.####" SpinButtons-ShowIncrementButtons="False">
                            <ClientSideEvents ValueChanged="function(s, e) { ActPopPrevia(); }" />
                        </dx:ASPxSpinEdit>
                        <div class="f-err" id="err_tf"></div>
                    </div>
                    <div class="c1">
                        <label class="pop-lbl">Tasa contable % <span class="req">*</span></label>
                        <dx:ASPxSpinEdit ID="PopTC" ClientInstanceName="PopTC" runat="server" Theme="Office365" Width="100%"
                            NumberType="Float" DecimalPlaces="4" MinValue="0" MaxValue="100" AllowNull="True"
                            DisplayFormatString="0.####" SpinButtons-ShowIncrementButtons="False">
                            <ClientSideEvents ValueChanged="function(s, e) { ActPopPrevia(); }" />
                        </dx:ASPxSpinEdit>
                        <div class="f-err" id="err_tc"></div>
                    </div>
                    <div class="c6">
                        <div class="pop-aviso" id="popAvisoAuto" role="group" aria-labelledby="lblVeh" hidden>
                            <span id="lblVeh"><b>Equipo de transporte con MOI mayor a $175,000.00.</b> Para efectos fiscales el MOI tiene tope; indica el tipo de vehículo <span class="req">*</span></span>
                            <div class="pop-veh">
                                <label><input type="radio" name="popVeh" value="normal" onclick="ActPopVehiculoElegido();" /> Normal (combustión): tope <b>$175,000.00</b></label>
                                <label><input type="radio" name="popVeh" value="hibrido" onclick="ActPopVehiculoElegido();" /> Híbrido (propulsión eléctrica y de combustión): tope <b>$250,000.00</b></label>
                                <label><input type="radio" name="popVeh" value="electrico" onclick="ActPopVehiculoElegido();" /> Solo eléctrico: tope <b>$250,000.00</b></label>
                                <label><input type="radio" name="popVeh" value="sintope" onclick="ActPopVehiculoElegido();" /> Mantener el valor capturado, <b>sin tope</b> (p. ej. camión, tractocamión o remolque)</label>
                            </div>
                            <div class="f-err" id="err_veh"></div>
                        </div>
                        <div class="pop-aviso" id="popAvisoTasas" hidden>La tasa contable es distinta de la fiscal. Se puede guardar así; revisa que sea intencional.</div>
                    </div>
                </div>
            </div>

            <%-- ---------------- Vista previa (solo cliente) ---------------- --%>
            <div class="pop-seccion">
                <h3>Vista previa</h3>
                <p class="pop-prev-tit">Estimación con los datos capturados; el cálculo oficial es el de CalcularDepreciaciones.</p>
                <div class="pop-prev" aria-live="polite">
                    <div><span class="k">Vida útil contable</span><span class="v" id="prevVida">—</span></div>
                    <div><span class="k">Depreciación mensual contable</span><span class="v" id="prevMensual">—</span></div>
                    <div><span class="k">Depreciación anual fiscal</span><span class="v" id="prevAnual">—</span></div>
                    <div><span class="k">Primer mes de depreciación</span><span class="v" id="prevPrimer">—</span></div>
                </div>
            </div>

            <%-- ---------------- Datos del vehículo / detalle (plegable) ---------------- --%>
            <div class="pop-seccion">
                <button type="button" class="f-acordeon" id="btnDet" aria-expanded="false" aria-controls="panDet"
                    onclick="ActAcordeon('Det'); return false;">
                    <span class="f-titulo">Datos del vehículo / detalle</span>
                    <span class="f-sel" id="selDet"></span>
                    <svg class="f-flecha" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"/></svg>
                </button>
                <div class="f-acordeon-cuerpo" id="panDet" hidden style="max-height:none;overflow:visible;">
                    <div class="pop-grid">
                        <div class="c2">
                            <label class="pop-lbl">Número de serie</label>
                            <dx:ASPxTextBox ID="PopSerie" ClientInstanceName="PopSerie" runat="server" Theme="Office365" Width="100%" MaxLength="30" />
                            <div class="f-err" id="err_serie"></div>
                        </div>
                        <div class="c1">
                            <label class="pop-lbl">Condición</label>
                            <dx:ASPxTextBox ID="PopCond" ClientInstanceName="PopCond" runat="server" Theme="Office365" Width="100%" MaxLength="15" />
                            <div class="f-err" id="err_cond"></div>
                        </div>
                        <div class="c1">
                            <label class="pop-lbl">Color</label>
                            <dx:ASPxTextBox ID="PopColor" ClientInstanceName="PopColor" runat="server" Theme="Office365" Width="100%" MaxLength="15" />
                            <div class="f-err" id="err_color"></div>
                        </div>
                        <div class="c2">
                            <label class="pop-lbl">Clave vehicular</label>
                            <dx:ASPxTextBox ID="PopClave" ClientInstanceName="PopClave" runat="server" Theme="Office365" Width="100%" MaxLength="50" />
                            <div class="f-err" id="err_clave"></div>
                        </div>
                        <div class="c6 pop-ayuda" id="popDetAyuda">Déjalo vacío si el activo no lleva estos datos. Al vaciar todos los campos de un detalle existente, se marca como borrado.</div>
                    </div>
                </div>
            </div>

            <div class="f-err" id="err_general" role="alert"></div>

            <div class="pop-pie">
                <span class="pop-contador" id="popContador"></span>
                <button type="button" class="btn" onclick="PopActivo.Hide(); return false;">Cancelar</button>
                <button type="button" class="btn btn-sec" id="btnGuardarOtro" onclick="ActPopGuardar(true); return false;">Guardar y capturar otro</button>
                <button type="button" class="btn btn-primario" id="btnGuardar" onclick="ActPopGuardar(false); return false;">Guardar activo</button>
                <span class="pop-atajos"><kbd>Enter</kbd> siguiente campo · <kbd>Ctrl</kbd>+<kbd>Enter</kbd> guardar · <kbd>Esc</kbd> cerrar</span>
            </div>

        </dx:PopupControlContentControl>
    </ContentCollection>
</dx:ASPxPopupControl>

<%-- Carga y guardado del activo sin postback completo --%>
<dx:ASPxCallback ID="CbActivo" ClientInstanceName="CbActivo" runat="server" OnCallback="CbActivo_Callback">
    <ClientSideEvents CallbackComplete="function(s, e) { ActPopRespuesta(e.result); }"
                      CallbackError="function(s, e) { e.handled = true; ActPopErrorCallback(e.message); }" />
</dx:ASPxCallback>

<%-- ==================================================================== --%>
<%-- POPUP DE BAJA (Etapa 5): registrar, ver detalle y revertir           --%>
<%-- ==================================================================== --%>
<dx:ASPxPopupControl ID="PopBaja" ClientInstanceName="PopBaja" runat="server"
    Theme="Office365" Modal="True" Width="780px" CssClass="dep pop"
    CloseAction="CloseButton" CloseOnEscape="False" PopupHorizontalAlign="WindowCenter"
    PopupVerticalAlign="WindowCenter" AllowDragging="True" ShowFooter="False"
    HeaderText="Baja" EnableViewState="False">
    <SettingsAdaptivity Mode="OnWindowInnerWidth" SwitchAtWindowInnerWidth="820" />
    <ClientSideEvents CloseUp="function(s, e) { ActBajaCerrado(); }" />
    <ContentCollection>
        <dx:PopupControlContentControl runat="server">

            <%-- Resumen del activo (lo pinta ActBajaResumen) --%>
            <div class="bj-resumen" id="bjResumen" aria-live="polite"></div>

            <%-- ---------------- Vista "registrar" ---------------- --%>
            <div id="bjRegistrar" hidden>
                <div class="pop-seccion">
                    <h3>Registrar baja</h3>
                    <div class="pop-grid">
                        <div class="c6">
                            <span class="pop-lbl" id="lblBjMotivo">Motivo <span class="req">*</span></span>
                            <div class="pop-veh" role="radiogroup" aria-labelledby="lblBjMotivo">
                                <label><input type="radio" name="bjMotivo" value="venta" onclick="ActBajaMotivo();" /> <b>Venta</b>: se registran el precio y, si la hay, la factura</label>
                                <label><input type="radio" name="bjMotivo" value="inutilidad" onclick="ActBajaMotivo();" /> <b>Inutilidad</b>: el activo deja de usarse sin venta (precio $0.00)</label>
                            </div>
                            <div class="f-err" id="err_bj_motivo"></div>
                        </div>
                        <div class="c2">
                            <label class="pop-lbl">Fecha de baja <span class="req">*</span></label>
                            <dx:ASPxDateEdit ID="PopBFecha" ClientInstanceName="PopBFecha" runat="server" Theme="Office365" Width="100%"
                                DisplayFormatString="dd/MM/yyyy" EditFormatString="dd/MM/yyyy" UseMaskBehavior="True" AllowNull="True">
                                <CalendarProperties FirstDayOfWeek="Monday" />
                            </dx:ASPxDateEdit>
                            <div class="pop-ayuda" id="bjFechaAyuda"></div>
                            <div class="f-err" id="err_bj_fecha"></div>
                        </div>
                        <div class="c2 bj-venta" hidden>
                            <label class="pop-lbl">Precio de venta <span class="req">*</span></label>
                            <dx:ASPxSpinEdit ID="PopBPrecio" ClientInstanceName="PopBPrecio" runat="server" Theme="Office365" Width="100%"
                                NumberType="Float" DecimalPlaces="2" MinValue="0" MaxValue="99999999.99" AllowNull="True"
                                DisplayFormatString="N2" SpinButtons-ShowIncrementButtons="False" />
                            <div class="f-err" id="err_bj_precio"></div>
                        </div>
                        <div class="c2 bj-venta" hidden>
                            <label class="pop-lbl">Número de factura</label>
                            <dx:ASPxTextBox ID="PopBFactura" ClientInstanceName="PopBFactura" runat="server" Theme="Office365" Width="100%" MaxLength="40"
                                NullText="Opcional" />
                            <div class="f-err" id="err_bj_factura"></div>
                        </div>
                        <div class="c6">
                            <label class="pop-lbl">Descripción del motivo</label>
                            <dx:ASPxTextBox ID="PopBTexto" ClientInstanceName="PopBTexto" runat="server" Theme="Office365" Width="100%" MaxLength="240"
                                NullText="Ej. vendido a un tercero, siniestro, robo, obsolescencia" />
                            <div class="pop-ayuda">Se guarda con el prefijo VENTA: o INUTILIDAD: según el motivo.</div>
                            <div class="f-err" id="err_bj_texto"></div>
                        </div>
                    </div>
                    <div class="pop-aviso" role="note">La depreciación se congela en el mes anterior a la baja.</div>
                </div>

                <div class="f-err" id="err_bj_general" role="alert"></div>

                <div class="pop-pie">
                    <span class="pop-contador"></span>
                    <button type="button" class="btn" onclick="PopBaja.Hide(); return false;">Cancelar</button>
                    <button type="button" class="btn btn-peligro" id="btnBajaRegistrar" onclick="ActBajaRegistrar(); return false;">Registrar baja</button>
                    <span class="pop-atajos"><kbd>Ctrl</kbd>+<kbd>Enter</kbd> registrar · <kbd>Esc</kbd> cerrar</span>
                </div>
            </div>

            <%-- ---------------- Vista "ver" (detalle y reversión) ---------------- --%>
            <div id="bjVer" hidden>
                <div class="pop-aviso-baja" id="bjIncompleta" role="alert" hidden></div>
                <div id="bjDetalle"></div>

                <div class="pop-pie">
                    <span class="bj-nota" id="bjRevertirNota" aria-live="polite"></span>
                    <button type="button" class="btn" id="btnBajaCerrar" onclick="PopBaja.Hide(); return false;">Cerrar</button>
                    <button type="button" class="btn btn-peligro" id="btnBajaRevertir" onclick="ActBajaRevertir(); return false;">Revertir baja</button>
                    <span class="pop-atajos"><kbd>Esc</kbd> cerrar</span>
                </div>
            </div>

        </dx:PopupControlContentControl>
    </ContentCollection>
</dx:ASPxPopupControl>

<%-- Carga, registro y reversión de la baja sin postback completo --%>
<dx:ASPxCallback ID="CbBaja" ClientInstanceName="CbBaja" runat="server" OnCallback="CbBaja_Callback">
    <ClientSideEvents CallbackComplete="function(s, e) { ActBajaRespuesta(e.result); }"
                      CallbackError="function(s, e) { e.handled = true; ActBajaErrorCallback(e.message); }" />
</dx:ASPxCallback>

</asp:Content>
