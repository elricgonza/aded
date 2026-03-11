
--select * 	from curso c 

-- mats de un grado p 1 curs
select n.nivel, c.paralelo, g.grado, m.materia 
	from curso c, grado g , nivel n, mat m 
	where c.grado_id = g.id 
		and g.nivel_id = n.id
		and g.id = m.grado_id 
