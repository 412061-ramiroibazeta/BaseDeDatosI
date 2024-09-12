-- Seleccionar todos los clientes que no hayan comprado el año pasado
Select * 
FROM clientes c 
WHERE c.cod_cliente not in ( SELECT F2.cod_cliente FROM facturas F2 WHERE YEAR(F2.fecha) = YEAR(GETDATE())-1)

-- Con ANY : Listar todos los clientes que compraron un producto menor a 10
select * from clientes c WHERE c.cod_cliente = any (select cod_cliente from facturas f, detalle_facturas df where df.pre_unitario < 10)

select * from clientes c WHERE 10 < any (select df.pre_unitario 
										from facturas f 
										join detalle_facturas df ON df.nro_factura = f.nro_factura
										where f.cod_cliente = c.cod_cliente)

-- Con ALL : Listar todos los clientes que fueron atendidos por el vendedor numero 3
Select * from clientes c
Where 3 = all (select cod_vendedor 
				from facturas f 
				where c.cod_cliente = f.cod_cliente
				and (select count(ff.cod_vendedor) from facturas ff) > 0) --referencia externa -- Acá da problemas porque al no tener vendedor, en las facturas, el comparador da siempre true pues no logra llegar a false con una comparación

select * from clientes c
where 4 = all (select f.cod_vendedor 
			   from facturas f 
			   where f.cod_cliente = c.cod_cliente)

          AND 0 <  (
			   SELECT count(*)
		       FROM facturas f
               WHERE f.cod_cliente = c.cod_cliente
               );

-- Emitir un listado de los articulos que no fueron vendidos en este año.
-- En ese listado, solo incluir aquellos cuyo precio unitario del articulo oscile entre 1000 y 2000.
Select * 
from articulos a
Where a.pre_unitario between 1000 and 2000
and a.cod_articulo NOT IN ( Select df.cod_articulo 
							from detalle_facturas df 
							Join facturas f on df.nro_factura = f.nro_factura
							Where year(f.fecha) = year(getdate()))

-- Se debería listar en la consulta principal, los vendedores con sus ventas totales agrupado por vendedor(codigo y nombre) y 
-- como condición es que su venta total sea superior al promedio general de ventas.

--Select v.nom_vendedor, v.cod_vendedor, count(*)
--FROM facturas f
--JOIN vendedores v on f.cod_vendedor = v.cod_vendedor
--WHERE (Select 
--GROUP BY v.nom_vendedor, v.cod_vendedor

--- Se quiere saber que clientes ni vinieron entre el 12-12-2015 y 13-7-2020
SET DATEFORMAT DMY
Select c.cod_cliente 'Codigo', c.nom_cliente 'Nombre'
FROM clientes C
WHERE c.cod_cliente NOT IN (
							select f.cod_cliente
							From facturas f
							Where f.fecha between '12-12-2015' AND '13-07-2020')

--- Listar los datos de las facturas de los clientes que solo vienen a comprar en febrero es decir que todas las veces que compraron fueron en febrero y no en otro mes.

Select c.cod_cliente 'Codigo', c.nom_cliente 'Nombre'
From clientes c
JOIN facturas f1 ON f1.cod_cliente = c.cod_cliente
Where 2 = all (select Month(f.fecha) from facturas f where c.cod_cliente = f.cod_cliente )

--- Realizar un listado de número de factura, fecha, cliente, articulo e importe para los casos en que al menoss uno de los importes de esa factura sea menor a 3000

Select f.nro_factura 'Nro' , f.fecha 'Fecha', f.cod_cliente 'Cliente', SUM(df.pre_unitario*df.cantidad) 'Importe'
FROM facturas f
JOIN detalle_facturas df on f.nro_factura = df.nro_factura
JOIN clientes c on c.cod_cliente = f.cod_cliente
JOIN articulos a on df.cod_articulo = a.cod_articulo
WHERE 3000 > any (
					Select SUM(df1.pre_unitario*df1.cantidad) from detalle_facturas df1 WHERE df1.nro_factura = df.nro_factura)
GROUP BY f.nro_factura , f.fecha, f.cod_cliente