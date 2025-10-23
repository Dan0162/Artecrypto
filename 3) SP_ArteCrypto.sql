-- ============================================================================
-- ARTECRYPTO - STORED PROCEDURES
-- ============================================================================

-- ============================================================================
-- SP 1: CREATE NFT
-- ============================================================================
CREATE OR ALTER PROCEDURE usp_CrearNFT
    @ID_Persona INT,
    @ID_Formato INT,
    @ID_Tipo INT,
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Tamaño DECIMAL(10,2),
    @Ancho DECIMAL(10,2),
    @Alto DECIMAL(10,2),
    @Precio MONEY = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @Hash VARCHAR(100);
        DECLARE @PrecioFinal MONEY;
        DECLARE @NombrePersona NVARCHAR(100);
        DECLARE @ID_NFT_Creado INT;
        DECLARE @ErrorCount INT = 0;
        
    -- Create temporary table for errors
        CREATE TABLE #Errores (
            NumeroError INT IDENTITY(1,1),
            MensajeError NVARCHAR(500)
        );
        
    -- 1. VALIDATE DIMENSIONS AND SIZE (MULTIPLE ERRORS)
        INSERT INTO #Errores (MensajeError)
        SELECT MensajeError
        FROM dbo.ufn_Validación(@Tamaño, @Alto, @Ancho)
        WHERE EsValido = 0;
        
    -- 2. VALIDATE THAT THE FORMAT EXISTS
        IF NOT EXISTS (SELECT 1 FROM Formato WHERE ID_Formato = @ID_Formato)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El formato especificado no existe');
        END
        
    -- 3. VALIDATE THAT THE TYPE EXISTS
        IF NOT EXISTS (SELECT 1 FROM Tipo WHERE ID_Tipo = @ID_Tipo)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El tipo de NFT especificado no existe');
        END
        
    -- 4. VALIDATE THAT THE PERSON EXISTS
        IF NOT EXISTS (SELECT 1 FROM Persona WHERE ID_Persona = @ID_Persona)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('La persona especificada no existe');
        END
        
    -- 5. VALIDATE NAME IS NOT EMPTY
        IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El nombre del NFT no puede estar vacío');
        END
        
    -- 6. VALIDATE PRICE IS NOT NEGATIVE
        IF @Precio < 0
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El precio no puede ser negativo');
        END
        
    -- Get error count
        SELECT @ErrorCount = COUNT(*) FROM #Errores;
        
    -- If there are errors, show them and exit
        IF @ErrorCount > 0
        BEGIN
            DECLARE @MensajeFinal NVARCHAR(MAX) = 'Se encontraron ' + CAST(@ErrorCount AS VARCHAR) + ' error(es):' + CHAR(13) + CHAR(10);
            
            SELECT @MensajeFinal = @MensajeFinal + 
                   'Error ' + CAST(NumeroError AS VARCHAR) + ': ' + MensajeError + CHAR(13) + CHAR(10)
            FROM #Errores
            ORDER BY NumeroError;
            
            PRINT @MensajeFinal;
            THROW 50001, @MensajeFinal, 1;
        END
        
    -- 7. GENERATE UNIQUE HASH
        SET @Hash = dbo.ufn_GenerarHash(@ID_Formato, @ID_Tipo, @Nombre, @Descripcion);
        
    -- Verify that the hash does not exist
        IF EXISTS (SELECT 1 FROM NFT WHERE hash_NFT = @Hash)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('Este NFT ya existe en el sistema (hash duplicado)');
            
            SELECT @MensajeFinal = 'Error: Este NFT ya existe en el sistema (hash duplicado)';
            PRINT @MensajeFinal;
            THROW 50002, @MensajeFinal, 1;
        END
        
    -- 8. ASSIGN PRICE
        IF @Precio = 0
        BEGIN
            SET @PrecioFinal = dbo.ufn_ObtenerPrecioDefault(@ID_Formato);
        END
        ELSE
        BEGIN
            SET @PrecioFinal = @Precio;
        END
        
    -- 9. INSERT NFT
        INSERT INTO NFT (
            ID_Persona, ID_Formato, ID_Tipo, Nombre, hash_NFT,
            Descripcion, Tamaño, Ancho, Alto, Precio, Fecha_Creacion
        )
        VALUES (
            @ID_Persona, @ID_Formato, @ID_Tipo, @Nombre, @Hash,
            @Descripcion, @Tamaño, @Ancho, @Alto, @PrecioFinal, GETDATE()
        );
        
        -- Obtener el ID del NFT
        SELECT @ID_NFT_Creado = ID_NFT
        FROM NFT
        WHERE hash_NFT = @Hash;

        IF @ID_NFT_Creado IS NULL
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('No se pudo recuperar ID_NFT tras insertar el registro');
            
            SELECT @MensajeFinal = 'Error: No se pudo recuperar ID_NFT tras insertar el registro';
            PRINT @MensajeFinal;
            THROW 50012, @MensajeFinal, 1;
        END
        
    -- 10. SEND NOTIFICATION TO THE ARTIST
        SELECT @NombrePersona = Nombre FROM Persona WHERE ID_Persona = @ID_Persona;
        
        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (
            @ID_Persona,
            '¡Hola ' + @NombrePersona + '! Recibimos "' + @Nombre + 
            '". Nuestro equipo de curadores la revisará pronto. ' +
            'Mientras tanto, puedes editar los metadatos antes de la aprobación.'
        );

        PRINT 'NFT creado exitosamente. ID: ' + CAST(@ID_NFT_Creado AS VARCHAR);
        
    -- Clean up temporary table
        DROP TABLE #Errores;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Limpiar tabla temporal en caso de error
        IF OBJECT_ID('tempdb..#Errores') IS NOT NULL
            DROP TABLE #Errores;
            
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END
GO


-- ============================================================================
-- SP 2: APPROVE NFT
-- ============================================================================
CREATE OR ALTER PROCEDURE usp_AprobarNFT
    @ID_Revision INT,
    @Comentario NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @ID_NFT INT;
        DECLARE @ID_Artista INT;
        DECLARE @NombreNFT NVARCHAR(100);
        DECLARE @EstadoAprobadoID INT;
        DECLARE @NombreArtista NVARCHAR(100);
        
    -- usp_AprobarNFT: approve revision, create auction and notify
    -- Get ID for the "Approved" state
        SELECT @EstadoAprobadoID = ID_EstadoNFT 
        FROM Estado_NFT 
        WHERE Nombre = 'Aprobado';
        
    -- Verify that the revision exists and belongs to the curator
        SELECT @ID_NFT = ID_NFT
        FROM Revision 
        WHERE ID_Revision = @ID_Revision 
        
        IF @ID_NFT IS NULL
        BEGIN
            THROW 50006, 'Error: Revisión no encontrada o no pertenece a este curador', 1;
        END
        
    -- Get NFT and artist data
        SELECT 
            @ID_Artista = ID_Persona,
            @NombreNFT = Nombre
        FROM NFT 
        WHERE ID_NFT = @ID_NFT;
        
        SELECT @NombreArtista = Nombre 
        FROM Persona 
        WHERE ID_Persona = @ID_Artista;
        
    -- Update the revision (change state and finalize)
        UPDATE Revision
        SET ID_EstadoNFT = @EstadoAprobadoID,
            Fecha_Final = GETDATE(),
            Comentario = ISNULL(@Comentario, 'NFT aprobado - Cumple estándares de calidad')
        WHERE ID_Revision = @ID_Revision;
        
    -- Send notification to the artist
        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (
            @ID_Artista,
            '¡Felicidades ' + @NombreArtista + '! "' + @NombreNFT + 
            '" fue aprobada y ya está en subasta. Termina en 72 horas. ' +
            'Comparte el enlace con tus seguidores.'
        );

        COMMIT TRANSACTION;     
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END
GO

-- ============================================================================
-- SP 3: REJECT NFT
-- ============================================================================
CREATE OR ALTER PROCEDURE usp_RechazarNFT
    @ID_Revision INT,
    @Comentario NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @ID_NFT INT;
        DECLARE @ID_Artista INT;
        DECLARE @NombreNFT NVARCHAR(100);
        DECLARE @EstadoRechazadoID INT;
        DECLARE @NombreArtista NVARCHAR(100);
        
    -- usp_RechazarNFT: reject revision and notify the artist
    -- Validate that a comment is provided
        IF @Comentario IS NULL OR LTRIM(RTRIM(@Comentario)) = ''
        BEGIN
            THROW 50007, 'Error: Debe proporcionar un comentario explicando el rechazo', 1;
        END
        
    -- Get ID for the "Rejected" state
        SELECT @EstadoRechazadoID = ID_EstadoNFT 
        FROM Estado_NFT 
        WHERE Nombre = 'Rechazado';
            
    -- Verify that the revision exists and belongs to the curator
        SELECT @ID_NFT = ID_NFT
        FROM Revision 
        WHERE ID_Revision = @ID_Revision 

        
        IF @ID_NFT IS NULL
        BEGIN
            THROW 50008, 'Error: Revisión no encontrada o no pertenece a este curador', 1;
        END
        
    -- Get NFT and artist data
        SELECT 
            @ID_Artista = ID_Persona,
            @NombreNFT = Nombre
        FROM NFT 
        WHERE ID_NFT = @ID_NFT;
        
        SELECT @NombreArtista = Nombre 
        FROM Persona 
        WHERE ID_Persona = @ID_Artista;
        
    -- Update the revision (change state and finalize)
        UPDATE Revision
        SET ID_EstadoNFT = @EstadoRechazadoID,
            Fecha_Final = GETDATE(),
            Comentario = @Comentario
        WHERE ID_Revision = @ID_Revision;
        
    -- Send notification to the artist
        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (
            @ID_Artista,
            'Hola ' + @NombreArtista + ', lamentamos informarte que "' + @NombreNFT + 
            '" no fue aprobada. Motivo: ' + @Comentario + 
            '. Puedes corregir los datos y reenviar para validación.'
        );
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END
GO

-- ============================================================================
-- SP 4: UPDATE NFT (with re-validation)
-- ============================================================================
CREATE OR ALTER PROCEDURE usp_ActualizarNFT
    @ID_NFT INT,
    @ID_Persona INT, -- Para verificar que sea el propietario
    @Nombre NVARCHAR(100) = NULL,
    @Descripcion NVARCHAR(MAX) = NULL,
    @Tamaño DECIMAL(10,2) = NULL,
    @Ancho DECIMAL(10,2) = NULL,
    @Alto DECIMAL(10,2) = NULL,
    @Precio MONEY = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @CodigoValidacion INT;
        DECLARE @MensajeError NVARCHAR(200);
        DECLARE @NombrePersona NVARCHAR(100);
        DECLARE @PropietarioActual INT;
        
    -- Verify that the NFT exists and belongs to the person
        SELECT @PropietarioActual = ID_Persona
        FROM NFT 
        WHERE ID_NFT = @ID_NFT;
        
        IF @PropietarioActual IS NULL
        BEGIN
            THROW 50009, 'Error: NFT no encontrado', 1;
        END        
       
    -- If dimensions are modified, validate
        IF @Tamaño IS NOT NULL OR @Ancho IS NOT NULL OR @Alto IS NOT NULL
        BEGIN
            -- Get current values if new ones are not provided
            IF @Tamaño IS NULL SELECT @Tamaño = Tamaño FROM NFT WHERE ID_NFT = @ID_NFT;
            IF @Ancho IS NULL SELECT @Ancho = Ancho FROM NFT WHERE ID_NFT = @ID_NFT;
            IF @Alto IS NULL SELECT @Alto = Alto FROM NFT WHERE ID_NFT = @ID_NFT;
            
            SET @CodigoValidacion = dbo.ufn_Validación(@Tamaño, @Alto, @Ancho);
            
            IF @CodigoValidacion <> 1
            BEGIN
                SET @MensajeError = 
                    CASE @CodigoValidacion
                        WHEN -1 THEN 'Error: Tamaño excede el máximo permitido'
                        WHEN -2 THEN 'Error: Tamaño es menor al mínimo permitido'
                        WHEN -3 THEN 'Error: Alto excede el máximo permitido'
                        WHEN -4 THEN 'Error: Alto es menor al mínimo permitido'
                        WHEN -5 THEN 'Error: Ancho excede el máximo permitido'
                        WHEN -6 THEN 'Error: Ancho es menor al mínimo permitido'
                        ELSE 'Error de validación desconocido'
                    END;
                
                THROW 50011, @MensajeError, 1;
            END
        END
        
        -- Actualizar solo los campos proporcionados
        UPDATE NFT
        SET 
            Nombre = ISNULL(@Nombre, Nombre),
            Descripcion = ISNULL(@Descripcion, Descripcion),
            Tamaño = ISNULL(@Tamaño, Tamaño),
            Ancho = ISNULL(@Ancho, Ancho),
            Alto = ISNULL(@Alto, Alto),
            Precio = ISNULL(@Precio, Precio),
            Fecha_Modificacion = GETDATE(),
            hash_NFT = dbo.ufn_GenerarHash(
                ID_Formato, 
                ID_Tipo, 
                ISNULL(@Nombre, Nombre), 
                ISNULL(@Descripcion, Descripcion)
            )
        WHERE ID_NFT = @ID_NFT;
        
    -- Send notification
        SELECT @NombrePersona = Nombre FROM Persona WHERE ID_Persona = @ID_Persona;
        
        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (
            @ID_Persona,
            '¡Hola ' + @NombrePersona + '! Tu NFT ha sido actualizado exitosamente.'
        );
        
        COMMIT TRANSACTION;       
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END
GO

-- ============================================================================
-- SP 5: BID IN AUCTION
-- ============================================================================
CREATE OR ALTER PROCEDURE usp_PujarEnSubasta
    @ID_Subasta INT,
    @ID_Persona INT,
    @Monto MONEY
AS
BEGIN
    SET NOCOUNT ON;

    IF @Monto <= 0
    BEGIN
        THROW 50013, 'Error: La oferta debe ser mayor que 0.', 1;
    END

    DECLARE @EstadoSubastaActivaID INT;
    DECLARE @PrecioActual MONEY;
    DECLARE @OfertaMinima MONEY;
    DECLARE @ID_Billetera INT;
    DECLARE @SaldoDisponible MONEY;
    DECLARE @SaldoReservado MONEY;
    DECLARE @ID_EstadoPuja_Activa INT;
    DECLARE @ID_EstadoPuja_Superada INT;
    DECLARE @ID_EstadoPuja_Ganadora INT;
    DECLARE @PrevPujaID INT = NULL;
    DECLARE @PrevPujaMonto MONEY = 0;
    DECLARE @MontoAReservar MONEY;
    DECLARE @ExisteEmpate BIT = 0;
    DECLARE @MontoMaximoActual MONEY;
    DECLARE @CantidadEmpates INT = 0;

    -- Get static IDs
    SELECT @ID_EstadoPuja_Activa = ID_EstadoPuja FROM Estado_Puja WHERE Nombre = 'Activa';
    SELECT @ID_EstadoPuja_Superada = ID_EstadoPuja FROM Estado_Puja WHERE Nombre = 'Superada';
    SELECT @ID_EstadoPuja_Ganadora = ID_EstadoPuja FROM Estado_Puja WHERE Nombre = 'Ganadora';
    SELECT @EstadoSubastaActivaID = ID_EstadoSubasta FROM Estado_Subasta WHERE Nombre = 'Activa'


    -- Verify that the auction exists, is active and not finished
    IF NOT EXISTS (
        SELECT 1 FROM Subasta s 
        INNER JOIN Estado_Subasta es ON s.ID_EstadoSubasta = es.ID_EstadoSubasta
        WHERE s.ID_Subasta = @ID_Subasta
        AND es.ID_EstadoSubasta = @EstadoSubastaActivaID
        AND s.Fecha_Inicio <= GETDATE() AND s.Fecha_Final > GETDATE()
    )
    BEGIN
        THROW 50016, 'Error: La subasta no existe, no está activa o ya finalizó.', 1;
    END

    -- Get current price and minimum bid
    SET @PrecioActual = dbo.ufn_ObtenerPrecioActualSubasta(@ID_Subasta);
    SET @OfertaMinima = dbo.ufn_CalcularOfertaMinima(@ID_Subasta);

    -- Competitiveness validation: require at least the minimum bid (5% over current)
    IF @Monto < @OfertaMinima
    BEGIN
        DECLARE @Mensaje NVARCHAR(200);
        SET @Mensaje = 'Error: Oferta no competitiva.';
        THROW 50015, @Mensaje, 1;
    END

    BEGIN TRANSACTION;
    BEGIN TRY

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
    -- Get the bidder's wallet to update balances
         SELECT TOP 1 @ID_Billetera = ID_Billetera, @SaldoDisponible = Saldo_Disponible, @SaldoReservado = Saldo_Reservado
         FROM Billetera
         WHERE ID_Persona = @ID_Persona;

        IF @ID_Billetera IS NULL
        BEGIN
            THROW 50017, 'Error: No se encontró billetera para el usuario.', 1;
        END

    -- Check if the same user already has an active/winning bid in this auction
        SELECT TOP 1 @PrevPujaID = ID_Puja, @PrevPujaMonto = Monto
        FROM Puja
        WHERE ID_Subasta = @ID_Subasta
          AND ID_Persona = @ID_Persona
          AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora)
        ORDER BY Fecha DESC;

        IF @PrevPujaID IS NOT NULL
        BEGIN
            SET @MontoAReservar = @Monto - ISNULL(@PrevPujaMonto, 0);
        END
        ELSE
        BEGIN
            SET @MontoAReservar = @Monto;
        END


    -- Verify available balance to reserve the difference
        IF @SaldoDisponible < @MontoAReservar
        BEGIN
            THROW 50014, 'Error: Saldo insuficiente en la billetera para cubrir la reserva de la oferta.', 1;
        END

    -- Check if there is a tie with other bids of the same amount
        SELECT @MontoMaximoActual = MAX(Monto)
        FROM Puja 
        WHERE ID_Subasta = @ID_Subasta 
          AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);

    -- If the offered amount equals the current maximum, there is a tie
        IF @Monto = @MontoMaximoActual AND @MontoMaximoActual IS NOT NULL
        BEGIN
            SET @ExisteEmpate = 1;
            
            -- Count how many ties exist
            SELECT @CantidadEmpates = COUNT(*)
            FROM Puja
            WHERE ID_Subasta = @ID_Subasta 
              AND Monto = @Monto
              AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);
            
            -- Notify all users with tied bids
            INSERT INTO Correo_log (ID_Persona, Descripcion)
            SELECT DISTINCT ID_Persona, 
                   'Aviso de Empate: Su oferta de ' + CONVERT(VARCHAR(50), @Monto) + 
                   ' ETH para la subasta ' + CONVERT(VARCHAR(20), @ID_Subasta) + 
                   ' está empatada con otros participantes. La oferta más reciente será considerada ganadora.'
            FROM Puja
            WHERE ID_Subasta = @ID_Subasta 
              AND Monto = @Monto
              AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora)
              AND ID_Persona <> @ID_Persona; -- Excluir al usuario actual (se notificará después)
        END

    -- If the user had a previous bid, mark it as surpassed
        IF @PrevPujaID IS NOT NULL
        BEGIN
            UPDATE Puja SET Estado = @ID_EstadoPuja_Superada WHERE ID_Puja = @PrevPujaID;
        END

    -- Insert new bid as Winning
        INSERT INTO Puja (ID_Subasta, ID_Persona, Monto, Fecha, Estado)
        VALUES (@ID_Subasta, @ID_Persona, @Monto, GETDATE(), @ID_EstadoPuja_Ganadora);


    -- If there is a tie, mark tied bids as Winning
        IF @ExisteEmpate = 1
        BEGIN
            UPDATE Puja 
            SET Estado = @ID_EstadoPuja_Ganadora
            WHERE ID_Subasta = @ID_Subasta 
              AND Monto = @Monto
              AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);
        END
        ELSE
        BEGIN
            UPDATE Puja 
            SET Estado = @ID_EstadoPuja_Activa
            WHERE ID_Subasta = @ID_Subasta 
            AND  ID_Persona <> @ID_Persona
            AND Estado = @ID_EstadoPuja_Ganadora

        END

    -- Update the wallet to reserve the difference
        UPDATE Billetera
        SET Saldo_Disponible = Saldo_Disponible - @MontoAReservar,
            Saldo_Reservado = Saldo_Reservado + @MontoAReservar,
            Fecha_Actualizacion = GETDATE()
        WHERE ID_Billetera = @ID_Billetera;

    -- Email log / confirmation to the bidder
        DECLARE @MensajeCorreo NVARCHAR(500);
        
        IF @ExisteEmpate = 1
        BEGIN
            SET @MensajeCorreo = '¡Felicidades! Su oferta de ' + CONVERT(VARCHAR(50), @Monto) + 
                                ' ETH para la subasta ' + CONVERT(VARCHAR(20), @ID_Subasta) + 
                                ' está empatada con ' + CONVERT(VARCHAR(10), @CantidadEmpates) + 
                                ' otros participantes. Se tomará como ganador la puja más reciente.';
        END
        ELSE
        BEGIN
            SET @MensajeCorreo = '¡Felicidades! Su oferta de ' + CONVERT(VARCHAR(50), @Monto) + 
                                ' ETH para la subasta ' + CONVERT(VARCHAR(20), @ID_Subasta) + 
                                ' fue registrada como ganadora en ' + 
                                CONVERT(VARCHAR(20), GETDATE(), 120);
        END

        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (@ID_Persona, @MensajeCorreo);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END
GO




-- ============================================================================
-- SP 6: AUCTION MODIFICATION
-- ============================================================================

CREATE OR ALTER PROCEDURE usp_ModificarSubasta
    @ID_Subasta INT,
    @NuevoPrecioInicial MONEY = NULL,
    @HorasExtras INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @SubastaExiste BIT = 0;
        DECLARE @FechaInicioActual DATETIME;
        DECLARE @FechaFinalActual DATETIME;
        DECLARE @Mensaje NVARCHAR(500) = '';
        
    -- Validate that the auction exists
        SELECT 
            @SubastaExiste = 1,
            @FechaInicioActual = Fecha_Inicio,
            @FechaFinalActual = Fecha_Final
        FROM Subasta 
        WHERE ID_Subasta = @ID_Subasta;
        
        IF @SubastaExiste = 0
        BEGIN
            THROW 50030, 'Error: La subasta especificada no existe.', 1;
        END
        
    -- Validate that at least one parameter was provided
        IF @NuevoPrecioInicial IS NULL AND @HorasExtras IS NULL
        BEGIN
            THROW 50031, 'Error: Debe proporcionar al menos un parámetro (precio o horas extras).', 1;
        END
        
    -- Validate that the price is not negative
        IF @NuevoPrecioInicial IS NOT NULL AND @NuevoPrecioInicial < 0
        BEGIN
            THROW 50032, 'Error: El precio inicial no puede ser negativo.', 1;
        END
        
    -- Update initial price if provided
        IF @NuevoPrecioInicial IS NOT NULL
        BEGIN
            UPDATE Subasta 
            SET Precio_Inicial = @NuevoPrecioInicial
            WHERE ID_Subasta = @ID_Subasta;
            
            SET @Mensaje = @Mensaje + 'Precio inicial actualizado a ' + CAST(@NuevoPrecioInicial AS VARCHAR) + ' ETH. ';
        END


 
    -- Extend duration if extra hours are provided
        IF @HorasExtras IS NOT NULL
        BEGIN
                  
            UPDATE Subasta 
            SET Fecha_Final = DATEADD(HOUR, @HorasExtras, @FechaFinalActual)
            WHERE ID_Subasta = @ID_Subasta;
            
            IF @HorasExtras > 0
            BEGIN
            SET @Mensaje = @Mensaje + 'Duración extendida por ' + CAST(@HorasExtras AS VARCHAR) + 
                          ' horas.';
            END
            ELSE IF @HorasExtras < 0
            BEGIN
            SET @Mensaje = @Mensaje + 'Duración acortada por ' + CAST(ABS(@HorasExtras) AS VARCHAR) + 
                          ' horas.';
            END
        END
        
        PRINT @Mensaje
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END
GO