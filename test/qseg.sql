--q from -seg- test
select s.id, s.aprob, s.mat_id,
		i.fecha_insc,
		a.id, a.nombre, 
		c.id, c.paralelo,
		g.id, g.grado,
		m.id, m.materia
		, ai.id, --ai.mat_id, 
		p.id, p.nombre as nomp
	from seg s, insc i, cur c, alum a, gra g, asig ai, prof p, mat m
	where s.insc_id = i.id
		and i.cur_id = c.id --and c.id= 1
		and c.gra_id = g.id
		and ai.cur_id = c.id
			and s.mat_id = ai.mat_id
			and s.mat_id = m.id
		and i.alum_id = a.id and a.nombre= 'Fito'		
		and ai.prof_id = p.id
		and g.id = 1
		--and c.paralelo = 'B'