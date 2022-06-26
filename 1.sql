USE master
GO

CREATE LOGIN administrador WITH PASSWORD = N'flicks4uEcuador2022'
GO

CREATE LOGIN gestorFunciones WITH PASSWORD = N'salasCineFlicks4uEcuador'
GO

CREATE LOGIN recursosHumanos WITH PASSWORD = N'recursosHumanosFlicks4UEcuador'
GO

CREATE LOGIN visualizadorReportes WITH PASSWORD = N'visulizadorFlicks4UEcuador'
GO


CREATE DATABASE Flicks4U
GO

USE Flicks4U
GO

--Tipo de datos--
CREATE TYPE dbo.email
FROM nvarchar(50) NOT NULL
GO
Create Rule ck_email
as @email LIKE '%@%.%'
GO
sp_bindrule ck_email,'dbo.email'
GO

CREATE TYPE dbo.phoneNumber
FROM nvarchar(50) NOT NULL
GO
Create Rule ck_phoneNumber
as @phoneNumber LIKE '+%[0-9]% %[0-9]%'
GO
sp_bindrule ck_phoneNumber,'dbo.phoneNumber'
GO

CREATE TYPE dbo.gender
FROM char(1) NOT NULL
GO
Create Rule ck_gender
as @gender IN ('M', 'F', 'O')
GO
sp_bindrule ck_gender,'dbo.gender'
GO

CREATE SCHEMA RecursosHumanos
GO

CREATE SCHEMA Funciones
GO

CREATE SCHEMA Reportes
GO

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

CREATE SYNONYM EmpleadoParaGestor FOR RecursosHumanos.Empleado
GO

CREATE SYNONYM HorarioEmpleadoParaGestor FOR RecursosHumanos.HorarioLaboral
GO

ALTER SCHEMA Funciones TRANSFER OBJECT :: EmpleadoParaGestor
GO

ALTER SCHEMA Funciones TRANSFER OBJECT :: HorarioEmpleadoParaGestor
GO


CREATE USER [administrador] FOR LOGIN [administrador] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [gestorFunciones] FOR LOGIN [gestorFunciones] WITH DEFAULT_SCHEMA=[Funciones]
GO

CREATE USER [RRHH] FOR LOGIN [recursosHumanos] WITH DEFAULT_SCHEMA=[RecursosHumanos]
GO

CREATE USER [visualizadorReportes] FOR LOGIN visualizadorReportes WITH DEFAULT_SCHEMA=[Reportes]
GO

-- Asignación de permiso a administrador como db_owner.
EXEC sp_addrolemember N'db_owner', N'administrador'
GO

-- Asignación de permiso a gestor de funciones de cine.
GRANT SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Funciones
TO gestorFunciones
GO

DENY SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: Funciones
TO RRHH
CASCADE
GO

-- Asignación de permisos a sinónimo para gestor de funciones.
GRANT SELECT ON Funciones.EmpleadoParaGestor TO gestorFunciones
GO

DENY SELECT ON Funciones.EmpleadoParaGestor TO RRHH
GO

GRANT SELECT ON Funciones.HorarioEmpleadoParaGestor TO gestorFunciones
GO

DENY SELECT ON Funciones.HorarioEmpleadoParaGestor TO RRHH
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