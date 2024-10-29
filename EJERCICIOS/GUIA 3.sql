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

--Mostrar los artículos cuyo precio sea mayor o igual que un valor que se
--envía por parámetro.
CREATE PROCEDURE SP_PRECIOS_ALTOS
@PRECIO INT = 0
AS
SELECT descripcioN 'ARTICULO', pre_unitario 'PRECIO'
FROM articulos 
WHERE pre_unitario >= @PRECIO

--b. Ingresar un artículo nuevo, verificando que la cantidad de stock que se
--pasa por parámetro sea un valor mayor a 30 unidades y menor que 100.
--Informar un error caso contrario.

CREATE PROCEDURE SP_INGRESAR_ARTICULO
@DESCRIPCION VARCHAR (50),
@STOCK_MIN INT,
@STOCK INT,
@PRE_UNITARIO INT,
@OBSERVACIONES VARCHAR(100)
AS
IF(@STOCK > 100 OR @STOCK < 30 OR @DESCRIPCION IS NULL OR @PRE_UNITARIO IS NULL)
BEGIN 
RAISERROR('DEBE INGRESAR UN STOCK ENTRE 30 Y 100', 16,1)
END 
ELSE 
BEGIN
INSERT INTO articulos (descripcion,stock_minimo, stock, pre_unitario, observaciones)
values(@DESCRIPCION,@STOCK_MIN,@STOCK,@PRE_UNITARIO,@OBSERVACIONES)

--c. Mostrar un mensaje informativo acerca de si hay que reponer o no stock
--de un artículo cuyo código sea enviado por parámetro

ALTER PROCEDURE SP_REPONER_ARTICULO
@CODIGO INT
AS
IF EXISTS(SELECT cod_articulo FROM articulos WHERE stock < stock_minimo AND cod_articulo = @CODIGO)
BEGIN SELECT 'DEBE REPONER EL ARTICULO' END
ELSE BEGIN SELECT 'NO ES NECESARIO REPONER' END
--TAMBIEN PODRÍA POR EJEMPLO PONER 1, ESO ME DEVOLVERÍA 1 SI LA CONDICIÓN SE CUMPLE Y EL EXISTS TRARÍA RESULTADOS
EXEC SP_REPONER_ARTICULO 1

--d. Actualizar el precio de los productos que tengan un precio menor a uno
--ingresado por parámetro en un porcentaje que también se envíe por
--parámetro. Si no se modifica ningún elemento informar dicha situación
CREATE PROCEDURE SP_ACTUALIZAR_PRECIO
@PRECIO INT, @PORCENTAJE DECIMAL(4,2)
AS
IF EXISTS(SELECT * FROM articulos WHERE pre_unitario < @PRECIO)
BEGIN
UPDATE articulos
SET pre_unitario = pre_unitario * @PORCENTAJE
WHERE pre_unitario < @PRECIO
SELECT 'ARTICULOS ACTUALIZADOS' 
END
ELSE BEGIN
SELECT 'NO HAY ARTICULOS PARA ACTUALIZAR'
END

--e. Mostrar el nombre del cliente al que se le realizó la primer venta en un parámetro de salida.
CREATE PROCEDURE SP_PRIMER_VENTA
@CLIENTE VARCHAR(50) OUTPUT
AS
SELECT TOP 1 @CLIENTE = C.nom_cliente + ' ' + C.ape_cliente
FROM facturas F
JOIN clientes C ON C.cod_cliente = F.cod_cliente
ORDER BY fecha ASC

DECLARE @C VARCHAR(50) 
EXEC SP_PRIMER_VENTA @C OUTPUT
SELECT @C 'CLIENTE 1ER VENTA'

--f. Realizar un select que busque el artículo cuyo nombre empiece con un
--valor enviado por parámetro y almacenar su nombre en un parámetro de
--salida. En caso que haya varios artículos ocurrirá una excepción que
--deberá ser manejada con try catch

CREATE PROCEDURE SP_ARTICULO_NOMBRE
@BUSQUEDA VARCHAR(50),
@ARTICULO VARCHAR(50) OUTPUT
AS
DECLARE @CANTIDAD INT
BEGIN TRY
SELECT @CANTIDAD = COUNT(*) FROM articulos WHERE descripcion LIKE @BUSQUEDA + '%'
IF(@CANTIDAD = 1)
BEGIN SELECT @ARTICULO = DESCRIPCION FROM articulos WHERE descripcion LIKE @BUSQUEDA + '%' END
ELSE BEGIN
RAISERROR(CASE WHEN @CANTIDAD = 0 THEN 'NO COINCIDEN ARTICULOS'
			ELSE 'COINCIDEN MAS DE 2 ARTICULOS', 16,1) 
			END TRY
BEGIN CATCH SELECT ERROR_MESSAGE() ERROR END CATCH
-----------------------------------------------------------

--Hora: una función que les devuelva la hora del sistema en el formato
--HH:MM:SS (tipo carácter de 8).
CREATE FUNCTION FN_HORA()
RETURNS CHAR(8)
AS
BEGIN
    RETURN CONVERT(CHAR(8), GETDATE(), 108);
END; 
SELECT dbo.FN_HORA();

--b. Fecha: una función que devuelva la fecha en el formato AAAMMDD (en
--carácter de 8), a partir de una fecha que le ingresa como parámetro
--(ingresa como tipo fecha).
CREATE FUNCTION FN_FECHA
(@FECHA DATE)
RETURNS CHAR(8)
BEGIN 
RETURN CONVERT(CHAR(8), @FECHA, 112)
END

SELECT DBO.FN_FECHA('2024-10-27')

--c. Dia_Habil: función que devuelve si un día es o no hábil (considere como
--días no hábiles los sábados y domingos). Debe devolver 1 (hábil), 0 (no
--hábil)
CREATE FUNCTION FN_HABIL
(@FECHA DATE)
RETURNS INT
BEGIN
DECLARE @DIA VARCHAR(10)
SET @DIA = DATENAME(WEEKDAY,@FECHA)
RETURN CASE WHEN LOWER(@DIA) = 'domingo' THEN 0
			WHEN LOWER(@DIA) = 'sábado' THEN 0
			ELSE 1 END
END

--7. Modifique la f(x) 1.c, considerando solo como día no hábil el domingo.
ALTER FUNCTION FN_HABIL
(@FECHA DATE)
RETURNS INT
BEGIN
DECLARE @DIA VARCHAR(10)
SET @DIA = DATENAME(WEEKDAY,@FECHA)
RETURN CASE WHEN LOWER(@DIA) = 'domingo' THEN 0
			ELSE 1 END
END

--10. Programar funciones que permitan realizar las siguientes tareas:
--a. Devolver una cadena de caracteres compuesto por los siguientes datos:
--Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio, de un
--determinado cliente, que se puede informar por codigo de cliente o
--email.


--b. Devolver todos los artículos, se envía un parámetro que permite ordenar
--el resultado por el campo precio de manera ascendente (‘A’), o
--descendente (‘D’).

--c. Crear una función que devuelva el precio al que quedaría un artículo en
--caso de aplicar un porcentaje de aumento pasado por parámetro.























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

------------------------------------------------------------------------------------------
-- Crear una función que devuelva el codigo del articulo con mayor stock 
create function f_ofertas_articulos
(@precioInf int = 0, @precioSup int = 1000000)
returns int
as
begin
declare @resultado int
Select top 1 @resultado = cod_articulo
from articulos
WHERE pre_unitario between @precioInf and @precioSup
order by stock desc
return @resultado
end;

select dbo.f_ofertas_articulos(1500, 4000) 'Cod Articulo'