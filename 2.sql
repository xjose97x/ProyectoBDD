USE Flicks4U
GO

-- Stored Procedures para Sala
CREATE PROCEDURE Funciones.Crear_Sala_SP
(@AFORO TINYINT, @TIPO_SALA VARCHAR(4), @TIPO_PROYECTOR CHAR(1), @NEW_ID TINYINT = NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF @AFORO < 10
			THROW 60000, 'El aforo minimo es de 10 personas.', 1; 
		ELSE
			INSERT INTO Funciones.Sala(Aforo, TipoSala, TipoProyector)
			VALUES(@AFORO, @TIPO_SALA, @TIPO_PROYECTOR)
			SET @NEW_ID = SCOPE_IDENTITY();
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

CREATE PROCEDURE Funciones.Obtener_Estado_Sala_SP
(@ID_SALA INT, @FECHA_INICIO DATETIME, @FECHA_FIN DATETIME, @RESULTADO VARCHAR(15) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		--VALIDAR SI EXISTE SALA--
		IF NOT EXISTS(SELECT * FROM Funciones.Sala WHERE Id = @ID_SALA)
			THROW 60000, 'La sala no existe.', 1; 
		ELSE
			IF EXISTS (SELECT * FROM Funciones.Funcion
						WHERE SalaId = @ID_SALA
						AND (FechaInicio <= @FECHA_FIN) AND (@FECHA_INICIO <= FechaFin))
				SET @RESULTADO = 'No disponible'
			ELSE
				SET @RESULTADO = 'Disponible'
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


-- Stored  Procedures para Pelicula
CREATE PROCEDURE Funciones.Insertar_Pelicula_SP
(@NOMBRE NVARCHAR(100), @SINOPSIS TEXT, @GENERO VARCHAR(14), @DURACION  TIME(0), @IMAGEN_URL VARCHAR(100),
@FORMATO varchar(10), @FECHA_ESTRENO DATE, @FECHA_SALIDA_CARTELERA Date, @NEW_ID INT = NULL OUTPUT)
AS
	SET NOCOUNT ON
	BEGIN TRY
		DECLARE @CondicionDuracion time(0)
		SET @CondicionDuracion = '04:00:00'
		IF (@Duracion > @CondicionDuracion)
			THROW 60000, 'La duración excede el tiempo permitido.', 1; 
		ELSE
			INSERT INTO Funciones.Pelicula (Nombre, Sinopsis, Genero, Duracion, ImagenUrl, Formato, FechaEstreno, FechaSalidaCartelera)
			VALUES (@NOMBRE, @SINOPSIS, @GENERO, @DURACION, @IMAGEN_URL, @FORMATO, @FECHA_ESTRENO, @FECHA_SALIDA_CARTELERA)
			SET @NEW_ID = SCOPE_IDENTITY();
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

-- Stored Procedures para Empleado
CREATE PROCEDURE RecursosHumanos.Insertar_HorarioLaboral_SP
(@ID_EMPLEADO SMALLINT, @NUMERO_DIA TINYINT, @HORA_INICIO TIME, @HORA_FIN TIME)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		INSERT INTO RecursosHumanos.HorarioLaboral(EmpleadoId, NumeroDia, HoraInicio, HoraFin)
		VALUES (@ID_EMPLEADO, @NUMERO_DIA, @HORA_INICIO, @HORA_FIN)
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

CREATE PROCEDURE RecursosHumanos.Insertar_Empleado_SP
(@DNI VARCHAR(10), @NOMBRES NVARCHAR(30), @APELLIDOS NVARCHAR(30), @CORREO EMAIL, 
 @TELEFONO phoneNumber, @GENERO gender, @FECHA_NACIMIENTO DATE, @DIRECCION NVARCHAR(100),
 @SALARIO SMALLMONEY, @TIPO VARCHAR(45), @NEW_ID SMALLINT = NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		INSERT INTO RecursosHumanos.Empleado
		( Dni, Nombres, Apellidos, Correo, Telefono, Genero, FechaNacimiento,
		  FechaIngreso, Direccion, Salario, Tipo)
		VALUES
		( @DNI, @NOMBRES, @APELLIDOS, @CORREO, @TELEFONO, @GENERO, @FECHA_NACIMIENTO,
			GETDATE(), @DIRECCION, @SALARIO, @TIPO )
		SET @NEW_ID = SCOPE_IDENTITY();

		-- Insertar horario laboral por defecto
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 1, NULL, NULL
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 2, '08:00:00', '16:00:00'
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 3, '08:00:00', '16:00:00'
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 4, '08:00:00', '16:00:00'
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 5, '08:00:00', '16:00:00'
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 6, '08:00:00', '16:00:00'
		EXEC  RecursosHumanos.Insertar_HorarioLaboral_SP @NEW_ID, 7, NULL, NULL

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

CREATE PROCEDURE Funciones.Obtener_Estado_Empleado_SP
(@ID_EMPLEADO SMALLINT, @FECHA_INICIO DATETIME, @FECHA_FIN DATETIME, @RESULTADO VARCHAR(15) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF NOT EXISTS(SELECT * FROM Funciones.EmpleadoParaGestor WHERE Id = @ID_EMPLEADO)
			THROW 60000, 'El empleado no existe', 1; 
		ELSE
			--VALIDAR SI EMPLEADO SE ENCUENTRA EN HORARIO LABORAL
			DECLARE @dayNumber INT
			SET @dayNumber = (SELECT DATEPART(WEEKDAY, @FECHA_INICIO))
		
			DECLARE @horaInicio TIME(0)
			DECLARE @horaFin TIME(0)
			SET @horaInicio = (SELECT HoraInicio FROM Funciones.HorarioEmpleadoParaGestor WHERE EmpleadoId = @ID_EMPLEADO AND NumeroDia = @dayNumber)
			SET @horaFin = (SELECT HoraFin FROM Funciones.HorarioEmpleadoParaGestor WHERE EmpleadoId = @ID_EMPLEADO AND NumeroDia = @dayNumber)

			IF (CONVERT(TIME(0), @FECHA_INICIO) >= @horaInicio AND  CONVERT(TIME(0), @FECHA_FIN) <= @horaFin)
				AND NOT EXISTS (SELECT * FROM Funciones.Funcion
								WHERE (EmpleadoLimpiezaId = @ID_EMPLEADO OR EmpleadoProyecionId = @ID_EMPLEADO)
								AND (FechaInicio <= @FECHA_FIN) AND (@FECHA_INICIO <= FechaFin))
				SET @RESULTADO = 'Disponible'
			ELSE
				SET @RESULTADO = 'No disponible'
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

CREATE PROCEDURE RecursosHumanos.Despedir_Empleado_SP
(@ID_EMPLEADO INT)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		IF NOT EXISTS(SELECT * FROM RecursosHumanos.Empleado WHERE Id = @ID_EMPLEADO)
			THROW 60000, 'El empleado no existe.', 1; 
		ELSE IF EXISTS(SELECT * FROM RecursosHumanos.Empleado WHERE Id = @ID_EMPLEADO AND FechaEgreso IS NULL)
			THROW 60000, 'El empleado ya fue despedido.', 1; 
		ELSE
			UPDATE RecursosHumanos.Empleado
			SET FechaEgreso = GETDATE()
			WHERE Id = @ID_EMPLEADO
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

-- Stored Procedures para Funcion
CREATE PROCEDURE Funciones.Crear_Funcion_SP
(@FECHA_INICIO DATETIME, @PELICULA_ID INT, @SALA_ID TINYINT, @EMPLEADO_LIMPIEZA_ID SMALLINT,
@EMPLEADO_PROYECTOR_ID SMALLINT, @NEW_ID INT = NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF NOT EXISTS(SELECT * FROM Funciones.Pelicula WHERE Id = @PELICULA_ID)
			THROW 60000, 'La pelicula no existe', 1; 
		ELSE IF NOT EXISTS (SELECT * FROM Funciones.Sala WHERE Id = @SALA_ID)
			THROW 60000, 'La sala no existe', 1; 
		ELSE IF NOT EXISTS(SELECT * FROM Funciones.EmpleadoParaGestor WHERE id = @EMPLEADO_LIMPIEZA_ID)
			THROW 60000, 'El empleado de limpieza no existe', 1; 
		ELSE IF NOT EXISTS(SELECT * FROM Funciones.EmpleadoParaGestor WHERE id = @EMPLEADO_PROYECTOR_ID)
			THROW 60000, 'El empleado de proyeccion no existe', 1; 
		ELSE
			DECLARE @fechaFin DATETIME
			SET @fechaFin = @FECHA_INICIO +
							CAST((SELECT Duracion FROM Funciones.Pelicula WHERE Id = @PELICULA_ID) as datetime) +
							CAST('00:35:00' as datetime)
			DECLARE @estadoSala VARCHAR(15)
			EXEC Funciones.Obtener_Estado_Sala_SP @SALA_ID, @FECHA_INICIO, @fechaFin, @estadoSala OUTPUT

			DECLARE @estadoEmpleadoLimpieza VARCHAR(15)
			EXEC Funciones.Obtener_Estado_Empleado_SP @EMPLEADO_LIMPIEZA_ID, @FECHA_INICIO, @fechaFin, @estadoEmpleadoLimpieza OUTPUT

			DECLARE @estadoEmpleadoProyeccion VARCHAR(15)
			EXEC Funciones.Obtener_Estado_Empleado_SP @EMPLEADO_PROYECTOR_ID, @FECHA_INICIO, @fechaFin, @estadoEmpleadoProyeccion OUTPUT

			IF @estadoSala = 'No disponible'
				THROW 60000, 'La sala no se encuentra disponible.', 1; 
			ELSE IF @estadoEmpleadoLimpieza = 'No disponible'
				THROW 60000, 'El empleado de limpieza no se encuentra disponible.', 1; 
			ELSE IF @estadoEmpleadoProyeccion = 'No disponible'
				THROW 60000, 'El empleado de proyeccion no se encuentra disponible.', 1; 
			ELSE
				INSERT INTO Funciones.Funcion (FechaInicio, FechaFin, PeliculaId, SalaId, EmpleadoLimpiezaId, EmpleadoProyecionId)
					VALUES (@FECHA_INICIO, @fechaFin, @PELICULA_ID, @SALA_ID, @EMPLEADO_LIMPIEZA_ID,@EMPLEADO_PROYECTOR_ID)
				SET @NEW_ID = SCOPE_IDENTITY();
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
