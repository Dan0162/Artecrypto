--Insertar personas

    INSERT INTO Persona (Nombre, Correo, Telefono) 
    VALUES 
    ('Ana Artista', 'persona01@example.com', 67000010),
    ('Bruno Curador', 'persona02@example.com', 67000011),
    ('Carla Coleccionista', 'persona03@example.com', 67000012),
    ('Diego Diseñador', 'persona04@example.com', 67000013),
    ('Diego Diseñador', 'persona05@example.com', 67000013),
    ('Elena Curadora', 'persona06@example.com', 67000014),
    ('Fernando Artista', 'persona07@example.com', 67000015),
    ('Gabriela Coleccionista', 'persona08@example.com', 67000016),
    ('Héctor Curador', 'persona09@example.com', 67000017),
    ('Irene Ilustradora', 'persona10@example.com', 67000018),
    ('Irene Ilustradora', 'persona11@example.com', 67000018),
    ('Javier Joyero', 'persona12@example.com', 67000019),
    ('Karla Kinetica', 'persona13@example.com', 67000020),
    ('Luis Lienzo', 'persona14@example.com', 67000021),
    ('Marina Mosaico', 'persona15@example.com', 67000022),
    ('Nicolás Nuevo', 'persona16@example.com', 67000023),
    ('Olga Óptica', 'persona17@example.com', 67000024),
    ('Pablo Pixel', 'persona18@example.com', 67000025),
    ('Queta Querida', 'persona19@example.com', 67000026),
    ('Rafael Retro', 'persona20@example.com', 67000027),
    ('Sandra Serigrafía', 'persona21@example.com', 67000028),
    ('Sandra Serigrafía', 'persona22@example.com', 67000028),
    ('Tomás Tipografía', 'persona23@example.com', 67000029);
GO


--Dar roles
INSERT INTO Entidad_Rol (ID_Persona, ID_TipoEntidad, Fecha_Registro) VALUES 
(1, 1, GETDATE()),  -- Ana Artista
(2, 2, GETDATE()),  -- Bruno Curador
(3, 3, GETDATE()),  -- Carla Coleccionista 3
(4, 1, GETDATE()),  -- Diego Diseñador
(5, 2, GETDATE()),  -- Elena Curadora
(6, 1, GETDATE()),  -- Fernando Artista
(7, 3, GETDATE()),  -- Gabriela Coleccionista 7
(8, 2, GETDATE()),  -- Héctor Curador
(9, 1, GETDATE()),  -- Irene Ilustradora
(10,1, GETDATE()),  -- Javier Joyero
(11,3, GETDATE()),  -- Karla Kinetica
(12,3, GETDATE()),  -- Luis Lienzo
(13,3, GETDATE()),  -- Marina Mosaico
(14,1, GETDATE()),  -- Nicolás Nuevo
(15,1, GETDATE()),  -- Olga Óptica
(16,3, GETDATE()),  -- Pablo Pixel 16
(17,3, GETDATE()),  -- Queta Querida 16
(18,1, GETDATE()),  -- Rafael Retro
(19,1, GETDATE()),  -- Sandra Serigrafía
(20,1, GETDATE());  -- Tomás Tipografía

--Crear y dar saldo a la billeteras
--A los coleccionistas
INSERT INTO Billetera (ID_Persona, Saldo_Disponible, Saldo_Reservado)
SELECT
    er.ID_Persona,
    3000.00, -- Saldo inicial
    0.00  -- Reservado inicial
FROM Entidad_Rol er
WHERE
    -- 1. Busca el ID del rol 'Coleccionista'
    er.ID_TipoEntidad = (SELECT ID_TipoEntidad FROM Tipo_Entidad WHERE Nombre = 'Coleccionista')
AND NOT EXISTS (
    -- 2. Y que NO exista ya en la tabla Billetera
    SELECT 1
    FROM Billetera b
    WHERE b.ID_Persona = er.ID_Persona
);
GO

--A los artistas
INSERT INTO Billetera (ID_Persona, Saldo_Disponible, Saldo_Reservado)
SELECT
    er.ID_Persona,
    0.00, -- Saldo inicial
    0.00  -- Reservado inicial
FROM Entidad_Rol er
WHERE
    -- 1. Busca el ID del rol 'Coleccionista'
    er.ID_TipoEntidad = (SELECT ID_TipoEntidad FROM Tipo_Entidad WHERE Nombre = 'Artista')
AND NOT EXISTS (
    -- 2. Y que NO exista ya en la tabla Billetera
    SELECT 1
    FROM Billetera b
    WHERE b.ID_Persona = er.ID_Persona
);
GO

Select *
from Billetera

-- Insertar NFT's
-- Insertar NFT's solo para artistas (ID_TipoEntidad = 1)
EXEC usp_CrearNFT 
    @ID_Persona = 1, @ID_Formato = 1, @ID_Tipo = 1, 
    @Nombre = 'Reflejo Cósmico #01', @Descripcion = 'Espejo digital que refleja galaxias en movimiento.', 
    @Tamaño = 65.00, @Ancho = 95.00, @Alto = 70.00, @Precio = 7;

EXEC usp_CrearNFT 
    @ID_Persona = 4, @ID_Formato = 2, @ID_Tipo = 3, 
    @Nombre = 'Ecos del Tiempo #07', @Descripcion = 'Generativo que simula ondas temporales en capas.', 
    @Tamaño = 80.00, @Ancho = 85.00, @Alto = 85.00, @Precio = 6.75;

EXEC usp_CrearNFT 
    @ID_Persona = 6, @ID_Formato = 3, @ID_Tipo = 4, 
    @Nombre = 'Retro Game Over', @Descripcion = 'Pantalla de Game Over en estilo arcade 80s animado.', 
    @Tamaño = 18.00, @Ancho = 64.00, @Alto = 48.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 9, @ID_Formato = 1, @ID_Tipo = 2, 
    @Nombre = 'Sombras del Pasado', @Descripcion = 'Fotografía en B&N de ruinas antiguas al atardecer.', 
    @Tamaño = 42.00, @Ancho = 100.00, @Alto = 66.00, @Precio = 5.00;

EXEC usp_CrearNFT 
    @ID_Persona = 10, @ID_Formato = 2, @ID_Tipo = 5, 
    @Nombre = 'Torre de Datos 3D', @Descripcion = 'Estructura 3D de servidores con flujo de datos.', 
    @Tamaño = 80.00, @Ancho = 80.00, @Alto = 80.00, @Precio = 2.3;

EXEC usp_CrearNFT 
    @ID_Persona = 14, @ID_Formato = 3, @ID_Tipo = 1, 
    @Nombre = 'Fuego Azul #22', @Descripcion = 'Llamas azules danzando en cámara lenta.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 70.00, @Precio = 11.00;

EXEC usp_CrearNFT 
    @ID_Persona = 15, @ID_Formato = 1, @ID_Tipo = 3, 
    @Nombre = 'Vórtice Generativo', @Descripcion = 'Torbellino de partículas en colores neón.', 
    @Tamaño = 95.00, @Ancho = 100.00, @Alto = 100.00, @Precio = 21;

EXEC usp_CrearNFT 
    @ID_Persona = 18, @ID_Formato = 2, @ID_Tipo = 4, 
    @Nombre = '8-Bit Warrior', @Descripcion = 'Personaje de videojuego en estilo retro animado.', 
    @Tamaño = 22.00, @Ancho = 40.00, @Alto = 60.00, @Precio = 3.80;

EXEC usp_CrearNFT 
    @ID_Persona = 19, @ID_Formato = 3, @ID_Tipo = 5, 
    @Nombre = 'Planeta Giratorio', @Descripcion = 'Modelo 3D de planeta con atmósfera dinámica.', 
    @Tamaño = 80.00, @Ancho = 75.00, @Alto = 75.00, @Precio = 12;

EXEC usp_CrearNFT 
    @ID_Persona = 20, @ID_Formato = 1, @ID_Tipo = 1, 
    @Nombre = 'Sueño Eléctrico #99', @Descripcion = 'Obra abstracta con líneas de energía y pulsos.', 
    @Tamaño = 55.00, @Ancho = 90.00, @Alto = 70.00, @Precio = 7.50;

EXEC usp_CrearNFT 
    @ID_Persona = 1, @ID_Formato = 1, @ID_Tipo = 1, 
    @Nombre = 'Neón Nocturno #01', @Descripcion = 'Ciudad cyberpunk con luces de neón y lluvia digital.', 
    @Tamaño = 45.00, @Ancho = 80.00, @Alto = 60.00, @Precio = 1.5;

EXEC usp_CrearNFT 
    @ID_Persona = 4, @ID_Formato = 2, @ID_Tipo = 3, 
    @Nombre = 'Fractal del Vacío #001', @Descripcion = 'Patrón generativo infinito en tonos azul profundo.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 90.00, @Precio = 5.00;

EXEC usp_CrearNFT 
    @ID_Persona = 6, @ID_Formato = 3, @ID_Tipo = 2, 
    @Nombre = 'Atardecer Pixelado', @Descripcion = 'Fotografía de atardecer convertida en pixel art 8-bit.', 
    @Tamaño = 15.00, @Ancho = 64.00, @Alto = 48.00, @Precio = 2.5;

EXEC usp_CrearNFT 
    @ID_Persona = 9, @ID_Formato = 1, @ID_Tipo = 4, 
    @Nombre = 'Glitch Portrait #07', @Descripcion = 'Retrato digital con errores de datos y distorsión.', 
    @Tamaño = 80.00, @Ancho = 100.00, @Alto = 75.00, @Precio = 7.50;

EXEC usp_CrearNFT 
    @ID_Persona = 10, @ID_Formato = 2, @ID_Tipo = 5, 
    @Nombre = 'Cubo Giratorio 3D', @Descripcion = 'Modelo 3D animado de un cubo con texturas cambiantes.', 
    @Tamaño = 70.00, @Ancho = 70.00, @Alto = 70.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 14, @ID_Formato = 3, @ID_Tipo = 1, 
    @Nombre = 'Ola Digital #12', @Descripcion = 'Animación fluida de olas abstractas en tonos turquesa.', 
    @Tamaño = 80.00, @Ancho = 85.00, @Alto = 60.00, @Precio = 10.00;

EXEC usp_CrearNFT 
    @ID_Persona = 15, @ID_Formato = 1, @ID_Tipo = 3, 
    @Nombre = 'Mandelbrot Zoom #03', @Descripcion = 'Zoom infinito en el conjunto de Mandelbrot.', 
    @Tamaño = 100.00, @Ancho = 100.00, @Alto = 100.00, @Precio = 1.5;

EXEC usp_CrearNFT 
    @ID_Persona = 18, @ID_Formato = 2, @ID_Tipo = 2, 
    @Nombre = 'Silueta Urbana', @Descripcion = 'Fotografía en blanco y negro de rascacielos al amanecer.', 
    @Tamaño = 25.00, @Ancho = 90.00, @Alto = 60.00, @Precio = 4.00;

EXEC usp_CrearNFT 
    @ID_Persona = 19, @ID_Formato = 3, @ID_Tipo = 4, 
    @Nombre = 'Pixel Cat #001', @Descripcion = 'Gato animado en estilo pixel art con movimiento.', 
    @Tamaño = 12.00, @Ancho = 32.00, @Alto = 32.00, @Precio = 2.5;

EXEC usp_CrearNFT 
    @ID_Persona = 20, @ID_Formato = 1, @ID_Tipo = 5, 
    @Nombre = 'Esfera Reflectante', @Descripcion = 'Modelo 3D de esfera con reflejos dinámicos.', 
    @Tamaño = 80.00, @Ancho = 80.00, @Alto = 80.00, @Precio = 8.00;

EXEC usp_CrearNFT 
    @ID_Persona = 1, @ID_Formato = 3, @ID_Tipo = 1, 
    @Nombre = 'Fuego Eterno #40', @Descripcion = 'Animación de llamas danzantes con partículas.', 
    @Tamaño = 90.00, @Ancho = 95.00, @Alto = 70.00, @Precio = 12.00;

EXEC usp_CrearNFT 
    @ID_Persona = 4, @ID_Formato = 2, @ID_Tipo = 1, 
    @Nombre = 'Ecos del Silencio', @Descripcion = 'Arte digital minimalista con ondas sonoras visualizadas.', 
    @Tamaño = 38.00, @Ancho = 90.00, @Alto = 60.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 6, @ID_Formato = 3, @ID_Tipo = 3, 
    @Nombre = 'Caos Organizado #11', @Descripcion = 'Generativo que transforma ruido en patrones simétricos.', 
    @Tamaño = 100.00, @Ancho = 100.00, @Alto = 100.00, @Precio = 9.50;

EXEC usp_CrearNFT 
    @ID_Persona = 9, @ID_Formato = 1, @ID_Tipo = 4, 
    @Nombre = 'Sprite Knight #03', @Descripcion = 'Personaje de RPG en 16-bit con animación de ataque.', 
    @Tamaño = 14.00, @Ancho = 48.00, @Alto = 48.00, @Precio = 1.4;

EXEC usp_CrearNFT 
    @ID_Persona = 10, @ID_Formato = 2, @ID_Tipo = 2, 
    @Nombre = 'Luz al Final', @Descripcion = 'Fotografía de túnel con luz dramática y contraste.', 
    @Tamaño = 55.00, @Ancho = 95.00, @Alto = 63.00, @Precio = 6.00;

EXEC usp_CrearNFT 
    @ID_Persona = 14, @ID_Formato = 3, @ID_Tipo = 5, 
    @Nombre = 'Nebulosa Pulsante', @Descripcion = 'Modelo 3D de nebulosa con pulsos de luz y partículas.', 
    @Tamaño = 80.00, @Ancho = 80.00, @Alto = 80.00, @Precio = 2.5;

EXEC usp_CrearNFT 
    @ID_Persona = 15, @ID_Formato = 1, @ID_Tipo = 1, 
    @Nombre = 'Pinceladas Eléctricas', @Descripcion = 'Pintura digital con trazos de energía y color vivo.', 
    @Tamaño = 72.00, @Ancho = 100.00, @Alto = 75.00, @Precio = 8.20;

EXEC usp_CrearNFT 
    @ID_Persona = 18, @ID_Formato = 2, @ID_Tipo = 3, 
    @Nombre = 'Río de Datos', @Descripcion = 'Flujo generativo de información en forma de río digital.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 70.00, @Precio = 1;

EXEC usp_CrearNFT 
    @ID_Persona = 19, @ID_Formato = 3, @ID_Tipo = 4, 
    @Nombre = 'Retro Arcade Loop', @Descripcion = 'Bucle de juego arcade con sprites y efectos 8-bit.', 
    @Tamaño = 20.00, @Ancho = 64.00, @Alto = 64.00, @Precio = 3.90;

EXEC usp_CrearNFT 
    @ID_Persona = 20, @ID_Formato = 1, @ID_Tipo = 5, 
    @Nombre = 'Cristal Fracturado 3D', @Descripcion = 'Modelo 3D de cristal roto con reflejos internos.', 
    @Tamaño = 80.00, @Ancho = 85.00, @Alto = 85.00, @Precio = 1;

EXEC usp_CrearNFT 
    @ID_Persona = 1, @ID_Formato = 2, @ID_Tipo = 2, 
    @Nombre = 'Niebla Matutina', @Descripcion = 'Fotografía de paisaje envuelto en niebla suave.', 
    @Tamaño = 48.00, @Ancho = 100.00, @Alto = 66.00, @Precio = 5.50;

EXEC usp_CrearNFT 
    @ID_Persona = 4, @ID_Formato = 3, @ID_Tipo = 1, 
    @Nombre = 'Luz Fractal #08', @Descripcion = 'Animación de luz atravesando estructuras fractales.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 70.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 6, @ID_Formato = 1, @ID_Tipo = 3, 
    @Nombre = 'Código Vivo #04', @Descripcion = 'Generativo que simula código evolucionando en tiempo real.', 
    @Tamaño = 90.00, @Ancho = 100.00, @Alto = 75.00, @Precio = 7.80;

EXEC usp_CrearNFT 
    @ID_Persona = 9, @ID_Formato = 2, @ID_Tipo = 4, 
    @Nombre = 'Pixel Dragon #01', @Descripcion = 'Dragón animado en 16-bit con fuego y vuelo.', 
    @Tamaño = 28.00, @Ancho = 64.00, @Alto = 48.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 10, @ID_Formato = 3, @ID_Tipo = 2, 
    @Nombre = 'Reflejo en el Agua', @Descripcion = 'Fotografía de lago con reflejo perfecto y niebla.', 
    @Tamaño = 65.00, @Ancho = 95.00, @Alto = 63.00, @Precio = 6.50;

EXEC usp_CrearNFT 
    @ID_Persona = 14, @ID_Formato = 1, @ID_Tipo = 5, 
    @Nombre = 'Esfera de Energía 3D', @Descripcion = 'Modelo 3D de esfera con energía interna pulsante.', 
    @Tamaño = 80.00, @Ancho = 80.00, @Alto = 80.00, @Precio = 10;

EXEC usp_CrearNFT 
    @ID_Persona = 15, @ID_Formato = 2, @ID_Tipo = 1, 
    @Nombre = 'Ojo del Horizonte', @Descripcion = 'Arte digital con horizonte circular y luz central.', 
    @Tamaño = 88.00, @Ancho = 100.00, @Alto = 100.00, @Precio = 9.00;

EXEC usp_CrearNFT 
    @ID_Persona = 18, @ID_Formato = 3, @ID_Tipo = 3, 
    @Nombre = 'Partículas Danzantes', @Descripcion = 'Generativo de partículas con movimiento orgánico.', 
    @Tamaño = 80.00, @Ancho = 85.00, @Alto = 85.00, @Precio = 1;

EXEC usp_CrearNFT 
    @ID_Persona = 19, @ID_Formato = 1, @ID_Tipo = 4, 
    @Nombre = 'Retro Spaceship', @Descripcion = 'Nave espacial animada en estilo 8-bit con propulsión.', 
    @Tamaño = 18.00, @Ancho = 48.00, @Alto = 32.00, @Precio = 4.20;

EXEC usp_CrearNFT 
    @ID_Persona = 20, @ID_Formato = 2, @ID_Tipo = 2, 
    @Nombre = 'Cielo Tormentoso', @Descripcion = 'Fotografía de tormenta con relámpagos y nubes dramáticas.', 
    @Tamaño = 75.00, @Ancho = 100.00, @Alto = 66.00, @Precio = 1.9;

EXEC usp_CrearNFT 
    @ID_Persona = 1, @ID_Formato = 3, @ID_Tipo = 5, 
    @Nombre = 'Cubo Infinito 3D', @Descripcion = 'Modelo 3D de cubo con reflejos infinitos internos.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 90.00, @Precio = 13.00;

EXEC usp_CrearNFT 
    @ID_Persona = 4, @ID_Formato = 1, @ID_Tipo = 1, 
    @Nombre = 'Portal al Vacío', @Descripcion = 'Arte digital con portal circular que absorbe luz.', 
    @Tamaño = 68.00, @Ancho = 100.00, @Alto = 75.00, @Precio = 1.5;

EXEC usp_CrearNFT 
    @ID_Persona = 6, @ID_Formato = 2, @ID_Tipo = 3, 
    @Nombre = 'Red Neuronal Viva', @Descripcion = 'Generativo que simula conexiones neuronales en expansión.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 90.00, @Precio = 10.50;

EXEC usp_CrearNFT 
    @ID_Persona = 9, @ID_Formato = 3, @ID_Tipo = 4, 
    @Nombre = 'Retro Robot #05', @Descripcion = 'Robot animado en 8-bit con movimientos mecánicos.', 
    @Tamaño = 16.00, @Ancho = 32.00, @Alto = 48.00, @Precio = 2.5;

EXEC usp_CrearNFT 
    @ID_Persona = 10, @ID_Formato = 1, @ID_Tipo = 2, 
    @Nombre = 'Cascada Oculta', @Descripcion = 'Fotografía de cascada en selva profunda con luz filtrada.', 
    @Tamaño = 58.00, @Ancho = 95.00, @Alto = 63.00, @Precio = 7.00;

EXEC usp_CrearNFT 
    @ID_Persona = 14, @ID_Formato = 2, @ID_Tipo = 5, 
    @Nombre = 'Torus Energético 3D', @Descripcion = 'Modelo 3D de toroide con energía giratoria.', 
    @Tamaño = 80.00, @Ancho = 85.00, @Alto = 85.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 15, @ID_Formato = 3, @ID_Tipo = 1, 
    @Nombre = 'Fuego Líquido #33', @Descripcion = 'Animación de fuego líquido en tonos metálicos.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 70.00, @Precio = 12.00;

EXEC usp_CrearNFT 
    @ID_Persona = 18, @ID_Formato = 1, @ID_Tipo = 3, 
    @Nombre = 'Ondas del Cosmos', @Descripcion = 'Generativo de ondas gravitacionales en espacio profundo.', 
    @Tamaño = 90.00, @Ancho = 100.00, @Alto = 100.00, @Precio = 1.5;

EXEC usp_CrearNFT 
    @ID_Persona = 19, @ID_Formato = 2, @ID_Tipo = 4, 
    @Nombre = 'Pixel Castle #02', @Descripcion = 'Castillo medieval en estilo 16-bit con banderas ondeando.', 
    @Tamaño = 24.00, @Ancho = 64.00, @Alto = 64.00, @Precio = 4.50;

EXEC usp_CrearNFT 
    @ID_Persona = 20, @ID_Formato = 3, @ID_Tipo = 2, 
    @Nombre = 'Luna Llena Nocturna', @Descripcion = 'Fotografía de luna llena sobre paisaje nevado.', 
    @Tamaño = 52.00, @Ancho = 100.00, @Alto = 66.00, @Precio = 2;

EXEC usp_CrearNFT 
    @ID_Persona = 1, @ID_Formato = 1, @ID_Tipo = 5, 
    @Nombre = 'Esfera de Cristal 3D', @Descripcion = 'Modelo 3D de esfera con refracción y reflejos.', 
    @Tamaño = 80.00, @Ancho = 80.00, @Alto = 80.00, @Precio = 11.80;

EXEC usp_CrearNFT 
    @ID_Persona = 4, @ID_Formato = 1, @ID_Tipo = 1, 
    @Nombre = 'Aurora Digital #01', @Descripcion = 'Representación abstracta de aurora boreal en píxeles.', 
    @Tamaño = 78.00, @Ancho = 100.00, @Alto = 70.00, @Precio = 1.5;

EXEC usp_CrearNFT 
    @ID_Persona = 6, @ID_Formato = 2, @ID_Tipo = 3, 
    @Nombre = 'Evolución Binaria #09', @Descripcion = 'Generativo que simula evolución de formas a partir de código binario.', 
    @Tamaño = 90.00, @Ancho = 95.00, @Alto = 95.00, @Precio = 9.90;

EXEC usp_CrearNFT 
    @ID_Persona = 9, @ID_Formato = 3, @ID_Tipo = 4, 
    @Nombre = 'Retro Hero #01', @Descripcion = 'Héroe de videojuego en 8-bit con capa y espada animada.', 
    @Tamaño = 19.00, @Ancho = 48.00, @Alto = 64.00, @Precio = 2.5;

EXEC usp_CrearNFT 
    @ID_Persona = 10, @ID_Formato = 1, @ID_Tipo = 2, 
    @Nombre = 'Valle de las Sombras', @Descripcion = 'Fotografía de valle montañoso con sombras largas al atardecer.', 
    @Tamaño = 62.00, @Ancho = 100.00, @Alto = 66.00, @Precio = 6.80;

EXEC usp_CrearNFT 
    @ID_Persona = 14, @ID_Formato = 3, @ID_Tipo = 5, 
    @Nombre = 'Esfera de Realidades 3D', @Descripcion = 'Modelo 3D de esfera que contiene múltiples realidades internas.', 
    @Tamaño = 90.00, @Ancho = 90.00, @Alto = 90.00, @Precio = 2.5;

EXEC usp_CrearNFT 
    @ID_Persona = 15, @ID_Formato = 3, @ID_Tipo = 1,
    @Nombre = 'Éter Infinito #∞',
    @Descripcion = 'Obra maestra generativa que representa el flujo eterno del éter digital: un vórtice de luz, color y tiempo que nunca se detiene. Pieza única en la colección.',
    @Tamaño = 99.99, @Ancho = 100.00, @Alto = 100.00, @Precio = 25.00;
GO

Select  *
from Revision

-- Aprobar y rechazar algunos NFT's para pruebas de views y reportes

    -- Aprobamos 8
EXEC usp_AprobarNFT @ID_Revision = 1, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 2, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 3, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 4, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 5, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 6, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 7, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 8, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 9, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 10, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 11, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 12, @Comentario = 'Aprobado para prueba de view';

Select *
from Revision
    
    -- Rechazamos 2
EXEC usp_RechazarNFT @ID_Revision = 9, @Comentario = 'Rechazado para prueba de view';
EXEC usp_RechazarNFT @ID_Revision = 10, @Comentario = 'Rechazado para prueba de view';

-- Insertar pujas en subastas para pruebas de reportes
-- 3, 7, 11, 12 ,13, 16, 17
	
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 7, @Monto = 10.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 11, @Monto = 15.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 16, @Monto = 20.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 13, @Monto = 25.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 3, @Monto = 15.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 12, @Monto = 23.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 3, @Monto = 38.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 12, @Monto = 49.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 11, @Monto = 15.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 16, @Monto = 23.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 17, @Monto = 38.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 13, @Monto = 49.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 17, @Monto = 50.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 16, @Monto = 150.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 7, @Monto = 178.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 3, @Monto = 200.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 12, @Monto = 60.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 3, @Monto = 78.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 17, @Monto = 130.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 11, @Monto = 187.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 7, @Monto = 60.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 16, @Monto = 79.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 17, @Monto = 100.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 12, @Monto = 150.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 11, @Monto = 84.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 16, @Monto = 169.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 11, @Monto = 200.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 16, @Monto = 266.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 3, @Monto = 30.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 11, @Monto = 53.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 3, @Monto = 98.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 12, @Monto = 129.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 11, @Monto = 15.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 16, @Monto = 23.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 17, @Monto = 38.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 13, @Monto = 49.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 17, @Monto = 65.00;

EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 11, @Monto = 15.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 16, @Monto = 23.50;
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 17, @Monto = 38.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 13, @Monto = 49.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 16, @Monto = 80.50;



SELECT * FROM EficienciaCuradores;

SELECT * FROM ActividadColeccionistas;

SELECT * FROM ValorizacionArtistas;

SELECT * FROM SubastaXPeriodo;


select *
from Billetera
Where ID_Persona = 3
print 53-26