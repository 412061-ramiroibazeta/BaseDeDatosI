--1) Crear una funci�n escalar que devuelva la edad recibiendo como par�metro de entrada una fecha
--(edad cumplida respecto a la fecha ingresada, no la que va a cumplir ese a�o).
Create function fn_edad
(@cumpleanios datetime, @fecha datetime)
returns int
begin 
declare @edad int
set @edad = datediff(year, @cumpleanios, @fecha)
if(month(@cumpleanios) > MONTH(@fecha) OR (MONTH(@cumpleanios) = MONTH(@fecha) and day(@cumpleanios) > day(@fecha)))
begin 
set @edad = @edad - 1
end
return @edad
end	

--------------------- EDAD
Create function fn_edad_real
(@cumpleanios datetime)
returns int
begin 
declare @edad int
set @edad = datediff(year, @cumpleanios, getdate())
if(month(@cumpleanios) > MONTH(getdate()) OR (MONTH(@cumpleanios) = MONTH(getdate()) and day(@cumpleanios) > day(getdate())))
begin 
set @edad = @edad - 1
end
return @edad
end	

--2) Crear una vista que muestre el monto total pagado, cantidad de pagos, promedio de monto pagado
--mensualmente por alumno. Tenga en cuenta de agregar una columna edad que ten�a el alumno al
--momento de pagar la cuota, ya que se le pedir� en el punto siguiente. Calcule la edad con la funci�n
--del punto anterior. Monto pagado de cuota es el importe_cuota m�s el recargo.
--Aclaraci�n: Vistas no se tomar� en el segundo parcial pero se est� ultilizando aqu� tambi�n como repaso para
--el examen final.

create view vis_punto_2
 as
 select a.nombre 'Nombre', 
 dbo.fn_edad_real(fec_nac) 'Alumnos',
 month(fecha_pago) Mes, 
 year(fecha_pago) Anio,
 sum (importe_cuota + recargo) 'Monto_Total', 
 count(id_pago) 'Cant_Pagos',
 avg(importe_cuota + recargo) 'Importe_Promedio' 
 from Pagos p 
 join Alumnos a on a.id_alumno = p.id_alumno
 group by a.nombre, dbo.fn_edad_real(fec_nac), month(fecha_pago), year(fecha_pago)

-- 3) Cree un procedimiento almacenado que consulte la vista anterior y muestre los totales pagados y
--la cantidad de pagos mensualmente por alumnos cuya edad se ingresar� por par�metro. Verifique
--que la edad ingresada por par�metro sea mayor a 5 y menor a 100 para poder ejecutar el SP, en
--caso contrario dar un mensaje de error por una excepci�n.

CREATE PROCEDURE SP_PUNTO3
@EDAD INT = 0
AS
if(@edad > 5 AND @edad < 100)
BEGIN
SELECT MONTO_TOTAL, CANT_PAGOS
FROM vis_punto_2
WHERE alumnos = @EDAD
END
ELSE
BEGIN 
raiserror('Debe ingresar una edad valida',16,1)
end

--Cree un trigger que impida ingresar un pago de un alumno que no existe; en dicho caso, d� un
--mensaje informando esta situaci�n

CREATE TRIGGER DIS_ALUMNO
ON PAGOS
FOR INSERT
AS
DECLARE @ID INT 
SELECT @ID = I.id_alumno FROM inserted I
IF NOT EXISTS (SELECT * FROM Alumnos WHERE id_alumno = @ID)
BEGIN 
raiserror('NO EXISTE ESE ALUMNO',16,1)
ROLLBACK TRANSACTION
END
END

--Si el campo mes es un campo de tipo char que indica el mes de cursado que se est� pagando por
--ejemplo 202307 para indicar julio del 2023, crear una funci�n que devuelva mes en letras y a�o
--separado con un guion a partir del campo este mes de la tabla PAGOS. Ejemplo campo mes=202307,
--debe devolver: Julio-2023

CREATE FUNCTION FN_FECHA
(@FECHA CHAR(6))
RETURNS VARCHAR(20)
BEGIN
DECLARE @RESULTADO VARCHAR(20), @MES VARCHAR(2), @A�O VARCHAR(4)
SET @MES = RIGHT(@FECHA, 2)
SET @A�O = LEFT(@FECHA, 4)

SET @RESULTADO = CASE
					WHEN @MES = '01' THEN 'ENERO-' + @A�O 
					WHEN @MES = '02' THEN 'FEBRERO-' + @A�O 
					WHEN @MES = '03' THEN 'MARZO-' + @A�O 
					WHEN @MES = '04' THEN 'ABRIL-' + @A�O 
					WHEN @MES = '05' THEN 'MAYO-' + @A�O 
					WHEN @MES = '06' THEN 'JUNIO-' + @A�O 
					WHEN @MES = '07' THEN 'JULIO-' + @A�O 
					WHEN @MES = '08' THEN 'AGOSTO-' + @A�O 
					WHEN @MES = '09' THEN 'SEPTIEMBRE-' + @A�O 
					WHEN @MES = '10' THEN 'OCTUBRE-' + @A�O 
					WHEN @MES = '11' THEN 'NOVIEMBRE-' + @A�O 
					WHEN @MES = '12' THEN 'DICIEMBRE-' + @A�O
					END
RETURN @RESULTADO 
END

SELECT DBO.FN_FECHA('202307')

--6) Programar un procedimiento almacenado (P.A.) que muestre todos los datos de los alumnos que
--pagaron este mes o el mes pasado, nacidos en una d�cada que se ingresar� por par�metro.
--Adem�s, mostrar la clase a la que asisten, actividad y el mes que pagan utilizando la funci�n anterior
--Entendiendo que se ingresar�n decadas tal que por ejemplo 1900 -+9> 1909. terminados en 0

CREATE PROCEDURE SP_DATOS_ALUMNOS
@DECADA INT
AS
SELECT A.nombre,
C.descripcion 'CLASE', 
YEAR(A.fec_nac),
DBO.FN_FECHA(P.Fecha_pago)
FROM Alumnos A
JOIN PAGOS P ON A.id_alumno = P.id_alumno
JOIN Cursos C ON C.id_curso = P.id_curso
WHERE (MONTH(P.Fecha_pago) = MONTH(GETDATE()) OR MONTH(P.Fecha_pago) = MONTH(GETDATE()) - 1)
AND YEAR(A.fec_nac) BETWEEN @DECADA AND @DECADA + 9

EXEC SP_DATOS_ALUMNOS @DECADA = 1990

--7) De un ejemplo de Trigger con las tablas de la base de datos del examen distinto al del punto 4.
--Explique el ejemplo, es decir qu� hace y por qu�.




