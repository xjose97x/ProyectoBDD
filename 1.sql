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
	Id INT PRIMARY KEY IDENTITY (1, 1),
	Dni VARCHAR(10) NOT NULL UNIQUE,
	Nombres NVARCHAR(30) NOT NULL,
	Apellidos NVARCHAR(30) NOT NULL,
	Correo email NOT NULL UNIQUE,
	Telefono phoneNumber NOT NULL,
	Genero gender NOT NULL,
	FechaNacimiento DATE NOT NULL,
	FechaIngreso DATE NOT NULL,
	Direccion NVARCHAR(100) NOT NULL,
	FechaEgreso DATE NULL,
	Salario SMALLMONEY NOT NULL,
	Tipo varchar(45) NOT NULL,
	CONSTRAINT ck_salario CHECK (Salario > 0),
	CONSTRAINT ck_fechaNacimiento CHECK (FechaNacimiento < GETDATE()),
	CONSTRAINT ck_tipo CHECK (Tipo IN ('Limpieza', 'Proyeccion')),
	CONSTRAINT ck_nombres CHECK (LEN(Nombres) > 0),
	CONSTRAINT ck_apellidos CHECK (LEN(Apellidos) > 0),
	CONSTRAINT ck_direccion CHECK (LEN(Direccion) > 0)
)
GO

CREATE TABLE RecursosHumanos.HorarioLaboral
(
	EmpleadoId INT NOT NULL FOREIGN KEY REFERENCES RecursosHumanos.Empleado(Id),
	NumeroDia TINYINT NOT NULL,
	HoraInicio TIME NULL,
	HoraFin TIME NULL,
	CONSTRAINT PK_HorarioLaboral PRIMARY KEY (EmpleadoId, NumeroDia),
	CONSTRAINT ck_NumeroDia CHECK(NumeroDia BETWEEN 1 AND 7),
	CONSTRAINT ck_Hora CHECK(HoraFin > HoraInicio)
)
GO

CREATE TABLE Funciones.Pelicula
(
	Id int PRIMARY KEY identity (1,1),
	Nombre nvarchar(100) NOT NULL,
	Sinopsis Text NOT NULL,
	Genero varchar(14) NOT NULL,
	Duracion time(0) NOT NULL,
	ImagenUrl varchar(100) NOT NULL,
	Formato varchar(10) NOT NULL,
	FechaEstreno DATE NOT NULL,
	FechaSalidaCartelera DATE NOT NULL,
	CONSTRAINT CK_Formato CHECK (Formato IN ('35mm', '16mm', 'digital', 'IMAX','digital3D')),
	CONSTRAINT CK_Genero CHECK (Genero IN ('Aventura', 'Terror', 'Comedia', 'Drama', 'Acción', 'Sci-fi')),
	CONSTRAINT CK_FechaSalidaCartelera CHECK (FechaSalidaCartelera > FechaEstreno AND datediff(MONTH, FechaEstreno, FechaSalidaCartelera) = 2)
)
GO

CREATE TABLE Funciones.Sala
(
	Id INT PRIMARY KEY identity (1,1),
	Aforo TINYINT NOT NULL,
	TipoSala VARCHAR(4) NOT NULL,
	TipoProyector CHAR(1) NOT NULL,
	CONSTRAINT ck_TipoSala CHECK (TipoSala IN ('REG', '3D', '4D', 'VBOX')),
	CONSTRAINT ck_Equipo CHECK (TipoProyector IN ('D', 'A'))
)
GO

CREATE TABLE Funciones.Funcion
(
	Id INT PRIMARY KEY identity (1,1),
	FechaInicio DATETIME,
	FechaFin DATETIME, --Duracion Pelicula + 5 min Anuncios + 30 min limpieza
	PeliculaId INT NOT NULL FOREIGN KEY REFERENCES Funciones.Pelicula(Id),
	SalaId INT NOT NULL FOREIGN KEY REFERENCES Funciones.Sala(Id),
	EmpleadoLimpiezaId INT NOT NULL FOREIGN KEY REFERENCES RecursosHumanos.Empleado(Id),
	EmpleadoProyecionId INT NOT NULL FOREIGN KEY REFERENCES RecursosHumanos.Empleado(Id)
)
GO

CREATE SYNONYM EmpleadoParaGestor FOR RecursosHumanos.Empleado
GO

ALTER SCHEMA Funciones TRANSFER OBJECT :: EmpleadoParaGestor
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

-- Asignación de permisos a sinónimo para gestor de funciones.
GRANT SELECT ON Funciones.EmpleadoParaGestor TO gestorFunciones
GO

-- Asignación de permisos a gestor de recursos humanos.
GRANT SELECT, INSERT, DELETE, UPDATE
ON SCHEMA :: RecursosHumanos
TO RRHH
GO