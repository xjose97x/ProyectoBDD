USE master
GO

alter database Flicks4U set single_user with rollback immediate

DROP DATABASE Flicks4U
DROP LOGIN administrador
DROP LOGIN gestorFunciones
DROP LOGIN recursosHumanos
DROP LOGIN visualizadorReportes