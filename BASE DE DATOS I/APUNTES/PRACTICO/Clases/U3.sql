-- declaramos una variable, le asignamos 1 y lo mostramos
declare @codigo int;
set @codigo = 1;
select @codigo as 'valor variable'

/*
vemos el if y el begin end
*/
if exists (select * from articulos where pre_unitario<30)  
 begin
    select 'existen artículos con esos precios' as 'Obs' 

  end 
 else
 begin
    select 'no hay artículos con esos precios'  
	end
/*
vemos el while
*/
declare @a int
set @a = 2
while @a < 6
begin
   select 'vuelta ', @a , 'vuelta ' + cast(@a as varchar(2))
   set @a = @a + 1
end

-- Case
declare @b int
set @b = 2
select mensaje=
case
   when @b < 10 then 'Minorista'
   when @b >= 10 then 'Mayorista'
   else 'No hay else'
end

-- IIF
declare @c int
set @c = 20000
SELECT iif(@c>10000,'Caro','Barato') 'Consideración'

--Procedimiento almacenado de suba o baja de precios a un articulo
create PROCEDURE sp_modiprecio
  @articulo INT,
  @cambio VARCHAR(4),
  @monto MONEY
AS
BEGIN
  SELECT @articulo, @cambio, @monto
END
IF @cambio = 'suba'
	update articulos 
	set pre_unitario = pre_unitario + @monto
	where cod_articulo = @articulo
else
	update articulos 
	set pre_unitario = pre_unitario - @monto
	where cod_articulo = @articulo

-- Subimos 5 pe
EXECUTE sp_modiprecio 1, 'suba', 5

-- bajamos 10 pe
EXECUTE sp_modiprecio 1, 'baja', 100

-- Función escalar
create FUNCTION multi2
(@entrada INT)
RETURNS INT
BEGIN
 set @entrada = @entrada * 2
RETURN @entrada
END;

-- ejecutamos la funcion pero no estamos guardando lo que devuelve
exec dbo.multi2 3
-- mostramos lo que devuelve
select dbo.multi2(3)

-- Funcion q devuelve tabla con articulos de precio menor al ingresado
create function f_ofertas_2nov
  (@minimo decimal(8,2))
  returns @ofertas table -- nombre de la tabla
  --formato de la tabla
  (cod_articulo int,
   descripcion varchar(100), 
   pre_unitario money
  )
as
  begin
    insert @ofertas
	-- inserta en la tabla los articulos que valen menos el monto ingresado
    select cod_articulo,descripcion,pre_unitario
    from articulos
    where pre_unitario < @minimo
    return
  end;

  -- Uso la función como si fuera una tabla
  select * from dbo.f_ofertas_2nov(60)


  -- Función de tabla en linea
 create function f_articulos_2Nov
(@descrip varchar(100)='Lápiz')
returns table
as
return (
select descripcion,pre_unitario
from articulos
where descripcion like '%'+@descrip+'%'
);

-- consultamos la tabla en linea
select * from dbo.f_articulos_2Nov('reg') where pre_unitario > 80

-- Trigger que evite que se ingrese articulo con precio menor a 50pe
create trigger tr_art_menos50
on articulos
FOR insert
as
begin
if exists (select * from inserted i where i.pre_unitario < 50) 
	raiserror(15600,-1,-1,'NOOOO, Basta de precios menor de 50pe')
end

-- Creamos un proc para dividir usamos try catch
CREATE PROC usp_dividir(
   @a decimal,
    @b decimal,
    @c decimal output
) AS
BEGIN
    BEGIN TRY
        SET @c = @a / @b;
    END TRY
    BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END;

-- ejecutamos el proc con escenario sin errores
declare @pri as decimal, @seg as decimal, @ter as decimal
set @pri = 14
set @seg = 2
set @ter = 0
exec usp_dividir @pri, @seg, @ter OUT

select  @ter

-- ejecutamos el proc con escenario con errores
declare @pri as decimal, @seg as decimal, @ter as decimal
set @pri = 14
set @seg = 0
set @ter = 0
exec usp_dividir @pri, @seg, @ter OUT

select  @ter

-- Uso el @@ERROR
select 1/0
select 1
Select  @@Error as 'error en la variable global @@error'
