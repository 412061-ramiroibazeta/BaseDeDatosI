--1.3.3 Se quiere saber la fecha de la primera venta, la cantidad total vendida y el
--importe total vendido por vendedor para los casos en que el promedio de
--la cantidad vendida sea inferior o igual a 56.

Select v.nom_vendedor + ' ' + v.ape_vendedor 'Vendedor',
MIN(f.fecha) 'Primera venta',
SUM(df.cantidad) 'Cantidad total',
SUM(df.cantidad * df.Pre_unitario) 'Importe total',
AVG(df.cantidad) 'Promedio Cantidad'
FROM Facturas f
JOIN Vendedores v on f.cod_vendedor = v.cod_vendedor
JOIN detalle_facturas df on df.nro_factura = f.nro_factura
GROUP BY v.nom_vendedor + ' ' + v.ape_vendedor
HAVING AVG(df.cantidad) <= 56

--Desde la administración se solicita un reporte que muestre el precio
--promedio, el importe total y el promedio del importe vendido por artículo
--que no comiencen con “c”, que su cantidad total vendida sea 100 o más o
--que ese importe total vendido sea superior a 700

Select a.descripcion 'Articulo',
AVG(df.pre_unitario) 'Promedio' ,
SUM(df.cantidad * df.pre_unitario) 'Importe total',
AVG(df.cantidad * df.pre_unitario) 'Importe promedio',
SUM(df.cantidad) 'Cantidad'
FROM Facturas f
JOIN detalle_facturas df on df.nro_factura = f.nro_factura
JOIN articulos a on a.cod_articulo = df.cod_articulo
WHERE a.descripcion not like 'c%'
Group By a.descripcion
HAving SUM(df.cantidad) >= 100 or SUM(df.cantidad * df.pre_unitario) > 700

--¿Cuánto le vendió cada vendedor a cada cliente el año pasado siempre
--que la cantidad de facturas emitidas (por cada vendedor a cada cliente)
--sea menor a 5?

Select v.nom_vendedor + ' ' + v.ape_vendedor 'Vendedor',
c.nom_cliente + ' ' + c.ape_cliente 'Cliente',
COUNT(f.nro_factura) 'Cantidad de ventas'
FROM Facturas f
JOIN Vendedores v on f.cod_vendedor = v.cod_vendedor
JOIN clientes c on c.cod_cliente = f.cod_cliente
WHERE YEAR(f.fecha) = YEAR(GETDATE())-1
GROUP BY v.nom_vendedor + ' ' + v.ape_vendedor, c.nom_cliente + ' ' + c.ape_cliente
HAVING COUNT(f.nro_factura) < 5

--Emitir un listado donde se muestren qué artículos, clientes y vendedores hay en
--la empresa. Determine los campos a mostrar y su ordenamiento.

Select a.descripcion 'Empresa', 'Articulo' Origen
FROM articulos a
UNION 
Select v.nom_vendedor + ' ' + v.ape_vendedor, 'Vendedor' Origen
FROM vendedores v
UNION
Select c.nom_cliente + ' ' + c.ape_cliente 'Empresa', 'Cliente' Origen
FROM clientes c
ORDER BY 2