--REPORTES

USE Flicks4u
GO

--Reporte de funciones en una fecha especifica
CREATE PROC Reportes.Funciones_Dia_SP
(@Fecha DATE)
AS
BEGIN
	SELECT FP.Nombre AS 'Pelicula', FF.SalaId, FF.FechaInicio, FF.FechaFin,
		CONCAT(EL.Nombres, ' ', EL.Apellidos) AS 'Empleado Limpieza', 
		CONCAT(EP.Nombres, ' ', EP.Apellidos) AS 'Empleado Proyeccion' 
	FROM Reportes.FuncionesParaReportes AS FF
	JOIN Reportes.PeliculaParaReportes AS FP ON FP.Id = FF.PeliculaId
	JOIN Reportes.EmpleadoParaReportes AS EL ON EL.Id = FF.EmpleadoLimpiezaId
	JOIN Reportes.EmpleadoParaReportes AS EP ON EP.Id = FF.EmpleadoProyecionId
	WHERE CAST(FF.FechaInicio AS DATE) = '2022-06-19'
END
GO
--EXEC Reportes.Funciones_Dia_SP '2022-06-19'
--Estadistica de funciones por genero de pelicula.
--	--Genero, Cantidad En cartelera, Cantidad Fuera de cartelera, Total Tiempo en Pantalla
--Horario de un empleado en una fecha especifica

CREATE PROC Reportes.Horario_Empleado_SP
(@EmpleadoId INT, @Fecha DATE)
AS
BEGIN
	SELECT FP.Nombre AS 'Pelicula', FF.SalaId, CAST(FF.FechaInicio AS TIME(0)) AS 'Hora Inicio',
	CAST(FF.FechaFin AS TIME(0)) AS 'Hora Fin'
	FROM Reportes.FuncionesParaReportes AS FF
	JOIN Reportes.PeliculaParaReportes AS FP ON FP.Id = FF.PeliculaId
	WHERE (EmpleadoLimpiezaId = @EmpleadoId OR EmpleadoProyecionId = @EmpleadoId)
		AND CAST(FF.FechaInicio AS DATE) = @Fecha
END
GO
-- EXEC Reportes.Horario_Empleado_SP 1, '2022-06-19'

-- Permite recuperar las estadísticas de una película en base a su género.
CREATE PROC Reportes.Estadisticas_Pelicula_Genero_SP
(@Genero varchar(14))
AS
SELECT DISTINCT p.Nombre, p.Duracion as 'Duración', COUNT(f.PeliculaId) as 'Salas asignadas',
SUM(DATEDIFF(MINUTE,f.FechaInicio, f.FechaFin) - 35) as 'Tiempo reproducida',
COUNT(f.Fechainicio) * 35 as 'Tiempo muerto (limpieza, avances)',
SUM(DATEDIFF(MINUTE,f.FechaInicio, f.FechaFin)) AS 'Tiempo total acumulado'
FROM Reportes.PeliculaParaReportes as p
inner join Reportes.FuncionesParaReportes as f on f.PeliculaId = p.Id
inner join Reportes.SalasParaReportes as s on s.Id = f.SalaId
WHERE p.Genero = @Genero
GROUP BY p.Nombre, p.Duracion, p.Genero, f.SalaId
GO

-- EXEC Reportes.Estadisticas_Pelicula_Genero_SP 'Comedia'


