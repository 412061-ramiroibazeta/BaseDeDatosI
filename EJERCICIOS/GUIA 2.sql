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

--- Se quiere saber que clientes ni vinieron entre el 12-12-2015 y 13-7-2020 -- EJ 4 de la Guía
SET DATEFORMAT DMY
Select c.cod_cliente 'Codigo', c.nom_cliente 'Nombre'
FROM clientes C
WHERE c.cod_cliente NOT IN (
							select f.cod_cliente
							From facturas f
							Where f.fecha between '12-12-2015' AND '13-07-2020')

--- Listar los datos de las facturas de los clientes que solo vienen a comprar en febrero es decir que todas las veces que compraron fueron en febrero y no en otro mes. -- EJ 5 de la Guía

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

-- Crear una consulta que muestre los articulos que compran con más frecuenta
Select a.descripcion, COUNT(f.nro_factura) --Es mejor poner df.cod_articulo -- IMO es mejor el nro factu porque cuenta por factura y
FROM Facturas f
JOIN detalle_facturas df on df.nro_factura = f.nro_factura
JOIN articulos a on a.cod_articulo = df.cod_articulo
WHERE MONTH(f.fecha) = 3 AND YEAR(f.fecha) = YEAR(GETDATE())
GROUP BY a.descripcion
ORDER BY 2 DESC

-- Clientes que compran con más frecuencia

SELECT c.nom_cliente + ' ' + c.ape_cliente 'Nombre y apellido', COUNT(f.cod_cliente)
FROM Facturas f
JOIN clientes c ON f.cod_cliente = c.cod_cliente
WHERE MONTH(f.fecha) = 3 AND YEAR(f.fecha) = YEAR(GETDATE())
GROUP BY c.nom_cliente + ' ' + c.ape_cliente
ORDER BY 2 DESC

-- Crear una vista que resalte el desempeño de un vendedor

CREATE VIEW VendedoresDesempenio with encryption -->> Es mejor ponerle el nombre VIS_NOMBRE_VISTA
AS 
SELECT v.nom_vendedor + ' ' + v.ape_vendedor 'Vendedor' , COUNT(f.nro_factura) 'Cantidad de ventas'
FROM vendedores v
JOIN Facturas f on f.cod_vendedor = v.cod_vendedor
WHERE YEAR(f.fecha) = YEAR(GETDATE())
GROUP BY v.nom_vendedor + ' ' + v.ape_vendedor

SELECT * FROM VendedoresDesempenio -->> Llamo a la vista - Acá se usa el order by, no tiene sentido de hacer la vista con order pues es como una tabla nueva

EXECUTE sp_helptext VendedoresDesempenio -->> ESTE SP PERMITE VER EL CODIGO DETRAS DE LA INSTRUCCIÓN


-- Crear una consulta que muestre clientes destacando la fidelidad según dos o más criterios | Compras en enero, frecuencia(+5 veces), diversos articulos(3 o +)

--- CREAR UNA CONSULTAQUE MUESTRE LOS CLIENTES DESTACANDO LA FIDELIDAD SEGUN DOS O MAS CRITERIOS

-- Primer criterio: compras de enero

select c.nom_cliente + ' ' + c.ape_cliente Cliente, COUNT(f.nro_factura) Facturas,'Compra enero' Tipo
from clientes c
join facturas f on c.cod_cliente = f.cod_cliente
join detalle_facturas df on f.nro_factura = df.nro_factura
where month(f.fecha) = 1 AND year(f.fecha) = 2024
group by c.nom_cliente + ' ' + c.ape_cliente

-- Segundo criterio: 5 clientes que fueron con más frecuencia en 2024

union

select top 5 c.nom_cliente + ' ' + c.ape_cliente Cliente, COUNT(f.nro_factura) Facturas, 'Frecuencia de 5' Tipo
from clientes c
join facturas f on c.cod_cliente = f.cod_cliente
WHERE year(f.fecha) = 2024
group by c.nom_cliente + ' ' + c.ape_cliente
order by 2 desc

-- Tercer criterio: mas de 2 articulos en una factura

select c.nom_cliente + ' ' + c.ape_cliente Cliente, COUNT(df.cod_articulo) Facturas, 'Mas de 2 articulos' Tipo
from clientes c
join facturas f on c.cod_cliente = f.cod_cliente
join detalle_facturas df on f.nro_factura = df.nro_factura
where 2 < all (select COUNT(df1.cod_articulo) from detalle_facturas df1
join facturas f1 on df1.nro_factura = f1.nro_factura
where f1.nro_factura = f.nro_factura)
group by c.nom_cliente + ' ' + c.ape_cliente

-- 1.2.2 A 1.2.10 HACER EJERCICIOS Y ENVIAR AL PROFE
---------------------------- UNION --------------

--Todas las personas que participan en la BD

-- UNION ELIMINA COLUMNAS REPETIDAS Y TRAE LOS DATOS DE LA CONSULTA DE ARRIBA Y ABAJO
Select c.cod_cliente 'Código', c.nom_cliente + ' ' + c.ape_cliente 'Nombre y apellido', 'Cliente' Tipo
FROM clientes c
UNION
SELECT v.cod_vendedor 'Código', v.nom_vendedor + ' ' + v.ape_vendedor 'Nombre y apellido', 'Vendedor' TIPO
FROM Vendedores v

-- UNION ALL JUNTA TODOS A PESAR DE QUE SE REPITAN



---------------------------------------------------------------------<<EJERCICIOS>>---------------------------------------------------------------


-- 3
Select c.cod_cliente 'Codigo', c.nom_cliente 'Nombre'
FROM clientes c
WHERE 2 < (Select COUNT(*) FROM FACTURAS f WHERE f.cod_cliente = c.cod_cliente AND YEAR(f.fecha) = YEAR(GETDATE()) -1)

-- 6 
SELECT *
FROM facturas f
WHERE YEAR(f.fecha) IN (
    SELECT YEAR(f2.fecha)
    FROM facturas f2
    GROUP BY YEAR(f2.fecha)
    HAVING COUNT(*) < 9
)

----- Subconsultas en el HAVING 

-- 1
Select MIN(f.fecha) 'Fecha', 
v.nom_vendedor 'Nombre', 
sum(df.cantidad * df.pre_unitario) 'Importe total'
From Facturas f
JOIN vendedores v ON v.cod_vendedor = f.cod_vendedor
JOIN detalle_facturas df  on f.nro_factura = df.nro_factura
GROUP BY v.nom_vendedor
HAVING AVG(df.cantidad * df.pre_unitario) > (SELECT AVG(dff.pre_unitario*dff.cantidad) FROM detalle_facturas dff)

-- 2 --PREGUNTAR
SET DATEFORMAT DMY
Select Month(f.fecha) 'Fecha', 
c.nom_cliente 'Nombre', 
sum(df.cantidad * df.pre_unitario) 'Importe total',
AVG(df.cantidad * df.pre_unitario) 'Importe promedio'
From Facturas f
JOIN clientes c ON c.cod_cliente = f.cod_cliente
JOIN detalle_facturas df  on f.nro_factura = df.nro_factura
WHERE f.fecha between '01-02-2014' AND '30-08-2014'
GROUP BY Month(f.fecha), c.nom_cliente
HAVING sum(df.cantidad * df.pre_unitario) >= (SELECT AVG(dff.pre_unitario*dff.cantidad) FROM detalle_facturas dff)

---- PREGUNTAR:
-- Hay que tener en cuenta que las referencias externas en las subconsultas en el HAVING deben ser parte de los campos de agrupación del GROUP BY | P.6
-- Como funcionan las subconsultas en el JOIN | P.8 ---> EJEMPLO:
SELECT f.nro_factura, 
fecha, 
ape_cliente +' '+ nom_cliente 'Cliente',
f2.total
FROM facturas f 
JOIN clientes c ON c.cod_cliente = f.cod_cliente
JOIN 
	(SELECT nro_factura, SUM(pre_unitario * cantidad) 'total'
	FROM detalle_facturas
	GROUP BY nro_factura) AS f2 ON f2.nro_factura = f.nro_factura
							
WHERE YEAR(fecha)= YEAR(GETDATE())

-- 3
--Por cada artículo que se tiene a la venta, se quiere saber el importe
--promedio vendido, la cantidad total vendida por artículo, para los casos
--en que los números de factura no sean uno de los siguientes: 2, 10, 7, 13,
--22 y que ese importe promedio sea inferior al importe promedio de ese
--artículo. 
Select a.cod_articulo 'Codigo',
AVG(df.cantidad * df.pre_unitario) 'Importe promedio', 
SUM(df.cantidad) 'Cantidad'
FROM articulos a
JOIN detalle_facturas df ON df.cod_articulo = a.cod_articulo
WHERE df.nro_factura NOT IN(2,10,7,13,22)
GROUP BY a.cod_articulo, a.descripcion
HAVING AVG(df.cantidad * df.pre_unitario) > (Select AVG(df1.cantidad * df1.pre_unitario) from detalle_facturas df1 WHERE df1.cod_articulo = a.cod_articulo)

--Listar la cantidad total vendida, el importe y promedio vendido por fecha,
--siempre que esa cantidad sea superior al promedio de la cantidad global.
--Rotule y ordene. 
Select convert(varchar, f.fecha, 103) 'Fecha',
Sum(df.cantidad) 'Cantidad Total',
Sum(df.cantidad * df.pre_unitario) 'Importe',
AVG(df.cantidad * df.pre_unitario) 'Promedio'
FROM Facturas f 
JOIN detalle_facturas df on df.nro_factura = f.nro_factura
Group by convert(varchar, f.fecha, 103)
HAVING SUM(df.cantidad) > (Select avg(cantidad) from detalle_facturas)

--Se quiere saber el promedio del importe vendido y la fecha de la primer
--venta por fecha y artículo para los casos en que las cantidades vendidas
--oscilen entre 5 y 20 y que ese importe sea superior al importe promedio
--de ese artículo. 



