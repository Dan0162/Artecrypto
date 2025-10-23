-- trg_NFT_AfterInsert_AsignarRevision: assigns reviews after inserting NFT
CREATE OR ALTER TRIGGER trg_NFT_AfterInsert_AsignarRevision
ON NFT 
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @CuradorAsignado INT;
    DECLARE @EstadoPendienteID INT;

        -- Get ID for the 'Pending' state
    SELECT @EstadoPendienteID = ID_EstadoNFT 
    FROM Estado_NFT 
    WHERE Nombre = 'Pendiente';

        -- Find the curator with the fewest assigned pending reviews
    SELECT TOP 1 @CuradorAsignado = p.ID_Persona
    FROM Persona p
    INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
    INNER JOIN Tipo_Entidad te ON te.ID_TipoEntidad = er.ID_TipoEntidad
    LEFT JOIN Revision r ON p.ID_Persona = r.ID_Persona 
                       AND r.ID_EstadoNFT = @EstadoPendienteID
    WHERE te.Nombre = 'Curador'
    GROUP BY p.ID_Persona
    ORDER BY COUNT(r.ID_Revision) ASC;

        -- If no curator is found, take the first available
    IF @CuradorAsignado IS NULL
    BEGIN
        SELECT TOP 1 @CuradorAsignado = p.ID_Persona
        FROM Persona p
        INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
        INNER JOIN Tipo_Entidad te ON te.ID_TipoEntidad = er.ID_TipoEntidad
        WHERE te.Nombre = 'Curador'
        ORDER BY p.ID_Persona;
    END

        -- Insert into the Revision table for each inserted NFT
    INSERT INTO Revision (ID_Persona, ID_NFT, ID_EstadoNFT, Fecha_Inicio, Fecha_Final, Comentario)
    SELECT 
        @CuradorAsignado,
        i.ID_NFT,
        @EstadoPendienteID,
        GETDATE(),    -- Fecha_Inicio set at assignment
        NULL,         
        NULL
    FROM inserted i;
END;
GO