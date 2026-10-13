/*
 Navicat Premium Dump SQL

 Source Server         : NOMINA
 Source Server Type    : SQL Server
 Source Server Version : 15004430 (15.00.4430)
 Source Host           : GGP\PRUEBASRT:1433
 Source Catalog        : Deprecia
 Source Schema         : aud

 Target Server Type    : SQL Server
 Target Server Version : 15004430 (15.00.4430)
 File Encoding         : 65001

 Date: 12/10/2026 23:33:53
*/


-- ----------------------------
-- Table structure for Activos_Historia
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[Activos_Historia]') AND type IN ('U'))
	DROP TABLE [aud].[Activos_Historia]
GO

CREATE TABLE [aud].[Activos_Historia] (
  [Id] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [Identificador] varchar(255) COLLATE Modern_Spanish_CI_AS  NULL,
  [IdCatalogo] int  NOT NULL,
  [FechaAdquisicion] date  NOT NULL,
  [Descripcion] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [PorcentajeDepFIscalAnual] float(53)  NULL,
  [PorcentajeDepContableAnual] float(53)  NULL,
  [Moi] decimal(18,2)  NOT NULL,
  [MoiFiscal] decimal(18,2)  NOT NULL,
  [Baja] decimal(10,2)  NULL,
  [FechaBaja] date  NULL,
  [Convencional] tinyint  NOT NULL,
  [FechaProcesado] datetime  NOT NULL,
  [IdTemporal] int  NULL,
  [ValidoDesde] datetime2(3)  NOT NULL,
  [ValidoHasta] datetime2(3)  NOT NULL,
  [FechaUso] date  NULL
)
GO

ALTER TABLE [aud].[Activos_Historia] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CatalogoMotivo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[CatalogoMotivo]') AND type IN ('U'))
	DROP TABLE [aud].[CatalogoMotivo]
GO

CREATE TABLE [aud].[CatalogoMotivo] (
  [Clave] varchar(30) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Descripcion] nvarchar(200) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Naturaleza] varchar(20) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [SugiereCascada] bit  NOT NULL,
  [Activo] bit DEFAULT 1 NOT NULL
)
GO

ALTER TABLE [aud].[CatalogoMotivo] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for Configuracion
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[Configuracion]') AND type IN ('U'))
	DROP TABLE [aud].[Configuracion]
GO

CREATE TABLE [aud].[Configuracion] (
  [Clave] varchar(40) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Valor] varchar(200) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Descripcion] nvarchar(400) COLLATE Modern_Spanish_CI_AS  NULL,
  [FechaCambio] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [UsuarioSQL] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL
)
GO

ALTER TABLE [aud].[Configuracion] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CorridaCalculo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[CorridaCalculo]') AND type IN ('U'))
	DROP TABLE [aud].[CorridaCalculo]
GO

CREATE TABLE [aud].[CorridaCalculo] (
  [IdCorrida] bigint  IDENTITY(1,1) NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [Periodo] int  NOT NULL,
  [Mes] tinyint  NOT NULL,
  [FechaInicio] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [FechaFin] datetime2(3)  NULL,
  [DuracionSegundos] AS (datediff(second,[FechaInicio],[FechaFin])) PERSISTED,
  [Estado] varchar(20) COLLATE Modern_Spanish_CI_AS DEFAULT 'EN_PROCESO' NOT NULL,
  [Mensaje] nvarchar(2000) COLLATE Modern_Spanish_CI_AS  NULL,
  [UsuarioSQL] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL,
  [UsuarioApp] nvarchar(128) COLLATE Modern_Spanish_CI_AS  NULL,
  [HostName] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT host_name() NULL,
  [AppName] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT app_name() NULL,
  [EstadoPeriodoPrevio] varchar(30) COLLATE Modern_Spanish_CI_AS  NULL,
  [IdSolicitud] int  NULL,
  [EsRecalculo] bit DEFAULT 0 NOT NULL,
  [FilasDetalle] int  NULL,
  [FilasMensual] int  NULL,
  [ActivosProcesados] int  NULL,
  [IdCorridaPrevia] bigint  NULL,
  [ActivosConCambio] int  NULL
)
GO

ALTER TABLE [aud].[CorridaCalculo] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CriterioCalculo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[CriterioCalculo]') AND type IN ('U'))
	DROP TABLE [aud].[CriterioCalculo]
GO

CREATE TABLE [aud].[CriterioCalculo] (
  [IdCriterio] int  NOT NULL,
  [Clave] varchar(30) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Nombre] nvarchar(150) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Descripcion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Fundamento] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NULL,
  [VigenteDesde] date  NULL,
  [VigenteHasta] date  NULL,
  [EsPredeterminado] bit DEFAULT 0 NOT NULL
)
GO

ALTER TABLE [aud].[CriterioCalculo] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for EmpresaAlcance
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[EmpresaAlcance]') AND type IN ('U'))
	DROP TABLE [aud].[EmpresaAlcance]
GO

CREATE TABLE [aud].[EmpresaAlcance] (
  [IdEmpresa] int  NOT NULL,
  [PrimerPeriodo] int  NOT NULL,
  [PrimerMes] tinyint  NOT NULL,
  [FechaAlta] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [UsuarioAlta] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL
)
GO

ALTER TABLE [aud].[EmpresaAlcance] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for FirmaActivo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[FirmaActivo]') AND type IN ('U'))
	DROP TABLE [aud].[FirmaActivo]
GO

CREATE TABLE [aud].[FirmaActivo] (
  [IdCorrida] bigint  NOT NULL,
  [IdActivo] int  NOT NULL,
  [Hash] binary(32)  NOT NULL,
  [Moi] decimal(18,2)  NULL,
  [MoiFiscal] decimal(18,2)  NULL,
  [PctContable] decimal(14,6)  NULL,
  [PctFiscal] decimal(14,6)  NULL,
  [IdCatalogo] int  NULL,
  [Convencional] tinyint  NULL,
  [FechaAdquisicion] date  NULL,
  [FechaBaja] date  NULL,
  [FechaUso] date  NULL
)
GO

ALTER TABLE [aud].[FirmaActivo] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for LogFechaUso
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[LogFechaUso]') AND type IN ('U'))
	DROP TABLE [aud].[LogFechaUso]
GO

CREATE TABLE [aud].[LogFechaUso] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NULL,
  [FechaAdquisicion] date  NULL,
  [FechaUso_Anterior] date  NULL,
  [FechaUso_Nueva] date  NULL,
  [Accion] varchar(20) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Motivo] nvarchar(500) COLLATE Modern_Spanish_CI_AS  NULL,
  [Lote] varchar(40) COLLATE Modern_Spanish_CI_AS  NULL,
  [Moi] decimal(18,2)  NULL,
  [PctContable] decimal(14,6)  NULL,
  [ImpactoUnMes] decimal(18,2)  NULL,
  [FechaOperacion] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [UsuarioSQL] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL,
  [UsuarioApp] nvarchar(128) COLLATE Modern_Spanish_CI_AS  NULL,
  [AppName] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT app_name() NULL
)
GO

ALTER TABLE [aud].[LogFechaUso] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for LogInpc
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[LogInpc]') AND type IN ('U'))
	DROP TABLE [aud].[LogInpc]
GO

CREATE TABLE [aud].[LogInpc] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [Anio] int  NOT NULL,
  [Mes] tinyint  NOT NULL,
  [Inpc_Anterior] decimal(18,4)  NULL,
  [Inpc_Nuevo] decimal(18,4)  NOT NULL,
  [EsProvisional_Anterior] bit  NULL,
  [EsProvisional_Nuevo] bit  NOT NULL,
  [Accion] varchar(20) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Fuente] nvarchar(100) COLLATE Modern_Spanish_CI_AS  NULL,
  [Motivo] nvarchar(500) COLLATE Modern_Spanish_CI_AS  NULL,
  [CierresAfectados] int  NULL,
  [FechaOperacion] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [UsuarioSQL] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL,
  [AppName] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT app_name() NULL
)
GO

ALTER TABLE [aud].[LogInpc] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for PeriodoEstado
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[PeriodoEstado]') AND type IN ('U'))
	DROP TABLE [aud].[PeriodoEstado]
GO

CREATE TABLE [aud].[PeriodoEstado] (
  [IdEmpresa] int  NOT NULL,
  [Periodo] int  NOT NULL,
  [Mes] tinyint  NOT NULL,
  [Estado] varchar(30) COLLATE Modern_Spanish_CI_AS DEFAULT 'ABIERTO' NOT NULL,
  [FechaCierre] datetime2(3)  NULL,
  [UsuarioCierre] nvarchar(128) COLLATE Modern_Spanish_CI_AS  NULL,
  [IdSolicitudVigente] int  NULL,
  [FechaUltimoCalculo] datetime2(3)  NULL,
  [IdCorridaUltima] bigint  NULL,
  [Recalculos] int DEFAULT 0 NOT NULL,
  [FechaAlta] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [InsumosProvisionales] bit DEFAULT 0 NOT NULL,
  [DetalleProvisional] nvarchar(500) COLLATE Modern_Spanish_CI_AS  NULL
)
GO

ALTER TABLE [aud].[PeriodoEstado] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for RolUsuario
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[RolUsuario]') AND type IN ('U'))
	DROP TABLE [aud].[RolUsuario]
GO

CREATE TABLE [aud].[RolUsuario] (
  [Usuario] nvarchar(128) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Rol] varchar(20) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [IdEmpresa] int DEFAULT 0 NOT NULL,
  [Activo] bit DEFAULT 1 NOT NULL,
  [FechaAlta] datetime2(3) DEFAULT sysdatetime() NOT NULL
)
GO

ALTER TABLE [aud].[RolUsuario] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for SnapshotCalculoDetalle
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[SnapshotCalculoDetalle]') AND type IN ('U'))
	DROP TABLE [aud].[SnapshotCalculoDetalle]
GO

CREATE TABLE [aud].[SnapshotCalculoDetalle] (
  [IdCorrida] bigint  NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
  [IdMes] tinyint  NULL,
  [Meses_Transcurridos] int  NULL,
  [Porcentaje_Dep_Fiscal_Anual] decimal(14,6)  NULL,
  [Porcentaje_Dep_Contable_Anual] decimal(14,6)  NULL,
  [Moi] decimal(18,2)  NOT NULL,
  [MoiFiscal] decimal(18,2)  NOT NULL,
  [Baja] decimal(18,2)  NULL,
  [FechaBaja] date  NULL,
  [Meses_Efectivos_Contables] int  NULL,
  [DeduccionContableInvHistorico] decimal(18,2)  NULL,
  [SaldoContablePorDeducir] decimal(18,2)  NULL,
  [DepreciacionContableInversionAnual] decimal(18,2)  NULL,
  [DepreciacionContableAcumulado] decimal(18,2)  NULL,
  [Meses_Efectivos_Fiscales] int  NULL,
  [DeduccionFiscalInvHistorico] decimal(18,2)  NULL,
  [SaldoFiscalPorDeducir] decimal(18,2)  NULL,
  [DepreciacionFiscalInversionAnual] decimal(18,2)  NULL,
  [DepreciacionFiscalAcumulado] decimal(18,2)  NULL,
  [InpcMitadPeriodo] decimal(18,4)  NOT NULL,
  [InpcFechaAdquisicion] decimal(18,4)  NOT NULL,
  [Factor_Ajuste] decimal(18,2)  NOT NULL,
  [Deduccion_Fiscal_Inv_Actualizado] decimal(18,2)  NOT NULL,
  [Convencional] tinyint  NOT NULL
)
GO

ALTER TABLE [aud].[SnapshotCalculoDetalle] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for SnapshotCalculoMensual
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[SnapshotCalculoMensual]') AND type IN ('U'))
	DROP TABLE [aud].[SnapshotCalculoMensual]
GO

CREATE TABLE [aud].[SnapshotCalculoMensual] (
  [IdCorrida] bigint  NOT NULL,
  [IdActivo] int  NOT NULL,
  [TipoContabilidad] tinyint  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
  [IdMes] tinyint  NULL,
  [Enero] decimal(18,2)  NULL,
  [Febrero] decimal(18,2)  NULL,
  [Marzo] decimal(18,2)  NULL,
  [Abril] decimal(18,2)  NULL,
  [Mayo] decimal(18,2)  NULL,
  [Junio] decimal(18,2)  NULL,
  [Julio] decimal(18,2)  NULL,
  [Agosto] decimal(18,2)  NULL,
  [Septiembre] decimal(18,2)  NULL,
  [Octubre] decimal(18,2)  NULL,
  [Noviembre] decimal(18,2)  NULL,
  [Diciembre] decimal(18,2)  NULL
)
GO

ALTER TABLE [aud].[SnapshotCalculoMensual] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for SolicitudReapertura
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[SolicitudReapertura]') AND type IN ('U'))
	DROP TABLE [aud].[SolicitudReapertura]
GO

CREATE TABLE [aud].[SolicitudReapertura] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [Periodo] int  NOT NULL,
  [Mes] tinyint  NOT NULL,
  [ClaveMotivo] varchar(30) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Motivo] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [ActivosAfectados] nvarchar(2000) COLLATE Modern_Spanish_CI_AS  NULL,
  [Solicitante] nvarchar(128) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [FechaSolicitud] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [Estado] varchar(20) COLLATE Modern_Spanish_CI_AS DEFAULT 'PENDIENTE' NOT NULL,
  [Autorizador] nvarchar(128) COLLATE Modern_Spanish_CI_AS  NULL,
  [FechaResolucion] datetime2(3)  NULL,
  [ComentarioResolucion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NULL,
  [VigenteHasta] datetime2(3)  NULL,
  [IdCorridaConsumo] bigint  NULL,
  [FechaConsumo] datetime2(3)  NULL,
  [RequirioAutorizacion] bit DEFAULT 1 NOT NULL
)
GO

ALTER TABLE [aud].[SolicitudReapertura] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for TipoDiferencia
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[TipoDiferencia]') AND type IN ('U'))
	DROP TABLE [aud].[TipoDiferencia]
GO

CREATE TABLE [aud].[TipoDiferencia] (
  [Clave] varchar(30) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Nombre] nvarchar(150) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Descripcion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Naturaleza] varchar(20) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [SeAutoCompensa] bit  NOT NULL,
  [Excepciones] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NULL,
  [Estado] varchar(20) COLLATE Modern_Spanish_CI_AS DEFAULT 'EN_CONSULTA' NOT NULL,
  [Resolucion] nvarchar(1000) COLLATE Modern_Spanish_CI_AS  NULL,
  [FechaAlta] datetime2(3) DEFAULT sysdatetime() NOT NULL
)
GO

ALTER TABLE [aud].[TipoDiferencia] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- View structure for vw_DiferenciaCriterio
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[vw_DiferenciaCriterio]') AND type IN ('V'))
	DROP VIEW [aud].[vw_DiferenciaCriterio]
GO

CREATE VIEW [aud].[vw_DiferenciaCriterio] AS WITH Calc AS (
    SELECT
        H.IdEmpresa, EM.RFC, Periodo = CP.Periodo, H.IdMes,
        H.IdActivo, A.Identificador, A.Descripcion, Grupo = CC.Grupo,
        A.FechaAdquisicion, A.FechaUso,
        Dia = DAY(A.FechaUso),
        A.FechaBaja,
        H.Moi, Pct = H.Porcentaje_Dep_Contable_Anual,
        MesesSistema = H.Meses_Efectivos_Contables,
        ImporteSistema = H.DepreciacionContableInversionAnual,
        -- PEND-BACK-03: el sistema ya cuenta desde FechaUso, así que el criterio
        -- alterno se evalúa contra esa fecha y no contra la de adquisición.
        -- Antes de ese cambio, esta rama descontaba un mes sobre un cálculo que
        -- aún partía de FechaAdquisicion, y producía una diferencia inexistente.
        MesesAlterno = CASE
            WHEN DAY(A.FechaUso) <> 1
                THEN H.Meses_Efectivos_Contables
            WHEN H.Meses_Efectivos_Contables = 0
                THEN 0
            WHEN YEAR(A.FechaUso) = CP.Periodo
                THEN H.Meses_Efectivos_Contables - 1
            WHEN A.FechaBaja IS NULL
                 AND H.Meses_Efectivos_Contables BETWEEN 1 AND 11
                THEN H.Meses_Efectivos_Contables + 1
            ELSE H.Meses_Efectivos_Contables
        END
    FROM dbo.CalculoDetalle_Historico H
    INNER JOIN dbo.Activos A          ON A.Id = H.IdActivo
    INNER JOIN dbo.CatalogoPeriodo CP ON CP.Id = H.IdPeriodo
    LEFT  JOIN dbo.CatalogoCuentas CC ON CC.Id = A.IdCatalogo
    LEFT  JOIN dbo.Empresas EM        ON EM.Id = H.IdEmpresa
    WHERE H.Convencional = 1
)
SELECT
    IdEmpresa, RFC, Periodo, IdMes,
    IdActivo, Identificador, Descripcion, Grupo,
    FechaAdquisicion,
    FechaUso,
    Dia_Adquisicion = Dia,
    FechaBaja, Moi, Pct,
    Meses_Sistema          = MesesSistema,
    Meses_Criterio_Alterno = MesesAlterno,
    Importe_Sistema          = ImporteSistema,
    Importe_Criterio_Alterno = ROUND(Moi * Pct / 12.0 * MesesAlterno, 2),
    Diferencia               = ImporteSistema - ROUND(Moi * Pct / 12.0 * MesesAlterno, 2),
    TipoDiferencia = CASE WHEN MesesSistema <> MesesAlterno THEN 'DIF-01' END,
    Explicacion = CASE
        WHEN MesesSistema = MesesAlterno THEN NULL
        WHEN YEAR(FechaUso) = Periodo
            THEN CONCAT(N'Puesto en uso el día 1. El bien se utilizó el mes de inicio completo, ',
                        N'así que el criterio LISR lo cuenta (', MesesSistema,
                        N' meses) y el de resta de meses lo descarta (', MesesAlterno, N').')
        ELSE CONCAT(N'Ejercicio de agotamiento. Al haber deducido un mes antes, ',
                    N'el sistema termina con ', MesesSistema,
                    N' meses y el criterio alterno con ', MesesAlterno, N'.')
    END
FROM Calc;
GO


-- ----------------------------
-- View structure for vw_InpcEstado
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[vw_InpcEstado]') AND type IN ('V'))
	DROP VIEW [aud].[vw_InpcEstado]
GO

CREATE VIEW [aud].[vw_InpcEstado] AS SELECT
    Anio          = YEAR(I.Fecha),
    Mes           = DAY(I.Fecha),          -- el mes va en la posicion del dia
    PrimerDiaMes  = DATEFROMPARTS(YEAR(I.Fecha), DAY(I.Fecha), 1),
    I.Inpc,
    I.EsProvisional,
    I.FechaPublicacion,
    I.Fuente,
    I.Nota,
    Variacion = I.Inpc - LAG(I.Inpc) OVER (ORDER BY YEAR(I.Fecha) * 100 + DAY(I.Fecha)),
    Alerta = CASE
        WHEN I.EsProvisional = 1 THEN 'PROVISIONAL'
        WHEN I.Inpc = LAG(I.Inpc) OVER (ORDER BY YEAR(I.Fecha) * 100 + DAY(I.Fecha))
            THEN 'IDENTICO AL MES ANTERIOR · verificar'
        WHEN I.Inpc < LAG(I.Inpc) OVER (ORDER BY YEAR(I.Fecha) * 100 + DAY(I.Fecha))
            THEN 'MENOR AL ANTERIOR · posible pero verificar'
        ELSE NULL END
FROM dbo.Inpc I;
GO


-- ----------------------------
-- View structure for vw_UltimaCorrida
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[vw_UltimaCorrida]') AND type IN ('V'))
	DROP VIEW [aud].[vw_UltimaCorrida]
GO

CREATE VIEW [aud].[vw_UltimaCorrida] AS SELECT
    C.IdEmpresa, EM.RFC, C.Periodo, C.Mes,
    C.IdCorrida, C.FechaInicio, C.FechaFin, C.DuracionSegundos,
    C.Estado, C.UsuarioSQL, C.UsuarioApp, C.AppName, C.HostName,
    C.EsRecalculo, C.ActivosProcesados, C.ActivosConCambio,
    C.EstadoPeriodoPrevio,
    EstadoActual = ISNULL(PE.Estado, 'ABIERTO'),
    PE.Recalculos,
    Sin_Novedad = CASE WHEN C.ActivosConCambio = 0 THEN 'SI'
                       WHEN C.ActivosConCambio IS NULL THEN '(primera corrida)'
                       ELSE 'NO' END
FROM aud.CorridaCalculo C
LEFT JOIN dbo.Empresas EM      ON EM.Id = C.IdEmpresa
LEFT JOIN aud.PeriodoEstado PE ON PE.IdEmpresa = C.IdEmpresa
                              AND PE.Periodo   = C.Periodo
                              AND PE.Mes       = C.Mes
WHERE C.IdCorrida = ISNULL(PE.IdCorridaUltima, C.IdCorrida);
GO


-- ----------------------------
-- procedure structure for sp_RegistrarInpc
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_RegistrarInpc]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_RegistrarInpc]
GO

CREATE PROCEDURE [aud].[sp_RegistrarInpc]
    @Anio          INT,
    @Mes           TINYINT,
    @Inpc          DECIMAL(18,4),
    @EsProvisional BIT           = 0,
    @Fuente        NVARCHAR(100) = NULL,
    @Motivo        NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Mes NOT BETWEEN 1 AND 12
    BEGIN
        RAISERROR('Mes invalido: %d', 16, 1, @Mes);
        RETURN;
    END

    IF @Inpc <= 0
    BEGIN
        RAISERROR('El INPC debe ser mayor que cero.', 16, 1);
        RETURN;
    END

    -- Codificacion AAAA-01-MM: el mes va en la posicion del dia
    DECLARE @Fecha DATE = DATEFROMPARTS(@Anio, 1, @Mes);

    DECLARE @InpcAnterior DECIMAL(18,4), @ProvAnterior BIT, @Accion VARCHAR(20);

    SELECT @InpcAnterior = Inpc, @ProvAnterior = EsProvisional
    FROM dbo.Inpc WHERE Fecha = @Fecha;

    SET @Accion = CASE
        WHEN @InpcAnterior IS NULL THEN 'ALTA'
        WHEN @ProvAnterior = 1 AND @EsProvisional = 0 THEN 'DEFINITIVO'
        ELSE 'ACTUALIZACION' END;

    -- Advertencia: valor identico al mes anterior sin marcar provisional
    DECLARE @MesPrev TINYINT = CASE WHEN @Mes = 1 THEN 12 ELSE @Mes - 1 END;
    DECLARE @AnioPrev INT    = CASE WHEN @Mes = 1 THEN @Anio - 1 ELSE @Anio END;
    DECLARE @InpcPrev DECIMAL(18,4) =
        (SELECT Inpc FROM dbo.Inpc WHERE Fecha = DATEFROMPARTS(@AnioPrev, 1, @MesPrev));

    IF @InpcPrev IS NOT NULL AND @InpcPrev = @Inpc AND @EsProvisional = 0
    BEGIN
        -- RAISERROR no admite decimal como parametro de sustitucion: solo
        -- acepta %d para enteros y %s para cadenas. Cualquier decimal, money,
        -- date o datetime hay que convertirlo antes.
        DECLARE @InpcPrevTxt VARCHAR(30) = CAST(@InpcPrev AS VARCHAR(30));

        RAISERROR('El valor es identico al del mes anterior (%s). Si es un sustituto, marcarlo como provisional; si es real, confirmarlo con el DOF.',
                  16, 1, @InpcPrevTxt);
        RETURN;
    END

    BEGIN TRANSACTION;

        IF @InpcAnterior IS NULL
            INSERT INTO dbo.Inpc (Fecha, Inpc, EsProvisional, FechaPublicacion, Fuente, Nota)
            VALUES (@Fecha, @Inpc, @EsProvisional,
                    CASE WHEN @EsProvisional = 0 THEN CAST(GETDATE() AS DATE) END,
                    @Fuente, @Motivo);
        ELSE
            UPDATE dbo.Inpc
            SET Inpc = @Inpc,
                EsProvisional = @EsProvisional,
                FechaPublicacion = CASE WHEN @EsProvisional = 0 THEN CAST(GETDATE() AS DATE)
                                        ELSE FechaPublicacion END,
                Fuente = ISNULL(@Fuente, Fuente),
                Nota = @Motivo,
                FechaCaptura = SYSDATETIME(),
                UsuarioCaptura = SUSER_SNAME()
            WHERE Fecha = @Fecha;

        -- Cierres que quedan invalidados por este cambio
        DECLARE @Afectados INT = 0;

        IF @InpcAnterior IS NOT NULL AND @InpcAnterior <> @Inpc
            SELECT @Afectados = COUNT(DISTINCT CONCAT(H.IdEmpresa,'-',H.IdPeriodo,'-',H.IdMes))
            FROM dbo.CalculoDetalle_Historico H
            WHERE H.InpcMitadPeriodo = @InpcAnterior
               OR H.InpcFechaAdquisicion = @InpcAnterior;

        INSERT INTO aud.LogInpc
            (Anio, Mes, Inpc_Anterior, Inpc_Nuevo, EsProvisional_Anterior, EsProvisional_Nuevo,
             Accion, Fuente, Motivo, CierresAfectados)
        VALUES
            (@Anio, @Mes, @InpcAnterior, @Inpc, @ProvAnterior, @EsProvisional,
             @Accion, @Fuente, @Motivo, @Afectados);

    COMMIT TRANSACTION;

    SELECT Accion = @Accion, Anio = @Anio, Mes = @Mes,
           Inpc_Anterior = @InpcAnterior, Inpc_Nuevo = @Inpc,
           EsProvisional = @EsProvisional,
           Cierres_Que_Requieren_Recalculo = @Afectados;
END
GO


-- ----------------------------
-- procedure structure for sp_InpcFaltantes
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_InpcFaltantes]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_InpcFaltantes]
GO

CREATE PROCEDURE [aud].[sp_InpcFaltantes]
    @DesdeAnio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @DesdeAnio = ISNULL(@DesdeAnio, YEAR(GETDATE()) - 2);

    ;WITH Calendario AS (
        SELECT Anio = YEAR(DATEADD(MONTH, n, DATEFROMPARTS(@DesdeAnio,1,1))),
               Mes  = MONTH(DATEADD(MONTH, n, DATEFROMPARTS(@DesdeAnio,1,1)))
        FROM (SELECT TOP 120 n = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1
              FROM sys.all_objects) N
        WHERE DATEADD(MONTH, n, DATEFROMPARTS(@DesdeAnio,1,1)) <= GETDATE()
    )
    SELECT
        C.Anio, C.Mes,
        Estado = CASE
            WHEN I.Inpc IS NULL THEN 'FALTANTE'
            WHEN I.EsProvisional = 1 THEN 'PROVISIONAL'
            ELSE 'DEFINITIVO' END,
        I.Inpc, I.Nota
    FROM Calendario C
    LEFT JOIN dbo.Inpc I ON I.Fecha = DATEFROMPARTS(C.Anio, 1, C.Mes)
    WHERE I.Inpc IS NULL OR I.EsProvisional = 1
    ORDER BY C.Anio DESC, C.Mes DESC;
END
GO


-- ----------------------------
-- procedure structure for sp_CierresConInpcProvisional
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_CierresConInpcProvisional]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_CierresConInpcProvisional]
GO

CREATE PROCEDURE [aud].[sp_CierresConInpcProvisional]
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH InpcUsado AS (
        SELECT DISTINCT
            H.IdEmpresa, H.IdPeriodo, H.IdMes,
            Valor = H.InpcMitadPeriodo
        FROM dbo.CalculoDetalle_Historico H
        WHERE H.InpcMitadPeriodo IS NOT NULL
        UNION
        SELECT DISTINCT
            H.IdEmpresa, H.IdPeriodo, H.IdMes,
            H.InpcFechaAdquisicion
        FROM dbo.CalculoDetalle_Historico H
        WHERE H.InpcFechaAdquisicion IS NOT NULL
    )
    SELECT
        U.IdEmpresa,
        EM.RFC,
        Periodo = CP.Periodo,
        U.IdMes,
        Estado_Cierre = ISNULL(PE.Estado, 'ABIERTO'),
        Valores_Provisionales = COUNT(DISTINCT U.Valor),
        Detalle = STRING_AGG(CONCAT(YEAR(I.Fecha), '/', DAY(I.Fecha), ' = ', CAST(I.Inpc AS VARCHAR(20))), ' · '),
        Accion = 'RECALCULAR cuando el INPC sea definitivo'
    FROM InpcUsado U
    INNER JOIN dbo.Inpc I ON I.Inpc = U.Valor AND I.EsProvisional = 1
    LEFT  JOIN dbo.CatalogoPeriodo CP ON CP.Id = U.IdPeriodo
    LEFT  JOIN dbo.Empresas EM        ON EM.Id = U.IdEmpresa
    LEFT  JOIN aud.PeriodoEstado PE   ON PE.IdEmpresa = U.IdEmpresa
                                     AND PE.Periodo   = CP.Periodo
                                     AND PE.Mes       = U.IdMes
    GROUP BY U.IdEmpresa, EM.RFC, CP.Periodo, U.IdMes, PE.Estado
    ORDER BY CP.Periodo, U.IdMes, U.IdEmpresa;
END
GO


-- ----------------------------
-- procedure structure for sp_MarcarInsumosProvisionales
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_MarcarInsumosProvisionales]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_MarcarInsumosProvisionales]
GO

CREATE PROCEDURE [aud].[sp_MarcarInsumosProvisionales]
    @IdEmpresa INT,
    @Periodo   INT,
    @Mes       TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @IdPeriodo INT = (SELECT Id FROM dbo.CatalogoPeriodo WHERE Periodo = @Periodo);
        DECLARE @Detalle NVARCHAR(500);

        SELECT @Detalle = STRING_AGG(CONCAT(YEAR(I.Fecha), '/', DAY(I.Fecha)), ', ')
        FROM dbo.Inpc I
        WHERE I.EsProvisional = 1
          AND EXISTS (SELECT 1 FROM dbo.CalculoDetalle_Historico H
                      WHERE H.IdEmpresa = @IdEmpresa AND H.IdPeriodo = @IdPeriodo
                        AND H.IdMes = @Mes
                        AND (H.InpcMitadPeriodo = I.Inpc OR H.InpcFechaAdquisicion = I.Inpc));

        UPDATE aud.PeriodoEstado
        SET InsumosProvisionales = CASE WHEN @Detalle IS NULL THEN 0 ELSE 1 END,
            DetalleProvisional   = CASE WHEN @Detalle IS NULL THEN NULL
                                        ELSE CONCAT('INPC provisional: ', @Detalle) END
        WHERE IdEmpresa = @IdEmpresa AND Periodo = @Periodo AND Mes = @Mes;
    END TRY
    BEGIN CATCH
        -- La auditoria no tumba el calculo
    END CATCH;
END
GO


-- ----------------------------
-- procedure structure for sp_CerrarPeriodo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_CerrarPeriodo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_CerrarPeriodo]
GO

CREATE PROCEDURE [aud].[sp_CerrarPeriodo]
    @IdEmpresa  INT,
    @Periodo    INT,
    @Mes        TINYINT,
    @UsuarioApp NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Estado VARCHAR(30), @Calculado BIT, @Provisional BIT, @Detalle NVARCHAR(500);

    SELECT @Estado = Estado,
           @Calculado = CASE WHEN IdCorridaUltima IS NOT NULL THEN 1 ELSE 0 END,
           @Provisional = InsumosProvisionales,
           @Detalle = DetalleProvisional
    FROM aud.PeriodoEstado
    WHERE IdEmpresa = @IdEmpresa AND Periodo = @Periodo AND Mes = @Mes;

    IF @Estado IS NULL OR @Calculado = 0
    BEGIN
        RAISERROR('No se puede cerrar %d/%d: el periodo no ha sido calculado.', 16, 1, @Mes, @Periodo);
        RETURN;
    END

    IF @Estado = 'CERRADO'
    BEGIN
        RAISERROR('El periodo %d/%d ya esta cerrado.', 16, 1, @Mes, @Periodo);
        RETURN;
    END

    -- El INPC solo afecta lo fiscal, pero se bloquea el cierre completo:
    -- separar contable y fiscal obligaria a dos estados y a que todo lo que
    -- consume PeriodoEstado los distinga. Se puede afinar despues.
    IF @Provisional = 1
    BEGIN
        RAISERROR('No se puede cerrar %d/%d: el calculo uso insumos provisionales (%s). Cargue el valor definitivo y recalcule.',
                  16, 1, @Mes, @Periodo, @Detalle);
        RETURN;
    END

    -- El mes anterior debe estar cerrado para cerrar este
    DECLARE @MesAnt TINYINT = CASE WHEN @Mes = 1 THEN 12 ELSE @Mes - 1 END;
    DECLARE @PerAnt INT     = CASE WHEN @Mes = 1 THEN @Periodo - 1 ELSE @Periodo END;
    DECLARE @PrimerPeriodo INT, @PrimerMes TINYINT;

    SELECT @PrimerPeriodo = PrimerPeriodo, @PrimerMes = PrimerMes
    FROM aud.EmpresaAlcance WHERE IdEmpresa = @IdEmpresa;

    IF @PrimerPeriodo IS NOT NULL
       AND (@PerAnt * 100 + @MesAnt) >= (@PrimerPeriodo * 100 + @PrimerMes)
       AND NOT EXISTS (SELECT 1 FROM aud.PeriodoEstado
                       WHERE IdEmpresa = @IdEmpresa AND Periodo = @PerAnt
                         AND Mes = @MesAnt AND Estado = 'CERRADO')
    BEGIN
        RAISERROR('No se puede cerrar %d/%d: el mes anterior (%d/%d) no esta cerrado.',
                  16, 1, @Mes, @Periodo, @MesAnt, @PerAnt);
        RETURN;
    END

    UPDATE aud.PeriodoEstado
    SET Estado = 'CERRADO',
        FechaCierre = SYSDATETIME(),
        UsuarioCierre = ISNULL(@UsuarioApp, SUSER_SNAME())
    WHERE IdEmpresa = @IdEmpresa AND Periodo = @Periodo AND Mes = @Mes;

    SELECT Resultado = 1, Mensaje = CONCAT('Periodo ', @Mes, '/', @Periodo, ' cerrado correctamente.');
END
GO


-- ----------------------------
-- function structure for fn_MesesSegunCriterio
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[fn_MesesSegunCriterio]') AND type IN ('FN', 'FS', 'FT', 'IF', 'TF'))
	DROP FUNCTION[aud].[fn_MesesSegunCriterio]
GO

CREATE FUNCTION [aud].[fn_MesesSegunCriterio] (
    @FechaAdquisicion DATE,
    @FechaCorte       DATE,
    @FechaBaja        DATE,
    @IdCriterio       INT
)
RETURNS INT
AS
BEGIN
    IF @FechaAdquisicion IS NULL OR @FechaCorte IS NULL RETURN 0;

    -- Fuera del ejercicio de corte
    IF YEAR(@FechaAdquisicion) > YEAR(@FechaCorte) RETURN 0;

    DECLARE @MesFin   INT = CASE
        WHEN @FechaBaja IS NOT NULL AND YEAR(@FechaBaja) = YEAR(@FechaCorte)
             AND MONTH(@FechaBaja) - 1 < MONTH(@FechaCorte)
        THEN MONTH(@FechaBaja) - 1
        ELSE MONTH(@FechaCorte) END;

    DECLARE @MesIni   INT = CASE
        WHEN YEAR(@FechaAdquisicion) < YEAR(@FechaCorte) THEN 1
        ELSE MONTH(@FechaAdquisicion) END;

    DECLARE @EsAnioAdq BIT = CASE WHEN YEAR(@FechaAdquisicion) = YEAR(@FechaCorte) THEN 1 ELSE 0 END;

    IF @IdCriterio = 1   -- LISR: el mes de inicio cuenta si el dia es 1
    BEGIN
        IF @EsAnioAdq = 0 RETURN CASE WHEN @MesFin < 1 THEN 0 ELSE @MesFin END;
        IF DAY(@FechaAdquisicion) = 1
            RETURN CASE WHEN @MesFin - @MesIni + 1 < 0 THEN 0 ELSE @MesFin - @MesIni + 1 END;
        RETURN CASE WHEN @MesFin - @MesIni < 0 THEN 0 ELSE @MesFin - @MesIni END;
    END

    IF @IdCriterio = 2   -- Resta de meses: el mes de inicio nunca cuenta
    BEGIN
        IF @EsAnioAdq = 0 RETURN CASE WHEN @MesFin < 1 THEN 0 ELSE @MesFin END;
        RETURN CASE WHEN @MesFin - @MesIni < 0 THEN 0 ELSE @MesFin - @MesIni END;
    END

    RETURN 0;
END
GO


-- ----------------------------
-- procedure structure for sp_ExplicarActivo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_ExplicarActivo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_ExplicarActivo]
GO

CREATE PROCEDURE [aud].[sp_ExplicarActivo]
    @IdActivo INT,
    @Periodo  INT,
    @Mes      TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        D.IdActivo, D.Identificador, D.Descripcion, D.Grupo,
        D.FechaAdquisicion, D.Dia_Adquisicion, D.Moi, D.Pct,
        D.Meses_Sistema, D.Meses_Criterio_Alterno,
        D.Importe_Sistema, D.Importe_Criterio_Alterno, D.Diferencia,
        D.TipoDiferencia,
        D.Explicacion,
        Naturaleza = T.Naturaleza,
        SeAutoCompensa = T.SeAutoCompensa,
        Excepciones = T.Excepciones,
        EstadoConsulta = T.Estado,
        Fundamento = C.Fundamento,
        TieneDiferencia = CASE WHEN D.Diferencia <> 0 THEN 1 ELSE 0 END
    FROM aud.vw_DiferenciaCriterio D
    LEFT JOIN aud.TipoDiferencia T  ON T.Clave = D.TipoDiferencia
    LEFT JOIN aud.CriterioCalculo C ON C.IdCriterio = 1
    WHERE D.IdActivo = @IdActivo AND D.Periodo = @Periodo AND D.IdMes = @Mes;
END
GO


-- ----------------------------
-- procedure structure for sp_ConciliacionPeriodo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_ConciliacionPeriodo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_ConciliacionPeriodo]
GO

CREATE PROCEDURE [aud].[sp_ConciliacionPeriodo]
    @IdEmpresa INT,
    @Periodo   INT,
    @Mes       TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Resumen por grupo
    SELECT
        D.Grupo,
        Activos = COUNT(*),
        Activos_Con_Diferencia = SUM(CASE WHEN D.Diferencia <> 0 THEN 1 ELSE 0 END),
        Importe_Sistema = SUM(D.Importe_Sistema),
        Importe_Criterio_Alterno = SUM(D.Importe_Criterio_Alterno),
        Diferencia = SUM(D.Diferencia)
    FROM aud.vw_DiferenciaCriterio D
    WHERE D.IdEmpresa = @IdEmpresa AND D.Periodo = @Periodo AND D.IdMes = @Mes
    GROUP BY D.Grupo
    ORDER BY ABS(SUM(D.Diferencia)) DESC, D.Grupo;

    -- Detalle solo de los que difieren
    SELECT
        D.IdActivo, D.Identificador, D.Descripcion, D.Grupo,
        D.FechaAdquisicion, D.Dia_Adquisicion,
        D.Moi, D.Pct,
        D.Meses_Sistema, D.Meses_Criterio_Alterno,
        D.Importe_Sistema, D.Importe_Criterio_Alterno, D.Diferencia,
        D.TipoDiferencia, D.Explicacion
    FROM aud.vw_DiferenciaCriterio D
    WHERE D.IdEmpresa = @IdEmpresa AND D.Periodo = @Periodo AND D.IdMes = @Mes
      AND D.Diferencia <> 0
    ORDER BY ABS(D.Diferencia) DESC;

    -- Encabezado del papel de trabajo
    SELECT
        Criterio_Del_Sistema = C.Nombre,
        C.Fundamento,
        Criterio_Comparado = C2.Nombre,
        Total_Diferencia = (SELECT SUM(Diferencia) FROM aud.vw_DiferenciaCriterio
                            WHERE IdEmpresa = @IdEmpresa AND Periodo = @Periodo AND IdMes = @Mes),
        Naturaleza = T.Naturaleza,
        T.Excepciones
    FROM aud.CriterioCalculo C
    CROSS JOIN aud.CriterioCalculo C2
    LEFT JOIN aud.TipoDiferencia T ON T.Clave = 'DIF-01'
    WHERE C.IdCriterio = 1 AND C2.IdCriterio = 2;
END
GO


-- ----------------------------
-- procedure structure for sp_EfectoEnajenacion
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_EfectoEnajenacion]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_EfectoEnajenacion]
GO

CREATE PROCEDURE [aud].[sp_EfectoEnajenacion]
    @IdEmpresa INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AB.IdActivo, A.Identificador, A.Descripcion,
        A.IdEmpresa, EM.RFC,
        A.FechaAdquisicion, Dia = DAY(A.FechaAdquisicion),
        AB.FechaVenta,
        Ejercicio_Venta = YEAR(AB.FechaVenta),
        A.Moi, Pct = A.PorcentajeDepContableAnual,
        AB.ImporteContableDepreciado,
        AB.RemanenteContableDepreciar,
        AB.PrecioVenta,
        AB.UtilidadContable, AB.PerdidaContable,
        AB.ValorActualizadoPendienteDeducir,
        AB.UtilidadFiscalVenta, AB.PerdidaFiscalVenta,
        AB.FactoraAjuste,

        Un_Mes = ROUND(A.Moi * A.PorcentajeDepContableAnual / 12.0, 2),
        Remanente_Criterio_Alterno = AB.RemanenteContableDepreciar
                                   + ROUND(A.Moi * A.PorcentajeDepContableAnual / 12.0, 2),
        Efecto_En_Utilidad = -ROUND(A.Moi * A.PorcentajeDepContableAnual / 12.0, 2),
        Efecto_Fiscal_Actualizado = -ROUND(A.Moi * A.PorcentajeDepContableAnual / 12.0
                                           * ISNULL(AB.FactoraAjuste, 1), 2),

        Nota = N'Con el criterio LISR se dedujo un mes más antes de la venta, así que el remanente es menor. El efecto se concentra en el ejercicio de la enajenación en vez de repartirse hasta el agotamiento. Al actualizarse el remanente por INPC, la compensación no es exacta en términos actualizados.'
    FROM dbo.ActivosBaja AB
    INNER JOIN dbo.Activos A   ON A.Id = AB.IdActivo
    LEFT  JOIN dbo.Empresas EM ON EM.Id = A.IdEmpresa
    WHERE DAY(A.FechaAdquisicion) = 1
      AND ISNULL(A.PorcentajeDepContableAnual, 0) > 0
      AND (@IdEmpresa IS NULL OR A.IdEmpresa = @IdEmpresa)
    ORDER BY ABS(ROUND(A.Moi * A.PorcentajeDepContableAnual / 12.0, 2)) DESC;
END
GO


-- ----------------------------
-- procedure structure for sp_CorridaIniciar
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_CorridaIniciar]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_CorridaIniciar]
GO

CREATE PROCEDURE [aud].[sp_CorridaIniciar]
    @IdEmpresa   INT,
    @Periodo     INT,
    @Mes         TINYINT,
    @UsuarioApp  NVARCHAR(128) = NULL,
    @Simulacion  BIT           = 0,
    @IdCorrida   BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @IdCorrida = NULL;

    -- Interruptor de mantenimiento
    IF (SELECT Valor FROM aud.Configuracion WHERE Clave = 'AUDITORIA_HABILITADA') = '0'
        RETURN;

    BEGIN TRY
        DECLARE @EstadoPrevio VARCHAR(30), @IdSolicitud INT, @EsRecalculo BIT = 0;

        SELECT @EstadoPrevio = PE.Estado,
               @IdSolicitud  = PE.IdSolicitudVigente,
               @EsRecalculo  = CASE WHEN PE.IdCorridaUltima IS NOT NULL THEN 1 ELSE 0 END
        FROM aud.PeriodoEstado PE
        WHERE PE.IdEmpresa = @IdEmpresa AND PE.Periodo = @Periodo AND PE.Mes = @Mes;

        SET @EstadoPrevio = ISNULL(@EstadoPrevio, 'ABIERTO');

        INSERT INTO aud.CorridaCalculo
            (IdEmpresa, Periodo, Mes, Estado, UsuarioApp,
             EstadoPeriodoPrevio, IdSolicitud, EsRecalculo)
        VALUES
            (@IdEmpresa, @Periodo, @Mes,
             CASE WHEN @Simulacion = 1 THEN 'SIMULACION' ELSE 'EN_PROCESO' END,
             @UsuarioApp, @EstadoPrevio, @IdSolicitud, @EsRecalculo);

        SET @IdCorrida = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        SET @IdCorrida = NULL;
    END CATCH;
END
GO


-- ----------------------------
-- function structure for fn_HashInsumos
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[fn_HashInsumos]') AND type IN ('FN', 'FS', 'FT', 'IF', 'TF'))
	DROP FUNCTION[aud].[fn_HashInsumos]
GO

CREATE FUNCTION [aud].[fn_HashInsumos] (
    @Moi              DECIMAL(18,2),
    @MoiFiscal        DECIMAL(18,2),
    @PctContable      DECIMAL(14,6),
    @PctFiscal        DECIMAL(14,6),
    @IdCatalogo       INT,
    @Convencional     TINYINT,
    @FechaAdquisicion DATE,
    @FechaBaja        DATE,
    @FechaUso         DATE = NULL      -- PEND-BACK-04
)
RETURNS BINARY(32)
AS
BEGIN
    RETURN HASHBYTES('SHA2_256', CONCAT(
        ISNULL(CAST(@Moi          AS VARCHAR(30)), '~'), '|',
        ISNULL(CAST(@MoiFiscal    AS VARCHAR(30)), '~'), '|',
        ISNULL(CAST(@PctContable  AS VARCHAR(30)), '~'), '|',
        ISNULL(CAST(@PctFiscal    AS VARCHAR(30)), '~'), '|',
        ISNULL(CAST(@IdCatalogo   AS VARCHAR(12)), '~'), '|',
        ISNULL(CAST(@Convencional AS VARCHAR(3)),  '~'), '|',
        ISNULL(CONVERT(VARCHAR(10), @FechaAdquisicion, 23), '~'), '|',
        ISNULL(CONVERT(VARCHAR(10), @FechaBaja,        23), '~'), '|',
        -- PEND-BACK-04: gobierna meses transcurridos y meses efectivos
        ISNULL(CONVERT(VARCHAR(10), @FechaUso,         23), '~')
    ));
END
GO


-- ----------------------------
-- procedure structure for sp_DiffCorridas
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_DiffCorridas]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_DiffCorridas]
GO

CREATE PROCEDURE [aud].[sp_DiffCorridas]
    @IdCorridaNueva  BIGINT,
    @IdCorridaPrevia BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdCorridaPrevia IS NULL
        SELECT @IdCorridaPrevia = C.IdCorridaPrevia
        FROM aud.CorridaCalculo C WHERE C.IdCorrida = @IdCorridaNueva;

    IF @IdCorridaPrevia IS NULL
    BEGIN
        SELECT Aviso = 'No hay corrida previa con la cual comparar.';
        RETURN;
    END

    -- Encabezado
    SELECT
        Corrida_Previa = P.IdCorrida, Fecha_Previa = P.FechaInicio,
        Usuario_Previa = P.UsuarioSQL, App_Previa = P.AppName,
        Corrida_Nueva  = N.IdCorrida, Fecha_Nueva  = N.FechaInicio,
        Usuario_Nueva  = N.UsuarioSQL, App_Nueva  = N.AppName,
        N.IdEmpresa, N.Periodo, N.Mes,
        Activos_Previa = P.ActivosProcesados,
        Activos_Nueva  = N.ActivosProcesados,
        Motivo = S.Motivo, TipoMotivo = S.ClaveMotivo,
        Naturaleza = M.Naturaleza, SugiereCascada = M.SugiereCascada
    FROM aud.CorridaCalculo N
    INNER JOIN aud.CorridaCalculo P ON P.IdCorrida = @IdCorridaPrevia
    LEFT  JOIN aud.SolicitudReapertura S ON S.Id = N.IdSolicitud
    LEFT  JOIN aud.CatalogoMotivo M ON M.Clave = S.ClaveMotivo
    WHERE N.IdCorrida = @IdCorridaNueva;

    -- Detalle por activo y campo
    ;WITH Nueva AS (SELECT * FROM aud.FirmaActivo WHERE IdCorrida = @IdCorridaNueva),
          Previa AS (SELECT * FROM aud.FirmaActivo WHERE IdCorrida = @IdCorridaPrevia),
    Cambios AS (
        SELECT Tipo = 'ALTA', N.IdActivo, Campo = '(activo completo)',
               Valor_Anterior = NULL, Valor_Nuevo = CAST(N.Moi AS NVARCHAR(50)), Delta = N.Moi
        FROM Nueva N
        WHERE NOT EXISTS (SELECT 1 FROM Previa P WHERE P.IdActivo = N.IdActivo)

        UNION ALL
        SELECT 'SALIDA', P.IdActivo, '(activo completo)',
               CAST(P.Moi AS NVARCHAR(50)), NULL, -P.Moi
        FROM Previa P
        WHERE NOT EXISTS (SELECT 1 FROM Nueva N WHERE N.IdActivo = P.IdActivo)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'Moi',
               CAST(P.Moi AS NVARCHAR(50)), CAST(N.Moi AS NVARCHAR(50)), N.Moi - P.Moi
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.Moi,-1) <> ISNULL(P.Moi,-1)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'MoiFiscal',
               CAST(P.MoiFiscal AS NVARCHAR(50)), CAST(N.MoiFiscal AS NVARCHAR(50)), N.MoiFiscal - P.MoiFiscal
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.MoiFiscal,-1) <> ISNULL(P.MoiFiscal,-1)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'PctContable',
               CAST(P.PctContable AS NVARCHAR(50)), CAST(N.PctContable AS NVARCHAR(50)), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.PctContable,-1) <> ISNULL(P.PctContable,-1)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'PctFiscal',
               CAST(P.PctFiscal AS NVARCHAR(50)), CAST(N.PctFiscal AS NVARCHAR(50)), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.PctFiscal,-1) <> ISNULL(P.PctFiscal,-1)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'IdCatalogo',
               CAST(P.IdCatalogo AS NVARCHAR(50)), CAST(N.IdCatalogo AS NVARCHAR(50)), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.IdCatalogo,-1) <> ISNULL(P.IdCatalogo,-1)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'Convencional',
               CAST(P.Convencional AS NVARCHAR(50)), CAST(N.Convencional AS NVARCHAR(50)), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.Convencional,255) <> ISNULL(P.Convencional,255)

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'FechaAdquisicion',
               CONVERT(NVARCHAR(10), P.FechaAdquisicion, 23), CONVERT(NVARCHAR(10), N.FechaAdquisicion, 23), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.FechaAdquisicion,'1900-01-01') <> ISNULL(P.FechaAdquisicion,'1900-01-01')

        UNION ALL
        -- PEND-BACK-04
        SELECT 'CAMBIO', N.IdActivo, 'FechaUso',
               CONVERT(NVARCHAR(10), P.FechaUso, 23), CONVERT(NVARCHAR(10), N.FechaUso, 23), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.FechaUso,'1900-01-01') <> ISNULL(P.FechaUso,'1900-01-01')

        UNION ALL
        SELECT 'CAMBIO', N.IdActivo, 'FechaBaja',
               CONVERT(NVARCHAR(10), P.FechaBaja, 23), CONVERT(NVARCHAR(10), N.FechaBaja, 23), NULL
        FROM Nueva N INNER JOIN Previa P ON P.IdActivo = N.IdActivo
        WHERE N.Hash <> P.Hash AND ISNULL(N.FechaBaja,'1900-01-01') <> ISNULL(P.FechaBaja,'1900-01-01')
    )
    SELECT
        C.Tipo, C.IdActivo, A.Identificador, A.Descripcion,
        Grupo = CC.Grupo,
        C.Campo, C.Valor_Anterior, C.Valor_Nuevo, C.Delta,
        -- Enlace con la bitacora de FechaUso, cuando el campo sea ese
        Lote = CASE WHEN C.Campo = 'FechaUso'
                    THEN (SELECT TOP 1 L.Lote FROM aud.LogFechaUso L
                          WHERE L.IdActivo = C.IdActivo AND L.Accion <> 'POBLADO_INICIAL'
                          ORDER BY L.FechaOperacion DESC) END,
        Motivo_FechaUso = CASE WHEN C.Campo = 'FechaUso'
                    THEN (SELECT TOP 1 L.Motivo FROM aud.LogFechaUso L
                          WHERE L.IdActivo = C.IdActivo AND L.Accion <> 'POBLADO_INICIAL'
                          ORDER BY L.FechaOperacion DESC) END
    FROM Cambios C
    INNER JOIN dbo.Activos A ON A.Id = C.IdActivo
    LEFT  JOIN dbo.CatalogoCuentas CC ON CC.Id = A.IdCatalogo
    ORDER BY C.Tipo, C.Campo, C.IdActivo;

    -- Resumen
    SELECT Campo = 'Moi', Activos = COUNT(*), Impacto_MOI = SUM(N.Moi - P.Moi)
    FROM aud.FirmaActivo N
    INNER JOIN aud.FirmaActivo P ON P.IdActivo = N.IdActivo AND P.IdCorrida = @IdCorridaPrevia
    WHERE N.IdCorrida = @IdCorridaNueva AND N.Hash <> P.Hash
      AND ISNULL(N.Moi,-1) <> ISNULL(P.Moi,-1);
END
GO


-- ----------------------------
-- procedure structure for sp_CorridaFinalizar_copy1
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_CorridaFinalizar_copy1]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_CorridaFinalizar_copy1]
GO

CREATE PROCEDURE [aud].[sp_CorridaFinalizar_copy1]
    @IdCorrida BIGINT,
    @Estado    VARCHAR(20)    = 'OK',
    @Mensaje   NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdCorrida IS NULL RETURN;

    BEGIN TRY
        DECLARE @IdEmpresa INT, @Periodo INT, @Mes TINYINT, @IdSolicitud INT;

        SELECT @IdEmpresa = IdEmpresa, @Periodo = Periodo, @Mes = Mes,
               @IdSolicitud = IdSolicitud
        FROM aud.CorridaCalculo WHERE IdCorrida = @IdCorrida;

        IF @IdEmpresa IS NULL RETURN;

        DECLARE @IdPeriodo INT = (SELECT Id FROM dbo.CatalogoPeriodo WHERE Periodo = @Periodo);

        -- ---------------------------------------------------------------
        -- Firma de insumos
        -- ---------------------------------------------------------------
        IF @Estado = 'OK'
        BEGIN
            INSERT INTO aud.FirmaActivo
                (IdCorrida, IdActivo, Hash, Moi, MoiFiscal, PctContable, PctFiscal,
                 IdCatalogo, Convencional, FechaAdquisicion, FechaBaja, FechaUso)
            SELECT
                @IdCorrida,
                H.IdActivo,
                aud.fn_HashInsumos(H.Moi, H.MoiFiscal,
                                   H.Porcentaje_Dep_Contable_Anual,
                                   H.Porcentaje_Dep_Fiscal_Anual,
                                   A.IdCatalogo, H.Convencional,
                                   A.FechaAdquisicion, H.FechaBaja,
                                   A.FechaUso),
                H.Moi, H.MoiFiscal,
                H.Porcentaje_Dep_Contable_Anual, H.Porcentaje_Dep_Fiscal_Anual,
                A.IdCatalogo, H.Convencional,
                A.FechaAdquisicion, H.FechaBaja, A.FechaUso
            FROM dbo.CalculoDetalle_Historico H
            INNER JOIN dbo.Activos A ON A.Id = H.IdActivo
            WHERE H.IdEmpresa = @IdEmpresa
              AND H.IdPeriodo = @IdPeriodo
              AND H.IdMes     = @Mes
              AND H.Convencional = 1
            GROUP BY H.IdActivo, H.Moi, H.MoiFiscal,
                     H.Porcentaje_Dep_Contable_Anual, H.Porcentaje_Dep_Fiscal_Anual,
                     A.IdCatalogo, H.Convencional, A.FechaAdquisicion, H.FechaBaja,
                     A.FechaUso;
        END

        -- ---------------------------------------------------------------
        -- Corrida previa del mismo cierre
        -- ---------------------------------------------------------------
        DECLARE @IdCorridaPrevia BIGINT = (
            SELECT MAX(C.IdCorrida)
            FROM aud.CorridaCalculo C
            WHERE C.IdEmpresa = @IdEmpresa AND C.Periodo = @Periodo AND C.Mes = @Mes
              AND C.IdCorrida < @IdCorrida AND C.Estado = 'OK');

        DECLARE @ActivosConCambio INT = NULL;

        IF @IdCorridaPrevia IS NOT NULL
        BEGIN
            SELECT @ActivosConCambio = COUNT(*)
            FROM (
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorrida
                EXCEPT
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorridaPrevia
                UNION
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorridaPrevia
                EXCEPT
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorrida
                UNION
                SELECT N.IdActivo
                FROM aud.FirmaActivo N
                INNER JOIN aud.FirmaActivo P
                        ON P.IdActivo = N.IdActivo AND P.IdCorrida = @IdCorridaPrevia
                WHERE N.IdCorrida = @IdCorrida AND N.Hash <> P.Hash
            ) D;
        END

        -- ---------------------------------------------------------------
        -- Cierre de la bitacora
        -- ---------------------------------------------------------------
        UPDATE aud.CorridaCalculo
        SET FechaFin         = SYSDATETIME(),
            Estado           = @Estado,
            Mensaje          = @Mensaje,
            FilasDetalle     = (SELECT COUNT(*) FROM dbo.CalculoDetalle_Historico
                                WHERE IdEmpresa = @IdEmpresa AND IdPeriodo = @IdPeriodo AND IdMes = @Mes),
            FilasMensual     = (SELECT COUNT(*) FROM dbo.CalculoMensual_Historico
                                WHERE IdEmpresa = @IdEmpresa AND IdPeriodo = @IdPeriodo AND IdMes = @Mes),
            ActivosProcesados = (SELECT COUNT(*) FROM aud.FirmaActivo WHERE IdCorrida = @IdCorrida),
            IdCorridaPrevia  = @IdCorridaPrevia,
            ActivosConCambio = @ActivosConCambio
        WHERE IdCorrida = @IdCorrida;

        -- ---------------------------------------------------------------
        -- Estado del periodo y consumo de la autorizacion
        -- ---------------------------------------------------------------
        IF @Estado = 'OK'
        BEGIN
            MERGE aud.PeriodoEstado AS T
            USING (SELECT @IdEmpresa AS IdEmpresa, @Periodo AS Periodo, @Mes AS Mes) AS S
                ON T.IdEmpresa = S.IdEmpresa AND T.Periodo = S.Periodo AND T.Mes = S.Mes
            WHEN MATCHED THEN UPDATE SET
                T.FechaUltimoCalculo = SYSDATETIME(),
                T.IdCorridaUltima    = @IdCorrida,
                T.Recalculos         = T.Recalculos + 1,
                T.Estado = CASE WHEN T.Estado = 'REAPERTURA_AUTORIZADA'
                                THEN 'CERRADO' ELSE T.Estado END,
                T.IdSolicitudVigente = NULL
            WHEN NOT MATCHED THEN INSERT
                (IdEmpresa, Periodo, Mes, Estado, FechaUltimoCalculo, IdCorridaUltima, Recalculos)
                VALUES (@IdEmpresa, @Periodo, @Mes, 'ABIERTO', SYSDATETIME(), @IdCorrida, 1);

            EXEC aud.sp_MarcarInsumosProvisionales @IdEmpresa, @Periodo, @Mes;

            IF @IdSolicitud IS NOT NULL
                UPDATE aud.SolicitudReapertura
                SET Estado = 'CONSUMIDA', IdCorridaConsumo = @IdCorrida, FechaConsumo = SYSDATETIME()
                WHERE Id = @IdSolicitud AND Estado = 'AUTORIZADA';
        END
    END TRY
    BEGIN CATCH
        BEGIN TRY
            UPDATE aud.CorridaCalculo
            SET FechaFin = SYSDATETIME(),
                Estado   = @Estado,
                Mensaje  = CONCAT(ISNULL(@Mensaje, ''), ' | AUDITORIA: ', ERROR_MESSAGE())
            WHERE IdCorrida = @IdCorrida;
        END TRY
        BEGIN CATCH END CATCH;
    END CATCH;
END
GO


-- ----------------------------
-- procedure structure for sp_CorridaFinalizar
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_CorridaFinalizar]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_CorridaFinalizar]
GO

CREATE PROCEDURE [aud].[sp_CorridaFinalizar]
    @IdCorrida BIGINT,
    @Estado    VARCHAR(20)    = 'OK',
    @Mensaje   NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdCorrida IS NULL RETURN;

    BEGIN TRY
        DECLARE @IdEmpresa INT, @Periodo INT, @Mes TINYINT, @IdSolicitud INT;

        SELECT @IdEmpresa = IdEmpresa, @Periodo = Periodo, @Mes = Mes,
               @IdSolicitud = IdSolicitud
        FROM aud.CorridaCalculo WHERE IdCorrida = @IdCorrida;

        IF @IdEmpresa IS NULL RETURN;

        DECLARE @IdPeriodo INT = (SELECT Id FROM dbo.CatalogoPeriodo WHERE Periodo = @Periodo);

        -- ---------------------------------------------------------------
        -- Firma de insumos
        -- ---------------------------------------------------------------
        IF @Estado = 'OK'
        BEGIN
            INSERT INTO aud.FirmaActivo
                (IdCorrida, IdActivo, Hash, Moi, MoiFiscal, PctContable, PctFiscal,
                 IdCatalogo, Convencional, FechaAdquisicion, FechaBaja, FechaUso)
            SELECT
                @IdCorrida,
                H.IdActivo,
                aud.fn_HashInsumos(H.Moi, H.MoiFiscal,
                                   H.Porcentaje_Dep_Contable_Anual,
                                   H.Porcentaje_Dep_Fiscal_Anual,
                                   A.IdCatalogo, H.Convencional,
                                   A.FechaAdquisicion, H.FechaBaja,
                                   A.FechaUso),
                H.Moi, H.MoiFiscal,
                H.Porcentaje_Dep_Contable_Anual, H.Porcentaje_Dep_Fiscal_Anual,
                A.IdCatalogo, H.Convencional,
                A.FechaAdquisicion, H.FechaBaja, A.FechaUso
            FROM dbo.CalculoDetalle_Historico H
            INNER JOIN dbo.Activos A ON A.Id = H.IdActivo
            WHERE H.IdEmpresa = @IdEmpresa
              AND H.IdPeriodo = @IdPeriodo
              AND H.IdMes     = @Mes
              AND H.Convencional = 1
            GROUP BY H.IdActivo, H.Moi, H.MoiFiscal,
                     H.Porcentaje_Dep_Contable_Anual, H.Porcentaje_Dep_Fiscal_Anual,
                     A.IdCatalogo, H.Convencional, A.FechaAdquisicion, H.FechaBaja,
                     A.FechaUso;

            -- -----------------------------------------------------------
            -- SNAPSHOT: resultado completo de esta corrida (opcion B)
            -- -----------------------------------------------------------
            INSERT INTO aud.SnapshotCalculoDetalle (
                IdCorrida, IdActivo, IdEmpresa, IdPeriodo, IdMes,
                Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
                Moi, MoiFiscal, Baja, FechaBaja,
                Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
                DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
                Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
                DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
                InpcMitadPeriodo, InpcFechaAdquisicion, Factor_Ajuste,
                Deduccion_Fiscal_Inv_Actualizado, Convencional
            )
            SELECT
                @IdCorrida, IdActivo, IdEmpresa, IdPeriodo, IdMes,
                Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
                Moi, MoiFiscal, Baja, FechaBaja,
                Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
                DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
                Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
                DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
                InpcMitadPeriodo, InpcFechaAdquisicion, Factor_Ajuste,
                Deduccion_Fiscal_Inv_Actualizado, Convencional
            FROM dbo.CalculoDetalle_Historico
            WHERE IdEmpresa = @IdEmpresa AND IdPeriodo = @IdPeriodo AND IdMes = @Mes;

            INSERT INTO aud.SnapshotCalculoMensual (
                IdCorrida, IdActivo, TipoContabilidad, IdEmpresa, IdPeriodo, IdMes,
                Enero, Febrero, Marzo, Abril, Mayo, Junio,
                Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre
            )
            SELECT
                @IdCorrida, IdActivo, TipoContabilidad, IdEmpresa, IdPeriodo, IdMes,
                Enero, Febrero, Marzo, Abril, Mayo, Junio,
                Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre
            FROM dbo.CalculoMensual_Historico
            WHERE IdEmpresa = @IdEmpresa AND IdPeriodo = @IdPeriodo AND IdMes = @Mes;
        END

        -- ---------------------------------------------------------------
        -- Corrida previa del mismo cierre
        -- ---------------------------------------------------------------
        DECLARE @IdCorridaPrevia BIGINT = (
            SELECT MAX(C.IdCorrida)
            FROM aud.CorridaCalculo C
            WHERE C.IdEmpresa = @IdEmpresa AND C.Periodo = @Periodo AND C.Mes = @Mes
              AND C.IdCorrida < @IdCorrida AND C.Estado = 'OK');

        DECLARE @ActivosConCambio INT = NULL;

        IF @IdCorridaPrevia IS NOT NULL
        BEGIN
            SELECT @ActivosConCambio = COUNT(*)
            FROM (
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorrida
                EXCEPT
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorridaPrevia
                UNION
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorridaPrevia
                EXCEPT
                SELECT IdActivo FROM aud.FirmaActivo WHERE IdCorrida = @IdCorrida
                UNION
                SELECT N.IdActivo
                FROM aud.FirmaActivo N
                INNER JOIN aud.FirmaActivo P
                        ON P.IdActivo = N.IdActivo AND P.IdCorrida = @IdCorridaPrevia
                WHERE N.IdCorrida = @IdCorrida AND N.Hash <> P.Hash
            ) D;
        END

        -- ---------------------------------------------------------------
        -- Cierre de la bitacora
        -- ---------------------------------------------------------------
        UPDATE aud.CorridaCalculo
        SET FechaFin         = SYSDATETIME(),
            Estado           = @Estado,
            Mensaje          = @Mensaje,
            FilasDetalle     = (SELECT COUNT(*) FROM dbo.CalculoDetalle_Historico
                                WHERE IdEmpresa = @IdEmpresa AND IdPeriodo = @IdPeriodo AND IdMes = @Mes),
            FilasMensual     = (SELECT COUNT(*) FROM dbo.CalculoMensual_Historico
                                WHERE IdEmpresa = @IdEmpresa AND IdPeriodo = @IdPeriodo AND IdMes = @Mes),
            ActivosProcesados = (SELECT COUNT(*) FROM aud.FirmaActivo WHERE IdCorrida = @IdCorrida),
            IdCorridaPrevia  = @IdCorridaPrevia,
            ActivosConCambio = @ActivosConCambio
        WHERE IdCorrida = @IdCorrida;

        -- ---------------------------------------------------------------
        -- Estado del periodo y consumo de la autorizacion
        -- ---------------------------------------------------------------
        IF @Estado = 'OK'
        BEGIN
            MERGE aud.PeriodoEstado AS T
            USING (SELECT @IdEmpresa AS IdEmpresa, @Periodo AS Periodo, @Mes AS Mes) AS S
                ON T.IdEmpresa = S.IdEmpresa AND T.Periodo = S.Periodo AND T.Mes = S.Mes
            WHEN MATCHED THEN UPDATE SET
                T.FechaUltimoCalculo = SYSDATETIME(),
                T.IdCorridaUltima    = @IdCorrida,
                T.Recalculos         = T.Recalculos + 1,
                T.Estado = CASE WHEN T.Estado = 'REAPERTURA_AUTORIZADA'
                                THEN 'CERRADO' ELSE T.Estado END,
                T.IdSolicitudVigente = NULL
            WHEN NOT MATCHED THEN INSERT
                (IdEmpresa, Periodo, Mes, Estado, FechaUltimoCalculo, IdCorridaUltima, Recalculos)
                VALUES (@IdEmpresa, @Periodo, @Mes, 'ABIERTO', SYSDATETIME(), @IdCorrida, 1);

            EXEC aud.sp_MarcarInsumosProvisionales @IdEmpresa, @Periodo, @Mes;

            IF @IdSolicitud IS NOT NULL
                UPDATE aud.SolicitudReapertura
                SET Estado = 'CONSUMIDA', IdCorridaConsumo = @IdCorrida, FechaConsumo = SYSDATETIME()
                WHERE Id = @IdSolicitud AND Estado = 'AUTORIZADA';
        END
    END TRY
    BEGIN CATCH
        BEGIN TRY
            UPDATE aud.CorridaCalculo
            SET FechaFin = SYSDATETIME(),
                Estado   = @Estado,
                Mensaje  = CONCAT(ISNULL(@Mensaje, ''), ' | AUDITORIA: ', ERROR_MESSAGE())
            WHERE IdCorrida = @IdCorrida;
        END TRY
        BEGIN CATCH END CATCH;
    END CATCH;
END
GO


-- ----------------------------
-- procedure structure for sp_PurgarSnapshots
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[aud].[sp_PurgarSnapshots]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[aud].[sp_PurgarSnapshots]
GO

CREATE PROCEDURE [aud].[sp_PurgarSnapshots]
    @Conservar   INT = 5,       -- ultimas N corridas OK por cierre, ademas de la primera
    @Simulacion  BIT = 1        -- 1 = solo muestra que se borraria, 0 = borra de verdad
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Rankeadas AS (
        SELECT IdCorrida, IdEmpresa, Periodo, Mes,
               ROW_NUMBER() OVER (PARTITION BY IdEmpresa, Periodo, Mes ORDER BY IdCorrida ASC)  AS OrdenAsc,
               ROW_NUMBER() OVER (PARTITION BY IdEmpresa, Periodo, Mes ORDER BY IdCorrida DESC) AS OrdenDesc
        FROM aud.CorridaCalculo
        WHERE Estado = 'OK'
    ),
    AConservar AS (
        SELECT IdCorrida FROM Rankeadas WHERE OrdenAsc = 1          -- primera corrida (linea base)
        UNION
        SELECT IdCorrida FROM Rankeadas WHERE OrdenDesc <= @Conservar  -- ultimas N
    ),
    ABorrar AS (
        SELECT C.IdCorrida
        FROM aud.CorridaCalculo C
        WHERE NOT EXISTS (SELECT 1 FROM AConservar A WHERE A.IdCorrida = C.IdCorrida)
    )
    SELECT * INTO #ABorrar FROM ABorrar;

    IF @Simulacion = 1
    BEGIN
        SELECT 'SIMULACION -- nada se borro' AS Aviso;
        SELECT (SELECT COUNT(*) FROM #ABorrar) AS CorridasAPurgar,
               (SELECT COUNT(*) FROM aud.SnapshotCalculoDetalle D
                WHERE D.IdCorrida IN (SELECT IdCorrida FROM #ABorrar)) AS FilasDetalleAPurgar,
               (SELECT COUNT(*) FROM aud.SnapshotCalculoMensual M
                WHERE M.IdCorrida IN (SELECT IdCorrida FROM #ABorrar)) AS FilasMensualAPurgar;
    END
    ELSE
    BEGIN
        DELETE D FROM aud.SnapshotCalculoDetalle D
        INNER JOIN #ABorrar B ON D.IdCorrida = B.IdCorrida;

        DELETE M FROM aud.SnapshotCalculoMensual M
        INNER JOIN #ABorrar B ON M.IdCorrida = B.IdCorrida;

        SELECT (SELECT COUNT(*) FROM #ABorrar) AS CorridasPurgadas;
    END

    DROP TABLE IF EXISTS #ABorrar;
END
GO


-- ----------------------------
-- Indexes structure for table Activos_Historia
-- ----------------------------
CREATE CLUSTERED INDEX [ix_Activos_Historia]
ON [aud].[Activos_Historia] (
  [ValidoHasta] ASC,
  [ValidoDesde] ASC
)
GO


-- ----------------------------
-- Checks structure for table CatalogoMotivo
-- ----------------------------
ALTER TABLE [aud].[CatalogoMotivo] ADD CONSTRAINT [CK_aud_CatalogoMotivo_Nat] CHECK ([Naturaleza]='HECHO_NUEVO' OR [Naturaleza]='CORRECCION_ERROR')
GO


-- ----------------------------
-- Primary Key structure for table CatalogoMotivo
-- ----------------------------
ALTER TABLE [aud].[CatalogoMotivo] ADD CONSTRAINT [PK_aud_CatalogoMotivo] PRIMARY KEY CLUSTERED ([Clave])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table Configuracion
-- ----------------------------
ALTER TABLE [aud].[Configuracion] ADD CONSTRAINT [PK__Configur__E8181E104E8B1E85] PRIMARY KEY CLUSTERED ([Clave])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CorridaCalculo
-- ----------------------------
DBCC CHECKIDENT ('[aud].[CorridaCalculo]', RESEED, 32)
GO


-- ----------------------------
-- Indexes structure for table CorridaCalculo
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_Corrida_Periodo]
ON [aud].[CorridaCalculo] (
  [IdEmpresa] ASC,
  [Periodo] ASC,
  [Mes] ASC,
  [FechaInicio] DESC
)
GO


-- ----------------------------
-- Checks structure for table CorridaCalculo
-- ----------------------------
ALTER TABLE [aud].[CorridaCalculo] ADD CONSTRAINT [CK_aud_Corrida_Estado] CHECK ([Estado]='SIMULACION' OR [Estado]='ERROR' OR [Estado]='OK' OR [Estado]='EN_PROCESO')
GO


-- ----------------------------
-- Primary Key structure for table CorridaCalculo
-- ----------------------------
ALTER TABLE [aud].[CorridaCalculo] ADD CONSTRAINT [PK_aud_CorridaCalculo] PRIMARY KEY CLUSTERED ([IdCorrida])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Uniques structure for table CriterioCalculo
-- ----------------------------
ALTER TABLE [aud].[CriterioCalculo] ADD CONSTRAINT [UQ_aud_CriterioCalculo_Clave] UNIQUE NONCLUSTERED ([Clave] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table CriterioCalculo
-- ----------------------------
ALTER TABLE [aud].[CriterioCalculo] ADD CONSTRAINT [PK_aud_CriterioCalculo] PRIMARY KEY CLUSTERED ([IdCriterio])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Checks structure for table EmpresaAlcance
-- ----------------------------
ALTER TABLE [aud].[EmpresaAlcance] ADD CONSTRAINT [CK_aud_EmpresaAlcance_Mes] CHECK ([PrimerMes]>=(1) AND [PrimerMes]<=(12))
GO


-- ----------------------------
-- Primary Key structure for table EmpresaAlcance
-- ----------------------------
ALTER TABLE [aud].[EmpresaAlcance] ADD CONSTRAINT [PK_aud_EmpresaAlcance] PRIMARY KEY CLUSTERED ([IdEmpresa])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Indexes structure for table FirmaActivo
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_FirmaActivo_Activo]
ON [aud].[FirmaActivo] (
  [IdActivo] ASC,
  [IdCorrida] DESC
)
GO


-- ----------------------------
-- Primary Key structure for table FirmaActivo
-- ----------------------------
ALTER TABLE [aud].[FirmaActivo] ADD CONSTRAINT [PK_aud_FirmaActivo] PRIMARY KEY CLUSTERED ([IdCorrida], [IdActivo])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for LogFechaUso
-- ----------------------------
DBCC CHECKIDENT ('[aud].[LogFechaUso]', RESEED, 1)
GO


-- ----------------------------
-- Indexes structure for table LogFechaUso
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_LogFechaUso_Activo]
ON [aud].[LogFechaUso] (
  [IdActivo] ASC,
  [FechaOperacion] DESC
)
GO

CREATE NONCLUSTERED INDEX [IX_aud_LogFechaUso_Lote]
ON [aud].[LogFechaUso] (
  [Lote] ASC,
  [FechaOperacion] ASC
)
GO


-- ----------------------------
-- Checks structure for table LogFechaUso
-- ----------------------------
ALTER TABLE [aud].[LogFechaUso] ADD CONSTRAINT [CK_aud_LogFechaUso_Accion] CHECK ([Accion]='CORRECCION' OR [Accion]='REVERSION' OR [Accion]='CAPTURA' OR [Accion]='AJUSTE_DIA1' OR [Accion]='POBLADO_INICIAL')
GO


-- ----------------------------
-- Primary Key structure for table LogFechaUso
-- ----------------------------
ALTER TABLE [aud].[LogFechaUso] ADD CONSTRAINT [PK_aud_LogFechaUso] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for LogInpc
-- ----------------------------
DBCC CHECKIDENT ('[aud].[LogInpc]', RESEED, 1)
GO


-- ----------------------------
-- Primary Key structure for table LogInpc
-- ----------------------------
ALTER TABLE [aud].[LogInpc] ADD CONSTRAINT [PK__LogInpc__3214EC076AB81640] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Indexes structure for table PeriodoEstado
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_PeriodoEstado_Estado]
ON [aud].[PeriodoEstado] (
  [Estado] ASC
)
INCLUDE ([IdEmpresa], [Periodo], [Mes])
GO


-- ----------------------------
-- Checks structure for table PeriodoEstado
-- ----------------------------
ALTER TABLE [aud].[PeriodoEstado] ADD CONSTRAINT [CK_aud_PeriodoEstado_Mes] CHECK ([Mes]>=(1) AND [Mes]<=(12))
GO

ALTER TABLE [aud].[PeriodoEstado] ADD CONSTRAINT [CK_aud_PeriodoEstado_Estado] CHECK ([Estado]='REAPERTURA_AUTORIZADA' OR [Estado]='REAPERTURA_SOLICITADA' OR [Estado]='CERRADO' OR [Estado]='ABIERTO')
GO


-- ----------------------------
-- Primary Key structure for table PeriodoEstado
-- ----------------------------
ALTER TABLE [aud].[PeriodoEstado] ADD CONSTRAINT [PK_aud_PeriodoEstado] PRIMARY KEY CLUSTERED ([IdEmpresa], [Periodo], [Mes])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Checks structure for table RolUsuario
-- ----------------------------
ALTER TABLE [aud].[RolUsuario] ADD CONSTRAINT [CK_aud_RolUsuario_Rol] CHECK ([Rol]='ADMINISTRADOR' OR [Rol]='CONTADOR')
GO


-- ----------------------------
-- Primary Key structure for table RolUsuario
-- ----------------------------
ALTER TABLE [aud].[RolUsuario] ADD CONSTRAINT [PK_aud_RolUsuario] PRIMARY KEY CLUSTERED ([Usuario], [Rol], [IdEmpresa])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Indexes structure for table SnapshotCalculoDetalle
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_SnapshotCalculoDetalle_Activo]
ON [aud].[SnapshotCalculoDetalle] (
  [IdActivo] ASC,
  [IdCorrida] ASC
)
WITH (
  FILLFACTOR = 100
)
GO


-- ----------------------------
-- Primary Key structure for table SnapshotCalculoDetalle
-- ----------------------------
ALTER TABLE [aud].[SnapshotCalculoDetalle] ADD CONSTRAINT [PK_aud_SnapshotCalculoDetalle] PRIMARY KEY CLUSTERED ([IdCorrida], [IdActivo])
WITH (PAD_INDEX = OFF, FILLFACTOR = 100, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Indexes structure for table SnapshotCalculoMensual
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_SnapshotCalculoMensual_Activo]
ON [aud].[SnapshotCalculoMensual] (
  [IdActivo] ASC,
  [TipoContabilidad] ASC,
  [IdCorrida] ASC
)
WITH (
  FILLFACTOR = 100
)
GO


-- ----------------------------
-- Primary Key structure for table SnapshotCalculoMensual
-- ----------------------------
ALTER TABLE [aud].[SnapshotCalculoMensual] ADD CONSTRAINT [PK_aud_SnapshotCalculoMensual] PRIMARY KEY CLUSTERED ([IdCorrida], [IdActivo], [TipoContabilidad])
WITH (PAD_INDEX = OFF, FILLFACTOR = 100, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for SolicitudReapertura
-- ----------------------------
DBCC CHECKIDENT ('[aud].[SolicitudReapertura]', RESEED, 1)
GO


-- ----------------------------
-- Indexes structure for table SolicitudReapertura
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_aud_Solicitud_Pendientes]
ON [aud].[SolicitudReapertura] (
  [Estado] ASC,
  [FechaSolicitud] ASC
)
INCLUDE ([IdEmpresa], [Periodo], [Mes], [Solicitante])
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_aud_Solicitud_Viva]
ON [aud].[SolicitudReapertura] (
  [IdEmpresa] ASC,
  [Periodo] ASC,
  [Mes] ASC
)
WHERE ([Estado] IN ('PENDIENTE', 'AUTORIZADA'))
GO


-- ----------------------------
-- Checks structure for table SolicitudReapertura
-- ----------------------------
ALTER TABLE [aud].[SolicitudReapertura] ADD CONSTRAINT [CK_aud_Solicitud_Estado] CHECK ([Estado]='CANCELADA' OR [Estado]='VENCIDA' OR [Estado]='CONSUMIDA' OR [Estado]='RECHAZADA' OR [Estado]='AUTORIZADA' OR [Estado]='PENDIENTE')
GO

ALTER TABLE [aud].[SolicitudReapertura] ADD CONSTRAINT [CK_aud_Solicitud_Motivo_Largo] CHECK (len(ltrim(rtrim([Motivo])))>=(15))
GO


-- ----------------------------
-- Primary Key structure for table SolicitudReapertura
-- ----------------------------
ALTER TABLE [aud].[SolicitudReapertura] ADD CONSTRAINT [PK_aud_SolicitudReapertura] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Checks structure for table TipoDiferencia
-- ----------------------------
ALTER TABLE [aud].[TipoDiferencia] ADD CONSTRAINT [CK_aud_TipoDif_Nat] CHECK ([Naturaleza]='MIXTA' OR [Naturaleza]='PERMANENTE' OR [Naturaleza]='TEMPORAL')
GO

ALTER TABLE [aud].[TipoDiferencia] ADD CONSTRAINT [CK_aud_TipoDif_Est] CHECK ([Estado]='DESCARTADA' OR [Estado]='RESUELTA' OR [Estado]='ACEPTADA' OR [Estado]='EN_CONSULTA')
GO


-- ----------------------------
-- Primary Key structure for table TipoDiferencia
-- ----------------------------
ALTER TABLE [aud].[TipoDiferencia] ADD CONSTRAINT [PK_aud_TipoDiferencia] PRIMARY KEY CLUSTERED ([Clave])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Foreign Keys structure for table SnapshotCalculoDetalle
-- ----------------------------
ALTER TABLE [aud].[SnapshotCalculoDetalle] ADD CONSTRAINT [FK_aud_SnapshotCalculoDetalle_Corrida] FOREIGN KEY ([IdCorrida]) REFERENCES [aud].[CorridaCalculo] ([IdCorrida]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO


-- ----------------------------
-- Foreign Keys structure for table SnapshotCalculoMensual
-- ----------------------------
ALTER TABLE [aud].[SnapshotCalculoMensual] ADD CONSTRAINT [FK_aud_SnapshotCalculoMensual_Corrida] FOREIGN KEY ([IdCorrida]) REFERENCES [aud].[CorridaCalculo] ([IdCorrida]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO


-- ----------------------------
-- Foreign Keys structure for table SolicitudReapertura
-- ----------------------------
ALTER TABLE [aud].[SolicitudReapertura] ADD CONSTRAINT [FK_aud_Solicitud_Motivo] FOREIGN KEY ([ClaveMotivo]) REFERENCES [aud].[CatalogoMotivo] ([Clave]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO

