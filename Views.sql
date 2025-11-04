-- ============================================================================
-- ARTECRYPTO - VIEWS
-- ============================================================================

-- ============================================================================
-- VIEW 1: MEDIR  EFICIENCIA DE LOS CURADORES 
-- ============================================================================
CREATE OR ALTER VIEW EficienciaCuradores
AS
SELECT 
    p.Nombre AS [Nombre], 
    COUNT(*) AS [NFTs Revisados],

    -- Tiempo promedio de revisión en horas (de minutos a horas)
    FORMAT(
        AVG(DATEDIFF(MINUTE, r.Fecha_Inicio, r.Fecha_Final)/ 60.0), 
        'N2'
    ) AS [Tiempo promedio de revisión (horas)],
    
     -- Conteo de NFTs aprobados y rechazados
    COUNT(CASE WHEN e.Nombre = 'Aprobado' THEN 1 END) AS [Aprobados],
    COUNT(CASE WHEN e.Nombre = 'Rechazado' THEN 1 END) AS [Rechazados],
    
    -- Tasa de rechazo en porcentaje
    FORMAT(
        COUNT(CASE WHEN e.Nombre = 'Rechazado' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 
        'N2'
    ) + ' %' AS [Tasa de rechazo]
FROM Revision r
INNER JOIN Persona p ON r.ID_Persona = p.ID_Persona
INNER JOIN Estado_NFT e ON r.ID_EstadoNFT = e.ID_EstadoNFT
INNER JOIN Entidad_Rol er ON r.ID_Persona = er.ID_Persona
INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad
WHERE te.Nombre = 'Curador' 
  AND r.Fecha_Final IS NOT NULL -- Solo revisiones completadas
GROUP BY p.ID_Persona, p.Nombre;
GO

-- ============================================================================
-- VIEW 2: ACTIVIDAD DE LOS COLECCIONISTAS
-- ============================================================================
CREATE OR ALTER VIEW ActividadColeccionistas
AS
WITH EstadoGanadora AS (
    -- Identifica el ID correspondiente al estado 'Ganadora'
    SELECT ID_EstadoPuja AS ID_Ganadora 
    FROM Estado_Puja 
    WHERE Nombre = N'Ganadora'
),
PujasXColeccionista AS (
   -- Métricas agregadas por coleccionista
    SELECT 
        pu.ID_Persona,
        COUNT(*) AS TotalOfertas,
        COUNT(DISTINCT pu.ID_Subasta) AS SubastasParticipadas,
        SUM(CASE WHEN pu.Estado = eg.ID_Ganadora THEN pu.Monto ELSE 0 END) AS MontoInvertido,
        COUNT(CASE WHEN pu.Estado = eg.ID_Ganadora THEN 1 END) AS SubastasGanadas
    FROM Puja pu
    CROSS JOIN EstadoGanadora eg
    INNER JOIN Persona pe ON pu.ID_Persona = pe.ID_Persona
    INNER JOIN Entidad_Rol er ON pe.ID_Persona = er.ID_Persona
    INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad 
        AND te.Nombre = N'Coleccionista'
    GROUP BY pu.ID_Persona
),
RegistroColeccionista AS (
    -- Fecha de registro del coleccionista más temprana
    SELECT 
        er.ID_Persona,
        MIN(er.Fecha_Registro) AS FechaRegistro
    FROM Entidad_Rol er
    INNER JOIN Tipo_Entidad te ON er.ID_TipoEntidad = te.ID_TipoEntidad 
        AND te.Nombre = N'Coleccionista'
    GROUP BY er.ID_Persona
)
SELECT 
    pe.Nombre,
    pe.Correo,
    rc.FechaRegistro AS [Fecha registro],
    pc.TotalOfertas AS [Total de ofertas realizadas],
    pc.SubastasGanadas AS [Subastas ganadas],
    pc.MontoInvertido AS [Monto total invertido],
    -- ✅ Modificación: Tasa de éxito basada en subastas participadas
    FORMAT((pc.SubastasGanadas * 100.0 / NULLIF(pc.SubastasParticipadas, 0)), 'N2') AS [Tasa de éxito (%)],
    FORMAT(CAST(pc.TotalOfertas AS DECIMAL(10, 2)) / NULLIF(pc.SubastasParticipadas, 0), 'N2') AS [Promedio de ofertas por subasta]
FROM PujasXColeccionista pc
INNER JOIN Persona pe ON pc.ID_Persona = pe.ID_Persona
INNER JOIN RegistroColeccionista rc ON pc.ID_Persona = rc.ID_Persona;
GO


-- ============================================================================
-- VIEW 3: VALORACIÓN DE LOS ARTISTAS
-- ============================================================================
CREATE OR ALTER VIEW ValorizacionArtistas
AS

-- CTE 1: Obtener todas las ventas finalizadas (base de todo)
WITH Ventas AS (
    SELECT 
        p.Nombre AS Artista,
        n.Nombre AS NFT,
        s.Oferta_Ganadora AS Precio,
        rn.Fecha_Adquisicion AS Fecha
    FROM Registro_NFT rn
    INNER JOIN Subasta s ON rn.ID_Subasta = s.ID_Subasta
    INNER JOIN NFT n ON rn.ID_NFT = n.ID_NFT
    INNER JOIN Persona p ON n.ID_Persona = p.ID_Persona
    WHERE s.ID_EstadoSubasta = (SELECT ID_EstadoSubasta FROM Estado_Subasta WHERE Nombre = 'Finalizada') 
      AND s.Oferta_Ganadora > 0
),

-- CTE 2: Encontrar SOLO el precio de la PRIMERA venta de cada artista
PrimeraVenta AS (
    SELECT Artista, Precio AS PrecioPrimera
    FROM (
        SELECT 
            Artista, 
            Precio,
            -- Asigna el #1 a la venta más antigua
            ROW_NUMBER() OVER (PARTITION BY Artista ORDER BY Fecha ASC) AS rn
        FROM Ventas
    ) AS Subquery
    WHERE rn = 1 -- Filtra solo la primera venta
),

-- CTE 3: Encontrar SOLO el precio de la ÚLTIMA venta de cada artista
UltimaVenta AS (
    SELECT Artista, Precio AS PrecioUltima
    FROM (
        SELECT 
            Artista, 
            Precio,
            -- Asigna el #1 a la venta más nueva
            ROW_NUMBER() OVER (PARTITION BY Artista ORDER BY Fecha DESC) AS rn
        FROM Ventas
    ) AS Subquery
    WHERE rn = 1 -- Filtra solo la última venta
),

-- CTE 4: Calcular los datos para la correlación y la lista de NFTs
-- (Necesita todas las ventas de cada artista)
DatosAgregados AS (
    SELECT 
        Artista,
        -- Lista de todos los NFTs vendidos
        STRING_AGG(NFT, ' | ') WITHIN GROUP (ORDER BY Fecha ASC) AS [NFT analizado],
        
        -- Conteo total de ventas
        COUNT(*) AS [Número de ventas del artista],
        
        -- Lógica de Correlación (usa todas las filas)
        FORMAT(
            COALESCE(
                ROUND(
                    (COUNT(*) * SUM(Precio * Dia) - SUM(Precio) * SUM(Dia)) 
                    / NULLIF(SQRT( (COUNT(*) * SUM(Precio*Precio) - SUM(Precio)*SUM(Precio))
                                * (COUNT(*) * SUM(Dia*Dia)     - SUM(Dia)*SUM(Dia)) )
                    , 0)
                , 3)
            , 0)
        , 'N3') AS [Correlación precio-tiempo]
        
    FROM (
        -- Subquery para calcular los 'Días' desde la primera venta
        SELECT 
            *,
            DATEDIFF(DAY, MIN(Fecha) OVER (PARTITION BY Artista), Fecha) AS Dia
        FROM Ventas
    ) AS VentasConDia
    GROUP BY Artista
)

-- Query Final: Unir los 4 CTEs
SELECT 
    agg.Artista AS [Nombre],
    agg.[NFT analizado],
    FORMAT(ISNULL(pv.PrecioPrimera, 0), 'N2') AS [Precio de la primera venta],
    FORMAT(ISNULL(uv.PrecioUltima, 0), 'N2') AS [Precio de la última venta],
    
    -- El porcentaje se calcula al final, usando los valores ya obtenidos
    FORMAT(
        (uv.PrecioUltima - pv.PrecioPrimera) * 100.0 / NULLIF(pv.PrecioPrimera, 0),
        'N2'
    ) + ' %' AS [Porcentaje de revalorización],
    
    agg.[Correlación precio-tiempo],
    agg.[Número de ventas del artista]
FROM 
    DatosAgregados AS agg
LEFT JOIN 
    PrimeraVenta AS pv ON agg.Artista = pv.Artista
LEFT JOIN 
    UltimaVenta AS uv ON agg.Artista = uv.Artista;
GO

-- ============================================================================
-- VIEW 4: SUBASTA POR PERÍODO
-- ============================================================================
CREATE OR ALTER VIEW SubastaXPeriodo
AS
WITH ConteoPujas AS (
     -- Cantidad de pujas por subasta
    SELECT ID_Subasta, COUNT(*) AS NumPujas
    FROM Puja
    GROUP BY ID_Subasta
),
SubastasPeriodo AS (
    -- Información de subastas finalizadas con datos del artista y número de pujas
    SELECT 
        YEAR(s.Fecha_Inicio) AS Anio,
        MONTH(s.Fecha_Inicio) AS Mes,
        s.ID_Subasta,
        n.ID_Persona AS ID_Artista, -- Obtenido directamente de NFT
        s.Oferta_Ganadora,
        ISNULL(cp.NumPujas, 0) AS NumPujas
    FROM Subasta s
    INNER JOIN NFT n ON s.ID_NFT = n.ID_NFT
    
    -- (Se eliminaron los INNER JOINs innecesarios a Persona, Entidad_Rol y Tipo_Entidad)

    INNER JOIN Estado_Subasta es ON s.ID_EstadoSubasta = es.ID_EstadoSubasta 
        AND es.Nombre = N'Finalizada'
    LEFT JOIN ConteoPujas cp ON s.ID_Subasta = cp.ID_Subasta
)
SELECT 
    FORMAT(Anio, '0000') + '-' + FORMAT(Mes, '00') AS [Año y mes del período],
    COUNT(*) AS [Total de subastas realizadas],
    COUNT(DISTINCT ID_Artista) AS [Artistas únicos participantes],
    SUM(NumPujas) AS [Ofertas realizadas],
    SUM(ISNULL(Oferta_Ganadora, 0)) AS [Monto Total (ETH)],
    FORMAT (AVG(CAST(NumPujas AS DECIMAL(10, 2))), 'N2' ) AS [Promedio de ofertas],
    FORMAT (AVG(CAST(ISNULL(Oferta_Ganadora, 0) AS DECIMAL(10, 2))), 'N2') AS [Monto promedio],
    FORMAT ((SUM(CASE WHEN Oferta_Ganadora IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 'N2') AS [Tasa de éxito %]
FROM SubastasPeriodo
GROUP BY Anio, Mes;
GO