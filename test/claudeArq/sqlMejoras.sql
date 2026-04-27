-- ÍNDICES ADICIONALES RECOMENDADOS
CREATE INDEX idx_ins_cur_id ON ins(cur_id);
CREATE INDEX idx_ins_est_id ON ins(est_id);
CREATE INDEX idx_cal_ins_id ON cal(ins_id);
CREATE INDEX idx_cal_mat_id ON cal(mat_id);
CREATE INDEX idx_pag_ins_id ON pag(ins_id);
CREATE INDEX idx_pag_pagado ON pag(pagado);
CREATE INDEX idx_asi_cur_id ON asi(cur_id);
CREATE INDEX idx_asi_pro_id ON asi(pro_id);
CREATE INDEX idx_usr_activo ON usr(activo);
CREATE INDEX idx_est_activo ON est(activo);

-- VISTAS ÚTILES
CREATE OR REPLACE VIEW v_estudiantes_activos AS
SELECT 
    e.id,
    e.nombre || ' ' || COALESCE(e.paterno, '') || ' ' || COALESCE(e.materno, '') as nombre_completo,
    e.ci,
    c.paralelo,
    g.grado,
    g.nivel,
    i.descu as descuento
FROM est e
INNER JOIN ins i ON e.id = i.est_id
INNER JOIN cur c ON i.cur_id = c.id
INNER JOIN gra g ON c.gra_id = g.id
WHERE e.activo = true AND i.inscrito = true AND i.abandono = false;

CREATE OR REPLACE VIEW v_resumen_pagos AS
SELECT 
    i.id as inscripcion_id,
    e.nombre || ' ' || e.paterno as estudiante,
    COUNT(p.id) as total_cuotas,
    COUNT(CASE WHEN p.pagado = true THEN 1 END) as cuotas_pagadas,
    COUNT(CASE WHEN p.pagado = false OR p.pagado IS NULL THEN 1 END) as cuotas_pendientes,
    SUM(p.cuota) as monto_total,
    SUM(CASE WHEN p.pagado = true THEN p.cuota ELSE 0 END) as monto_pagado,
    SUM(CASE WHEN p.pagado = false OR p.pagado IS NULL THEN p.cuota ELSE 0 END) as monto_pendiente
FROM ins i
INNER JOIN est e ON i.est_id = e.id
LEFT JOIN pag p ON i.id = p.ins_id
GROUP BY i.id, e.nombre, e.paterno;

-- FUNCIÓN: Generar plan de pagos automático
CREATE OR REPLACE FUNCTION fn_generar_plan_pagos(p_ins_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_cur_id INTEGER;
    v_cos_record RECORD;
    v_descu SMALLINT;
    v_cuota_final NUMERIC(10,2);
    v_registros INTEGER := 0;
BEGIN
    -- Obtener datos de inscripción
    SELECT cur_id, descu INTO v_cur_id, v_descu
    FROM ins WHERE id = p_ins_id;
    
    -- Obtener configuración de costos
    SELECT * INTO v_cos_record FROM cos WHERE cur_id = v_cur_id;
    
    -- Aplicar descuento
    v_cuota_final := v_cos_record.cuota * (1 - v_descu / 100.0);
    
    -- Generar cuotas
    FOR i IN 1..v_cos_record.nro_cuota LOOP
        INSERT INTO pag (ins_id, nro_cuota, cuota, pagado, creado, act)
        VALUES (p_ins_id, i, v_cuota_final, false, CURRENT_DATE, CURRENT_DATE);
        v_registros := v_registros + 1;
    END LOOP;
    
    RETURN v_registros;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Actualizar campo 'act' automáticamente
CREATE OR REPLACE FUNCTION actualizar_fecha_act()
RETURNS TRIGGER AS $$
BEGIN
    NEW.act = CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_est_act BEFORE UPDATE ON est
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_act();
    
CREATE TRIGGER trg_ins_act BEFORE UPDATE ON ins
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_act();
