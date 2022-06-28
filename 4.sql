USE Flicks4u
GO

CREATE PROC Funciones.Obtener_Estado_Sala_SP
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

CREATE PROC Funciones.Obtener_Estado_Empleado_SP
    (@ID_EMPLEADO SMALLINT,
	 @FECHA_INICIO DATETIME,
	 @FECHA_FIN DATETIME,
	 @RESULTADO varchar(15) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
    BEGIN TRY
		IF NOT EXISTS(SELECT * FROM Funciones.EmpleadoParaGestor WHERE Id = @ID_EMPLEADO)
			THROW 60000, 'El empleado no existe', 1; 
		ELSE
			--VALIDAR SI EMPLEADO SE ENCUENTRA EN HORARIO LABORAL--
			DECLARE @dayNumber INT
			SET @dayNumber = (SELECT DATEPART(WEEKDAY, @FECHA_INICIO))
		
			DECLARE @horaInicio TIME(0)
			DECLARE @horaFin TIME(0)
			SET @horaInicio = (SELECT HoraInicio FROM Funciones.HorarioEmpleadoParaGestor WHERE EmpleadoId = @ID_EMPLEADO AND NumeroDia = @dayNumber)
			SET @horaFin = (SELECT HoraFin FROM Funciones.HorarioEmpleadoParaGestor WHERE EmpleadoId = @ID_EMPLEADO AND NumeroDia = @dayNumber)

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

CREATE PROC RecursosHumanos.Despedir_Empleado_SP
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