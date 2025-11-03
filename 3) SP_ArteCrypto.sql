-- ============================================================================
-- ARTECRYPTO - PROCEDIMIENTOS ALMACENADOS
-- ============================================================================

-- ============================================================================
-- SP 1: CREAR NFT 
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
        
        -- Crear tabla temporal para errores
        CREATE TABLE #Errores (
            NumeroError INT IDENTITY(1,1),
            MensajeError NVARCHAR(500)
        );
        
        -- 1. VALIDAR DIMENSIONES Y TAMAÑO (MÚLTIPLES ERRORES)
        INSERT INTO #Errores (MensajeError)
        SELECT MensajeError
        FROM dbo.ufn_Validación(@Tamaño, @Alto, @Ancho)
        WHERE EsValido = 0;
        
        -- 2. VALIDAR QUE EL FORMATO EXISTA
        IF NOT EXISTS (SELECT 1 FROM Formato WHERE ID_Formato = @ID_Formato)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El formato especificado no existe');
        END
        
        -- 3. VALIDAR QUE EL TIPO EXISTA
        IF NOT EXISTS (SELECT 1 FROM Tipo WHERE ID_Tipo = @ID_Tipo)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El tipo de NFT especificado no existe');
        END
        
        -- 4. VALIDAR QUE LA PERSONA EXISTA
        IF NOT EXISTS (SELECT 1 FROM Persona WHERE ID_Persona = @ID_Persona)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('La persona especificada no existe');
        END
        
        -- 5. VALIDAR NOMBRE NO VACÍO
        IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El nombre del NFT no puede estar vacío');
        END
        
        -- 6. VALIDAR PRECIO NO NEGATIVO
        IF @Precio < 0
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('El precio no puede ser negativo');
        END
        
        -- Obtener conteo de errores
        SELECT @ErrorCount = COUNT(*) FROM #Errores;
        
        -- Si hay errores, mostrarlos y salir
        IF @ErrorCount > 0
        BEGIN
            DECLARE @MensajeFinal NVARCHAR(MAX) = 'Se encontraron ' + CAST(@ErrorCount AS VARCHAR) + ' error(es):' + CHAR(13) + CHAR(10);
            
            SELECT @MensajeFinal = @MensajeFinal + 
                   'Error ' + CAST(NumeroError AS VARCHAR) + ': ' + MensajeError + CHAR(13) + CHAR(10)
            FROM #Errores
            ORDER BY NumeroError;

            THROW 50001, @MensajeFinal, 1;
        END
        
        -- 7. GENERAR HASH ÚNICO
        SET @Hash = dbo.ufn_GenerarHash(@ID_Formato, @ID_Tipo, @Nombre, @Descripcion);
        
        -- Verificar que el hash no exista
        IF EXISTS (SELECT 1 FROM NFT WHERE hash_NFT = @Hash)
        BEGIN
            INSERT INTO #Errores (MensajeError) 
            VALUES ('Este NFT ya existe en el sistema (hash duplicado)');
            
            SELECT @MensajeFinal = 'Error: Este NFT ya existe en el sistema (hash duplicado)';
            PRINT @MensajeFinal;
            THROW 50002, @MensajeFinal, 1;
        END
        
        -- 8. ASIGNAR PRECIO
        IF @Precio = 0
        BEGIN
            SET @PrecioFinal = dbo.ufn_ObtenerPrecioDefault(@ID_Formato);
        END
        ELSE
        BEGIN
            SET @PrecioFinal = @Precio;
        END
        
        -- 9. INSERTAR NFT
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
        
        -- 10. ENVIAR NOTIFICACIÓN AL ARTISTA
        SELECT @NombrePersona = Nombre FROM Persona WHERE ID_Persona = @ID_Persona;
        
        INSERT INTO Correo_log (ID_Persona, Descripcion)
        VALUES (
            @ID_Persona,
            '¡Hola ' + @NombrePersona + '! Recibimos "' + @Nombre + 
            '". Nuestro equipo de curadores la revisará pronto. ' +
            'Mientras tanto, puedes editar los metadatos antes de la aprobación.'
        );

        PRINT 'NFT creado exitosamente. ID: ' + CAST(@ID_NFT_Creado AS VARCHAR);
        
        -- Limpiar tabla temporal
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
-- SP 2: APROBAR NFT
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
        
        -- usp_AprobarNFT: aprueba revisión, crea subasta y notifica
        -- Obtener ID del estado "Aprobado"
        SELECT @EstadoAprobadoID = ID_EstadoNFT 
        FROM Estado_NFT 
        WHERE Nombre = 'Aprobado';
        
        -- Verificar que la revisión existe y pertenece al curador
        SELECT @ID_NFT = ID_NFT
        FROM Revision 
        WHERE ID_Revision = @ID_Revision 
        
        IF @ID_NFT IS NULL
        BEGIN
            THROW 50006, 'Error: Revisión no encontrada o no pertenece a este curador', 1;
        END
        
        -- Obtener datos del NFT y artista
        SELECT 
            @ID_Artista = ID_Persona,
            @NombreNFT = Nombre
        FROM NFT 
        WHERE ID_NFT = @ID_NFT;
        
        SELECT @NombreArtista = Nombre 
        FROM Persona 
        WHERE ID_Persona = @ID_Artista;
        
        -- Actualizar la revisión (cambiar estado y finalizar)
        UPDATE Revision
        SET ID_EstadoNFT = @EstadoAprobadoID,
            Fecha_Final = GETDATE(),
            Comentario = ISNULL(@Comentario, 'NFT aprobado - Cumple estándares de calidad')
        WHERE ID_Revision = @ID_Revision;
        
        -- Enviar notificación al artista
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
-- SP 3: RECHAZAR NFT
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
        
        -- usp_RechazarNFT: rechaza revisión y notifica al artista
        -- Validar que se proporcione un comentario
        IF @Comentario IS NULL OR LTRIM(RTRIM(@Comentario)) = ''
        BEGIN
            THROW 50007, 'Error: Debe proporcionar un comentario explicando el rechazo', 1;
        END
        
        -- Obtener ID del estado "Rechazado"
        SELECT @EstadoRechazadoID = ID_EstadoNFT 
        FROM Estado_NFT 
        WHERE Nombre = 'Rechazado';
            
        -- Verificar que la revisión existe y pertenece al curador
        SELECT @ID_NFT = ID_NFT
        FROM Revision 
        WHERE ID_Revision = @ID_Revision 

        
        IF @ID_NFT IS NULL
        BEGIN
            THROW 50008, 'Error: Revisión no encontrada o no pertenece a este curador', 1;
        END
        
        -- Obtener datos del NFT y artista
        SELECT 
            @ID_Artista = ID_Persona,
            @NombreNFT = Nombre
        FROM NFT 
        WHERE ID_NFT = @ID_NFT;
        
        SELECT @NombreArtista = Nombre 
        FROM Persona 
        WHERE ID_Persona = @ID_Artista;
        
        -- Actualizar la revisión (cambiar estado y finalizar)
        UPDATE Revision
        SET ID_EstadoNFT = @EstadoRechazadoID,
            Fecha_Final = GETDATE(),
            Comentario = @Comentario
        WHERE ID_Revision = @ID_Revision;
        
        -- Enviar notificación al artista
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
-- SP 4: ACTUALIZAR NFT (con re-validación)
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
        
        -- Verificar que el NFT existe y pertenece a la persona
        SELECT @PropietarioActual = ID_Persona
        FROM NFT 
        WHERE ID_NFT = @ID_NFT;
        
        IF @PropietarioActual IS NULL
        BEGIN
            THROW 50009, 'Error: NFT no encontrado', 1;
        END        
       
        -- Si se modifican dimensiones, validar
        IF @Tamaño IS NOT NULL OR @Ancho IS NOT NULL OR @Alto IS NOT NULL
        BEGIN
            -- Obtener valores actuales si no se proporcionan nuevos
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
        
        -- Enviar notificación
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
-- SP 5: PUJA EN SUBASTA
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
    DECLARE @UltimaPujaFecha DATETIME;
    DECLARE @DiferenciaSegundos INT;
    DECLARE @NewPujaID INT;

    -- Obtiene los IDs estáticos
    SELECT @ID_EstadoPuja_Activa = ID_EstadoPuja FROM Estado_Puja WHERE Nombre = 'Activa';
    SELECT @ID_EstadoPuja_Superada = ID_EstadoPuja FROM Estado_Puja WHERE Nombre = 'Superada';
    SELECT @ID_EstadoPuja_Ganadora = ID_EstadoPuja FROM Estado_Puja WHERE Nombre = 'Ganadora';
    SELECT @EstadoSubastaActivaID = ID_EstadoSubasta FROM Estado_Subasta WHERE Nombre = 'Activa';

    -- Verifica que la subasta existe y está activa y no finalizada 
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

    -- Obtiene precio actual y oferta mínima
    SET @PrecioActual = dbo.ufn_ObtenerPrecioActualSubasta(@ID_Subasta);
    SET @OfertaMinima = dbo.ufn_CalcularOfertaMinima(@ID_Subasta);

    -- Obtiene la fecha de la última puja para calcular diferencia de tiempo
    SELECT TOP 1 @UltimaPujaFecha = Fecha
    FROM Puja
    WHERE ID_Subasta = @ID_Subasta
    ORDER BY Fecha DESC;

    -- Calcula diferencia en segundos desde la última puja
    IF @UltimaPujaFecha IS NOT NULL
    BEGIN
        SET @DiferenciaSegundos = DATEDIFF(SECOND, @UltimaPujaFecha, GETDATE());
    END
    ELSE
    BEGIN
        SET @DiferenciaSegundos = 11;
    END

    -- Validación de competitividad: la oferta debe ser al menos la oferta mínima
    -- (se aplica siempre para evitar aceptar montos por debajo del mínimo competitivo)
    IF @Monto < @OfertaMinima
    BEGIN
        DECLARE @Mensaje NVARCHAR(200);
        SET @Mensaje = 'Error: Oferta no competitiva. El monto debe ser >= oferta mínima.';
        THROW 50015, @Mensaje, 1;
    END

    BEGIN TRANSACTION;
    BEGIN TRY

        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

        -- Obtiene la billetera del pujador para actualizar saldos
        SELECT TOP 1 @ID_Billetera = ID_Billetera, @SaldoDisponible = Saldo_Disponible, @SaldoReservado = Saldo_Reservado
        FROM Billetera
        WHERE ID_Persona = @ID_Persona;

        IF @ID_Billetera IS NULL
        BEGIN
            THROW 50017, 'Error: No se encontró billetera para el usuario.', 1;
        END

        -- Verifica si el mismo usuario ya tiene una puja activa/ganadora previa en esta subasta
        SELECT TOP 1 @PrevPujaID = ID_Puja, @PrevPujaMonto = Monto
        FROM Puja
        WHERE ID_Subasta = @ID_Subasta
          AND ID_Persona = @ID_Persona
          AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora)
        ORDER BY Fecha DESC;

        IF @PrevPujaID IS NOT NULL
        BEGIN
             -- No permitir reducir el monto de una puja previa del mismo usuario
            IF @Monto < @PrevPujaMonto
            BEGIN
                THROW 50018, 'Error: No se permite disminuir el monto de una puja previa.', 1;
            END

            SET @MontoAReservar = @Monto - ISNULL(@PrevPujaMonto, 0);
        END
        ELSE
        BEGIN
            SET @MontoAReservar = @Monto;
        END

        -- Verifica saldo disponible para reservar la diferencia
        IF @SaldoDisponible < @MontoAReservar
        BEGIN
            THROW 50014, 'Error: Saldo insuficiente en la billetera para cubrir la reserva de la oferta.', 1;
        END

        -- Verifica si existe empate con otras pujas del mismo monto
        SELECT @MontoMaximoActual = MAX(Monto)
        FROM Puja 
        WHERE ID_Subasta = @ID_Subasta 
          AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);

        -- Si el monto ofertado es igual al máximo actual, ocurre el empate
        IF @Monto = @MontoMaximoActual AND @MontoMaximoActual IS NOT NULL
        BEGIN
            SET @ExisteEmpate = 1;
            
            -- Cuenta la cantidad de empates existentes (ANTES de insertar la nueva puja)
            SELECT @CantidadEmpates = COUNT(*)
            FROM Puja
            WHERE ID_Subasta = @ID_Subasta 
              AND Monto = @Monto
              AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);
        END

        -- Si el usuario tenía una puja previa, se marca como superada 
        IF @PrevPujaID IS NOT NULL
        BEGIN
            UPDATE Puja SET Estado = @ID_EstadoPuja_Superada WHERE ID_Puja = @PrevPujaID;
        END

        -- Inserta nueva puja como Ganadora 
        INSERT INTO Puja (ID_Subasta, ID_Persona, Monto, Fecha, Estado)
        VALUES (@ID_Subasta, @ID_Persona, @Monto, GETDATE(), @ID_EstadoPuja_Ganadora);

        SET @NewPujaID = SCOPE_IDENTITY();

        --Notifica empates 
        IF @ExisteEmpate = 1
        BEGIN
            -- Notifica a los usuarios con pujas empatadas (incluyendo al actual)
            INSERT INTO Correo_log (ID_Persona, Descripcion)
            SELECT DISTINCT ID_Persona, 
                   'Aviso de Empate: Su oferta de ' + CONVERT(VARCHAR(50), @Monto) + 
                   ' ETH para la subasta ' + CONVERT(VARCHAR(20), @ID_Subasta) + 
                   ' está empatada con otros participantes.'
            FROM Puja
            WHERE ID_Subasta = @ID_Subasta 
              AND Monto = @Monto
              AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);
            
            -- Marca todas las pujas empatadas como Ganadoras
            UPDATE Puja 
            SET Estado = @ID_EstadoPuja_Ganadora
            WHERE ID_Subasta = @ID_Subasta 
              AND Monto = @Monto
              AND Estado IN (@ID_EstadoPuja_Activa, @ID_EstadoPuja_Ganadora);
        END
        ELSE
        BEGIN
            -- Sin empate: se marcan otras pujas como Activas
            UPDATE Puja 
            SET Estado = @ID_EstadoPuja_Activa
            WHERE ID_Subasta = @ID_Subasta 
            AND ID_Persona <> @ID_Persona
            AND Estado = @ID_EstadoPuja_Ganadora;
        END

        -- Actualiza la billetera para reservar la diferencia
        UPDATE Billetera
        SET Saldo_Disponible = Saldo_Disponible - @MontoAReservar,
            Saldo_Reservado = Saldo_Reservado + @MontoAReservar,
            Fecha_Actualizacion = GETDATE()
        WHERE ID_Billetera = @ID_Billetera;

        -- Log de correo/confirmación al pujador 
        DECLARE @MensajeCorreo NVARCHAR(500);
        
        IF @ExisteEmpate = 1
        BEGIN
            SET @MensajeCorreo = 'Su oferta de ' + CONVERT(VARCHAR(50), @Monto) + 
                                ' ETH para la subasta ' + CONVERT(VARCHAR(20), @ID_Subasta) + 
                                ' ha sido recibida, pero está empatada con ' + CONVERT(VARCHAR(10), @CantidadEmpates) + 
                                ' otros participantes. Se respetará el orden de llegada.';
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
-- SP 6: MODIFICACION EN LA SUBASTA
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
        
        -- Validar que la subasta existe
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
        
        -- Validar que al menos un parámetro fue proporcionado
        IF @NuevoPrecioInicial IS NULL AND @HorasExtras IS NULL
        BEGIN
            THROW 50031, 'Error: Debe proporcionar al menos un parámetro (precio o horas extras).', 1;
        END
        
        -- Validar que el precio no sea negativo
        IF @NuevoPrecioInicial IS NOT NULL AND @NuevoPrecioInicial < 0
        BEGIN
            THROW 50032, 'Error: El precio inicial no puede ser negativo.', 1;
        END
        
        -- Actualizar precio inicial si se proporciona
        IF @NuevoPrecioInicial IS NOT NULL
        BEGIN
            UPDATE Subasta 
            SET Precio_Inicial = @NuevoPrecioInicial
            WHERE ID_Subasta = @ID_Subasta;
            
            SET @Mensaje = @Mensaje + 'Precio inicial actualizado a ' + CAST(@NuevoPrecioInicial AS VARCHAR) + ' ETH. ';
        END


 
        -- Extender duración si se proporcionan horas extras
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


-- ============================================================================
-- SP 7: FINALIZACION DE LA SUBASTA
-- ============================================================================

CREATE OR ALTER PROCEDURE FinalizarSubastas
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SubastasProcesadas INT = 0;
    DECLARE @InicioEjecucion DATETIME = GETDATE();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Obtener estados
        DECLARE @EstadoProcesando INT = (SELECT ID_EstadoSubasta FROM Estado_Subasta WHERE Nombre = 'Procesando');
        DECLARE @EstadoFinalizada INT = (SELECT ID_EstadoSubasta FROM Estado_Subasta WHERE Nombre = 'Finalizada');
        DECLARE @EstadoActiva INT = (SELECT ID_EstadoSubasta FROM Estado_Subasta WHERE Nombre = 'Activa');
        
        -- 2. Verificar primero si hay subastas para procesar
        IF NOT EXISTS (
            SELECT 1 
            FROM Subasta 
            WHERE ID_EstadoSubasta = @EstadoActiva 
            AND Fecha_Final <= GETDATE()
        )
        BEGIN
            -- No hay subastas para procesar, hacer commit y salir
            COMMIT TRANSACTION;
            
            PRINT 'No hay subastas pendientes de finalizar.';
            RETURN 0;
        END
        
        -- 3. Si hay subastas, continuar con el procesamiento normal
        UPDATE Subasta 
        SET ID_EstadoSubasta = @EstadoProcesando
        WHERE ID_EstadoSubasta = @EstadoActiva 
        AND Fecha_Final <= GETDATE();
        
        -- 4. Identificar subastas que deben finalizar
        DECLARE @SubastasFinalizadas TABLE (
            ID_Subasta INT,
            ID_NFT INT,
            ID_Persona_Artista INT,
            Oferta_Ganadora MONEY,
            ID_Persona_Ganador INT,
            Nombre_NFT NVARCHAR(100),
            Correo_Artista NVARCHAR(100),
            Correo_Ganador NVARCHAR(100)
        );
        
            INSERT INTO @SubastasFinalizadas (
                ID_Subasta, ID_NFT, ID_Persona_Artista, Oferta_Ganadora, ID_Persona_Ganador,
                Nombre_NFT, Correo_Artista, Correo_Ganador
            )
            SELECT 
                s.ID_Subasta,
                s.ID_NFT,
                n.ID_Persona AS ID_Persona_Artista,
                -- Obtiene la oferta máxima para esta subasta específica
                (SELECT MAX(Monto) FROM Puja WHERE ID_Subasta = s.ID_Subasta) AS Oferta_Ganadora,
                -- Obtiene el primer ganador en caso de empate (por fecha más temprana)
                (SELECT TOP 1 p2.ID_Persona 
                 FROM Puja p2 
                 WHERE p2.ID_Subasta = s.ID_Subasta 
                 AND p2.Monto = (SELECT MAX(Monto) FROM Puja WHERE ID_Subasta = s.ID_Subasta)
                 ORDER BY p2.Fecha ASC) AS ID_Persona_Ganador,
                n.Nombre AS Nombre_NFT,
                pa.Correo AS Correo_Artista,
                pg.Correo AS Correo_Ganador
            FROM Subasta s
            INNER JOIN NFT n ON s.ID_NFT = n.ID_NFT
            INNER JOIN Persona pa ON n.ID_Persona = pa.ID_Persona
            LEFT JOIN Persona pg ON (SELECT TOP 1 p2.ID_Persona 
                                   FROM Puja p2 
                                   WHERE p2.ID_Subasta = s.ID_Subasta 
                                   AND p2.Monto = (SELECT MAX(Monto) FROM Puja WHERE ID_Subasta = s.ID_Subasta)
                                   ORDER BY p2.Fecha ASC) = pg.ID_Persona
            WHERE s.ID_EstadoSubasta = @EstadoProcesando
            GROUP BY s.ID_Subasta, s.ID_NFT, n.ID_Persona, n.Nombre, pa.Correo, pg.Correo;
        
        SET @SubastasProcesadas = @@ROWCOUNT;
        
        -- 5. Procesar cada subasta finalizada
        DECLARE @ID_Subasta INT, @ID_NFT INT, @ID_Artista INT, @Oferta_Ganadora MONEY, 
                @ID_Ganador INT, @Nombre_NFT NVARCHAR(100), @Correo_Artista NVARCHAR(100), 
                @Correo_Ganador NVARCHAR(100);
        
        DECLARE subasta_cursor CURSOR FOR
        SELECT ID_Subasta, ID_NFT, ID_Persona_Artista, Oferta_Ganadora, ID_Persona_Ganador,
               Nombre_NFT, Correo_Artista, Correo_Ganador
        FROM @SubastasFinalizadas;
        
        OPEN subasta_cursor;
        FETCH NEXT FROM subasta_cursor INTO @ID_Subasta, @ID_NFT, @ID_Artista, @Oferta_Ganadora, 
                                            @ID_Ganador, @Nombre_NFT, @Correo_Artista, @Correo_Ganador;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verifica si hay ofertas ganadoras
            IF @Oferta_Ganadora IS NOT NULL AND @ID_Ganador IS NOT NULL
            BEGIN
                -- Transfiere NFT al ganador
                INSERT INTO Registro_NFT (ID_Persona, ID_NFT, ID_Subasta, Fecha_Adquisicion)
                VALUES (@ID_Ganador, @ID_NFT, @ID_Subasta, GETDATE());
                
                -- Transferir fondos al artista
                UPDATE Billetera 
                SET Saldo_Disponible = Saldo_Disponible + @Oferta_Ganadora,
                    Fecha_Actualizacion = GETDATE()
                WHERE ID_Persona = @ID_Artista;
                
                -- Registra la transacción para el artista (Pago)
                INSERT INTO Transaccion_Billetera (ID_Billetera, ID_TipoTransaccion, ID_Subasta, Monto, Fecha_Transaccion, Motivo)
                SELECT 
                    b.ID_Billetera,
                    (SELECT ID_TipoTransaccion FROM Tipo_Transaccion WHERE Nombre = 'Pago'),
                    @ID_Subasta,
                    @Oferta_Ganadora,
                    GETDATE(),
                    'Venta de NFT: ' + @Nombre_NFT
                FROM Billetera b
                WHERE b.ID_Persona = @ID_Artista;
                
                -- *** NUEVO: Registrar transacción de COMPRA para el ganador ***
                INSERT INTO Transaccion_Billetera (ID_Billetera, ID_TipoTransaccion, ID_Subasta, Monto, Fecha_Transaccion, Motivo)
                SELECT 
                    b.ID_Billetera,
                    (SELECT ID_TipoTransaccion FROM Tipo_Transaccion WHERE Nombre = 'Compra'),
                    @ID_Subasta,
                    @Oferta_Ganadora,
                    GETDATE(),
                    'Compra de NFT: ' + @Nombre_NFT
                FROM Billetera b
                WHERE b.ID_Persona = @ID_Ganador;
                
                -- Reembolsa a los perdedores
                UPDATE Billetera 
                SET Saldo_Disponible = Saldo_Disponible + p.Monto,
                    Saldo_Reservado = Saldo_Reservado - p.Monto,
                    Fecha_Actualizacion = GETDATE()
                FROM Billetera b
                INNER JOIN Puja p ON b.ID_Persona = p.ID_Persona
                WHERE p.ID_Subasta = @ID_Subasta
                AND p.ID_Persona != @ID_Ganador;
                
                -- Registra transacciones de reembolso
                INSERT INTO Transaccion_Billetera (ID_Billetera, ID_TipoTransaccion, ID_Subasta, Monto, Fecha_Transaccion, Motivo)
                SELECT 
                    b.ID_Billetera,
                    (SELECT ID_TipoTransaccion FROM Tipo_Transaccion WHERE Nombre = 'Reembolso'),
                    @ID_Subasta,
                    p.Monto,
                    GETDATE(),
                    'Reembolso por oferta no ganadora en: ' + @Nombre_NFT
                FROM Billetera b
                INNER JOIN Puja p ON b.ID_Persona = p.ID_Persona
                WHERE p.ID_Subasta = @ID_Subasta
                AND p.ID_Persona != @ID_Ganador;
                
                -- Libera fondos reservados del ganador
                UPDATE Billetera 
                SET Saldo_Reservado = Saldo_Reservado - @Oferta_Ganadora,
                    Fecha_Actualizacion = GETDATE()
                WHERE ID_Persona = @ID_Ganador;
                
                -- Actualiza subasta con oferta ganadora
                UPDATE Subasta 
                SET Oferta_Ganadora = @Oferta_Ganadora,
                    ID_EstadoSubasta = @EstadoFinalizada
                WHERE ID_Subasta = @ID_Subasta;
                
                -- Registra notificaciones
                INSERT INTO Correo_log (ID_Persona, Descripcion, Fecha_Envio)
                VALUES 
                    (@ID_Ganador, '¡Felicidades! Eres el nuevo dueño de "' + @Nombre_NFT + '" por ' + CAST(@Oferta_Ganadora AS NVARCHAR(20)) + ' ETH.', GETDATE()),
                    (@ID_Artista, '¡Venta exitosa! Has recibido ' + CAST(@Oferta_Ganadora AS NVARCHAR(20)) + ' ETH por tu NFT "' + @Nombre_NFT + '".', GETDATE());
                
                -- Notifica a perdedores
                INSERT INTO Correo_log (ID_Persona, Descripcion, Fecha_Envio)
                SELECT DISTINCT 
                    p.ID_Persona,
                    'Tu oferta en la subasta de "' + @Nombre_NFT + '" no fue ganadora. Los fondos han sido reembolsados a tu billetera.',
                    GETDATE()
                FROM Puja p
                WHERE p.ID_Subasta = @ID_Subasta
                AND p.ID_Persona != @ID_Ganador;
            END
            ELSE
            BEGIN
                -- Subasta sin ofertas
                UPDATE Subasta 
                SET ID_EstadoSubasta = @EstadoFinalizada
                WHERE ID_Subasta = @ID_Subasta;
                
                -- Notificar al artista
                INSERT INTO Correo_log (ID_Persona, Descripcion, Fecha_Envio)
                VALUES (@ID_Artista, 'Lamentamos informarte que tu subasta de "' + @Nombre_NFT + '" ha terminado sin ofertas.', GETDATE());
            END
            
            FETCH NEXT FROM subasta_cursor INTO @ID_Subasta, @ID_NFT, @ID_Artista, @Oferta_Ganadora, 
                                                @ID_Ganador, @Nombre_NFT, @Correo_Artista, @Correo_Ganador;
        END
        
        CLOSE subasta_cursor;
        DEALLOCATE subasta_cursor;
        
        COMMIT TRANSACTION;
        
        -- 6. Log de ejecución exitosa
        DECLARE @TiempoEjecucion INT = DATEDIFF(SECOND, @InicioEjecucion, GETDATE());
        
        PRINT 'Proceso de finalización completado. ' + CAST(@SubastasProcesadas AS NVARCHAR(10)) + ' subastas procesadas en ' + CAST(@TiempoEjecucion AS NVARCHAR(10)) + ' segundos.';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Registrar error detallado
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        -- Insertar en log de errores
        
        RAISERROR ('Error en finalización de subastas: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;