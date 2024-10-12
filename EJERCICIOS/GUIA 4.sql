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