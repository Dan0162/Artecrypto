CREATE OR ALTER TRIGGER trg_Revision_Aprobada_IniciarSubasta
ON Revision
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si se aprobó ALGUNA revisión
    IF NOT EXISTS (
        SELECT 1
        FROM INSERTED i
        INNER JOIN Estado_NFT e ON i.ID_EstadoNFT = e.ID_EstadoNFT
        WHERE e.Nombre = 'Aprobado'
    )
    BEGIN
        RETURN;
    END

    DECLARE @ID_NFT INT;
    DECLARE @NombreNFT NVARCHAR(100);
    DECLARE @PrecioNFT MONEY;
    DECLARE @ID_Formato INT;
    DECLARE @PrecioDefault MONEY;
    DECLARE @PrecioInicial MONEY;
    DECLARE @EstadoActivaID INT;
    DECLARE @ID_Coleccionista INT;
    DECLARE @Mensaje NVARCHAR(200);

    -- Obtener ID del estado 'Activa'
    SELECT @EstadoActivaID = ID_EstadoSubasta
    FROM Estado_Subasta
    WHERE Nombre = 'Activa';

    IF @EstadoActivaID IS NULL
    BEGIN
        RAISERROR('No se encontró el estado "Activa" en la tabla Estado_Subasta', 16, 1);
        RETURN;
    END

    -- Obtener NFT aprobado con sus datos de precio y formato
    SELECT TOP 1 
        @ID_NFT = i.ID_NFT,
        @NombreNFT = n.Nombre,
        @PrecioNFT = n.Precio,
        @ID_Formato = n.ID_Formato
    FROM INSERTED i
    INNER JOIN NFT n ON i.ID_NFT = n.ID_NFT
    INNER JOIN Estado_NFT e ON i.ID_EstadoNFT = e.ID_EstadoNFT
    WHERE e.Nombre = 'Aprobado'
      AND NOT EXISTS (
          SELECT 1 
          FROM Subasta s 
          WHERE s.ID_NFT = i.ID_NFT 
          AND s.ID_EstadoSubasta = @EstadoActivaID
      );

    -- Si no hay NFT válido, retornar error
    IF @ID_NFT IS NULL
    BEGIN
        RAISERROR('No se pudo encontrar un NFT aprobado válido para crear la subasta. Puede que ya exista una subasta activa para este NFT.', 16, 1);
        RETURN;
    END

    -- Obtener precio default del formato
    SET @PrecioDefault = dbo.ufn_ObtenerPrecioDefault(@ID_Formato);

    -- Determinar precio inicial: usar el mayor entre precio del NFT y precio default
    IF @PrecioNFT >= @PrecioDefault
        SET @PrecioInicial = @PrecioNFT;
    ELSE
        SET @PrecioInicial = @PrecioDefault;

    -- Crear subasta con el precio inicial determinado
    INSERT INTO Subasta (
        ID_EstadoSubasta, 
        ID_NFT, 
        Nombre,
        Precio_Inicial,  -- Nueva columna agregada
        Fecha_Inicio, 
        Fecha_Final, 
        Oferta_Ganadora
    )
    VALUES (
        @EstadoActivaID,
        @ID_NFT,
        CONCAT('Subasta - ', @NombreNFT),
        @PrecioInicial,  -- Usar el precio calculado
        GETDATE(),
        DATEADD(SECOND, 180, GETDATE()),
        NULL
    );

    -- Notificar coleccionistas CON CURSOR
    SET @Mensaje = CONCAT('Nueva subasta disponible: "', @NombreNFT, '" - Precio inicial: ', @PrecioInicial, ' ETH');
    
    DECLARE cur_Coleccionistas CURSOR FOR
        SELECT p.ID_Persona
        FROM Persona p
        INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
        INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad
        WHERE te.Nombre = 'Coleccionista';

    OPEN cur_Coleccionistas;
    FETCH NEXT FROM cur_Coleccionistas INTO @ID_Coleccionista;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (@ID_Coleccionista, @Mensaje);

        FETCH NEXT FROM cur_Coleccionistas INTO @ID_Coleccionista;
    END

    CLOSE cur_Coleccionistas;
    DEALLOCATE cur_Coleccionistas;

END
GO