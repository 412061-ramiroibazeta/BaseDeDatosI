declare @cant_clientes int, @ultima_compra date;

select @cant_clientes = count(*) from clientes
select @ultima_compra = max(fecha) from facturas

select @cant_clientes 'Cantidad de clientes', @ultima_compra 'Ultima Compra'

----------------------------------------------------------------- GUIA 3 ---------------------------------------------------------------------
--1) Declarar 3 variables que se llamen codigo, stock y stockMinimo
--respectivamente. A la variable codigo setearle un valor. Las variables stock y
--stockMinimo almacenarán el resultado de las columnas de la tabla artículos
--stock y stockMinimo respectivamente filtradas por el código que se
--corresponda con la variable codigo

declare @codigo int, @stock int, @stockMinimo int
set @codigo = 3

Select @stock = stock, @stockMinimo = stock_minimo 
from articulos
WHERE cod_articulo = @codigo

-- select @codigo 'Codigo', @stock 'Stock', @stockMinimo 'Stock Minimo'

--Utilizando el punto anterior, verificar si la variable stock o stockMinimo tienen
--algún valor. Mostrar un mensaje indicando si es necesario realizar reposición
--de artículos o no.

select @codigo 'Codigo', @stock 'Stock', @stockMinimo 'Stock Minimo', mensaje = case 
																	when (@stock is null OR @stockMinimo is null) then 'Se debe reponer el articulo'
																	else 'La cantidad de articulos es suficiente'
																	END

--Modificar el ejercicio 1 agregando una variable más donde se almacene el precio
--del artículo. En caso que el precio sea menor a $500, aplicarle un incremento del
--10%. En caso de que el precio sea mayor a $500 notificar dicha situación y
--mostrar el precio del artículo.

declare @codigo int, @stock int, @stockMinimo int, @precio int
set @codigo = 3

Select @stock = stock, @stockMinimo = stock_minimo, @precio = pre_unitario
from articulos
WHERE cod_articulo = @codigo

select @codigo 'Codigo', @stock 'Stock', @stockMinimo 'Stock Minimo', mensaje = case 
																	when (@stock is null OR @stockMinimo is null) then 'Se debe reponer el articulo'
																	else 'La cantidad de articulos es suficiente'
																	END ,
																	mensaje2 = case 
																	when @precio < 500 then @precio*1.1
																	else @precio
																	END

--Declarar dos variables enteras, y mostrar la suma de todos los números
--comprendidos entre ellos. En caso de ser ambos números iguales mostrar un
--mensaje informando dicha situación 
DECLARE @num1 INT = 5;
DECLARE @num2 INT = 10;
DECLARE @suma INT = 0;
DECLARE @menor INT;
DECLARE @mayor INT;

IF @num1 = @num2
BEGIN
    SELECT 'Ambos números son iguales'
END
ELSE
BEGIN
	SET @menor = CASE WHEN @num1 < @num2 THEN @num1 ELSE @num2 END;
	SET @mayor = CASE WHEN @num1 > @num2 THEN @num1 ELSE @num2 END;

		WHILE @menor <= @mayor
		BEGIN
			SET @suma = @suma + @menor;
			SET @menor = @menor + 1;
		END
    
	SELECT @suma AS SumaTotal;
END

--Mostrar nombre y precio de todos los artículos. Mostrar en una tercer columna la leyenda 
--‘Muy caro’ para precios mayores a $500, 
--‘Accesible’ para precios entre $300 y $500, 
--‘Barato’ para precios entre $100 y $300 y 
--‘Regalado’ para precios menores a $100.

SELECT a.descripcion, a.pre_unitario, CASE WHEN a.pre_unitario > 500 THEN 'Muy caro'
										   WHEN a.pre_unitario between 300 and 500 THEN 'Accesible'
										   WHEN a.pre_unitario between 100 and 300 THEN 'Barato'
										   WHEN a.pre_unitario < 100 THEN 'Regalado' END 'Leyenda'
FROM articulos a
Order by a.pre_unitario desc


-- SP's
--a. Detalle_Ventas: liste la fecha, la factura, el vendedor, el cliente, el
--artículo, cantidad e importe. Este SP recibirá como parámetros de E un
--rango de fechas.
Create procedure detalle_ventas
@fecha1 Datetime,
@fecha2 Datetime
AS
BEGIN
SELECT  f.nro_factura 'Factura',
		f.fecha 'Fecha',
		f.cod_vendedor 'Cod Vendedor',
		f.cod_cliente 'Cod Cliente',
		df.cod_articulo 'Cod Articulo',
		df.cantidad 'Cantidad',
		df.cantidad * df.pre_unitario 'Importe'
FROM detalle_facturas df
JOIN Facturas f ON df.nro_factura = f.nro_factura
WHERE f.fecha between @fecha1 AND @fecha2
END

--b. CantidadArt_Cli : este SP me debe devolver la cantidad de artículos o
--clientes (según se pida) que existen en la empresa.
CREATE PROCEDURE CantidadArt_cli 
@tabla Varchar(10)
AS
SET @tabla = LOWER(@tabla);

IF @tabla = 'articulos' 
    BEGIN
        SELECT COUNT(*) 'Cantidad de articulos'
        FROM articulos
    END
ELSE IF @tabla = 'clientes' 
    BEGIN
        SELECT COUNT(*) 'Cantidad de clientes'
        FROM clientes
    END
ELSE 
    BEGIN
        SELECT 'Ingresar "articulos" o "clientes"' 'Mensaje'
    END

--c. INS_Vendedor: Cree un SP que le permita insertar registros en la tabla
--vendedores.
CREATE PROCEDURE INS_VENDEDOR
@ape_vendedor varchar(50), @nom_vendedor varchar(50), @calle varchar(50), @altura INT, @cod_barrio int, @nro_tel int, @mail varchar(50), @fec_nac datetime
AS
IF(@ape_vendedor is null or @nom_vendedor is null or @calle is null or @altura is null or @cod_barrio is null)
BEGIN select 'Faltan datos del vendedor' return END
ELSE
BEGIN
insert into vendedores (ape_vendedor, nom_vendedor, calle, altura, cod_barrio, nro_tel, [e-mail], fec_nac) values (@ape_vendedor, @nom_vendedor,@calle, @altura,@cod_barrio,@nro_tel,@mail,@fec_nac);
END

--d. UPD_Vendedor: cree un SP que le permita modificar un vendedor cargado.
CREATE PROCEDURE UPD_VENDEDOR
@cod_vendedor int, @ape_vendedor varchar(50), @nom_vendedor varchar(50), @calle varchar(50), @altura INT, @cod_barrio int, @nro_tel int, @mail varchar(50), @fec_nac datetime
AS
IF(@ape_vendedor is null or @nom_vendedor is null or @calle is null or @altura is null or @cod_barrio is null or @cod_vendedor<1)
BEGIN select 'Faltan datos del vendedor' return END
ELSE
BEGIN
update vendedores 
set ape_vendedor = @ape_vendedor, 
nom_vendedor = @nom_vendedor, 
calle = @calle,
altura = @altura,
cod_barrio = @cod_barrio,
nro_tel = @nro_tel, 
[e-mail] = @nro_tel, 
fec_nac = @fec_nac
WHERE cod_vendedor = @cod_vendedor
END























-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE sp_articulos_info 
--@cod_articulo int = 0
--AS 
--SELECT a.cod_articulo 'Codigo',
--a.descripcion 'Articulo',
--a.stock 'Stock',
--a.pre_unitario 'Precio'  
--FROM articulos a WHERE a.cod_articulo = @cod_articulo

--EXEC sp_articulos_info 2

--ALTER PROCEDURE sp_articulos_stock 
--@cod_articulo int,
--@stock int output
--AS 
--SELECT @stock = stock
--FROM articulos a 
--WHERE cod_articulo = @cod_articulo


--declare @s int;
--exec sp_articulos_stock 5, @s output
--select @s

-- Realizar un sp que me diga como parametro de salida superen un precio ingresado
-- como parametro de entrada

CREATE PROCEDURE sp_articulos_mayores
@precio int, @cantidad int output
as
select @cantidad = count(a.cod_articulo) from articulos a where a.pre_unitario > @precio

declare @c int;
exec sp_articulos_mayores 100, @c output
select @c


-- FUncion que devuelva la edad desde una fecha

create function f_edad_validado
(@nacimiento datetime = null)
returns int
as 
begin
declare @edad int
set @edad = datediff(year,@nacimiento,getdate())
if (month (@nacimiento) > month(getdate()) 
or (month (@nacimiento) = month (getdate()) and day(@nacimiento) > day(getdate())))
begin
set @edad = @edad -1
end
return @edad
end;

select dbo.f_edad_validado('12/12/2000') as 'Edad';