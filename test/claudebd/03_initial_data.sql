-- ============================================================================
-- DATOS INICIALES
-- Sistema de Gestión Escolar
-- ============================================================================

-- ============================================================================
-- 1. GESTIONES
-- ============================================================================

INSERT INTO gestion (anio, periodo, fecha_inicio, fecha_fin, activo) VALUES
(2024, 'Anual', '2024-02-01', '2024-11-30', FALSE),
(2025, 'Anual', '2025-02-01', '2025-11-30', TRUE),
(2026, 'Anual', '2026-02-01', '2026-11-30', FALSE);

-- ============================================================================
-- 2. GRADOS
-- ============================================================================

-- Primaria
INSERT INTO grado (nivel, grado, orden, descripcion) VALUES
('Primaria', '1ro de Primaria', 1, 'Primer año de educación primaria'),
('Primaria', '2do de Primaria', 2, 'Segundo año de educación primaria'),
('Primaria', '3ro de Primaria', 3, 'Tercer año de educación primaria'),
('Primaria', '4to de Primaria', 4, 'Cuarto año de educación primaria'),
('Primaria', '5to de Primaria', 5, 'Quinto año de educación primaria'),
('Primaria', '6to de Primaria', 6, 'Sexto año de educación primaria');

-- Secundaria
INSERT INTO grado (nivel, grado, orden, descripcion) VALUES
('Secundaria', '1ro de Secundaria', 7, 'Primer año de educación secundaria'),
('Secundaria', '2do de Secundaria', 8, 'Segundo año de educación secundaria'),
('Secundaria', '3ro de Secundaria', 9, 'Tercer año de educación secundaria'),
('Secundaria', '4to de Secundaria', 10, 'Cuarto año de educación secundaria'),
('Secundaria', '5to de Secundaria', 11, 'Quinto año de educación secundaria'),
('Secundaria', '6to de Secundaria', 12, 'Sexto año de educación secundaria');

-- ============================================================================
-- 3. MATERIAS
-- ============================================================================

-- Materias de Primaria
INSERT INTO materia (codigo, nombre, grado_id, area, horas_semanales) VALUES
-- 1ro Primaria
('MAT-P1-01', 'Matemáticas', 1, 'Matemáticas', 5),
('LEN-P1-01', 'Lenguaje y Comunicación', 1, 'Lenguaje', 5),
('CNA-P1-01', 'Ciencias Naturales', 1, 'Ciencias', 3),
('CSO-P1-01', 'Ciencias Sociales', 1, 'Sociales', 3),
('ART-P1-01', 'Artes Plásticas', 1, 'Artes', 2),
('MUS-P1-01', 'Música', 1, 'Artes', 2),
('EDF-P1-01', 'Educación Física', 1, 'Deportes', 2),

-- 2do Primaria
('MAT-P2-01', 'Matemáticas', 2, 'Matemáticas', 5),
('LEN-P2-01', 'Lenguaje y Comunicación', 2, 'Lenguaje', 5),
('CNA-P2-01', 'Ciencias Naturales', 2, 'Ciencias', 3),
('CSO-P2-01', 'Ciencias Sociales', 2, 'Sociales', 3),
('ART-P2-01', 'Artes Plásticas', 2, 'Artes', 2),
('MUS-P2-01', 'Música', 2, 'Artes', 2),
('EDF-P2-01', 'Educación Física', 2, 'Deportes', 2);

-- Materias de Secundaria
INSERT INTO materia (codigo, nombre, grado_id, area, horas_semanales) VALUES
-- 1ro Secundaria
('MAT-S1-01', 'Matemáticas', 7, 'Matemáticas', 6),
('LEN-S1-01', 'Lengua y Literatura', 7, 'Lenguaje', 5),
('FIS-S1-01', 'Física', 7, 'Ciencias', 4),
('QUI-S1-01', 'Química', 7, 'Ciencias', 4),
('BIO-S1-01', 'Biología', 7, 'Ciencias', 4),
('HIS-S1-01', 'Historia', 7, 'Sociales', 3),
('GEO-S1-01', 'Geografía', 7, 'Sociales', 3),
('ING-S1-01', 'Inglés', 7, 'Idiomas', 3),
('INF-S1-01', 'Informática', 7, 'Tecnología', 2),
('EDF-S1-01', 'Educación Física', 7, 'Deportes', 2),
('ART-S1-01', 'Artes', 7, 'Artes', 2);

-- ============================================================================
-- 4. CONCEPTOS DE PAGO
-- ============================================================================

INSERT INTO concepto_pago (codigo, nombre, descripcion, monto_base, tipo) VALUES
('MAT-001', 'Matrícula', 'Pago único anual de matrícula', 500.00, 'Único'),
('PEN-001', 'Pensión Mensual', 'Pago mensual de colegiatura', 350.00, 'Mensual'),
('UNI-001', 'Uniforme Escolar', 'Compra de uniforme escolar', 250.00, 'Único'),
('LIB-001', 'Libros y Material', 'Adquisición de libros y material escolar', 300.00, 'Único'),
('SEG-001', 'Seguro Escolar', 'Seguro médico escolar anual', 150.00, 'Anual'),
('TRA-001', 'Transporte Escolar', 'Servicio de transporte mensual', 200.00, 'Mensual'),
('ACT-001', 'Actividades Extracurriculares', 'Talleres y actividades', 100.00, 'Mensual'),
('COM-001', 'Comedor Escolar', 'Servicio de alimentación mensual', 180.00, 'Mensual');

-- ============================================================================
-- EJEMPLO DE DATOS DE PRUEBA
-- ============================================================================

-- Tutores de ejemplo
INSERT INTO tutor (nombres, apellido_paterno, apellido_materno, ci, telefono, email, parentesco) VALUES
('Juan Carlos', 'Pérez', 'López', '1234567', '70000001', 'juan.perez@email.com', 'Padre'),
('María Elena', 'García', 'Mamani', '1234568', '70000002', 'maria.garcia@email.com', 'Madre'),
('Roberto', 'Fernández', 'Quispe', '1234569', '70000003', 'roberto.fernandez@email.com', 'Padre');

-- Profesores de ejemplo
INSERT INTO profesor (codigo_profesor, nombres, apellido_paterno, apellido_materno, ci, fecha_nacimiento, genero, telefono, email, formacion, especialidad, fecha_contratacion) VALUES
('PROF20240001', 'Ana María', 'Rodríguez', 'Silva', '5678901', '1985-03-15', 'F', '71000001', 'ana.rodriguez@colegio.edu', 'Licenciatura en Matemáticas', 'Matemáticas', '2020-02-01'),
('PROF20240002', 'Carlos Eduardo', 'Morales', 'Choque', '5678902', '1982-07-20', 'M', '71000002', 'carlos.morales@colegio.edu', 'Licenciatura en Lengua y Literatura', 'Lenguaje', '2019-02-01'),
('PROF20240003', 'Patricia', 'Vargas', 'Condori', '5678903', '1988-11-10', 'F', '71000003', 'patricia.vargas@colegio.edu', 'Licenciatura en Ciencias Naturales', 'Ciencias', '2021-02-01'),
('PROF20240004', 'Miguel Ángel', 'Sánchez', 'Alanoca', '5678904', '1980-05-25', 'M', '71000004', 'miguel.sanchez@colegio.edu', 'Licenciatura en Historia', 'Sociales', '2018-02-01'),
('PROF20240005', 'Laura Beatriz', 'Gutiérrez', 'Apaza', '5678905', '1990-01-30', 'F', '71000005', 'laura.gutierrez@colegio.edu', 'Licenciatura en Educación Física', 'Deportes', '2022-02-01');

-- Estudiantes de ejemplo
INSERT INTO estudiante (codigo_estudiante, nombres, apellido_paterno, apellido_materno, ci, fecha_nacimiento, genero, telefono, tutor_id, fecha_ingreso) VALUES
('EST20250001', 'Luis Fernando', 'Pérez', 'García', '9876501', '2013-04-12', 'M', '72000001', 1, '2025-02-01'),
('EST20250002', 'Sofía Isabel', 'Fernández', 'Quispe', '9876502', '2013-08-25', 'F', '72000002', 3, '2025-02-01'),
('EST20250003', 'Diego Alejandro', 'García', 'López', '9876503', '2013-11-18', 'M', '72000003', 2, '2025-02-01');

-- Cursos de ejemplo (Gestión 2025)
INSERT INTO curso (grado_id, paralelo, gestion_id, aula, turno, capacidad_maxima, profesor_tutor_id) VALUES
(1, 'A', 2, '101', 'Mañana', 35, 1),  -- 1ro Primaria A
(1, 'B', 2, '102', 'Mañana', 35, 2),  -- 1ro Primaria B
(2, 'A', 2, '201', 'Mañana', 35, 3),  -- 2do Primaria A
(7, 'A', 2, '301', 'Tarde', 40, 4);   -- 1ro Secundaria A

-- Inscripciones de ejemplo
INSERT INTO inscripcion (estudiante_id, curso_id, gestion_id, fecha_inscripcion, estado) VALUES
(1, 1, 2, '2025-01-15', 'Activo'),  -- Luis en 1ro Primaria A
(2, 1, 2, '2025-01-16', 'Activo'),  -- Sofía en 1ro Primaria A
(3, 2, 2, '2025-01-17', 'Activo');  -- Diego en 1ro Primaria B

-- Asignaciones de ejemplo (materias al curso 1ro Primaria A)
INSERT INTO asignacion (curso_id, materia_id, profesor_id, gestion_id) VALUES
(1, 1, 1, 2),  -- Matemáticas
(1, 2, 2, 2),  -- Lenguaje
(1, 3, 3, 2),  -- Ciencias Naturales
(1, 4, 4, 2),  -- Ciencias Sociales
(1, 7, 5, 2);  -- Educación Física

-- Horarios de ejemplo
INSERT INTO horario (asignacion_id, dia_semana, hora_inicio, hora_fin, aula) VALUES
-- Lunes
(1, 1, '08:00', '09:30', '101'),  -- Matemáticas
(2, 1, '09:45', '11:15', '101'),  -- Lenguaje
-- Martes
(1, 2, '08:00', '09:30', '101'),  -- Matemáticas
(3, 2, '09:45', '11:15', '101'),  -- Ciencias Naturales
-- Miércoles
(2, 3, '08:00', '09:30', '101'),  -- Lenguaje
(4, 3, '09:45', '11:15', '101'),  -- Ciencias Sociales
-- Jueves
(1, 4, '08:00', '09:30', '101'),  -- Matemáticas
(5, 4, '09:45', '11:15', 'Cancha'),  -- Educación Física
-- Viernes
(2, 5, '08:00', '09:30', '101'),  -- Lenguaje
(3, 5, '09:45', '11:15', '101');  -- Ciencias Naturales

-- Seguimiento de ejemplo (1er bimestre)
INSERT INTO seguimiento (inscripcion_id, materia_id, asignacion_id, bimestre, evaluacion_1, evaluacion_2, evaluacion_3) VALUES
-- Luis Fernando
(1, 1, 1, 1, 85, 90, 88),  -- Matemáticas
(1, 2, 2, 1, 78, 82, 80),  -- Lenguaje
(1, 3, 3, 1, 92, 88, 90),  -- Ciencias Naturales
-- Sofía Isabel
(2, 1, 1, 1, 95, 92, 94),  -- Matemáticas
(2, 2, 2, 1, 88, 90, 89),  -- Lenguaje
(2, 3, 3, 1, 85, 87, 86);  -- Ciencias Naturales

-- Pagos de ejemplo
-- Generar matrícula para estudiantes inscritos
INSERT INTO pago (inscripcion_id, concepto_pago_id, monto, monto_total, fecha_pago, estado, metodo_pago, numero_comprobante)
SELECT 
    i.id,
    1,  -- Concepto: Matrícula
    500.00,
    500.00,
    i.fecha_inscripcion,
    'Pagado',
    'Efectivo',
    'COMP-' || LPAD(i.id::TEXT, 6, '0')
FROM inscripcion i
WHERE i.gestion_id = 2;

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Mostrar resumen de datos cargados
SELECT 'Gestiones' as tabla, COUNT(*) as registros FROM gestion
UNION ALL
SELECT 'Grados', COUNT(*) FROM grado
UNION ALL
SELECT 'Materias', COUNT(*) FROM materia
UNION ALL
SELECT 'Conceptos de Pago', COUNT(*) FROM concepto_pago
UNION ALL
SELECT 'Tutores', COUNT(*) FROM tutor
UNION ALL
SELECT 'Profesores', COUNT(*) FROM profesor
UNION ALL
SELECT 'Estudiantes', COUNT(*) FROM estudiante
UNION ALL
SELECT 'Cursos', COUNT(*) FROM curso
UNION ALL
SELECT 'Inscripciones', COUNT(*) FROM inscripcion
UNION ALL
SELECT 'Asignaciones', COUNT(*) FROM asignacion
UNION ALL
SELECT 'Horarios', COUNT(*) FROM horario
UNION ALL
SELECT 'Seguimiento', COUNT(*) FROM seguimiento
UNION ALL
SELECT 'Pagos', COUNT(*) FROM pago
ORDER BY tabla;
