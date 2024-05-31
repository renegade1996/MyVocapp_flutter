CREATE DATABASE pi_diccionarios
CHARSET utf8mb4
COLLATE utf8mb4_spanish2_ci;

USE pi_diccionarios;

CREATE TABLE Usuarios (
    idUsuario INT AUTO_INCREMENT,
    nombreUsuario VARCHAR(20) NOT NULL,
    claveUsuario VARCHAR(20) NOT NULL,
    PRIMARY KEY (idUsuario)
);

CREATE TABLE Diccionarios (
    idDiccionario INT AUTO_INCREMENT,
    nombreDiccionario VARCHAR(85) NOT NULL,
    idUsuarioFK INT NOT NULL,
    PRIMARY KEY (idDiccionario),
    FOREIGN KEY (idUsuarioFK) REFERENCES Usuarios(idUsuario)
);

CREATE TABLE Entradas (
    idEntrada INT AUTO_INCREMENT,
    tituloEntrada VARCHAR(150) NOT NULL,
    descripcionEntrada VARCHAR(150),
    ejemploEntrada VARCHAR(150),
    trucoEntrada VARCHAR(150),
    tipoEntrada BOOLEAN,
    idDiccionarioFK INT NOT NULL,
    PRIMARY KEY (idEntrada),
    FOREIGN KEY (idDiccionarioFK) REFERENCES Diccionarios(idDiccionario)
);

-- usuario con permisos de datos sobre todas las tablas
CREATE USER 'userPI'@'localhost' IDENTIFIED BY 'Studium2024;';
GRANT SELECT, INSERT, DELETE, UPDATE ON pi_diccionarios.* TO 'userPI'@'localhost';
FLUSH PRIVILEGES;

