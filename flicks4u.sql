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


CREATE TABLE RecursosHumanos.HorarioLaboral
(
	EmpleadoId INT NOT NULL,
	NumeroDia TINYINT NOT NULL,
	HoraInicio TIME NULL,
	HoraFin TIME NULL,
	CONSTRAINT PK_HorarioLaboral PRIMARY KEY (EmpleadoId, NumeroDia),
	CONSTRAINT ck_NumeroDia CHECK(NumeroDia BETWEEN 1 AND 7),
	CONSTRAINT ck_Hora CHECK(HoraFin > HoraInicio)
)
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

CREATE PROCEDURE CrearSala_SP
    (@AFORO TINYINT,
    @TIPO_SALA VARCHAR(4),
	@TIPO_PROYECTOR CHAR(1),
	@NewId INT = NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF @AFORO < 10
			THROW 60000, 'El aforo minimo es de 10 personas.', 1; 
		ELSE
			INSERT INTO Sala(Aforo, TipoSala, TipoProyector)
			VALUES(@AFORO, @TIPO_SALA, @TIPO_PROYECTOR)
			SET @NewId = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		PRINT N'Error durante la inserción a la tabla [Sala]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO

CREATE PROCEDURE InsertarPelicula_SP
(@Nombre nvarchar(100), @Sinopsis Text, @Genero varchar(14), @Duracion time(0), @ImagenUrl varchar(100),
@Formato varchar(10), @FechaEstreno Date, @FechaSalidaCartelera Date, @NewId INT = NULL OUTPUT)
AS
	SET NOCOUNT ON
	BEGIN TRY
		DECLARE @CondicionDuracion time(0)
		SET @CondicionDuracion = '04:00:00'
		IF (@Duracion > @CondicionDuracion)
			THROW 60000, 'La duración excede el tiempo permitido.', 1; 
		ELSE
			INSERT INTO Pelicula (Nombre, Sinopsis, Genero, Duracion, ImagenUrl, Formato, FechaEstreno, FechaSalidaCartelera)
			VALUES (@Nombre, @Sinopsis, @Genero, @Duracion, @ImagenUrl, @Formato, @FechaEstreno, @FechaSalidaCartelera)
			SET @NewId = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		PRINT N'Error durante la inserción a la tabla [Pelicula]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
GO

CREATE PROC ObtenerEstadoSala_SP
    (@ID_SALA INT,
	 @FECHA_INICIO DATETIME,
	 @FECHA_FIN DATETIME,
	 @RESULTADO varchar(15) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		--VALIDAR SI EXISTE SALA--
		IF NOT EXISTS(SELECT * FROM Sala WHERE Id = @ID_SALA)
			THROW 60000, 'La sala no existe.', 1; 
		ELSE
			IF EXISTS (SELECT * FROM Funcion
						WHERE SalaId = @ID_SALA
						AND @FECHA_INICIO >= FechaInicio AND @FECHA_FIN <= FechaFin)
				SET @resultado = 'No disponible'
			ELSE
				SET @resultado = 'Disponible'
	END TRY
	BEGIN CATCH
		PRINT N'Error al intentar obtener el estado de [Sala]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO

CREATE PROC ObtenerEstadoEmpleado_SP
    (@ID_EMPLEADO INT,
	 @FECHA_INICIO DATETIME,
	 @FECHA_FIN DATETIME,
	 @RESULTADO varchar(15) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF NOT EXISTS(SELECT * FROM Empleado WHERE Id = @ID_EMPLEADO)
			THROW 60000, 'El empleado no existe', 1; 
		ELSE
			--VALIDAR SI EMPLEADO SE ENCUENTRA EN HORARIO LABORAL--
			DECLARE @dayNumber INT
			SET @dayNumber = (SELECT DATEPART(WEEKDAY, @FECHA_INICIO))
		
			DECLARE @horaInicio TIME(0)
			DECLARE @horaFin TIME(0)
			SET @horaInicio = (SELECT HoraInicio FROM HorarioLaboral WHERE EmpleadoId = @ID_EMPLEADO AND NumeroDia = @dayNumber)
			SET @horaFin = (SELECT HoraFin FROM HorarioLaboral WHERE EmpleadoId = @ID_EMPLEADO AND NumeroDia = @dayNumber)

			IF (@horaInicio < CONVERT(TIME, @FECHA_INICIO) OR @horaFin < CONVERT(TIME, @FECHA_FIN)) OR
				EXISTS (SELECT * FROM Funcion
							WHERE (EmpleadoLimpiezaId = @ID_EMPLEADO OR EmpleadoProyecionId = @ID_EMPLEADO)
							AND @FECHA_INICIO >= FechaInicio AND @FECHA_FIN <= FechaFin)
				SET @resultado = 'No disponible'
			ELSE
				SET @resultado = 'Disponible'
	END TRY
	BEGIN CATCH
		PRINT N'Error al intentar obtener el estado de [Empleado]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO


CREATE PROC CrearFuncion_SP
    (@FECHA_INICIO DATETIME,
	@PELICULA_ID INT,
	@SALA_ID INT,
	@EMPLEADO_LIMPIEZA_ID INT,
	@EMPLEADO_PROYECTOR_ID INT,
	@NewId INT = NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF NOT EXISTS(SELECT * FROM Pelicula WHERE Id = @PELICULA_ID)
			THROW 60000, 'La pelicula no existe', 1; 
		ELSE IF NOT EXISTS (SELECT * FROM Sala WHERE Id = @SALA_ID)
			THROW 60000, 'La sala no existe', 1; 
		ELSE IF NOT EXISTS(SELECT * FROM Empleado WHERE id = @EMPLEADO_LIMPIEZA_ID)
			THROW 60000, 'El empleado de limpieza no existe', 1; 
		ELSE IF NOT EXISTS(SELECT * FROM Empleado WHERE id = @EMPLEADO_PROYECTOR_ID)
			THROW 60000, 'El empleado de proyeccion no existe', 1; 
		ELSE
			DECLARE @fechaFin DATETIME
			SET @fechaFin = @FECHA_INICIO +
							CAST((SELECT Duracion FROM Pelicula WHERE Id = @PELICULA_ID) as datetime) +
							CAST('00:35:00' as datetime)
			DECLARE @estadoSala VARCHAR(15)
			EXEC ObtenerEstadoSala_SP @SALA_ID, @FECHA_INICIO, @fechaFin, @estadoSala OUTPUT

			DECLARE @estadoEmpleadoLimpieza VARCHAR(15)
			EXEC ObtenerEstadoEmpleado_SP @EMPLEADO_LIMPIEZA_ID, @FECHA_INICIO, @fechaFin, @estadoEmpleadoLimpieza OUTPUT

			DECLARE @estadoEmpleadoProyeccion VARCHAR(15)
			EXEC ObtenerEstadoEmpleado_SP @EMPLEADO_PROYECTOR_ID, @FECHA_INICIO, @fechaFin, @estadoEmpleadoProyeccion OUTPUT


			IF @estadoSala = 'No disponible'
				THROW 60000, 'La sala no se encuentra disponible.', 1; 
			ELSE IF @estadoEmpleadoLimpieza = 'No disponible'
				THROW 60000, 'El empleado de limpieza no se encuentra disponible.', 1; 
			ELSE IF @estadoEmpleadoProyeccion = 'No disponible'
				THROW 60000, 'El empleado de proyeccion no se encuentra disponible.', 1; 
			ELSE
				INSERT INTO Funcion (FechaInicio, FechaFin, PeliculaId, SalaId, EmpleadoLimpiezaId, EmpleadoProyecionId)
					VALUES (@FECHA_INICIO, @fechaFin, @PELICULA_ID, @SALA_ID, @EMPLEADO_LIMPIEZA_ID,@EMPLEADO_PROYECTOR_ID)
				SET @NewId = SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
		PRINT N'Error durante la inserción a la tabla [Funcion]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO


CREATE PROC Insertar_HorarioLaboral_SP
(
	@IdEmpleado INT,
	@NumeroDia TINYINT,
	@HoraInicio TIME,
	@HoraFin TIME
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		INSERT INTO HorarioLaboral(EmpleadoId, NumeroDia, HoraInicio, HoraFin)
		VALUES (@IdEmpleado, @NumeroDia, @HoraInicio, @HoraFin)
	END TRY
	BEGIN CATCH
		PRINT N'Error durante la inserción a la tabla [HorarioLaboral]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO

CREATE PROCEDURE Insertar_Empleado_SP
(
	@dni varchar(10),
	@nombres NVARCHAR(30),
	@apellidos NVARCHAR(30),
	@correo email,
	@telefono phoneNumber,
	@genero gender,
	@fechaNacimiento DATE,
	@direccion NVARCHAR(100),
	@salario SMALLMONEY,
	@tipo VARCHAR(45),
	@NewId INT = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		INSERT INTO Empleado
		( Dni, Nombres, Apellidos, Correo, Telefono, Genero, FechaNacimiento,
		  FechaIngreso, Direccion, Salario, Tipo)
		VALUES
		( @dni, @nombres, @apellidos, @correo, @telefono, @genero, @fechaNacimiento,
			GETDATE(), @direccion, @salario, @tipo )
		SET @NewId = SCOPE_IDENTITY();

		EXEC Insertar_HorarioLaboral_SP @NewId, 1, NULL, NULL
		EXEC Insertar_HorarioLaboral_SP @NewId, 2, '08:00:00', '16:00:00'
		EXEC Insertar_HorarioLaboral_SP @NewId, 3, '08:00:00', '16:00:00'
		EXEC Insertar_HorarioLaboral_SP @NewId, 4, '08:00:00', '16:00:00'
		EXEC Insertar_HorarioLaboral_SP @NewId, 5, '08:00:00', '16:00:00'
		EXEC Insertar_HorarioLaboral_SP @NewId, 6, '08:00:00', '16:00:00'
		EXEC Insertar_HorarioLaboral_SP @NewId, 7, NULL, NULL

	END TRY
	BEGIN CATCH
		PRINT N'Error durante la inserción a la tabla [Empleado]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO

CREATE PROC DespedirEmpleado_SP
(
	@IdEmpleado INT
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		IF NOT EXISTS(SELECT * FROM Empleado WHERE Id = @IdEmpleado)
			THROW 60000, 'El empleado no existe.', 1; 
		ELSE IF EXISTS(SELECT * FROM Empleado WHERE Id = @IdEmpleado AND FechaEgreso IS NULL)
			THROW 60000, 'El empleado ya fue despedido.', 1; 
		ELSE
			UPDATE Empleado
			SET FechaEgreso = GETDATE()
			WHERE Id = @IdEmpleado
	END TRY
	BEGIN CATCH
		PRINT N'Error intentando despedir a un [Empleado]'
		PRINT ERROR_MESSAGE()
		PRINT N'Número de error: '+ CAST(ERROR_NUMBER() AS varchar(10))
		PRINT N'Estado: ' + CAST(ERROR_SEVERITY() AS varchar(20))
		PRINT N'Severidad: ' + CAST(ERROR_SEVERITY() AS varchar(10))
		PRINT N'Línea de error: ' + CAST(ERROR_LINE() AS varchar(10));
		THROW;
	END CATCH
END
GO

CREATE PROC ModificarEmpleado
(
	@EmpleadoId INT,
	@Dni VARCHAR(10),
	@Nombres NVARCHAR(30),
	@Apellidos NVARCHAR(30),
	@Correo email,
	@Telefono phoneNumber,
	@Genero gender,
	@FechaNacimiento DATE,
	@FechaIngreso DATE,
	@Direccion NVARCHAR(100),
	@FechaEgreso DATE,
	@Salario SMALLMONEY,
	@Tipo varchar(45)
)
AS
BEGIN
	BEGIN TRY
		UPDATE Empleado
		SET Dni = @Dni,
			Nombres = @Nombres,
			Apellidos = @Apellidos,
			Correo = @Correo,
			Telefono = @Telefono,
			Genero = @Genero,
			FechaNacimiento = @FechaNacimiento,
			Direccion = @Direccion,
			FechaEgreso = @FechaEgreso,
			Salario = @Salario,
			Tipo = @Tipo
		WHERE Id = @EmpleadoId
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage AS NVARCHAR(4000);
		DECLARE @errorSeverity AS INT;
		DECLARE @errorState as INT;
		SELECT @errorMessage = ERROR_MESSAGE(), @errorSeverity = ERROR_SEVERITY(), @errorState = ERROR_STATE()
		RAISERROR(@errorMessage, @errorSeverity, @errorState);
	END CATCH
END

-- Creación de logins para tres tipos de usuarios.
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

-- Creación de usuarios a nivel de base de datos.
Use Flicks4U
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