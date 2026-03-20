qryaded1

select * from cur
select * from niv
select * from gra

-- mats de un grado p 1 curs
select n.nivel, c.paralelo, g.grado, m.materia 
	from cur c, gra g , niv n, mat m 
	where c.gra_id = g.id 
		and g.niv_id = n.id
		and g.id = m.gra_id 

-- asig
select *
  from asig, gra
    left join cur on (asig.cur_id = cur.id and cur.gra_id = 10)
    left join mat on asig.mat_id = mat.id
    left join prof on asig.prof_id = prof.id

-- siguiendo erd
select *
  from asig, gra, cur, mat, prof
  where asig.cur_id = cur.id 
  			and cur.gra_id = gra.id
  		and asig.mat_id = mat.id 
		  	and gra.id = mat.gra_id
		and asig.prof_id = prof.id
		--and gra.id = 10 and cur.paralelo = 'B'
		and gra.id = 1 and cur.paralelo = 'A'
	order by asig.id
	
-- alums 2o b (gra 10, cur b)
select * from niv;


--ok alum del 2do Sec
select niv.nivel, gra.grado, cur.paralelo, cur.gestion, insc.fecha_insc, 
		alum.nombre
	from cur, gra, niv, insc, alum
	where cur.gra_id = gra.id
		and gra.niv_id = niv.id
		and insc.cur_id = cur.id
		and gra.grado = '2do Sec' --and cur.paralelo= 'B'
		and insc.alum_id = alum.id

--

