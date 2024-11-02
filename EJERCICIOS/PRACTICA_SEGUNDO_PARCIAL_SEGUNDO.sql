--1. Crear una funci�n que devuelva el nombre completo del due�o con el apellido todo en may�sculas,
--coma, espacio y el nombre con la 1er. letra en may�sculas y el resto en min�sculas
CREATE FUNCTION FN_NOMBRE_DUENIO
(@ID INT)
RETURNS VARCHAR(100)
BEGIN 
DECLARE @RESULTADO VARCHAR(100)

SELECT @RESULTADO = UPPER(D.apellido) + ', ' + UPPER(LEFT(d.nombre, 1)) + LOWER(SUBSTRING(D.NOMBRE,2,LEN(D.NOMBRE)))
	FROM Due�os D
	WHERE D.id_due�o = @ID

RETURN @RESULTADO 
END

SELECT DBO.FN_NOMBRE_DUENIO(2)

--2. Crear una vista que muestre el listado de mascotas (nombre, tipo, raza, edad) con sus due�os
--(nombre completo utilizando la funci�n del punto 1, direcci�n completa, tel�fono)alter view vista_masc2
as
 select m.id_mascota,
 m.nombre 'nombre_m', 
 t.tipo 'tipo', 
 r.raza 'raza', 
 DATEDIFF(YEAR, m.fec_nac, GETDATE()) 'edad',
 DBO.FN_NOMBRE_DUENIO(m.id_due�o) 'duenio', 
 d.calle+' '+cast(d.altura as varchar(10)) 'direccion', 
 d.telefono 'telefono'
from mascotas m,tipos t, due�os d, razas r
where m.id_tipo = t.id_tipo and d.id_due�o = m.id_due�o and m.id_raza = r.id_raza--Consultar la vista anterior mostrando nombre y raza de perros con m�s de 5 a�os, de due�os con
--tel�fono conocido (mostrar nombre de due�o y tel�fono), que vinieron a consulta este a�o SELECT nombre_m, raza, duenio, telefonofrom vista_masc2where edad > 5 and telefono is not nulland raza = 'perro'and id_mascota IN (select id_mascota from Consultas where year(fecha) = year(getdate()))--4. Mostrar los importes totales cobrados mensualmente por cada m�dico entre los a�os que se
--ingresar�n por par�metrocreate procedure sp_importe_cobrado@anioInicio int, @anioFin intasselect c.id_medico 'id', 		m.nombre + ', ' + m.apellido 'Medico',		sum(importe) 'Importe',		month(c.fecha) 'mes',		year(c.fecha) 'anio'from Consultas cJOIN medicos m on c.id_medico = m.id_medicoWHERE year(c.fecha) between @anioInicio and @anioFingroup by c.id_medico, m.nombre + ', ' + m.apellido, month(c.fecha), year(c.fecha)--Crear un trigger que impida que se modifique el importe de las consultas.CREATE TRIGGER DIS_IMPORTE_CONSULTASON CONSULTASFOR UPDATEASIF UPDATE(importe)BEGINRAISERROR('NO SE PUEDE MODIFICAR EL IMPORTE', 16,1)ROLLBACK TRANSACTIONEND--1. Crear un procedimiento almacenado para insertar un nuevo m�dico. (antes de completar este punto,
--agregue lo que se solicita en el punto 2 y 3)CREATE FUNCTION FN_FECHA(@MESCONSULTA VARCHAR(20))RETURNS VARCHAR(20)ASBEGIN DECLARE @MES VARCHAR(20)SET @MES = (SELECT FORMAT(CAST(LEFT(@MESCONSULTA,4)+'-' RIGHT(@MESCONSULTA,2) + '-01' AS DATE), (MMMM-YYYY))RETURN @MESENDcreate function convertir(@fecha char(6))
returns char(15)
as
begin
  declare @conversion char(15), @anio int,@mesNum char(2),@mes varchar(15)
  set @anio = CAST(LEFT(@FECHA,4) AS INT)
  set @mesNum = CAST(RIGHT(@FECHA,2) AS INT)
  set @mes = case @mesNum 
		when 1 then 'Enero'
		when 2 then 'Febrero'
		when 3 then 'Marzo'
		when 4 then 'Abril'
		when 5 then 'Mayo'
		when 6 then 'Junio'
		when 7 then 'Julio'
		when 8 then 'Agosto'
		when 9 then 'Septiembre'
		when 10 then 'Octubre'
		when 11 then 'Noviembre'
		when 12 then 'Diciembre'
	end
	set @conversion = @mes+'-'+cast(@anio as nvarchar(4))
	return @conversion
end