---- Creación de la base de datos
--CREATE DATABASE db_clinica_veterinaria;
--GO

--USE db_clinica_veterinaria;
--GO

---- Creación de la tabla Barrios
--CREATE TABLE Barrios (
--    id_barrio INT PRIMARY KEY,
--    barrio VARCHAR(100)
--);

---- Creación de la tabla Dueños
--CREATE TABLE Dueños (
--    id_dueño INT PRIMARY KEY,
--    nombre VARCHAR(100),
--    apellido VARCHAR(100),
--    calle VARCHAR(100),
--    altura INT,
--    id_barrio INT,
--    telefono VARCHAR(20),
--    FOREIGN KEY (id_barrio) REFERENCES Barrios(id_barrio)
--);

---- Creación de la tabla Tipos
--CREATE TABLE Tipos (
--    id_tipo INT PRIMARY KEY,
--    tipo VARCHAR(100)
--);

---- Creación de la tabla Razas
--CREATE TABLE Razas (
--    id_raza INT PRIMARY KEY,
--    raza VARCHAR(100)
--);

---- Creación de la tabla Mascotas
--CREATE TABLE Mascotas (
--    id_mascota INT PRIMARY KEY,
--    nombre VARCHAR(100),
--    fec_nac DATE,
--    id_tipo INT,
--    id_raza INT,
--    id_dueño INT,
--    FOREIGN KEY (id_tipo) REFERENCES Tipos(id_tipo),
--    FOREIGN KEY (id_raza) REFERENCES Razas(id_raza),
--    FOREIGN KEY (id_dueño) REFERENCES Dueños(id_dueño)
--);

---- Creación de la tabla Médicos
--CREATE TABLE Medicos (
--    id_medico INT PRIMARY KEY,
--    nombre VARCHAR(100),
--    apellido VARCHAR(100),
--    fec_ingreso DATE,
--    matricula INT,
--    id_barrio INT,
--    telefono VARCHAR(20),
--    FOREIGN KEY (id_barrio) REFERENCES Barrios(id_barrio)
--);

---- Creación de la tabla Consultas
--CREATE TABLE Consultas (
--    id_consulta INT PRIMARY KEY,
--    id_medico INT,
--    id_mascota INT,
--    fecha DATE,
--    detalle_consulta VARCHAR(255),
--    importe DECIMAL(10, 2),
--    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico),
--    FOREIGN KEY (id_mascota) REFERENCES Mascotas(id_mascota)
--);

---- Inserts en la tabla Barrios
--INSERT INTO Barrios (id_barrio, barrio) VALUES 
--(1, 'Centro'), 
--(2, 'Norte'), 
--(3, 'Sur');

---- Inserts en la tabla Dueños
--INSERT INTO Dueños (id_dueño, nombre, apellido, calle, altura, id_barrio, telefono) VALUES 
--(1, 'Juan', 'Pérez', 'Av. Principal', 123, 1, '123456789'),
--(2, 'Ana', 'García', 'Calle Secundaria', 456, 2, '987654321');

---- Inserts en la tabla Tipos
--INSERT INTO Tipos (id_tipo, tipo) VALUES 
--(1, 'Perro'), 
--(2, 'Gato');

---- Inserts en la tabla Razas
--INSERT INTO Razas (id_raza, raza) VALUES 
--(1, 'Golden Retriever'), 
--(2, 'Siames');

---- Inserts en la tabla Mascotas
--INSERT INTO Mascotas (id_mascota, nombre, fec_nac, id_tipo, id_raza, id_dueño) VALUES 
--(1, 'Max', '2018-05-20', 1, 1, 1),
--(2, 'Milo', '2019-08-15', 2, 2, 2);

---- Inserts en la tabla Médicos
--INSERT INTO Medicos (id_medico, nombre, apellido, fec_ingreso, matricula, id_barrio, telefono) VALUES 
--(1, 'Carlos', 'Sánchez', '2020-03-01', 123456, 1, '456789123'),
--(2, 'Laura', 'Martínez', '2019-07-10', 789012, 2, '654321987');

---- Inserts en la tabla Consultas
--INSERT INTO Consultas (id_consulta, id_medico, id_mascota, fecha, detalle_consulta, importe) VALUES 
--(1, 1, 1, '2023-01-10', 'Chequeo general', 2000.00),
--(2, 2, 2, '2023-02-20', 'Vacunación', 1500.00);
