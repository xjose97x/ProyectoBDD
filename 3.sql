USE Flicks4U
GO

EXEC Funciones.Insertar_Pelicula_SP 'Up', 'Un hombre amargado le cuelga globos a su casa y viaja a Sudamérica', 'Comedia', '01:47:00', 'https://disney.com/up/up.jpg', 'digital', '2010-05-05', '2010-07-05'
EXEC Funciones.Insertar_Pelicula_SP 'Jurassic World: Dominion', 'La última parte en la saga épica de Jurassic Park', 'Aventura', '02:31:00', 'https://universalapi.com/jurassicworld/dominion/poster.jpg', 'digital', '2022-04-07', '2022-06-07'
EXEC Funciones.Insertar_Pelicula_SP 'Men', 'Una mujer tiene experiencias extrañas cuando se va de vacaciones para recuperarse de una tragedia', 'Terror', '02:01:00', 'https://a24api.com/men/men.jpg', '35mm', '2022-06-05', '2022-08-05'
EXEC Funciones.Insertar_Pelicula_SP 'Top Gun: Maverick', 'Después de 30 años de servicio, Maverick se niega a retirarse.', 'Acción', '02:10:00', 'https://paramount.com/topgun/maverick/poster.jpg', 'IMAX', '2022-05-05', '2022-07-05'
EXEC Funciones.Insertar_Pelicula_SP 'Todo al mismo tiempo en todas partes', 'Una mujer descubre que tiene el poder de salvar el multiverso de su hija.', 'Sci-fi', '02:14:00', 'https://a24.com/EEAAO/poster.jpg', '16mm', '2022-05-05', '2022-07-05'
EXEC Funciones.Insertar_Pelicula_SP 'Doctor Strange en el multiverso de la locura', 'Doctor Strange se enfrenta a una nueva amenaza, la Bruja Escarlata que busca apoderarse de los poderes de una joven que viaja a través de los universos', 'Sci-fi', '02:05:00', 'https://disney.com/drstrange/multiverseofmaddness/drstrange.jpg', 'digital3D', '2022-05-05', '2022-07-15'
EXEC Funciones.Insertar_Pelicula_SP 'Doctor Strange en el multiverso de la locura', 'Doctor Strange se enfrenta a una nueva amenaza, la Bruja Escarlata que busca apoderarse de los poderes de una joven que viaja a través de los universos', 'Sci-fi', '02:05:00', 'https://disney.com/drstrange/multiverseofmaddness/drstrange.jpg', 'digital', '2022-05-05', '2022-07-15'
EXEC Funciones.Insertar_Pelicula_SP 'Sonic 2', 'Las nuevas aventuras de Sonic. Esta vez, tiene que volver a enfrentar a Dr. Robotnik y su nuevo secuaz con la ayuda de nuevos aliados.', 'Aventura', '02:02:00', 'https://paramount.com/sonic/movie/sequel/poster.jpg', 'digital3D', '2022-05-17', '2022-07-19'
EXEC Funciones.Insertar_Pelicula_SP 'Lightyear', 'La historia de origen de Buzz Lightyear, una aventura intergaláctica junto a un grupo de ambiciosos reclutas y su divertido compañero robot Sox.', 'Aventura', '01:46:00', 'https://disney.com/lightyear/poster.jpg', 'digital', '2022-06-16', '2022-08-21'
EXEC Funciones.Insertar_Pelicula_SP 'Thor: Amor y Trueno', 'La película encuentra a Thor (Chris Hemsworth) en un viaje diferente a todo lo que ha enfrentado: una búsqueda de paz interior. Pero su retiro es interrumpido por un asesino de la galaxia conocido como Gorr, el Carnicero de Dioses (Christian Bale), que busca la extinción de los dioses.', 'Acción', '02:13:00', 'https://disney.com/marvel/thor/loveandthunder.jpg', 'IMAX', '2022-07-03', '2022-09-05'
EXEC Funciones.Insertar_Pelicula_SP 'El Gato con Botas: El último deseo', 'El último deseo sigue las nuevas andanzas del temerario y valiente felino. En esta ocasión, el campestre personaje descubrirá el precio de su pasión por el peligro y el no tenerle miedo a la muerte.', 'Aventura', '01:40:00', 'https://universal.com/dreamworks/pussinboots2/poster.jpg', 'IMAX', '2022-10-05', '2022-12-05'
EXEC Funciones.Insertar_Pelicula_SP 'Crimes of the Future', 'En un futuro no muy lejano la humanidad está aprendiendo a adaptarse a su entorno sintético, en un mundo donde no existe el dolor. Esta evolución lleva a los humanos más allá de su estado natural y hacia una metamorfosis, alterando su estructura biológica.', 'Terror', '01:47:00', 'https://telefilm.com/international/crimesofthefuture/poster.jpg', '35mm', '2022-05-22', '2022-07-22'
GO
EXEC Funciones.Crear_Sala_SP 250, 'REG', 'D'
EXEC Funciones.Crear_Sala_SP 200, 'REG', 'D'
EXEC Funciones.Crear_Sala_SP 180, 'REG', 'A'
EXEC Funciones.Crear_Sala_SP 150, 'REG', 'D'
EXEC Funciones.Crear_Sala_SP 150, 'REG', 'A'

EXEC Funciones.Crear_Sala_SP 200, '3D', 'D'
EXEC Funciones.Crear_Sala_SP 180, '3D', 'D'
EXEC Funciones.Crear_Sala_SP 180, '3D', 'D'

EXEC Funciones.Crear_Sala_SP 120, '4D', 'D'
EXEC Funciones.Crear_Sala_SP 90, '4D', 'D'

EXEC Funciones.Crear_Sala_SP 100, 'VBOX', 'D'
EXEC Funciones.Crear_Sala_SP 90, 'VBOX', 'D'

EXEC RecursosHumanos.Insertar_Empleado_SP '1700000000', 'Pepito', 'De Los Palotes', 'pepito@delospalotes.com', '+593 4512312', 'M', '2000-01-01', 'Av. Granados E4-12', 450.00, 'Limpieza'
EXEC RecursosHumanos.Insertar_Empleado_SP '1700000002', 'Patricio', 'Estrella', 'patricioe@gmail.com', '+593 4512232', 'M', '1997-01-16', 'Av. La Prensa E4-12', 500.00, 'Limpieza'

EXEC RecursosHumanos.Insertar_Empleado_SP '1200000000', 'Juan Carlos', 'Bodoque', 'juancarlos@bodoque.com', '+593 987654421', 'M', '1997-01-01', 'Av. Amazonas E4-12', 700.00, 'Proyeccion'
EXEC RecursosHumanos.Insertar_Empleado_SP '1200000003', 'Miguel', 'Brito', 'miguelb@gmail.com', '+593 98123451', 'M', '2000-12-12', 'Av. 10 de Agosto E4-12', 800.00, 'Proyeccion'

--Inserción de funciones
EXEC Funciones.Crear_Funcion_SP '20220620 10:30:00 AM', 1, 1, 1, 3
EXEC Funciones.Crear_Funcion_SP '20220620 01:30:00 PM', 1, 1, 1, 3

EXEC Funciones.Crear_Funcion_SP '20220620 01:30:00 PM', 2, 2, 2, 4
EXEC Funciones.Crear_Funcion_SP '20220620 03:30:00 PM', 2, 2, 2, 4
GO