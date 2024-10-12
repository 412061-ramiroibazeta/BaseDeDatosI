CREATE DATABASE Inmobiliaria
GO
USE Inmobiliaria
GO

CREATE TABLE Ubicacion (
    id INT,
    lugar VARCHAR(100),
    CONSTRAINT PK_Ubicacion PRIMARY KEY (Id)
);

CREATE TABLE Inmuebles (
    idInmueble INT,
    tipoInmueble VARCHAR(50),
    superficie DECIMAL(10,2),
    codUbicacion INT,
    CONSTRAINT PK_Inmuebles PRIMARY KEY (idInmueble),
    CONSTRAINT FK_Inmuebles_Ubicacion FOREIGN KEY (codUbicacion) 
	REFERENCES Ubicacion(Id)
);

CREATE TABLE Vendedores (
    idVendedor INT,
    apellido VARCHAR(100),
    nombre VARCHAR(100),
    edad INT,
    CONSTRAINT PK_Vendedores PRIMARY KEY (idVendedor)
);

CREATE TABLE Transacciones (
    idTransaccion INT,
    fechaTransaccion DATE,
    idVendedor INT,
    tipoOperacion VARCHAR(50),
    idInmueble INT,
    ValorTransaccion DECIMAL(18,2),
    CONSTRAINT PK_Transacciones PRIMARY KEY (idTransaccion),
    CONSTRAINT FK_Transacciones_Vendedores FOREIGN KEY (idVendedor) REFERENCES Vendedores(idVendedor),
    CONSTRAINT FK_Transacciones_Inmuebles FOREIGN KEY (idInmueble) REFERENCES Inmuebles(idInmueble)
);

