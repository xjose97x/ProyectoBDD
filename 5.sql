--REPORTES

USE Flicks4U
GO

--Reporte de funciones en una fecha especifica
CREATE PROC FuncionesDia_SP
(@Fecha DATE)
AS
BEGIN
	SELECT FP.Nombre AS 'Pelicula', FF.SalaId, FF.FechaInicio, FF.FechaFin,
		CONCAT(EL.Nombres, ' ', EL.Apellidos) AS 'Empleado Limpieza', 
		CONCAT(EP.Nombres, ' ', EP.Apellidos) AS 'Empleado Proyeccion' 
	FROM Funciones.Funcion AS FF
	JOIN Funciones.Pelicula AS FP ON FP.Id = FF.PeliculaId
	JOIN RecursosHumanos.Empleado AS EL ON EL.Id = FF.EmpleadoLimpiezaId
	JOIN RecursosHumanos.Empleado AS EP ON EP.Id = FF.EmpleadoProyecionId
	WHERE CAST(FF.FechaInicio AS DATE) = @Fecha
END

--EXEC FuncionesDia_SP '2022-06-19'

--Estadistica de funciones por genero de pelicula.
--	--Genero, Cantidad En cartelera, Cantidad Fuera de cartelera, Total Tiempo en Pantalla

--Horario de un empleado en una fecha especifica
CREATE PROC HorarioEmpleado_SP
(@EmpleadoId INT, @Fecha DATE)
AS
BEGIN
	SELECT FP.Nombre AS 'Pelicula', FF.SalaId, CAST(FF.FechaInicio AS TIME(0)) AS 'Hora Inicio',
		CAST(FF.FechaFin AS TIME(0)) AS 'Hora Fin' FROM Funciones.Funcion AS FF
	JOIN Funciones.Pelicula AS FP ON FP.Id = FF.PeliculaId
	WHERE (EmpleadoLimpiezaId = @EmpleadoId OR EmpleadoProyecionId = @EmpleadoId)
		AND CAST(FF.FechaInicio AS DATE) = @Fecha
END

--EXEC HorarioEmpleado_SP 1, '2022-06-21'