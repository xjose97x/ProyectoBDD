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