USE master
GO

-- **** CREACIÓN DE LOGINS ****
-- Creación login administrador
IF NOT EXISTS(SELECT name FROM sys.syslogins
			  WHERE NAME = 'administrador')
	CREATE LOGIN administrador WITH PASSWORD = N'flicks4uEcuador2022'

-- Creación login gestorFunciones
IF NOT EXISTS(SELECT name FROM sys.syslogins
			  WHERE NAME = 'gestorFunciones')
	CREATE LOGIN gestorFunciones WITH PASSWORD = N'salasCineFlicks4uEcuador'

-- Creación login recursosHumanos
IF NOT EXISTS(SELECT name FROM sys.syslogins
			  WHERE NAME = 'recursosHumanos')
	CREATE LOGIN recursosHumanos WITH PASSWORD = N'recursosHumanosFlicks4UEcuador'

-- Creación login visualizadorReportes
IF NOT EXISTS(SELECT name FROM sys.syslogins
			  WHERE NAME = 'visualizadorReportes')
	CREATE LOGIN visualizadorReportes WITH PASSWORD = N'visulizadorFlicks4UEcuador'


-- **** CREACIÓN DE BASE DE DATOS ****
IF(DB_ID('Flicks4U') IS NOT NULL)
BEGIN
	ALTER DATABASE Flicks4U SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE Flicks4U
END
GO

CREATE DATABASE Flicks4U
GO

USE Flicks4U
GO

-- **** CREACIÓN DE TIPOS DE DATOS Y REGLAS ****

-- Creación de tipo de dato email
IF (TYPE_ID('email') IS NOT NULL)
    DROP TYPE email
GO

CREATE TYPE email
FROM nvarchar(50) NOT NULL
GO
Create Rule ck_email
as @email LIKE '%@%.%'
GO
sp_bindrule ck_email,'email'
GO

--Creación de tipo de dato phoneNumber
IF (TYPE_ID('phoneNumber') IS NOT NULL)
    DROP TYPE phoneNumber
GO

CREATE TYPE phoneNumber
FROM nvarchar(50) NOT NULL
GO
Create Rule ck_phoneNumber
as @phoneNumber LIKE '+%[0-9]% %[0-9]%'
GO
sp_bindrule ck_phoneNumber,'phoneNumber'
GO

--Creación de tipo de dato gender
IF (TYPE_ID('gender') IS NOT NULL)
    DROP TYPE phoneNumber
GO
IF (TYPE_ID('gender') IS NOT NULL)
    DROP TYPE phoneNumber
GO

CREATE TYPE gender
FROM char(1) NOT NULL
GO
Create Rule ck_gender
as @gender IN ('M', 'F', 'O')
GO
sp_bindrule ck_gender,'gender'
GO

--Creación de Esquema RecursosHumanos
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'RecursosHumanos')
    EXEC( 'CREATE SCHEMA RecursosHumanos' );
GO

--Creación de Esquema Funciones
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Funciones')
	EXEC( 'CREATE SCHEMA Funciones' );
GO

--Creación de Esquema Reportes
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Reportes')
	EXEC( 'CREATE SCHEMA Reportes' );
GO

-- **** CREACIÓN DE TABLAS ****
-- Creación de tabla Empleado
IF(OBJECT_ID('RecursosHumanos.Empleado') IS NOT NULL)
	DROP TABLE RecursosHumanos.Empleado
CREATE TABLE RecursosHumanos.Empleado
(
	Id SMALLINT IDENTITY (1, 1),
	DNI VARCHAR(10) NOT NULL UNIQUE,
	Nombres NVARCHAR(30) NOT NULL,
	Apellidos NVARCHAR(30) NOT NULL,
	Correo email NOT NULL UNIQUE,
	Telefono phoneNumber NOT NULL,
	Genero gender NOT NULL,
	FechaNacimiento DATE NOT NULL,
	FechaIngreso DATE NOT NULL DEFAULT GETDATE(),
	Direccion NVARCHAR(100) NOT NULL,
	FechaEgreso DATE NULL,
	Salario SMALLMONEY NOT NULL,
	Tipo varchar(45) NOT NULL,
	CONSTRAINT CK_salario CHECK (Salario > 0),
	CONSTRAINT CK_fechaNacimiento CHECK (FechaNacimiento < GETDATE() AND DATEDIFF(YEAR, FechaNacimiento, GETDATE()) >= 18),
	CONSTRAINT CK_tipo CHECK (Tipo IN ('Limpieza', 'Proyeccion')),
	CONSTRAINT CK_nombres CHECK (LEN(Nombres) > 0 AND ISNUMERIC(Nombres) = 0),
	CONSTRAINT CK_apellidos CHECK (LEN(Apellidos) > 0 AND ISNUMERIC(Apellidos) = 0),
	CONSTRAINT CK_direccion CHECK (LEN(Direccion) > 0),
	CONSTRAINT PK_Empleado PRIMARY KEY (Id)
)
GO

-- Creación de tabla HorarioLaboral
IF(OBJECT_ID('RecursosHumanos.HorarioLaboral') IS NOT NULL)
	DROP TABLE RecursosHumanos.HorarioLaboral
CREATE TABLE RecursosHumanos.HorarioLaboral
(
	EmpleadoId SMALLINT NOT NULL,
	NumeroDia TINYINT NOT NULL,
	HoraInicio TIME NULL,
	HoraFin TIME NULL,
	CONSTRAINT PK_HorarioLaboral PRIMARY KEY (EmpleadoId, NumeroDia),
	CONSTRAINT CK_NumeroDia CHECK(NumeroDia BETWEEN 1 AND 7),
	CONSTRAINT CK_Hora CHECK(HoraFin > HoraInicio),
	CONSTRAINT FK_Empleado FOREIGN KEY (EmpleadoId) REFERENCES RecursosHumanos.Empleado(Id)
)
GO

-- Creación de tabla Pelicula
IF(OBJECT_ID('Funciones.Pelicula') IS NOT NULL)
	DROP TABLE Funciones.Pelicula
CREATE TABLE Funciones.Pelicula
(
	Id INT IDENTITY (1,1),
	Nombre NVARCHAR(100) NOT NULL,
	Sinopsis TEXT NOT NULL,
	Genero VARCHAR(14) NOT NULL,
	Duracion TIME(0) NOT NULL,
	ImagenUrl VARCHAR(100) NOT NULL,
	Formato VARCHAR(10) NOT NULL,
	FechaEstreno DATE NOT NULL,
	FechaSalidaCartelera DATE NOT NULL,
	CONSTRAINT CK_Formato CHECK (Formato IN ('35mm', '16mm', 'digital', 'IMAX','digital3D')),
	CONSTRAINT CK_Genero CHECK (Genero IN ('Aventura', 'Terror', 'Comedia', 'Drama', 'Acción', 'Sci-fi')),
	CONSTRAINT CK_FechaSalidaCartelera CHECK (FechaSalidaCartelera > FechaEstreno AND datediff(MONTH, FechaEstreno, FechaSalidaCartelera) = 2),
	CONSTRAINT PK_Pelicula PRIMARY KEY (Id)
)
GO

-- Creación de tabla Sala
IF(OBJECT_ID('Funciones.Sala') IS NOT NULL)
	DROP TABLE Funciones.Sala
CREATE TABLE Funciones.Sala
(
	Id TINYINT IDENTITY (1,1),
	Aforo TINYINT NOT NULL,
	TipoSala VARCHAR(4) NOT NULL,
	TipoProyector CHAR(1) NOT NULL,
	CONSTRAINT CK_TipoSala CHECK (TipoSala IN ('REG', '3D', '4D', 'VBOX')),
	CONSTRAINT CK_Equipo CHECK (TipoProyector IN ('D', 'A')),
	CONSTRAINT PK_Sala PRIMARY KEY (Id)
)
GO

-- Creación de tabla Funcion
IF(OBJECT_ID('Funciones.Funcion') IS NOT NULL)
	DROP TABLE Funciones.Funcion
CREATE TABLE Funciones.Funcion
(
	Id INT identity (1,1),
	FechaInicio DATETIME,
	FechaFin DATETIME, --Duracion Pelicula + 5 min Anuncios + 30 min limpieza
	EmpleadoLimpiezaId SMALLINT NOT NULL,
	EmpleadoProyecionId SMALLINT NOT NULL,
	PeliculaId INT NOT NULL,
	SalaId TINYINT NOT NULL,
	CONSTRAINT PK_Funcion PRIMARY KEY (Id),
	CONSTRAINT FK_Pelicula FOREIGN KEY (PeliculaId) REFERENCES Funciones.Pelicula(Id),
	CONSTRAINT FK_Sala FOREIGN KEY (SalaId) REFERENCES Funciones.Sala(Id),
	CONSTRAINT FK_EmpleadoLimpieza FOREIGN KEY (EmpleadoLimpiezaId) REFERENCES RecursosHumanos.Empleado(Id),
	CONSTRAINT FK_EmpleadoProyeccion FOREIGN KEY (EmpleadoProyecionId) REFERENCES RecursosHumanos.Empleado(Id),
)
GO

-- Creación de Sinónimo EmpleadoParaGestor para esquema de funciones.
IF EXISTS (SELECT * FROM sys.synonyms WHERE NAME = 'EmpleadoParaGestor')
	DROP SYNONYM EmpleadoParaGestor
CREATE SYNONYM EmpleadoParaGestor FOR RecursosHumanos.Empleado
GO

ALTER SCHEMA Funciones TRANSFER OBJECT :: EmpleadoParaGestor
GO

-- Creación de Sinónimo HorarioEmpleadoParaGestor para esquema de funciones.
IF EXISTS (SELECT * FROM sys.synonyms WHERE NAME = 'HorarioEmpleadoParaGestor')
	DROP SYNONYM HorarioEmpleadoParaGestor
CREATE SYNONYM HorarioEmpleadoParaGestor FOR RecursosHumanos.HorarioLaboral
GO

ALTER SCHEMA Funciones TRANSFER OBJECT :: HorarioEmpleadoParaGestor
GO

-- Creación de Sinónimo PeliculaParaReportes para esquema de reportes.
IF EXISTS (SELECT * FROM sys.synonyms WHERE NAME = 'PeliculaParaReportes')
	DROP SYNONYM PeliculaParaReportes
CREATE SYNONYM PeliculaParaReportes FOR Funciones.Pelicula
GO

ALTER SCHEMA Reportes TRANSFER OBJECT :: PeliculaParaReportes
GO

-- Creación de Sinónimo FuncionesParaReportes para esquema de reportes.
IF EXISTS (SELECT * FROM sys.synonyms WHERE NAME = 'FuncionesParaReportes')
	DROP SYNONYM FuncionesParaReportes
CREATE SYNONYM FuncionesParaReportes FOR Funciones.Funcion
GO

ALTER SCHEMA Reportes TRANSFER OBJECT :: FuncionesParaReportes
GO

-- Creación de Sinónimo EmpleadoParaReportes para esquema de reportes.
IF EXISTS (SELECT * FROM sys.synonyms WHERE NAME = 'EmpleadoParaReportes')
	DROP SYNONYM EmpleadoParaReportes
CREATE SYNONYM EmpleadoParaReportes FOR RecursosHumanos.Empleado
GO

ALTER SCHEMA Reportes TRANSFER OBJECT :: EmpleadoParaReportes
GO

-- Creación de Sinónimo SalasParaReportes para esquema de reportes.
IF EXISTS (SELECT * FROM sys.synonyms WHERE NAME = 'SalasParaReportes')
	DROP SYNONYM SalasParaReportes
CREATE SYNONYM SalasParaReportes FOR Funciones.Sala
GO

ALTER SCHEMA Reportes TRANSFER OBJECT :: SalasParaReportes
GO


-- **** CREACIÓN DE USUARIOS ****
-- Creación de usuario administrador
IF DATABASE_PRINCIPAL_ID('administrador') IS NULL
BEGIN
    CREATE USER [administrador] FOR LOGIN [administrador] WITH DEFAULT_SCHEMA=[dbo]
END
GO

-- Creación de usuario gestorFunciones
IF DATABASE_PRINCIPAL_ID('gestorFunciones') IS NULL
BEGIN
	CREATE USER [gestorFunciones] FOR LOGIN [gestorFunciones] WITH DEFAULT_SCHEMA=[Funciones]
END
GO

-- Creación de usuario RRHH
IF DATABASE_PRINCIPAL_ID('RRHH') IS NULL
BEGIN
	CREATE USER [RRHH] FOR LOGIN [recursosHumanos] WITH DEFAULT_SCHEMA=[RecursosHumanos]
END
GO

-- Creación de usuario visualizadorReportes
IF DATABASE_PRINCIPAL_ID('visualizadorReportes') IS NULL
BEGIN
	CREATE USER [visualizadorReportes] FOR LOGIN visualizadorReportes WITH DEFAULT_SCHEMA=[Reportes]
END
GO

-- **** ASIGNACIÓN DE PERMISOS ****
-- Asignación de permiso a administrador como db_owner.
EXEC sp_addrolemember N'db_owner', N'administrador'
GO

-- Asignación de permisos a gestor de funciones de cine.
GRANT SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Funciones
TO gestorFunciones
GO

-- Asignación de permisos a RRHH
DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Funciones
TO RRHH
CASCADE
GO

DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Funciones
TO visualizadorReportes
CASCADE

-- Asignación de permisos a sinónimo EmpleadoParaGestor
GRANT SELECT ON Funciones.EmpleadoParaGestor TO gestorFunciones
GO

-- Asignación de permiso a visualizador de reportes.
GRANT SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Reportes
TO visualizadorReportes
GO

DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Reportes
TO gestorFunciones

-- Asignación de permisos a sinónimo HorarioEmpleadoParaGestor
GRANT SELECT ON Funciones.HorarioEmpleadoParaGestor TO gestorFunciones
GO

DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Reportes
TO RRHH
GO

-- Asignación de permisos a gestor de recursos humanos.
GRANT SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: RecursosHumanos
TO RRHH
GO

DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: RecursosHumanos
TO gestorFunciones
GO

DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: RecursosHumanos
TO visualizadorReportes
GO

-- Asignación de permisos a sinónimos para gestor de funciones.
GRANT SELECT ON Funciones.EmpleadoParaGestor TO gestorFunciones
GO

DENY INSERT, DELETE, UPDATE ON Funciones.EmpleadoParaGestor TO gestorFunciones
GO

GRANT SELECT ON Funciones.HorarioEmpleadoParaGestor TO gestorFunciones
GO

DENY INSERT, DELETE, UPDATE ON Funciones.HorarioEmpleadoParaGestor TO gestorFunciones
GO

-- Asignación de permisos a sinónimos para visualizador de reportes.
GRANT SELECT ON Reportes.EmpleadoParaReportes TO visualizadorReportes
GO

DENY INSERT, DELETE, UPDATE ON Reportes.EmpleadoParaReportes TO visualizadorReportes
GO

GRANT SELECT ON Reportes.FuncionesParaReportes TO visualizadorReportes
GO

DENY INSERT, DELETE, UPDATE ON Reportes.FuncionesParaReportes TO visualizadorReportes
GO

GRANT SELECT ON Reportes.PeliculaParaReportes TO visualizadorReportes
GO

DENY INSERT, DELETE, UPDATE ON Reportes.PeliculaParaReportes TO visualizadorReportes
GO

GRANT SELECT ON Reportes.SalasParaReportes TO visualizadorReportes
GO

DENY INSERT, DELETE, UPDATE ON Reportes.SalasParaReportes TO visualizadorReportes
GO

-- Asignación de permisos para ejecutar stored procedures a gestor sobre su esquema, 
-- configuración para evitar que otros usuarios ejecuten SPs que no sean de su esquema.
GRANT EXECUTE 
ON SCHEMA :: Funciones
TO gestorFunciones
GO

DENY EXECUTE
ON SCHEMA :: RecursosHumanos
TO RRHH
GO

DENY EXECUTE
ON SCHEMA :: RecursosHumanos
TO visualizadorReportes
GO

-- Asignación de permisos para ejecutar stored procedures a recursos humanos sobre su esquema, 
-- configuración para evitar que otros usuarios ejecuten SPs que no sean de su esquema.
GRANT EXECUTE
ON SCHEMA :: RecursosHumanos
TO RRHH
GO

DENY EXECUTE
ON SCHEMA :: RecursosHumanos
TO gestorFunciones
GO

DENY EXECUTE
ON SCHEMA :: RecursosHumanos
TO visualizadorReportes

-- Asignación de permisos para ejecutar stored procedures a recursos humanos sobre su esquema, 
-- configuración para evitar que otros usuarios ejecuten SPs que no sean de su esquema.
GRANT EXECUTE
ON SCHEMA :: Reportes
TO visualizadorReportes

DENY EXECUTE
ON SCHEMA :: Reportes
TO RRHH

DENY EXECUTE
ON SCHEMA :: Reportes
TO gestorFunciones
