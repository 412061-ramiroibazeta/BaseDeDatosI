------------------------------------------------------EJERCICIOS 1.2.2 A 1.2.10 - GUÍA 1-------------------------------------------------------------------------
-- RAMIRO IBAZETA


--1.2.2
--Por cada factura emitida mostrar la cantidad total de artículos vendidos 
--(suma de las cantidades vendidas), la cantidad ítems que tiene cada factura 
--en el detalle (cantidad de registros de detalles) y el Importe total de la 
--facturación de este año.
Select f.nro_factura 'Nro. Factura', 
SUM(df.cantidad) 'Cant. Items', 
COUNT(df.nro_factura) 'Cant. Detalles', 
SUM(df.cantidad * df.pre_unitario) 'Importe'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
WHERE YEAR(f.fecha) = YEAR(GETDATE())
GROUP BY f.nro_factura

--1.2.3
--Se quiere saber en este negocio, cuánto se factura: 
---a. Diariamente 
Select CONVERT(Varchar, f.fecha, 103) 'Fecha',  
SUM(df.cantidad * df.pre_unitario) 'Importe total diario'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
GROUP BY CONVERT(Varchar, f.fecha, 103)
ORDER BY 1
 
---b. Mensualmente -- En esta consigna considero tambien necesario separar por año para que los datos sean más certeros
Select MONTH(f.fecha) 'MES',
YEAR(f.fecha) 'AÑO',  
SUM(df.cantidad * df.pre_unitario) 'Importe total mensual'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
GROUP BY MONTH(f.fecha), YEAR(f.fecha)
ORDER BY 2,1  

--- En caso de que solo se quisiera distinguir por mes y no por mes y año:
Select MONTH(f.fecha) 'MES',
SUM(df.cantidad * df.pre_unitario) 'Importe total mensual'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
GROUP BY MONTH(f.fecha)
ORDER BY 1 

---c. Anualmente  
Select YEAR(f.fecha) 'AÑO',
SUM(df.cantidad * df.pre_unitario) 'Importe total anual'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
GROUP BY YEAR(f.fecha)
ORDER BY 1 

--1.2.4
--Emitir un listado de la cantidad de facturas confeccionadas diariamente, 
--correspondiente a los meses que no sean enero, julio ni diciembre. Ordene 
--por la cantidad de facturas en forma descendente y fecha. 
Select CONVERT(Varchar, f.fecha, 103) 'Fecha',  
COUNT(f.nro_factura) 'Cantidad de facturas'
FROM Facturas f 
WHERE MONTH(f.fecha) NOT IN (1,7,12)
GROUP BY CONVERT(Varchar, f.fecha, 103)
ORDER BY 2 DESC, 1 

--1.2.5
--Se quiere saber la cantidad y el importe promedio vendido por fecha y 
--cliente, paraa códigos de vendedor superiores a 2. Ordene por fecha y 
--cliente.
Select CONVERT(Varchar, f.fecha, 103) 'Fecha',
f.cod_cliente 'Codigo cliente',  
AVG(df.cantidad * df.pre_unitario) 'Importe promedio',
SUM(df.cantidad) 'Cantidad'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
WHERE f.cod_vendedor > 2
GROUP BY CONVERT(Varchar, f.fecha, 103), f.cod_cliente
ORDER BY 1, 2

--1.2.6
--Se quiere saber el importe promedio vendido y la cantidad total vendida(ASUMO QUE ES LA SUMA DE CANTIDADES POR DETALLE) por 
--fecha y artículo (AQUÍ ENTIENDO QUE ME PIDE QUE LO HAGA POR EL NOMBRE DE ARTÍCULO), para códigos de cliente inferior a 3. Ordene por fecha y 
--artículo.
-- EN CANTIDAD TOTAL ENTIENDO QUE PIDE LA SUMA DE LAS CANTIDADES DE LOS DETALLES_FACTURA
Select CONVERT(Varchar, f.fecha, 103) 'Fecha',
a.descripcion 'Articulo',  
AVG(df.cantidad * df.pre_unitario) 'Importe promedio',
SUM(df.cantidad) 'Cantidad'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN articulos a ON df.cod_articulo = a.cod_articulo
WHERE f.cod_cliente < 3
GROUP BY CONVERT(Varchar, f.fecha, 103), a.descripcion
ORDER BY 1, 2

--1.2.7
--Listar la cantidad total vendida, el importe total vendido y el importe 
--promedio total vendido por número de factura, siempre que la fecha no 
--oscile entre el 13/2/2007 y el 13/7/2010.
SET DATEFORMAT DMY
Select f.nro_factura 'Nro. Factura', 
SUM(df.cantidad * df.pre_unitario) 'Importe total',
AVG(df.cantidad * df.pre_unitario) 'Importe promedio',
SUM(df.cantidad) 'Cantidad'
FROM Facturas f 
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
WHERE f.fecha NOT BETWEEN '13-02-2007' AND '13-07-2010'
GROUP BY f.nro_factura
ORDER BY f.nro_factura

--1.2.8
--Emitir un reporte que muestre la fecha de la primer y última venta y el 
--importe comprado por cliente. Rotule como CLIENTE, PRIMER VENTA, 
--ÚLTIMA VENTA, IMPORTE. 
Select c.nom_cliente + ' ' + c.ape_cliente 'CLIENTE',
CONVERT(VARCHAR, MIN(f.fecha), 103) AS 'PRIMER VENTA', 
CONVERT(VARCHAR, MAX(f.fecha), 103) AS 'ÚLTIMA VENTA',
SUM(df.cantidad * df.pre_unitario) 'IMPORTE'
FROM Facturas f 
JOIN clientes c ON f.cod_cliente = c.cod_cliente
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
GROUP BY c.nom_cliente + ' ' + c.ape_cliente
ORDER BY 1

--1.2.9
--Se quiere saber el importe total vendido, la cantidad total vendida y el precio 
--unitario promedio por cliente y artículo (AQUI ENTIENDO QUE ME PIDE POR NOMBRE DE ARTICULO), siempre que el nombre del cliente 
--comience con letras que van de la “a” a la “m”. Ordene por cliente, precio 
--unitario promedio en forma descendente y artículo. Rotule como IMPORTE 
--TOTAL, CANTIDAD TOTAL, PRECIO PROMEDIO.
-- ESTA RESOLUCION ES ACORDE A LO SOLICITADO POR LA CONSIGNA Y SU REDACCION QUE AUNQUE DA CUATRO ROTULACIONES PIDE 5.
SELECT c.nom_cliente + ' ' + c.ape_cliente 'CLIENTE',
SUM(df.cantidad * df.pre_unitario) 'IMPORTE TOTAL',
SUM(df.cantidad) 'CANTIDAD TOTAL',
AVG(df.pre_unitario) 'PRECIO PROMEDIO', --ASUMO QUE PIDE PRECIO UNITARIO DEL DETALLE
a.descripcion 'ARTICULO'
FROM Facturas f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN clientes c ON f.cod_cliente = c.cod_cliente
JOIN articulos a ON df.cod_articulo = a.cod_articulo
WHERE c.nom_cliente LIKE '[a-m]%'
GROUP BY c.nom_cliente + ' ' + c.ape_cliente, a.descripcion
ORDER BY 1 DESC,4 DESC, a.descripcion

-- A MI ENTENDER SERIA MEJOR RESOLVERLA ASI Y CORREGIR LA CONSIGNA
SELECT c.nom_cliente + ' ' + c.ape_cliente 'CLIENTE',
SUM(df.cantidad * df.pre_unitario) 'IMPORTE TOTAL',
SUM(df.cantidad) 'CANTIDAD TOTAL',
AVG(df.pre_unitario) 'PRECIO PROMEDIO'
FROM Facturas f
JOIN detalle_facturas df ON f.nro_factura = df.nro_factura
JOIN clientes c ON f.cod_cliente = c.cod_cliente
WHERE c.nom_cliente LIKE '[a-m]%'
GROUP BY c.nom_cliente + ' ' + c.ape_cliente
ORDER BY 1 DESC,4 DESC

-- 1.2.10
--Se quiere saber la cantidad de facturas y la fecha la primer y última factura 
--por vendedor y cliente, para números de factura que oscilan entre 5 y 30. 
--Ordene por vendedor, cantidad de ventas en forma descendente y cliente. 
SELECT v.nom_vendedor + ' ' + v.ape_vendedor 'Vendedor',
c.nom_cliente + ' ' + c.ape_cliente 'Cliente',
COUNT(f.nro_factura) 'Cantidad de ventas',
CONVERT(VARCHAR, MIN(f.fecha), 103) 'Primer factura', 
CONVERT(VARCHAR, MAX(f.fecha), 103) 'Ultima factura'
FROM Facturas f
JOIN clientes c ON f.cod_cliente = c.cod_cliente
JOIN vendedores v ON v.cod_vendedor = f.cod_vendedor
WHERE f.nro_factura BETWEEN 5 AND 30
GROUP BY v.nom_vendedor + ' ' + v.ape_vendedor, c.nom_cliente + ' ' + c.ape_cliente
ORDER BY 1 DESC, 3 DESC, 2




