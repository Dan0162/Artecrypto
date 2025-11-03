-- trg_NFT_AfterInsert_AsignarRevision: asigna revisiones tras insertar NFT
CREATE OR ALTER TRIGGER trg_NFT_AfterInsert_AsignarRevision
ON NFT 
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @CuradorAsignado INT;
    DECLARE @EstadoPendienteID INT;

    -- Obtener ID del estado 'Pendiente'
    SELECT @EstadoPendienteID = ID_EstadoNFT 
    FROM Estado_NFT 
    WHERE Nombre = 'Pendiente';

    -- Busca al curador con menos revisiones pendientes asignadas
    SELECT TOP 1 @CuradorAsignado = p.ID_Persona
    FROM Persona p
    INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
    INNER JOIN Tipo_Entidad te ON te.ID_TipoEntidad = er.ID_TipoEntidad
    LEFT JOIN Revision r ON p.ID_Persona = r.ID_Persona 
                       AND r.ID_EstadoNFT = @EstadoPendienteID
    WHERE te.Nombre = 'Curador'
    GROUP BY p.ID_Persona
    ORDER BY COUNT(r.ID_Revision) ASC;

    -- Por si no se encuentra un curador, tomar el primero disponible
    IF @CuradorAsignado IS NULL
    BEGIN
        SELECT TOP 1 @CuradorAsignado = p.ID_Persona
        FROM Persona p
        INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
        INNER JOIN Tipo_Entidad te ON te.ID_TipoEntidad = er.ID_TipoEntidad
        WHERE te.Nombre = 'Curador'
        ORDER BY p.ID_Persona;
    END

    -- Realiza el Insert en la Tabla Revision para cada NFT insertado
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