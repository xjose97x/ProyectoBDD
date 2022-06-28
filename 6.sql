USE Flicks4U
GO

-- Menu de funcionalidades relacionadas al esquema de funciones
CREATE PROCEDURE menuFunciones_SP
AS
BEGIN
	PRINT 'ESQUEMA FUNCIONES'
	PRINT ''
	PRINT '		Funciones.Crear_Funcion_SP @FechaInicio, @PeliculaId, @SalaId, @EmpleadoLimpiezaId, @EmpleadoProyectorId - Crea una nueva funcion'
	PRINT ''
	PRINT '		Funciones.Crear_Sala_SP @Aforo, @TipoSala, @TipoProyector - Crea una nueva sala'
	PRINT ''
	PRINT '		Funciones.Insertar_Pelicula_SP @Nombre, @Sinopsis, @Genero, @Duracion, @ImagenUrl, @Formato, @FechaEstreno, @FechaSalidaCartelera - Crea una nueva pelicula'
	PRINT ''
	PRINT '		Funciones.Obtener_Estado_Sala_SP @IdSala, @FechaInicio, @FechaFin - Retorna el estado de una sala entre un rango de fechas'
	PRINT ''
	PRINT '		Funciones.Obtener_Estado_Empleado_SP @IdEmpleado, @FechaInicio, @FechaFin - Retorna el estado de un empleado en un rango de fechas'
	PRINT ''
END
GO

-- Menu de funcionalidades relacionadas al esquema de recursos humanos
CREATE PROCEDURE menuRecursosHumanos_SP
AS
BEGIN
	PRINT 'ESQUEMA RECURSOS HUMANOS'
	PRINT ''
	PRINT '		RecursosHumanos.Insertar_HorarioLaboral_SP @IdEmpleado, @NumeroDia, @HoraInicio, @HoraFin - Inserta un horario laboral'
	PRINT ''
	PRINT '		RecursosHumanos.Insertar_Empleado_SP @dni, @nombres, @apellidos, @correo, @telefono, @genero, @fechaNacimiento, @direccion, @salario, @tipo - Inserta un nuevo empleado'
	PRINT ''
	PRINT '		RecursosHumanos.Despedir_Empleado_SP @IdEmpleado - Remueve un empleado existente'
	PRINT ''
END
GO
	
-- Menu de reportes
CREATE PROCEDURE menuReportes_SP
AS
BEGIN
	PRINT 'REPORTES'
	PRINT ''
	PRINT '		FuncionesDia_SP @Fecha - Reporte de Funciones en un día especifico'
	PRINT ''
	PRINT '		HorarioEmpleado_SP @EmpleadoId, @Fecha - Reporte de horario de un empleado en una fecha especifica'
	PRINT ''
END
GO

-- Procedimiento almacenado encargado de imprimir el menu
CREATE PROCEDURE menu_SP
AS
BEGIN
	IF (SUSER_NAME() = 'gestorFunciones')
	BEGIN
		PRINT ''
		PRINT '------ MENU GESTOR DE FUNCIONES ------'
		PRINT ''
		EXEC menuFunciones_SP
		EXEC menuReportes_SP
	END
	ELSE IF (SUSER_NAME() = 'recursosHumanos')
	BEGIN
		PRINT ''
		PRINT '------ MENU RECURSOS HUMANOS ------'
		PRINT ''
		EXEC menuRecursosHumanos_SP
		EXEC menuReportes_SP
	END
	ELSE IF (SUSER_NAME() = 'visualizadorReportes')
	BEGIN
		PRINT ''
		PRINT '------ MENU VISUALIZADOR REPORTES ------'
		PRINT ''
		EXEC menuReportes_SP
	END
	ELSE
	BEGIN
		PRINT ''
		PRINT '------ MENU ADMINISTRADOR ------'
		PRINT ''
		EXEC menuFunciones_SP
		EXEC menuRecursosHumanos_SP
		EXEC menuReportes_SP
	END
END
GO

--DROP PROC menuFunciones_SP
--DROP PROC menuReportes_SP
--DROP PROC menuRecursosHumanos_SP
--DROP PROC menu_SP

--USE Flicks4U
--GO
--EXEC menu_SP