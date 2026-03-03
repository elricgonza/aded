
------
delete from plan;
insert into plan (id, plan) values (1, 'Bach Hum');
insert into plan (id, plan) values (2, 'Bach Téc');
insert into plan (id, plan) values (3, 'Tecn Med');

/*
delete from plan where id=3;  --x  ok
update plan set id=9 where id=3  --x ok
update plan set id=3 where id=9  --x ok
select *
	from plan a, nivel b
	where a.id = b.id_plan
*/	

------
--insert into nivel (id, nivel, id_plan) values (1, 'Inic0', 0); --x ok
delete from nivel;
insert into nivel (id, nivel, id_plan) values (1, 'Inic', 1);
insert into nivel (id, nivel, id_plan) values (2, 'Prim', 1);
insert into nivel (id, nivel, id_plan) values (3, 'Sec', 1);

insert into nivel (id, nivel, id_plan) values (4, 'Inic', 3);
insert into nivel (id, nivel, id_plan) values (5, 'Basico', 3);
insert into nivel (id, nivel, id_plan) values (6, 'Interm', 3);

------
--insert into grado  (id, grado, id_nivel) values (1, 'pre k', 0);  --x ok
delete from grado;
insert into grado  (id, grado, id_nivel) values (1, 'pre k', 1);
insert into grado  (id, grado, id_nivel) values (2, 'kind', 1);

insert into grado  (id, grado, id_nivel) values (3, '1ro Prim', 2);
insert into grado  (id, grado, id_nivel) values (4, '2do Prim', 2);
insert into grado  (id, grado, id_nivel) values (5, '3ro Prim', 2);
insert into grado  (id, grado, id_nivel) values (6, '4to Prim', 2);
insert into grado  (id, grado, id_nivel) values (7, '5to Prim', 2);
insert into grado  (id, grado, id_nivel) values (8, '6to Prim', 2);

insert into grado  (id, grado, id_nivel) values (9, '1ro Sec', 3);
insert into grado  (id, grado, id_nivel) values (10, '2do Sec', 3);
insert into grado  (id, grado, id_nivel) values (11, '3ro Sec', 3);
insert into grado  (id, grado, id_nivel) values (12, '4to Sec', 3);
insert into grado  (id, grado, id_nivel) values (13, '5to Sec', 3);
insert into grado  (id, grado, id_nivel) values (14, '6to Sec', 3);

------
insert into grado  (id, grado, id_nivel) values (15, '1ro. Inic', 4);
insert into grado  (id, grado, id_nivel) values (16, '2do. Inic', 4);
insert into grado  (id, grado, id_nivel) values (17, '1ro. Bas', 5);
insert into grado  (id, grado, id_nivel) values (18, '2do. Bas', 5);
insert into grado  (id, grado, id_nivel) values (19, '1ro. Interm', 6);
insert into grado  (id, grado, id_nivel) values (20, '1ro. Interm', 6);
insert into grado  (id, grado, id_nivel) values (21, '3ro. Interm', 6);

--delete from grado where id_nivel = 9


--------
--insert into mat(id, materia, id_grado) values (1, 'mat chit', 50);	--x ok
--delete from materia

--inic
insert into mat(id, materia, id_grado) values (1, 'mat chit', 1);
insert into mat(id, materia, id_grado) values (2, 'mat mov', 1);

insert into mat(id, materia, id_grado) values (3, 'mat movis', 2);
insert into mat(id, materia, id_grado) values (4, 'mat capor', 2);
insert into mat(id, materia, id_grado) values (5, 'mat count', 2);

--prim
insert into mat(id, materia, id_grado) values (6, 'escrit', 3);
insert into mat(id, materia, id_grado) values (7, 'lect', 3);
insert into mat(id, materia, id_grado) values (8, 'ed fis', 3);

insert into mat(id, materia, id_grado) values (9, 'escrit', 4);
insert into mat(id, materia, id_grado) values (10, 'lect', 4);
insert into mat(id, materia, id_grado) values (11, 'ed fis', 4);

insert into mat(id, materia, id_grado) values (12, 'escrit', 5);
insert into mat(id, materia, id_grado) values (13, 'lect', 5);
insert into mat(id, materia, id_grado) values (14, 'ed fis', 5);

insert into mat(id, materia, id_grado) values (16, 'escrit', 6);
insert into mat(id, materia, id_grado) values (17, 'lect', 6);
insert into mat(id, materia, id_grado) values (18, 'ed fis', 6);

insert into mat(id, materia, id_grado) values (19, 'escrit', 7);
insert into mat(id, materia, id_grado) values (20, 'lect', 7);
insert into mat(id, materia, id_grado) values (21, 'ed fis', 7);
insert into mat(id, materia, id_grado) values (22, 'music', 7);

insert into mat(id, materia, id_grado) values (23, 'escrit', 8);
insert into mat(id, materia, id_grado) values (24, 'lect', 8);
insert into mat(id, materia, id_grado) values (25, 'ed fis', 8);
insert into mat(id, materia, id_grado) values (26, 'music', 8);


--sec
insert into mat(id, materia, id_grado) values (27, 'mat', 9);
insert into mat(id, materia, id_grado) values (28, 'lite', 9);
insert into mat(id, materia, id_grado) values (29, 'est soc', 9);
insert into mat(id, materia, id_grado) values (30, 'music', 9);

insert into mat(id, materia, id_grado) values (31, 'mat', 10);
insert into mat(id, materia, id_grado) values (32, 'lite', 10);
insert into mat(id, materia, id_grado) values (33, 'est soc', 10);
insert into mat(id, materia, id_grado) values (34, 'music', 10);

insert into mat(id, materia, id_grado) values (35, 'mat', 11);
insert into mat(id, materia, id_grado) values (36, 'lite', 11);
insert into mat(id, materia, id_grado) values (37, 'est soc', 11);
insert into mat(id, materia, id_grado) values (38, 'music', 11);

insert into mat(id, materia, id_grado) values (39, 'mat', 12);
insert into mat(id, materia, id_grado) values (40, 'lite', 12);
insert into mat(id, materia, id_grado) values (41, 'est soc', 12);
insert into mat(id, materia, id_grado) values (42, 'music', 12);

insert into mat(id, materia, id_grado) values (43, 'mat', 13);
insert into mat(id, materia, id_grado) values (44, 'lite', 13);
insert into mat(id, materia, id_grado) values (45, 'est soc', 13);
insert into mat(id, materia, id_grado) values (46, 'music', 13);
insert into mat(id, materia, id_grado) values (47, 'filos', 13);

insert into mat(id, materia, id_grado) values (48, 'mat', 14);
insert into mat(id, materia, id_grado) values (49, 'lite', 14);
insert into mat(id, materia, id_grado) values (50, 'est soc', 14);
insert into mat(id, materia, id_grado) values (51, 'music', 14);
insert into mat(id, materia, id_grado) values (52, 'filos', 14);


--
/*
ALTER TABLE ONLY public.nivel
   ADD CONSTRAINT nivel_id_plan_fkey FOREIGN KEY (id_plan) 
   REFERENCES public.plan(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.grado
   ADD CONSTRAINT grado_id_nivel_fkey FOREIGN KEY (id_nivel) 
   REFERENCES public.nivel(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.materia
   ADD CONSTRAINT materia_id_grado_fkey FOREIGN KEY (id_grado) 
   REFERENCES public.grado(id) ON UPDATE CASCADE ON DELETE RESTRICT;
*/
