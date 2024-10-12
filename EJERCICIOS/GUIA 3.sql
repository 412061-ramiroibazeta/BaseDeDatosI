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
--de artículos o no.select @codigo 'Codigo', @stock 'Stock', @stockMinimo 'Stock Minimo', mensaje = case 																	when (@stock is null OR @stockMinimo is null) then 'Se debe reponer el articulo'																	else 'La cantidad de articulos es suficiente'																	END--Modificar el ejercicio 1 agregando una variable más donde se almacene el precio
--del artículo. En caso que el precio sea menor a $500, aplicarle un incremento del
--10%. En caso de que el precio sea mayor a $500 notificar dicha situación y
--mostrar el precio del artículo.

declare @codigo int, @stock int, @stockMinimo int, @precio int
set @codigo = 3

Select @stock = stock, @stockMinimo = stock_minimo, @precio = pre_unitario
from articulos
WHERE cod_articulo = @codigo

select @codigo 'Codigo', @stock 'Stock', @stockMinimo 'Stock Minimo', mensaje = case 																	when (@stock is null OR @stockMinimo is null) then 'Se debe reponer el articulo'																	else 'La cantidad de articulos es suficiente'																	END ,
																	mensaje2 = case 
																	when @precio < 500 then @precio*1.1
																	else @precio
																	END


