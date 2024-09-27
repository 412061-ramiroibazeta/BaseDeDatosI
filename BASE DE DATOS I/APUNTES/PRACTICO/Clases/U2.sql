-- Articulos cuyo precio supera al promedio
select * from articulos

-- Consulta de precio promedio
select avg(pre_unitario) from articulos

-- Consulta con subconsulta
select * from articulos
where pre_unitario > (select avg(pre_unitario) from articulos)

-- Alguna vez se vendieron más de 20 de este articulo
select * from articulos a 
where exists ( select cod_articulo 
			   from detalle_facturas d
			   where d.cantidad > 20
			   and  d.cod_articulo = a.cod_articulo
			   )