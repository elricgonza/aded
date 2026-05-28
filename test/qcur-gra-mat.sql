
select cur.id as cur_id, cur.curso, cur.paralelo,
		gra.id as gra_id, gra.grado, gra.nivel,
		mat.id as mat_id, mat.materia 
	from curso cur,
		grado gra,
		materia mat
	where cur.gra_id = gra.id
		and gra.id = mat.gra_id
	order by cur.curso, cur.gra_id, cur.paralelo, mat.id
	
--
select a.id as asi_id, 
		b.id as cur_id, b.curso, b.gra_id , b.paralelo,
		c.id as mat_id, c.materia ,
		d.id as pro_id, d.nombre, d.paterno 
	from asignado a, 
		curso b,
		materia c,
		profesor d
	where
		a.cur_id  = b.id
		and a.mat_id = c.id
		and a.pro_id = d.id 
		and a.cur_id = 17
		
--
select * --a.id as asi_id, a.cur_id 
	from asignado a
	where a.cur_id = 17