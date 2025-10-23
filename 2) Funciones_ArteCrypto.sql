-- ufn_GenerarHash: returns SHA2_256 hash of NFT content
CREATE OR ALTER FUNCTION ufn_GenerarHash(
    @ID_Formato INT, 
    @ID_Tipo INT,
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(MAX)
)
RETURNS VARCHAR(100)
AS 
BEGIN 
    DECLARE @ConcatData NVARCHAR(MAX);
    DECLARE @hash VARBINARY(32); -- SHA_256 genera 32 bytes (256 bits)

    SET @ConcatData = CONCAT(
		CAST(@ID_Formato as NVARCHAR(10)), '|',
		CAST(@ID_Tipo as NVARCHAR(10)), '|',
		@Nombre, '|',
		@Descripcion
	);
    
    SET @hash = HASHBYTES('SHA2_256', @ConcatData);
    RETURN CONVERT(VARCHAR(64), @hash, 2);
END;
GO
-- ufn_ObtenerPrecioDefault: returns active base price for a format
CREATE OR ALTER FUNCTION ufn_ObtenerPrecioDefault(
    @ID_Formato INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Precio MONEY;
    
    -- Find the most recent active base price for the format
    SELECT TOP 1 @Precio = Precio_Base
    FROM Precio_Default
    WHERE ID_Formato = @ID_Formato
        AND Activo = 1
        AND Fecha_Inicio_Vigencia <= GETDATE()
        AND (Fecha_Fin_Vigencia IS NULL OR Fecha_Fin_Vigencia >= GETDATE())
    ORDER BY Fecha_Inicio_Vigencia DESC;
    
    -- If no price is configured, return 1.5
    RETURN ISNULL(@Precio, 1.5); 
END;
GO
-- ufn_Validación: validates size and dimensions using the Error table
CREATE FUNCTION ufn_Validación(
    @Tamaño DECIMAL(10,2), 
    @Largo DECIMAL(10,2), 
    @Ancho DECIMAL(10,2)
)
RETURNS @Resultados TABLE (
    CodigoError INT,
    MensajeError NVARCHAR(200),
    EsValido BIT
)
AS
BEGIN
    DECLARE @TamañoMax DECIMAL(10,2);
    DECLARE @TamañoMin DECIMAL(10,2);
    DECLARE @LargoMax DECIMAL(10,2);
    DECLARE @LargoMin DECIMAL(10,2);
    DECLARE @AnchoMax DECIMAL(10,2);
    DECLARE @AnchoMin DECIMAL(10,2);

    -- Get validation values from the Error table
    SELECT @TamañoMax = Valor FROM Error WHERE Id_Error = 5;
    SELECT @TamañoMin = Valor FROM Error WHERE Id_Error = 6;
    SELECT @LargoMax = Valor FROM Error WHERE Id_Error = 2;
    SELECT @LargoMin = Valor FROM Error WHERE Id_Error = 4;
    SELECT @AnchoMax = Valor FROM Error WHERE Id_Error = 1;
    SELECT @AnchoMin = Valor FROM Error WHERE Id_Error = 3;

    -- Initialize as valid
    INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
    VALUES (1, 'Validación exitosa', 1);

    -- Validate size
    IF (@Tamaño > @TamañoMax)
    BEGIN
        INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
        VALUES (-1, 'Tamaño excede el máximo permitido (' + CAST(@TamañoMax AS VARCHAR) + ')', 0);
    END
    
    IF (@Tamaño < @TamañoMin)
    BEGIN
        INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
        VALUES (-2, 'Tamaño es menor al mínimo permitido (' + CAST(@TamañoMin AS VARCHAR) + ')', 0);
    END
    
    -- Validate length (height)
    IF (@Largo > @LargoMax)
    BEGIN
        INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
        VALUES (-3, 'Alto excede el máximo permitido (' + CAST(@LargoMax AS VARCHAR) + ')', 0);
    END
    
    IF (@Largo < @LargoMin)
    BEGIN
        INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
        VALUES (-4, 'Alto es menor al mínimo permitido (' + CAST(@LargoMin AS VARCHAR) + ')', 0);
    END
    
    -- Validate width
    IF (@Ancho > @AnchoMax)
    BEGIN
        INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
        VALUES (-5, 'Ancho excede el máximo permitido (' + CAST(@AnchoMax AS VARCHAR) + ')', 0);
    END
    
    IF (@Ancho < @AnchoMin)
    BEGIN
        INSERT INTO @Resultados (CodigoError, MensajeError, EsValido)
        VALUES (-6, 'Ancho es menor al mínimo permitido (' + CAST(@AnchoMin AS VARCHAR) + ')', 0);
    END

    -- If there are errors, remove the "validation successful" record
    IF EXISTS (SELECT 1 FROM @Resultados WHERE EsValido = 0)
    BEGIN
        DELETE FROM @Resultados WHERE EsValido = 1;
    END

    RETURN;
END;
GO
-- ufn_ObtenerPrecioActualSubasta: returns the highest bid or the initial price
CREATE OR ALTER FUNCTION ufn_ObtenerPrecioActualSubasta(
    @ID_Subasta INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @PrecioActual MONEY;
    
    -- Get the highest active bid
    SELECT TOP 1 @PrecioActual = Monto
    FROM Puja
    WHERE ID_Subasta = @ID_Subasta
        AND Estado IN (SELECT ID_EstadoPuja FROM Estado_Puja WHERE Nombre IN ('Activa', 'Ganadora'))
    ORDER BY Monto DESC, Fecha ASC; -- Mayor monto, primera en caso de empate
    
    -- If there are no bids, return the NFT's initial price
    IF @PrecioActual IS NULL
    BEGIN
        SELECT @PrecioActual = n.Precio
        FROM Subasta s
        INNER JOIN NFT n ON s.ID_NFT = n.ID_NFT
        WHERE s.ID_Subasta = @ID_Subasta;
    END
    
    RETURN ISNULL(@PrecioActual, 0);
END;
GO

-- ufn_CalcularOfertaMinima: calculates 5% over the current price
CREATE OR ALTER FUNCTION ufn_CalcularOfertaMinima(
    @ID_Subasta INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @PrecioActual MONEY;
    DECLARE @OfertaMinima MONEY;
    
    -- Get current price
    SET @PrecioActual = dbo.ufn_ObtenerPrecioActualSubasta(@ID_Subasta);
    
    -- Calculate the additional 5%
    SET @OfertaMinima = @PrecioActual * 1.05;
    
    RETURN @OfertaMinima;
END;
GO