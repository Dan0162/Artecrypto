PRINT '========== EJEMPLO 1: CREAR NFT ==========';
GO

DECLARE @NFT_ID INT;

IF OBJECT_ID('tempdb..#tmpNft') IS NULL
    CREATE TABLE #tmpNft (ID_NFT_Creado INT);
INSERT INTO #tmpNft (ID_NFT_Creado)
EXEC usp_CrearNFT 
    @ID_Persona = 1,
    @ID_Formato = 2,
    @ID_Tipo = 1,
    @Nombre = 'CyberDreams 2025',
    @Descripcion = 'Paisaje futurista con influencias cyberpunk inspirado en Blade Runner',
    @Tamaño = 45.5,
    @Ancho = 80.0,
    @Alto = 60.0,
    @Precio = 2.5;

SELECT TOP 1 @NFT_ID = ID_NFT_Creado FROM #tmpNft;

PRINT 'NFT Creado con ID: ' + CAST(@NFT_ID AS VARCHAR);
GO

PRINT '========== EJEMPLO 2: VER REVISIONES PENDIENTES ==========';
GO

SELECT * FROM vw_RevisionesPendientes;
GO

SELECT * FROM vw_RevisionesPendientes WHERE ID_Curador = 1;
GO

PRINT '========== EJEMPLO 3: INICIAR REVISION ==========';
GO

EXEC usp_IniciarRevision 
    @ID_Revision = 1,
    @ID_Curador = 1;
GO

SELECT 
    r.ID_Revision,
    n.Nombre AS NFT,
    e.Nombre AS Estado,
    r.Fecha_Asignacion,
    r.Fecha_Inicio,
    DATEDIFF(MINUTE, r.Fecha_Inicio, GETDATE()) AS Minutos_En_Revision
FROM Revision r
INNER JOIN NFT n ON r.ID_NFT = n.ID_NFT
INNER JOIN Estado_NFT e ON r.ID_EstadoNFT = e.ID_EstadoNFT
WHERE r.ID_Revision = 1;
GO

PRINT '========== EJEMPLO 4: APROBAR NFT ==========';
GO

EXEC usp_AprobarNFT 
    @ID_Revision = 1,
    @ID_Curador = 1,
    @Comentario = 'Excelente calidad técnica y originalidad. La composición es impecable.';
GO

SELECT TOP 1
    s.ID_Subasta,
    s.Nombre,
    s.Fecha_Inicio,
    s.Fecha_Final,
    DATEDIFF(HOUR, GETDATE(), s.Fecha_Final) AS Horas_Restantes,
    es.Nombre AS Estado
FROM Subasta s
INNER JOIN Estado_Subasta es ON s.ID_EstadoSubasta = es.ID_EstadoSubasta
ORDER BY s.ID_Subasta DESC;
GO

SELECT TOP 5 * FROM Correo_log ORDER BY ID_Correo DESC;
GO

PRINT '========== EJEMPLO 5: RECHAZAR NFT ==========';
GO

DECLARE @NFT_ID_2 INT;

IF OBJECT_ID('tempdb..#tmpNft') IS NULL
    CREATE TABLE #tmpNft (ID_NFT_Creado INT);
INSERT INTO #tmpNft (ID_NFT_Creado)
EXEC usp_CrearNFT 
    @ID_Persona = 2,
    @ID_Formato = 1,
    @ID_Tipo = 2,
    @Nombre = 'Urban Shadows',
    @Descripcion = 'Serie de fotografías urbanas en blanco y negro',
    @Tamaño = 55.0,
    @Ancho = 90.0,
    @Alto = 75.0,
    @Precio = 0;

SELECT TOP 1 @NFT_ID_2 = ID_NFT_Creado FROM #tmpNft;

DECLARE @ID_Revision_2 INT;
SELECT @ID_Revision_2 = ID_Revision 
FROM Revision 
WHERE ID_NFT = @NFT_ID_2;

EXEC usp_RechazarNFT 
    @ID_Revision = @ID_Revision_2,
    @ID_Curador = 4,
    @Comentario = 'La resolución de las imágenes es muy baja. Se requiere mínimo 2000x1500px para fotografía profesional.';
GO

SELECT 
    r.ID_Revision,
    n.Nombre AS NFT,
    p.Nombre AS Artista,
    e.Nombre AS Estado,
    r.Comentario,
    r.Fecha_Final
FROM Revision r
INNER JOIN NFT n ON r.ID_NFT = n.ID_NFT
INNER JOIN Persona p ON n.ID_Persona = p.ID_Persona
INNER JOIN Estado_NFT e ON r.ID_EstadoNFT = e.ID_EstadoNFT
WHERE r.ID_EstadoNFT = (SELECT ID_EstadoNFT FROM Estado_NFT WHERE Nombre = 'Rechazado');
GO

PRINT '========== EJEMPLO 6: ACTUALIZAR Y REENVIAR NFT ==========';
GO

EXEC usp_ActualizarNFT
    @ID_NFT = @NFT_ID_2,
    @ID_Persona = 2,
    @Tamaño = 75.0,
    @Ancho = 95.0,
    @Alto = 85.0,
    @Descripcion = 'Serie de fotografías urbanas en blanco y negro - Alta resolución';
GO

SELECT * FROM vw_RevisionesPendientes 
WHERE ID_NFT = @NFT_ID_2;
GO

PRINT '========== EJEMPLO 7: VER SUBASTAS ACTIVAS ==========';
GO

SELECT * FROM vw_SubastasActivas;
GO

PRINT '========== EJEMPLO 8: CREAR MULTIPLES NFTs ==========';
GO

DECLARE @i INT = 1;
DECLARE @NFT_Temp INT;

WHILE @i <= 5
BEGIN
    TRUNCATE TABLE #tmpNft;
    DECLARE @call_Persona INT, @call_Formato INT, @call_Tipo INT, @call_Tamano DECIMAL(10,2), @call_Ancho DECIMAL(10,2), @call_Alto DECIMAL(10,2), @call_Precio MONEY, @call_Nombre NVARCHAR(200), @call_Descripcion NVARCHAR(400);
    SET @call_Persona = CASE WHEN @i % 3 = 0 THEN 3 ELSE CASE WHEN @i % 2 = 0 THEN 5 ELSE 7 END END;
    SET @call_Formato = ((@i % 3) + 1);
    SET @call_Tipo = ((@i % 5) + 1);
    SET @call_Nombre = CONCAT('Test NFT ', @i);
    SET @call_Descripcion = CONCAT('Descripción de prueba para NFT número ', @i);
    SET @call_Tamano = 45.0;
    SET @call_Ancho = 80.0;
    SET @call_Alto = 60.0;
    SET @call_Precio = @i * 0.5;

    INSERT INTO #tmpNft (ID_NFT_Creado)
    EXEC usp_CrearNFT 
        @ID_Persona = @call_Persona,
        @ID_Formato = @call_Formato,
        @ID_Tipo = @call_Tipo,
        @Nombre = @call_Nombre,
        @Descripcion = @call_Descripcion,
        @Tamaño = @call_Tamano,
        @Ancho = @call_Ancho,
        @Alto = @call_Alto,
        @Precio = @call_Precio;

    SELECT TOP 1 @NFT_Temp = ID_NFT_Creado FROM #tmpNft;
    SET @i = @i + 1;
END
GO

SELECT 
    c.Nombre AS Curador,
    COUNT(r.ID_Revision) AS Total_Revisiones_Pendientes,
    AVG(DATEDIFF(HOUR, r.Fecha_Asignacion, GETDATE())) AS Promedio_Horas_Espera
FROM Persona c
INNER JOIN Entidad_Rol er ON c.ID_Persona = er.ID_Persona
INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad
LEFT JOIN Revision r ON c.ID_Persona = r.ID_Persona 
    AND r.ID_EstadoNFT = (SELECT ID_EstadoNFT FROM Estado_NFT WHERE Nombre = 'Pendiente')
WHERE te.Nombre = 'Curador'
GROUP BY c.Nombre
ORDER BY Total_Revisiones_Pendientes DESC;
GO

PRINT '========== EJEMPLO 9: REPORTES BÁSICOS ==========';
GO

SELECT 
    e.Nombre AS Estado,
    COUNT(*) AS Total_NFTs
FROM Revision r
INNER JOIN Estado_NFT e ON r.ID_EstadoNFT = e.ID_EstadoNFT
GROUP BY e.Nombre;
GO

SELECT 
    p.Nombre AS Artista,
    COUNT(n.ID_NFT) AS Total_NFTs_Creados,
    AVG(n.Precio) AS Precio_Promedio,
    SUM(CASE WHEN r.ID_EstadoNFT = (SELECT ID_EstadoNFT FROM Estado_NFT WHERE Nombre = 'Aprobado') 
        THEN 1 ELSE 0 END) AS NFTs_Aprobados
FROM Persona p
INNER JOIN Entidad_Rol er ON p.ID_Persona = er.ID_Persona
INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad
LEFT JOIN NFT n ON p.ID_Persona = n.ID_Persona
LEFT JOIN Revision r ON n.ID_NFT = r.ID_NFT
WHERE te.Nombre = 'Artista'
GROUP BY p.Nombre
ORDER BY Total_NFTs_Creados DESC;
GO

SELECT 
    c.Nombre AS Curador,
    COUNT(r.ID_Revision) AS Total_Revisiones_Completadas,
    AVG(DATEDIFF(HOUR, r.Fecha_Asignacion, r.Fecha_Final)) AS Promedio_Horas_Revision,
    SUM(CASE WHEN r.ID_EstadoNFT = (SELECT ID_EstadoNFT FROM Estado_NFT WHERE Nombre = 'Aprobado') 
        THEN 1 ELSE 0 END) AS Aprobados,
    SUM(CASE WHEN r.ID_EstadoNFT = (SELECT ID_EstadoNFT FROM Estado_NFT WHERE Nombre = 'Rechazado') 
        THEN 1 ELSE 0 END) AS Rechazados,
    CAST(SUM(CASE WHEN r.ID_EstadoNFT = (SELECT ID_EstadoNFT FROM Estado_NFT WHERE Nombre = 'Rechazado') 
        THEN 1.0 ELSE 0 END) / COUNT(r.ID_Revision) * 100 AS DECIMAL(5,2)) AS Tasa_Rechazo_Pct
FROM Persona c
INNER JOIN Entidad_Rol er ON c.ID_Persona = er.ID_Persona
INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad
LEFT JOIN Revision r ON c.ID_Persona = r.ID_Persona AND r.Fecha_Final IS NOT NULL
WHERE te.Nombre = 'Curador'
GROUP BY c.Nombre
ORDER BY Total_Revisiones_Completadas DESC;
GO

PRINT '========== EJEMPLO 10: PUJAR EN SUBASTA - ESCENARIOS ==========';
GO

-- Caso exitoso: persona con saldo suficiente realiza una oferta
PRINT 'Ejemplo 10A: Oferta exitosa (saldo suficiente)';
BEGIN TRY
    EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 3, @Monto = 2.00;
END TRY
BEGIN CATCH
    PRINT 'Error en puja: ' + ERROR_MESSAGE();
END CATCH
GO

-- Caso fallo: saldo insuficiente
PRINT 'Ejemplo 10B: Oferta fallida por saldo insuficiente';
BEGIN TRY
    EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 8, @Monto = 100.00;
END TRY
BEGIN CATCH
    PRINT 'Error en puja: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '========== EJEMPLO 10: VALIDACIONES Y ERRORES ==========';
PRINT '========== EXAMPLE 1: CREATE NFT ==========';

BEGIN TRY
    EXEC usp_CrearNFT 
PRINT '========== EXAMPLE 2: VIEW PENDING REVIEWS ==========';
        @ID_Formato = 1,
        @ID_Tipo = 1,
        @Nombre = 'NFT con error',
PRINT '========== EXAMPLE 3: START REVIEW ==========';
        @Tamaño = 600.0,
        @Ancho = 80.0,
        @Alto = 60.0,
PRINT '========== EXAMPLE 4: APPROVE NFT ==========';
END TRY
BEGIN CATCH
    PRINT 'Error capturado correctamente: ' + ERROR_MESSAGE();
PRINT '========== EXAMPLE 5: REJECT NFT ==========';
GO

BEGIN TRY
PRINT '========== EXAMPLE 6: UPDATE AND RESUBMIT NFT ==========';
        @ID_Persona = 1,
        @ID_Formato = 1,
        @ID_Tipo = 1,
PRINT '========== EXAMPLE 7: VIEW ACTIVE AUCTIONS ==========';
        @Descripcion = 'Este también debería fallar',
        @Tamaño = 45.0,
        @Ancho = 5.0,
PRINT '========== EXAMPLE 8: CREATE MULTIPLE NFTs ==========';
        @Precio = 1.0;
END TRY
BEGIN CATCH
PRINT '========== EXAMPLE 9: BASIC REPORTS ==========';
END CATCH
GO

PRINT '========== EXAMPLE 10: BID IN AUCTION - SCENARIOS ==========';
    EXEC usp_RechazarNFT 
        @ID_Revision = 1,
        @ID_Curador = 1,
PRINT 'Example 10A: Successful bid (sufficient balance)';
END TRY
BEGIN CATCH
    PRINT 'Error capturado correctamente: ' + ERROR_MESSAGE();
PRINT 'Example 10B: Failed bid due to insufficient balance';
GO

BEGIN TRY
PRINT '========== EXAMPLE 10: VALIDATIONS AND ERRORS ==========';
        @ID_NFT = 1,
        @ID_Persona = 99,
        @Nombre = 'Intento de hackeo';
PRINT 'Error correctly captured: ' + ERROR_MESSAGE();
BEGIN CATCH
    PRINT 'Error capturado correctamente: ' + ERROR_MESSAGE();
END CATCH
PRINT '========== EXAMPLES COMPLETED ==========';

PRINT 'System ready for use';
    DROP TABLE #tmpNft;

PRINT '========== EJEMPLOS COMPLETADOS ==========';
PRINT 'Sistema listo para uso';
GO