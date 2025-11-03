-- trg_NFT_AfterUpdate_ReasignarRevision: crea nueva revisión si NFT actualizado tras rechazo
CREATE OR ALTER TRIGGER trg_NFT_AfterUpdate_ReasignarRevision
ON NFT 
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    -- Solo procesa NFTs que fueron rechazados y ahora se actualizan
    -- Y que no tengan ya una revisión pendiente
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN Revision r ON i.ID_NFT = r.ID_NFT
        INNER JOIN Estado_NFT e ON r.ID_EstadoNFT = e.ID_EstadoNFT
        WHERE e.Nombre = 'Rechazado'
        AND NOT EXISTS (
            SELECT 1 
            FROM Revision r2 
            INNER JOIN Estado_NFT e2 ON r2.ID_EstadoNFT = e2.ID_EstadoNFT
            WHERE r2.ID_NFT = i.ID_NFT 
            AND e2.Nombre = 'Pendiente'
        )
    )
    BEGIN
        DECLARE @CuradorAsignado INT;
        DECLARE @EstadoPendienteID INT;

        SELECT @EstadoPendienteID = ID_EstadoNFT 
        FROM Estado_NFT 
        WHERE Nombre = 'Pendiente';

        -- Busca al curador con menos carga de trabajo
        SELECT TOP 1 @CuradorAsignado = p.ID_Persona
        FROM Persona p
        INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
        INNER JOIN Tipo_Entidad te ON te.ID_TipoEntidad = er.ID_TipoEntidad
        LEFT JOIN Revision r ON p.ID_Persona = r.ID_Persona 
                           AND r.ID_EstadoNFT = @EstadoPendienteID
        WHERE te.Nombre = 'Curador'
        GROUP BY p.ID_Persona
        ORDER BY COUNT(r.ID_Revision) ASC;

        -- Por si no se encuentra a un curador, asigna el primero de la lista
        IF @CuradorAsignado IS NULL
        BEGIN
            SELECT TOP 1 @CuradorAsignado = p.ID_Persona
            FROM Persona p
            INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
            INNER JOIN Tipo_Entidad te ON te.ID_TipoEntidad = er.ID_TipoEntidad
            WHERE te.Nombre = 'Curador'
            ORDER BY p.ID_Persona;
        END

        -- Si el NFT fue rechazado y actualizado, crear nueva revision
        INSERT INTO Revision (ID_Persona, ID_NFT, ID_EstadoNFT, Fecha_Inicio, Fecha_Final, Comentario)
        SELECT 
            @CuradorAsignado,
            i.ID_NFT,
            @EstadoPendienteID,
            GETDATE(),    -- Fecha_Inicio set at reassignment
            NULL,         
            'Re-enviado para revisión después de correcciones'
        FROM inserted i
        INNER JOIN Revision r ON i.ID_NFT = r.ID_NFT
        INNER JOIN Estado_NFT e ON r.ID_EstadoNFT = e.ID_EstadoNFT
        WHERE e.Nombre = 'Rechazado'
        AND NOT EXISTS (
            SELECT 1 
            FROM Revision r2 
            INNER JOIN Estado_NFT e2 ON r2.ID_EstadoNFT = e2.ID_EstadoNFT
            WHERE r2.ID_NFT = i.ID_NFT 
            AND e2.Nombre = 'Pendiente'
        );
    END
END;
GO