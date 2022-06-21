CREATE PROC Funciones.ObtenerEstadoSala_SP
    (@ID_SALA INT,
	 @FECHA_INICIO DATETIME,
	 @FECHA_FIN DATETIME,
	 @RESULTADO varchar(15) OUTPUT)
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
				EXISTS (SELECT * FROM Funciones.Funcion
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


CREATE PROC Funciones.ProgramarFuncion_SP
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
				INSERT INTO Funciones.Funcion (FechaInicio, FechaFin, PeliculaId, SalaId, EmpleadoLimpiezaId, EmpleadoProyecionId)
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

CREATE PROC RecursosHumanos.DespedirEmpleado_SP
(
	@IdEmpleado INT
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		IF NOT EXISTS(SELECT * FROM RecursosHumanos.Empleado WHERE Id = @IdEmpleado)
			THROW 60000, 'El empleado no existe.', 1; 
		ELSE IF EXISTS(SELECT * FROM RecursosHumanos.Empleado WHERE Id = @IdEmpleado AND FechaEgreso IS NULL)
			THROW 60000, 'El empleado ya fue despedido.', 1; 
		ELSE
			UPDATE RecursosHumanos.Empleado
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