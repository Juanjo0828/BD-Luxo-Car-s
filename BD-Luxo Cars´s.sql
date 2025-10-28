CREATE DATABASE CompraventaCarros
USE CompraventaCarros
DROP TABLE IF EXISTS PERSONAS_INTERESADAS;
DROP TABLE IF EXISTS SOLICITUDES_VENTA;
DROP TABLE IF EXISTS AUTOS_EN_VENTA;

-- TABLA AUTOS_EN_VENTA
CREATE TABLE AUTOS_EN_VENTA (
    id_auto BIGINT PRIMARY KEY AUTO_INCREMENT,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio SMALLINT NOT NULL,
    precio_cop DECIMAL(15, 2) NOT NULL,
    kilometraje INT,
    descripcion TEXT,
    imagen_ruta VARCHAR(255),
    fecha_publicacion DATE,
    CONSTRAINT CHK_AnioValido CHECK (anio >= 1990 AND anio <= YEAR(CURDATE()) + 1)
);

-- TABLA SOLICITUDES_VENTA
CREATE TABLE SOLICITUDES_VENTA (
    id_solicitud BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(150) NOT NULL,
    telefono VARCHAR(15),
    marca_auto VARCHAR(50) NOT NULL,
    modelo_auto VARCHAR(100) NOT NULL,
    anio_auto SMALLINT NOT NULL,
    precio_estimado DECIMAL(15, 2),
    descripcion_auto TEXT,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado_solicitud VARCHAR(20) DEFAULT 'Pendiente',
    CONSTRAINT UQ_CorreoCliente UNIQUE (correo_electronico)
);

-- TABLA PERSONAS_INTERESADAS
CREATE TABLE PERSONAS_INTERESADAS (
    id_interesado BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    ciudad VARCHAR(50) NOT NULL,
    id_auto_interesado BIGINT,
    CONSTRAINT FK_AutoInteresado
    FOREIGN KEY (id_auto_interesado)
    REFERENCES AUTOS_EN_VENTA(id_auto)
);

-- INSERCIÓN DE DATOS INICIALES
INSERT INTO AUTOS_EN_VENTA (marca, modelo, anio, precio_cop, kilometraje, descripcion, imagen_ruta, fecha_publicacion) VALUES
('Mazda', 'CX-30', 2024, 140000000.00, 500, 'Mazda CX-30, perfecto estado.', '../Images/CX30.jpg', CURDATE()),
('BMW', 'M3 Competition', 2023, 550000000.00, 12000, 'Deportivo de alto rendimiento.', '../Images/Bmw m3.jpg', CURDATE()),
('Audi', 'R8', 2019, 850000000.00, 25000, 'Superdeportivo, motor V10.', '../Images/Audi R8.jpg', CURDATE()),
('Ferrari', '488 pista', 2020, 2500000000.00, 1500, 'Edición especial Pista.', '../Images/488 pista.jpg', CURDATE()),
('Chevrolet', 'Corvette C8', 2021, 750000000.00, 8000, 'Motor central V8.', '../Images/Corvette C8.jpg', CURDATE()),
('Lamborghini', 'Aventador SVJ', 2018, 4000000000.00, 4500, 'Modelo SVJ, muy exclusivo.', '../Images/SCJ.jpg', CURDATE()),
('Porsche', '911 Carrera T', 2023, 1500000000.00, 3000, 'Versión ligera y deportiva.', '../Images/911 Carrera T.jpg', CURDATE()),
('Porsche', '911 GT3 RS', 2022, 2500000000.00, 1000, 'Enfocado en circuito.', '../Images/911 GT3 RS.jpg', CURDATE()),
('Volkswagen', 'Golf GTI MK8', 2025, 250000000.00, 100, 'Última generación.', '../Images/MK8.jpg', CURDATE()),
('Toyota', '4Runner', 2025, 345000000.00, 200, 'SUV con muy poco uso.', '../Images/Toyota 4Runner.jpg', CURDATE()),
('Mercedes-Benz', 'C63 AMG', 2017, 180000000.00, 35000, 'Sedán deportivo, motor V8.', '../Images/C63.jpg', CURDATE());

INSERT INTO SOLICITUDES_VENTA (nombre_completo, correo_electronico, telefono, marca_auto, modelo_auto, anio_auto, precio_estimado, descripcion_auto) VALUES
('Carlos Velez', 'carlos.v@mail.com', '3001234567', 'Ford', 'Mustang GT', 2016, 150000000.00, 'Único dueño, color rojo.'),
('Ana María Restrepo', 'ana.restrepo@mail.com', '3109876543', 'Kia', 'Sportage', 2021, 80000000.00, 'Versión full equipo, mantenimiento reciente.');

INSERT INTO PERSONAS_INTERESADAS (nombre, apellido, email, ciudad, id_auto_interesado) VALUES
('Jorge', 'Giraldo', 'jorge.g@mail.com', 'Medellín', 7),
('Luisa', 'Mora', 'luisa.m@mail.com', 'Cali', 4),
('Pedro', 'Acosta', 'pedro.a@mail.com', 'Bogotá', 2);

-- MANIPULACIÓN DE DATOS Y ESTRUCTURA
ALTER TABLE AUTOS_EN_VENTA
ADD COLUMN garantia_extendida BOOLEAN DEFAULT FALSE;

UPDATE AUTOS_EN_VENTA
SET precio_cop = precio_cop + 50000000.00
WHERE id_auto = 4;

ALTER TABLE SOLICITUDES_VENTA
MODIFY estado_solicitud VARCHAR(30);

UPDATE SOLICITUDES_VENTA
SET estado_solicitud = 'En Contacto'
WHERE correo_electronico = 'carlos.v@mail.com';

DELETE FROM AUTOS_EN_VENTA
WHERE id_auto = 3;

-- CONSULTAS AVANZADAS
SELECT
    modelo AS Modelo_Vehiculo,
    marca AS Marca,
    precio_cop AS Precio_COP,
    (precio_cop / 4000.00) AS Precio_USD_Estimado,
    (YEAR(CURDATE()) - anio) AS Antiguedad_Anios
FROM
    AUTOS_EN_VENTA
ORDER BY
    Precio_USD_Estimado DESC;

SELECT
    P.nombre,
    P.apellido,
    P.ciudad,
    A.marca AS Auto_Marca,
    A.modelo AS Auto_Modelo
FROM
    PERSONAS_INTERESADAS P
INNER JOIN
    AUTOS_EN_VENTA A
ON
    P.id_auto_interesado = A.id_auto
ORDER BY
    P.ciudad;

SELECT
    S.nombre_completo,
    S.telefono,
    S.marca_auto,
    S.estado_solicitud
FROM
    SOLICITUDES_VENTA S
INNER JOIN
    (SELECT 'En Contacto' AS estado) AS E
ON
    S.estado_solicitud = E.estado;

-- PROCEDIMIENTOS ALMACENADOS
DELIMITER $$
CREATE PROCEDURE SP_RegistrarSolicitudVenta (
    IN p_nombre VARCHAR(100),
    IN p_correo VARCHAR(150),
    IN p_telefono VARCHAR(15),
    IN p_marca VARCHAR(50),
    IN p_modelo VARCHAR(100),
    IN p_anio SMALLINT,
    IN p_precio DECIMAL(15, 2),
    IN p_descripcion TEXT
)
BEGIN
    INSERT INTO SOLICITUDES_VENTA (nombre_completo, correo_electronico, telefono, marca_auto, modelo_auto, anio_auto, precio_estimado, descripcion_auto)
    VALUES (p_nombre, p_correo, p_telefono, p_marca, p_modelo, p_anio, p_precio, p_descripcion);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE SP_ActualizarEstadoSolicitud (
    IN p_correo VARCHAR(150),
    IN p_nuevo_estado VARCHAR(30)
)
BEGIN
    UPDATE SOLICITUDES_VENTA
    SET estado_solicitud = p_nuevo_estado
    WHERE correo_electronico = p_correo;
END $$
DELIMITER ;