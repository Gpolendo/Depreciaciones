/*
 Navicat Premium Dump SQL

 Source Server         : NOMINA
 Source Server Type    : SQL Server
 Source Server Version : 15004430 (15.00.4430)
 Source Host           : GGP\PRUEBASRT:1433
 Source Catalog        : Deprecia
 Source Schema         : dbo

 Target Server Type    : SQL Server
 Target Server Version : 15004430 (15.00.4430)
 File Encoding         : 65001

 Date: 12/10/2026 23:34:40
*/


-- ----------------------------
-- Table structure for Activos
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[Activos]') AND type IN ('U'))
	DROP TABLE [dbo].[Activos]
GO

CREATE TABLE [dbo].[Activos] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [Identificador] varchar(255) COLLATE Modern_Spanish_CI_AS  NULL,
  [IdCatalogo] int  NOT NULL,
  [FechaAdquisicion] date  NOT NULL,
  [Descripcion] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [PorcentajeDepFIscalAnual] float(53)  NULL,
  [PorcentajeDepContableAnual] float(53)  NULL,
  [Moi] decimal(18,2)  NOT NULL,
  [MoiFiscal] decimal(18,2)  NOT NULL,
  [Baja] decimal(10,2) DEFAULT 0.00 NULL,
  [FechaBaja] date  NULL,
  [Convencional] tinyint DEFAULT 1 NOT NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL,
  [IdTemporal] int  NULL,
  [ValidoDesde] datetime2(3) DEFAULT sysutcdatetime() NOT NULL,
  [ValidoHasta] datetime2(3) DEFAULT CONVERT([datetime2](3),'9999-12-31 23:59:59.999') NOT NULL,
  [FechaUso] date  NULL
)
GO

ALTER TABLE [dbo].[Activos] SET (LOCK_ESCALATION = TABLE)
GO

EXEC sp_addextendedproperty
'MS_Description', N'Catalogo de cuentas',
'SCHEMA', N'dbo',
'TABLE', N'Activos',
'COLUMN', N'IdCatalogo'
GO


-- ----------------------------
-- Table structure for ActivosBaja
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivosBaja]') AND type IN ('U'))
	DROP TABLE [dbo].[ActivosBaja]
GO

CREATE TABLE [dbo].[ActivosBaja] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdEmpresa] int  NULL,
  [IdActivo] int  NOT NULL,
  [Identificador] varchar(50) COLLATE Modern_Spanish_CI_AS  NULL,
  [FechaVenta] date  NOT NULL,
  [NumFactura] nvarchar(40) COLLATE Modern_Spanish_CI_AS  NULL,
  [PrecioVenta] decimal(10,2)  NULL,
  [MesesUso] int  NULL,
  [IdPeriodo] int  NOT NULL,
  [IdMes] int  NULL,
  [FechaProcesado] date DEFAULT getdate() NOT NULL,
  [ImporteContableDepreciado] decimal(18,4)  NULL,
  [RemanenteContableDepreciar] decimal(18,4)  NULL,
  [UtilidadContable] decimal(18,4)  NULL,
  [PerdidaContable] decimal(18,4)  NULL,
  [ImporteFiscalDeducido] decimal(18,4)  NULL,
  [AniosDepreciacionFiscalDI] int  NULL,
  [PorcentajeFiscalDI] decimal(14,6)  NULL,
  [PorcentajeFiscalAplicarDI] decimal(14,6)  NULL,
  [MoiPorcentajeFiscalAplicarDI] decimal(14,6)  NULL,
  [RemanentePendienteDeducir] decimal(18,4)  NULL,
  [InpcUltimoMesMitadPeriodo] decimal(18,4)  NULL,
  [InpcFechaAdquisicion] decimal(18,4)  NULL,
  [FactoraAjuste] decimal(18,4)  NULL,
  [ValorActualizadoPendienteDeducir] decimal(18,4)  NULL,
  [UtilidadFiscalVenta] decimal(18,4)  NULL,
  [PerdidaFiscalVenta] decimal(18,4)  NULL,
  [MotivoBaja] varchar(255) COLLATE Modern_Spanish_CI_AS DEFAULT 'NA' NULL
)
GO

ALTER TABLE [dbo].[ActivosBaja] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for ActivosDetalle
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivosDetalle]') AND type IN ('U'))
	DROP TABLE [dbo].[ActivosDetalle]
GO

CREATE TABLE [dbo].[ActivosDetalle] (
  [IdDetalle] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [Serie] varchar(30) COLLATE Modern_Spanish_CI_AS  NULL,
  [Condicion] varchar(15) COLLATE Modern_Spanish_CI_AS  NULL,
  [Color] varchar(15) COLLATE Modern_Spanish_CI_AS  NULL,
  [ClaveVehicular] varchar(50) COLLATE Modern_Spanish_CI_AS  NULL,
  [Borrado] datetime DEFAULT getdate() NULL
)
GO

ALTER TABLE [dbo].[ActivosDetalle] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CalculoDetalle
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoDetalle]') AND type IN ('U'))
	DROP TABLE [dbo].[CalculoDetalle]
GO

CREATE TABLE [dbo].[CalculoDetalle] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
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
  [Factor_Ajuste] decimal(37,21)  NOT NULL,
  [Deduccion_Fiscal_Inv_Actualizado] decimal(18,2)  NOT NULL,
  [Convencional] tinyint  NOT NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL,
  [IdMes] int  NULL
)
GO

ALTER TABLE [dbo].[CalculoDetalle] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CalculoDetalle_Historico
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoDetalle_Historico]') AND type IN ('U'))
	DROP TABLE [dbo].[CalculoDetalle_Historico]
GO

CREATE TABLE [dbo].[CalculoDetalle_Historico] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
  [IdMes] int  NULL,
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
  [Convencional] tinyint  NOT NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL
)
GO

ALTER TABLE [dbo].[CalculoDetalle_Historico] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CalculoDetalle_HistoricoBajas
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoDetalle_HistoricoBajas]') AND type IN ('U'))
	DROP TABLE [dbo].[CalculoDetalle_HistoricoBajas]
GO

CREATE TABLE [dbo].[CalculoDetalle_HistoricoBajas] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
  [IdMes] int  NULL,
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
  [Convencional] tinyint  NOT NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL
)
GO

ALTER TABLE [dbo].[CalculoDetalle_HistoricoBajas] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CalculoMensual
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoMensual]') AND type IN ('U'))
	DROP TABLE [dbo].[CalculoMensual]
GO

CREATE TABLE [dbo].[CalculoMensual] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
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
  [Diciembre] decimal(18,2)  NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL,
  [TipoContabilidad] tinyint  NOT NULL,
  [IdMes] int  NULL
)
GO

ALTER TABLE [dbo].[CalculoMensual] SET (LOCK_ESCALATION = TABLE)
GO

EXEC sp_addextendedproperty
'MS_Description', N'1=Contable 0=Fiscal',
'SCHEMA', N'dbo',
'TABLE', N'CalculoMensual',
'COLUMN', N'TipoContabilidad'
GO


-- ----------------------------
-- Table structure for CalculoMensual_Historico
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoMensual_Historico]') AND type IN ('U'))
	DROP TABLE [dbo].[CalculoMensual_Historico]
GO

CREATE TABLE [dbo].[CalculoMensual_Historico] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [IdPeriodo] int  NOT NULL,
  [IdMes] int  NULL,
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
  [Diciembre] decimal(18,2)  NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL,
  [TipoContabilidad] tinyint  NOT NULL
)
GO

ALTER TABLE [dbo].[CalculoMensual_Historico] SET (LOCK_ESCALATION = TABLE)
GO

EXEC sp_addextendedproperty
'MS_Description', N'1=Contable 0=Fiscal',
'SCHEMA', N'dbo',
'TABLE', N'CalculoMensual_Historico',
'COLUMN', N'TipoContabilidad'
GO


-- ----------------------------
-- Table structure for CatalogoCuentas
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CatalogoCuentas]') AND type IN ('U'))
	DROP TABLE [dbo].[CatalogoCuentas]
GO

CREATE TABLE [dbo].[CatalogoCuentas] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [Grupo] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Porcentaje] decimal(10,2)  NULL,
  [PorcentajeMaximo] decimal(10,2)  NULL
)
GO

ALTER TABLE [dbo].[CatalogoCuentas] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CatalogoMes
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CatalogoMes]') AND type IN ('U'))
	DROP TABLE [dbo].[CatalogoMes]
GO

CREATE TABLE [dbo].[CatalogoMes] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [Fecha] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL
)
GO

ALTER TABLE [dbo].[CatalogoMes] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CatalogoPeriodo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CatalogoPeriodo]') AND type IN ('U'))
	DROP TABLE [dbo].[CatalogoPeriodo]
GO

CREATE TABLE [dbo].[CatalogoPeriodo] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [Periodo] int  NOT NULL
)
GO

ALTER TABLE [dbo].[CatalogoPeriodo] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for CatalogoPorcentajes
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CatalogoPorcentajes]') AND type IN ('U'))
	DROP TABLE [dbo].[CatalogoPorcentajes]
GO

CREATE TABLE [dbo].[CatalogoPorcentajes] (
  [IdPorcentaje] int  IDENTITY(1,1) NOT NULL,
  [IdCatCuenta] int  NOT NULL,
  [Descripcion] varchar(255) COLLATE Modern_Spanish_CI_AS  NULL,
  [Porcentaje] decimal(10,2)  NOT NULL,
  [TipoDepreciacion] int  NOT NULL,
  [PeriodoFiscal] int  NULL,
  [DescripcionCompleta] text COLLATE Modern_Spanish_CI_AS  NULL
)
GO

ALTER TABLE [dbo].[CatalogoPorcentajes] SET (LOCK_ESCALATION = TABLE)
GO

EXEC sp_addextendedproperty
'MS_Description', N'El estímulo consiste en optar por efectuar la deducción inmediata de la inversión en bienes nuevos de activo fijo, adquiridos a partir de la fecha de entrada en vigor del presente decreto y hasta el 30 de septiembre de 2030,
 deduciendo en el ejercicio en el que se realice la inversión la cantidad que resulte de aplicar al monto original de la inversión, únicamente los por cientos que se establecen en el artículo Segundo de este decreto, 
en lugar de los señalados en los artículos 34, 35 y 209, apartados B y C de la Ley del Impuesto sobre la Renta, según corresponda.


TIPOS DEPRECIACION

0=Inmediata
1=Convencional',
'SCHEMA', N'dbo',
'TABLE', N'CatalogoPorcentajes'
GO


-- ----------------------------
-- Table structure for CatalogoRegimen
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CatalogoRegimen]') AND type IN ('U'))
	DROP TABLE [dbo].[CatalogoRegimen]
GO

CREATE TABLE [dbo].[CatalogoRegimen] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [Regimen] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Clasificacion] varchar(15) COLLATE Modern_Spanish_CI_AS  NOT NULL
)
GO

ALTER TABLE [dbo].[CatalogoRegimen] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for Empresas
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[Empresas]') AND type IN ('U'))
	DROP TABLE [dbo].[Empresas]
GO

CREATE TABLE [dbo].[Empresas] (
  [Id] int  IDENTITY(5,1) NOT NULL,
  [RFC] nvarchar(14) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Empresa] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [FechaCreacion] datetime DEFAULT getdate() NOT NULL,
  [FechaBaja] date  NULL
)
GO

ALTER TABLE [dbo].[Empresas] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for Inpc
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[Inpc]') AND type IN ('U'))
	DROP TABLE [dbo].[Inpc]
GO

CREATE TABLE [dbo].[Inpc] (
  [Idnpc] int  IDENTITY(1,1) NOT NULL,
  [Fecha] date  NOT NULL,
  [Inpc] decimal(10,4)  NOT NULL,
  [EsProvisional] bit DEFAULT 0 NOT NULL,
  [FechaPublicacion] date  NULL,
  [Fuente] nvarchar(100) COLLATE Modern_Spanish_CI_AS  NULL,
  [Nota] nvarchar(300) COLLATE Modern_Spanish_CI_AS  NULL,
  [FechaCaptura] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [UsuarioCaptura] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL
)
GO

ALTER TABLE [dbo].[Inpc] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for Log_ReversionBajas
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[Log_ReversionBajas]') AND type IN ('U'))
	DROP TABLE [dbo].[Log_ReversionBajas]
GO

CREATE TABLE [dbo].[Log_ReversionBajas] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [FechaOperacion] datetime2(3) DEFAULT sysdatetime() NOT NULL,
  [IdBaja] int  NOT NULL,
  [IdActivo] int  NOT NULL,
  [FechaBajaOriginal] date  NULL,
  [MotivoBajaOriginal] nvarchar(500) COLLATE Modern_Spanish_CI_AS  NULL,
  [Resultado] bit  NOT NULL,
  [Mensaje] nvarchar(500) COLLATE Modern_Spanish_CI_AS  NULL,
  [UsuarioSQL] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT suser_sname() NOT NULL,
  [HostName] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT host_name() NOT NULL,
  [AppName] nvarchar(128) COLLATE Modern_Spanish_CI_AS DEFAULT app_name() NOT NULL
)
GO

ALTER TABLE [dbo].[Log_ReversionBajas] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for Sujetos_Informacion
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[Sujetos_Informacion]') AND type IN ('U'))
	DROP TABLE [dbo].[Sujetos_Informacion]
GO

CREATE TABLE [dbo].[Sujetos_Informacion] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [Id_Empresa] int  NOT NULL,
  [Id_TipoSujeto] int  NOT NULL,
  [RFC] nvarchar(13) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [CURP] nvarchar(18) COLLATE Modern_Spanish_CI_AS  NULL,
  [RazonSocial] nvarchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [PorcentajeAcciones] decimal(18,4)  NULL,
  [EsExtranjero] bit DEFAULT 0 NULL,
  [CreatedAt] datetime DEFAULT getdate() NULL
)
GO

ALTER TABLE [dbo].[Sujetos_Informacion] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- Table structure for Usuarios
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[Usuarios]') AND type IN ('U'))
	DROP TABLE [dbo].[Usuarios]
GO

CREATE TABLE [dbo].[Usuarios] (
  [Email] nvarchar(256) COLLATE Modern_Spanish_CI_AS  NULL,
  [ContrasenaHash] nvarchar(max) COLLATE Modern_Spanish_CI_AS  NULL,
  [creacion] datetime DEFAULT getdate() NULL,
  [borrado] datetime  NULL,
  [Id] int  NULL
)
GO

ALTER TABLE [dbo].[Usuarios] SET (LOCK_ESCALATION = TABLE)
GO


-- ----------------------------
-- procedure structure for CalculosMensuales
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculosMensuales]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[CalculosMensuales]
GO

CREATE PROCEDURE [dbo].[CalculosMensuales]
    @Fechafinal       DATE,
    @EjercicioVigente VARCHAR(4),
    @IdEmpresa        INT
AS
BEGIN

SET LANGUAGE 'Spanish';
DECLARE @contador    INT        = 1;
DECLARE @contadorfin INT        = 12;
DECLARE @MesLstday   VARCHAR(10);
DECLARE @MesCurrent  VARCHAR(30);
DECLARE @MesCa       INT        = MONTH(@Fechafinal);
DECLARE @Anio        VARCHAR(5) = YEAR(@Fechafinal);
DECLARE @Anioint     INT        = YEAR(@Fechafinal);

-- [ CONTABLE MENSUAL ]
TRUNCATE TABLE MensualConvencionalContable;
INSERT INTO MensualConvencionalContable (id)
/*SELECT id FROM Activos WHERE IdEmpresa = @IdEmpresa;*/
SELECT DISTINCT Id FROM CalculoFinalConvencional;

UPDATE CatalogoMes
SET Fecha = CASE
    WHEN (@Anioint % 4 = 0 AND @Anioint % 100 != 0) OR (@Anioint % 400 = 0) THEN
        CASE WHEN Id = 2 THEN '02/29' END
    ELSE '02/28'
END
WHERE Id = 2;

SET @Anio = CONCAT(@Anio, '/');

WHILE @contador <= @contadorfin
BEGIN
    SET @MesLstday  = CONCAT(@Anio, (SELECT Fecha FROM CatalogoMes WHERE Id = @contador));
    SET @MesCurrent = DATENAME(month, @MesLstday);

    SELECT FechaAdquisicion, Id,
    CASE WHEN ISNULL(Porcentaje_Dep_Contable_Anual, 0) > 0 THEN
        CASE WHEN
            Moi = DeduccionContableInvHistorico
            OR FechaAdquisicion > @MesLstday
            -- FIX-CALCULOSMENSUALES-PENDIENTE-9: comparar fecha completa, no solo el anio
            OR (FechaBaja IS NOT NULL AND FechaBaja <= @MesLstday)
            OR ((12 - MONTH(FechaAdquisicion) + ((YEAR(@MesLstday) - YEAR(FechaAdquisicion) - 1) * 12) + @contador)
                -- >>> FIX DIV/0: NULLIF evita division por cero cuando pct = 0
                > ROUND((((100 / NULLIF(ISNULL(Porcentaje_Dep_Contable_Anual, 0), 0)) * 12) / 100), 2))
            OR Meses_Efectivos_Contables = 0
            OR (YEAR(FechaAdquisicion) = @EjercicioVigente AND @contador = MONTH(FechaAdquisicion))
        THEN 0
        ELSE
            -- FIX-CALCULOSMENSUALES-PENDIENTE-10: tope al saldo pendiente en el
            -- ultimo mes de vida util (patron FIX-C, sin caso real para validar hoy)
            CASE
                WHEN (ISNULL(DeduccionContableInvHistorico, 0)
                      + ((Moi * ISNULL(Porcentaje_Dep_Contable_Anual, 0)) / 12) * @contador) > Moi
                    THEN
                        CASE
                            WHEN (Moi - ISNULL(DeduccionContableInvHistorico, 0)
                                  - ((Moi * ISNULL(Porcentaje_Dep_Contable_Anual, 0)) / 12) * (@contador - 1)) > 0
                                THEN (Moi - ISNULL(DeduccionContableInvHistorico, 0)
                                      - ((Moi * ISNULL(Porcentaje_Dep_Contable_Anual, 0)) / 12) * (@contador - 1))
                            ELSE 0
                        END
                ELSE (Moi * ISNULL(Porcentaje_Dep_Contable_Anual, 0)) / 12
            END
        END
    ELSE 0   -- FIX-CALCULOSMENSUALES-PENDIENTE-1: Pct=0/NULL -> 0, no NULL
    END AS Mesx
    INTO Tmpmensual
    FROM [dbo].[CalculoFinalConvencional];

    UPDATE MensualConvencionalContable
    SET
        Enero      = CASE WHEN @contador =  1 THEN TMS.Mesx ELSE Enero      END,
        Febrero    = CASE WHEN @contador =  2 THEN TMS.Mesx ELSE Febrero    END,
        Marzo      = CASE WHEN @contador =  3 THEN TMS.Mesx ELSE Marzo      END,
        Abril      = CASE WHEN @contador =  4 THEN TMS.Mesx ELSE Abril      END,
        Mayo       = CASE WHEN @contador =  5 THEN TMS.Mesx ELSE Mayo       END,
        Junio      = CASE WHEN @contador =  6 THEN TMS.Mesx ELSE Junio      END,
        Julio      = CASE WHEN @contador =  7 THEN TMS.Mesx ELSE Julio      END,
        Agosto     = CASE WHEN @contador =  8 THEN TMS.Mesx ELSE Agosto     END,
        Septiembre = CASE WHEN @contador =  9 THEN TMS.Mesx ELSE Septiembre END,
        Octubre    = CASE WHEN @contador = 10 THEN TMS.Mesx ELSE Octubre    END,
        Noviembre  = CASE WHEN @contador = 11 THEN TMS.Mesx ELSE Noviembre  END,
        Diciembre  = CASE WHEN @contador = 12 THEN TMS.Mesx ELSE Diciembre  END
    FROM Tmpmensual TMS
    INNER JOIN MensualConvencionalContable CMC ON CMC.Id = TMS.id;

    SET @contador = @contador + 1;
    DROP TABLE IF EXISTS Tmpmensual;
END;

-- [ FISCAL MENSUAL ]
BEGIN
    SET @contador = 1;
    TRUNCATE TABLE MensualConvencionalFiscal;
    INSERT INTO MensualConvencionalFiscal (id)
    SELECT DISTINCT Id FROM CalculoFinalConvencional
    /*SELECT id FROM Activos WHERE IdEmpresa = @IdEmpresa;*/

    UPDATE CatalogoMes
    SET Fecha = CASE
        WHEN (@Anioint % 4 = 0 AND @Anioint % 100 != 0) OR (@Anioint % 400 = 0) THEN
            CASE WHEN Id = 2 THEN '02/29' END
        ELSE '02/28'
    END
    WHERE Id = 2;

    WHILE @contador <= @contadorfin
    BEGIN
        SET @MesLstday  = CONCAT(@Anio, (SELECT Fecha FROM CatalogoMes WHERE Id = @contador));
        SET @MesCurrent = DATENAME(month, @MesLstday);

        SELECT FechaAdquisicion, Id,
        CASE WHEN ISNULL(Porcentaje_Dep_Fiscal_Anual, 0) > 0 THEN
            CASE WHEN
                -- FIX-CALCULOSMENSUALES-PENDIENTE-5: comparar contra el acumulado FISCAL, no el contable
                MoiFiscal = DeduccionFiscalInvHistorico
                OR FechaAdquisicion > @MesLstday
                -- FIX-CALCULOSMENSUALES-PENDIENTE-9: comparar fecha completa, no solo el anio
                OR (FechaBaja IS NOT NULL AND FechaBaja <= @MesLstday)
                OR ((12 - MONTH(FechaAdquisicion) + ((YEAR(@MesLstday) - YEAR(FechaAdquisicion) - 1) * 12) + @contador)
                    -- >>> FIX DIV/0: NULLIF evita division por cero cuando pct = 0
                    -- >>> FIX-CALCULOSMENSUALES-PENDIENTE-3: usar el porcentaje FISCAL, no el contable
                    > ROUND((((100 / NULLIF(ISNULL(Porcentaje_Dep_Fiscal_Anual, 0), 0)) * 12) / 100), 2))
                -- FIX-CALCULOSMENSUALES-PENDIENTE-8: usar meses efectivos FISCALES, no contables
                OR Meses_Efectivos_Fiscales = 0
                OR (YEAR(FechaAdquisicion) = @EjercicioVigente AND @contador = MONTH(FechaAdquisicion))
            THEN 0
            ELSE
                -- FIX-CALCULOSMENSUALES-PENDIENTE-10: tope al saldo pendiente en el
                -- ultimo mes de vida util (patron FIX-C, sin caso real para validar hoy)
                CASE
                    WHEN (ISNULL(DeduccionFiscalInvHistorico, 0)
                          + ((MoiFiscal * ISNULL(Porcentaje_Dep_Fiscal_Anual, 0)) / 12) * @contador) > MoiFiscal
                        THEN
                            CASE
                                WHEN (MoiFiscal - ISNULL(DeduccionFiscalInvHistorico, 0)
                                      - ((MoiFiscal * ISNULL(Porcentaje_Dep_Fiscal_Anual, 0)) / 12) * (@contador - 1)) > 0
                                    THEN (MoiFiscal - ISNULL(DeduccionFiscalInvHistorico, 0)
                                          - ((MoiFiscal * ISNULL(Porcentaje_Dep_Fiscal_Anual, 0)) / 12) * (@contador - 1))
                                ELSE 0
                            END
                    ELSE (MoiFiscal * ISNULL(Porcentaje_Dep_Fiscal_Anual, 0)) / 12
                END
            END
        ELSE 0   -- FIX-CALCULOSMENSUALES-PENDIENTE-1: Pct=0/NULL -> 0, no NULL
        END AS Mesx
        INTO Tmpmensual
        FROM [dbo].[CalculoFinalConvencional];

        UPDATE MensualConvencionalFiscal
        SET
            Enero      = CASE WHEN @contador =  1 THEN TMS.Mesx ELSE Enero      END,
            Febrero    = CASE WHEN @contador =  2 THEN TMS.Mesx ELSE Febrero    END,
            Marzo      = CASE WHEN @contador =  3 THEN TMS.Mesx ELSE Marzo      END,
            Abril      = CASE WHEN @contador =  4 THEN TMS.Mesx ELSE Abril      END,
            Mayo       = CASE WHEN @contador =  5 THEN TMS.Mesx ELSE Mayo       END,
            Junio      = CASE WHEN @contador =  6 THEN TMS.Mesx ELSE Junio      END,
            Julio      = CASE WHEN @contador =  7 THEN TMS.Mesx ELSE Julio      END,
            Agosto     = CASE WHEN @contador =  8 THEN TMS.Mesx ELSE Agosto     END,
            Septiembre = CASE WHEN @contador =  9 THEN TMS.Mesx ELSE Septiembre END,
            Octubre    = CASE WHEN @contador = 10 THEN TMS.Mesx ELSE Octubre    END,
            Noviembre  = CASE WHEN @contador = 11 THEN TMS.Mesx ELSE Noviembre  END,
            Diciembre  = CASE WHEN @contador = 12 THEN TMS.Mesx ELSE Diciembre  END
        FROM Tmpmensual TMS
        INNER JOIN MensualConvencionalFiscal CMC ON CMC.Id = TMS.id;

        SET @contador = @contador + 1;
        DROP TABLE IF EXISTS Tmpmensual;
    END;
END

EXEC dbo.InsercionFinal
    @Periodo   = @EjercicioVigente,
    @IdEmpresa = @IdEmpresa,
    @Mes       = @MesCa;

END
GO


-- ----------------------------
-- procedure structure for sp_ReporteDepreciacion_Vigentes
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ReporteDepreciacion_Vigentes]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[sp_ReporteDepreciacion_Vigentes]
GO

CREATE PROCEDURE [dbo].[sp_ReporteDepreciacion_Vigentes]
    @Periodo      VARCHAR(10),
    @Mes          INT,
    @RFC          VARCHAR(20) = NULL,
    @IdEmpresa    INT         = NULL,
    @Convencional TINYINT     = 1,
    @Origen       VARCHAR(10) = 'HISTORICO'   -- 'HISTORICO' | 'VIVO'
AS
BEGIN
    SET NOCOUNT ON;

    -- Se identifica la empresa por @IdEmpresa (preferente) o por @RFC.
    IF @IdEmpresa IS NULL AND @RFC IS NULL
    BEGIN
        RAISERROR('Debe indicar @IdEmpresa o @RFC.', 16, 1);
        RETURN;
    END

    IF @Origen NOT IN ('HISTORICO','VIVO')
    BEGIN
        RAISERROR('@Origen debe ser HISTORICO o VIVO.', 16, 1);
        RETURN;
    END

    -- =================================================================
    -- ORIGEN DE DATOS
    -- 'HISTORICO' -> CalculoDetalle_Historico (cierre ya guardado)
    -- 'VIVO'      -> CalculoDetalle           (ultimo calculo corrido)
    -- Ambas tablas tienen las MISMAS columnas, asi que se vuelcan a
    -- #CFC y de ahi en adelante la consulta es una sola.
    --
    -- En 'VIVO' el periodo y el mes se DERIVAN de los datos, porque el
    -- front no los conoce al pintar el calculo en curso. Los parametros
    -- @Periodo y @Mes se ignoran en ese modo.
    -- =================================================================
    DROP TABLE IF EXISTS #CFC;

    CREATE TABLE #CFC (
        IdActivo                            INT,
        IdEmpresa                           INT,
        IdPeriodo                           INT,
        IdMes                               INT,
        Convencional                        TINYINT,
        Moi                                 DECIMAL(18,2),
        MoiFiscal                           DECIMAL(18,2),
        FechaBaja                           DATE,
        DeduccionContableInvHistorico       DECIMAL(18,2),
        SaldoContablePorDeducir             DECIMAL(18,2),
        DepreciacionContableInversionAnual  DECIMAL(18,2),
        DepreciacionContableAcumulado       DECIMAL(18,2),
        DeduccionFiscalInvHistorico         DECIMAL(18,2),
        SaldoFiscalPorDeducir               DECIMAL(18,2),
        DepreciacionFiscalInversionAnual    DECIMAL(18,2),
        DepreciacionFiscalAcumulado         DECIMAL(18,2),
        Deduccion_Fiscal_Inv_Actualizado    DECIMAL(18,2)
    );

    IF @Origen = 'VIVO'
    BEGIN
        INSERT INTO #CFC
        SELECT CD.IdActivo, CD.IdEmpresa, CD.IdPeriodo, CD.IdMes, CD.Convencional,
               CD.Moi, CD.MoiFiscal, CD.FechaBaja,
               CD.DeduccionContableInvHistorico, CD.SaldoContablePorDeducir,
               CD.DepreciacionContableInversionAnual, CD.DepreciacionContableAcumulado,
               CD.DeduccionFiscalInvHistorico, CD.SaldoFiscalPorDeducir,
               CD.DepreciacionFiscalInversionAnual, CD.DepreciacionFiscalAcumulado,
               CD.Deduccion_Fiscal_Inv_Actualizado
        FROM [dbo].[CalculoDetalle] CD
        INNER JOIN [dbo].[Activos]  AD ON CD.IdActivo  = AD.Id
        INNER JOIN [dbo].[Empresas] EM ON AD.IdEmpresa = EM.Id
        WHERE CD.Convencional = @Convencional
          AND ((@IdEmpresa IS NOT NULL AND AD.IdEmpresa = @IdEmpresa)
            OR (@IdEmpresa IS NULL     AND EM.RFC       = @RFC));

        -- Periodo y mes reales del calculo vivo
        SELECT @Periodo = CAST(CPE.Periodo AS VARCHAR(10))
        FROM [dbo].[CatalogoPeriodo] CPE
        WHERE CPE.Id = (SELECT MAX(IdPeriodo) FROM #CFC);

        SELECT @Mes = ISNULL(MAX(IdMes), 12) FROM #CFC;
    END
    ELSE
    BEGIN
        INSERT INTO #CFC
        SELECT CD.IdActivo, CD.IdEmpresa, CD.IdPeriodo, CD.IdMes, CD.Convencional,
               CD.Moi, CD.MoiFiscal, CD.FechaBaja,
               CD.DeduccionContableInvHistorico, CD.SaldoContablePorDeducir,
               CD.DepreciacionContableInversionAnual, CD.DepreciacionContableAcumulado,
               CD.DeduccionFiscalInvHistorico, CD.SaldoFiscalPorDeducir,
               CD.DepreciacionFiscalInversionAnual, CD.DepreciacionFiscalAcumulado,
               CD.Deduccion_Fiscal_Inv_Actualizado
        FROM [dbo].[CalculoDetalle_Historico] CD
        INNER JOIN [dbo].[Activos]         AD  ON CD.IdActivo  = AD.Id
        INNER JOIN [dbo].[Empresas]        EM  ON AD.IdEmpresa = EM.Id
        INNER JOIN [dbo].[CatalogoPeriodo] CPX ON CD.IdPeriodo = CPX.Id
        WHERE CD.Convencional = @Convencional
          AND CPX.Periodo = @Periodo
          AND CD.IdMes    = @Mes
          AND ((@IdEmpresa IS NOT NULL AND AD.IdEmpresa = @IdEmpresa)
            OR (@IdEmpresa IS NULL     AND EM.RFC       = @RFC));
    END

    DECLARE @IdPeriodo    INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = CAST(@Periodo AS INT));
    DECLARE @IdPeriodoAnt INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = CAST(@Periodo AS INT) - 1);

    -- Ultimo dia del mes consultado. Una baja se considera YA OCURRIDA
    -- solo si su fecha real es <= este corte. Comparar por fecha completa
    -- (no solo por MONTH) es indispensable para consultar ejercicios
    -- anteriores: un activo con baja en 2026 estaba VIGENTE en 2024.
    DECLARE @Corte DATE = EOMONTH(DATEFROMPARTS(CAST(@Periodo AS INT), @Mes, 1));

    -- =============================================
    -- Bajas: todos los activos dados de baja
    -- en el ejercicio @Periodo, en meses <= @Mes.
    -- Se toma el registro congelado del mes
    -- inmediato anterior al mes de baja.
    -- Caso borde: baja en enero -> periodo anterior.
    -- =============================================
    DROP TABLE IF EXISTS #BajasRecientes;

    SELECT CDHB.*
    INTO #BajasRecientes
    FROM [dbo].[CalculoDetalle_Historico] CDHB
    INNER JOIN [dbo].[Activos]  ADE ON CDHB.IdActivo = ADE.Id
    INNER JOIN [dbo].[Empresas] EMP ON ADE.IdEmpresa = EMP.Id
    WHERE ((@IdEmpresa IS NOT NULL AND ADE.IdEmpresa = @IdEmpresa)
        OR (@IdEmpresa IS NULL     AND EMP.RFC       = @RFC))
      AND CDHB.Convencional = @Convencional
      AND ADE.FechaBaja IS NOT NULL
      AND YEAR(ADE.FechaBaja)  = CAST(@Periodo AS INT)
      AND MONTH(ADE.FechaBaja) <= @Mes
      -- Registro congelado del mes ANTERIOR al mes de baja
      AND CDHB.IdPeriodo = CASE WHEN MONTH(ADE.FechaBaja) = 1
                                THEN @IdPeriodoAnt
                                ELSE @IdPeriodo
                           END
      AND CDHB.IdMes     = CASE WHEN MONTH(ADE.FechaBaja) = 1
                                THEN 12
                                ELSE MONTH(ADE.FechaBaja) - 1
                           END;

    -- =============================================
    -- Consulta principal
    -- =============================================
    SELECT
        CAC.Grupo AS Descripcion,

        -- MOI: activos vivos del mes + MOI de bajas del periodo actual
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte) THEN CFC.Moi ELSE 0 END)
                                                                                        AS Moi,

        -- Baja: MOI de las bajas YA OCURRIDAS al mes consultado.
        -- Se usa ADE.FechaBaja (fecha real) para no anticipar bajas
        -- futuras en los meses previos.
        SUM(CASE WHEN ADE.FechaBaja IS NOT NULL
                      AND YEAR(ADE.FechaBaja) = CAST(@Periodo AS INT)
                      AND ADE.FechaBaja      <= @Corte
                 THEN CFC.Moi ELSE 0 END)
                                                                                        AS Baja,

        -- FIX-NULL-TERRENOS: ISNULL para que terrenos devuelvan 0 en lugar de NULL
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DeduccionContableInvHistorico, 0) ELSE 0 END)
                                                                                        AS DeduccionContableHistorica,

        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.SaldoContablePorDeducir, 0) ELSE 0 END)
                                                                                        AS SaldoContableMoiDeducir,

        -- Depreciacion contable anual
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DepreciacionContableInversionAnual, 0) ELSE 0 END)
                                                                                        AS DepreciacionContableInversionAnual,

        -- =========================================================
        -- ACUMULADO CONTABLE -- criterio de vigentes puro.
        -- A diferencia de sp_ReporteDepreciacion (criterio Excel, donde
        -- solo ESTA columna excluye las bajas), aqui las bajas quedan
        -- fuera de TODAS las columnas, asi que esta no es un caso
        -- especial: sigue la misma regla que las demas.
        SUM(CASE WHEN ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte
                 THEN ISNULL(CFC.DepreciacionContableAcumulado, 0)
                 ELSE 0 END)
                                                                                        AS DepreciacionContableAcumuladoEjercicio,

        -- FIX-NULL-TERRENOS: historico fiscal
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DeduccionFiscalInvHistorico, 0) ELSE 0 END)
                                                                                        AS DeduccionFiscalHistorica,

        -- FIX-NULL-TERRENOS: saldo fiscal
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.SaldoFiscalPorDeducir, 0) ELSE 0 END)
                                                                                        AS SaldoFiscalMoiDeducir,

        -- Depreciacion fiscal anual
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DepreciacionFiscalInversionAnual, 0) ELSE 0 END)
                                                                                        AS DepreciacionFiscalInversionAnual,

        -- =========================================================
        -- ACUMULADO FISCAL -- criterio de vigentes puro.
        -- OJO: en sp_ReporteDepreciacion esta columna SI suma las bajas
        -- (=SUMA simple del Excel 2024). Aqui NO. Esa es la diferencia
        -- visible mas grande entre las dos vistas.
        SUM(CASE WHEN ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte
                 THEN ISNULL(CFC.DepreciacionFiscalAcumulado, 0)
                 ELSE 0 END)
                                                                                        AS DepreciacionFiscalAcumuladoEjercicio,

        -- Deduccion fiscal actualizada (INPC)
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.Deduccion_Fiscal_Inv_Actualizado, 0) ELSE 0 END)
                                                                                        AS DeduccionFiscalActualizadoAnual

    FROM #CFC CFC
    -- FIX-UNIVERSO: condicion en el JOIN para que RIGHT JOIN no interfiera
    INNER JOIN [dbo].[Activos] ADE ON CFC.IdActivo = ADE.Id
        AND (ADE.FechaBaja IS NULL
             OR YEAR(ADE.FechaBaja) >= CAST(@Periodo AS INT))
    INNER JOIN [dbo].[Empresas]        EMP ON ADE.IdEmpresa  = EMP.Id
    RIGHT JOIN [dbo].[CatalogoCuentas] CAC ON ADE.IdCatalogo = CAC.Id
    -- El filtro de empresa, convencional, periodo y mes ya se aplico
    -- al poblar #CFC.
    --
    -- Este WHERE descarta los grupos del catalogo que no tienen ningun
    -- activo en #CFC. Es indispensable: al mover los filtros al poblado
    -- de #CFC el WHERE quedo vacio y el RIGHT JOIN empezo a devolver el
    -- catalogo COMPLETO con renglones en 0.00. Antes las condiciones
    -- sobre CFC en el WHERE convertian de hecho el RIGHT JOIN en INNER.
    WHERE CFC.IdActivo IS NOT NULL
    GROUP BY CAC.Grupo
    ORDER BY CAC.Grupo ASC;

    DROP TABLE IF EXISTS #BajasRecientes;
    DROP TABLE IF EXISTS #CFC;
END
GO


-- ----------------------------
-- procedure structure for InsercionFinal
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[InsercionFinal]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[InsercionFinal]
GO

CREATE PROCEDURE [dbo].[InsercionFinal]
  @Periodo INT, @IdEmpresa INT, @Mes INT,@UsuarioApp NVARCHAR(128) = NULL
AS

 -- AUDITORIA: abre la bitacora. Si falla, devuelve NULL y el
 -- calculo continua igual.
 DECLARE @IdCorrida BIGINT;
 EXEC aud.sp_CorridaIniciar
      @IdEmpresa  = @IdEmpresa,
      @Periodo    = @Periodo,
      @Mes        = @Mes,
      @UsuarioApp = @UsuarioApp,
      @IdCorrida  = @IdCorrida OUTPUT;

DECLARE @IdPeriodo INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = @Periodo);
DECLARE @ExisteCalculo INT;
DECLARE @ExisteHistorico INT;

BEGIN

-- FIX-ARRASTRE [1]: si el periodo no existe en el catalogo, @IdPeriodo queda
-- NULL y el procedimiento escribe filas inalcanzables por cualquier DELETE
-- posterior. Abortar es preferible a corromper el cierre en silencio.
IF @IdPeriodo IS NULL
BEGIN
    RAISERROR('InsercionFinal: el periodo %d no existe en CatalogoPeriodo.', 16, 1, @Periodo);
    RETURN;
END

IF @IdEmpresa IS NULL OR @Mes IS NULL
BEGIN
    RAISERROR('InsercionFinal: @IdEmpresa y @Mes son obligatorios.', 16, 1);
    RETURN;
END


-- FIX-CONCURRENCIA: antes era TRUNCATE, que vaciaba la tabla COMPLETA
-- sin importar la empresa. Si dos usuarios calculaban a la vez, el
-- segundo borraba lo que el primero acababa de generar y la pantalla
-- del primero quedaba vacia o con datos ajenos.
-- Se borra SOLO lo de la empresa que se esta calculando.
DELETE FROM CalculoMensual WHERE IdEmpresa = @IdEmpresa;

/*INSERCION EN CALCULO MENSUAL*/
INSERT INTO CalculoMensual (
IdActivo, IdEmpresa, IdPeriodo, IdMes,
Enero, Febrero, Marzo, Abril, Mayo, Junio,
Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
TipoContabilidad
) SELECT
ACT.Id, ACT.IdEmpresa, @IdPeriodo, @Mes,
Enero, Febrero, Marzo, Abril, Mayo, Junio,
Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre, 1
FROM MensualConvencionalContable MC
INNER JOIN Activos ACT ON MC.Id = ACT.Id
WHERE ACT.IdEmpresa = @IdEmpresa;

INSERT INTO CalculoMensual (
IdActivo, IdEmpresa, IdPeriodo, IdMes,
Enero, Febrero, Marzo, Abril, Mayo, Junio,
Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
TipoContabilidad
) SELECT
ACT.Id, ACT.IdEmpresa, @IdPeriodo, @Mes,
Enero, Febrero, Marzo, Abril, Mayo, Junio,
Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre, 0
FROM MensualConvencionalFiscal MCF
INNER JOIN Activos ACT ON MCF.Id = ACT.Id
WHERE ACT.IdEmpresa = @IdEmpresa;


IF EXISTS (SELECT * FROM sys.all_objects
           WHERE object_id = OBJECT_ID(N'[dbo].[ActivosBajas]') AND type IN ('U'))
BEGIN
    -- Inserción de bajas de activos definitiva
    INSERT INTO ActivosBaja (IdActivo, Identificador, FechaVenta, NumFactura, PrecioVenta, MesesUso, FechaProcesado, IdPeriodo, IdEmpresa)
    SELECT IdActivo, Identificador, FechaVenta, NumFactura, PrecioVenta, MesesUso, FechaProcesado, @IdPeriodo, @IdEmpresa
    FROM ActivosBajas
    WHERE IdEmpresa = @IdEmpresa;

    -- Actualización de la tabla ActivosBaja
    UPDATE ABAF
    SET ABAF.IdActivo = ACT.Id
    FROM Activos ACT
    INNER JOIN ActivosBaja ABAF ON ACT.Identificador = ABAF.Identificador
    WHERE ACT.IdEmpresa = @IdEmpresa AND ABAF.IdEmpresa = @IdEmpresa;
END
ELSE
BEGIN
    -- Solo la actualización en caso de que no exista la tabla
    UPDATE ABAF
    SET ABAF.IdActivo = ACT.Id
    FROM Activos ACT
    INNER JOIN ActivosBaja ABAF ON ACT.Identificador = ABAF.Identificador
    WHERE ACT.IdEmpresa = @IdEmpresa AND ABAF.IdEmpresa = @IdEmpresa;
END


-- FIX-CONCURRENCIA: mismo caso que CalculoMensual.
-- OJO: CalculoDetalle.IdEmpresa es NULLABLE. Si quedaran filas
-- historicas con IdEmpresa NULL de antes de este cambio, no las
-- borraria ningun DELETE por empresa. Limpiarlas una sola vez con:
--     DELETE FROM CalculoDetalle WHERE IdEmpresa IS NULL;
-- y despues considerar declarar la columna NOT NULL.
DELETE FROM CalculoDetalle WHERE IdEmpresa = @IdEmpresa;

INSERT INTO CalculoDetalle (
IdActivo, IdEmpresa, IdPeriodo, IdMes,
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
ACT.Id, ACT.IdEmpresa, @IdPeriodo, @Mes,
Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
CFC.Moi, CFC.MoiFiscal, CFC.Baja, CFC.FechaBaja,
Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
InpcMitadPeriodo, InpcFechaAdquisicion, Factor_Ajuste,
Deduccion_Fiscal_Inv_Actualizado, CFC.Convencional
FROM CalculoFinalConvencional CFC
INNER JOIN Activos ACT ON CFC.Id = ACT.Id AND CFC.IdEmpresa = ACT.IdEmpresa
-- FIX-ARRASTRE [4]: defensivo. CalculoFinalConvencional es una tabla
-- PERMANENTE compartida, no una temporal de sesion. Hoy se construye solo
-- para la empresa calculada, pero no conviene depender de eso.
WHERE ACT.IdEmpresa = @IdEmpresa;


/*HISTORICO DE CALCULO DETALLE*/

SET @ExisteCalculo = (SELECT
    CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS tiene_registros
FROM CalculoDetalle_Historico
WHERE IdPeriodo = @IdPeriodo AND IdMes = @Mes AND IdEmpresa = @IdEmpresa);

-- FIX-BORRADO-EMPRESA: el SET de arriba SI filtra por IdEmpresa, pero
-- este DELETE NO lo hacia. Dos efectos, ambos graves:
--   * Calcular una empresa BORRABA el cierre de TODAS las demas para
--     ese mismo periodo y mes.
--   * Si la empresa calculada no tenia datos previos pero otra si,
--     @ExisteCalculo daba 0, no se borraba nada y se ACUMULABAN filas
--     duplicadas en cada reproceso.
-- Se borra solo lo de la empresa que se esta calculando. El IF ya no
-- hace falta: DELETE sobre cero filas no cuesta nada.
DELETE FROM CalculoDetalle_Historico
WHERE IdPeriodo = @IdPeriodo AND IdMes = @Mes AND IdEmpresa = @IdEmpresa;

INSERT INTO CalculoDetalle_Historico (
IdActivo, IdEmpresa, IdPeriodo, IdMes,
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
IdActivo, IdEmpresa, IdPeriodo, IdMes,
Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
Moi, MoiFiscal, Baja, FechaBaja,
Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
InpcMitadPeriodo, InpcFechaAdquisicion, Factor_Ajuste,
Deduccion_Fiscal_Inv_Actualizado, Convencional
FROM CalculoDetalle
-- =====================================================================
-- FIX-ARRASTRE [2] · CAUSA RAIZ DE LOS DUPLICADOS
-- El DELETE de arriba borra UNA empresa. Este SELECT copiaba la tabla
-- COMPLETA, y CalculoDetalle conserva las filas de las demas empresas
-- porque su propio DELETE tambien es por empresa. Resultado: calcular
-- cualquier empresa reinsertaba el cierre vivo de todas las otras, con
-- su propio (IdEmpresa, IdPeriodo, IdMes), fuera del alcance del DELETE.
-- Observado: empresa 1 con 47 copias, empresa 27 con 8, empresa 54 con 2.
-- =====================================================================
WHERE IdEmpresa = @IdEmpresa
  AND IdPeriodo = @IdPeriodo
  AND IdMes     = @Mes;


/*CALCULO MENSUAL HISTORICO*/

SET @ExisteHistorico = (SELECT
    CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS tiene_registros
FROM CalculoMensual_Historico
WHERE IdPeriodo = @IdPeriodo AND IdMes = @Mes AND IdEmpresa = @IdEmpresa);

-- FIX-BORRADO-EMPRESA: mismo caso que CalculoDetalle_Historico.
DELETE FROM CalculoMensual_Historico
WHERE IdPeriodo = @IdPeriodo AND IdMes = @Mes AND IdEmpresa = @IdEmpresa;

INSERT INTO CalculoMensual_Historico (
IdActivo, IdEmpresa, IdPeriodo, IdMes,
Enero, Febrero, Marzo, Abril, Mayo, Junio,
Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
TipoContabilidad)
SELECT
IdActivo, IdEmpresa, IdPeriodo, IdMes,
Enero, Febrero, Marzo, Abril, Mayo, Junio,
Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre,
TipoContabilidad
FROM CalculoMensual
-- FIX-ARRASTRE [3]: mismo defecto que CalculoDetalle_Historico.
WHERE IdEmpresa = @IdEmpresa
  AND IdPeriodo = @IdPeriodo
  AND IdMes     = @Mes;


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ActivosBajas') AND type IN (N'U'))
    DROP TABLE ActivosBajas;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'CalculoFinalConvencional') AND type IN (N'U'))
    DROP TABLE CalculoFinalConvencional;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MensualConvencionalContable') AND type IN (N'U'))
    DROP TABLE MensualConvencionalContable;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'MensualConvencionalFiscal') AND type IN (N'U'))
    DROP TABLE MensualConvencionalFiscal;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'ActivosDepreciacion') AND type IN (N'U'))
    DROP TABLE ActivosDepreciacion;

    /*DELETE FROM CalculoDetalle_Historico WHERE FechaBaja IS NOT NULL*/;
    
    -- AUDITORIA: cierra la bitacora, firma los insumos y compara
-- contra la corrida anterior.
EXEC aud.sp_CorridaFinalizar @IdCorrida = @IdCorrida, @Estado = 'OK';

END
GO


-- ----------------------------
-- procedure structure for sp_DesgloseDepreciacion
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DesgloseDepreciacion]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[sp_DesgloseDepreciacion]
GO

CREATE PROCEDURE [dbo].[sp_DesgloseDepreciacion]
    @RFC          VARCHAR(20),
    @Periodo      VARCHAR(10),
    @Mes          INT,
    @Grupo        VARCHAR(255),
    @Convencional TINYINT     = 1,
    @Vista        VARCHAR(20) = 'PRINCIPAL'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Anio INT = CAST(@Periodo AS INT);

    DECLARE @IdPeriodo    INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = @Anio);
    DECLARE @IdPeriodoAnt INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = @Anio - 1);

    -- Corte del mes consultado. La vigencia se compara por FECHA COMPLETA:
    -- un activo con baja en 2026 estaba VIGENTE al consultar 2024.
    DECLARE @Corte DATE = EOMONTH(DATEFROMPARTS(@Anio, @Mes, 1));

    -- =================================================================
    -- [A] Activos VIGENTES segun la vista, con sus importes del mes
    -- =================================================================
    DROP TABLE IF EXISTS #Vig;

    SELECT
        CFC.IdActivo,
        ADE.Identificador,
        ADE.Descripcion,
        ADE.FechaBaja,
        Moi        = ISNULL(CFC.Moi, 0),
        Historico  = ISNULL(CFC.DeduccionContableInvHistorico, 0),
        Anual      = ISNULL(CFC.DepreciacionContableInversionAnual, 0),
        Acumulado  = ISNULL(CFC.DepreciacionContableAcumulado, 0),
        HistoricoF = ISNULL(CFC.DeduccionFiscalInvHistorico, 0),
        AnualF     = ISNULL(CFC.DepreciacionFiscalInversionAnual, 0),
        AcumuladoF = ISNULL(CFC.DepreciacionFiscalAcumulado, 0)
    INTO #Vig
    FROM CalculoDetalle_Historico CFC
    INNER JOIN Activos         ADE ON CFC.IdActivo   = ADE.Id
    INNER JOIN Empresas        EMP ON ADE.IdEmpresa  = EMP.Id
    INNER JOIN CatalogoPeriodo CPE ON CFC.IdPeriodo  = CPE.Id
    INNER JOIN CatalogoCuentas CAC ON ADE.IdCatalogo = CAC.Id
    WHERE EMP.RFC          = @RFC
      AND CPE.Periodo      = @Periodo
      AND CFC.IdMes        = @Mes
      AND CFC.Convencional = @Convencional
      AND CAC.Grupo        = @Grupo
      AND (ADE.FechaBaja IS NULL OR YEAR(ADE.FechaBaja) >= @Anio)
      AND (
            (@Vista = 'PRINCIPAL' AND (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte))
         OR (@Vista = 'VIGENTES'  AND (ADE.FechaBaja IS NULL
                                       OR ADE.FechaBaja > @Corte))
          );

    -- =================================================================
    -- [B] BAJAS del ejercicio ya ocurridas al mes, desde el congelado
    -- =================================================================
    DROP TABLE IF EXISTS #Baj;

    SELECT
        ADE.Id AS IdActivo,
        ADE.Identificador,
        ADE.Descripcion,
        ADE.FechaBaja,
        MesBaja    = MONTH(ADE.FechaBaja),
        Moi        = ISNULL(CGL.Moi, 0),
        Historico  = ISNULL(CGL.DeduccionContableInvHistorico, 0),
        HistoricoF = ISNULL(CGL.DeduccionFiscalInvHistorico, 0),
        PctC       = ISNULL(CGL.Porcentaje_Dep_Contable_Anual, 0),
        PctF       = ISNULL(CGL.Porcentaje_Dep_Fiscal_Anual, 0)
    INTO #Baj
    FROM Activos ADE
    INNER JOIN Empresas        EMP ON ADE.IdEmpresa  = EMP.Id
    INNER JOIN CatalogoCuentas CAC ON ADE.IdCatalogo = CAC.Id
    OUTER APPLY (
        SELECT TOP 1 CDA.*
        FROM CalculoDetalle_Historico CDA
        WHERE CDA.IdActivo     = ADE.Id
          AND CDA.Convencional = @Convencional
          AND CDA.IdPeriodo    = CASE WHEN MONTH(ADE.FechaBaja) = 1
                                      THEN @IdPeriodoAnt ELSE @IdPeriodo END
          AND CDA.IdMes        = CASE WHEN MONTH(ADE.FechaBaja) = 1
                                      THEN 12 ELSE MONTH(ADE.FechaBaja) - 1 END
    ) CGL
    WHERE EMP.RFC     = @RFC
      AND CAC.Grupo   = @Grupo
      AND ADE.FechaBaja IS NOT NULL
      AND YEAR(ADE.FechaBaja)  = @Anio
      AND ADE.FechaBaja <= @Corte;

    -- Anual del ejercicio de las bajas: meses vigentes = MesBaja - 1
    DROP TABLE IF EXISTS #BajCalc;

    SELECT
        B.*,
        Anual  = CAST(CASE WHEN B.MesBaja > 1 AND B.PctC > 0
                           THEN (B.Moi * B.PctC) / 12 * (B.MesBaja - 1)
                           ELSE 0 END AS DECIMAL(18,2)),
        AnualF = CAST(CASE WHEN B.MesBaja > 1 AND B.PctF > 0
                           THEN (B.Moi * B.PctF) / 12 * (B.MesBaja - 1)
                           ELSE 0 END AS DECIMAL(18,2))
    INTO #BajCalc
    FROM #Baj B;

    -- =================================================================
    -- RESULTSET 1: RESUMEN
    -- =================================================================
    DECLARE @BajasSuman BIT = CASE WHEN @Vista = 'PRINCIPAL' THEN 1 ELSE 0 END;

    ;WITH Tot AS (
        SELECT
            Orden = 1,
            Concepto = 'Activos vigentes al mes ' + CAST(@Mes AS VARCHAR(2)),
            Signo = '+',
            Moi        = CAST(ISNULL((SELECT SUM(Moi)       FROM #Vig),0) AS DECIMAL(18,2)),
            Historico  = CAST(ISNULL((SELECT SUM(Historico) FROM #Vig),0) AS DECIMAL(18,2)),
            Anual      = CAST(ISNULL((SELECT SUM(Anual)     FROM #Vig),0) AS DECIMAL(18,2)),
            Acumulado  = CAST(ISNULL((SELECT SUM(Acumulado) FROM #Vig),0) AS DECIMAL(18,2))
        UNION ALL
        SELECT
            2,
            CASE WHEN @BajasSuman = 1
                 THEN 'Bajas del ejercicio (congelado al mes previo)'
                 ELSE 'Bajas del ejercicio (EXCLUIDAS del total)' END,
            CASE WHEN @BajasSuman = 1 THEN '+' ELSE '(info)' END,
            CAST(ISNULL((SELECT SUM(Moi)       FROM #BajCalc),0) AS DECIMAL(18,2)),
            CAST(ISNULL((SELECT SUM(Historico) FROM #BajCalc),0) AS DECIMAL(18,2)),
            CAST(ISNULL((SELECT SUM(Anual)     FROM #BajCalc),0) AS DECIMAL(18,2)),
            CAST(ISNULL((SELECT SUM(Historico) + SUM(Anual) FROM #BajCalc),0) AS DECIMAL(18,2))
    )
    SELECT Orden, Concepto, Signo, Moi, Historico, Anual, Acumulado FROM Tot
    UNION ALL
    SELECT
        3,
        'TOTAL MOSTRADO EN EL REPORTE',
        '=',
        CAST(SUM(CASE WHEN Orden = 1 OR @BajasSuman = 1 THEN Moi       ELSE 0 END) AS DECIMAL(18,2)),
        CAST(SUM(CASE WHEN Orden = 1 OR @BajasSuman = 1 THEN Historico ELSE 0 END) AS DECIMAL(18,2)),
        CAST(SUM(CASE WHEN Orden = 1 OR @BajasSuman = 1 THEN Anual     ELSE 0 END) AS DECIMAL(18,2)),
        CAST(SUM(CASE WHEN Orden = 1 OR @BajasSuman = 1 THEN Acumulado ELSE 0 END) AS DECIMAL(18,2))
    FROM Tot
    ORDER BY Orden;

    -- =================================================================
    -- RESULTSET 2: DETALLE POR ACTIVO
    -- =================================================================
    SELECT
        IdActivo, Identificador, DescripcionActivo, Estado, FechaBaja,
        Moi, Historico, Anual, Acumulado, Suma
    FROM (
        SELECT
            V.IdActivo,
            V.Identificador,
            DescripcionActivo = V.Descripcion,
            Estado    = 'Vigente',
            V.FechaBaja,
            Moi       = CAST(V.Moi       AS DECIMAL(18,2)),
            Historico = CAST(V.Historico AS DECIMAL(18,2)),
            Anual     = CAST(V.Anual     AS DECIMAL(18,2)),
            Acumulado = CAST(V.Acumulado AS DECIMAL(18,2)),
            Suma      = 'SI',
            OrdenEstado = 1
        FROM #Vig V
        UNION ALL
        SELECT
            B.IdActivo,
            B.Identificador,
            B.Descripcion,
            'Baja ' + RIGHT('0' + CAST(B.MesBaja AS VARCHAR(2)), 2) + '/' + @Periodo,
            B.FechaBaja,
            CAST(B.Moi       AS DECIMAL(18,2)),
            CAST(B.Historico AS DECIMAL(18,2)),
            CAST(B.Anual     AS DECIMAL(18,2)),
            CAST(B.Historico + B.Anual AS DECIMAL(18,2)),
            CASE WHEN @BajasSuman = 1 THEN 'SI' ELSE 'NO' END,
            2
        FROM #BajCalc B
    ) D
    ORDER BY D.OrdenEstado, D.Acumulado DESC;

    DROP TABLE IF EXISTS #Vig;
    DROP TABLE IF EXISTS #Baj;
    DROP TABLE IF EXISTS #BajCalc;
END
GO


-- ----------------------------
-- procedure structure for InsertarRegistrosEnTabla
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertarRegistrosEnTabla]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[InsertarRegistrosEnTabla]
GO

CREATE PROCEDURE [dbo].[InsertarRegistrosEnTabla] @RFC VARCHAR(14),@Tipo TINYINT,@Periodo INT
AS

IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivosBajas]') AND type IN ('U'))
	DROP TABLE [dbo].[ActivosBajas]


CREATE TABLE [dbo].[ActivosBajas] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdActivo] int  NOT NULL,
  [IdEmpresa] int  NULL,
  [Identificador] varchar(50) COLLATE Modern_Spanish_CI_AS  NULL,
  [FechaVenta] date  NOT NULL,
  [NumFactura] nvarchar(40) COLLATE Modern_Spanish_CI_AS  NULL,
  [PrecioVenta] decimal(10,2)  NULL,
  [MesesUso] int  NULL,
  [FechaProcesado] date DEFAULT getdate() NOT NULL
)

/*@RFC: Empresa que ingresara la informacion*/
/*@Tipo: Indica si el activo es convencional(1) o no convencional(0)*/
/*@Periodo: Año actual del ingreso de la informacion*/
BEGIN

/*Contador inicial*/
DECLARE @contador INT=1;
/*Contador Final*/
DECLARE @contadorfin INT;
/*Fila Minima para insertar por rangos*/
DECLARE @idrowmin INT;
/*Fila Maxima para insertar por rangos*/
DECLARE @idrowmax INT;
/*Id del catalogo de cuentas para asignar por ID */
DECLARE @idcatcuentas INT;
/*Saber si ya existe la empresa con activos ingresados */
DECLARE @empresaexiste INT;
/*Se cuenta la cantidad de bajas ya registradas*/
DECLARE @cantidadbajas INT=(SELECT COUNT(*) FROM Tmpbajas);
/*Saber si la variable contiene una fecha valida*/
DECLARE @esfecha INT;



/*CONTROL PARA SABER SI LA EMPRESA YA FUE DADA DE ALTA DE FORMA GENERAL*/
DECLARE @idempresa INT=(SELECT Id FROM Empresas WHERE RFC=@RFC);

IF @Tipo = 1

/*SABER SI LA EMPRESA EXISTE EN LOS ACTIVOS YA EXISTENTES*/
SET @empresaexiste=(SELECT COUNT(*) FROM Activos WHERE IdEmpresa=@idempresa AND Convencional=1);

ELSE

/*SABER SI LA EMPRESA EXISTE EN LOS ACTIVOS YA EXISTENTES*/
SET @empresaexiste=(SELECT COUNT(*) FROM Activos WHERE IdEmpresa=@idempresa AND Convencional=0);

/*SI LA EMPRESA NO TIENE ACTIVOS YA DADOS DE ALTA*/
IF @empresaexiste=0

BEGIN
--   +-++-++-++-++-++-+ +-++-++-++-++-++-++-+ +-++-++-++-++-+
--   |U||P||D||A||T||E| |F||O||R||M||A||T||O| |F||E||C||H||A| --TABLAS TEMPORALES
--   +-++-++-++-++-++-+ +-++-++-++-++-++-++-+ +-++-++-++-++-+
IF @Tipo = 1

/*Cambiando el formato de la columna FechaAdquisicion para que esté en el formato YYYY/MM/DD de activos convencionales*/
BEGIN TRY
UPDATE Tmpdeprecia
SET FechaAdquisicion = CONVERT(VARCHAR(10), CONVERT(DATE, FechaAdquisicion, 103), 111)
WHERE LEFT(FechaAdquisicion, 2) != '20' AND NumIdentificacion IS NOT NULL;
END TRY

BEGIN CATCH
  
END CATCH

ELSE
/*Cambiando el formato de la columna FechaAdquisicion para que esté en el formato YYYY/MM/DD de activos inmediatos*/
BEGIN TRY
UPDATE Tmpdepreciainmediato
SET FechaAdquisicion = CONVERT(VARCHAR(10), CONVERT(DATE, FechaAdquisicion, 103), 111)
WHERE LEFT(FechaAdquisicion, 2) != '20' AND NumIdentificacion IS NOT NULL;
END TRY
BEGIN CATCH
  
END CATCH



--   +-++-++-++-++-++-++-++-++-++-++-+ +-++-+ +-++-++-++-++-++-++-+
--   |A||G||R||U||P||A||D||O||R||E||S| |D||E| |A||C||T||I||V||O||S|--TABLAS TEMPORALES
--   +-++-++-++-++-++-++-++-++-++-++-+ +-++-+ +-++-++-++-++-++-++-+
/*Los agrupadores son para saber el tipo de adquisicion que se tiene*/
DROP TABLE IF EXISTS Tmpagrupadores;

IF @Tipo = 1
BEGIN
/*DEPRECIACION CONVENCIONAL*/
SELECT @contadorfin = COUNT(*) FROM TmpDeprecia td WHERE td.FechaAdquisicion NOT LIKE '%[0-9]%';

SELECT ROW_NUMBER() OVER(ORDER BY td.IdRow) AS IdFila,*
INTO Tmpagrupadores
FROM Tmpdeprecia td
WHERE td.FechaAdquisicion NOT LIKE '%[0-9]%'
ORDER BY td.IdRow ASC;

END
ELSE
BEGIN

/*DEPRECIACION INMEDIATA*/
SELECT @contadorfin = COUNT(*) FROM Tmpdepreciainmediato td WHERE td.FechaAdquisicion NOT LIKE '%[0-9]%';

SELECT ROW_NUMBER() OVER(ORDER BY td.IdRow) AS IdFila,*
INTO Tmpagrupadores
FROM Tmpdepreciainmediato td
WHERE td.FechaAdquisicion NOT LIKE '%[0-9]%'
ORDER BY td.IdRow ASC;

END


--   +-++-++-++-++-++-++-++-+ +-++-+ +-++-++-++-++-+
--   |C||O||M||I||E||N||Z||O| |D||E| |C||I||C||L||O|--TABLAS TEMPORALES
--   +-++-++-++-++-++-++-++-+ +-++-+ +-++-++-++-++-+
WHILE @contador <= @contadorfin

BEGIN

SET @idrowmin=(SELECT IdRow FROM Tmpagrupadores WHERE IdFila=@contador);
SET @idcatcuentas=(SELECT CC.Id FROM Tmpagrupadores TE INNER JOIN CatalogoCuentas CC ON TE.FechaAdquisicion=CC.Grupo WHERE IdFila=@contador);

IF @contador=@contadorfin
BEGIN

IF @Tipo = 1
BEGIN
SET @idrowmax=(SELECT COUNT(*) FROM TmpDeprecia)+1;
END
ELSE
BEGIN
SET @idrowmax=(SELECT COUNT(*) FROM Tmpdepreciainmediato)+1;
END 


END

ELSE
BEGIN 
SET @idrowmax=(SELECT IdRow FROM Tmpagrupadores WHERE IdFila=@contador+1);
END

IF @Tipo = 1
BEGIN
SET @esfecha=ISDATE((SELECT FechaAdquisicion FROM TmpDeprecia WHERE IdRow=@idrowmax-1));
END
ELSE
BEGIN
SET @esfecha=ISDATE((SELECT FechaAdquisicion FROM Tmpdepreciainmediato WHERE IdRow=@idrowmax-1));
END

IF @esfecha=0
BEGIN 
SET @contador = @contador + 1;
END 

ELSE
 
BEGIN
/*Fila Minima donde existen datos de inventario.*/
SET @idrowmin=@idrowmin+1;
/*Fila Maxima donde existen datos de inventario.*/
SET @idrowmax=@idrowmax-1;






--   +-++-++-++-++-++-++-++-++-+ +-++-+ +-++-++-++-++-++-++-+
--   |I||N||S||E||R||C||I||O||N| |D||E| |A||C||T||I||V||O||S|TABLAS PERSISTENTES
--   +-++-++-++-++-++-++-++-++-+ +-++-+ +-++-++-++-++-++-++-+
IF @Tipo = 1
BEGIN

/*DEPRECIACION CONVENCIONAL*/
INSERT INTO Activos (IdEmpresa,Identificador,IdCatalogo,FechaAdquisicion, Descripcion,Moi,MOIFiscal,Baja,FechaBaja,PorcentajeDepFIscalAnual,PorcentajeDepContableAnual)
SELECT @idempresa,NumIdentificacion,@idcatcuentas,FechaAdquisicion, Descripcion,Moi,MOIFiscal,Baja,FechaBaja,PorcentajeDepFIscalAnual,PorcentajeDepContableAnual
FROM Tmpdeprecia WHERE IdRow BETWEEN @idrowmin AND @idrowmax;
END

ELSE

BEGIN

/*DEPRECIACION INMEDIATA*/
INSERT INTO Activos (IdEmpresa,Identificador,IdCatalogo,FechaAdquisicion, Descripcion,Moi,MOIFiscal,Baja,FechaBaja,Convencional,PorcentajeDepFIscalAnual,PorcentajeDepContableAnual)
SELECT @idempresa,NumIdentificacion,@idcatcuentas,FechaAdquisicion, Descripcion,Moi,MOIFiscal,Baja,FechaBaja,0,PorcentajeDepFIscalAnual,PorcentajeDepContableAnual
FROM Tmpdepreciainmediato WHERE IdRow BETWEEN @idrowmin AND @idrowmax;
END

SET @contador = @contador + 1;
END 

END;

--   +-++-++-++-++-++-++-++-++-+ +-++-++-++-++-++-++-++-+ +-++-++-++-+ +-+ +-++-++-++-+
--   |A||C||T||U||A||L||I||Z||A| |C||A||N||T||I||D||A||D| |B||A||J||A| |A| |0||.||0||0|
--   +-++-++-++-++-++-++-++-++-+ +-++-++-++-++-++-++-++-+ +-++-++-++-+ +-+ +-++-++-++-+
UPDATE Activos
SET Baja = 0.00
WHERE Baja IS NULL;


IF @cantidadbajas >= 1
BEGIN/*INSERCION DE SOLO BAJAS NUEVAS EN CADA OPERACION*/

INSERT INTO ActivosBajas (IdActivo,IdEmpresa,Identificador,FechaVenta, NumFactura,PrecioVenta)
SELECT AD.Id,@idempresa,AD.Identificador,BA.FechaVenta,BA.NumFactura,BA.PrecioVenta
FROM Activos AD
INNER JOIN Tmpbajas BA ON AD.Identificador = BA.Identificador
WHERE AD.FechaBaja IS NOT NULL AND AD.IdEmpresa=@idempresa
AND NOT EXISTS (
    SELECT 1
    FROM ActivosBajas AB
    WHERE AB.IdActivo = AD.Id
);

UPDATE ActivosBajas
SET MesesUso = 
    CASE 
        WHEN @Periodo = YEAR(FechaAdquisicion) THEN 
            CASE 
                WHEN (MONTH(FechaVenta) - 1) - MONTH(FechaAdquisicion) < 0 THEN 0 
                ELSE (MONTH(FechaVenta) - 1) - MONTH(FechaAdquisicion)
            END
        ELSE 
            CASE 
                WHEN (MONTH(FechaVenta) - 1) < 1 THEN 0 
                ELSE (MONTH(FechaVenta) - 1) 
            END 
    END
FROM ActivosBajas ABA 
INNER JOIN Activos ADE ON ABA.IdActivo = ADE.Id
WHERE ADE.IdEmpresa=@idempresa;
END

IF @Tipo = 1
BEGIN
DROP TABLE IF EXISTS Tmpdeprecia;
END
ELSE
BEGIN
DROP TABLE IF EXISTS Tmpdepreciainmediato;
DROP TABLE IF EXISTS Tmpbajas;
END

DROP TABLE IF EXISTS Tmpagrupadores;

END;
END;
GO


-- ----------------------------
-- procedure structure for SP_RevertirBajaActivo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_RevertirBajaActivo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[SP_RevertirBajaActivo]
GO

CREATE PROCEDURE [dbo].[SP_RevertirBajaActivo]
    @Id       INT,
    @IdActivo INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM [dbo].[ActivosBaja]
        WHERE Id = @Id AND IdActivo = @IdActivo
    )
    BEGIN
        RAISERROR('No se encontró el registro de baja para el activo indicado.', 16, 1);
        RETURN;
    END

    -- Capturar snapshot ANTES de la transacción
    DECLARE @FechaBajaOriginal  DATE;
    DECLARE @MotivoOriginal     NVARCHAR(500);

    SELECT
        @FechaBajaOriginal = FechaVenta,
        @MotivoOriginal    = MotivoBaja
    FROM [dbo].[ActivosBaja]
    WHERE Id = @Id AND IdActivo = @IdActivo;

    -- FIX-002 [2]: contadores para que una reversión que no borra nada
    -- deje de reportarse como exitosa.
    DECLARE @FilasBaja      INT = 0;
    DECLARE @FilasCongelado INT = 0;
    DECLARE @MoiRestituido  INT = 0;
    DECLARE @Detalle        NVARCHAR(400);

    BEGIN TRY
        BEGIN TRANSACTION;

            -- FIX-002 [3] · GUARDA DEFENSIVA DE MOI
            -- El congelado es la única fuente del MOI al momento del retiro.
            -- Si el activo lo tuviera perdido, restituirlo ANTES de borrarlo.
            -- Tras la decisión del 2026-09-17 esto no debería dispararse.
            UPDATE A
            SET A.Moi       = CB.Moi,
                A.MoiFiscal = CB.MoiFiscal
            FROM [dbo].[Activos] A
            INNER JOIN [dbo].[CalculoDetalle_HistoricoBajas] CB ON CB.IdActivo = A.Id
            WHERE A.Id = @IdActivo
              AND A.Moi IN (0, 1)
              AND CB.Moi > 1;

            SET @MoiRestituido = @@ROWCOUNT;

            DELETE FROM [dbo].[ActivosBaja]
            WHERE Id = @Id AND IdActivo = @IdActivo;

            SET @FilasBaja = @@ROWCOUNT;

            -- =====================================================
            -- FIX-002 [1] · CORRECCIÓN PRINCIPAL
            -- Antes: WHERE Id = @Id AND IdActivo = @IdActivo
            -- @Id viene de ActivosBaja.Id y las dos tablas tienen
            -- IDENTITY independientes, así que el filtro no encontraba
            -- la fila y el borrado era silencioso.
            -- =====================================================
            DELETE FROM [dbo].[CalculoDetalle_HistoricoBajas]
            WHERE IdActivo = @IdActivo;

            SET @FilasCongelado = @@ROWCOUNT;

            UPDATE [dbo].[Activos]
            SET  Baja      = 0,
                 FechaBaja = NULL
            WHERE Id = @IdActivo;

            -- El registro de baja debía existir: se validó al entrar.
            IF @FilasBaja = 0
            BEGIN
                RAISERROR('No se eliminó el registro de ActivosBaja. Reversión abortada.', 16, 1);
            END

        COMMIT TRANSACTION;

        SET @Detalle = 'Baja revertida correctamente. ActivosBaja: '
                     + CAST(@FilasBaja AS VARCHAR(10)) + ' fila(s). Congelado BRE: '
                     + CAST(@FilasCongelado AS VARCHAR(10)) + ' fila(s).'
                     + CASE WHEN @MoiRestituido > 0
                            THEN ' AVISO: se restituyó el MOI desde el congelado.'
                            ELSE '' END
                     + CASE WHEN @FilasCongelado = 0
                            THEN ' AVISO: no existía congelado para este activo.'
                            ELSE '' END;

        -- Log de éxito (fuera de la transacción para que no revierta el log)
        INSERT INTO [dbo].[Log_ReversionBajas]
            (IdBaja, IdActivo, FechaBajaOriginal, MotivoBajaOriginal, Resultado, Mensaje)
        VALUES
            (@Id, @IdActivo, @FechaBajaOriginal, @MotivoOriginal, 1, @Detalle);

        SELECT 1 AS Resultado, 'Baja revertida correctamente.' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(500) = ERROR_MESSAGE();

        -- Log de error (se ejecuta después del rollback, no se pierde)
        INSERT INTO [dbo].[Log_ReversionBajas]
            (IdBaja, IdActivo, FechaBajaOriginal, MotivoBajaOriginal, Resultado, Mensaje)
        VALUES
            (@Id, @IdActivo, @FechaBajaOriginal, @MotivoOriginal, 0, @ErrMsg);

        SELECT
             0                       AS Resultado,
             @ErrMsg                 AS Mensaje,
             ERROR_NUMBER()          AS NumeroError,
             ERROR_SEVERITY()        AS Severidad,
             ERROR_STATE()           AS Estado,
             ERROR_PROCEDURE()       AS Procedimiento,
             ERROR_LINE()            AS Linea;
    END CATCH;
END;
GO


-- ----------------------------
-- procedure structure for VentaBajaActivoCalculo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[VentaBajaActivoCalculo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[VentaBajaActivoCalculo]
GO

CREATE PROCEDURE [dbo].[VentaBajaActivoCalculo]
    @IdActivo         INT,
    @Fechafinal       DATE,
    @IdEmpresa        INT,
    @EjercicioVigente VARCHAR(4),
    @MesesUso         INT = 0
AS
BEGIN

EXEC [dbo].[CrearTabla]

DECLARE @Anio AS VARCHAR(4) = YEAR(@Fechafinal);

DROP TABLE IF EXISTS Tmpcalculocontable;

SELECT *,
CAST(
CASE WHEN Porcentaje_Dep_Contable_Anual > 0 AND YEAR(FechaUso) < YEAR(@Fechafinal) THEN
    CASE
        WHEN Meses_Transcurridos > (12 / Porcentaje_Dep_Contable_Anual) THEN 0
        WHEN Meses_Transcurridos + MONTH(@Fechafinal) < (12 / Porcentaje_Dep_Contable_Anual) THEN
            CASE
                WHEN FechaBaja IS NOT NULL THEN @MesesUso
                ELSE MONTH(@Fechafinal)
            END
        ELSE
            CASE
                WHEN @MesesUso = 0 AND FechaBaja IS NOT NULL THEN (12 / Porcentaje_Dep_Contable_Anual) - Meses_Transcurridos
                WHEN (12 / Porcentaje_Dep_Contable_Anual - Meses_Transcurridos) > @MesesUso THEN @MesesUso
                ELSE (12 / Porcentaje_Dep_Contable_Anual) - Meses_Transcurridos
            END
    END
ELSE
    CASE WHEN MONTH(FechaUso) > MONTH(@Fechafinal) THEN 0
    ELSE
        CASE
            WHEN Porcentaje_Dep_Contable_Anual > 0 AND FechaBaja IS NOT NULL THEN @MesesUso
            WHEN Porcentaje_Dep_Contable_Anual > 0 THEN MONTH(@Fechafinal) - MONTH(FechaUso)
            ELSE 0
        END
    END
END AS INT) AS Meses_Efectivos_Contables,

CAST(
CASE WHEN Porcentaje_Dep_Contable_Anual > 0 THEN
    CASE WHEN Meses_Transcurridos > 12 / (12 * Porcentaje_Dep_Contable_Anual) * 12 THEN Moi
    ELSE ((Moi * Porcentaje_Dep_Contable_Anual) / 12) * Meses_Transcurridos
    END
ELSE 0
END AS DECIMAL(18,2)) AS DeduccionContableInvHistorico,

CAST(
CASE WHEN Porcentaje_Dep_Contable_Anual > 0 THEN
    CASE WHEN Meses_Transcurridos > 12 / (12 * Porcentaje_Dep_Contable_Anual) * 12 THEN Moi - Moi
    ELSE Moi - ((((Moi * Porcentaje_Dep_Contable_Anual) / 12) * Meses_Transcurridos))
    END
ELSE Moi
END AS DECIMAL(18,2)) AS SaldoContablePorDeducir

INTO Tmpcalculocontable
FROM
(SELECT
    AD.Id, AD.IdEmpresa, AD.Identificador, FechaAdquisicion, AD.FechaUso, IdCatalogo, Descripcion,
    CASE
        WHEN DATEDIFF(MONTH, FechaUso, @Fechafinal) < 0 THEN 0
        ELSE
            CASE
                WHEN 12 - MONTH(FechaUso) + ((YEAR(@Fechafinal) - YEAR(FechaUso)) - 1) * 12 < 0 THEN 0
                ELSE 12 - MONTH(FechaUso) + ((YEAR(@Fechafinal) - YEAR(FechaUso)) - 1) * 12
            END
    END AS Meses_Transcurridos,
    ISNULL(PorcentajeDepFIscalAnual, 0)   AS Porcentaje_Dep_Fiscal_Anual,
    ISNULL(PorcentajeDepContableAnual, 0) AS Porcentaje_Dep_Contable_Anual,
    Moi, MoiFiscal, Baja, FechaBaja,
    @MesesUso AS MesesUso,
    Convencional
FROM Activos AD
INNER JOIN CatalogoCuentas CC ON AD.IdCatalogo = CC.Id
WHERE AD.IdEmpresa = @IdEmpresa AND AD.Id = @IdActivo) AS Calculado
WHERE IdEmpresa = @IdEmpresa;


DROP TABLE IF EXISTS Tmpcalculofiscal;

SELECT Id,
CAST(
CASE WHEN Porcentaje_Dep_Fiscal_Anual > 0 AND YEAR(FechaUso) < YEAR(@Fechafinal) THEN
    CASE WHEN Convencional = 1 THEN
        CASE
            WHEN Meses_Transcurridos > (12 / Porcentaje_Dep_Fiscal_Anual) THEN 0
            WHEN Meses_Transcurridos + MONTH(@Fechafinal) < (12 / Porcentaje_Dep_Fiscal_Anual) THEN
                CASE
                    WHEN FechaBaja IS NOT NULL THEN @MesesUso
                    ELSE MONTH(@Fechafinal)
                END
            ELSE
                CASE
                    WHEN @MesesUso = 0 AND FechaBaja IS NOT NULL THEN (12 / Porcentaje_Dep_Fiscal_Anual) - Meses_Transcurridos
                    WHEN (12 / Porcentaje_Dep_Fiscal_Anual - Meses_Transcurridos) > @MesesUso THEN @MesesUso
                    ELSE (12 / Porcentaje_Dep_Fiscal_Anual) - Meses_Transcurridos
                END
        END
    ELSE (YEAR(@Fechafinal) - YEAR(FechaAdquisicion)) + 1
    END
ELSE
    CASE WHEN MONTH(FechaUso) > MONTH(@Fechafinal) AND Convencional = 1 THEN 0
    ELSE
        CASE
            WHEN Porcentaje_Dep_Fiscal_Anual > 0 AND FechaBaja IS NOT NULL AND Convencional = 1 THEN @MesesUso
            WHEN Porcentaje_Dep_Fiscal_Anual > 0 AND Convencional = 1 THEN MONTH(@Fechafinal) - MONTH(FechaUso)
            ELSE 0
        END
    END
END AS INT) AS Meses_Efectivos_Fiscales,

CAST(
CASE WHEN Porcentaje_Dep_Fiscal_Anual > 0 THEN
    CASE WHEN Convencional = 1 THEN
        CASE WHEN IdCatalogo = 8 AND Porcentaje_Dep_Fiscal_Anual = 1 THEN 0
        ELSE
            CASE WHEN Meses_Transcurridos > 12 / (12 * Porcentaje_Dep_Fiscal_Anual) * 12 THEN MoiFiscal
            ELSE ((MoiFiscal * Porcentaje_Dep_Fiscal_Anual) / 12) * Meses_Transcurridos
            END
        END
    ELSE
        CASE
            WHEN Meses_Transcurridos = 1 OR (YEAR(FechaAdquisicion) = 2015 AND MONTH(FechaAdquisicion) IN (9,10,11,12)) THEN 0
            ELSE MoiFiscal * Porcentaje_Dep_Fiscal_Anual
        END
    END
ELSE 0
END AS DECIMAL(18,2)) AS DeduccionFiscalInvHistorico,

CAST(
CASE WHEN Porcentaje_Dep_Fiscal_Anual > 0 THEN
    CASE WHEN Convencional = 1 THEN
        CASE WHEN Meses_Transcurridos > 12 / (12 * Porcentaje_Dep_Fiscal_Anual) * 12 THEN MoiFiscal - MoiFiscal
        ELSE (MoiFiscal - (((MoiFiscal * Porcentaje_Dep_Fiscal_Anual) / 12) * Meses_Transcurridos))
        END
    ELSE
        CASE
            WHEN Meses_Transcurridos = 1 THEN MoiFiscal
            WHEN (YEAR(FechaAdquisicion) = @EjercicioVigente AND MONTH(FechaAdquisicion) IN (9,10,11,12)) THEN MoiFiscal
            ELSE 0
        END
    END
ELSE MoiFiscal
END AS DECIMAL(18,2)) AS SaldoFiscalPorDeducir

INTO Tmpcalculofiscal
FROM
(SELECT
    AD.Id, AD.IdEmpresa, AD.Identificador, FechaAdquisicion, AD.FechaUso, IdCatalogo, Descripcion,
    CASE
        WHEN DATEDIFF(MONTH, FechaUso, @Fechafinal) < 0 THEN 0
        ELSE
            CASE
                WHEN 12 - MONTH(FechaUso) + ((YEAR(@Fechafinal) - YEAR(FechaUso)) - 1) * 12 < 0 THEN 0
                ELSE 12 - MONTH(FechaUso) + ((YEAR(@Fechafinal) - YEAR(FechaUso)) - 1) * 12
            END
    END AS Meses_Transcurridos,
    ISNULL(PorcentajeDepFIscalAnual, 0)   AS Porcentaje_Dep_Fiscal_Anual,
    ISNULL(PorcentajeDepContableAnual, 0) AS Porcentaje_Dep_Contable_Anual,
    Moi, MoiFiscal, Baja, FechaBaja,
    @MesesUso AS MesesUso,
    Convencional
FROM Activos AD
INNER JOIN CatalogoCuentas CC ON AD.IdCatalogo = CC.Id
WHERE AD.IdEmpresa = @IdEmpresa AND AD.Id = @IdActivo) AS Calculado
WHERE IdEmpresa = @IdEmpresa;


DROP TABLE IF EXISTS Tmpdateinpcinversion;

SELECT
    CC.Id, IdEmpresa, Identificador, FechaAdquisicion, Descripcion,
    Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
    Moi, MoiFiscal, Baja, FechaBaja,
    Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,

CAST(
CASE
    WHEN Moi = DeduccionContableInvHistorico THEN 0
    ELSE (Moi * Porcentaje_Dep_Contable_Anual) / 12 * Meses_Efectivos_Contables
END AS DECIMAL(18,2)) AS DepreciacionContableInversionAnual,

CAST(
CASE
    WHEN Moi = DeduccionContableInvHistorico THEN DeduccionContableInvHistorico
    ELSE (Moi * Porcentaje_Dep_Contable_Anual) / 12 * Meses_Efectivos_Contables + DeduccionContableInvHistorico
END AS DECIMAL(18,2)) AS DepreciacionContableAcumulado,

Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,

CAST(
CASE WHEN Convencional = 1 THEN
    CASE
        WHEN MoiFiscal = DeduccionFiscalInvHistorico THEN 0
        ELSE (MoiFiscal * Porcentaje_Dep_Fiscal_Anual) / 12 * Meses_Efectivos_Fiscales
    END
ELSE
    CASE
        WHEN MoiFiscal = DeduccionFiscalInvHistorico THEN 0
        ELSE SaldoFiscalPorDeducir * Porcentaje_Dep_Fiscal_Anual
    END
END AS DECIMAL(18,2)) AS DepreciacionFiscalInversionAnual,

CAST(
CASE WHEN Convencional = 1 THEN
    CASE
        WHEN MoiFiscal = DeduccionFiscalInvHistorico THEN DeduccionFiscalInvHistorico
        ELSE (MoiFiscal * Porcentaje_Dep_Fiscal_Anual) / 12 * Meses_Efectivos_Fiscales + DeduccionFiscalInvHistorico
    END
ELSE
    CASE
        WHEN MoiFiscal = DeduccionFiscalInvHistorico THEN DeduccionFiscalInvHistorico
        ELSE DeduccionFiscalInvHistorico + (SaldoFiscalPorDeducir * Porcentaje_Dep_Fiscal_Anual)
    END
END AS DECIMAL(18,2)) AS DepreciacionFiscalAcumulado,

CASE WHEN Convencional = 1 THEN
    CONCAT(@Anio, '-', '01', '-',
    CASE
        WHEN Porcentaje_Dep_Contable_Anual = 0 AND Porcentaje_Dep_Fiscal_Anual = 0 THEN MONTH(@Fechafinal)
        WHEN Meses_Efectivos_Contables IS NULL AND Meses_Transcurridos = 0 AND Convencional = 1 THEN 0
        WHEN Meses_Efectivos_Contables IS NULL AND Convencional = 1 THEN 0
        WHEN Meses_Transcurridos = 0 THEN CEILING(12 - Meses_Efectivos_Contables + (Meses_Efectivos_Contables / 2))
        WHEN Meses_Efectivos_Contables = 1 THEN 1
        WHEN Meses_Efectivos_Contables = 0 THEN 1
        ELSE CEILING(Meses_Efectivos_Contables / 2)
    END)
ELSE
    CASE WHEN YEAR(FechaAdquisicion) = YEAR(@Fechafinal) THEN
        CONCAT(@Anio, '-', '01', '-',
        CASE
            WHEN Meses_Efectivos_Contables IS NULL AND Meses_Transcurridos = 0 AND Convencional = 0 THEN 0
            WHEN Meses_Efectivos_Contables IS NULL AND Convencional = 0 THEN 0
            WHEN Meses_Transcurridos = 0 THEN CEILING(12 - Meses_Efectivos_Contables + (Meses_Efectivos_Contables / 2))
            WHEN Meses_Efectivos_Contables = 1 THEN 1
            WHEN Meses_Efectivos_Contables = 0 THEN 1
            ELSE CEILING(Meses_Efectivos_Contables / 2)
        END)
    WHEN Meses_Efectivos_Contables = 0 THEN '1910-01-01'
    END
END AS FechaInpc,

CASE WHEN Convencional = 1 THEN
    CASE
        WHEN Porcentaje_Dep_Contable_Anual = 0 AND Porcentaje_Dep_Fiscal_Anual = 0
            THEN CONCAT(YEAR(FechaAdquisicion), '-', '01', '-', MONTH(FechaAdquisicion))
        WHEN Meses_Efectivos_Contables > 0
            THEN CONCAT(YEAR(FechaAdquisicion), '-', '01', '-', MONTH(FechaAdquisicion))
        WHEN Meses_Efectivos_Contables = 0
            THEN CONCAT(YEAR(FechaAdquisicion), '-', '01', '-', MONTH(FechaAdquisicion))
        ELSE '1910-01-01'   -- FIX-CENTINELA-INPC: antes '1990-01-0' (typo/invalido)
    END
ELSE
    CASE WHEN YEAR(FechaAdquisicion) = YEAR(@Fechafinal) THEN
        CASE WHEN Meses_Efectivos_Contables > 0
            THEN CONCAT(YEAR(FechaAdquisicion), '-', '01', '-', MONTH(FechaAdquisicion))
            ELSE '1910-01-01'   -- FIX-CENTINELA-INPC: antes '1990-01-0' (typo/invalido)
        END
    ELSE
        CASE WHEN Meses_Efectivos_Contables = 0 AND Convencional = 0 THEN '1910-01-01' END
    END
END AS FechaInpcAd,
Convencional

INTO Tmpdateinpcinversion
FROM Tmpcalculocontable CC
INNER JOIN Tmpcalculofiscal CF ON CC.Id = CF.Id;


-- =========================================================================
-- CALCULO FINAL CON INPC  (FIX-PISO-CFF17A)
-- =========================================================================
DROP TABLE IF EXISTS CalculoFinalConvencional;

SELECT
    Id, IdEmpresa, Identificador, FechaAdquisicion, Descripcion,
    Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
    Moi, MoiFiscal, Baja, FechaBaja,
    Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
    DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
    Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
    DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
    ISNULL(INP.Inpc, 1) AS InpcMitadPeriodo,
    ISNULL(INPA.Inpc, 1) AS InpcFechaAdquisicion,
    ISNULL(CASE
        WHEN INP.Inpc = 0 AND INPA.Inpc = 0 THEN 0
        WHEN (INP.Inpc / INPA.Inpc) < 1 THEN 1
        ELSE ROUND(ROUND((INP.Inpc / INPA.Inpc) * 10000, 4) / 10000, 4, 1)
    END, 1) AS Factor_Ajuste,
    ISNULL(CAST(
    CASE
        -- FIX-CENTINELA-INPC: se agrega el chequeo de FechaInpcAd=1910 junto al de FechaInpc
        WHEN (INP.Inpc = 0 AND INPA.Inpc = 0) OR FechaInpc = '1910-01-01' OR FechaInpcAd = '1910-01-01' THEN 0
        WHEN Porcentaje_Dep_Fiscal_Anual = 0 AND Porcentaje_Dep_Contable_Anual = 0 THEN
            CASE WHEN (INP.Inpc / INPA.Inpc) < 1 THEN MoiFiscal * 1
                 ELSE MoiFiscal * ROUND(ROUND((INP.Inpc / INPA.Inpc) * 10000, 4) / 10000, 4, 1)
            END
        ELSE
            CASE WHEN (INP.Inpc / INPA.Inpc) < 1 THEN DepreciacionFiscalInversionAnual * 1
                 ELSE DepreciacionFiscalInversionAnual * ROUND(ROUND((INP.Inpc / INPA.Inpc) * 10000, 4) / 10000, 4, 1)
            END
    END AS DECIMAL(18,2)), 0) AS Deduccion_Fiscal_Inv_Actualizado,
    Convencional
INTO CalculoFinalConvencional
FROM Tmpdateinpcinversion CDE
LEFT JOIN Inpc INP  ON TRY_CONVERT(DATE, CDE.FechaInpc)   = INP.Fecha
LEFT JOIN Inpc INPA ON TRY_CONVERT(DATE, CDE.FechaInpcAd) = INPA.Fecha;


DROP TABLE IF EXISTS Tmpcalculocontable;
DROP TABLE IF EXISTS Tmpcalculofiscal;
DROP TABLE IF EXISTS Tmpdateinpcinversion;
DROP TABLE IF EXISTS Tmpdepreciainmediato;
DROP TABLE IF EXISTS Tmpbajas;


DECLARE @IdPeriodo INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = @EjercicioVigente);
DECLARE @Mes INT = MONTH(@Fechafinal);

INSERT INTO CalculoDetalle_HistoricoBajas (
    IdActivo, IdEmpresa, IdPeriodo, IdMes,
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
    ACT.Id, ACT.IdEmpresa, @IdPeriodo, @Mes,
    Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
    CFC.Moi, CFC.MoiFiscal, CFC.Baja, CFC.FechaBaja,
    Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
    DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
    Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
    DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
    InpcMitadPeriodo, InpcFechaAdquisicion, Factor_Ajuste,
    Deduccion_Fiscal_Inv_Actualizado, CFC.Convencional
FROM CalculoFinalConvencional CFC
INNER JOIN Activos ACT ON CFC.Id = ACT.Id AND CFC.IdEmpresa = ACT.IdEmpresa;

END;
GO


-- ----------------------------
-- procedure structure for VentaBajaActivo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[VentaBajaActivo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[VentaBajaActivo]
GO

CREATE PROCEDURE [dbo].[VentaBajaActivo]
    @IdActivo    INT,
    @FechaVenta  DATE,
    -- FIX-001: era INT. La columna destino ActivosBaja.NumFactura es
    -- nvarchar(40) y la carga masiva ya usa ese tipo de extremo a extremo.
    -- Con INT fallaban los folios con guiones, letras o series (A-123,
    -- FAC-2026-001) y se perdian los ceros a la izquierda (000123 -> 123).
    @NFactura    NVARCHAR(40),
    -- FIX-PRECISION: era DECIMAL sin precision, que SQL Server interpreta
    -- como DECIMAL(18,0) y TRUNCA los centavos antes de llegar a la tabla.
    -- ActivosBaja.PrecioVenta es decimal(10,2).
    @PrecioVenta DECIMAL(18,2),
    @Mbaja       VARCHAR(255)
AS
BEGIN
    -- ============================================================
    -- GUARD: verificar si el activo ya tiene una baja registrada
    -- ============================================================
    DECLARE @ExisteActivoBaja INT;

    SET @ExisteActivoBaja = (
        SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
        FROM ActivosBaja
        WHERE IdActivo = @IdActivo
    );

    IF @ExisteActivoBaja = 0
    BEGIN

        -- ============================================================
        -- VARIABLES BASE
        -- ============================================================
        DECLARE @AnioVenta        INT         = YEAR(@FechaVenta);
        DECLARE @MesVenta         INT         = MONTH(@FechaVenta);
        DECLARE @IdPeriodo        INT         = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = @AnioVenta);
        DECLARE @IdEmpresa        INT         = (SELECT IdEmpresa FROM Activos WHERE Id = @IdActivo);
        DECLARE @FechaAdquisicion DATE        = (SELECT FechaAdquisicion FROM Activos WHERE Id = @IdActivo);

        DECLARE @Fechafinal       DATE        = EOMONTH(DATEADD(MONTH, -1, @FechaVenta));
        DECLARE @EjercicioVigente VARCHAR(4)  = CAST(YEAR(@FechaVenta) AS VARCHAR(4));

        -- ============================================================
        -- FIX-MESESUSO: calcular MesesUso ANTES de llamar a
        -- VentaBajaActivoCalculo para evitar dependencia circular.
        -- ============================================================
        DECLARE @MesesUso INT =
            CASE
                WHEN @AnioVenta = YEAR(@FechaAdquisicion) THEN
                    CASE
                        WHEN (MONTH(@FechaVenta) - 1) - MONTH(@FechaAdquisicion) < 0 THEN 0
                        ELSE (MONTH(@FechaVenta) - 1) - MONTH(@FechaAdquisicion)
                    END
                ELSE
                    CASE
                        WHEN (MONTH(@FechaVenta) - 1) < 1 THEN 0
                        ELSE (MONTH(@FechaVenta) - 1)
                    END
            END;

        -- ============================================================
        -- CALCULO DE BAJA
        -- ============================================================
        DECLARE @ExisteCalculoBaja INT;

        SET @ExisteCalculoBaja = (
            SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
            FROM CalculoDetalle_HistoricoBajas
            WHERE IdActivo = @IdActivo
        );

        IF @ExisteCalculoBaja = 0
        BEGIN
            -- FIX-MESESUSO: pasar @MesesUso como parametro
            EXEC dbo.VentaBajaActivoCalculo
                @IdActivo         = @IdActivo,
                @Fechafinal       = @Fechafinal,
                @IdEmpresa        = @IdEmpresa,
                @EjercicioVigente = @EjercicioVigente,
                @MesesUso         = @MesesUso;
        END

        SET @ExisteCalculoBaja = (
            SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
            FROM CalculoDetalle_HistoricoBajas
            WHERE IdActivo = @IdActivo
        );

        IF @ExisteCalculoBaja = 1
        BEGIN
            BEGIN TRY
                BEGIN TRAN

                    INSERT INTO ActivosBaja (
                        IdEmpresa, IdActivo, IdPeriodo, IdMes,
                        FechaVenta, NumFactura, PrecioVenta, Identificador,
                        ImporteContableDepreciado, RemanenteContableDepreciar,
                        UtilidadContable, PerdidaContable,
                        ImporteFiscalDeducido, AniosDepreciacionFiscalDI,
                        PorcentajeFiscalDI, PorcentajeFiscalAplicarDI,
                        MoiPorcentajeFiscalAplicarDI, RemanentePendienteDeducir,
                        InpcUltimoMesMitadPeriodo, InpcFechaAdquisicion,
                        FactoraAjuste, ValorActualizadoPendienteDeducir,
                        UtilidadFiscalVenta, PerdidaFiscalVenta,
                        MesesUso, FechaProcesado, MotivoBaja
                    )
                    SELECT
                        @IdEmpresa, @IdActivo, @IdPeriodo, @MesVenta,
                        @FechaVenta, @NFactura, @PrecioVenta,
                        0 AS Identificador,

                        -- CONTABLE
                        DepreciacionContableAcumulado AS ImporteContableDepreciado,
                        CDH.Moi - DepreciacionContableAcumulado AS RemanenteContableDepreciar,

                        CASE
                            WHEN (@PrecioVenta - (CDH.Moi - DepreciacionContableAcumulado)) > 0
                                THEN @PrecioVenta - (CDH.Moi - DepreciacionContableAcumulado)
                            ELSE 0
                        END AS UtilidadContable,

                        CASE
                            WHEN (@PrecioVenta - (CDH.Moi - DepreciacionContableAcumulado)) < 0
                                THEN (CDH.Moi - DepreciacionContableAcumulado) - @PrecioVenta
                            ELSE 0
                        END AS PerdidaContable,

                        -- FISCAL
                        DepreciacionFiscalAcumulado AS ImporteFiscalDeducido,

                        CASE
                            WHEN CDH.Convencional = 0
                                THEN FLOOR(DATEDIFF(YEAR, ACT.FechaAdquisicion, @AnioVenta) + 1)
                            ELSE 0
                        END AS AniosDepreciacionFiscalDI,

                        CASE
                            WHEN CDH.Convencional = 0 THEN CDH.Porcentaje_Dep_Fiscal_Anual
                            ELSE 0
                        END AS PorcentajeFiscalDI,

                        0.00 AS PorcentajeFiscalAplicarDI,

                        CASE
                            WHEN CDH.Convencional = 0
                                AND FLOOR(DATEDIFF(YEAR, ACT.FechaAdquisicion, @AnioVenta) + 1) > 0
                                THEN CDH.MoiFiscal * 0.00
                            ELSE 0
                        END AS MoiPorcentajeFiscalAplicarDI,

                        CASE
                            WHEN CDH.Porcentaje_Dep_Fiscal_Anual = 0
                             AND CDH.Porcentaje_Dep_Contable_Anual = 0
                                THEN CDH.Deduccion_Fiscal_Inv_Actualizado
                            WHEN CDH.Convencional = 1
                                THEN (CDH.MoiFiscal - DepreciacionFiscalAcumulado)
                            ELSE 0.00
                        END AS RemanentePendienteDeducir,

                        -- INPC
                        InpcMitadPeriodo    AS InpcUltimoMesMitadPeriodo,
                        InpcFechaAdquisicion,
                        Factor_Ajuste       AS FactoraAjuste,
                        CDH.Deduccion_Fiscal_Inv_Actualizado AS ValorActualizadoPendienteDeducir,

                        -- RESULTADO FISCAL
                        CASE
                            WHEN (@PrecioVenta - CDH.Deduccion_Fiscal_Inv_Actualizado) > 0
                                THEN @PrecioVenta - CDH.Deduccion_Fiscal_Inv_Actualizado
                            ELSE 0
                        END AS UtilidadFiscalVenta,

                        CASE
                            WHEN (@PrecioVenta - CDH.Deduccion_Fiscal_Inv_Actualizado) < 0
                                THEN CDH.Deduccion_Fiscal_Inv_Actualizado - @PrecioVenta
                            ELSE 0
                        END AS PerdidaFiscalVenta,

                        @MesesUso AS MesesUso,
                        GETDATE() AS FechaProcesado,
                        @Mbaja

                    FROM CalculoDetalle_HistoricoBajas CDH
                    INNER JOIN Activos ACT ON CDH.IdActivo = ACT.Id
                    WHERE CDH.IdActivo = @IdActivo;

                    -- Actualizar FechaBaja en Activos
                    UPDATE ACT
                    SET ACT.FechaBaja = @FechaVenta
                    FROM Activos ACT
                    WHERE ACT.Id = @IdActivo;

                    -- Limpieza de tablas temporales
                    IF OBJECT_ID('CalculoFinalConvencional', 'U') IS NOT NULL
                        DROP TABLE CalculoFinalConvencional;
                    IF OBJECT_ID('ActivosBajas', 'U') IS NOT NULL
                        DROP TABLE ActivosBajas;
                    IF OBJECT_ID('MensualConvencionalContable', 'U') IS NOT NULL
                        DROP TABLE MensualConvencionalContable;
                    IF OBJECT_ID('MensualConvencionalFiscal', 'U') IS NOT NULL
                        DROP TABLE MensualConvencionalFiscal;
                    IF OBJECT_ID('ActivosDepreciacion', 'U') IS NOT NULL
                        DROP TABLE ActivosDepreciacion;

                COMMIT TRAN

            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0
                    ROLLBACK TRAN;

                DECLARE @ErrorMsg       NVARCHAR(4000) = ERROR_MESSAGE();
                DECLARE @ErrorSeverity  INT            = ERROR_SEVERITY();
                DECLARE @ErrorState     INT            = ERROR_STATE();

                RAISERROR(@ErrorMsg, @ErrorSeverity, @ErrorState);
            END CATCH

        END -- IF @ExisteCalculoBaja = 1
    END -- IF @ExisteActivoBaja = 0
END;
GO


-- ----------------------------
-- function structure for DepreciacionPeriodo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[DepreciacionPeriodo]') AND type IN ('FN', 'FS', 'FT', 'IF', 'TF'))
	DROP FUNCTION[dbo].[DepreciacionPeriodo]
GO

CREATE FUNCTION [dbo].[DepreciacionPeriodo](
    @Monto DECIMAL(18,2),
    @PorcentajeAnual DECIMAL(10,4),
    @Meses INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @DepreciacionMensual DECIMAL(18,2);
    DECLARE @VidaUtilMeses INT;
    
    IF ISNULL(@PorcentajeAnual, 0) <= 0 OR ISNULL(@Meses, 0) <= 0
        RETURN 0;
    
    SET @VidaUtilMeses = 12 / @PorcentajeAnual;
    
    IF @Meses >= @VidaUtilMeses
        RETURN @Monto;
    
    SET @DepreciacionMensual = (@Monto * @PorcentajeAnual) / 12;
    
    RETURN @DepreciacionMensual * @Meses;
END;
GO


-- ----------------------------
-- function structure for MesesCompletosLISR
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[MesesCompletosLISR]') AND type IN ('FN', 'FS', 'FT', 'IF', 'TF'))
	DROP FUNCTION[dbo].[MesesCompletosLISR]
GO

CREATE FUNCTION [dbo].[MesesCompletosLISR](
    @FechaInicio DATE,
    @FechaFin DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Meses INT = 0;
    
    IF @FechaInicio > @FechaFin
        RETURN 0;
    
    SET @Meses = (YEAR(@FechaFin) * 12 + MONTH(@FechaFin)) 
               - (YEAR(@FechaInicio) * 12 + MONTH(@FechaInicio));
    
    IF DAY(@FechaInicio) > 1
        SET @Meses = @Meses - 1;
    
    RETURN CASE WHEN @Meses < 0 THEN 0 ELSE @Meses END;
END;
GO


-- ----------------------------
-- procedure structure for sp_ConsultaActivos
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ConsultaActivos]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[sp_ConsultaActivos]
GO

CREATE PROCEDURE [dbo].[sp_ConsultaActivos]
    @IdEmpresa        int,
    @Texto            nvarchar(200) = NULL,   -- búsqueda por palabras (todas deben aparecer)
    @Estado           varchar(20)   = NULL,   -- 'vigente' | 'agotado' | 'transito' | 'sincalc' | 'baja'
    @Saldo            varchar(10)   = NULL,   -- 'cero' | 'pos' | 'sincalc'
    @Bajas            varchar(10)   = NULL,   -- 'solo' | 'sin'
    @Convencional     varchar(10)   = NULL,   -- lista '0,1'
    @IdsCatalogo      varchar(max)  = NULL,   -- lista de IdCatalogo separada por comas
    @AdqDesde         date          = NULL,
    @AdqHasta         date          = NULL,
    @UsoDesde         date          = NULL,
    @UsoHasta         date          = NULL,
    @MoiMin           decimal(18,2) = NULL,
    @MoiMax           decimal(18,2) = NULL,
    @PermitirTransito bit           = 0,      -- espejo de appSettings["Activos.PermitirTransito"]
    @Resultado        tinyint       = 0       -- 0 ambos | 1 detalle | 2 resumen
AS
BEGIN
    SET NOCOUNT ON;

    -- -------------------------------------------------------------------------
    -- 1. Validación de parámetros
    -- -------------------------------------------------------------------------
    SET @Estado       = NULLIF(LOWER(LTRIM(RTRIM(@Estado))), '');
    SET @Saldo        = NULLIF(LOWER(LTRIM(RTRIM(@Saldo))), '');
    SET @Bajas        = NULLIF(LOWER(LTRIM(RTRIM(@Bajas))), '');
    SET @Convencional = NULLIF(LTRIM(RTRIM(@Convencional)), '');
    SET @IdsCatalogo  = NULLIF(LTRIM(RTRIM(@IdsCatalogo)), '');
    SET @Texto        = NULLIF(LTRIM(RTRIM(@Texto)), N'');
    SET @PermitirTransito = ISNULL(@PermitirTransito, 0);
    SET @Resultado        = ISNULL(@Resultado, 0);

    IF @IdEmpresa IS NULL
    BEGIN RAISERROR(N'Debe indicar @IdEmpresa.', 16, 1); RETURN; END

    IF @Estado IS NOT NULL AND @Estado NOT IN ('vigente', 'agotado', 'transito', 'sincalc', 'baja')
    BEGIN RAISERROR(N'@Estado no válido. Valores: vigente, agotado, transito, sincalc, baja.', 16, 1); RETURN; END

    IF @Saldo IS NOT NULL AND @Saldo NOT IN ('cero', 'pos', 'sincalc')
    BEGIN RAISERROR(N'@Saldo no válido. Valores: cero, pos, sincalc.', 16, 1); RETURN; END

    IF @Bajas IS NOT NULL AND @Bajas NOT IN ('solo', 'sin')
    BEGIN RAISERROR(N'@Bajas no válido. Valores: solo, sin.', 16, 1); RETURN; END

    IF @Resultado NOT IN (0, 1, 2)
    BEGIN RAISERROR(N'@Resultado no válido. Valores: 0, 1, 2.', 16, 1); RETURN; END

    IF @AdqDesde > @AdqHasta OR @UsoDesde > @UsoHasta OR @MoiMin > @MoiMax
    BEGIN RAISERROR(N'Rango no válido: el valor inicial es mayor que el final.', 16, 1); RETURN; END

    -- Listas: solo valores numéricos válidos. Una lista indicada sin ningún
    -- valor válido filtra a vacío (no se ignora en silencio).
    DECLARE @Conv TABLE (Valor tinyint PRIMARY KEY);
    IF @Convencional IS NOT NULL
        INSERT INTO @Conv (Valor)
        SELECT DISTINCT TRY_CAST(LTRIM(RTRIM(value)) AS tinyint)
        FROM STRING_SPLIT(@Convencional, ',')
        WHERE TRY_CAST(LTRIM(RTRIM(value)) AS tinyint) IN (0, 1);

    DECLARE @Cat TABLE (IdCatalogo int PRIMARY KEY);
    IF @IdsCatalogo IS NOT NULL
        INSERT INTO @Cat (IdCatalogo)
        SELECT DISTINCT TRY_CAST(LTRIM(RTRIM(value)) AS int)
        FROM STRING_SPLIT(@IdsCatalogo, ',')
        WHERE TRY_CAST(LTRIM(RTRIM(value)) AS int) > 0;

    -- Palabras de búsqueda (máximo 10), con los comodines de LIKE escapados.
    DECLARE @Pal TABLE (Patron nvarchar(420) NOT NULL);
    IF @Texto IS NOT NULL
        INSERT INTO @Pal (Patron)
        SELECT DISTINCT TOP (10)
               N'%' + REPLACE(REPLACE(REPLACE(W.Palabra, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%'
        FROM (SELECT LTRIM(RTRIM(value)) AS Palabra
              FROM STRING_SPLIT(REPLACE(REPLACE(@Texto, NCHAR(9), N' '), NCHAR(160), N' '), N' ')) W
        WHERE W.Palabra <> N'';

    DECLARE @HayTexto bit = CASE WHEN EXISTS (SELECT 1 FROM @Pal) THEN 1 ELSE 0 END;

    -- -------------------------------------------------------------------------
    -- 2. Último cálculo de la empresa (por año real y mes, como par)
    -- -------------------------------------------------------------------------
    DECLARE @UltIdPeriodo int, @UltPeriodo int, @UltMes int;

    SELECT TOP (1) @UltIdPeriodo = CDH.IdPeriodo,
                   @UltPeriodo   = CPE.Periodo,
                   @UltMes       = CDH.IdMes
    FROM dbo.CalculoDetalle_Historico CDH
    JOIN dbo.CatalogoPeriodo CPE ON CPE.Id = CDH.IdPeriodo
    WHERE CDH.IdEmpresa = @IdEmpresa
    ORDER BY CPE.Periodo DESC, CDH.IdMes DESC;

    -- -------------------------------------------------------------------------
    -- 3. Base: todos los activos de la empresa con su saldo y estado
    -- -------------------------------------------------------------------------
    DROP TABLE IF EXISTS #Base;

    SELECT A.Id,
           A.Descripcion,
           A.Identificador,
           A.IdCatalogo,
           ISNULL(CC.Grupo, 'Sin tipo')                                        AS TipoActivo,
           A.Convencional,
           CAST(CASE WHEN A.Convencional = 1 THEN 'Convencional' ELSE 'Acelerada' END
                AS varchar(12))                                                AS TipoDepreciacion,
           A.PorcentajeDepFIscalAnual,
           A.PorcentajeDepContableAnual,
           A.Moi,
           A.MoiFiscal,
           A.FechaAdquisicion,
           A.FechaUso,
           CASE WHEN @PermitirTransito = 1 THEN A.FechaUso
                ELSE COALESCE(A.FechaUso, A.FechaAdquisicion) END              AS FechaUsoEfectiva,
           CAST(CASE WHEN A.FechaUso IS NULL THEN 1 ELSE 0 END AS bit)         AS SinFechaUso,
           A.FechaBaja,
           S.SaldoContable,
           @UltPeriodo                                                         AS PeriodoSaldo,
           @UltMes                                                             AS MesSaldo,
           Z.Periodo                                                           AS PeriodoCongelado,
           Z.IdMes                                                             AS MesCongelado
    INTO #Base
    FROM dbo.Activos A
    LEFT JOIN dbo.CatalogoCuentas CC
           ON CC.Id = A.IdCatalogo
    -- Último cálculo (vivos)
    LEFT JOIN dbo.CalculoDetalle_Historico U
           ON U.IdEmpresa    = A.IdEmpresa
          AND U.IdPeriodo    = @UltIdPeriodo
          AND U.IdMes        = @UltMes
          AND U.IdActivo     = A.Id
          AND U.Convencional = A.Convencional
    -- Registro congelado (bajas), regla de #BajasRecientes
    OUTER APPLY (
        SELECT TOP (1) CZ.IdActivo, CPZ.Periodo, CZ.IdMes,
               CZ.SaldoContablePorDeducir, CZ.DepreciacionContableInversionAnual
        FROM dbo.CatalogoPeriodo CPZ
        JOIN dbo.CalculoDetalle_Historico CZ
          ON CZ.IdPeriodo    = CPZ.Id
         AND CZ.IdEmpresa    = A.IdEmpresa
         AND CZ.IdActivo     = A.Id
         AND CZ.Convencional = A.Convencional
        WHERE A.FechaBaja IS NOT NULL
          AND CPZ.Periodo = CASE WHEN MONTH(A.FechaBaja) = 1 THEN YEAR(A.FechaBaja) - 1 ELSE YEAR(A.FechaBaja) END
          AND CZ.IdMes    = CASE WHEN MONTH(A.FechaBaja) = 1 THEN 12 ELSE MONTH(A.FechaBaja) - 1 END
    ) Z
    CROSS APPLY (
        SELECT CAST(
            CASE
                WHEN ISNULL(A.PorcentajeDepContableAnual, 0) = 0 THEN A.Moi
                WHEN A.FechaBaja IS NOT NULL THEN
                    CASE WHEN Z.IdActivo IS NULL THEN NULL
                         WHEN ISNULL(Z.SaldoContablePorDeducir, 0) - ISNULL(Z.DepreciacionContableInversionAnual, 0) < 0 THEN 0
                         ELSE ISNULL(Z.SaldoContablePorDeducir, 0) - ISNULL(Z.DepreciacionContableInversionAnual, 0)
                    END
                ELSE
                    CASE WHEN U.IdActivo IS NULL THEN NULL
                         WHEN ISNULL(U.SaldoContablePorDeducir, 0) - ISNULL(U.DepreciacionContableInversionAnual, 0) < 0 THEN 0
                         ELSE ISNULL(U.SaldoContablePorDeducir, 0) - ISNULL(U.DepreciacionContableInversionAnual, 0)
                    END
            END AS decimal(18,2)) AS SaldoContable
    ) S
    WHERE A.IdEmpresa = @IdEmpresa;

    -- -------------------------------------------------------------------------
    -- 4. Estado y filtros (todos menos @Estado)
    -- -------------------------------------------------------------------------
    DROP TABLE IF EXISTS #Filtrado;

    SELECT B.*,
           CAST(CASE WHEN B.SaldoContable IS NULL OR ISNULL(B.Moi, 0) = 0 THEN NULL
                     ELSE B.SaldoContable * 100.0 / B.Moi END AS decimal(9,2)) AS PorcentajeSaldo,
           E.Estado
    INTO #Filtrado
    FROM #Base B
    CROSS APPLY (
        SELECT CAST(
            CASE
                WHEN B.FechaBaja IS NOT NULL                                          THEN 'baja'
                WHEN @PermitirTransito = 1 AND B.FechaUso IS NULL                     THEN 'transito'
                WHEN B.SaldoContable IS NULL                                          THEN 'sincalc'
                WHEN ISNULL(B.PorcentajeDepContableAnual, 0) > 0 AND B.SaldoContable = 0 THEN 'agotado'
                ELSE 'vigente'
            END AS varchar(10)) AS Estado
    ) E
    WHERE (@Saldo IS NULL
           OR (@Saldo = 'cero'    AND B.SaldoContable = 0)
           OR (@Saldo = 'pos'     AND B.SaldoContable > 0)
           OR (@Saldo = 'sincalc' AND B.SaldoContable IS NULL))
      AND (@Bajas IS NULL
           OR (@Bajas = 'solo' AND B.FechaBaja IS NOT NULL)
           OR (@Bajas = 'sin'  AND B.FechaBaja IS NULL))
      AND (@Convencional IS NULL OR B.Convencional IN (SELECT Valor FROM @Conv))
      AND (@IdsCatalogo  IS NULL OR B.IdCatalogo   IN (SELECT IdCatalogo FROM @Cat))
      AND (@AdqDesde IS NULL OR B.FechaAdquisicion >= @AdqDesde)
      AND (@AdqHasta IS NULL OR B.FechaAdquisicion <= @AdqHasta)
      AND (@UsoDesde IS NULL OR B.FechaUsoEfectiva >= @UsoDesde)
      AND (@UsoHasta IS NULL OR B.FechaUsoEfectiva <= @UsoHasta)
      AND (@MoiMin   IS NULL OR B.Moi >= @MoiMin)
      AND (@MoiMax   IS NULL OR B.Moi <= @MoiMax)
      -- Búsqueda: TODAS las palabras deben aparecer (sin acentos ni mayúsculas)
      -- en los datos del activo o en un detalle vigente (Serie, ClaveVehicular).
      AND (@HayTexto = 0 OR NOT EXISTS (
            SELECT 1
            FROM @Pal P
            WHERE NOT (
                   CONCAT_WS(N' ', B.Descripcion, B.Identificador, B.TipoActivo,
                             CAST(B.Id AS varchar(12)),
                             CAST(B.Moi AS varchar(30)),
                             CONVERT(varchar(30), CAST(B.Moi AS money), 1))
                       COLLATE Modern_Spanish_CI_AI LIKE P.Patron
                OR EXISTS (
                   SELECT 1
                   FROM dbo.ActivosDetalle D
                   WHERE D.IdActivo = B.Id
                     AND D.Borrado IS NULL
                     AND CONCAT_WS(N' ', D.Serie, D.ClaveVehicular)
                             COLLATE Modern_Spanish_CI_AI LIKE P.Patron)
            )
      ));

    -- -------------------------------------------------------------------------
    -- 5. Result set 1: detalle (con @Estado)
    -- -------------------------------------------------------------------------
    IF @Resultado IN (0, 1)
        SELECT Id, Descripcion, Identificador, IdCatalogo, TipoActivo,
               Convencional, TipoDepreciacion,
               PorcentajeDepFIscalAnual, PorcentajeDepContableAnual,
               Moi, MoiFiscal,
               FechaAdquisicion, FechaUso, FechaUsoEfectiva, SinFechaUso, FechaBaja,
               SaldoContable, PorcentajeSaldo, Estado,
               PeriodoSaldo, MesSaldo, PeriodoCongelado, MesCongelado
        FROM #Filtrado
        WHERE @Estado IS NULL OR Estado = @Estado
        ORDER BY FechaAdquisicion DESC, Id DESC;

    -- -------------------------------------------------------------------------
    -- 6. Result set 2: resumen por estado (SIN @Estado), para la barra
    -- -------------------------------------------------------------------------
    IF @Resultado IN (0, 2)
        SELECT E.Estado,
               COUNT(F.Id)          AS Activos,
               ISNULL(SUM(F.Moi), 0) AS MoiTotal
        FROM (VALUES ('vigente', 1), ('agotado', 2), ('sincalc', 3), ('transito', 4), ('baja', 5)) E (Estado, Orden)
        LEFT JOIN #Filtrado F ON F.Estado = E.Estado
        WHERE E.Estado <> 'transito' OR @PermitirTransito = 1
        GROUP BY E.Estado, E.Orden
        ORDER BY E.Orden;

    DROP TABLE IF EXISTS #Filtrado;
    DROP TABLE IF EXISTS #Base;
END
GO


-- ----------------------------
-- procedure structure for sp_EstadoCierresPeriodo
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_EstadoCierresPeriodo]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[sp_EstadoCierresPeriodo]
GO

CREATE PROCEDURE [dbo].[sp_EstadoCierresPeriodo]
    @IdEmpresa INT,
    @Periodo   INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Meses AS (
        SELECT Mes = 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
        UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    ),
    Cierres AS (
        SELECT H.IdMes, Activos = COUNT(DISTINCT H.IdActivo),
               Ultima = MAX(H.FechaProcesado)
        FROM dbo.CalculoDetalle_Historico H
        INNER JOIN dbo.CatalogoPeriodo CP ON CP.Id = H.IdPeriodo
        WHERE H.IdEmpresa = @IdEmpresa AND CP.Periodo = @Periodo
        GROUP BY H.IdMes
    ),
    -- Meses de los que depende el reporte por las bajas del ejercicio
    Dependencias AS (
        SELECT DISTINCT
            Mes_Reporte = MONTH(A.FechaBaja),
            Mes_Requerido = CASE WHEN MONTH(A.FechaBaja) = 1 THEN 12 ELSE MONTH(A.FechaBaja) - 1 END,
            Periodo_Requerido = CASE WHEN MONTH(A.FechaBaja) = 1 THEN @Periodo - 1 ELSE @Periodo END
        FROM dbo.Activos A
        WHERE A.IdEmpresa = @IdEmpresa AND YEAR(A.FechaBaja) = @Periodo
    )
    SELECT
        M.Mes,
        Calculado = CASE WHEN C.IdMes IS NULL THEN 0 ELSE 1 END,
        C.Activos,
        C.Ultima AS UltimoCalculo,
        Dependencias_Faltantes = (
            SELECT COUNT(*)
            FROM Dependencias D
            WHERE D.Mes_Reporte <= M.Mes
              AND NOT EXISTS (
                  SELECT 1 FROM dbo.CalculoDetalle_Historico H2
                  INNER JOIN dbo.CatalogoPeriodo CP2 ON CP2.Id = H2.IdPeriodo
                  WHERE H2.IdEmpresa = @IdEmpresa
                    AND CP2.Periodo = D.Periodo_Requerido
                    AND H2.IdMes    = D.Mes_Requerido)
        ),
        Estado = CASE
            WHEN C.IdMes IS NULL THEN 'SIN CALCULAR'
            WHEN EXISTS (
                SELECT 1 FROM Dependencias D
                WHERE D.Mes_Reporte <= M.Mes
                  AND NOT EXISTS (
                      SELECT 1 FROM dbo.CalculoDetalle_Historico H2
                      INNER JOIN dbo.CatalogoPeriodo CP2 ON CP2.Id = H2.IdPeriodo
                      WHERE H2.IdEmpresa = @IdEmpresa
                        AND CP2.Periodo = D.Periodo_Requerido
                        AND H2.IdMes    = D.Mes_Requerido)
            ) THEN 'INCOMPLETO'
            ELSE 'OK' END
    FROM Meses M
    LEFT JOIN Cierres C ON C.IdMes = M.Mes
    ORDER BY M.Mes;
END
GO


-- ----------------------------
-- procedure structure for CrearTabla
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CrearTabla]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[CrearTabla]
GO

CREATE PROCEDURE [dbo].[CrearTabla]
AS
BEGIN


IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[MensualConvencionalContable]') AND type IN ('U'))
	DROP TABLE [dbo].[MensualConvencionalContable];

CREATE TABLE [dbo].[MensualConvencionalContable] (
  [Id] int  NULL,
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
);


IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[MensualConvencionalFiscal]') AND type IN ('U'))
	DROP TABLE [dbo].[MensualConvencionalFiscal];

CREATE TABLE [dbo].[MensualConvencionalFiscal] (
  [Id] int  NULL,
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
);

IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[ActivosDepreciacion]') AND type IN ('U'))
	DROP TABLE [dbo].[ActivosDepreciacion];

CREATE TABLE [dbo].[ActivosDepreciacion] (
  [Id] int  IDENTITY(1,1) NOT NULL,
  [IdEmpresa] int  NOT NULL,
  [Identificador] varchar(255) COLLATE Modern_Spanish_CI_AS  NULL,
  [IdCatalogo] int  NOT NULL,
  [FechaAdquisicion] date  NOT NULL,
  [Descripcion] varchar(255) COLLATE Modern_Spanish_CI_AS  NOT NULL,
  [Moi] decimal(18,2)  NOT NULL,
  [MoiFiscal] decimal(18,2)  NOT NULL,
  [Baja] decimal(18,2) DEFAULT 0.00 NULL,
  [FechaBaja] date  NULL,
  [Convencional] tinyint DEFAULT 1 NOT NULL,
  [FechaProcesado] datetime DEFAULT getdate() NOT NULL,
  [PorcentajeDepFIscalAnual] float(53)  NULL,
  [PorcentajeDepContableAnual] float(53)  NULL
);



END
GO


-- ----------------------------
-- procedure structure for CalculoDepreciacionMensual_copy1
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoDepreciacionMensual_copy1]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[CalculoDepreciacionMensual_copy1]
GO

CREATE PROCEDURE [dbo].[CalculoDepreciacionMensual_copy1]
    @Fechafinal       DATE,
    @IdEmpresa        INT,
    @EjercicioVigente VARCHAR(4)
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

EXEC [dbo].[CrearTabla]

DECLARE @AnioActual    AS INT = YEAR(@Fechafinal);
DECLARE @MesConsultado AS INT = MONTH(@Fechafinal);

-- =========================================================================
-- [ 1. TABLA TEMPORAL BASE CON ACTIVOS A PROCESAR ]
-- =========================================================================
DROP TABLE IF EXISTS #ActivosBase;

SELECT
    AD.Id,
    AD.IdEmpresa,
    AD.Identificador,
    -- FIX-FECHAUSO: se llevan AMBAS fechas.
    --   FechaAdquisicion -> INPC y factor de actualizacion (LISR art. 31: el
    --                       INPC es "del mes en que se adquirio el bien")
    --   FechaUso         -> meses transcurridos y meses efectivos
    AD.FechaAdquisicion,
    AD.FechaUso,
    AD.IdCatalogo,
    CC.Grupo AS Descripcion,
    AD.PorcentajeDepFIscalAnual   AS Porcentaje_Dep_Fiscal_Anual,
    AD.PorcentajeDepContableAnual AS Porcentaje_Dep_Contable_Anual,
    AD.Moi,
    AD.MoiFiscal,
    AD.Baja,

    -- FIX-B: FechaBaja se pasa siempre que exista en el año actual o anterior.
    -- Bajas de ejercicios futuros se ignoran (NULL).
    -- La función MesesEfectivosAnioActual decide los meses efectivos según el mes de corte.
    CASE
        WHEN AD.FechaBaja IS NULL
            THEN NULL
        WHEN YEAR(AD.FechaBaja) = @AnioActual
            THEN DATEFROMPARTS(YEAR(AD.FechaBaja), MONTH(AD.FechaBaja), 1)
        WHEN YEAR(AD.FechaBaja) < @AnioActual
            THEN AD.FechaBaja
        ELSE NULL  -- baja de año futuro, se ignora
    END AS FechaBaja,

    AD.Convencional,
    -- Meses_Transcurridos: meses completos hasta dic del año anterior
    -- FIX-FECHAUSO: los meses transcurridos se cuentan desde el INICIO DE USO.
    -- Con FechaAdquisicion, un activo con la fecha corrida habria terminado su
    -- vida util un mes antes de lo que le corresponde y perderia esa deduccion.
    CASE
        WHEN DATEDIFF(MONTH, AD.FechaUso, @Fechafinal) < 0 THEN 0
        ELSE
            CASE
                WHEN 12 - MONTH(AD.FechaUso) + ((YEAR(@Fechafinal) - YEAR(AD.FechaUso)) - 1) * 12 < 0 THEN 0
                ELSE 12 - MONTH(AD.FechaUso) + ((YEAR(@Fechafinal) - YEAR(AD.FechaUso)) - 1) * 12
            END
    END AS Meses_Transcurridos

INTO #ActivosBase
FROM Activos AD
INNER JOIN CatalogoCuentas CC ON AD.IdCatalogo = CC.Id
WHERE AD.IdEmpresa = @IdEmpresa
  AND (AD.FechaBaja IS NULL OR AD.FechaBaja >= DATEFROMPARTS(@AnioActual - 1, 1, 1))
  -- =======================================================================
  -- FIX-ADQ-UNIVERSO: un activo no forma parte del universo de un
  -- ejercicio anterior a su fecha de adquisicion. Sin esta condicion, un
  -- bien comprado en 2026 aparecia en el reporte de 2024 aportando su MOI
  -- y su saldo por deducir (ya no su depreciacion, eso lo corrige FIX-ADQ
  -- en MesesEfectivosAnioActual).
  -- Observado en 2024 (RFC SAM140108MY1): activos 8956, 8957 y 11732,
  -- 101,694.78 de MOI que el Excel del ejercicio no contiene.
  -- Se compara la FECHA COMPLETA contra el fin del mes de corte.
  -- =======================================================================
  -- FIX-FECHAUSO: el filtro sigue usando FechaAdquisicion a proposito. Un bien
  -- comprado en agosto y puesto en uso en septiembre SI pertenece al universo de
  -- agosto -aporta MOI y saldo por deducir-; simplemente aun no deprecia, y de
  -- eso se encarga MesesEfectivosAnioActual. Cambiarlo por FechaUso lo haria
  -- desaparecer del reporte de ese mes.
  AND AD.FechaAdquisicion <= EOMONTH(DATEFROMPARTS(@AnioActual, @MesConsultado, 1));


-- =========================================================================
-- [ 2. CALCULO CONTABLE - HISTORICO ]  (criterio VIEJO: historico = solo Meses_Transcurridos)
-- =========================================================================
DROP TABLE IF EXISTS Tmpcalculocontable;

SELECT
    BASE.Id,
    BASE.IdEmpresa,
    BASE.Identificador,
    BASE.FechaAdquisicion,
    BASE.FechaUso,
    BASE.IdCatalogo,
    BASE.Descripcion,
    BASE.Meses_Transcurridos,
    BASE.Porcentaje_Dep_Fiscal_Anual,
    BASE.Porcentaje_Dep_Contable_Anual,
    BASE.Moi,
    BASE.MoiFiscal,
    BASE.Baja,
    BASE.FechaBaja,
    BASE.Convencional,

    -- FIX-FECHAUSO: los meses efectivos se cuentan desde el inicio de uso.
    dbo.MesesEfectivosAnioActual(
        BASE.FechaUso, BASE.FechaBaja, BASE.Porcentaje_Dep_Contable_Anual,
        @MesConsultado, BASE.Meses_Transcurridos, @AnioActual
    ) AS Meses_Efectivos_Contables,

    -- Historico contable = SOLO Meses_Transcurridos (meses hasta dic año anterior)
    CAST(
        CASE WHEN ISNULL(BASE.Porcentaje_Dep_Contable_Anual, 0) > 0 THEN
            CASE WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Contable_Anual, 0))
                THEN BASE.Moi
                ELSE ((BASE.Moi * BASE.Porcentaje_Dep_Contable_Anual) / 12) * BASE.Meses_Transcurridos
            END
        END
    AS DECIMAL(18,2)) AS DeduccionContableInvHistorico,

    CAST(
        CASE WHEN ISNULL(BASE.Porcentaje_Dep_Contable_Anual, 0) > 0 THEN
            CASE WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Contable_Anual, 0))
                THEN 0
                ELSE BASE.Moi - (((BASE.Moi * BASE.Porcentaje_Dep_Contable_Anual) / 12) * BASE.Meses_Transcurridos)
            END
        END
    AS DECIMAL(18,2)) AS SaldoContablePorDeducir

INTO Tmpcalculocontable
FROM #ActivosBase BASE;


-- =========================================================================
-- [ 3. CALCULO FISCAL - HISTORICO ]  (criterio VIEJO)
-- =========================================================================
DROP TABLE IF EXISTS Tmpcalculofiscal;

SELECT
    BASE.Id,
    -- FIX-FECHAUSO: los meses efectivos se cuentan desde el inicio de uso.
    dbo.MesesEfectivosAnioActual(
        BASE.FechaUso, BASE.FechaBaja, BASE.Porcentaje_Dep_Fiscal_Anual,
        @MesConsultado, BASE.Meses_Transcurridos, @AnioActual
    ) AS Meses_Efectivos_Fiscales,

    -- Historico fiscal = SOLO Meses_Transcurridos (convencional) / logica inmediato VIEJO
    CAST(
        CASE WHEN BASE.Convencional = 1 THEN
            CASE WHEN ISNULL(BASE.Porcentaje_Dep_Fiscal_Anual, 0) > 0 THEN
                -- Energias renovables: deduccion inmediata 100%, no acumula historico convencional
                CASE WHEN BASE.IdCatalogo = 8 AND BASE.Porcentaje_Dep_Fiscal_Anual = 1 THEN 0
                     WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Fiscal_Anual, 0))
                        THEN BASE.MoiFiscal
                     ELSE ((BASE.MoiFiscal * BASE.Porcentaje_Dep_Fiscal_Anual) / 12) * BASE.Meses_Transcurridos
                END
            ELSE 0
            END
        ELSE
            -- Fiscal inmediato
            CASE
                WHEN BASE.Meses_Transcurridos = 1 THEN 0
                WHEN (YEAR(BASE.FechaAdquisicion) = 2015 AND MONTH(BASE.FechaAdquisicion) IN (9,10,11,12)) THEN 0
                ELSE ISNULL(BASE.MoiFiscal * BASE.Porcentaje_Dep_Fiscal_Anual, 0)
            END
        END
    AS DECIMAL(18,2)) AS DeduccionFiscalInvHistorico,

    CAST(
        CASE WHEN BASE.Convencional = 1 THEN
            CASE WHEN ISNULL(BASE.Porcentaje_Dep_Fiscal_Anual, 0) > 0 THEN
                CASE WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Fiscal_Anual, 0))
                    THEN 0
                    ELSE BASE.MoiFiscal - (((BASE.MoiFiscal * BASE.Porcentaje_Dep_Fiscal_Anual) / 12) * BASE.Meses_Transcurridos)
                END
            ELSE BASE.MoiFiscal
            END
        ELSE
            -- Fiscal inmediato
            CASE
                WHEN BASE.Meses_Transcurridos = 1 THEN BASE.MoiFiscal
                WHEN (YEAR(BASE.FechaAdquisicion) = @EjercicioVigente AND MONTH(BASE.FechaAdquisicion) IN (9,10,11,12)) THEN BASE.MoiFiscal
                ELSE 0
            END
        END
    AS DECIMAL(18,2)) AS SaldoFiscalPorDeducir

INTO Tmpcalculofiscal
FROM #ActivosBase BASE;


-- =========================================================================
-- [ 4. FECHA INPC Y CALCULOS ANUALES CONTROLADOS ]
-- =========================================================================
DROP TABLE IF EXISTS Tmpdateinpcinversion;

SELECT
    CC.Id, CC.IdEmpresa, CC.Identificador, CC.FechaAdquisicion, CC.Descripcion,
    CC.Meses_Transcurridos, CC.Porcentaje_Dep_Fiscal_Anual, CC.Porcentaje_Dep_Contable_Anual,
    CC.Moi, CC.MoiFiscal, CC.Baja, CC.FechaBaja,
    CC.Meses_Efectivos_Contables, CC.DeduccionContableInvHistorico, CC.SaldoContablePorDeducir,

    -- FIX-C: DepAnual contable topa en SaldoContablePorDeducir
    CAST(
    CASE
        WHEN CC.Moi = CC.DeduccionContableInvHistorico THEN 0
        WHEN ISNULL(CC.Porcentaje_Dep_Contable_Anual, 0) <= 0 THEN 0
        ELSE
            CASE
                WHEN (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
                     > CC.SaldoContablePorDeducir
                THEN CC.SaldoContablePorDeducir
                ELSE (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
            END
    END AS DECIMAL(18,2)) AS DepreciacionContableInversionAnual,

    -- FIX-C: Acumulado contable topa en MOI
    CAST(
    CASE
        WHEN CC.Moi = CC.DeduccionContableInvHistorico THEN CC.DeduccionContableInvHistorico
        ELSE
            CASE
                WHEN (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
                     + CC.DeduccionContableInvHistorico > CC.Moi
                THEN CC.Moi
                ELSE (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
                     + CC.DeduccionContableInvHistorico
            END
    END AS DECIMAL(18,2)) AS DepreciacionContableAcumulado,

    CF.Meses_Efectivos_Fiscales, CF.DeduccionFiscalInvHistorico, CF.SaldoFiscalPorDeducir,

    -- FIX-C: DepAnual fiscal topa en SaldoFiscalPorDeducir (convencional)
    CAST(
    CASE WHEN CC.Convencional = 1 THEN
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN 0
            WHEN ISNULL(CC.Porcentaje_Dep_Fiscal_Anual, 0) <= 0 THEN 0
            ELSE
                CASE
                    WHEN (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                         > CF.SaldoFiscalPorDeducir
                    THEN CF.SaldoFiscalPorDeducir
                    ELSE (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                END
        END
    ELSE
        -- Fiscal inmediato
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN 0
            ELSE ISNULL(CF.SaldoFiscalPorDeducir * CC.Porcentaje_Dep_Fiscal_Anual, 0)
        END
    END AS DECIMAL(18,2)) AS DepreciacionFiscalInversionAnual,

    -- FIX-C: Acumulado fiscal topa en MoiFiscal (convencional)
    CAST(
    CASE WHEN CC.Convencional = 1 THEN
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN CF.DeduccionFiscalInvHistorico
            ELSE
                CASE
                    WHEN (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                         + CF.DeduccionFiscalInvHistorico > CC.MoiFiscal
                    THEN CC.MoiFiscal
                    ELSE (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                         + CF.DeduccionFiscalInvHistorico
                END
        END
    ELSE
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN CF.DeduccionFiscalInvHistorico
            ELSE CF.DeduccionFiscalInvHistorico
                 + ISNULL(CF.SaldoFiscalPorDeducir * CC.Porcentaje_Dep_Fiscal_Anual, 0)
        END
    END AS DECIMAL(18,2)) AS DepreciacionFiscalAcumulado,

    -- FechaInpc en formato VIEJO -> AAAA-01-<mes en posicion de DIA>, division ENTERA (/2)
    CASE WHEN CC.Convencional = 1 THEN
        CASE
            WHEN CC.Meses_Efectivos_Contables IS NULL OR CC.Meses_Efectivos_Contables = 0 THEN DATEFROMPARTS(1910,1,1)
            WHEN CC.Meses_Transcurridos = 0 THEN
                DATEFROMPARTS(@AnioActual, 1, CEILING(12 - CC.Meses_Efectivos_Contables + (CC.Meses_Efectivos_Contables / 2)))
            WHEN CC.Meses_Efectivos_Contables = 1 THEN DATEFROMPARTS(@AnioActual, 1, 1)
            ELSE DATEFROMPARTS(@AnioActual, 1, CEILING(CC.Meses_Efectivos_Contables / 2))
        END
    ELSE
        CASE WHEN YEAR(CC.FechaAdquisicion) = @AnioActual THEN
            CASE
                WHEN CC.Meses_Efectivos_Contables IS NULL OR CC.Meses_Efectivos_Contables = 0 THEN DATEFROMPARTS(1910,1,1)
                WHEN CC.Meses_Transcurridos = 0 THEN
                    DATEFROMPARTS(@AnioActual, 1, CEILING(12 - CC.Meses_Efectivos_Contables + (CC.Meses_Efectivos_Contables / 2)))
                WHEN CC.Meses_Efectivos_Contables = 1 THEN DATEFROMPARTS(@AnioActual, 1, 1)
                ELSE DATEFROMPARTS(@AnioActual, 1, CEILING(CC.Meses_Efectivos_Contables / 2))
            END
        ELSE DATEFROMPARTS(1910,1,1)
        END
    END AS FechaInpc,

    -- FechaInpcAd en formato VIEJO -> AAAA-01-<mes adquisicion en posicion de DIA>
    -- FIX-CENTINELA-INPC: centinela unificado a 1910-01-01 (igual que FechaInpc),
    -- ya no 1990-01-01 (que ahora tiene INPC real capturado)
    CASE WHEN CC.Convencional = 1 THEN
        CASE WHEN CC.Meses_Efectivos_Contables > 0
            THEN DATEFROMPARTS(YEAR(CC.FechaAdquisicion), 1, MONTH(CC.FechaAdquisicion))
            ELSE DATEFROMPARTS(1910,1,1)
        END
    ELSE
        CASE WHEN YEAR(CC.FechaAdquisicion) = @AnioActual THEN
            CASE WHEN CC.Meses_Efectivos_Contables > 0
                THEN DATEFROMPARTS(YEAR(CC.FechaAdquisicion), 1, MONTH(CC.FechaAdquisicion))
                ELSE DATEFROMPARTS(1910,1,1)
            END
        ELSE
            CASE WHEN CC.Meses_Efectivos_Contables = 0 AND CC.Convencional = 0 THEN DATEFROMPARTS(1910,1,1) END
        END
    END AS FechaInpcAd,
    CC.Convencional

INTO Tmpdateinpcinversion
FROM Tmpcalculocontable CC
INNER JOIN Tmpcalculofiscal CF ON CC.Id = CF.Id;


-- =========================================================================
-- [ 5. CALCULO FINAL CON INPC ]
-- =========================================================================
DROP TABLE IF EXISTS CalculoFinalConvencional;

SELECT
    Id, IdEmpresa, Identificador, FechaAdquisicion, Descripcion,
    Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
    Moi, MoiFiscal, Baja, FechaBaja,
    Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
    DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
    Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
    DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
    ISNULL(INP.Inpc, 1)  AS InpcMitadPeriodo,
    ISNULL(INPA.Inpc, 1) AS InpcFechaAdquisicion,
    ISNULL(CASE
        WHEN ISNULL(INP.Inpc, 0) = 0 OR ISNULL(INPA.Inpc, 0) = 0 THEN 1
        -- FIX-PISO-CFF17A: el factor nunca puede ser menor a 1
        WHEN (INP.Inpc / NULLIF(INPA.Inpc, 0)) < 1 THEN 1
        ELSE ROUND(ROUND((INP.Inpc / NULLIF(INPA.Inpc, 0)) * 10000, 4) / 10000, 4, 1)
    END, 1) AS Factor_Ajuste,
    ISNULL(CAST(
        CASE
            -- FIX-CENTINELA-INPC: se agrega el chequeo de FechaInpcAd=1910 junto al de FechaInpc
            WHEN (ISNULL(INP.Inpc, 0) = 0 AND ISNULL(INPA.Inpc, 0) = 0)
                 OR FechaInpc   = DATEFROMPARTS(1910,1,1)
                 OR FechaInpcAd = DATEFROMPARTS(1910,1,1) THEN 0
            -- FIX-PISO-CFF17A: el factor nunca puede ser menor a 1
            WHEN (INP.Inpc / NULLIF(INPA.Inpc, 0)) < 1 THEN DepreciacionFiscalInversionAnual * 1
            ELSE DepreciacionFiscalInversionAnual * ROUND(ROUND((INP.Inpc / NULLIF(INPA.Inpc, 0)) * 10000, 4) / 10000, 4, 1)
        END
    AS DECIMAL(18,2)), 0) AS Deduccion_Fiscal_Inv_Actualizado,
    Convencional
INTO CalculoFinalConvencional
FROM Tmpdateinpcinversion CDE
LEFT JOIN Inpc INP  ON CDE.FechaInpc   = INP.Fecha
LEFT JOIN Inpc INPA ON CDE.FechaInpcAd = INPA.Fecha;


-- =========================================================================
-- [ 6. LIMPIEZA DE TABLAS ]
-- =========================================================================
DROP TABLE IF EXISTS #ActivosBase;
DROP TABLE IF EXISTS Tmpcalculocontable;
DROP TABLE IF EXISTS Tmpcalculofiscal;
DROP TABLE IF EXISTS Tmpdateinpcinversion;
DROP TABLE IF EXISTS Tmpdepreciainmediato;
DROP TABLE IF EXISTS Tmpbajas;


-- =========================================================================
-- [ 7. EJECUCION DE PROCEDIMIENTO DE CIERRE MENSUAL ]
-- =========================================================================
EXEC dbo.CalculosMensuales
    @Fechafinal       = @Fechafinal,
    @EjercicioVigente = @EjercicioVigente,
    @IdEmpresa        = @IdEmpresa;

END TRY
BEGIN CATCH
    DROP TABLE IF EXISTS #ActivosBase;
    DROP TABLE IF EXISTS Tmpcalculocontable;
    DROP TABLE IF EXISTS Tmpcalculofiscal;
    DROP TABLE IF EXISTS Tmpdateinpcinversion;
    DROP TABLE IF EXISTS Tmpdepreciainmediato;
    DROP TABLE IF EXISTS Tmpbajas;

    DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT            = ERROR_SEVERITY();
    DECLARE @ErrorState    INT            = ERROR_STATE();
    DECLARE @ErrorLine     INT            = ERROR_LINE();
    DECLARE @ErrorProc     NVARCHAR(200)  = ISNULL(ERROR_PROCEDURE(), 'CalculoDepreciacionMensual');

    DECLARE @MensajeCompleto NVARCHAR(4000) = 
        'Error en [' + @ErrorProc + '] linea ' + CAST(@ErrorLine AS VARCHAR) 
        + ': ' + @ErrorMessage;

    RAISERROR(@MensajeCompleto, @ErrorSeverity, @ErrorState);
END CATCH

END;
GO


-- ----------------------------
-- procedure structure for CalculoDepreciacionMensual
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[CalculoDepreciacionMensual]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[CalculoDepreciacionMensual]
GO

CREATE PROCEDURE [dbo].[CalculoDepreciacionMensual]
    @Fechafinal       DATE,
    @IdEmpresa        INT,
    @EjercicioVigente VARCHAR(4)
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

EXEC [dbo].[CrearTabla]

DECLARE @AnioActual    AS INT = YEAR(@Fechafinal);
DECLARE @MesConsultado AS INT = MONTH(@Fechafinal);

-- =========================================================================
-- [ 1. TABLA TEMPORAL BASE CON ACTIVOS A PROCESAR ]
-- =========================================================================
DROP TABLE IF EXISTS #ActivosBase;

SELECT
    AD.Id,
    AD.IdEmpresa,
    AD.Identificador,
    -- FIX-FECHAUSO: se llevan AMBAS fechas.
    --   FechaAdquisicion -> INPC y factor de actualizacion (LISR art. 31: el
    --                       INPC es "del mes en que se adquirio el bien")
    --   FechaUso         -> meses transcurridos y meses efectivos
    AD.FechaAdquisicion,
    AD.FechaUso,
    AD.IdCatalogo,
    CC.Grupo AS Descripcion,
    AD.PorcentajeDepFIscalAnual   AS Porcentaje_Dep_Fiscal_Anual,
    AD.PorcentajeDepContableAnual AS Porcentaje_Dep_Contable_Anual,
    AD.Moi,
    AD.MoiFiscal,
    AD.Baja,

    -- FIX-B: FechaBaja se pasa siempre que exista en el año actual o anterior.
    -- Bajas de ejercicios futuros se ignoran (NULL).
    -- La función MesesEfectivosAnioActual decide los meses efectivos según el mes de corte.
    CASE
        WHEN AD.FechaBaja IS NULL
            THEN NULL
        WHEN YEAR(AD.FechaBaja) = @AnioActual
            THEN DATEFROMPARTS(YEAR(AD.FechaBaja), MONTH(AD.FechaBaja), 1)
        WHEN YEAR(AD.FechaBaja) < @AnioActual
            THEN AD.FechaBaja
        ELSE NULL  -- baja de año futuro, se ignora
    END AS FechaBaja,

    AD.Convencional,
    -- Meses_Transcurridos: meses completos hasta dic del año anterior
    -- FIX-FECHAUSO: los meses transcurridos se cuentan desde el INICIO DE USO.
    -- Con FechaAdquisicion, un activo con la fecha corrida habria terminado su
    -- vida util un mes antes de lo que le corresponde y perderia esa deduccion.
  CASE
    WHEN AD.FechaUso IS NULL THEN 0   -- FIX-RN006-TRANSITO: sin FechaUso, el activo esta en transito
    WHEN DATEDIFF(MONTH, AD.FechaUso, @Fechafinal) < 0 THEN 0
    ELSE
        CASE
            WHEN 12 - MONTH(AD.FechaUso) + ((YEAR(@Fechafinal) - YEAR(AD.FechaUso)) - 1) * 12 < 0 THEN 0
            ELSE 12 - MONTH(AD.FechaUso) + ((YEAR(@Fechafinal) - YEAR(AD.FechaUso)) - 1) * 12
        END
END AS Meses_Transcurridos

INTO #ActivosBase
FROM Activos AD
INNER JOIN CatalogoCuentas CC ON AD.IdCatalogo = CC.Id
WHERE AD.IdEmpresa = @IdEmpresa
  AND (AD.FechaBaja IS NULL OR AD.FechaBaja >= DATEFROMPARTS(@AnioActual - 1, 1, 1))
  -- =======================================================================
  -- FIX-ADQ-UNIVERSO: un activo no forma parte del universo de un
  -- ejercicio anterior a su fecha de adquisicion. Sin esta condicion, un
  -- bien comprado en 2026 aparecia en el reporte de 2024 aportando su MOI
  -- y su saldo por deducir (ya no su depreciacion, eso lo corrige FIX-ADQ
  -- en MesesEfectivosAnioActual).
  -- Observado en 2024 (RFC SAM140108MY1): activos 8956, 8957 y 11732,
  -- 101,694.78 de MOI que el Excel del ejercicio no contiene.
  -- Se compara la FECHA COMPLETA contra el fin del mes de corte.
  -- =======================================================================
  -- FIX-FECHAUSO: el filtro sigue usando FechaAdquisicion a proposito. Un bien
  -- comprado en agosto y puesto en uso en septiembre SI pertenece al universo de
  -- agosto -aporta MOI y saldo por deducir-; simplemente aun no deprecia, y de
  -- eso se encarga MesesEfectivosAnioActual. Cambiarlo por FechaUso lo haria
  -- desaparecer del reporte de ese mes.
  AND AD.FechaAdquisicion <= EOMONTH(DATEFROMPARTS(@AnioActual, @MesConsultado, 1));


-- =========================================================================
-- [ 2. CALCULO CONTABLE - HISTORICO ]  (criterio VIEJO: historico = solo Meses_Transcurridos)
-- =========================================================================
DROP TABLE IF EXISTS Tmpcalculocontable;

SELECT
    BASE.Id,
    BASE.IdEmpresa,
    BASE.Identificador,
    BASE.FechaAdquisicion,
    BASE.FechaUso,
    BASE.IdCatalogo,
    BASE.Descripcion,
    BASE.Meses_Transcurridos,
    BASE.Porcentaje_Dep_Fiscal_Anual,
    BASE.Porcentaje_Dep_Contable_Anual,
    BASE.Moi,
    BASE.MoiFiscal,
    BASE.Baja,
    BASE.FechaBaja,
    BASE.Convencional,

    -- FIX-FECHAUSO: los meses efectivos se cuentan desde el inicio de uso.
    dbo.MesesEfectivosAnioActual(
        BASE.FechaUso, BASE.FechaBaja, BASE.Porcentaje_Dep_Contable_Anual,
        @MesConsultado, BASE.Meses_Transcurridos, @AnioActual
    ) AS Meses_Efectivos_Contables,

    -- Historico contable = SOLO Meses_Transcurridos (meses hasta dic año anterior)
    CAST(
        CASE WHEN ISNULL(BASE.Porcentaje_Dep_Contable_Anual, 0) > 0 THEN
            CASE WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Contable_Anual, 0))
                THEN BASE.Moi
                ELSE ((BASE.Moi * BASE.Porcentaje_Dep_Contable_Anual) / 12) * BASE.Meses_Transcurridos
            END
        END
    AS DECIMAL(18,2)) AS DeduccionContableInvHistorico,

    CAST(
        CASE WHEN ISNULL(BASE.Porcentaje_Dep_Contable_Anual, 0) > 0 THEN
            CASE WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Contable_Anual, 0))
                THEN 0
                ELSE BASE.Moi - (((BASE.Moi * BASE.Porcentaje_Dep_Contable_Anual) / 12) * BASE.Meses_Transcurridos)
            END
        END
    AS DECIMAL(18,2)) AS SaldoContablePorDeducir

INTO Tmpcalculocontable
FROM #ActivosBase BASE;


-- =========================================================================
-- [ 3. CALCULO FISCAL - HISTORICO ]  (criterio VIEJO)
-- =========================================================================
DROP TABLE IF EXISTS Tmpcalculofiscal;

SELECT
    BASE.Id,
    -- FIX-FECHAUSO: los meses efectivos se cuentan desde el inicio de uso.
    dbo.MesesEfectivosAnioActual(
        BASE.FechaUso, BASE.FechaBaja, BASE.Porcentaje_Dep_Fiscal_Anual,
        @MesConsultado, BASE.Meses_Transcurridos, @AnioActual
    ) AS Meses_Efectivos_Fiscales,

    -- Historico fiscal = SOLO Meses_Transcurridos (convencional) / logica inmediato VIEJO
    CAST(
        CASE WHEN BASE.Convencional = 1 THEN
            CASE WHEN ISNULL(BASE.Porcentaje_Dep_Fiscal_Anual, 0) > 0 THEN
                -- Energias renovables: deduccion inmediata 100%, no acumula historico convencional
                CASE WHEN BASE.IdCatalogo = 8 AND BASE.Porcentaje_Dep_Fiscal_Anual = 1 THEN 0
                     WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Fiscal_Anual, 0))
                        THEN BASE.MoiFiscal
                     ELSE ((BASE.MoiFiscal * BASE.Porcentaje_Dep_Fiscal_Anual) / 12) * BASE.Meses_Transcurridos
                END
            ELSE 0
            END
        ELSE
            -- Fiscal inmediato
            CASE
                WHEN BASE.Meses_Transcurridos = 1 THEN 0
                WHEN (YEAR(BASE.FechaAdquisicion) = 2015 AND MONTH(BASE.FechaAdquisicion) IN (9,10,11,12)) THEN 0
                ELSE ISNULL(BASE.MoiFiscal * BASE.Porcentaje_Dep_Fiscal_Anual, 0)
            END
        END
    AS DECIMAL(18,2)) AS DeduccionFiscalInvHistorico,

    CAST(
        CASE WHEN BASE.Convencional = 1 THEN
            CASE WHEN ISNULL(BASE.Porcentaje_Dep_Fiscal_Anual, 0) > 0 THEN
                CASE WHEN BASE.Meses_Transcurridos > (12 / NULLIF(BASE.Porcentaje_Dep_Fiscal_Anual, 0))
                    THEN 0
                    ELSE BASE.MoiFiscal - (((BASE.MoiFiscal * BASE.Porcentaje_Dep_Fiscal_Anual) / 12) * BASE.Meses_Transcurridos)
                END
            ELSE BASE.MoiFiscal
            END
        ELSE
            -- Fiscal inmediato
            CASE
                WHEN BASE.Meses_Transcurridos = 1 THEN BASE.MoiFiscal
                WHEN (YEAR(BASE.FechaAdquisicion) = @EjercicioVigente AND MONTH(BASE.FechaAdquisicion) IN (9,10,11,12)) THEN BASE.MoiFiscal
                ELSE 0
            END
        END
    AS DECIMAL(18,2)) AS SaldoFiscalPorDeducir

INTO Tmpcalculofiscal
FROM #ActivosBase BASE;


-- =========================================================================
-- [ 4. FECHA INPC Y CALCULOS ANUALES CONTROLADOS ]
-- =========================================================================
DROP TABLE IF EXISTS Tmpdateinpcinversion;

SELECT
    CC.Id, CC.IdEmpresa, CC.Identificador, CC.FechaAdquisicion, CC.Descripcion,
    CC.Meses_Transcurridos, CC.Porcentaje_Dep_Fiscal_Anual, CC.Porcentaje_Dep_Contable_Anual,
    CC.Moi, CC.MoiFiscal, CC.Baja, CC.FechaBaja,
    CC.Meses_Efectivos_Contables, CC.DeduccionContableInvHistorico, CC.SaldoContablePorDeducir,

    -- FIX-C: DepAnual contable topa en SaldoContablePorDeducir
    CAST(
    CASE
        WHEN CC.Moi = CC.DeduccionContableInvHistorico THEN 0
        WHEN ISNULL(CC.Porcentaje_Dep_Contable_Anual, 0) <= 0 THEN 0
        ELSE
            CASE
                WHEN (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
                     > CC.SaldoContablePorDeducir
                THEN CC.SaldoContablePorDeducir
                ELSE (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
            END
    END AS DECIMAL(18,2)) AS DepreciacionContableInversionAnual,

    -- FIX-C: Acumulado contable topa en MOI
    CAST(
    CASE
        WHEN CC.Moi = CC.DeduccionContableInvHistorico THEN CC.DeduccionContableInvHistorico
        ELSE
            CASE
                WHEN (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
                     + CC.DeduccionContableInvHistorico > CC.Moi
                THEN CC.Moi
                ELSE (CC.Moi * CC.Porcentaje_Dep_Contable_Anual) / 12 * CC.Meses_Efectivos_Contables
                     + CC.DeduccionContableInvHistorico
            END
    END AS DECIMAL(18,2)) AS DepreciacionContableAcumulado,

    CF.Meses_Efectivos_Fiscales, CF.DeduccionFiscalInvHistorico, CF.SaldoFiscalPorDeducir,

    -- FIX-C: DepAnual fiscal topa en SaldoFiscalPorDeducir (convencional)
    CAST(
    CASE WHEN CC.Convencional = 1 THEN
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN 0
            WHEN ISNULL(CC.Porcentaje_Dep_Fiscal_Anual, 0) <= 0 THEN 0
            ELSE
                CASE
                    WHEN (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                         > CF.SaldoFiscalPorDeducir
                    THEN CF.SaldoFiscalPorDeducir
                    ELSE (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                END
        END
    ELSE
        -- Fiscal inmediato
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN 0
            ELSE ISNULL(CF.SaldoFiscalPorDeducir * CC.Porcentaje_Dep_Fiscal_Anual, 0)
        END
    END AS DECIMAL(18,2)) AS DepreciacionFiscalInversionAnual,

    -- FIX-C: Acumulado fiscal topa en MoiFiscal (convencional)
    CAST(
    CASE WHEN CC.Convencional = 1 THEN
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN CF.DeduccionFiscalInvHistorico
            ELSE
                CASE
                    WHEN (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                         + CF.DeduccionFiscalInvHistorico > CC.MoiFiscal
                    THEN CC.MoiFiscal
                    ELSE (CC.MoiFiscal * CC.Porcentaje_Dep_Fiscal_Anual) / 12 * CF.Meses_Efectivos_Fiscales
                         + CF.DeduccionFiscalInvHistorico
                END
        END
    ELSE
        CASE
            WHEN CC.MoiFiscal = CF.DeduccionFiscalInvHistorico THEN CF.DeduccionFiscalInvHistorico
            ELSE CF.DeduccionFiscalInvHistorico
                 + ISNULL(CF.SaldoFiscalPorDeducir * CC.Porcentaje_Dep_Fiscal_Anual, 0)
        END
    END AS DECIMAL(18,2)) AS DepreciacionFiscalAcumulado,

    -- FechaInpc en formato VIEJO -> AAAA-01-<mes en posicion de DIA>, division ENTERA (/2)
    -- FIX-RN002-MESFISCAL: usa CF.Meses_Efectivos_Fiscales, no
    -- CC.Meses_Efectivos_Contables -- este numerador alimenta EXCLUSIVAMENTE
    -- la deduccion fiscal actualizada.
    CASE WHEN CC.Convencional = 1 THEN
        CASE
            WHEN CF.Meses_Efectivos_Fiscales IS NULL OR CF.Meses_Efectivos_Fiscales = 0 THEN DATEFROMPARTS(1910,1,1)
            WHEN CC.Meses_Transcurridos = 0 THEN
                DATEFROMPARTS(@AnioActual, 1, CEILING(12 - CF.Meses_Efectivos_Fiscales + (CF.Meses_Efectivos_Fiscales / 2)))
            WHEN CF.Meses_Efectivos_Fiscales = 1 THEN DATEFROMPARTS(@AnioActual, 1, 1)
            ELSE DATEFROMPARTS(@AnioActual, 1, CEILING(CF.Meses_Efectivos_Fiscales / 2))
        END
    ELSE
        CASE WHEN YEAR(CC.FechaAdquisicion) = @AnioActual THEN
            CASE
                WHEN CF.Meses_Efectivos_Fiscales IS NULL OR CF.Meses_Efectivos_Fiscales = 0 THEN DATEFROMPARTS(1910,1,1)
                WHEN CC.Meses_Transcurridos = 0 THEN
                    DATEFROMPARTS(@AnioActual, 1, CEILING(12 - CF.Meses_Efectivos_Fiscales + (CF.Meses_Efectivos_Fiscales / 2)))
                WHEN CF.Meses_Efectivos_Fiscales = 1 THEN DATEFROMPARTS(@AnioActual, 1, 1)
                ELSE DATEFROMPARTS(@AnioActual, 1, CEILING(CF.Meses_Efectivos_Fiscales / 2))
            END
        ELSE DATEFROMPARTS(1910,1,1)
        END
    END AS FechaInpc,

    -- FechaInpcAd en formato VIEJO -> AAAA-01-<mes adquisicion en posicion de DIA>
    -- FIX-CENTINELA-INPC: centinela unificado a 1910-01-01 (igual que FechaInpc),
    -- ya no 1990-01-01 (que ahora tiene INPC real capturado)
    -- FIX-RN002-MESFISCAL: el guard tambien pasa a Meses_Efectivos_Fiscales,
    -- por la misma razon -- esta fecha solo alimenta el factor fiscal.
    CASE WHEN CC.Convencional = 1 THEN
        CASE WHEN CF.Meses_Efectivos_Fiscales > 0
            THEN DATEFROMPARTS(YEAR(CC.FechaAdquisicion), 1, MONTH(CC.FechaAdquisicion))
            ELSE DATEFROMPARTS(1910,1,1)
        END
    ELSE
        CASE WHEN YEAR(CC.FechaAdquisicion) = @AnioActual THEN
            CASE WHEN CF.Meses_Efectivos_Fiscales > 0
                THEN DATEFROMPARTS(YEAR(CC.FechaAdquisicion), 1, MONTH(CC.FechaAdquisicion))
                ELSE DATEFROMPARTS(1910,1,1)
            END
        ELSE
            CASE WHEN CF.Meses_Efectivos_Fiscales = 0 AND CC.Convencional = 0 THEN DATEFROMPARTS(1910,1,1) END
        END
    END AS FechaInpcAd,
    CC.Convencional

INTO Tmpdateinpcinversion
FROM Tmpcalculocontable CC
INNER JOIN Tmpcalculofiscal CF ON CC.Id = CF.Id;


-- =========================================================================
-- [ 5. CALCULO FINAL CON INPC ]
-- =========================================================================
DROP TABLE IF EXISTS CalculoFinalConvencional;

SELECT
    Id, IdEmpresa, Identificador, FechaAdquisicion, Descripcion,
    Meses_Transcurridos, Porcentaje_Dep_Fiscal_Anual, Porcentaje_Dep_Contable_Anual,
    Moi, MoiFiscal, Baja, FechaBaja,
    Meses_Efectivos_Contables, DeduccionContableInvHistorico, SaldoContablePorDeducir,
    DepreciacionContableInversionAnual, DepreciacionContableAcumulado,
    Meses_Efectivos_Fiscales, DeduccionFiscalInvHistorico, SaldoFiscalPorDeducir,
    DepreciacionFiscalInversionAnual, DepreciacionFiscalAcumulado,
    ISNULL(INP.Inpc, 1)  AS InpcMitadPeriodo,
    ISNULL(INPA.Inpc, 1) AS InpcFechaAdquisicion,
    ISNULL(CASE
        WHEN ISNULL(INP.Inpc, 0) = 0 OR ISNULL(INPA.Inpc, 0) = 0 THEN 1
        -- FIX-PISO-CFF17A: el factor nunca puede ser menor a 1
        WHEN (INP.Inpc / NULLIF(INPA.Inpc, 0)) < 1 THEN 1
        ELSE ROUND(ROUND((INP.Inpc / NULLIF(INPA.Inpc, 0)) * 10000, 4) / 10000, 4, 1)
    END, 1) AS Factor_Ajuste,
    ISNULL(CAST(
        CASE
            -- FIX-CENTINELA-INPC: se agrega el chequeo de FechaInpcAd=1910 junto al de FechaInpc
            WHEN (ISNULL(INP.Inpc, 0) = 0 AND ISNULL(INPA.Inpc, 0) = 0)
                 OR FechaInpc   = DATEFROMPARTS(1910,1,1)
                 OR FechaInpcAd = DATEFROMPARTS(1910,1,1) THEN 0
            -- FIX-PISO-CFF17A: el factor nunca puede ser menor a 1
            WHEN (INP.Inpc / NULLIF(INPA.Inpc, 0)) < 1 THEN DepreciacionFiscalInversionAnual * 1
            ELSE DepreciacionFiscalInversionAnual * ROUND(ROUND((INP.Inpc / NULLIF(INPA.Inpc, 0)) * 10000, 4) / 10000, 4, 1)
        END
    AS DECIMAL(18,2)), 0) AS Deduccion_Fiscal_Inv_Actualizado,
    Convencional
INTO CalculoFinalConvencional
FROM Tmpdateinpcinversion CDE
LEFT JOIN Inpc INP  ON CDE.FechaInpc   = INP.Fecha
LEFT JOIN Inpc INPA ON CDE.FechaInpcAd = INPA.Fecha;


-- =========================================================================
-- [ 6. LIMPIEZA DE TABLAS ]
-- =========================================================================
DROP TABLE IF EXISTS #ActivosBase;
DROP TABLE IF EXISTS Tmpcalculocontable;
DROP TABLE IF EXISTS Tmpcalculofiscal;
DROP TABLE IF EXISTS Tmpdateinpcinversion;
DROP TABLE IF EXISTS Tmpdepreciainmediato;
DROP TABLE IF EXISTS Tmpbajas;


-- =========================================================================
-- [ 7. EJECUCION DE PROCEDIMIENTO DE CIERRE MENSUAL ]
-- =========================================================================
EXEC dbo.CalculosMensuales
    @Fechafinal       = @Fechafinal,
    @EjercicioVigente = @EjercicioVigente,
    @IdEmpresa        = @IdEmpresa;

END TRY
BEGIN CATCH
    DROP TABLE IF EXISTS #ActivosBase;
    DROP TABLE IF EXISTS Tmpcalculocontable;
    DROP TABLE IF EXISTS Tmpcalculofiscal;
    DROP TABLE IF EXISTS Tmpdateinpcinversion;
    DROP TABLE IF EXISTS Tmpdepreciainmediato;
    DROP TABLE IF EXISTS Tmpbajas;

    DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT            = ERROR_SEVERITY();
    DECLARE @ErrorState    INT            = ERROR_STATE();
    DECLARE @ErrorLine     INT            = ERROR_LINE();
    DECLARE @ErrorProc     NVARCHAR(200)  = ISNULL(ERROR_PROCEDURE(), 'CalculoDepreciacionMensual');

    DECLARE @MensajeCompleto NVARCHAR(4000) = 
        'Error en [' + @ErrorProc + '] linea ' + CAST(@ErrorLine AS VARCHAR) 
        + ': ' + @ErrorMessage;

    RAISERROR(@MensajeCompleto, @ErrorSeverity, @ErrorState);
END CATCH

END;
GO


-- ----------------------------
-- procedure structure for sp_ReporteDepreciacion
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ReporteDepreciacion]') AND type IN ('P', 'PC', 'RF', 'X'))
	DROP PROCEDURE[dbo].[sp_ReporteDepreciacion]
GO

CREATE PROCEDURE [dbo].[sp_ReporteDepreciacion]
    @Periodo      VARCHAR(10),
    @Mes          INT,
    @RFC          VARCHAR(20) = NULL,
    @IdEmpresa    INT         = NULL,
    @Convencional TINYINT     = 1,
    @Origen       VARCHAR(10) = 'HISTORICO'   -- 'HISTORICO' | 'VIVO'
AS
BEGIN
    SET NOCOUNT ON;

    -- Se identifica la empresa por @IdEmpresa (preferente) o por @RFC.
    IF @IdEmpresa IS NULL AND @RFC IS NULL
    BEGIN
        RAISERROR('Debe indicar @IdEmpresa o @RFC.', 16, 1);
        RETURN;
    END

    IF @Origen NOT IN ('HISTORICO','VIVO')
    BEGIN
        RAISERROR('@Origen debe ser HISTORICO o VIVO.', 16, 1);
        RETURN;
    END

    -- =================================================================
    -- ORIGEN DE DATOS
    -- 'HISTORICO' -> CalculoDetalle_Historico (cierre ya guardado)
    -- 'VIVO'      -> CalculoDetalle           (ultimo calculo corrido)
    -- Ambas tablas tienen las MISMAS columnas, asi que se vuelcan a
    -- #CFC y de ahi en adelante la consulta es una sola.
    --
    -- En 'VIVO' el periodo y el mes se DERIVAN de los datos, porque el
    -- front no los conoce al pintar el calculo en curso. Los parametros
    -- @Periodo y @Mes se ignoran en ese modo.
    -- =================================================================
    DROP TABLE IF EXISTS #CFC;

    CREATE TABLE #CFC (
        IdActivo                            INT,
        IdEmpresa                           INT,
        IdPeriodo                           INT,
        IdMes                               INT,
        Convencional                        TINYINT,
        Moi                                 DECIMAL(18,2),
        MoiFiscal                           DECIMAL(18,2),
        FechaBaja                           DATE,
        DeduccionContableInvHistorico       DECIMAL(18,2),
        SaldoContablePorDeducir             DECIMAL(18,2),
        DepreciacionContableInversionAnual  DECIMAL(18,2),
        DepreciacionContableAcumulado       DECIMAL(18,2),
        DeduccionFiscalInvHistorico         DECIMAL(18,2),
        SaldoFiscalPorDeducir               DECIMAL(18,2),
        DepreciacionFiscalInversionAnual    DECIMAL(18,2),
        DepreciacionFiscalAcumulado         DECIMAL(18,2),
        Deduccion_Fiscal_Inv_Actualizado    DECIMAL(18,2)
    );

    IF @Origen = 'VIVO'
    BEGIN
        INSERT INTO #CFC
        SELECT CD.IdActivo, CD.IdEmpresa, CD.IdPeriodo, CD.IdMes, CD.Convencional,
               CD.Moi, CD.MoiFiscal, CD.FechaBaja,
               CD.DeduccionContableInvHistorico, CD.SaldoContablePorDeducir,
               CD.DepreciacionContableInversionAnual, CD.DepreciacionContableAcumulado,
               CD.DeduccionFiscalInvHistorico, CD.SaldoFiscalPorDeducir,
               CD.DepreciacionFiscalInversionAnual, CD.DepreciacionFiscalAcumulado,
               CD.Deduccion_Fiscal_Inv_Actualizado
        FROM [dbo].[CalculoDetalle] CD
        INNER JOIN [dbo].[Activos]  AD ON CD.IdActivo  = AD.Id
        INNER JOIN [dbo].[Empresas] EM ON AD.IdEmpresa = EM.Id
        WHERE CD.Convencional = @Convencional
          AND ((@IdEmpresa IS NOT NULL AND AD.IdEmpresa = @IdEmpresa)
            OR (@IdEmpresa IS NULL     AND EM.RFC       = @RFC));

        -- Periodo y mes reales del calculo vivo
        SELECT @Periodo = CAST(CPE.Periodo AS VARCHAR(10))
        FROM [dbo].[CatalogoPeriodo] CPE
        WHERE CPE.Id = (SELECT MAX(IdPeriodo) FROM #CFC);

        SELECT @Mes = ISNULL(MAX(IdMes), 12) FROM #CFC;
    END
    ELSE
    BEGIN
        INSERT INTO #CFC
        SELECT CD.IdActivo, CD.IdEmpresa, CD.IdPeriodo, CD.IdMes, CD.Convencional,
               CD.Moi, CD.MoiFiscal, CD.FechaBaja,
               CD.DeduccionContableInvHistorico, CD.SaldoContablePorDeducir,
               CD.DepreciacionContableInversionAnual, CD.DepreciacionContableAcumulado,
               CD.DeduccionFiscalInvHistorico, CD.SaldoFiscalPorDeducir,
               CD.DepreciacionFiscalInversionAnual, CD.DepreciacionFiscalAcumulado,
               CD.Deduccion_Fiscal_Inv_Actualizado
        FROM [dbo].[CalculoDetalle_Historico] CD
        INNER JOIN [dbo].[Activos]         AD  ON CD.IdActivo  = AD.Id
        INNER JOIN [dbo].[Empresas]        EM  ON AD.IdEmpresa = EM.Id
        INNER JOIN [dbo].[CatalogoPeriodo] CPX ON CD.IdPeriodo = CPX.Id
        WHERE CD.Convencional = @Convencional
          AND CPX.Periodo = @Periodo
          AND CD.IdMes    = @Mes
          AND ((@IdEmpresa IS NOT NULL AND AD.IdEmpresa = @IdEmpresa)
            OR (@IdEmpresa IS NULL     AND EM.RFC       = @RFC));
    END

    DECLARE @IdPeriodo    INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = CAST(@Periodo AS INT));
    DECLARE @IdPeriodoAnt INT = (SELECT Id FROM CatalogoPeriodo WHERE Periodo = CAST(@Periodo AS INT) - 1);

    -- Ultimo dia del mes consultado. Una baja se considera YA OCURRIDA
    -- solo si su fecha real es <= este corte. Comparar por fecha completa
    -- (no solo por MONTH) es indispensable para consultar ejercicios
    -- anteriores: un activo con baja en 2026 estaba VIGENTE en 2024.
    DECLARE @Corte DATE = EOMONTH(DATEFROMPARTS(CAST(@Periodo AS INT), @Mes, 1));

    -- =============================================
    -- Bajas: todos los activos dados de baja
    -- en el ejercicio @Periodo, en meses <= @Mes.
    -- Se toma el registro congelado del mes
    -- inmediato anterior al mes de baja.
    -- Caso borde: baja en enero -> periodo anterior.
    -- =============================================
    DROP TABLE IF EXISTS #BajasRecientes;

    SELECT CDHB.*
    INTO #BajasRecientes
    FROM [dbo].[CalculoDetalle_Historico] CDHB
    INNER JOIN [dbo].[Activos]  ADE ON CDHB.IdActivo = ADE.Id
    INNER JOIN [dbo].[Empresas] EMP ON ADE.IdEmpresa = EMP.Id
    WHERE ((@IdEmpresa IS NOT NULL AND ADE.IdEmpresa = @IdEmpresa)
        OR (@IdEmpresa IS NULL     AND EMP.RFC       = @RFC))
      AND CDHB.Convencional = @Convencional
      AND ADE.FechaBaja IS NOT NULL
      AND YEAR(ADE.FechaBaja)  = CAST(@Periodo AS INT)
      AND MONTH(ADE.FechaBaja) <= @Mes
      -- Registro congelado del mes ANTERIOR al mes de baja
      AND CDHB.IdPeriodo = CASE WHEN MONTH(ADE.FechaBaja) = 1
                                THEN @IdPeriodoAnt
                                ELSE @IdPeriodo
                           END
      AND CDHB.IdMes     = CASE WHEN MONTH(ADE.FechaBaja) = 1
                                THEN 12
                                ELSE MONTH(ADE.FechaBaja) - 1
                           END;

    -- =============================================
    -- Consulta principal
    -- =============================================
    SELECT
        CAC.Grupo AS Descripcion,

        -- MOI: activos vivos del mes + MOI de bajas del periodo actual
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte) THEN CFC.Moi ELSE 0 END)
            + SUM(ISNULL(BRE.Moi, 0))
                                                                                        AS Moi,

        -- Baja: MOI de las bajas YA OCURRIDAS al mes consultado.
        -- Se usa ADE.FechaBaja (fecha real) para no anticipar bajas
        -- futuras en los meses previos.
        SUM(CASE WHEN ADE.FechaBaja IS NOT NULL
                      AND YEAR(ADE.FechaBaja) = CAST(@Periodo AS INT)
                      AND ADE.FechaBaja      <= @Corte
                 THEN CFC.Moi ELSE 0 END)
                                                                                        AS Baja,

        -- FIX-NULL-TERRENOS: ISNULL para que terrenos devuelvan 0 en lugar de NULL
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DeduccionContableInvHistorico, 0) ELSE 0 END)
            + SUM(ISNULL(BRE.DeduccionContableInvHistorico, 0))
                                                                                        AS DeduccionContableHistorica,

        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.SaldoContablePorDeducir, 0) ELSE 0 END)
            + SUM(ISNULL(BRE.SaldoContablePorDeducir, 0))
                                                                                        AS SaldoContableMoiDeducir,

        -- Depreciacion contable anual
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DepreciacionContableInversionAnual, 0) ELSE 0 END)
            + SUM(CASE WHEN BRE.IdActivo IS NOT NULL
                       THEN CAST(
                            CASE
                                WHEN BRE.Moi = BRE.DeduccionContableInvHistorico        THEN 0
                                WHEN ISNULL(BRE.Porcentaje_Dep_Contable_Anual, 0) <= 0  THEN 0
                                ELSE (BRE.Moi * BRE.Porcentaje_Dep_Contable_Anual) / 12
                                     * (MONTH(ADE.FechaBaja) - 1)
                            END AS DECIMAL(18,2))
                       ELSE 0
                  END)
                                                                                        AS DepreciacionContableInversionAnual,

        -- =========================================================
        -- ACUMULADO CONTABLE -- criterio Excel: SUMAR.SI
        -- Equivale a  =SUMA(O80:O94)-SUMAR.SI(I80:I94,">0",O80:O94)
        -- Los activos con baja se restan POR COMPLETO de esta columna
        -- (su historico de ejercicios previos Y su anual del ejercicio).
        -- Los activos dados de baja durante el ejercicio NO aportan
        -- aqui, aunque SI aportan en Moi, DeduccionContableHistorica,
        -- SaldoContableMoiDeducir y DepreciacionContableInversionAnual
        -- (via #BajasRecientes).
        -- Consecuencia esperada y deliberada:
        --   Acumulado <> Historico + Anual en grupos con bajas.
        --   La diferencia queda documentada en la columna Baja.
        -- NO "corregir" esto sumando BRE de nuevo.
        -- =========================================================
        SUM(CASE WHEN ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte
                 THEN ISNULL(CFC.DepreciacionContableAcumulado, 0)
                 ELSE 0 END)
                                                                                        AS DepreciacionContableAcumuladoEjercicio,

        -- FIX-NULL-TERRENOS: historico fiscal
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DeduccionFiscalInvHistorico, 0) ELSE 0 END)
            + SUM(ISNULL(BRE.DeduccionFiscalInvHistorico, 0))
                                                                                        AS DeduccionFiscalHistorica,

        -- FIX-NULL-TERRENOS: saldo fiscal
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.SaldoFiscalPorDeducir, 0) ELSE 0 END)
            + SUM(ISNULL(BRE.SaldoFiscalPorDeducir, 0))
                                                                                        AS SaldoFiscalMoiDeducir,

        -- Depreciacion fiscal anual
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.DepreciacionFiscalInversionAnual, 0) ELSE 0 END)
            + SUM(CASE WHEN BRE.IdActivo IS NOT NULL
                       THEN CAST(
                            CASE WHEN BRE.Convencional = 1 THEN
                                CASE
                                    WHEN BRE.MoiFiscal = BRE.DeduccionFiscalInvHistorico   THEN 0
                                    WHEN ISNULL(BRE.Porcentaje_Dep_Fiscal_Anual, 0) <= 0   THEN 0
                                    ELSE (BRE.MoiFiscal * BRE.Porcentaje_Dep_Fiscal_Anual) / 12
                                         * (MONTH(ADE.FechaBaja) - 1)
                                END
                            ELSE
                                CASE
                                    WHEN BRE.MoiFiscal = BRE.DeduccionFiscalInvHistorico   THEN 0
                                    ELSE ISNULL(BRE.SaldoFiscalPorDeducir * BRE.Porcentaje_Dep_Fiscal_Anual, 0)
                                END
                            END AS DECIMAL(18,2))
                       ELSE 0
                  END)
                                                                                        AS DepreciacionFiscalInversionAnual,

        -- =========================================================
        -- ACUMULADO FISCAL -- criterio Excel: SUMA SIMPLE.
        -- Las bajas del ejercicio SI se suman aqui, igual que
        -- =SUMA(T80:T94) en la hoja de calculo.
        -- Su aporte se toma del congelado (historico) mas el anual
        -- recalculado hasta el mes previo a la baja.
        -- =========================================================
        SUM(CASE WHEN ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte
                 THEN ISNULL(CFC.DepreciacionFiscalAcumulado, 0) ELSE 0 END)
            + SUM(CASE WHEN BRE.IdActivo IS NOT NULL
                       THEN ISNULL(BRE.DeduccionFiscalInvHistorico, 0)
                          + CAST(
                            CASE WHEN BRE.Convencional = 1 THEN
                                CASE
                                    WHEN BRE.MoiFiscal = BRE.DeduccionFiscalInvHistorico   THEN 0
                                    WHEN ISNULL(BRE.Porcentaje_Dep_Fiscal_Anual, 0) <= 0   THEN 0
                                    ELSE (BRE.MoiFiscal * BRE.Porcentaje_Dep_Fiscal_Anual) / 12
                                         * (MONTH(ADE.FechaBaja) - 1)
                                END
                            ELSE
                                CASE
                                    WHEN BRE.MoiFiscal = BRE.DeduccionFiscalInvHistorico   THEN 0
                                    ELSE ISNULL(BRE.SaldoFiscalPorDeducir * BRE.Porcentaje_Dep_Fiscal_Anual, 0)
                                END
                            END AS DECIMAL(18,2))
                       ELSE 0
                  END)
                                                                                        AS DepreciacionFiscalAcumuladoEjercicio,

        -- =========================================================
        -- FIX-DIF01-FACTOR
        -- Deduccion fiscal actualizada (INPC)
        -- Antes: se recalculaba (MoiFiscal*Pct/12*meses) * BRE.Factor_Ajuste,
        -- donde BRE.Factor_Ajuste viene de una columna DECIMAL(18,2)
        -- (solo 2 decimales). El CFF art. 17-A exige el factor con
        -- 4 decimales, y ese calculo ya se hizo correctamente al
        -- generar CalculoFinalConvencional (Deduccion_Fiscal_Inv_
        -- Actualizado, con precision de 4 decimales antes del CAST a
        -- pesos). Ahora: se usa directamente ese monto ya calculado y
        -- congelado, sin volver a pasar por el factor truncado.
        -- =========================================================
        SUM(CASE WHEN (ADE.FechaBaja IS NULL OR ADE.FechaBaja > @Corte)
                 THEN ISNULL(CFC.Deduccion_Fiscal_Inv_Actualizado, 0) ELSE 0 END)
            + SUM(CASE WHEN BRE.IdActivo IS NOT NULL
                       THEN ISNULL(BRE.Deduccion_Fiscal_Inv_Actualizado, 0)
                       ELSE 0
                  END)
                                                                                        AS DeduccionFiscalActualizadoAnual

    FROM #CFC CFC
    -- FIX-UNIVERSO: condicion en el JOIN para que RIGHT JOIN no interfiera
    INNER JOIN [dbo].[Activos] ADE ON CFC.IdActivo = ADE.Id
        AND (ADE.FechaBaja IS NULL
             OR YEAR(ADE.FechaBaja) >= CAST(@Periodo AS INT))
    INNER JOIN [dbo].[Empresas]        EMP ON ADE.IdEmpresa  = EMP.Id
    RIGHT JOIN [dbo].[CatalogoCuentas] CAC ON ADE.IdCatalogo = CAC.Id
    LEFT  JOIN #BajasRecientes         BRE ON CFC.IdActivo   = BRE.IdActivo
    -- El filtro de empresa, convencional, periodo y mes ya se aplico
    -- al poblar #CFC.
    --
    -- Este WHERE descarta los grupos del catalogo que no tienen ningun
    -- activo en #CFC. Es indispensable: al mover los filtros al poblado
    -- de #CFC el WHERE quedo vacio y el RIGHT JOIN empezo a devolver el
    -- catalogo COMPLETO con renglones en 0.00. Antes las condiciones
    -- sobre CFC en el WHERE convertian de hecho el RIGHT JOIN en INNER.
    WHERE CFC.IdActivo IS NOT NULL
    GROUP BY CAC.Grupo
    ORDER BY CAC.Grupo ASC;

    DROP TABLE IF EXISTS #BajasRecientes;
    DROP TABLE IF EXISTS #CFC;
END
GO


-- ----------------------------
-- function structure for MesesEfectivosAnioActual
-- ----------------------------
IF EXISTS (SELECT * FROM sys.all_objects WHERE object_id = OBJECT_ID(N'[dbo].[MesesEfectivosAnioActual]') AND type IN ('FN', 'FS', 'FT', 'IF', 'TF'))
	DROP FUNCTION[dbo].[MesesEfectivosAnioActual]
GO

CREATE FUNCTION [dbo].[MesesEfectivosAnioActual](
    @FechaAdquisicion          DATE,
    @FechaBaja                 DATE,
    @PorcentajeDep             DECIMAL(10,4),
    @MesCorte                  INT,
    @MesesTranscurridosPrevios INT,
    @AnioCalculo               INT
)
RETURNS INT
AS
BEGIN
    DECLARE @VidaUtilMeses  INT;
    DECLARE @MesesEfectivos INT = 0;
    DECLARE @MesAdquisicion INT = MONTH(@FechaAdquisicion);
    DECLARE @MesBaja        INT = NULL;
    DECLARE @AnioActual     INT = @AnioCalculo;

    -- =========================================================================
    -- FIX-ADQ: el activo no puede depreciar antes de existir.
    -- Se compara la FECHA COMPLETA contra el ultimo dia del mes de corte.
    --
    -- Sin esta guarda, un activo adquirido en marzo de 2026 calculado para
    -- diciembre de 2024 caia en la rama "activos del anio actual" (la unica
    -- que quedaba, porque no habia rama para adquisiciones futuras) y ahi
    -- solo se comparaba el MES: 3 <= 12, generando 9 meses efectivos y
    -- depreciacion en un ejercicio en el que el bien no se habia comprado.
    -- Observado en 2024: activos 8956, 8957 y 11732.
    --
    -- Cubre los dos casos a la vez:
    --   * adquisicion en un anio POSTERIOR al calculado
    --   * adquisicion en un mes posterior dentro del mismo anio
    -- =========================================================================
    IF @FechaAdquisicion IS NULL
        RETURN 0;

    IF @FechaAdquisicion > EOMONTH(DATEFROMPARTS(@AnioCalculo, @MesCorte, 1))
        RETURN 0;

    -- NULLIF protege la division antes de asignar VidaUtilMeses
    IF ISNULL(@PorcentajeDep, 0) <= 0
        RETURN 0;

    SET @VidaUtilMeses = 12 / NULLIF(@PorcentajeDep, 0);

    -- Si la vida util quedo NULL o 0 por algun motivo, salir
    IF ISNULL(@VidaUtilMeses, 0) = 0
        RETURN 0;

    IF @FechaBaja IS NOT NULL
        SET @MesBaja = MONTH(@FechaBaja);

    -- =========================================================================
    -- Activos de anios anteriores
    -- =========================================================================
    IF YEAR(@FechaAdquisicion) < @AnioActual
    BEGIN
        -- FIX-A: si la baja ocurrio en un ejercicio anterior al que se calcula,
        -- el activo no genera depreciacion en el ejercicio actual.
        -- Ejemplo: baja mayo 2025, calculando 2026 → RETURN 0.
        IF @FechaBaja IS NOT NULL AND YEAR(@FechaBaja) < @AnioActual
            RETURN 0;

        IF @MesesTranscurridosPrevios >= @VidaUtilMeses
            RETURN 0;

        IF @MesBaja IS NOT NULL AND @MesBaja <= @MesCorte
        BEGIN
            SET @MesesEfectivos = @MesBaja - 1;
            IF @MesesEfectivos < 0 SET @MesesEfectivos = 0;
        END
        ELSE
        BEGIN
            SET @MesesEfectivos = @MesCorte;
        END

        IF (@MesesTranscurridosPrevios + @MesesEfectivos) > @VidaUtilMeses
            SET @MesesEfectivos = @VidaUtilMeses - @MesesTranscurridosPrevios;

        RETURN @MesesEfectivos;
    END

    -- =========================================================================
    -- Activos del anio actual
    -- =========================================================================
    BEGIN
        IF @MesAdquisicion > @MesCorte
            RETURN 0;

        SET @MesesEfectivos = @MesCorte - @MesAdquisicion + 1;

        IF DAY(@FechaAdquisicion) > 1
            SET @MesesEfectivos = @MesesEfectivos - 1;

        IF @MesBaja IS NOT NULL AND @MesBaja <= @MesCorte
        BEGIN
            SET @MesesEfectivos = @MesBaja - @MesAdquisicion;
            IF DAY(@FechaAdquisicion) > 1
                SET @MesesEfectivos = @MesesEfectivos - 1;
        END

        IF @MesesEfectivos < 0 SET @MesesEfectivos = 0;

        RETURN @MesesEfectivos;
    END
END;
GO


-- ----------------------------
-- Auto increment value for Activos
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[Activos]', RESEED, 15438)
GO


-- ----------------------------
-- Checks structure for table Activos
-- ----------------------------
ALTER TABLE [dbo].[Activos] ADD CONSTRAINT [CK_Activos_FechaUso] CHECK ([FechaUso] IS NULL OR [FechaAdquisicion] IS NULL OR [FechaUso]>=[FechaAdquisicion])
GO


-- ----------------------------
-- Primary Key structure for table Activos
-- ----------------------------
ALTER TABLE [dbo].[Activos] ADD CONSTRAINT [PK__Activos___3214EC075ABC1402] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for ActivosBaja
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[ActivosBaja]', RESEED, 1123)
GO


-- ----------------------------
-- Primary Key structure for table ActivosBaja
-- ----------------------------
ALTER TABLE [dbo].[ActivosBaja] ADD CONSTRAINT [PK__ActivosB__3214EC071605166A] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for ActivosDetalle
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[ActivosDetalle]', RESEED, 1)
GO


-- ----------------------------
-- Primary Key structure for table ActivosDetalle
-- ----------------------------
ALTER TABLE [dbo].[ActivosDetalle] ADD CONSTRAINT [PK__ActivosD__E43646A565A8086B] PRIMARY KEY CLUSTERED ([IdDetalle])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CalculoDetalle
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CalculoDetalle]', RESEED, 32565)
GO


-- ----------------------------
-- Indexes structure for table CalculoDetalle
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_CalculoDetalle_IdEmpresa]
ON [dbo].[CalculoDetalle] (
  [IdEmpresa] ASC
)
GO


-- ----------------------------
-- Primary Key structure for table CalculoDetalle
-- ----------------------------
ALTER TABLE [dbo].[CalculoDetalle] ADD CONSTRAINT [PK__CalculoD__3214EC07A09BC81B] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CalculoDetalle_Historico
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CalculoDetalle_Historico]', RESEED, 32565)
GO


-- ----------------------------
-- Indexes structure for table CalculoDetalle_Historico
-- ----------------------------
CREATE UNIQUE NONCLUSTERED INDEX [UX_CalculoDetalle_Historico_Cierre]
ON [dbo].[CalculoDetalle_Historico] (
  [IdEmpresa] ASC,
  [IdPeriodo] ASC,
  [IdMes] ASC,
  [IdActivo] ASC,
  [Convencional] ASC
)
GO


-- ----------------------------
-- Primary Key structure for table CalculoDetalle_Historico
-- ----------------------------
ALTER TABLE [dbo].[CalculoDetalle_Historico] ADD CONSTRAINT [PK__CalculoD__3214EC074029EF3B] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CalculoDetalle_HistoricoBajas
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CalculoDetalle_HistoricoBajas]', RESEED, 1124)
GO


-- ----------------------------
-- Primary Key structure for table CalculoDetalle_HistoricoBajas
-- ----------------------------
ALTER TABLE [dbo].[CalculoDetalle_HistoricoBajas] ADD CONSTRAINT [PK__CalculoD__3214EC076B2A26E5] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CalculoMensual
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CalculoMensual]', RESEED, 65130)
GO


-- ----------------------------
-- Indexes structure for table CalculoMensual
-- ----------------------------
CREATE NONCLUSTERED INDEX [IX_CalculoMensual_IdEmpresa]
ON [dbo].[CalculoMensual] (
  [IdEmpresa] ASC
)
GO


-- ----------------------------
-- Primary Key structure for table CalculoMensual
-- ----------------------------
ALTER TABLE [dbo].[CalculoMensual] ADD CONSTRAINT [PK__CalculoM__3214EC071216AB51] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CalculoMensual_Historico
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CalculoMensual_Historico]', RESEED, 65130)
GO


-- ----------------------------
-- Indexes structure for table CalculoMensual_Historico
-- ----------------------------
CREATE UNIQUE NONCLUSTERED INDEX [UX_CalculoMensual_Historico_Cierre]
ON [dbo].[CalculoMensual_Historico] (
  [IdEmpresa] ASC,
  [IdPeriodo] ASC,
  [IdMes] ASC,
  [IdActivo] ASC,
  [TipoContabilidad] ASC
)
GO


-- ----------------------------
-- Primary Key structure for table CalculoMensual_Historico
-- ----------------------------
ALTER TABLE [dbo].[CalculoMensual_Historico] ADD CONSTRAINT [PK__CalculoM__3214EC07545C3381] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CatalogoCuentas
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CatalogoCuentas]', RESEED, 23)
GO


-- ----------------------------
-- Primary Key structure for table CatalogoCuentas
-- ----------------------------
ALTER TABLE [dbo].[CatalogoCuentas] ADD CONSTRAINT [PK__Catalogo__3214EC076C35C172] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CatalogoMes
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CatalogoMes]', RESEED, 12)
GO


-- ----------------------------
-- Primary Key structure for table CatalogoMes
-- ----------------------------
ALTER TABLE [dbo].[CatalogoMes] ADD CONSTRAINT [PK__Catalogo__3214EC074773B3DC] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CatalogoPeriodo
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CatalogoPeriodo]', RESEED, 26)
GO


-- ----------------------------
-- Primary Key structure for table CatalogoPeriodo
-- ----------------------------
ALTER TABLE [dbo].[CatalogoPeriodo] ADD CONSTRAINT [PK__Catalogo__3214EC07F49F787E] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CatalogoPorcentajes
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CatalogoPorcentajes]', RESEED, 118)
GO


-- ----------------------------
-- Primary Key structure for table CatalogoPorcentajes
-- ----------------------------
ALTER TABLE [dbo].[CatalogoPorcentajes] ADD CONSTRAINT [PK__Catalogo__3BF6A4FA38BE4992] PRIMARY KEY CLUSTERED ([IdPorcentaje])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for CatalogoRegimen
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[CatalogoRegimen]', RESEED, 17)
GO


-- ----------------------------
-- Primary Key structure for table CatalogoRegimen
-- ----------------------------
ALTER TABLE [dbo].[CatalogoRegimen] ADD CONSTRAINT [PK__Catalogo__3214EC070B984843] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for Empresas
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[Empresas]', RESEED, 73)
GO


-- ----------------------------
-- Primary Key structure for table Empresas
-- ----------------------------
ALTER TABLE [dbo].[Empresas] ADD CONSTRAINT [PK_Empresas_Simple] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for Inpc
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[Inpc]', RESEED, 697)
GO


-- ----------------------------
-- Primary Key structure for table Inpc
-- ----------------------------
ALTER TABLE [dbo].[Inpc] ADD CONSTRAINT [PK__Inpc__3214EC0752FD00D0] PRIMARY KEY CLUSTERED ([Idnpc])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for Log_ReversionBajas
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[Log_ReversionBajas]', RESEED, 3)
GO


-- ----------------------------
-- Primary Key structure for table Log_ReversionBajas
-- ----------------------------
ALTER TABLE [dbo].[Log_ReversionBajas] ADD CONSTRAINT [PK__Log_Reve__3214EC0777C48AA6] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Auto increment value for Sujetos_Informacion
-- ----------------------------
DBCC CHECKIDENT ('[dbo].[Sujetos_Informacion]', RESEED, 1)
GO


-- ----------------------------
-- Uniques structure for table Sujetos_Informacion
-- ----------------------------
ALTER TABLE [dbo].[Sujetos_Informacion] ADD CONSTRAINT [UQ_RFC_Por_Empresa] UNIQUE NONCLUSTERED ([Id_Empresa] ASC, [RFC] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Primary Key structure for table Sujetos_Informacion
-- ----------------------------
ALTER TABLE [dbo].[Sujetos_Informacion] ADD CONSTRAINT [PK_Sujetos_Informacion] PRIMARY KEY CLUSTERED ([Id])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)  
ON [PRIMARY]
GO


-- ----------------------------
-- Foreign Keys structure for table Sujetos_Informacion
-- ----------------------------
ALTER TABLE [dbo].[Sujetos_Informacion] ADD CONSTRAINT [FK_Sujeto_Empresa] FOREIGN KEY ([Id_Empresa]) REFERENCES [dbo].[Empresas] ([Id]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO

ALTER TABLE [dbo].[Sujetos_Informacion] ADD CONSTRAINT [FK_TipoSujeto] FOREIGN KEY ([Id_TipoSujeto]) REFERENCES [conta].[Sujetos_CUFIN] ([Id_Sujeto]) ON DELETE NO ACTION ON UPDATE NO ACTION
GO

