--Crear dos tablas la de cuentas con id, saldo, la otra de movimientos con id, tipo de movimiento y -->
-->monto. Realizar un pa que: inserte en la tabla de movimientos y actualice el saldo en una transacción, CON TRIGGERS.
create table cuentas(
id_cuentas serial not null,
saldo numeric,
constraint pk_cuentas primary key (id_cuentas)
);
create table movimientos(
id_movimientos serial,
tipo_movimiento varchar(60),
monto_mov numeric,
id_cuentas integer,
constraint pk_movimientos primary key (id_movimientos),
constraint fk_movimientos_cuentas foreign key (id_cuentas)
	references cuentas(id_cuentas)
	on update cascade on delete cascade
);

insert into cuentas (id_cuentas, saldo) values (1, 6000.00);

select * from cuentas;

/*se crea la funcion*/
create or replace function actualiza_saldo()
returns trigger
as $$
begin                              /*con el new. hago referencia al insert de la tabla movimientos llevado a cabo abajo*/
update cuentas set saldo = saldo + new.monto_mov where id_cuentas = new.id_cuentas;
return new;

end $$ language 'plpgsql';

/*se crea el trigger*/
create trigger tg_actualiza_saldo
before insert
on movimientos
for each row
execute procedure actualiza_saldo();

/*pruebo el trigger*/
insert into movimientos (id_movimientos, tipo_movimiento, monto_mov, id_cuentas) values (1, 'ingreso', 1000.00, 1);

/*pruebo como quedan las tablas*/
select * from cuentas;
select * from movimientos;


---------------------------------------------------------------------------------------
--EL MISMO EJERCICIO PERO A LA INVERSA, que actualice en movimientos los cambios realizados en cuentas.

create table cuentas(
id_cuentas serial not null,
saldo numeric,
constraint pk_cuentas primary key (id_cuentas)
);
create table movimientos(
id_movimientos serial,
tipo_movimiento varchar(60),
monto_mov numeric,
id_cuentas integer,
constraint pk_movimientos primary key (id_movimientos),
constraint fk_movimientos_cuentas foreign key (id_cuentas)
	references cuentas(id_cuentas)
	on update cascade on delete cascade
);

insert into cuentas (id_cuentas, saldo) values (1, 6000.00);

select * from cuentas;

/*se crea la funcion*/
create or replace function actualiza_movimiento()
returns trigger
as $$
begin                              
insert into movimientos (id_movimientos, tipo_movimiento, monto_mov, id_cuentas) values (1, 'ingreso', new.saldo - saldo, new.id_cuentas);
return new;

end $$ language 'plpgsql';

/*se crea el trigger*/
create trigger tg_actualiza_movimiento
before insert
on cuentas
for each row
execute procedure actualiza_movimiento();

/*pruebo el trigger*/
update cuentas set saldo = 8000.00 where id_cuentas = 1;

/*pruebo como quedan las tablas*/
select * from movimientos; /*La tabla movimientos me aparece vacía, sin ningún registro, despues de revisarlo todo durante un rato, no consigo dar con cual puede ser el error.*/
select * from cuentas;

