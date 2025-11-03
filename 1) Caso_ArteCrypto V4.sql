-- Tipo_Entidad: lista tipos de entidad
CREATE TABLE Tipo_Entidad(
    ID_TipoEntidad INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL
);

-- Estado_NFT: estados posibles de revisión
CREATE TABLE Estado_NFT(
    ID_EstadoNFT INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(30) NOT NULL
);

-- Tipo: categorías de NFT
CREATE TABLE Tipo(
    ID_Tipo INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(30) NOT NULL
);

-- Formato: formatos de archivo
CREATE TABLE Formato(
    ID_Formato INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(30) NOT NULL
);

-- Estado_Subasta: estados de la subasta
CREATE TABLE Estado_Subasta(
    ID_EstadoSubasta INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(30) NOT NULL
);

-- Estado_Puja: estados de las pujas
CREATE TABLE Estado_Puja(
    ID_EstadoPuja INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL
);

-- Tipo_Transaccion: tipos de movimiento en billetera
CREATE TABLE Tipo_Transaccion(
    ID_TipoTransaccion INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);

-- Persona: usuarios del sistema
CREATE TABLE Persona(
    ID_Persona INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) NOT NULL,
    Telefono INT,
    CONSTRAINT UQ_Correo UNIQUE (Correo)
);

-- Entidad_Rol: relaciones persona -> rol
CREATE TABLE Entidad_Rol(
    ID_EntidadRol INT IDENTITY(1,1),
    ID_Persona INT NOT NULL,
    ID_TipoEntidad INT NOT NULL,
    Fecha_Registro DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (ID_EntidadRol, ID_Persona, ID_TipoEntidad),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (ID_TipoEntidad) REFERENCES Tipo_Entidad(ID_TipoEntidad)
);

-- NFT: registro principal de obras
CREATE TABLE NFT(
    ID_NFT INT PRIMARY KEY IDENTITY(1,1),
    ID_Persona INT NOT NULL,
    ID_Formato INT NOT NULL,
    ID_Tipo INT NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    hash_NFT VARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(MAX) NULL,
    Tamaño DECIMAL(10,2) NOT NULL,
    Ancho DECIMAL(10,2) NOT NULL,
    Alto DECIMAL(10,2) NOT NULL,
    Precio MONEY NOT NULL,
    Fecha_Creacion DATETIME NULL DEFAULT GETDATE(),
    Fecha_Modificacion DATETIME NULL,
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (ID_Formato) REFERENCES Formato(ID_Formato),
    FOREIGN KEY (ID_Tipo) REFERENCES Tipo(ID_Tipo),
    CONSTRAINT UQ_Hash UNIQUE (hash_NFT),
    CONSTRAINT CHK_Precio_Positivo CHECK (Precio >= 0),
    CONSTRAINT CHK_Dimensiones_Positivas CHECK (Ancho > 0 AND Alto > 0 AND Tamaño > 0)
);

-- Revision: historial y estado de revisión por curadores
CREATE TABLE Revision(
    ID_Revision INT PRIMARY KEY IDENTITY(1,1),
    ID_Persona INT NOT NULL,
    ID_NFT INT NOT NULL,
    ID_EstadoNFT INT NOT NULL,
    Fecha_Inicio DATETIME NULL,
    Fecha_Final DATETIME NULL,
    Comentario NVARCHAR(MAX) NULL,
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (ID_EstadoNFT) REFERENCES Estado_NFT(ID_EstadoNFT),
    FOREIGN KEY (ID_NFT) REFERENCES NFT(ID_NFT),
    CONSTRAINT CHK_Fecha_Revision CHECK (Fecha_Final IS NULL OR Fecha_Final >= Fecha_Inicio)
);

-- Subasta: subastas automáticas y manuales
CREATE TABLE Subasta(
    ID_Subasta INT PRIMARY KEY IDENTITY(1,1),
    ID_EstadoSubasta INT NOT NULL,
    ID_NFT INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Precio_Inicial MONEY NOT NULL,
    Fecha_Inicio DATETIME NOT NULL,
    Fecha_Final DATETIME NOT NULL,
    Oferta_Ganadora MONEY NULL,
    FOREIGN KEY (ID_EstadoSubasta) REFERENCES Estado_Subasta(ID_EstadoSubasta),
    FOREIGN KEY (ID_NFT) REFERENCES NFT(ID_NFT),
    CONSTRAINT CHK_Fecha_Subasta CHECK (Fecha_Final > Fecha_Inicio)
);

-- Puja: ofertas en subastas
CREATE TABLE Puja(
    ID_Puja INT PRIMARY KEY IDENTITY(1,1),
    ID_Subasta INT NOT NULL,
    ID_Persona INT NOT NULL,
    Monto MONEY NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    Estado INT NOT NULL,
    FOREIGN KEY (ID_Subasta) REFERENCES Subasta(ID_Subasta),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (Estado) REFERENCES Estado_Puja(ID_EstadoPuja),
    CONSTRAINT CHK_Monto_Positivo CHECK (Monto > 0)
);

-- Registro_NFT: transferencias/adquisiciones
CREATE TABLE Registro_NFT(
    ID_RegistroNFT INT PRIMARY KEY IDENTITY(1,1),
    ID_Persona INT NOT NULL,
    ID_NFT INT NOT NULL,
    ID_Subasta INT NOT NULL,
    Fecha_Adquisicion DATETIME NOT NULL,
    FOREIGN KEY (ID_NFT) REFERENCES NFT(ID_NFT),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (ID_Subasta) REFERENCES Subasta(ID_Subasta)
);

-- Billetera: saldo por persona
CREATE TABLE Billetera(
    ID_Billetera INT PRIMARY KEY IDENTITY(1,1),
    ID_Persona INT NOT NULL,
    Saldo_Disponible MONEY NOT NULL DEFAULT 0,
    Saldo_Reservado MONEY NOT NULL DEFAULT 0,
    Fecha_Actualizacion DATETIME NULL DEFAULT GETDATE(),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    CONSTRAINT CHK_Saldo_No_Negativo CHECK (Saldo_Disponible >= 0 AND Saldo_Reservado >= 0)
);

-- Transaccion_Billetera: movimientos de billetera
CREATE TABLE Transaccion_Billetera(
    ID_Transaccion INT PRIMARY KEY IDENTITY(1,1),
    ID_Billetera INT NOT NULL,
    ID_TipoTransaccion INT NOT NULL,
    ID_Subasta INT NULL,
    Monto MONEY NOT NULL,
    Motivo NVARCHAR(MAX) NULL,
    Fecha_Transaccion DATETIME NOT NULL,
    FOREIGN KEY (ID_Billetera) REFERENCES Billetera(ID_Billetera),
    FOREIGN KEY (ID_TipoTransaccion) REFERENCES Tipo_Transaccion(ID_TipoTransaccion),
    FOREIGN KEY (ID_Subasta) REFERENCES Subasta(ID_Subasta)
);

-- Error: parámetros de validación y límites
CREATE TABLE Error(
    Id_Error INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Valor DECIMAL(10,2) NOT NULL
);

-- Correo_log: registro de notificaciones
CREATE TABLE Correo_log(
    ID_Correo INT PRIMARY KEY IDENTITY(1,1),
    ID_Persona INT,
    Descripcion NVARCHAR(200),
    Fecha_Envio DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona)
);

-- Precio_Default: precios base por formato
CREATE TABLE Precio_Default(
    ID_PrecioDefault INT PRIMARY KEY IDENTITY(1,1),
    ID_Formato INT NOT NULL,
    Precio_Base MONEY NOT NULL,
    Fecha_Inicio_Vigencia DATETIME NOT NULL DEFAULT GETDATE(),
    Fecha_Fin_Vigencia DATETIME NULL,
    Activo BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (ID_Formato) REFERENCES Formato(ID_Formato),
    CONSTRAINT CHK_Precio_Base_Positivo CHECK (Precio_Base >= 0),
    CONSTRAINT CHK_Fechas_Vigencia CHECK (Fecha_Fin_Vigencia IS NULL OR Fecha_Fin_Vigencia > Fecha_Inicio_Vigencia)
);

GO