# Procesos de Gestión Escolar

## 📚 Índice de Procesos

1. [Proceso de Inscripción](#proceso-inscripción)
2. [Proceso de Asignación de Materias](#proceso-asignacion)
3. [Proceso de Registro de Calificaciones](#proceso-calificaciones)
4. [Proceso de Control de Asistencia](#proceso-asistencia)
5. [Proceso de Gestión de Pagos](#proceso-pagos)
6. [Proceso de Generación de Reportes](#proceso-reportes)

---

## 1. Proceso de Inscripción {#proceso-inscripción}

### Flujo del Proceso

```
1. Verificar cupo disponible en curso
2. Registrar/Actualizar información del tutor
3. Registrar/Actualizar información del estudiante
4. Crear inscripción
5. Generar pagos iniciales (matrícula)
6. Generar pagos mensuales (pensiones)
```

### SQL de Ejemplo

```sql
-- 1. Verificar cupo disponible
SELECT fn_curso_lleno(1) as curso_lleno;

-- 2. Registrar tutor
INSERT INTO tutor (nombres, apellido_paterno, ci, telefono, email, parentesco)
VALUES ('Carlos', 'Mendoza', '1234567', '70123456', 'carlos@email.com', 'Padre')
RETURNING id;

-- 3. Registrar estudiante
INSERT INTO estudiante (
    codigo_estudiante, nombres, apellido_paterno, apellido_materno,
    ci, fecha_nacimiento, genero, tutor_id
)
VALUES (
    fn_generar_codigo_estudiante(),
    'Pedro', 'Mendoza', 'López',
    '9876543', '2013-05-15', 'M', 1
)
RETURNING id;

-- 4. Crear inscripción
INSERT INTO inscripcion (estudiante_id, curso_id, gestion_id, fecha_inscripcion)
VALUES (1, 1, 2, CURRENT_DATE)
RETURNING id;

-- 5. Registrar pago de matrícula
INSERT INTO pago (inscripcion_id, concepto_pago_id, monto, monto_total, estado)
VALUES (1, 1, 500.00, 500.00, 'Pendiente');

-- 6. Generar pagos mensuales automáticamente
SELECT fn_generar_pagos_mensuales(1, 2, 10); -- 10 meses de pensión
```

---

## 2. Proceso de Asignación de Materias {#proceso-asignacion}

### Flujo del Proceso

```
1. Seleccionar curso
2. Seleccionar materias según grado
3. Asignar profesor a cada materia
4. Definir horarios
```

### SQL de Ejemplo

```sql
-- Asignar materia a curso con profesor
INSERT INTO asignacion (curso_id, materia_id, profesor_id, gestion_id)
VALUES (1, 1, 1, 2); -- Matemáticas al curso 1, profesor 1

-- Definir horario
INSERT INTO horario (asignacion_id, dia_semana, hora_inicio, hora_fin, aula)
VALUES (1, 1, '08:00', '09:30', '101'); -- Lunes 8:00-9:30

-- Consultar carga de profesor
SELECT * FROM v_carga_profesores WHERE profesor_id = 1;
```

---

## 3. Proceso de Registro de Calificaciones {#proceso-calificaciones}

### Flujo del Proceso

```
1. Seleccionar inscripción y materia
2. Ingresar calificaciones por bimestre
3. Sistema calcula promedio automáticamente
4. Al finalizar gestión, calcular promedio final
```

### SQL de Ejemplo

```sql
-- Registrar calificaciones del 1er bimestre
INSERT INTO seguimiento (
    inscripcion_id, materia_id, asignacion_id, bimestre,
    evaluacion_1, evaluacion_2, evaluacion_3
)
VALUES (1, 1, 1, 1, 85, 90, 88);
-- El trigger calcula automáticamente promedio_bimestre y aprobado

-- Consultar rendimiento de estudiante
SELECT * FROM v_rendimiento_estudiantes WHERE estudiante_id = 1;

-- Calcular promedios finales al terminar gestión
SELECT sp_calcular_promedio_final();
```

---

## 4. Proceso de Control de Asistencia {#proceso-asistencia}

### Flujo del Proceso

```
1. Seleccionar curso y materia
2. Seleccionar fecha
3. Marcar asistencia para cada estudiante
   O usar registro masivo
```

### SQL de Ejemplo

```sql
-- Registrar asistencia individual
INSERT INTO asistencia (inscripcion_id, asignacion_id, fecha, estado)
VALUES (1, 1, '2025-02-15', 'Presente');

-- Registrar asistencia masiva (todos presentes)
SELECT fn_registrar_asistencia_masiva(1, '2025-02-15', 'Presente');

-- Actualizar asistencia específica
UPDATE asistencia
SET estado = 'Ausente', observaciones = 'Enfermedad justificada'
WHERE inscripcion_id = 1 AND fecha = '2025-02-15';

-- Consultar estadísticas de asistencia
SELECT * FROM v_asistencia_estudiantes WHERE estudiante_id = 1;

-- Reporte de ausencias del día
SELECT 
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    a.fecha,
    a.estado,
    a.observaciones
FROM asistencia a
INNER JOIN inscripcion i ON a.inscripcion_id = i.id
INNER JOIN estudiante e ON i.estudiante_id = e.id
WHERE a.fecha = CURRENT_DATE
AND a.estado IN ('Ausente', 'Tardanza')
ORDER BY a.estado, e.apellido_paterno;
```

---

## 5. Proceso de Gestión de Pagos {#proceso-pagos}

### Flujo del Proceso

```
1. Generar pagos al inscribir (automático)
2. Registrar pagos cuando se realizan
3. Actualizar estado de pagos vencidos
4. Generar reportes de morosidad
```

### SQL de Ejemplo

```sql
-- Registrar un pago
UPDATE pago
SET 
    fecha_pago = CURRENT_DATE,
    estado = 'Pagado',
    metodo_pago = 'Transferencia',
    numero_comprobante = 'TRANS-001234'
WHERE id = 1;

-- Aplicar descuento
UPDATE pago
SET 
    descuento = 50.00,
    monto_total = monto - 50.00
WHERE id = 1;

-- Actualizar pagos vencidos (ejecutar diariamente)
SELECT sp_actualizar_pagos_vencidos();

-- Consultar pagos pendientes por estudiante
SELECT * FROM v_pagos_estudiante
WHERE codigo_estudiante = 'EST20250001'
AND estado IN ('Pendiente', 'Vencido')
ORDER BY fecha_vencimiento;

-- Reporte de morosidad general
SELECT 
    estado,
    COUNT(*) as cantidad,
    SUM(monto_total) as monto_total
FROM pago
WHERE estado IN ('Pendiente', 'Vencido')
GROUP BY estado;

-- Estudiantes con pagos vencidos
SELECT DISTINCT
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    t.telefono as telefono_tutor,
    COUNT(p.id) as pagos_vencidos,
    SUM(p.monto_total) as deuda_total
FROM pago p
INNER JOIN inscripcion i ON p.inscripcion_id = i.id
INNER JOIN estudiante e ON i.estudiante_id = e.id
LEFT JOIN tutor t ON e.tutor_id = t.id
WHERE p.estado = 'Vencido'
GROUP BY e.id, e.codigo_estudiante, e.nombres, e.apellido_paterno, t.telefono
ORDER BY deuda_total DESC;
```

---

## 6. Proceso de Generación de Reportes {#proceso-reportes}

### Reportes Disponibles

#### 6.1 Reporte de Rendimiento Académico

```sql
-- Rendimiento general por curso
SELECT 
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    COUNT(DISTINCT i.estudiante_id) as total_estudiantes,
    ROUND(AVG(s.promedio_bimestre), 2) as promedio_curso,
    COUNT(CASE WHEN s.aprobado = TRUE THEN 1 END) as aprobados,
    COUNT(CASE WHEN s.aprobado = FALSE THEN 1 END) as reprobados
FROM curso c
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN inscripcion i ON c.id = i.curso_id
LEFT JOIN seguimiento s ON i.id = s.inscripcion_id
WHERE i.estado = 'Activo'
GROUP BY g.nivel, g.grado, c.paralelo
ORDER BY g.orden, c.paralelo;

-- Top 10 mejores estudiantes
SELECT 
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    ROUND(AVG(s.promedio_bimestre), 2) as promedio_general
FROM estudiante e
INNER JOIN inscripcion i ON e.id = i.estudiante_id
INNER JOIN curso c ON i.curso_id = c.id
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN seguimiento s ON i.id = s.inscripcion_id
WHERE i.estado = 'Activo'
GROUP BY e.id, e.codigo_estudiante, e.nombres, e.apellido_paterno, g.nivel, g.grado, c.paralelo
HAVING AVG(s.promedio_bimestre) IS NOT NULL
ORDER BY promedio_general DESC
LIMIT 10;
```

#### 6.2 Reporte de Asistencia

```sql
-- Estadísticas de asistencia por curso
SELECT 
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    COUNT(DISTINCT a.inscripcion_id) as estudiantes,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN a.estado = 'Presente' THEN 1 END) as presentes,
    COUNT(CASE WHEN a.estado = 'Ausente' THEN 1 END) as ausentes,
    ROUND(
        COUNT(CASE WHEN a.estado = 'Presente' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 
    2) as porcentaje_asistencia
FROM curso c
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN inscripcion i ON c.id = i.curso_id
LEFT JOIN asistencia a ON i.id = a.inscripcion_id
GROUP BY g.nivel, g.grado, c.paralelo
ORDER BY g.orden, c.paralelo;
```

#### 6.3 Reporte Financiero

```sql
-- Resumen financiero del mes actual
SELECT * FROM v_resumen_financiero
WHERE gestion = EXTRACT(YEAR FROM CURRENT_DATE);

-- Ingresos por día (último mes)
SELECT 
    DATE(p.fecha_pago) as fecha,
    COUNT(*) as cantidad_pagos,
    SUM(p.monto_total) as total_recaudado
FROM pago p
WHERE p.estado = 'Pagado'
AND p.fecha_pago >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(p.fecha_pago)
ORDER BY fecha DESC;
```

#### 6.4 Boleta de Calificaciones Individual

```sql
-- Boleta de un estudiante
SELECT 
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    ges.anio as gestion,
    m.nombre as materia,
    s.bimestre,
    s.evaluacion_1,
    s.evaluacion_2,
    s.evaluacion_3,
    s.promedio_bimestre,
    CASE WHEN s.aprobado THEN 'APROBADO' ELSE 'REPROBADO' END as estado
FROM estudiante e
INNER JOIN inscripcion i ON e.id = i.estudiante_id
INNER JOIN curso c ON i.curso_id = c.id
INNER JOIN grado g ON c.grado_id = g.id
INNER JOIN gestion ges ON i.gestion_id = ges.id
INNER JOIN seguimiento s ON i.id = s.inscripcion_id
INNER JOIN materia m ON s.materia_id = m.id
WHERE e.codigo_estudiante = 'EST20250001'
AND ges.activo = TRUE
ORDER BY m.nombre, s.bimestre;
```

---

## Consultas Útiles Adicionales

### Estudiantes sin Inscripción Activa

```sql
SELECT 
    e.codigo_estudiante,
    e.nombres || ' ' || e.apellido_paterno as estudiante,
    e.fecha_ingreso,
    t.telefono as telefono_tutor
FROM estudiante e
LEFT JOIN tutor t ON e.tutor_id = t.id
LEFT JOIN inscripcion i ON e.id = i.estudiante_id AND i.estado = 'Activo'
WHERE e.activo = TRUE
AND i.id IS NULL
ORDER BY e.fecha_ingreso DESC;
```

### Cursos con Baja Matrícula

```sql
SELECT 
    c.id,
    g.nivel || ' ' || g.grado || ' ' || c.paralelo as curso,
    c.capacidad_maxima,
    COUNT(i.id) as inscritos,
    c.capacidad_maxima - COUNT(i.id) as cupos_disponibles
FROM curso c
INNER JOIN grado g ON c.grado_id = g.id
LEFT JOIN inscripcion i ON c.id = i.curso_id AND i.estado = 'Activo'
WHERE c.activo = TRUE
GROUP BY c.id, g.nivel, g.grado, c.paralelo, c.capacidad_maxima
HAVING COUNT(i.id) < c.capacidad_maxima * 0.5
ORDER BY inscritos;
```

### Profesores con Mayor Carga Horaria

```sql
SELECT * FROM v_carga_profesores
ORDER BY horas_semanales_totales DESC
LIMIT 10;
```

---

## Mantenimiento y Tareas Programadas

### Tareas Diarias

```sql
-- Actualizar estado de pagos vencidos
SELECT sp_actualizar_pagos_vencidos();
```

### Tareas al Fin de Bimestre

```sql
-- Calcular promedios finales
SELECT sp_calcular_promedio_final();

-- Generar reportes de rendimiento
-- (usar consultas de la sección 6.1)
```

### Tareas al Fin de Gestión

```sql
-- Cambiar estado de inscripciones
UPDATE inscripcion
SET estado = 'Finalizado'
WHERE gestion_id = (SELECT id FROM gestion WHERE activo = TRUE);

-- Activar nueva gestión
UPDATE gestion SET activo = FALSE WHERE activo = TRUE;
UPDATE gestion SET activo = TRUE WHERE anio = 2026;
```
