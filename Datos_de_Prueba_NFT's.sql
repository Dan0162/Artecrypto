-- NFT 1 Correct: Within all limits
EXEC usp_CrearNFT 
    @ID_Persona = 1,
    @ID_Formato = 1,      -- JPEG
    @ID_Tipo = 1,         -- Digital Art
    @Nombre = 'Amanecer Digital',
    @Descripcion = 'Representación abstracta de un amanecer en colores vibrantes',
    @Tamaño = 50.00,      -- MB (entre 10 y 500)
    @Ancho = 100.00,      -- px (entre 10 y 10000)
    @Alto = 90.00,       -- px (entre 10 y 10000)
    @Precio = 5.00;

-- NFT 2 Correct: At minimum limits
EXEC usp_CrearNFT 
    @ID_Persona = 2,
    @ID_Formato = 2,      -- PNG
    @ID_Tipo = 2,         -- Photography
    @Nombre = 'Minimalismo Urbano',
    @Descripcion = 'Fotografía minimalista de arquitectura urbana',
    @Tamaño = 10.00,      -- MB (mínimo)
    @Ancho = 10.00,       -- px (mínimo)
    @Alto = 10.00,        -- px (mínimo)
    @Precio = 3.50;

-- NFT 3 Correct: At maximum limits
EXEC usp_CrearNFT 
    @ID_Persona = 3,
    @ID_Formato = 3,      -- GIF
    @ID_Tipo = 3,         -- Generative
    @Nombre = 'Universo Infinito',
    @Descripcion = 'Animación generativa de un universo en expansión',
    @Tamaño = 500.00,     -- MB (máximo)
    @Ancho = 70.00,    -- px (máximo)
    @Alto = 80.00,     -- px (máximo)
    @Precio = 0;          -- Usará precio default del formato GIF (2.50)



-- NFT 1 Incorrect: Multiple errors - size too large, dimensions too small
EXEC usp_CrearNFT 
    @ID_Persona = 1,
    @ID_Formato = 1,
    @ID_Tipo = 1,
    @Nombre = 'Coloso Digital',
    @Descripcion = 'Obra monumental que excede límites',
    @Tamaño = 600.00,     -- ERROR: Mayor a 500MB (máximo)
    @Ancho = 5.00,        -- ERROR: Menor a 10px (mínimo)
    @Alto = 5.00,         -- ERROR: Menor a 10px (mínimo)
    @Precio = 8.00;

-- NFT 2 Incorrect: Extreme dimensions in both directions
EXEC usp_CrearNFT 
    @ID_Persona = 2,
    @ID_Formato = 2,
    @ID_Tipo = 2,
    @Nombre = 'Gigante Diminuto',
    @Descripcion = 'Contraste extremo en dimensiones',
    @Tamaño = 5.00,       -- ERROR: Menor a 10MB (mínimo)
    @Ancho = 15000.00,    -- ERROR: Mayor a 10000px (máximo)
    @Alto = 15000.00,     -- ERROR: Mayor a 10000px (máximo)
    @Precio = -10.00;     -- ERROR: Precio negativo

-- NFT 3 Incorrect: All parameters out of bounds
EXEC usp_CrearNFT 
    @ID_Persona = 3,
    @ID_Formato = 999,    -- ERROR: Formato no existe
    @ID_Tipo = 999,       -- ERROR: Tipo no existe
    @Nombre = '',         -- ERROR: Nombre vacío
    @Descripcion = 'NFT con todos los errores posibles',
    @Tamaño = 0.50,       -- ERROR: Menor a 10MB (mínimo)
    @Ancho = 20000.00,    -- ERROR: Mayor a 10000px (máximo)
    @Alto = 20000.00,     -- ERROR: Mayor a 10000px (máximo)
    @Precio = -5.00;      -- ERROR: Precio negativo