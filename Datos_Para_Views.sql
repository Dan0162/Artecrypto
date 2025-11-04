
--===================================================
--Crear y dar saldo a la billeteras
--===================================================

--A los coleccionistas
INSERT INTO Billetera (ID_Persona, Saldo_Disponible, Saldo_Reservado)
SELECT
    er.ID_Persona,
    300000000.00, -- Saldo inicial
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


-- Aprobar más NFTs para llegar a 20 aprobados totales
EXEC usp_AprobarNFT @ID_Revision = 1, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 2, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 3, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 4, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 5, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 6, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 7, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 8, @Comentario = 'Aprobado para prueba de view';
EXEC usp_AprobarNFT @ID_Revision = 11, @Comentario = 'Excelente calidad artística';
EXEC usp_AprobarNFT @ID_Revision = 12, @Comentario = 'Cumple con todos los estándares';
EXEC usp_AprobarNFT @ID_Revision = 13, @Comentario = 'Técnica innovadora';
EXEC usp_AprobarNFT @ID_Revision = 14, @Comentario = 'Aprobado para subasta premium';
EXEC usp_AprobarNFT @ID_Revision = 15, @Comentario = 'Potencial de valorización alto';
EXEC usp_AprobarNFT @ID_Revision = 16, @Comentario = 'Obra destacada de la colección';
EXEC usp_AprobarNFT @ID_Revision = 17, @Comentario = 'Concepto único y bien ejecutado';
EXEC usp_AprobarNFT @ID_Revision = 18, @Comentario = 'Aprobado - alta demanda esperada';
EXEC usp_AprobarNFT @ID_Revision = 19, @Comentario = 'Técnica digital avanzada';
EXEC usp_AprobarNFT @ID_Revision = 20, @Comentario = 'Obra maestra contemporánea';
EXEC usp_AprobarNFT @ID_Revision = 21, @Comentario = 'Aprobado para colección exclusiva';
EXEC usp_AprobarNFT @ID_Revision = 22, @Comentario = 'Innovación en arte generativo';
    
    -- Rechazamos 2
EXEC usp_RechazarNFT @ID_Revision = 9, @Comentario = 'Rechazado para prueba de view';
EXEC usp_RechazarNFT @ID_Revision = 10, @Comentario = 'Rechazado para prueba de view';



-- Insertar pujas masivas para cada subasta (mínimo 20 pujas por subasta)

-- Subasta 1: 20+ pujas
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 3, @Monto = 30.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 7, @Monto = 35.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 11, @Monto = 40.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 12, @Monto = 45.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 13, @Monto = 50.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 16, @Monto = 55.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 17, @Monto = 60.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 3, @Monto = 65.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 7, @Monto = 70.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 11, @Monto = 75.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 12, @Monto = 80.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 13, @Monto = 85.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 16, @Monto = 90.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 17, @Monto = 95.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 3, @Monto = 100.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 7, @Monto = 105.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 11, @Monto = 120.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 12, @Monto = 135.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 13, @Monto = 145.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 1, @ID_Persona = 16, @Monto = 170.00;



-- Subasta 2: 20+ pujas
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 7, @Monto = 55.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 11, @Monto = 60.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 12, @Monto = 65.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 13, @Monto = 70.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 16, @Monto = 75.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 17, @Monto = 80.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 3, @Monto = 85.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 7, @Monto = 90.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 11, @Monto = 95.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 12, @Monto = 100.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 13, @Monto = 105.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 16, @Monto = 111.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 17, @Monto = 117.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 3, @Monto = 125.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 7, @Monto = 135.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 11, @Monto = 145.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 12, @Monto = 155.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 13, @Monto = 164.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 16, @Monto = 175.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 2, @ID_Persona = 17, @Monto = 187.00;



-- Subasta 3: 20+ pujas
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 3, @Monto = 55.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 7, @Monto = 60.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 11, @Monto = 65.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 12, @Monto = 70.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 13, @Monto = 75.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 16, @Monto = 80.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 17, @Monto = 85.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 3, @Monto = 90.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 7, @Monto = 95.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 11, @Monto = 100.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 12, @Monto = 105.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 13, @Monto = 115.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 16, @Monto = 125.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 17, @Monto = 135.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 3, @Monto = 145.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 7, @Monto = 155.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 11, @Monto = 165.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 12, @Monto = 175.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 13, @Monto = 185.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 3, @ID_Persona = 16, @Monto = 200.00;



-- Continuar con las subastas 4-8 con 20+ pujas cada una
-- Subasta 4
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 7, @Monto = 210.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 11, @Monto = 230.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 12, @Monto = 250.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 13, @Monto = 270.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 16, @Monto = 290.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 17, @Monto = 310.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 3, @Monto = 330.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 7, @Monto = 350.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 11, @Monto = 370.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 12, @Monto = 400.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 13, @Monto = 430.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 16, @Monto = 460.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 17, @Monto = 490.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 3, @Monto = 520.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 7, @Monto = 550.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 11, @Monto = 580.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 12, @Monto = 610.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 13, @Monto = 650.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 16, @Monto = 690.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 4, @ID_Persona = 17, @Monto = 730.00;



-- Subasta 5
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 3, @Monto = 200.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 7, @Monto = 210.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 11, @Monto = 230.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 12, @Monto = 260.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 13, @Monto = 290.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 16, @Monto = 320.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 17, @Monto = 350.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 3, @Monto = 390.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 7, @Monto = 430.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 11, @Monto = 470.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 12, @Monto = 540.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 13, @Monto = 590.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 16, @Monto = 645.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 17, @Monto = 690.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 3, @Monto = 745.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 7, @Monto = 789.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 11, @Monto = 842.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 5, @ID_Persona = 13, @Monto = 910.00;



-- Subasta 6
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 3, @Monto = 160.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 7, @Monto = 170.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 11, @Monto = 180.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 12, @Monto = 190.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 13, @Monto = 200.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 16, @Monto = 210.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 17, @Monto = 240.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 3, @Monto = 270.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 7, @Monto = 310.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 11, @Monto = 351.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 12, @Monto = 450.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 13, @Monto = 500.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 16, @Monto = 560.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 17, @Monto = 612.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 3, @Monto = 690.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 7, @Monto = 751.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 11, @Monto = 859.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 12, @Monto = 920.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 6, @ID_Persona = 13, @Monto = 1000.00;



-- Subasta 7
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 3, @Monto = 270.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 7, @Monto = 283.51;  -- 270.00 * 1.05 = 283.50 → 283.51 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 11, @Monto = 297.69; -- 283.51 * 1.05 = 297.6855 → 297.69 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 12, @Monto = 312.58; -- 297.69 * 1.05 = 312.5745 → 312.58 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 13, @Monto = 328.21; -- 312.58 * 1.05 = 328.209 → 328.21 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 16, @Monto = 344.63; -- 328.21 * 1.05 = 344.6205 → 344.63 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 17, @Monto = 361.87; -- 344.63 * 1.05 = 361.8615 → 361.87 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 3, @Monto = 379.97;  -- 361.87 * 1.05 = 379.9635 → 379.97 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 7, @Monto = 398.97;  -- 379.97 * 1.05 = 398.9685 → 398.97 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 11, @Monto = 418.92; -- 398.97 * 1.05 = 418.9185 → 418.92 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 12, @Monto = 439.87; -- 418.92 * 1.05 = 439.866 → 439.87 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 13, @Monto = 461.87; -- 439.87 * 1.05 = 461.8635 → 461.87 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 16, @Monto = 484.97; -- 461.87 * 1.05 = 484.9635 → 484.97 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 17, @Monto = 509.22; -- 484.97 * 1.05 = 509.2185 → 509.22 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 3, @Monto = 534.69;  -- 509.22 * 1.05 = 534.681 → 534.69 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 7, @Monto = 561.43;  -- 534.69 * 1.05 = 561.4245 → 561.43 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 11, @Monto = 589.51; -- 561.43 * 1.05 = 589.5015 → 589.51 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 12, @Monto = 618.99; -- 589.51 * 1.05 = 618.9855 → 618.99 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 13, @Monto = 649.94; -- 618.99 * 1.05 = 649.9395 → 649.94 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 7, @ID_Persona = 16, @Monto = 682.44; -- 649.94 * 1.05 = 682.437 → 682.44 (> 1.05%)


-- Subasta 8
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 7, @Monto = 910.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 11, @Monto = 956.00;  -- 910.00 * 1.05 = 955.50 → 956.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 12, @Monto = 1004.00; -- 956.00 * 1.05 = 1003.80 → 1004.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 13, @Monto = 1055.00; -- 1004.00 * 1.05 = 1054.20 → 1055.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 16, @Monto = 1108.00; -- 1055.00 * 1.05 = 1107.75 → 1108.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 17, @Monto = 1164.00; -- 1108.00 * 1.05 = 1163.40 → 1164.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 3, @Monto = 1223.00; -- 1164.00 * 1.05 = 1222.20 → 1223.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 7, @Monto = 1285.00; -- 1223.00 * 1.05 = 1284.15 → 1285.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 11, @Monto = 1350.00; -- 1285.00 * 1.05 = 1349.25 → 1350.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 12, @Monto = 1418.00; -- 1350.00 * 1.05 = 1417.50 → 1418.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 13, @Monto = 1489.00; -- 1418.00 * 1.05 = 1488.90 → 1489.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 16, @Monto = 1564.00; -- 1489.00 * 1.05 = 1563.45 → 1564.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 17, @Monto = 1643.00; -- 1564.00 * 1.05 = 1642.20 → 1643.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 3, @Monto = 1726.00; -- 1643.00 * 1.05 = 1725.15 → 1726.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 7, @Monto = 1813.00; -- 1726.00 * 1.05 = 1812.30 → 1813.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 11, @Monto = 1904.00; -- 1813.00 * 1.05 = 1903.65 → 1904.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 12, @Monto = 2000.00; -- 1904.00 * 1.05 = 1999.20 → 2000.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 13, @Monto = 2101.00; -- 2000.00 * 1.05 = 2100.00 → 2101.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 16, @Monto = 2207.00; -- 2101.00 * 1.05 = 2206.05 → 2207.00 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 8, @ID_Persona = 17, @Monto = 2318.00; -- 2207.00 * 1.05 = 2317.35 → 2318.00 (> 1.05%)

-- Insertar pujas para las subastas 9-20 (nuevas subastas)
-- Subasta 9
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 3, @Monto = 80.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 7, @Monto = 84.01;   -- 80.00 * 1.05 = 84.00 → 84.01 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 11, @Monto = 88.22; -- 84.01 * 1.05 = 88.2105 → 88.22 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 12, @Monto = 92.64; -- 88.22 * 1.05 = 92.631 → 92.64 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 13, @Monto = 97.28; -- 92.64 * 1.05 = 97.272 → 97.28 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 16, @Monto = 102.15; -- 97.28 * 1.05 = 102.144 → 102.15 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 17, @Monto = 107.26; -- 102.15 * 1.05 = 107.2575 → 107.26 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 3, @Monto = 112.63; -- 107.26 * 1.05 = 112.623 → 112.63 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 7, @Monto = 118.27; -- 112.63 * 1.05 = 118.2615 → 118.27 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 11, @Monto = 124.19; -- 118.27 * 1.05 = 124.1835 → 124.19 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 12, @Monto = 130.40; -- 124.19 * 1.05 = 130.3995 → 130.40 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 13, @Monto = 136.93; -- 130.40 * 1.05 = 136.92 → 136.93 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 16, @Monto = 143.78; -- 136.93 * 1.05 = 143.7765 → 143.78 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 17, @Monto = 150.97; -- 143.78 * 1.05 = 150.969 → 150.97 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 3, @Monto = 158.52; -- 150.97 * 1.05 = 158.5185 → 158.52 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 7, @Monto = 166.45; -- 158.52 * 1.05 = 166.446 → 166.45 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 11, @Monto = 174.78; -- 166.45 * 1.05 = 174.7725 → 174.78 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 12, @Monto = 183.52; -- 174.78 * 1.05 = 183.519 → 183.52 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 13, @Monto = 192.70; -- 183.52 * 1.05 = 192.696 → 192.70 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 16, @Monto = 202.34; -- 192.70 * 1.05 = 202.335 → 202.34 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 9, @ID_Persona = 17, @Monto = 212.46; -- 202.34 * 1.05 = 212.457 → 212.46 (> 1.05%)


-- Continuar con subastas 10-20 con el mismo patrón...
-- Subasta 10
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 3, @Monto = 100.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 7, @Monto = 105.01;  -- 100.00 * 1.05 = 105.00 → 105.01 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 11, @Monto = 110.27; -- 105.01 * 1.05 = 110.2605 → 110.27 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 12, @Monto = 115.79; -- 110.27 * 1.05 = 115.7835 → 115.79 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 13, @Monto = 121.58; -- 115.79 * 1.05 = 121.5795 → 121.58 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 16, @Monto = 127.66; -- 121.58 * 1.05 = 127.659 → 127.66 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 17, @Monto = 134.05; -- 127.66 * 1.05 = 134.043 → 134.05 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 3, @Monto = 140.76; -- 134.05 * 1.05 = 140.7525 → 140.76 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 7, @Monto = 147.80; -- 140.76 * 1.05 = 147.798 → 147.80 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 11, @Monto = 155.19; -- 147.80 * 1.05 = 155.19 → 155.20 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 12, @Monto = 162.96; -- 155.20 * 1.05 = 162.96 → 162.97 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 13, @Monto = 171.12; -- 162.97 * 1.05 = 171.1185 → 171.12 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 16, @Monto = 179.68; -- 171.12 * 1.05 = 179.676 → 179.68 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 17, @Monto = 188.67; -- 179.68 * 1.05 = 188.664 → 188.67 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 3, @Monto = 198.11; -- 188.67 * 1.05 = 198.1035 → 198.11 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 7, @Monto = 208.02; -- 198.11 * 1.05 = 208.0155 → 208.02 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 11, @Monto = 218.43; -- 208.02 * 1.05 = 218.421 → 218.43 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 12, @Monto = 230.35; -- 218.43 * 1.05 = 229.3515 → 229.35 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 13, @Monto = 245.82; -- 229.35 * 1.05 = 240.8175 → 240.82 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 16, @Monto = 262.87; -- 240.82 * 1.05 = 252.861 → 252.87 (> 1.05%)
EXEC usp_PujarEnSubasta @ID_Subasta = 10, @ID_Persona = 17, @Monto = 285.52; 


-- Subasta 11
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 3, @Monto = 120.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 7, @Monto = 127.00;  -- 120.00 × 1.05 = 126.00 + 1 = 127.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 11, @Monto = 134.00; -- 127.00 × 1.05 = 133.35 + 1 = 134.35 ≈ 134.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 12, @Monto = 141.00; -- 134.00 × 1.05 = 140.70 + 1 = 141.70 ≈ 141.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 13, @Monto = 149.00; -- 141.00 × 1.05 = 148.05 + 1 = 149.05 ≈ 149.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 16, @Monto = 157.00; -- 149.00 × 1.05 = 156.45 + 1 = 157.45 ≈ 157.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 17, @Monto = 165.00; -- 157.00 × 1.05 = 164.85 + 1 = 165.85 ≈ 165.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 3, @Monto = 174.00;  -- 165.00 × 1.05 = 173.25 + 1 = 174.25 ≈ 174.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 7, @Monto = 183.00;  -- 174.00 × 1.05 = 182.70 + 1 = 183.70 ≈ 183.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 11, @Monto = 193.00; -- 183.00 × 1.05 = 192.15 + 1 = 193.15 ≈ 193.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 12, @Monto = 203.00; -- 193.00 × 1.05 = 202.65 + 1 = 203.65 ≈ 203.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 13, @Monto = 214.00; -- 203.00 × 1.05 = 213.15 + 1 = 214.15 ≈ 214.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 16, @Monto = 225.00; -- 214.00 × 1.05 = 224.70 + 1 = 225.70 ≈ 225.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 17, @Monto = 237.00; -- 225.00 × 1.05 = 236.25 + 1 = 237.25 ≈ 237.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 3, @Monto = 249.00;  -- 237.00 × 1.05 = 248.85 + 1 = 249.85 ≈ 249.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 7, @Monto = 262.00;  -- 249.00 × 1.05 = 261.45 + 1 = 262.45 ≈ 262.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 11, @Monto = 276.00; -- 262.00 × 1.05 = 275.10 + 1 = 276.10 ≈ 276.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 12, @Monto = 290.00; -- 276.00 × 1.05 = 289.80 + 1 = 290.80 ≈ 290.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 13, @Monto = 305.00; -- 290.00 × 1.05 = 304.50 + 1 = 305.50 ≈ 305.00
EXEC usp_PujarEnSubasta @ID_Subasta = 11, @ID_Persona = 16, @Monto = 321.00; -- 305.00 × 1.05 = 320.25 + 1 = 321.25 ≈ 321.00



-- Subasta 12
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 3, @Monto = 140.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 7, @Monto = 148.00;  -- 140.00 × 1.05 = 147.00 + 1 = 148.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 11, @Monto = 156.00; -- 148.00 × 1.05 = 155.40 + 1 = 156.40 ≈ 156.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 12, @Monto = 164.00; -- 156.00 × 1.05 = 163.80 + 1 = 164.80 ≈ 164.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 13, @Monto = 173.00; -- 164.00 × 1.05 = 172.20 + 1 = 173.20 ≈ 173.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 16, @Monto = 182.00; -- 173.00 × 1.05 = 181.65 + 1 = 182.65 ≈ 182.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 17, @Monto = 192.00; -- 182.00 × 1.05 = 191.10 + 1 = 192.10 ≈ 192.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 3, @Monto = 202.00;  -- 192.00 × 1.05 = 201.60 + 1 = 202.60 ≈ 202.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 7, @Monto = 213.00;  -- 202.00 × 1.05 = 212.10 + 1 = 213.10 ≈ 213.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 11, @Monto = 224.00; -- 213.00 × 1.05 = 223.65 + 1 = 224.65 ≈ 224.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 12, @Monto = 236.00; -- 224.00 × 1.05 = 235.20 + 1 = 236.20 ≈ 236.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 13, @Monto = 248.00; -- 236.00 × 1.05 = 247.80 + 1 = 248.80 ≈ 248.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 16, @Monto = 261.00; -- 248.00 × 1.05 = 260.40 + 1 = 261.40 ≈ 261.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 17, @Monto = 275.00; -- 261.00 × 1.05 = 274.05 + 1 = 275.05 ≈ 275.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 3, @Monto = 289.00;  -- 275.00 × 1.05 = 288.75 + 1 = 289.75 ≈ 289.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 7, @Monto = 304.00;  -- 289.00 × 1.05 = 303.45 + 1 = 304.45 ≈ 304.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 11, @Monto = 320.00; -- 304.00 × 1.05 = 319.20 + 1 = 320.20 ≈ 320.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 12, @Monto = 337.00; -- 320.00 × 1.05 = 336.00 + 1 = 337.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 13, @Monto = 355.00; -- 337.00 × 1.05 = 353.85 + 1 = 354.85 ≈ 355.00
EXEC usp_PujarEnSubasta @ID_Subasta = 12, @ID_Persona = 16, @Monto = 374.00; -- 355.00 × 1.05 = 372.75 + 1 = 373.75 ≈ 374.00



-- Subasta 13 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 3, @Monto = 160.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 7, @Monto = 169.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 11, @Monto = 178.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 12, @Monto = 188.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 13, @Monto = 198.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 16, @Monto = 209.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 17, @Monto = 220.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 3, @Monto = 232.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 7, @Monto = 244.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 11, @Monto = 257.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 12, @Monto = 270.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 13, @Monto = 284.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 16, @Monto = 299.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 17, @Monto = 315.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 3, @Monto = 331.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 7, @Monto = 348.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 11, @Monto = 366.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 12, @Monto = 385.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 13, @Monto = 405.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 13, @ID_Persona = 16, @Monto = 426.00;

-- Subasta 14 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 3, @Monto = 180.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 7, @Monto = 190.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 11, @Monto = 200.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 12, @Monto = 211.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 13, @Monto = 222.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 16, @Monto = 234.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 17, @Monto = 246.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 3, @Monto = 259.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 7, @Monto = 273.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 11, @Monto = 287.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 12, @Monto = 302.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 13, @Monto = 318.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 16, @Monto = 335.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 17, @Monto = 352.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 3, @Monto = 370.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 7, @Monto = 389.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 11, @Monto = 409.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 12, @Monto = 430.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 13, @Monto = 452.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 14, @ID_Persona = 16, @Monto = 475.00;

-- Subasta 15 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 3, @Monto = 200.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 7, @Monto = 211.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 11, @Monto = 222.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 12, @Monto = 234.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 13, @Monto = 246.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 16, @Monto = 259.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 17, @Monto = 273.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 3, @Monto = 287.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 7, @Monto = 302.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 11, @Monto = 318.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 12, @Monto = 335.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 13, @Monto = 352.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 16, @Monto = 370.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 17, @Monto = 389.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 3, @Monto = 409.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 7, @Monto = 430.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 11, @Monto = 452.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 12, @Monto = 475.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 13, @Monto = 499.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 15, @ID_Persona = 16, @Monto = 524.00;

-- Subasta 16 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 3, @Monto = 220.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 7, @Monto = 232.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 11, @Monto = 244.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 12, @Monto = 257.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 13, @Monto = 270.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 16, @Monto = 284.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 17, @Monto = 299.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 3, @Monto = 315.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 7, @Monto = 331.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 11, @Monto = 348.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 12, @Monto = 366.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 13, @Monto = 385.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 16, @Monto = 405.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 17, @Monto = 426.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 3, @Monto = 448.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 7, @Monto = 471.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 11, @Monto = 495.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 12, @Monto = 520.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 13, @Monto = 546.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 16, @ID_Persona = 16, @Monto = 574.00;

-- Subasta 17 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 3, @Monto = 240.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 7, @Monto = 253.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 11, @Monto = 266.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 12, @Monto = 280.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 13, @Monto = 295.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 16, @Monto = 310.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 17, @Monto = 326.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 3, @Monto = 343.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 7, @Monto = 361.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 11, @Monto = 380.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 12, @Monto = 400.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 13, @Monto = 421.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 16, @Monto = 443.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 17, @Monto = 466.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 3, @Monto = 490.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 7, @Monto = 515.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 11, @Monto = 541.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 12, @Monto = 569.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 13, @Monto = 598.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 17, @ID_Persona = 16, @Monto = 629.00;

-- Subasta 18 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 3, @Monto = 260.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 7, @Monto = 274.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 11, @Monto = 288.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 12, @Monto = 303.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 13, @Monto = 319.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 16, @Monto = 336.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 17, @Monto = 354.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 3, @Monto = 372.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 7, @Monto = 391.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 11, @Monto = 411.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 12, @Monto = 432.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 13, @Monto = 454.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 16, @Monto = 477.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 17, @Monto = 501.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 3, @Monto = 527.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 7, @Monto = 554.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 11, @Monto = 582.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 12, @Monto = 612.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 13, @Monto = 643.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 18, @ID_Persona = 16, @Monto = 676.00;


-- Subasta 19 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 3, @Monto = 280.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 7, @Monto = 295.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 11, @Monto = 310.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 12, @Monto = 326.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 13, @Monto = 343.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 16, @Monto = 361.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 17, @Monto = 380.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 3, @Monto = 400.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 7, @Monto = 421.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 11, @Monto = 443.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 12, @Monto = 466.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 13, @Monto = 490.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 16, @Monto = 515.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 17, @Monto = 541.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 3, @Monto = 569.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 7, @Monto = 598.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 11, @Monto = 629.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 12, @Monto = 661.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 13, @Monto = 695.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 19, @ID_Persona = 16, @Monto = 730.00;

-- Subasta 20 (20 pujas)
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 3, @Monto = 300.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 7, @Monto = 316.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 11, @Monto = 332.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 12, @Monto = 349.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 13, @Monto = 367.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 16, @Monto = 386.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 17, @Monto = 406.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 3, @Monto = 427.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 7, @Monto = 449.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 11, @Monto = 472.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 12, @Monto = 496.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 13, @Monto = 521.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 16, @Monto = 548.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 17, @Monto = 576.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 3, @Monto = 605.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 7, @Monto = 636.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 11, @Monto = 668.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 12, @Monto = 702.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 13, @Monto = 738.00;
EXEC usp_PujarEnSubasta @ID_Subasta = 20, @ID_Persona = 16, @Monto = 775.00;

-- Verificar el resultado
PRINT 'Datos insertados exitosamente:'
PRINT '- 20 NFTs aprobados (subastas activas)'
PRINT '- Mínimo 20 pujas por subasta'
PRINT '- Total de más de 400 pujas en el sistema'

Select *
from Transaccion_Billetera

-- Consultar las vistas para verificar los datos
SELECT * FROM EficienciaCuradores;
SELECT * FROM ActividadColeccionistas;
SELECT * FROM ValorizacionArtistas;
SELECT * FROM SubastaXPeriodo;

