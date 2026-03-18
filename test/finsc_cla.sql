-- Opción 1: PostgreSQL
-- =====================================================

-- Primero, limpiar la tabla INSC si es necesario
TRUNCATE TABLE INSC;

-- Resetear la secuencia del ID si existe
ALTER SEQUENCE insc_id_seq RESTART WITH 1;

-- Insertar inscripciones asignando ~45 alumnos por curso
WITH cursos_numerados AS (
    -- Numerar todos los cursos disponibles
    SELECT 
        id as cur_id,
        ROW_NUMBER() OVER (ORDER BY id) as curso_num
    FROM CUR
),
alumnos_numerados AS (
    -- Numerar todos los alumnos disponibles
    SELECT 
        id as alum_id,
        ROW_NUMBER() OVER (ORDER BY id) as alumno_num
    FROM ALUM
),
distribucion AS (
    -- Distribuir alumnos entre cursos (45 por curso)
    SELECT 
        a.alum_id,
        c.cur_id,
        -- Calcular a qué curso pertenece cada alumno
        CEIL(a.alumno_num / 45.0) as grupo_curso
    FROM alumnos_numerados a
    CROSS JOIN (SELECT COUNT(*) as total_cursos FROM CUR) tc
    CROSS JOIN cursos_numerados c
    WHERE c.curso_num = CEIL(a.alumno_num / 45.0)
        AND CEIL(a.alumno_num / 45.0) <= tc.total_cursos
)
INSERT INTO INSC (alum_id, cur_id, fecha_insc)
SELECT 
    d.alum_id,
    d.cur_id,
    -- Asignar fecha de inscripción cercana a la fecha de inicio del curso
    c.fecha_ini - INTERVAL '7 days' + 
        (random() * INTERVAL '6 days') as fecha_insc
FROM distribucion d
JOIN CUR c ON d.cur_id = c.id
ORDER BY d.cur_id, d.alum_id;

-- Verificar la distribución
SELECT 
    cur_id,
    COUNT(*) as total_alumnos
FROM INSC
GROUP BY cur_id
ORDER BY cur_id;
