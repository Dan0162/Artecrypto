-- Seed: Tipo_Entidad
INSERT INTO Tipo_Entidad (Nombre) VALUES
('Artista'),
('Curador'),
('Coleccionista');

-- Seed: Estado_NFT
-- Seed: Tipo_Entidad (Entity types)
('Aprobado'),
('Pendiente'),
('Rechazado');

-- Seed: Estado_Subasta
-- Seed: Estado_NFT (NFT states)
('Activa'),
('Finalizada'),
('Cancelada');

-- Seed: Estado_Puja
-- Seed: Estado_Subasta (Auction states)
('Activa'),
('Superada'),
('Ganadora'),
('Reembolsada');

-- Seed: Estado_Puja (Bid states)
INSERT INTO Tipo_Transaccion (Nombre) VALUES
('Depósito'),
('Retiro'),
('Reserva'),
('Liberación'),
('Pago a Artista'),
-- Seed: Tipo_Transaccion (Transaction types)

-- Seed: Formato
INSERT INTO Formato (Nombre) VALUES
('JPEG'),
('PNG'),
('GIF');

-- Seed: Tipo
-- Seed: Formato (File formats)
('Arte Digital'),
('Fotografía'),
('Generativo'),
('Pixel Art'),
('3D');
-- Seed: Tipo (NFT categories)
-- Seed: Error (parámetros de validación)
INSERT INTO Error (Nombre, Valor) VALUES
('Ancho Máximo', 100.00),
('Largo Máximo', 100.00),
('Ancho Minimo', 10.00),
('Largo Minimo', 10.00),
('Tamaño Máximo', 500.00),
-- Seed: Error (validation parameters)


-- Seed: Precio_Default
INSERT INTO Precio_Default (ID_Formato, Precio_Base, Fecha_Inicio_Vigencia) VALUES
(1, 1.50, GETDATE()),
(2, 2.00, GETDATE()),
(3, 2.50, GETDATE());

-- Seed: Precio_Default (default prices)
INSERT INTO Persona (Nombre, Correo, Telefono) VALUES
('María González López', 'maria.gonzalez@email.com', 65123456),
('Carlos Rodríguez Pérez', 'carlos.rodriguez@email.com', 65234567),
('Ana Martínez Sánchez', 'ana.martinez@email.com', 65345678),
('Javier Fernández García', 'javier.fernandez@email.com', 65456789),
-- Seed: Persona (people / users)
('David Torres Navarro', 'david.torres@email.com', 65678901),
('Elena Ruiz Martín', 'elena.ruiz@email.com', 65789012),
('Miguel Ángel Silva Castro', 'miguel.silva@email.com', 65890123),
('Sofía Herrera Mendoza', 'sofia.herrera@email.com', 65901234),
('Daniel Vargas Ortega', 'daniel.vargas@email.com', 65012345);

-- Seed: Entidad_Rol
INSERT INTO Entidad_Rol (ID_Persona, ID_TipoEntidad, Fecha_Registro) VALUES
(1, 1, '2024-01-15 10:30:00'), 
(1, 2, '2024-02-01 14:20:00'),
(2, 1, '2024-01-20 09:15:00'),
(3, 1, '2024-01-25 11:45:00'), 
-- Seed: Entidad_Rol (person-role relations)
(4, 2, '2024-02-05 08:00:00'),
(5, 1, '2024-02-10 13:25:00'),
(6, 3, '2024-02-15 10:00:00'),
(7, 1, '2024-02-20 15:40:00'),
(8, 3, '2024-03-01 12:10:00'),
(9, 3, '2024-03-05 15:30:00'),
(10, 3, '2024-03-08 11:20:00');

-- Seed: Billetera
INSERT INTO Billetera (ID_Persona, Saldo_Disponible, Saldo_Reservado) VALUES
(3, 10.00, 0.00),
(6, 15.00, 0.00),
(8, 8.00, 0.00),
(9, 12.00, 0.00),
-- Seed: Billetera (wallet balances)

GO