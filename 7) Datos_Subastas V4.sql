-- Seed: Tipo_Entidad
INSERT INTO Tipo_Entidad (Nombre) VALUES
('Artista'),
('Curador'),
('Coleccionista');

-- Seed: Estado_NFT
INSERT INTO Estado_NFT (Nombre) VALUES
('Aprobado'),
('Pendiente'),
('Rechazado');

-- Seed: Estado_Subasta
INSERT INTO Estado_Subasta (Nombre) VALUES
('Activa'),
('Finalizada'),
('Procesando'),
('Cancelada')
;

-- Seed: Estado_Puja
INSERT INTO Estado_Puja (Nombre) VALUES
('Activa'),
('Superada'),
('Ganadora'),
('Reembolsada');

-- Seed: Tipo_Transaccion
INSERT INTO Tipo_Transaccion (Nombre) VALUES
('Depósito'),
('Retiro'),
('Pago'),
('Compra'),
('Liberación'),
('Reservación');

-- Seed: Formato
INSERT INTO Formato (Nombre) VALUES
('JPEG'),
('PNG'),
('GIF');

-- Seed: Tipo
INSERT INTO Tipo (Nombre) VALUES
('Arte Digital'),
('Fotografía'),
('Generativo'),
('Pixel Art'),
('3D');

-- Seed: Error (parámetros de validación)
INSERT INTO Error (Nombre, Valor) VALUES
('Ancho Máximo', 100.00),
('Largo Máximo', 100.00),
('Ancho Minimo', 10.00),
('Largo Minimo', 10.00),
('Tamaño Máximo', 500.00),
('Tamaño Minimo', 10.00);


-- Seed: Precio_Default
INSERT INTO Precio_Default (ID_Formato, Precio_Base, Fecha_Inicio_Vigencia) VALUES
(1, 1.50, GETDATE()),
(2, 2.00, GETDATE()),
(3, 2.50, GETDATE());
GO


