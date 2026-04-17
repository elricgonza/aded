-- ============================================================================
-- VISTAS Y FUNCIONES ÚTILES
-- Sistema de Gestión Escolar
-- ============================================================================

-- ============================================================================
-- VISTAS ACADÉMICAS
-- ============================================================================

-- Vista: Información completa de estudiantes inscritos
CREATE OR REPLACE VIEW v_estudiantes_inscritos AS
SELECT 
    e.id as estudiante_id,
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno || ' ' || COALESCE(e.apellido_materno, '') as nombre_completo,
    e.ci,
    e.genero,
    e.fecha_nacimiento,
    EXTRACT(YEAR FROM AGE(e.fecha_nacimiento)) as edad,
    t.nombres || ' ' || t.apellido_paterno as tutor,
    t.telefono as telefono_tutor,
    i.id as inscripcion_id,
    c.id as curso_id,
    g.nivel,
    g.grado,
    c.paralelo,
    ges.anio as gestion,
    i.estado as estado_inscripcion,
    p.nombres || ' ' || p.apellido_paterno as profesor_tutor
FROM estudiante e
LEFT JOIN tutor t ON e.tutor_id = t.id
LEFT JOIN inscripcion i ON e.id = i.estudiante_id AND i.estado = 'Activo'
LEFT JOIN curso c ON i.curso_id = c.id
LEFT JOIN grado g ON c.grado_id = g.id
LEFT JOIN gestion ges ON i.gestion_id = ges.id
LEFT JOIN profesor p ON c.profesor_tutor_id = p.id
WHERE e.activo = TRUE;

-- Vista: Carga académica de profesores
CREATE OR REPLACE VIEW v_carga_profesores AS
SELECT 
    p.id as profesor_id,
    p.codigo_profesor,
    p.nombres || ' ' || p.apellido_paterno as profesor,
    p.especialidad,
    ges.anio as gestion,
    COUNT(DISTINCT a.curso_id) as total_cursos,
    COUNT(DISTINCT a.materia_id) as total_materias,
    STRING_AGG(DISTINCT m.nombre, ', ') as materias,
    SUM(m.horas_semanales) as horas_semanales_totales
FROM profesor p
INNER JOIN asignacion a ON p.id = a.profesor_id
INNER JOIN materia m ON a.materia_id = m.id
INNER JOIN gestion ges ON a.gestion_id = ges.id
WHERE a.activo = TRUE AND p.activo = TRUE
GROUP BY p.id, p.codigo_profesor, p.nombres, p.apellido_paterno, p.especialidad, ges.anio;

-- Vista: Rendimiento académico por estudiante
CREATE OR REPLACE VIEW v_rendimiento_estudiantes AS
SELECT 
    i.id as inscripcion_id,
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    ges.anio as gestion,
    COUNT(DISTINCT s.materia_id) as total_materias,
    COUNT(CASE WHEN s.aprobado = TRUE THEN 1 END) as materias_aprobadas,
    COUNT(CASE WHEN s.aprobado = FALSE THEN 1 END) as materias_reprobadas,
    ROUND(AVG(s.promedio_bimestre), 2) as promedio_general,
    CASE 
        WHEN COUNT(CASE WHEN s.aprobado = FALSE THEN 1 END) = 0 THEN 'Aprobado'
        ELSE 'Reprobado'
    END as estado_final
FROM inscripcion i
INNER JOIN estudiante e ON i.estudiante_id = e.id
INNER JOIN curso c ON i.curso_id = c.id
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN gestion ges ON i.gestion_id = ges.id
LEFT JOIN seguimiento s ON i.id = s.inscripcion_id
WHERE i.estado = 'Activo'
GROUP BY i.id, e.codigo_estudiante, e.nombres, e.apellido_paterno, g.nivel, g.grado, c.paralelo, ges.anio;

-- Vista: Asistencia por estudiante
CREATE OR REPLACE VIEW v_asistencia_estudiantes AS
SELECT 
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN a.estado = 'Presente' THEN 1 END) as presentes,
    COUNT(CASE WHEN a.estado = 'Ausente' THEN 1 END) as ausentes,
    COUNT(CASE WHEN a.estado = 'Tardanza' THEN 1 END) as tardanzas,
    COUNT(CASE WHEN a.estado = 'Justificado' THEN 1 END) as justificados,
    ROUND(
        (COUNT(CASE WHEN a.estado = 'Presente' THEN 1 END) * 100.0) / 
        NULLIF(COUNT(*), 0), 
    2) as porcentaje_asistencia
FROM inscripcion i
INNER JOIN estudiante e ON i.estudiante_id = e.id
INNER JOIN curso c ON i.curso_id = c.id
INNER JOIN grado g ON c.grado_id = g.id
LEFT JOIN asistencia a ON i.id = a.inscripcion_id
WHERE i.estado = 'Activo'
GROUP BY e.codigo_estudiante, e.nombres, e.apellido_paterno, g.nivel, g.grado, c.paralelo;

-- Vista: Horarios por curso
CREATE OR REPLACE VIEW v_horarios_curso AS
SELECT 
    c.id as curso_id,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    c.turno,
    CASE h.dia_semana
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END as dia,
    h.hora_inicio,
    h.hora_fin,
    m.nombre as materia,
    p.nombres || ' ' || p.apellido_paterno as profesor,
    h.aula
FROM curso c
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN asignacion a ON c.id = a.curso_id
INNER JOIN materia m ON a.materia_id = m.id
INNER JOIN profesor p ON a.profesor_id = p.id
LEFT JOIN horario h ON a.id = h.asignacion_id
WHERE h.activo = TRUE
ORDER BY c.id, h.dia_semana, h.hora_inicio;

-- ============================================================================
-- VISTAS FINANCIERAS
-- ============================================================================

-- Vista: Estado de pagos por estudiante
CREATE OR REPLACE VIEW v_pagos_estudiante AS
SELECT 
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    cp.nombre as concepto,
    p.monto,
    p.descuento,
    p.monto_total,
    p.fecha_vencimiento,
    p.fecha_pago,
    p.mes_correspondiente,
    p.estado,
    CASE 
        WHEN p.estado = 'Vencido' THEN p.fecha_vencimiento - CURRENT_DATE
        ELSE 0
    END as dias_vencidos
FROM inscripcion i
INNER JOIN estudiante e ON i.estudiante_id = e.id
INNER JOIN curso c ON i.curso_id = c.id
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN pago p ON i.id = p.inscripcion_id
INNER JOIN concepto_pago cp ON p.concepto_pago_id = cp.id
WHERE i.estado = 'Activo';

-- Vista: Resumen financiero por gestión
CREATE OR REPLACE VIEW v_resumen_financiero AS
SELECT 
    ges.anio as gestion,
    cp.nombre as concepto,
    COUNT(DISTINCT p.inscripcion_id) as total_estudiantes,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN p.estado = 'Pagado' THEN 1 END) as pagados,
    COUNT(CASE WHEN p.estado = 'Pendiente' THEN 1 END) as pendientes,
    COUNT(CASE WHEN p.estado = 'Vencido' THEN 1 END) as vencidos,
    SUM(CASE WHEN p.estado = 'Pagado' THEN p.monto_total ELSE 0 END) as monto_recaudado,
    SUM(CASE WHEN p.estado IN ('Pendiente', 'Vencido') THEN p.monto_total ELSE 0 END) as monto_pendiente,
    SUM(p.monto_total) as monto_total
FROM pago p
INNER JOIN inscripcion i ON p.inscripcion_id = i.id
INNER JOIN gestion ges ON i.gestion_id = ges.id
INNER JOIN concepto_pago cp ON p.concepto_pago_id = cp.id
GROUP BY ges.anio, cp.nombre;

-- ============================================================================
-- FUNCIONES DE NEGOCIO
-- ============================================================================

-- Función: Obtener edad de un estudiante
CREATE OR REPLACE FUNCTION fn_edad_estudiante(p_estudiante_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_edad INTEGER;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(fecha_nacimiento))
    INTO v_edad
    FROM estudiante
    WHERE id = p_estudiante_id;
    
    RETURN v_edad;
END;
$$ LANGUAGE plpgsql;

-- Función: Calcular promedio final de un estudiante en una gestión
CREATE OR REPLACE FUNCTION fn_promedio_final_estudiante(
    p_inscripcion_id INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    v_promedio NUMERIC;
BEGIN
    SELECT ROUND(AVG(promedio_bimestre), 2)
    INTO v_promedio
    FROM seguimiento
    WHERE inscripcion_id = p_inscripcion_id
    AND promedio_bimestre IS NOT NULL;
    
    RETURN COALESCE(v_promedio, 0);
END;
$$ LANGUAGE plpgsql;

-- Función: Verificar si un curso está lleno
CREATE OR REPLACE FUNCTION fn_curso_lleno(p_curso_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_inscritos INTEGER;
    v_capacidad INTEGER;
BEGIN
    SELECT COUNT(*), MAX(c.capacidad_maxima)
    INTO v_inscritos, v_capacidad
    FROM inscripcion i
    INNER JOIN curso c ON i.curso_id = c.id
    WHERE i.curso_id = p_curso_id
    AND i.estado = 'Activo'
    GROUP BY c.id;
    
    RETURN v_inscritos >= v_capacidad;
END;
$$ LANGUAGE plpgsql;

-- Función: Generar código de estudiante automático
CREATE OR REPLACE FUNCTION fn_generar_codigo_estudiante()
RETURNS VARCHAR AS $$
DECLARE
    v_anio VARCHAR(4);
    v_correlativo VARCHAR(4);
    v_codigo VARCHAR(20);
BEGIN
    v_anio := TO_CHAR(CURRENT_DATE, 'YYYY');
    
    SELECT LPAD((COUNT(*) + 1)::TEXT, 4, '0')
    INTO v_correlativo
    FROM estudiante
    WHERE codigo_estudiante LIKE v_anio || '%';
    
    v_codigo := 'EST' || v_anio || v_correlativo;
    
    RETURN v_codigo;
END;
$$ LANGUAGE plpgsql;

-- Función: Registrar asistencia masiva
CREATE OR REPLACE FUNCTION fn_registrar_asistencia_masiva(
    p_asignacion_id INTEGER,
    p_fecha DATE,
    p_estado VARCHAR DEFAULT 'Presente'
)
RETURNS INTEGER AS $$
DECLARE
    v_registros INTEGER := 0;
    v_inscripcion RECORD;
BEGIN
    -- Obtener todas las inscripciones del curso de la asignación
    FOR v_inscripcion IN 
        SELECT i.id
        FROM inscripcion i
        INNER JOIN asignacion a ON i.curso_id = a.curso_id
        WHERE a.id = p_asignacion_id
        AND i.estado = 'Activo'
    LOOP
        -- Insertar asistencia si no existe
        INSERT INTO asistencia (inscripcion_id, asignacion_id, fecha, estado)
        VALUES (v_inscripcion.id, p_asignacion_id, p_fecha, p_estado)
        ON CONFLICT (inscripcion_id, asignacion_id, fecha) DO NOTHING;
        
        v_registros := v_registros + 1;
    END LOOP;
    
    RETURN v_registros;
END;
$$ LANGUAGE plpgsql;

-- Función: Generar pagos mensuales para una inscripción
CREATE OR REPLACE FUNCTION fn_generar_pagos_mensuales(
    p_inscripcion_id INTEGER,
    p_concepto_pago_id INTEGER,
    p_meses INTEGER DEFAULT 10
)
RETURNS INTEGER AS $$
DECLARE
    v_monto NUMERIC;
    v_mes INTEGER;
    v_registros INTEGER := 0;
    v_fecha_vencimiento DATE;
BEGIN
    -- Obtener monto del concepto
    SELECT monto_base INTO v_monto
    FROM concepto_pago
    WHERE id = p_concepto_pago_id;
    
    -- Generar pagos para cada mes
    FOR v_mes IN 1..p_meses LOOP
        v_fecha_vencimiento := DATE_TRUNC('month', CURRENT_DATE) + 
                               INTERVAL '1 month' * (v_mes - 1) + 
                               INTERVAL '5 days'; -- Vence el día 5 de cada mes
        
        INSERT INTO pago (
            inscripcion_id,
            concepto_pago_id,
            monto,
            monto_total,
            fecha_vencimiento,
            mes_correspondiente,
            estado
        )
        VALUES (
            p_inscripcion_id,
            p_concepto_pago_id,
            v_monto,
            v_monto,
            v_fecha_vencimiento,
            v_mes,
            'Pendiente'
        );
        
        v_registros := v_registros + 1;
    END LOOP;
    
    RETURN v_registros;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ============================================================================

-- Procedimiento: Actualizar estado de pagos vencidos
CREATE OR REPLACE FUNCTION sp_actualizar_pagos_vencidos()
RETURNS INTEGER AS $$
DECLARE
    v_actualizados INTEGER;
BEGIN
    UPDATE pago
    SET estado = 'Vencido'
    WHERE estado = 'Pendiente'
    AND fecha_vencimiento < CURRENT_DATE;
    
    GET DIAGNOSTICS v_actualizados = ROW_COUNT;
    
    RETURN v_actualizados;
END;
$$ LANGUAGE plpgsql;

-- Procedimiento: Calcular promedio final por bimestres
CREATE OR REPLACE FUNCTION sp_calcular_promedio_final()
RETURNS VOID AS $$
BEGIN
    UPDATE seguimiento s1
    SET promedio_final = (
        SELECT AVG(s2.promedio_bimestre)
        FROM seguimiento s2
        WHERE s2.inscripcion_id = s1.inscripcion_id
        AND s2.materia_id = s1.materia_id
        AND s2.promedio_bimestre IS NOT NULL
    )
    WHERE s1.bimestre = 4; -- Solo actualizar en el 4to bimestre
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMENTARIOS
-- ============================================================================

COMMENT ON VIEW v_estudiantes_inscritos IS 'Vista completa de estudiantes inscritos con información de tutor y curso';
COMMENT ON VIEW v_carga_profesores IS 'Carga académica de profesores por gestión';
COMMENT ON VIEW v_rendimiento_estudiantes IS 'Rendimiento académico de estudiantes';
COMMENT ON VIEW v_asistencia_estudiantes IS 'Estadísticas de asistencia por estudiante';
COMMENT ON VIEW v_pagos_estudiante IS 'Estado de pagos por estudiante';
COMMENT ON VIEW v_resumen_financiero IS 'Resumen financiero por gestión y concepto';

COMMENT ON FUNCTION fn_edad_estudiante IS 'Calcula la edad de un estudiante';
COMMENT ON FUNCTION fn_promedio_final_estudiante IS 'Calcula el promedio final de un estudiante en una gestión';
COMMENT ON FUNCTION fn_curso_lleno IS 'Verifica si un curso alcanzó su capacidad máxima';
COMMENT ON FUNCTION fn_generar_codigo_estudiante IS 'Genera código automático para nuevo estudiante';
COMMENT ON FUNCTION fn_registrar_asistencia_masiva IS 'Registra asistencia para todos los estudiantes de un curso';
COMMENT ON FUNCTION fn_generar_pagos_mensuales IS 'Genera pagos mensuales para una inscripción';
