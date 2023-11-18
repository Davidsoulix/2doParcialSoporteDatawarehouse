USE tempdb;
GO

IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N' Hotel_RealtaDMParcial2')
BEGIN
    ALTER DATABASE  Hotel_RealtaDMParcial2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END

DROP DATABASE IF EXISTS Hotel_RealtaDMParcial2;
GO

CREATE DATABASE  Hotel_RealtaDMParcial2;
GO

USE  Hotel_RealtaDMParcial2;
GO

--parcial 2

--dimensiones 

CREATE TABLE Dim_parcial (
	hotel_name nvarchar(85) NOT NULL,
	numero_habitacion INT,
	nombre_area NVARCHAR(100) NOT NULL,
	nombre_tipo_habitacion NVARCHAR(100) NOT NULL
primary key (numero_habitacion)
);

CREATE TABLE Dim_parcialhuesped (
	gender_huesped nchar(1) CHECK(gender_huesped IN('M','F')),
	name_huesped varchar(100) not null, -- de user.users full name
	edad nvarchar (6) check (EDAD in ('Adulto', 'Nino')) 
primary key (name_huesped)
);

--hechos

--drop table fact_parcial;
CREATE TABLE fact_parcial (
	fparcial_key int IDENTITY (1,1) NOT NULL ,
	numero_habitacion INT references Dim_parcial (numero_habitacion),
	name_huesped varchar(100) references Dim_parcialhuesped(name_huesped) ,
	cantdiasocupados int,
	cantdiastotal int,
	costo money,
	ingresos money
Primary key (fparcial_key, numero_habitacion,name_huesped)
);

select * from fact_parcial
select * from Dim_parcial

--consulta por detalle con not exist

select Hotel_Realta.dbo.Habitacion.numero_habitacion ,
ABS(DATEDIFF(DAY, Hotel_Realta.dbo.Habitacion.fecha_inauguracion, MAX(Hotel_Realta.Booking.booking_order_detail.borde_checkout) )) AS cant_diastotales,
ABS(DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout )) AS cant_diasocupados,
Hotel_Realta.dbo.Habitacion.costo*ABS(DATEDIFF(DAY, Hotel_Realta.dbo.Habitacion.fecha_inauguracion, Hotel_Realta.Booking.booking_order_detail.borde_checkout ))
as costo,
Hotel_Realta.Booking.booking_order_detail.borde_price*ABS(DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout )) 
 as ingreso
from Hotel_Realta.Booking.booking_order_detail, Hotel_Realta.dbo.Habitacion
where Hotel_Realta.dbo.Habitacion.habitacion_id = Hotel_Realta.Booking.booking_order_detail.habitacion_id /*AND NOT EXISTS (
    SELECT 1
    FROM Pruebas.dbo.fact_parcial
    WHERE  Hotel_Realta.dbo.Habitacion.numero_habitacion= fact_parcial.numero_habitacion )*/
group by Hotel_Realta.dbo.Habitacion.numero_habitacion, Hotel_Realta.dbo.Habitacion.fecha_inauguracion,
		 Hotel_Realta.Booking.booking_order_detail.borde_checkin, 
		 Hotel_Realta.Booking.booking_order_detail.borde_checkout,
		 Hotel_Realta.Booking.booking_order_detail.borde_price, 
		 Hotel_Realta.dbo.Habitacion.costo 

--por habitacion con not exist
select Hotel_Realta.dbo.Habitacion.numero_habitacion ,
ABS(DATEDIFF(DAY, Hotel_Realta.dbo.Habitacion.fecha_inauguracion, MAX(Hotel_Realta.Booking.booking_order_detail.borde_checkout) )) AS cant_diastotales,
SUM (DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout )) AS cant_diasocupados,
SUM (Hotel_Realta.dbo.Habitacion.costo*ABS(DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout ))) 
as costo,
SUM (Hotel_Realta.Booking.booking_order_detail.borde_price*ABS(DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout )) 
- Hotel_Realta.dbo.Habitacion.costo) as ingreso
from Hotel_Realta.Booking.booking_order_detail, Hotel_Realta.dbo.Habitacion
where Hotel_Realta.dbo.Habitacion.habitacion_id = Hotel_Realta.Booking.booking_order_detail.habitacion_id /*AND NOT EXISTS (
    SELECT 1
    FROM Pruebas.dbo.fact_parcial
    WHERE  Hotel_Realta.dbo.Habitacion.numero_habitacion= fact_parcial.numero_habitacion )*//
group by Hotel_Realta.dbo.Habitacion.numero_habitacion, Hotel_Realta.dbo.Habitacion.fecha_inauguracion,
		 Hotel_Realta.dbo.Habitacion.costo 

--por habitacion y huesped con not exist
select Hotel_Realta.Booking.booking_orders.boor_id, 
       Hotel_Realta.Booking.booking_order_detail.borde_id,
	   Hotel_Realta.dbo.Habitacion.numero_habitacion, 
	   Hotel_Realta.Users.users.user_full_name, 
DATEDIFF(DAY, Hotel_Realta.dbo.Habitacion.fecha_inauguracion, Hotel_Realta.Booking.booking_order_detail.borde_checkout ) AS cant_diastotales,
DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout ) AS cant_diasocupados,
Hotel_Realta.dbo.Habitacion.costo*DATEDIFF(DAY, Hotel_Realta.dbo.Habitacion.fecha_inauguracion, Hotel_Realta.Booking.booking_order_detail.borde_checkout ) 
as costo,
Hotel_Realta.Booking.booking_order_detail.borde_price*DATEDIFF(DAY, Hotel_Realta.Booking.booking_order_detail.borde_checkin, Hotel_Realta.Booking.booking_order_detail.borde_checkout ) as ingreso
from Hotel_Realta.Booking.booking_order_detail, 
	 Hotel_Realta.dbo.Habitacion , 
	 Hotel_Realta.Users.users , 
	 Hotel_Realta.Booking.booking_orders
where Hotel_Realta.dbo.Habitacion.habitacion_id = Hotel_Realta.Booking.booking_order_detail.habitacion_id
	  AND Hotel_Realta.Booking.booking_orders.boor_id = Hotel_Realta.Booking.booking_order_detail.borde_boor_id 
	  AND Hotel_Realta.Booking.booking_orders.boor_user_id= Hotel_Realta.Users.users.user_id
	/*AND NOT EXISTS (
    SELECT 1
    FROM Pruebas.dbo.fact_parcial
    WHERE  Hotel_Realta.dbo.Habitacion.numero_habitacion= fact_parcial.numero_habitacion 
	AND Hotel_Realta.Users.users.user_full_name = fact_parcial.name_huesped )*/
group by Hotel_Realta.dbo.Habitacion.numero_habitacion, Hotel_Realta.dbo.Habitacion.fecha_inauguracion, Hotel_Realta.dbo.Habitacion.costo,
			Hotel_Realta.Users.users.user_full_name,Hotel_Realta.Booking.booking_order_detail.borde_checkout,
			Hotel_Realta.Booking.booking_order_detail.borde_checkin,Hotel_Realta.Booking.booking_order_detail.borde_price,
			Hotel_Realta.Booking.booking_order_detail.borde_id,  Hotel_Realta.Booking.booking_orders.boor_id
order by --Hotel_Realta.Booking.booking_order_detail.borde_id
		  Hotel_Realta.dbo.Habitacion.numero_habitacion




