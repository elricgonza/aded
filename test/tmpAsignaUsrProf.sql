
select cur.id as cur_id, cur.curso, cur.paralelo,
		gra.id as gra_id, gra.grado, gra.nivel,
		mat.id as mat_id, mat.materia 
	from curso cur,
		grado gra,
		materia mat
	where cur.gra_id = gra.id
		and gra.id = mat.gra_id
	order by cur.curso, cur.gra_id, cur.paralelo, mat.id