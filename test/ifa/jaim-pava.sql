select * from asignado where pro_id in (34, 39)

select * from inscrito where cur_id in (31,32);  --jaim esc
select * from inscrito where cur_id in (34);  --ludw

select * from nota where ins_id= 1133 --jaim
select * from nota where ins_id= 1137 --ludw
-------------------------------------------------------------------------------------------
--1 prof
select * from profesor order by act desc limit 10;   --jaim 34,  pava 41
--2 usr
select * from usuario order by act desc limit 7; -- pavar 14, jaim 10
--3 asoc prof usr

--gra
select * from grado order by act desc limit 5;  -- id 18 cant i,  --
--mat
select * from materia order by act desc limit 10;  -- id 55 hist cant, id 56 cant prelim --gra_id 18 (ambos)
--cur
select * from curso order by act desc limit 5;  -- id 35 cant inic -par A -gra_id 18
--asig (cur - mat)
select * from asignado order by act desc limit 10;  --   1ra parte (add 2 rows ok)
"id"	"cur_id"	"mat_id"	"pro_id"	"creado"	"act"	"usu_id"
206		35			56						"2026-08-28 00:00:00"	"2026-08-28 00:00:00"	1
205		35			55						"2026-08-28 00:00:00"	"2026-08-28 00:00:00"	1

select * from asignado order by act desc limit 10;  --   2da parte (complemented ok)
"id"	"cur_id"	"mat_id"	"pro_id"	"creado"	"act"	"usu_id"
206		35			56				41		"2026-08-28 00:00:00"	"2026-08-28 00:00:00"	1
205		35			55				41		"2026-08-28 00:00:00"	"2026-08-28 00:00:00"	1

-----alu
select * from alumno order by act desc limit 5
"id"	"nombre"	"paterno"	"materno"	"nacimiento"	"masculino"	"ci"	"direccion"	"email"	"activo"	"obs"	"usr_id_login"	"foto_ruta"	"creado"	"act"	"usu_id"
2021	"Nahomi"	"Vasquez"	"Gonzales"	"2011-05-05"	false	8877665	"V. Dolor #874 C. 123"	"moni@gm.com"	true				"2026-08-28 12:55:40.545423"	"2026-08-28 12:55:40.545426"	1
2020	"Elliete "	"Santa Cruz"	"Loza"	"2020-12-05"	false	998877	"C. Sat # 11"	"elli@gm.com"	true				"2026-08-28 12:54:39.215286"	"2026-08-28 12:54:39.215292"	1

--ins
select * from inscrito order by act desc limit 5
"id"	"alu_id"	"cur_id"	"reserva"	"inscrito"	"descuento"	"motivo_descuento"	"abandono"	"obs"	"creado"	"act"	"usu_id"
1139	2021	35	false	true	0		false		"2026-08-28 15:35:44.752067"	"2026-08-28 15:35:44.752071"	1
1138	2020	35	false	true	0		false		"2026-08-28 14:56:23.296897"	"2026-08-28 14:56:23.2969"	1

--not (inic not)
select * from nota order by act desc limit 5
"id"	"ins_id"	"mat_id"	"nota1"	"nota2"	"nota3"	"nota_final"	"nota_aprob"	"aprobado"	"obs"	"creado"	"act"	"usu_id"
3828	1139	56	0	0	0	0.0	51	false		"2026-08-28 15:40:04.139991"	"2026-08-28 15:40:04.139993"	1
3827	1139	55	0	0	0	0.0	51	false		"2026-08-28 15:40:04.138429"	"2026-08-28 15:40:04.138432"	1
3826	1138	56	0	0	0	0.0	51	false		"2026-08-28 15:40:04.136053"	"2026-08-28 15:40:04.136057"	1
3825	1138	55	0	0	0	0.0	51	false		"2026-08-28 15:40:04.092484"	"2026-08-28 15:40:04.092487"	1

--=========================================================================================================================

