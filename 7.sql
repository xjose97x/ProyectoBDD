USE Flicks4u
GO
--------------------------------------------------------------------------------------
-- Comentarios para cada columna de la tabla "Funciones.Funci�n"
--------------------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para la tabla la tabla "Funci�n". Es autoincremental y es de tipo INT. ' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena fecha y hora de inicio de una funci�n, se agrega directamente desde el stored procedure de "CrearFuncion_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'FechaInicio'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena fecha y hora de finalizaci�n de una funci�n. Se calcula en base a "FechaInicio" directamente desde "CrearFuncion_SP", donde a "FechaInicio" se suma la duraci�n de la pel�cula junto con 35 minutos que contemplan limpieza y anuncios. NO AGREGAR DIRECTAMENTE.' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'FechaFin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID que permite asignar un empleado de limpieza a una sala. Se lo asigna desde "CrearFuncion_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'EmpleadoLimpiezaId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID que permite asignar un empleado de proyecci�n a una sala. Se lo asigna desde "CrearFuncion_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'EmpleadoProyecionId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Permite asignar una pel�cula a una funci�n. Se utiliza dentro de FK_Pel�cula y se carga directamente desde "CrearFuncion_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'PeliculaId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Permite asignar una sala a una funci�n. Se utiliza dentro de FK_Sala y se carga directamente desde "CrearFuncion_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Funcion', @level2type=N'COLUMN',@level2name=N'SalaId'
GO

--------------------------------------------------------------------------------------
-- Comentarios para cada columna de la tabla "Funciones.Pel�cula"
--------------------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para la tabla de "Pel�cula". Es autoincremental y es de tipo INT.' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena el nombre de la pel�cula, es de tipo nvarchar y puede tener una longitud de hasta 100 caracteres. Se carga directamente en "InsertarPelicula_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'Nombre'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la sinopsis de la pel�cula. El tipo de dato utilizado es "Text" con el objetivo de almacenar cantidades grandes de texto. Se carga directamente en "InsertarPelicula_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'Sinopsis'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena el g�nero de la pel�cula. Flicks4u tiene una serie de opciones limitadas que pueden ser agregadas en este campo, estas siendo "Aventura", "Terror",  "Comedia", "Drama", "Acci�n", "Sci-fi". Se carga directamente en "InsertarPelicula_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'Genero'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena la duraci�n de la pel�cula. Se agrega con el formato de "HH:MM:SS" y no puede exceder las 4 horas que es la duraci�n m�xima permitida por Flicks4u. Se carga directamente desde "InsertarPelicula_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'Duracion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena un link directo de internet donde se alojan los posters promocionales de cada pel�cula. �nicamente se pueden cargar imagenes de formato jpg con formato "https://".  Se carga directamente desde "InsertarPelicula_SP"' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'ImagenUrl'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Determina en qu� tipo de proyector debe ser reproducida la pel�cula. Flicks4u �nicamente admite pel�culas en rollo de "35mm", "16mm", "digital", "IMAX" y "digital3D". Se carga directamente desde "InsertarPelicula_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'Formato'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Es de tipo DATE y se carga directamente desde "InsertarPelicula_SP" con el formato "YYYY-MM-DD".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'FechaEstreno'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Todas las pel�culas que se estrenan en Flicks4u tienen un tiempo en cartelera de 2 meses con ciertas variaciones en cantidades de d�as dependiendo del �xito del filme. Esto se debe cumplir en agregaciones a mano desde "InsertarPelicula_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Pelicula', @level2type=N'COLUMN',@level2name=N'FechaSalidaCartelera'
GO
--------------------------------------------------------------------------------------
-- Comentarios para cada columna de la tabla "Funciones.Sala"
--------------------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para la tabla de "Pel�cula". Es autoincremental y es de tipo TINYINT.' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Sala', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena cu�ntas personas puede alojar una sala, es de tipo TINYINT lo que significa que toda sala puede tener un l�mite de aforo de 255 personas. Se carga directamente desde "CrearSala_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Sala', @level2type=N'COLUMN',@level2name=N'Aforo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena el tipo de sala disponible en Flicks4u y tiene valores estandarizados de acuerdo a las necesidades de la empresa, estos siendo "REG" (regular), "3D", "4D" y "VBOX". Se carga directamente desde "CrearSala_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Sala', @level2type=N'COLUMN',@level2name=N'TipoSala'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'En Flicks4u, �nicamente manejamos dos tipos de proyectores, estos siendo an�logos ("A") y digitales ("D"), las especificaciones acerca del tipo de rollo que consumen las c�maras an�logas son dadas al empleado de proyecci�n al momento de entrar a la sala. Se carga directamente desde "CrearSala_SP".' , @level0type=N'SCHEMA',@level0name=N'Funciones', @level1type=N'TABLE',@level1name=N'Sala', @level2type=N'COLUMN',@level2name=N'TipoProyector'
GO
--------------------------------------------------------------------------------------
-- Agregar comentarios para cada columna de "RecursosHumanos.Empleado"
--------------------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para la tabla de "Empleado". Es autoincremental y es de tipo SMALLINT.' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena el identificacdor �nico de un empleado, este puede tener una longitud m�xima de 10 caracteres y debe ser �nico.  Se carga directamente desde "InsertarEmpleado_SP".' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'DNI'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena los nombres de un empleado para su registro en el sistema. No se pueden agregar valores num�ricos y tiene una longitud m�xima de 30 caracteres (incluyendo especiales). Se agrega directamente desde "InsertarEmpleado_SP"..' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Nombres'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena los apellidos de un empleado para su registro en el sistema. No se pueden agregar valores num�ricos, tiene una longitud m�xima de 30 caracteres (incluyendo especiales). Se agrega directamente desde "InsertarEmpleado_SP"..' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Apellidos'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hace uso de un tipo de dato customizado llamado "email" que requiere de inserciones de correo que cumplan con la inclusi�n de un "@" y un "." y una longitud m�xima de 50 caracteres (incluyendo especiales). Se carga direcamente desde Almacena los nombres de un empleado para su registro en el sistema. No se pueden agregar valores num�ricos y tiene una longitud m�xima de 30 caracteres. Se agrega directamente desde "InsertarEmpleado_SP".  ' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Correo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hace uso de un tipo de dato customizado llamado "phoneNumber" que requiere de inserciones de n�mero de tel�fono que cumplan con la inclusi�n de un "+", un n�mero de extensi�n y el resto de d�gitos de n�mero celular.  Se agrega directamente desde "InsertarEmpleado_SP".  ' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Telefono'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hace uso de un tipo de dato customizado llamado "gender" que requiere de inserciones de un solo caracter "M" (masculino), "F" (femenino) u "O" (otro). ' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Genero'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Es de tipo DATE y debe ser ingresado con el formato "YYYY-MM-DD", el sistema verifica que la fecha ingresada sea menor a la fecha actual y que la persona insertada sea mayor de edad (18 a�os). Se ingresa directamente desde "InsertarEmpleado_SP".' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'FechaNacimiento'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Es de tipo DATE y debe ser ingresado con el formato "YYYY-MM-DD". Se agrega directamente desde "InsertarEmpleado_SP" y tiene un valor default de GETDATE().' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'FechaIngreso'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Permite ingresar la direcci�n del empleado, se carga directamente desde "InsertarEmpleado_SP".' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Direccion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo nuleable, se define al momento de despedir al empleado o cuando este sale de la empresa por diferentes razones.' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'FechaEgreso'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'De tipo smallmoney, sirve para agregar los salarios de cada tipo de empleado. Los valores estandarizados son de $450 para empleado de limpieza y $700 d�lares para empleados de proyecci�n (al mes). Se agregan directamente desde "InsertarEmpleado_SP"' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Salario'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacena si el empleado es de "Limpieza" o de "Proyecci�n". Se agrega directamente desde "InsertarEmpleado_SP".' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'Empleado', @level2type=N'COLUMN',@level2name=N'Tipo'
GO
--------------------------------------------------------------------------------------
-- Agregar comentarios para cada columna de "RecursosHumanos.HorarioLaboral"
--------------------------------------------------------------------------------------
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para la tabla de "HorarioLaboral", se agrega conjuntamente con "NumeroDia" para determinar el cronograma de trabajo. Es autoincremental y es de tipo SMALLINT.' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'HorarioLaboral', @level2type=N'COLUMN',@level2name=N'EmpleadoId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Clave primaria para la tabla de "HorarioLaboral", se agrega conjuntamente con "EmpleadoId" para determinar a qu� empleado se le asigna un cronograma de trabajo. Es autoincremental, de tipo TINYINT. y �nicamente permite realizar inserciones desde el 1 hasta el 7' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'HorarioLaboral', @level2type=N'COLUMN',@level2name=N'NumeroDia'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'De tipo TIME, sirve para agregar la hora en la que un empleado inicia su horario laboral. Permite valores NULL para fines de semana puesto que se consideran d�as de trabajo extra con bonificaciones.' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'HorarioLaboral', @level2type=N'COLUMN',@level2name=N'HoraInicio'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'De tipo TIME, sirve para agregar la hora en la que un empleado termina su horario laboral.  Permite valores NULL para fines de semana puesto que se consideran d�as de trabajo extra con bonificaciones.' , @level0type=N'SCHEMA',@level0name=N'RecursosHumanos', @level1type=N'TABLE',@level1name=N'HorarioLaboral', @level2type=N'COLUMN',@level2name=N'HoraFin'
GO

