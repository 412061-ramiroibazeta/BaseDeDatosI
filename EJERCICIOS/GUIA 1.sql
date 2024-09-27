-- 1

SELECT 
f.nro_factura 'Numero de factura',
c.nom_cliente + ' ' + c.ape_cliente 'Nombre del cliente',
v.nom_vendedor + ' ' + v.ape_vendedor 'Nombre del vendedor',
f.fecha 'Fecha'
FROM facturas f
JOIN clientes c on c.cod_cliente = f.cod_cliente
JOIN vendedores v on v.cod_vendedor = f.cod_vendedor
WHERE year(f.fecha) in (2010, 2017, 2018, 2022) 
order by f.fecha asc

-- 2

SELECT 
v.nom_vendedor + ' ' + v.ape_vendedor 'Nombre del vendedor',
f.nro_factura 'Número de factura',
f.fecha 'Fecha' 
FROM vendedores v 
JOIN facturas f ON v.cod_vendedor = f.cod_vendedor
WHERE YEAR(f.fecha) = YEAR(getdate()) 

-- 3

SELECT 
f.nro_factura 'Numero de factura',
c.nom_cliente + ' ' + c.ape_cliente 'Nombre del cliente',
v.nom_vendedor + ' ' + v.ape_vendedor 'Nombre del vendedor',
cast(f.fecha as date) 'Fecha',
datename(WEEKDAY, f.fecha) 'Día',
floor(df.cantidad * df.pre_unitario) 'Importe' -- convert(int,(df.cantidad * df.pre_unitario))
FROM facturas f
JOIN clientes c on c.cod_cliente = f.cod_cliente
JOIN vendedores v on v.cod_vendedor = f.cod_vendedor
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a ON df.cod_articulo = a.cod_articulo
WHERE year(f.fecha) in (2016, 2020) 
AND month(f.fecha) in (2,3)
AND a.descripcion like '[a-m]%'

-- 4

Select *
FROM clientes c
JOIN facturas f on c.cod_cliente = f.cod_cliente
JOIN vendedores v on f.cod_vendedor = v.cod_vendedor
JOIN barrios b on v.cod_barrio = b.cod_barrio
WHERE c.nom_cliente like 'C%'
AND c.ape_cliente like '%z'
AND (b.barrio NOT LIKE '%[n-p]%'
OR (c.[e-mail] is not null or c.nro_tel is not null))
AND ((year(getdate()) - year(v.fec_nac) >= 50 
OR LEN(b.barrio) >= 5))

-- 5

SELECT 
v.nom_vendedor + ' ' + v.ape_vendedor 'Nombre del vendedor',
CAST(v.fec_nac AS DATE) 'Fecha de nacimiento',
CAST(f.fecha AS DATE)
FROM VENDEDORES V
JOIN facturas f ON v.cod_vendedor = f.cod_vendedor
WHERE MONTH(V.fec_nac) > (MONTH(GETDATE())+1)
AND MONTH(V.fec_nac) BETWEEN 1990 AND 1999
AND MONTH(f.fecha) = (MONTH(GETDATE())-1)

-- 6

SELECT 
a.descripcion 'Nombre',
a.pre_unitario 'Precio actual',
df.pre_unitario 'Precio de venta',
a.observaciones 'Observaciones',
a.stock 'Stock',
a.stock_minimo 'Stock mínimo'
FROM FACTURAS f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a ON df.cod_articulo = a.cod_articulo
WHERE 
DAY(f.fecha) BETWEEN 1 AND 10
AND YEAR(f.fecha) = YEAR(getdate())
AND df.pre_unitario < a.pre_unitario
AND a.observaciones is not null
AND a.stock_minimo <= a.stock

-- 7

SELECT 
a.descripcion 'Nombre',
a.pre_unitario 'Precio actual',
a.observaciones 'Observaciones',
a.stock_minimo 'Stock mínimo'
FROM articulos a
WHERE 
a.pre_unitario < 20
AND a.stock_minimo > 10
AND a.descripcion NOT LIKE '[p,r,v]%'
AND a.descripcion NOT LIKE '%[h,j,m]%'

-- 8

SELECT 
a.descripcion 'Nombre',
a.pre_unitario 'Precio actual',
df.pre_unitario 'Precio de venta',
a.observaciones 'Observaciones',
a.stock 'Stock',
a.stock_minimo 'Stock mínimo'
FROM FACTURAS f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a ON df.cod_articulo = a.cod_articulo
JOIN vendedores v on v.cod_vendedor = f.cod_vendedor
WHERE 
df.pre_unitario NOT BETWEEN 100 AND 500
AND MONTH(v.fec_nac) IN (2,4,5,9)

-- 9 

SELECT DISTINCT
f.nro_factura 'Factrura',
a.descripcion 'Nombre',
df.cantidad 'Cantidad',
(df.pre_unitario * df.cantidad) 'Importe'
FROM FACTURAS f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a ON df.cod_articulo = a.cod_articulo
JOIN vendedores v on v.cod_vendedor = f.cod_vendedor
WHERE 
f.nro_factura NOT BETWEEN 17 AND 136
ORDER BY 2,3

-- 10

SELECT 
a.descripcion 'Nombre',
a.pre_unitario 'Precio actual',
df.pre_unitario 'Precio de venta',
a.observaciones 'Observaciones',
(((a.pre_unitario - df.pre_unitario)/a.pre_unitario)/100) + '%' 'Porcentaje de incremento'
FROM FACTURAS f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a ON df.cod_articulo = a.cod_articulo
JOIN vendedores v on v.cod_vendedor = f.cod_vendedor
WHERE 
YEAR(f.fecha) = 2021
AND df.pre_unitario < 300
AND YEAR(getdate()) - YEAR(v.fec_nac) < 35

-- VENDEDORES QUE HAN VENDIDO MÁS DE 25 VENTAS EN 2024

Select v.nom_vendedor 'Nombre', v.ape_vendedor 'Apellido', count(*) 'Total de ventas'
From vendedores v
JOIN facturas f ON f.cod_vendedor = v.cod_vendedor
WHERE year(f.fecha) = 2024
GROUP BY v.nom_vendedor, v.ape_vendedor
HAVING COUNT(*) > 25

-- 5 artículos más vendidos

--
Select c.nom_cliente 'Nombre', count (*) 'Compras', sum(df.cantidad * df.pre_unitario) 'Importe'
FROM facturas f
JOIN clientes c ON f.cod_vendedor = c.cod_cliente
JOIN detalle_facturas df on f.nro_factura = df.nro_factura
WHERE YEAR(f.fecha) = 2024
GROUP BY c.nom_cliente
HAVING count(*) > 30 or sum(df.cantidad * df.pre_unitario) > 800000
order by 2

-----------------------------------------------CLASE 22/08-------------------------------------------------

-- Calcular el total facturado por cada vendedor y a cada cliente el año pasado ordenado por vendedor primero y luego por cliente

SELECT SUM(df.pre_unitario * df.cantidad), 
v.nom_vendedor 'Nombre de vendedor', 
c.nom_cliente 'Nombre del cliente'
FROM facturas f
JOIN vendedores v ON f.cod_vendedor = v.cod_vendedor 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN clientes c on f.cod_cliente = c.cod_cliente
WHERE YEAR(f.fecha) = YEAR(getdate())-1
GROUP BY v.nom_vendedor, c.nom_cliente
ORDER BY 2,3

-- Granuralidad de los datos - BUSCAR INFO

-- 2 - Se necesita un listado que informe sobre el monto(individual por producto) máximo, mínimo y total que gastó en esta librería cada cliente el año pasado, pero solo donde el importe total gastado por esos clientes este entre 50000 y 90000

SELECT
c.nom_cliente 'Nombre del cliente',
MIN(df.pre_unitario) 'Mínimo',
MAX(df.pre_unitario) 'Máximo',
SUM(df.pre_unitario * df.cantidad) 'Total'
FROM Facturas f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN clientes c on f.cod_cliente = c.cod_cliente
WHERE YEAR(f.fecha) = YEAR(getdate())-1
GROUP BY c.nom_cliente
HAVING SUM(df.pre_unitario * df.cantidad) BETWEEN 50000 AND 90000

--  FUNCIONES INCORPORADAS

-- MATEMATICAS

-- Desde la administración se solicita un reporte que muestre el precio promedio, el importe total y el promedio del importe vendido por articulo que no comience con 'c', 
--y que ese importe total vendido sea superior a 20000. Redondear promedios hacia abajo e importes hacia arriba

SELECT
a.descripcion,
FLOOR(avg(a.pre_unitario)) 'Promedio',
CEILING(SUM(df.cantidad * a.pre_unitario)) 'Importe total',
CEILING(AVG(df.cantidad * a.pre_unitario)) 'Promedio Total'
FROM Facturas f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a on a.cod_articulo = df.cod_articulo
WHERE a.descripcion not like 'c%'
GROUP BY a.descripcion
HAVING SUM(a.pre_unitario * df.cantidad) > 20000

-- FUNCIONES FECHA/HORA

SELECT 
SUM(df.pre_unitario * df.cantidad), 
v.nom_vendedor 'Nombre de vendedor',
c.nom_cliente 'Nombre del cliente',
DATENAME(weekday,f.fecha) 'Día de la venta',
DATENAME(year,f.fecha) 'Año'
FROM facturas f
JOIN vendedores v ON f.cod_vendedor = v.cod_vendedor 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN clientes c on f.cod_cliente = c.cod_cliente
GROUP BY v.nom_vendedor, c.nom_cliente, DATENAME(weekday,f.fecha), DATENAME(year,f.fecha)
ORDER BY DATENAME(weekday,f.fecha)
