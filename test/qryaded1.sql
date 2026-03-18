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

-- only erd
select *
  from asig, gra, cur, mat, prof
  where asig.cur_id = cur.id 
  			and cur.gra_id = gra.id
  		and asig.mat_id = mat.id 
		  	and gra.id = mat.gra_id
		and asig.prof_id = prof.id
		and gra.id = 10 and cur.paralelo = 'B'
	order by asig.id
	
