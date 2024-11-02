-------- TEMA 1 -----------

--1. En una misma tabla de resultados se quiere ver los responsables que no trabajaron
--el mes pasado y por otro lado los responsables de aquellas órdenes de producción,
--del mes pasado, cuyas cantidades superan las 100 unidades Agregar una columna que los
--identifique, ordenar convenientemente; y listar los responsables sin repeticiones.

Select apellido, nombre, 'No trabajó' Observaciones
From responsables
Where id_responsable not in (select id_responsable
								From ordenes
								Where datediff(month,fecha_fab,getdate())=1)
Union
Select distinct apellido,nombre, 'Ordenes mayores a 100 un.'
From responsables r join ordenes o on o.id_responsable=r.id_responsable
Where cantidad >100
 and datediff(month,fecha_fab,getdate())=1
Order by 3,1,2--2. Se quiere saber, en el año en curso: ¿Cuántas órdenes de producción se ejecutaron, cuál es
--la mayor cantidad de producción y cuánto fue el costo total en todas esas órdenes?

Select count(*) 'cant. Ordenes',
       max(cantidad) 'mayor cantidad', 
       sum(costo_total) 'costo total'
From ordenes
Where year(fecha_fab)=year(getdate())

--3. Listar por sección y por turno, los costos totales, cantidad de órdenes de producción,
--el promedio de las cantidades de producto producido en lo que va del mes, siempre que
--el tipo de producto comience con letras que van de la “A” a la “M” y que la mínima
--cantidad producida (en esa sección y turno, este mes) haya sido mayor a 50
Select s.id_seccion,sección, tu.id_turno, turno,
 sum(costo_total) 'costo total', count(*)'cant. Ordenes', 
 avg(cantidad) 'promedio de la cant.'
From secciones s join ordenes o on s.id_seccion=o.id_seccion
Join turnos tu on tu.id_turno=o.id_turno
Join productos p on p.id_producto=o.id_producto
join tipos ti on ti.id_tipo=p.id_tipo
Where month(fecha_fab)=month(getdate()) 
and year(fecha_fab)=year(getdate()) And tipo like '[A-M]%`'
Group by s.id_seccion, seccion, tu.id_turno, turno
Having min(cantidad)>50

--4. Se quiere saber cuánto es la cantidad total de unidades producidas y el total del costo por mes
--por producto siempre que el promedio de esas cantidades (por mes por producto) sea menor que
--el promedio de las cantidades de ese producto de todas las órdenes de la base de datos.

Select year(fecha_fab) Año ,month(fecha_fab) Mes,p.id_producto, descripcion,
sum(cantidad) 'cant. productos', sum(costo_total) 'costo total'
from productos p join ordenes o on p.id_producto=o.id_producto
group by year(fecha_fab),month(fecha_fab), p.id_producto,descripcion
having avg(cantidad)<(select avg(cantidad)
						from ordenes o1
						where p.id_producto=o.id_producto)

--Crear una vista que muestre el costo total, la cantidad de órdenes, el promedio del costo
--unitario y la fecha de la primera y última orden por producto por mes entre el 2019 y el 2021
--Realizar una consulta a la vista anterior mostrando la descripción del producto y el costo total
--solo los casos en que el promedio del costo unitario sea menor al promedio general del costo
--unitario del mes pasado.create view punto5asselect year(fecha_fab) Año ,month(fecha_fab) Mes,p.id_producto, descripcion, sum(costo_total) 'Costo_total',count(*)'Cantidad_Ord',sum(costo_total)/sum(cantidad) Costo_unitario, min(fecha_fab) 1erFecha,max(fecha_fab)from joinear las tablas necesariaswhere year(fecha_fab) between 2019 and 2021group by year(fecha_fab),month(fecha_fab),p.id_producto, descripcionselect descripcion, costo_totalfrom punto5where costo_unitario<(select avg(sum(costo_total)/sum(cantidad)						from ordenes						where datediff(month,fecha_fab,getdate())=1)

------------- TEMA 2 ------------------

--1. Listar los productos que tengan más de 10 órdenes de fabricación el mes pasado.
Select descripción
From productos p
Where 10<(select count(*)
		From ordenes
		Where datediff(month,fecha_fab,getdate())=1 		and p.id_producto=id_producto)--otra opciónselect id_producto, descripcionfrom productos p join ordenes o on p.id_producto=o.id_productowhere datediff(month,fecha_fab,getdate())=1group by id_producto, descripcionhaving count(*)>10--2. En una misma tabla de resultados se quiere mostrar la cantidad de órdenes de producción que
--se ejecutaron, la mayor cantidad producida y el costo total de las órdenes correspondiente al mes
--en curso en primer lugar y las del año en curso en 2do lugar
Select count(*)'cant.Ord',max(cantidad)'mayor cant',
sum(costo_total)'costo tot','este mes' Observaciones
From ordenes
Where datediff(month,fecha_fab,getdate())=0
union
Select count(*),max(cantidad),sum(costo_total),'año en curso'
From ordenes
Where year(fecha_fab)=year(getdate())
Order by 4 desc--3. Emitir un listado que muestre, por mes y por producto, los costos totales, cantidad de órdenes
--de producción, el promedio de las cantidades producidas, siempre que el tipo de producto comience
--con letras que van de a “P” a la “S” y que la máxima cantidad producida (por mes y por producto) 
--haya sido menor a 800
Select year(fecha_fab) Año ,month(fecha_fab) Mes,p.id_producto, descripcion,
sum(costo_total) 'costo total', count(*)'cant. Ordenes', avg(cantidad) 'promedio de la cant.'
from productos p join ordenes o on p.id_producto=o.id_producto
Join tipos ti on ti.id_tipo=p.id_tipo
Where tipo like '[P-S]%'
group by year(fecha_fab),month(fecha_fab), p.id_producto,descripción
Having max(cantidad)<800--4-Se quiere saber cuánto es la cantidad total de unidades producidas y el total del costo por mes por producto siempre que
--el promedio de esas cantidades (por mes por producto) sea menor que el promedio de las cantidades de ese producto de
--todas las órdenes de la base de datos.
Select year(fecha_fab) Año ,month(fecha_fab) Mes,p.id_producto, descripcion,
sum(cantidad) 'cant. productos', sum(costo_total) 'costo total'
from productos p join ordenes o on p.id_producto=o.id_producto 
group by year(fecha_fab),month(fecha_fab), p.id_producto,descripción
having avg(cantidad)<(select avg(cantidad)
					from ordenes o1
					where p.id_producto=o1.id_producto)

--5. Crear una vista que muestre el costo mensual promedio (promedio ponderado) 
--de cada unidad de producto en los últimos 12 meses sin contar el
--actual.
--Consulte la vista anterior y muestre el margen de ganancia de cada
--producto respecto a los costos unitarios del mes pasado 
--y el precio de venta de cada producto.
Create view punto5_2
as
select year(fecha_fab) Año ,month(fecha_fab) Mes,p.id_producto, descripcion,
sum(costo_total)/sum(cantidad) costo_promedio
from ordenes o join productos p on p.id_producto=o.id_producto
where datediff(month,fecha_fab,getdate()) between 1 and 12
group by year(fecha_fab),month(fecha_fab),p.id_producto, descripcion

select p5.id_producto,descripcion,precio_venta-costo_promedio ganancia,
from punto5_2 p5 join productos p on p5.id_producto=p.id_producto
where mes=month(dateadd(month,-1,getdate()))

