CREATE DATABASE CompraventaAutos;

USE CompraventaAutos;

CREATE TABLE Clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    cedula_cliente VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE PropietariosVenta (
    id_solicitud INT IDENTITY(1,1) PRIMARY KEY,
    nombre_vendedor VARCHAR(100) NOT NULL,
    correo_vendedor VARCHAR(150) NOT NULL,
    marca_vehiculo VARCHAR(50) NOT NULL,
    modelo_vehiculo VARCHAR(80) NOT NULL,
    anio_vehiculo SMALLINT NOT NULL,
    precio_solicitado DECIMAL(15, 2) NOT NULL,
    descripcion TEXT NULL,
    fecha_registro DATE DEFAULT GETDATE()
);

CREATE TABLE Vehiculos (
    id_vehiculo INT IDENTITY(1,1) PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('Nuevo', 'Usado')),
    kilometraje INT NULL,
    garantia INT NULL,
    vendido BIT DEFAULT 0,
    color VARCHAR(20) DEFAULT 'Blanco'
);

CREATE TABLE Ventas (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT,
    id_vehiculo INT,
    fecha_venta DATE DEFAULT GETDATE(),
    total_venta DECIMAL(12,2),
    CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    CONSTRAINT fk_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES Vehiculos(id_vehiculo)
);

INSERT INTO Clientes (nombre_cliente, cedula_cliente)
VALUES
('Juan Pérez', '1001234567'),
('María López', '1002345678'),
('Carlos Gómez', '1003456789');

INSERT INTO Vehiculos (marca, modelo, anio, precio, tipo, kilometraje, garantia, color)
VALUES
('Toyota', 'Corolla', 2022, 85000000, 'Nuevo', NULL, 3, 'Gris'),
('Chevrolet', 'Onix', 2021, 65000000, 'Usado', 40000, NULL, 'Rojo'),
('Mazda', 'CX5', 2023, 130000000, 'Nuevo', NULL, 5, 'Negro');

INSERT INTO PropietariosVenta (nombre_vendedor, correo_vendedor, marca_vehiculo, modelo_vehiculo, anio_vehiculo, precio_solicitado, descripcion)
VALUES
('Diana Rodríguez', 'diana.r@mail.com', 'Hyundai', 'Tucson', 2019, 75000000.00, 'Perfecto estado, llantas nuevas.'),
('Andrés Castro', 'a.castro@mail.com', 'Kia', 'Picanto', 2020, 35000000.00, NULL);

UPDATE Vehiculos
SET precio = 140000000
WHERE modelo = 'CX5';

DELETE FROM Vehiculos
WHERE id_vehiculo = 2;

SELECT
    v.id_venta,
    c.nombre_cliente AS Cliente,
    ve.marca AS Marca,
    ve.modelo AS Modelo,
    ve.precio AS Precio_Vehiculo,
    v.total_venta AS Total_Pagado,
    v.fecha_venta AS Fecha_Venta
FROM Ventas v
INNER JOIN Clientes c ON v.id_cliente = c.id_cliente
INNER JOIN Vehiculos ve ON v.id_vehiculo = ve.id_vehiculo;

SELECT
    marca,
    modelo,
    precio,
    (precio * 0.19) AS IVA_Estimado,
    (precio * 1.19) AS PrecioFinal_Estimado
FROM Vehiculos;



IF OBJECT_ID('sp_RegistrarCliente') IS NOT NULL DROP PROCEDURE sp_RegistrarCliente;
GO
CREATE PROCEDURE sp_RegistrarCliente
    @nombre VARCHAR(100),
    @cedula VARCHAR(20)
AS
BEGIN
    INSERT INTO Clientes (nombre_cliente, cedula_cliente) VALUES (@nombre, @cedula);
END;
GO

IF OBJECT_ID('sp_RegistrarVehiculo') IS NOT NULL DROP PROCEDURE sp_RegistrarVehiculo;
GO
CREATE PROCEDURE sp_RegistrarVehiculo
    @marca VARCHAR(50),
    @modelo VARCHAR(50),
    @anio INT,
    @precio DECIMAL(12,2),
    @tipo VARCHAR(20),
    @km INT = NULL,
    @garantia INT = NULL,
    @color VARCHAR(20) = 'Blanco'
AS
BEGIN
    INSERT INTO Vehiculos (marca, modelo, anio, precio, tipo, kilometraje, garantia, color)
    VALUES (@marca, @modelo, @anio, @precio, @tipo, @km, @garantia, @color);
END;
GO

IF OBJECT_ID('sp_RegistrarPropietarioVenta') IS NOT NULL DROP PROCEDURE sp_RegistrarPropietarioVenta;
GO
CREATE PROCEDURE sp_RegistrarPropietarioVenta
    @nombre VARCHAR(100),
    @correo VARCHAR(150),
    @marca VARCHAR(50),
    @modelo VARCHAR(80),
    @anio SMALLINT,
    @precio DECIMAL(15, 2),
    @descripcion TEXT = NULL
AS
BEGIN
    INSERT INTO PropietariosVenta (nombre_vendedor, correo_vendedor, marca_vehiculo, modelo_vehiculo, anio_vehiculo, precio_solicitado, descripcion)
    VALUES (@nombre, @correo, @marca, @modelo, @anio, @precio, @descripcion);
END;
GO

IF OBJECT_ID('sp_RegistrarVenta') IS NOT NULL DROP PROCEDURE sp_RegistrarVenta;
GO
CREATE PROCEDURE sp_RegistrarVenta
    @idCliente INT,
    @idVehiculo INT,
    @total DECIMAL(12,2)
AS
BEGIN
    INSERT INTO Ventas (id_cliente, id_vehiculo, total_venta)
    VALUES (@idCliente, @idVehiculo, @total);

    UPDATE Vehiculos
    SET vendido = 1
    WHERE id_vehiculo = @idVehiculo;
END;
GO