--select * from nota;

select  ins.id as ins_id,
		cur.id as cur_id,  cur.curso, cur.paralelo, cur.gra_id, cur.gestion,
		pro.id as pro_id, pro.nombre || ' ' || pro.paterno as pro_, 
		alu.id as alu_id, alu.nombre || ' ' || alu.paterno || ' ' || alu.materno as alu_, alu.ci, alu.activo,
		mat.id as mat_id, mat.materia 
	from inscrito ins, alumno alu, curso cur, 
		asignado asi, materia mat, profesor pro
	where
		ins.cur_id = cur.id
		and cur.id = asi.cur_id
		and pro.id = asi.pro_id
		and mat.id = asi.mat_id
		and alu.id = ins.alu_id
		--and alu.id = 115 --i1
		--and curso = 's6'
		--and alu.id = 496
		and pro.nombre ilike '%jaime%'
	order by cur.id, pro.id, alu.id, mat.id
	
	
	