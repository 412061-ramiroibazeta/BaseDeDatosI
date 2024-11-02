-- FUNCIONES

select convert(varchar, getdate(), 103), case datepart(WEEKDAY, GETDATE())											
											when 1 then 'Lunes'
											when 2 then 'Martes'
											when 3 then 'Miercoles'
											when 4 then 'Jueves'
											when 5 then 'Viernes'
											when 6 then 'Sabado'
											when 7 then 'Domingo'
											end 'Dia'

--Funci�n Estado del Stock: Crea una funci�n fn_estado_stock que reciba el cod_articulo y devuelva "Bajo" si el stock est� por debajo del stock_minimo, 
--"Suficiente" si est� igual o mayor que el m�nimo, y "Excesivo" si supera el m�nimo en m�s del doble.
create function fn_estado_stock
(@articulo int)
returns varchar(10)
begin 
declare @respuesta varchar(10), @stock int, @stock_min int;

select @stock = stock, @stock_min = stock_minimo from articulos where cod_articulo = @articulo

set @respuesta = case when @stock < @stock_min then 'Bajo'
						when @stock >= @stock_min then 'Suficiente'
						when @stock > @stock_min * 2 then 'Excedido'
				END
return @respuesta
end

select dbo.fn_estado_stock(4)

--Funci�n Edad de Vendedor: Crea una funci�n que reciba el cod_vendedor y 
--devuelva la edad del vendedor calculada con base en su fecha de nacimiento (fec_nac).

CREATE FUNCTION fn_edad_vendedor
(@VENDEDOR INT)
RETURNS INT
BEGIN
DECLARE @CUMPLEA�OS DATETIME, @EDAD INT
SELECT @CUMPLEA�OS = FEC_NAC FROM vendedores WHERE cod_vendedor = @VENDEDOR

SET @EDAD = DATEDIFF(YEAR, @CUMPLEA�OS, GETDATE())

IF (MONTH(@CUMPLEA�OS) > MONTH(GETDATE()) OR (MONTH(@CUMPLEA�OS) = MONTH(GETDATE()) AND DAY(@CUMPLEA�OS) > DAY(GETDATE())))
BEGIN 
SET @EDAD = @EDAD - 1
END

RETURN @EDAD
END

SELECT dbo.FN_EDAD_VENDEDOR(2) 'EDAD'

--Funci�n Cliente Completo: Crea una funci�n fn_cliente_completo que reciba el cod_cliente y 
--devuelva una cadena concatenando nom_cliente, ape_cliente, nro_tel, y barrio, en el formato "Apellido, Nombre - Tel�fono - Barrio".

CREATE FUNCTION fn_cliente_completo
(@CLIENTE INT)
RETURNS VARCHAR(200)
BEGIN 
DECLARE @RESULTADO VARCHAR(200)
SELECT @RESULTADO = CONCAT('Apellido: ', c.ape_cliente, ', ',
            'Nombre: ', c.nom_cliente, ', ',
            'Telefono: ', CAST(c.nro_tel AS VARCHAR(15)), ', ',
            'Calle: ', c.calle, ', ',
            'Altura: ', CAST(c.altura AS VARCHAR(10)), ', ',
            'Barrio: ', b.barrio)
FROM clientes c
JOIN barrios b on b.cod_barrio = c.cod_barrio
WHERE cod_cliente = @CLIENTE
RETURN @RESULTADO
END

SELECT dbo.fn_cliente_completo(2) 'CLIENTE'

--Funci�n Cantidad de Facturas del Cliente: Crea una funci�n fn_facturas_cliente que reciba el cod_cliente y 
--devuelva la cantidad total de facturas asociadas a ese cliente.

CREATE FUNCTION fn_facturas_cliente
(@CLIENTE INT)
RETURNS INT
BEGIN
DECLARE @FACTURAS INT
SELECT @FACTURAS = COUNT(NRO_FACTURA)
FROM facturas
WHERE cod_cliente = @CLIENTE
RETURN @FACTURAS
END

SELECT dbo.fn_facturas_cliente(1) 'CANT FACTURAS'

--Funci�n Precio Final con Descuento: Crea una funci�n fn_precio_final que reciba un cod_articulo y un porcentaje de descuento, 
--y devuelva el precio del art�culo con el descuento aplicado.

CREATE FUNCTION fn_precio_final
(@COD_ARTICULO INT, @DESCUENTO DECIMAL(4,2))
RETURNS DECIMAL(8,2)
BEGIN 
DECLARE @PRECIO DECIMAL(8,2)

SELECT @PRECIO = pre_unitario
FROM articulos 
WHERE cod_articulo = @COD_ARTICULO

SET @PRECIO = @PRECIO * (@DESCUENTO + 1)

RETURN @PRECIO
END

SELECT dbo.fn_precio_final(2, 0.10) 'NUEVO PRECIO'

-------------------------------------------------------------------------------------------------------------------------------------------
--TRIGGERS

--Trigger para Actualizaci�n de Cliente: 
--Crea un trigger que registre en la tabla auditorias cualquier actualizaci�n en los datos de direcci�n de los clientes (calle, altura, cod_barrio).

CREATE TRIGGER DIS_CLIENTE
ON CLIENTES
FOR UPDATE
AS 
IF UPDATE(calle) or UPDATE(ALTURA) OR UPDATE(COD_BARRIO)
BEGIN 
INSERT INTO auditorias (tabla, fecha, detalle, cod_entidad, movimiento)
        SELECT 
            'clientes',
            GETDATE(),
            'Actualizaci�n de direcci�n',
            i.cod_cliente,
            'actualizacion'
        FROM inserted i
        JOIN deleted d ON i.cod_cliente = d.cod_cliente
END

--Trigger para Control de Stock Bajo: 
--Crea un trigger que al insertar un detalle en detalle_facturas verifique si el stock del art�culo es mayor al de la venta.

CREATE TRIGGER DIS_VERIFICAR_STOCK
ON DETALLE_FACTURAS
FOR INSERT
AS
DECLARE @CANTIDAD INT

SELECT @CANTIDAD = A.STOCK 
FROM articulos A 
JOIN inserted I ON A.cod_articulo = I.cod_articulo

IF(@CANTIDAD > (SELECT CANTIDAD FROM inserted))
BEGIN 
UPDATE articulos
SET stock = stock - I.CANTIDAD
FROM articulos 
JOIN inserted I ON articulos.cod_articulo = I.cod_articulo
END
ELSE BEGIN
RAISERROR('NO HAY STOCK',16,1)
ROLLBACK TRANSACTION
END

insert into detalle_facturas (nro_factura, cod_articulo, pre_unitario, cantidad) values(700,3,450.00,154);

--Trigger para Registrar Cambios en Art�culos: 
--Crea un trigger que al actualizar el descripcion o observaciones de un art�culo en la tabla articulos, deniegue el cambio.
CREATE TRIGGER DIS_MODIF_ARTICULOS
ON ARTICULOS
FOR UPDATE
AS
IF UPDATE(DESCRIPCION) OR UPDATE(COD_ARTICULO)
BEGIN
RAISERROR('NO SE PUEDE CAMBIAR EL NOMBRE NI EL ID DE UN ARTICULO', 16,1)
ROLLBACK TRANSACTION
END

--Trigger para Registrar Precio Anterior: 
--Crea un trigger que, antes de cambiar el pre_unitario en la tabla articulos, inserte el cod_articulo, el precio anterior, y la fecha en historial_precios.
ALTER TRIGGER DIS_PRECIOS
ON ARTICULOS
FOR UPDATE 
AS 
IF UPDATE(PRE_UNITARIO)
BEGIN 
INSERT INTO historial_precios (cod_articulo, precio, fecha_desde)
        SELECT d.cod_articulo, d.pre_unitario, GETDATE()
        FROM deleted d        
--DECLARE @PRECIO INT
--SELECT @PRECIO = A.PRE_UNITARIO FROM articulos A
--JOIN DELETED I ON I.cod_articulo = A.cod_articulo

--INSERT INTO historial_precios(cod_articulo, precio, fecha_desde)
--SELECT I.cod_articulo, @PRECIO, GETDATE()
--FROM inserted I
END

--Trigger de Restricci�n en Tel�fono de Vendedores: 
--Crea un trigger que impida la inserci�n o actualizaci�n de un nro_tel en vendedores si el n�mero tiene menos de 10 d�gitos.

create trigger dis_tel_vendedor
on vendedores
for insert 
as
declare @telefono int 
select @telefono = i.nro_tel
from inserted i
if(len(cast(@telefono as varchar(20))) < 10)
begin
raiserror('la cantidad de digitos del telefono debe ser mayor o igual a 10', 16,1)
rollback transaction
end

----------------------------------------------------------------------------------------------------------------------------------------------
-- STORED PROCEDUES
--Actualizar Barrio del Cliente: Crea un procedimiento sp_actualizar_barrio_cliente 
-- que reciba el cod_cliente y el cod_barrio y actualice el barrio de ese cliente.

CREATE PROCEDURE sp_actualizar_barrio_cliente
@CLIENTE INT, @BARRIO INT
AS
UPDATE clientes
SET cod_barrio = @BARRIO
WHERE cod_cliente = @CLIENTE

--Obtener Ventas de un Cliente por Fecha: Crea un procedimiento sp_ventas_cliente_fecha que reciba un cod_cliente, una fecha de inicio, y una fecha de fin; 
--y devuelva un listado de las facturas del cliente en ese per�odo, incluyendo el total de cada factura.

--Insertar Art�culo con Validaci�n de Descripci�n: Crea un procedimiento sp_insertar_articulo_validado que reciba los datos del art�culo. 
--Si la descripcion ya existe en la tabla articulos, muestre un mensaje de error; si no, inserte el art�culo.

--Eliminar Cliente y sus Facturas: Crea un procedimiento sp_eliminar_cliente que reciba el cod_cliente, elimine las facturas y detalles asociados, 
--y luego elimine al cliente. Usa una transacci�n para asegurar que todas las eliminaciones ocurran correctamente o se reviertan en caso de error.

--Reporte de Ventas por Vendedor y Mes: Crea un procedimiento sp_reporte_ventas_vendedor_mes que reciba 
--el cod_vendedor y el mes/a�o (por ejemplo, @mes y @anio) y devuelva el total de ventas realizadas por ese vendedor en el mes, as� como 
-- el detalle de cada factura.