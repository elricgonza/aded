
------
insert into plan (id, plan) values (1, 'Bach Hum');
insert into plan (id, plan) values (2, 'Bach Téc');
insert into plan (id, plan) values (3, 'Tecn Med');

delete from plan where id=3;  --x  ok
update plan set id=9 where id=3  --x ok
update plan set id=3 where id=9  --x ok
select *
	from plan a, nivel b
	where a.id = b.id_plan

------
insert into nivel (id, nivel, id_plan) values (1, 'Inic', 0); --x ok

insert into nivel (id, nivel, id_plan) values (1, 'Inic', 1);
insert into nivel (id, nivel, id_plan) values (2, 'Prim', 1);
insert into nivel (id, nivel, id_plan) values (3, 'Sec', 1);

insert into nivel (id, nivel, id_plan) values (4, 'Inicial', 3);
insert into nivel (id, nivel, id_plan) values (5, 'Basico', 3);
insert into nivel (id, nivel, id_plan) values (6, 'Interm', 3);

------
insert into grado  (id, grado, id_nivel) values (1, 'pre k', 1);
insert into grado  (id, grado, id_nivel) values (2, 'kind', 1);

insert into grado  (id, grado, id_nivel) values (3, '1ro Bas', 2);
insert into grado  (id, grado, id_nivel) values (4, '2do Bas', 2);
insert into grado  (id, grado, id_nivel) values (5, '3ro Bas', 2);
insert into grado  (id, grado, id_nivel) values (6, '4to Bas', 2);
insert into grado  (id, grado, id_nivel) values (7, '5to Bas', 2);
insert into grado  (id, grado, id_nivel) values (8, '6to Bas', 2);

insert into grado  (id, grado, id_nivel) values (9, '1ro Sec', 3);
insert into grado  (id, grado, id_nivel) values (10, '2do Sec', 3);
insert into grado  (id, grado, id_nivel) values (11, '3ro Sec', 3);
insert into grado  (id, grado, id_nivel) values (12, '4to Sec', 3);
insert into grado  (id, grado, id_nivel) values (13, '5to Sec', 3);
insert into grado  (id, grado, id_nivel) values (14, '6to Sec', 3);

------
insert into grado  (id, grado, id_nivel) values (15, '1ro. Inic', 4);
insert into grado  (id, grado, id_nivel) values (16, '2do. Inic', 4);
insert into grado  (id, grado, id_nivel) values (17, '1ro. Básico', 5);
insert into grado  (id, grado, id_nivel) values (18, '2do. Básico', 5);
insert into grado  (id, grado, id_nivel) values (19, '1ro. Interm', 6);
insert into grado  (id, grado, id_nivel) values (20, '1ro. Interm', 6);

delete from grado where id_nivel = 9

ALTER TABLE "nivel"
ADD FOREIGN KEY("id") REFERENCES "grado"("id_nivel")
ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE "grado"
ADD FOREIGN KEY("id_nivel") REFERENCES "nivel"("id")
ON UPDATE CASCADE ON DELETE RESTRICT;


