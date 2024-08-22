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

--

SELECT 
v.nom_vendedor + ' ' + v.ape_vendedor 'Nombre del vendedor',
f.nro_factura 'Número de factura',
f.fecha 'Fecha' 
FROM vendedores v 
JOIN facturas f ON v.cod_vendedor = f.cod_vendedor
WHERE YEAR(f.fecha) = YEAR(getdate()) 

-- 

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

-- VENDEDORES QUE HAN VENDIDO MÁS DE 25 VENTAS EN 2024

Select v.nom_vendedor 'Nombre', v.ape_vendedor 'Apellido', count(*) 'Total de ventas'
From vendedores v
JOIN facturas f ON f.cod_vendedor = v.cod_vendedor
WHERE year(f.fecha) = 2024
GROUP BY v.nom_vendedor, v.ape_vendedor
HAVING COUNT(*) > 25

-- 5 artículos más vendidos

-- 

SELECT SUM(df.cantidad), a.descripcion 
From facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a on df.cod_articulo = a.cod_articulo
WHERE YEAR(f.fecha) = 2024
GROUP BY a.descripcion, a.stock_minimo
HAVING SUM(df.cantidad) < a.stock_minimo

--
Select c.nom_cliente 'Nombre', count (*) 'Compras', sum(df.cantidad * df.pre_unitario) 'Importe'
FROM facturas f
JOIN clientes c ON f.cod_vendedor = c.cod_cliente
JOIN detalle_facturas df on f.nro_factura = df.nro_factura
WHERE YEAR(f.fecha) = 2024
GROUP BY c.nom_cliente
HAVING count(*) > 30 or sum(df.cantidad * df.pre_unitario) > 800000
order by 2

-- HACER EJERCICIOS DE PDF TUP_2C_BDI_GUIA_Repaso_Consultas