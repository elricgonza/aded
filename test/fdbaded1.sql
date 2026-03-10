
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
	where a.id = b.plan_id
*/	

------
--insert into nivel (id, nivel, plan_id) values (1, 'Inic0', 0); --x ok
delete from nivel;
insert into nivel (id, nivel, plan_id) values (1, 'Inic', 1);
insert into nivel (id, nivel, plan_id) values (2, 'Prim', 1);
insert into nivel (id, nivel, plan_id) values (3, 'Sec', 1);

insert into nivel (id, nivel, plan_id) values (4, 'Inic', 3);
insert into nivel (id, nivel, plan_id) values (5, 'Basico', 3);
insert into nivel (id, nivel, plan_id) values (6, 'Interm', 3);

------
--insert into grado  (id, grado, nivel_id) values (1, 'pre k', 0);  --x ok
delete from grado;
insert into grado  (id, grado, nivel_id) values (1, 'pre k', 1);
insert into grado  (id, grado, nivel_id) values (2, 'kind', 1);

insert into grado  (id, grado, nivel_id) values (3, '1ro Prim', 2);
insert into grado  (id, grado, nivel_id) values (4, '2do Prim', 2);
insert into grado  (id, grado, nivel_id) values (5, '3ro Prim', 2);
insert into grado  (id, grado, nivel_id) values (6, '4to Prim', 2);
insert into grado  (id, grado, nivel_id) values (7, '5to Prim', 2);
insert into grado  (id, grado, nivel_id) values (8, '6to Prim', 2);

insert into grado  (id, grado, nivel_id) values (9, '1ro Sec', 3);
insert into grado  (id, grado, nivel_id) values (10, '2do Sec', 3);
insert into grado  (id, grado, nivel_id) values (11, '3ro Sec', 3);
insert into grado  (id, grado, nivel_id) values (12, '4to Sec', 3);
insert into grado  (id, grado, nivel_id) values (13, '5to Sec', 3);
insert into grado  (id, grado, nivel_id) values (14, '6to Sec', 3);

------
insert into grado  (id, grado, nivel_id) values (15, '1ro. Inic', 4);
insert into grado  (id, grado, nivel_id) values (16, '2do. Inic', 4);
insert into grado  (id, grado, nivel_id) values (17, '1ro. Bas', 5);
insert into grado  (id, grado, nivel_id) values (18, '2do. Bas', 5);
insert into grado  (id, grado, nivel_id) values (19, '1ro. Interm', 6);
insert into grado  (id, grado, nivel_id) values (20, '2do. Interm', 6);
insert into grado  (id, grado, nivel_id) values (21, '3ro. Interm', 6);

--delete from grado where nivel_id = 9


--------
--insert into mat(id, materia, grado_id) values (1, 'mat chit', 50);	--x ok
delete from mat;

--inic
insert into mat(id, materia, grado_id) values (1, 'mat chit', 1);
insert into mat(id, materia, grado_id) values (2, 'mat mov', 1);

insert into mat(id, materia, grado_id) values (3, 'mat movis', 2);
insert into mat(id, materia, grado_id) values (4, 'mat capor', 2);
insert into mat(id, materia, grado_id) values (5, 'mat count', 2);

--prim
insert into mat(id, materia, grado_id) values (6, 'escrit', 3);
insert into mat(id, materia, grado_id) values (7, 'lect', 3);
insert into mat(id, materia, grado_id) values (8, 'ed fis', 3);

insert into mat(id, materia, grado_id) values (9, 'escrit', 4);
insert into mat(id, materia, grado_id) values (10, 'lect', 4);
insert into mat(id, materia, grado_id) values (11, 'ed fis', 4);

insert into mat(id, materia, grado_id) values (12, 'escrit', 5);
insert into mat(id, materia, grado_id) values (13, 'lect', 5);
insert into mat(id, materia, grado_id) values (14, 'ed fis', 5);

insert into mat(id, materia, grado_id) values (16, 'escrit', 6);
insert into mat(id, materia, grado_id) values (17, 'lect', 6);
insert into mat(id, materia, grado_id) values (18, 'ed fis', 6);

insert into mat(id, materia, grado_id) values (19, 'escrit', 7);
insert into mat(id, materia, grado_id) values (20, 'lect', 7);
insert into mat(id, materia, grado_id) values (21, 'ed fis', 7);
insert into mat(id, materia, grado_id) values (22, 'music', 7);

insert into mat(id, materia, grado_id) values (23, 'escrit', 8);
insert into mat(id, materia, grado_id) values (24, 'lect', 8);
insert into mat(id, materia, grado_id) values (25, 'ed fis', 8);
insert into mat(id, materia, grado_id) values (26, 'music', 8);


--sec
insert into mat(id, materia, grado_id) values (27, 'mat', 9);
insert into mat(id, materia, grado_id) values (28, 'lite', 9);
insert into mat(id, materia, grado_id) values (29, 'est soc', 9);
insert into mat(id, materia, grado_id) values (30, 'music', 9);

insert into mat(id, materia, grado_id) values (31, 'mat', 10);
insert into mat(id, materia, grado_id) values (32, 'lite', 10);
insert into mat(id, materia, grado_id) values (33, 'est soc', 10);
insert into mat(id, materia, grado_id) values (34, 'music', 10);

insert into mat(id, materia, grado_id) values (35, 'mat', 11);
insert into mat(id, materia, grado_id) values (36, 'lite', 11);
insert into mat(id, materia, grado_id) values (37, 'est soc', 11);
insert into mat(id, materia, grado_id) values (38, 'music', 11);

insert into mat(id, materia, grado_id) values (39, 'mat', 12);
insert into mat(id, materia, grado_id) values (40, 'lite', 12);
insert into mat(id, materia, grado_id) values (41, 'est soc', 12);
insert into mat(id, materia, grado_id) values (42, 'music', 12);

insert into mat(id, materia, grado_id) values (43, 'mat', 13);
insert into mat(id, materia, grado_id) values (44, 'lite', 13);
insert into mat(id, materia, grado_id) values (45, 'est soc', 13);
insert into mat(id, materia, grado_id) values (46, 'music', 13);
insert into mat(id, materia, grado_id) values (47, 'filos', 13);

insert into mat(id, materia, grado_id) values (48, 'mat', 14);
insert into mat(id, materia, grado_id) values (49, 'lite', 14);
insert into mat(id, materia, grado_id) values (50, 'est soc', 14);
insert into mat(id, materia, grado_id) values (51, 'music', 14);
insert into mat(id, materia, grado_id) values (52, 'filos', 14);


--
/*
ALTER TABLE ONLY public.nivel
   ADD CONSTRAINT nivel_plan_id_fkey FOREIGN KEY (plan_id) 
   REFERENCES public.plan(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.grado
   ADD CONSTRAINT grado_nivel_id_fkey FOREIGN KEY (nivel_id) 
   REFERENCES public.nivel(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY public.materia
   ADD CONSTRAINT materia_grado_id_fkey FOREIGN KEY (grado_id) 
   REFERENCES public.grado(id) ON UPDATE CASCADE ON DELETE RESTRICT;
*/

--Tarea adm
--conformación de curso // generador de cursos
--proceso anual / otros (semestral, trimestral, etc)
delete from curso;

insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(1, 1, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(2, 1, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(3, 2, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(4, 2, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(5, 3, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(6, 3, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(7, 4, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(8, 4, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(9, 5, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(10, 5, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(11, 6, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(12, 6, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(13, 7, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(14, 7, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(15, 8, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(16, 8, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(17, 9, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(18, 9, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(19, 10, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(20, 10, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(21, 11, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(22, 11, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(23, 12, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(24, 12, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(25, 13, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(26, 13, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(27, 14, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(28, 14, 'B', 2025, '2025-01-01', '2025-12-31');


--ifalfa
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(29, 15, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(30, 15, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(31, 16, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(32, 16, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(33, 17, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(34, 17, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(35, 18, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(36, 18, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(37, 19, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(38, 19, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(39, 20, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(40, 20, 'B', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(41, 21, 'A', 2025, '2025-01-01', '2025-12-31');
insert into curso (id, grado_id, paralelo, gestion, fecha_ini, fecha_fin) values 
	(42, 21, 'B', 2025, '2025-01-01', '2025-12-31');

--prof
insert into prof(id, nombre, apellido, formacion) values (1, 'prof A', 'apellido A', 'formacion A');
insert into prof(id, nombre, apellido, formacion) values (2, 'prof B', 'apellido B', 'formacion B');
insert into prof(id, nombre, apellido, formacion) values (3, 'prof C', 'apellido C', 'formacion C');
insert into prof(id, nombre, apellido, formacion) values (4, 'prof D', 'apellido D', 'formacion D');
insert into prof(id, nombre, apellido, formacion) values (5, 'prof E', 'apellido E', 'formacion E');
insert into prof(id, nombre, apellido, formacion) values (6, 'prof F', 'apellido F', 'formacion F');
insert into prof(id, nombre, apellido, formacion) values (7, 'prof G', 'apellido G', 'formacion G');
insert into prof(id, nombre, apellido, formacion) values (8, 'prof H', 'apellido H', 'formacion H');
insert into prof(id, nombre, apellido, formacion) values (9, 'prof I', 'apellido I', 'formacion I');
insert into prof(id, nombre, apellido, formacion) values (10, 'prof J', 'apellido J', 'formacion J');
insert into prof(id, nombre, apellido, formacion) values (11, 'prof K', 'apellido K', 'formacion K');
insert into prof(id, nombre, apellido, formacion) values (12, 'prof L', 'apellido L', 'formacion L');
insert into prof(id, nombre, apellido, formacion) values (13, 'prof M', 'apellido M', 'formacion M');
insert into prof(id, nombre, apellido, formacion) values (14, 'prof N', 'apellido N', 'formacion N');

insert into prof(id, nombre, apellido, formacion) values (15, 'prof O', 'apellido O', 'formacion O');
insert into prof(id, nombre, apellido, formacion) values (16, 'prof P', 'apellido P', 'formacion P');
insert into prof(id, nombre, apellido, formacion) values (17, 'prof Q', 'apellido Q', 'formacion Q');
insert into prof(id, nombre, apellido, formacion) values (18, 'prof R', 'apellido R', 'formacion R');
insert into prof(id, nombre, apellido, formacion) values (19, 'prof S', 'apellido S', 'formacion S');
insert into prof(id, nombre, apellido, formacion) values (20, 'prof T', 'apellido T', 'formacion T');
insert into prof(id, nombre, apellido, formacion) values (21, 'prof U', 'apellido U', 'formacion U');
insert into prof(id, nombre, apellido, formacion) values (22, 'prof V', 'apellido V', 'formacion V');
insert into prof(id, nombre, apellido, formacion) values (23, 'prof W', 'apellido W', 'formacion W');
insert into prof(id, nombre, apellido, formacion) values (24, 'prof X', 'apellido X', 'formacion X');
insert into prof(id, nombre, apellido, formacion) values (25, 'prof Y', 'apellido Y', 'formacion Y');
insert into prof(id, nombre, apellido, formacion) values (26, 'prof Z', 'apellido Z', 'formacion Z');	
insert into prof(id, nombre, apellido, formacion) values (27, 'prof AA', 'apellido AA', 'formacion AA');
insert into prof(id, nombre, apellido, formacion) values (28, 'prof AB', 'apellido AB', 'formacion AB');
insert into prof(id, nombre, apellido, formacion) values (29, 'prof AC', 'apellido AC', 'formacion AC');

--asig
insert into asig(id, curso_id, mat_id, prof_id) values (1, 1, 1, 1);
insert into asig(id, curso_id, mat_id, prof_id) values (1, 1, 1, 0);
