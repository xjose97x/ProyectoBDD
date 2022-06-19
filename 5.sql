--REPORTES

USE Flicks4U
GO

--REPORTE DE FUNCIONES EN UNA FECHA ESPECIFICA
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

