-- HAVING 
select count(cod_articulo) "cant. art", stock_minimo
from articulos
group by stock_minimo
having count(cod_articulo) > 1


--- Crear una vista
create view vis_stock_art
as select count(cod_articulo) "cant. art", stock_minimo
from articulos
group by stock_minimo
having count(cod_articulo) > 1

-- Consultar Vista
select * from vis_stock_art

-- Crear tabla temporal
CREATE TABLE #EjemploTablaTemp (
    ID INT PRIMARY KEY,
    Nombre NVARCHAR(50),
    Edad INT
);

-- Agregamos un campo
INSERT INTO #EjemploTablaTemp (ID, Nombre, Edad)
VALUES (1, 'Damian', 44)

-- Consultamos
Select * from  #EjemploTablaTemp