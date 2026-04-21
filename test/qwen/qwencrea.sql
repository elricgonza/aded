--# Sistema de Gestión Escolar - Propuesta Completa

--## 📋 **Script SQL para Creación de Base de Datos (PostgreSQL)**

--```sql
-- =============================================
-- SISTEMA DE GESTIÓN ESCOLAR
-- Script de creación de base de datos PostgreSQL
-- =============================================

-- Eliminar base de datos si existe (solo para desarrollo)
-- DROP DATABASE IF EXISTS gestion_escolar;
-- CREATE DATABASE gestion_escolar;

-- Conectar a la base de datos
-- \c gestion_escolar

-- =============================================
-- EXTENSIONES NECESARIAS
-- =============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- TABLA: persona (Tabla base para estudiantes y profesores)
-- =============================================
CREATE TABLE persona (
    id_persona SERIAL PRIMARY KEY,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero VARCHAR(10) CHECK (genero IN ('M', 'F', 'O')),
    email VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN DEFAULT TRUE
);

-- Índices para persona
CREATE INDEX idx_persona_documento ON persona(tipo_documento, numero_documento);
CREATE INDEX idx_persona_email ON persona(email);
CREATE INDEX idx_persona_estado ON persona(estado);

-- =============================================
-- TABLA: estudiante
-- =============================================
CREATE TABLE estudiante (
    id_estudiante INTEGER PRIMARY KEY REFERENCES persona(id_persona) ON DELETE CASCADE,
    codigo_estudiante VARCHAR(20) UNIQUE NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado_academico VARCHAR(20) DEFAULT 'ACTIVO' 
        CHECK (estado_academico IN ('ACTIVO', 'INACTIVO', 'GRADUADO', 'SUSPENDIDO', 'RETIRADO')),
    promedio_general DECIMAL(3,2) DEFAULT 0.00 CHECK (promedio_general >= 0.00 AND promedio_general <= 20.00)
);

-- Índice para estudiante
CREATE INDEX idx_estudiante_codigo ON estudiante(codigo_estudiante);
CREATE INDEX idx_estudiante_estado ON estudiante(estado_academico);

-- =============================================
-- TABLA: profesor
-- =============================================
CREATE TABLE profesor (
    id_profesor INTEGER PRIMARY KEY REFERENCES persona(id_persona) ON DELETE CASCADE,
    codigo_profesor VARCHAR(20) UNIQUE NOT NULL,
    especialidad VARCHAR(100),
    departamento VARCHAR(100),
    titulo_academico VARCHAR(100),
    fecha_contratacion DATE NOT NULL,
    estado_laboral VARCHAR(20) DEFAULT 'ACTIVO'
        CHECK (estado_laboral IN ('ACTIVO', 'INACTIVO', 'VACACIONES', 'JUBILADO'))
);

-- Índice para profesor
CREATE INDEX idx_profesor_codigo ON profesor(codigo_profesor);
CREATE INDEX idx_profesor_estado ON profesor(estado_laboral);

-- =============================================
-- TABLA: periodo_academico
-- =============================================
CREATE TABLE periodo_academico (
    id_periodo SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo_periodo VARCHAR(20) NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'ACTIVO'
        CHECK (estado IN ('ACTIVO', 'INACTIVO', 'FINALIZADO')),
    CONSTRAINT chk_fechas CHECK (fecha_fin > fecha_inicio)
);

-- Índice para periodo_academico
CREATE INDEX idx_periodo_codigo ON periodo_academico(codigo_periodo);
CREATE INDEX idx_periodo_estado ON periodo_academico(estado);
CREATE INDEX idx_periodo_fechas ON periodo_academico(fecha_inicio, fecha_fin);

-- =============================================
-- TABLA: curso
-- =============================================
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    codigo_curso VARCHAR(20) NOT NULL UNIQUE,
    nivel VARCHAR(50) NOT NULL, -- Primaria, Secundaria, Bachillerato, Universidad, etc.
    duracion_meses INTEGER NOT NULL CHECK (duracion_meses > 0),
    costo_mensual DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (costo_mensual >= 0),
    descripcion TEXT,
    estado BOOLEAN DEFAULT TRUE
);

-- Índice para curso
CREATE INDEX idx_curso_codigo ON curso(codigo_curso);
CREATE INDEX idx_curso_nivel ON curso(nivel);
CREATE INDEX idx_curso_estado ON curso(estado);

-- =============================================
-- TABLA: materia
-- =============================================
CREATE TABLE materia (
    id_materia SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    codigo_materia VARCHAR(20) NOT NULL UNIQUE,
    creditos INTEGER NOT NULL DEFAULT 0 CHECK (creditos >= 0),
    horas_semanales INTEGER NOT NULL DEFAULT 0 CHECK (horas_semanales >= 0),
    descripcion TEXT,
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso) ON DELETE RESTRICT,
    estado BOOLEAN DEFAULT TRUE
);

-- Índices para materia
CREATE INDEX idx_materia_curso ON materia(id_curso);
CREATE INDEX idx_materia_codigo ON materia(codigo_materia);
CREATE INDEX idx_materia_estado ON materia(estado);

-- =============================================
-- TABLA: inscripcion
-- =============================================
CREATE TABLE inscripcion (
    id_inscripcion SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE RESTRICT,
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso) ON DELETE RESTRICT,
    id_periodo INTEGER NOT NULL REFERENCES periodo_academico(id_periodo) ON DELETE RESTRICT,
    fecha_inscripcion DATE DEFAULT CURRENT_DATE,
    estado VARCHAR(20) DEFAULT 'ACTIVA'
        CHECK (estado IN ('ACTIVA', 'CANCELADA', 'COMPLETADA', 'SUSPENDIDA', 'RETIRADA')),
    UNIQUE(id_estudiante, id_curso, id_periodo)
);

-- Índices para inscripcion
CREATE INDEX idx_inscripcion_estudiante ON inscripcion(id_estudiante);
CREATE INDEX idx_inscripcion_curso ON inscripcion(id_curso);
CREATE INDEX idx_inscripcion_periodo ON inscripcion(id_periodo);
CREATE INDEX idx_inscripcion_estado ON inscripcion(estado);
CREATE INDEX idx_inscripcion_fecha ON inscripcion(fecha_inscripcion);

-- =============================================
-- TABLA: asignacion_profesor
-- =============================================
CREATE TABLE asignacion_profesor (
    id_asignacion SERIAL PRIMARY KEY,
    id_profesor INTEGER NOT NULL REFERENCES profesor(id_profesor) ON DELETE RESTRICT,
    id_materia INTEGER NOT NULL REFERENCES materia(id_materia) ON DELETE RESTRICT,
    id_periodo INTEGER NOT NULL REFERENCES periodo_academico(id_periodo) ON DELETE RESTRICT,
    fecha_asignacion DATE DEFAULT CURRENT_DATE,
    estado VARCHAR(20) DEFAULT 'ACTIVA'
        CHECK (estado IN ('ACTIVA', 'FINALIZADA', 'CANCELADA')),
    observaciones TEXT,
    UNIQUE(id_profesor, id_materia, id_periodo)
);

-- Índices para asignacion_profesor
CREATE INDEX idx_asignacion_profesor ON asignacion_profesor(id_profesor);
CREATE INDEX idx_asignacion_materia ON asignacion_profesor(id_materia);
CREATE INDEX idx_asignacion_periodo ON asignacion_profesor(id_periodo);
CREATE INDEX idx_asignacion_estado ON asignacion_profesor(estado);

-- =============================================
-- TABLA: pago
-- =============================================
CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE RESTRICT,
    id_periodo INTEGER NOT NULL REFERENCES periodo_academico(id_periodo) ON DELETE RESTRICT,
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago DATE DEFAULT CURRENT_DATE,
    concepto VARCHAR(100) NOT NULL, -- Matrícula, Mensualidad, Inscripción, etc.
    metodo_pago VARCHAR(50) DEFAULT 'EFECTIVO'
        CHECK (metodo_pago IN ('EFECTIVO', 'TRANSFERENCIA', 'TARJETA', 'CHEQUE', 'PAYPAL')),
    estado VARCHAR(20) DEFAULT 'PENDIENTE'
        CHECK (estado IN ('PENDIENTE', 'PAGADO', 'CANCELADO', 'PARCIAL')),
    referencia VARCHAR(100), -- Número de transacción, cheque, etc.
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para pago
CREATE INDEX idx_pago_estudiante ON pago(id_estudiante);
CREATE INDEX idx_pago_periodo ON pago(id_periodo);
CREATE INDEX idx_pago_fecha ON pago(fecha_pago);
CREATE INDEX idx_pago_estado ON pago(estado);
CREATE INDEX idx_pago_concepto ON pago(concepto);

-- =============================================
-- TABLA: asistencia
-- =============================================
CREATE TABLE asistencia (
    id_asistencia SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE RESTRICT,
    id_materia INTEGER NOT NULL REFERENCES materia(id_materia) ON DELETE RESTRICT,
    id_periodo INTEGER NOT NULL REFERENCES periodo_academico(id_periodo) ON DELETE RESTRICT,
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'AUSENTE'
        CHECK (estado IN ('PRESENTE', 'AUSENTE', 'TARDANZA', 'JUSTIFICADO')),
    observaciones TEXT,
    UNIQUE(id_estudiante, id_materia, fecha)
);

-- Índices para asistencia
CREATE INDEX idx_asistencia_estudiante ON asistencia(id_estudiante);
CREATE INDEX idx_asistencia_materia ON asistencia(id_materia);
CREATE INDEX idx_asistencia_fecha ON asistencia(fecha);
CREATE INDEX idx_asistencia_periodo ON asistencia(id_periodo);
CREATE INDEX idx_asistencia_estado ON asistencia(estado);

-- =============================================
-- TABLA: calificacion
-- =============================================
CREATE TABLE calificacion (
    id_calificacion SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES estudiante(id_estudiante) ON DELETE RESTRICT,
    id_materia INTEGER NOT NULL REFERENCES materia(id_materia) ON DELETE RESTRICT,
    id_periodo INTEGER NOT NULL REFERENCES periodo_academico(id_periodo) ON DELETE RESTRICT,
    nota DECIMAL(3,2) NOT NULL 
        CHECK (nota >= 0.00 AND nota <= 20.00), -- Escala 0-20
    tipo_evaluacion VARCHAR(50) NOT NULL, -- Parcial, Final, Proyecto, Laboratorio, etc.
    fecha_evaluacion DATE NOT NULL,
    observaciones TEXT,
    UNIQUE(id_estudiante, id_materia, id_periodo, tipo_evaluacion)
);

-- Índices para calificacion
CREATE INDEX idx_calificacion_estudiante ON calificacion(id_estudiante);
CREATE INDEX idx_calificacion_materia ON calificacion(id_materia);
CREATE INDEX idx_calificacion_periodo ON calificacion(id_periodo);
CREATE INDEX idx_calificacion_tipo ON calificacion(tipo_evaluacion);
CREATE INDEX idx_calificacion_nota ON calificacion(nota);

-- =============================================
-- TABLA: rol (para gestión de permisos)
-- =============================================
CREATE TABLE rol (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN DEFAULT TRUE
);

-- Insertar roles predeterminados
INSERT INTO rol (nombre_rol, descripcion) VALUES
('ADMINISTRADOR', 'Acceso total al sistema'),
('SECRETARIA', 'Gestión de inscripciones, pagos y estudiantes'),
('PROFESOR', 'Gestión de materias asignadas, asistencia y calificaciones'),
('ESTUDIANTE', 'Visualización de su información académica'),
('DIRECTOR', 'Supervisión académica y reportes');

-- =============================================
-- TABLA: permiso
-- =============================================
CREATE TABLE permiso (
    id_permiso SERIAL PRIMARY KEY,
    nombre_permiso VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    categoria VARCHAR(50) NOT NULL, -- ESTUDIANTES, PROFESORES, ACADEMICO, FINANCIERO, SISTEMA
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar permisos predeterminados
INSERT INTO permiso (nombre_permiso, descripcion, categoria) VALUES
-- Permisos de ESTUDIANTES
('GESTION_ESTUDIANTES_VER', 'Ver listado de estudiantes', 'ESTUDIANTES'),
('GESTION_ESTUDIANTES_CREAR', 'Crear nuevos estudiantes', 'ESTUDIANTES'),
('GESTION_ESTUDIANTES_EDITAR', 'Editar información de estudiantes', 'ESTUDIANTES'),
('GESTION_ESTUDIANTES_ELIMINAR', 'Eliminar estudiantes', 'ESTUDIANTES'),

-- Permisos de PROFESORES
('GESTION_PROFESORES_VER', 'Ver listado de profesores', 'PROFESORES'),
('GESTION_PROFESORES_CREAR', 'Crear nuevos profesores', 'PROFESORES'),
('GESTION_PROFESORES_EDITAR', 'Editar información de profesores', 'PROFESORES'),
('GESTION_PROFESORES_ELIMINAR', 'Eliminar profesores', 'PROFESORES'),

-- Permisos ACADEMICOS
('GESTION_CURSOS_VER', 'Ver listado de cursos', 'ACADEMICO'),
('GESTION_CURSOS_CREAR', 'Crear nuevos cursos', 'ACADEMICO'),
('GESTION_MATERIAS_VER', 'Ver listado de materias', 'ACADEMICO'),
('GESTION_MATERIAS_CREAR', 'Crear nuevas materias', 'ACADEMICO'),
('GESTION_PERIODOS_VER', 'Ver periodos académicos', 'ACADEMICO'),
('GESTION_INSCRIPCIONES_VER', 'Ver inscripciones', 'ACADEMICO'),
('GESTION_INSCRIPCIONES_CREAR', 'Crear inscripciones', 'ACADEMICO'),
('GESTION_ASIGNACIONES_VER', 'Ver asignaciones de profesores', 'ACADEMICO'),
('GESTION_ASIGNACIONES_CREAR', 'Crear asignaciones de profesores', 'ACADEMICO'),

-- Permisos FINANCIEROS
('GESTION_PAGOS_VER', 'Ver pagos', 'FINANCIERO'),
('GESTION_PAGOS_CREAR', 'Registrar pagos', 'FINANCIERO'),
('GESTION_PAGOS_EDITAR', 'Editar pagos', 'FINANCIERO'),

-- Permisos de ASISTENCIA Y CALIFICACIONES
('GESTION_ASISTENCIA_VER', 'Ver asistencia', 'ACADEMICO'),
('GESTION_ASISTENCIA_CREAR', 'Registrar asistencia', 'ACADEMICO'),
('GESTION_CALIFICACIONES_VER', 'Ver calificaciones', 'ACADEMICO'),
('GESTION_CALIFICACIONES_CREAR', 'Registrar calificaciones', 'ACADEMICO'),
('GESTION_CALIFICACIONES_EDITAR', 'Editar calificaciones', 'ACADEMICO'),

-- Permisos del SISTEMA
('GESTION_USUARIOS_VER', 'Ver usuarios del sistema', 'SISTEMA'),
('GESTION_USUARIOS_CREAR', 'Crear usuarios', 'SISTEMA'),
('GESTION_ROLES_VER', 'Ver roles y permisos', 'SISTEMA'),
('GENERAR_REPORTES', 'Generar reportes del sistema', 'SISTEMA'),
('CONFIGURACION_SISTEMA', 'Configuración general del sistema', 'SISTEMA');

-- =============================================
-- TABLA: rol_permiso (relación muchos a muchos)
-- =============================================
CREATE TABLE rol_permiso (
    id_rol INTEGER REFERENCES rol(id_rol) ON DELETE CASCADE,
    id_permiso INTEGER REFERENCES permiso(id_permiso) ON DELETE CASCADE,
    PRIMARY KEY (id_rol, id_permiso)
);

-- Asignar permisos a roles predeterminados

-- ADMINISTRADOR (todos los permisos)
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso 
FROM rol r, permiso p 
WHERE r.nombre_rol = 'ADMINISTRADOR';

-- SECRETARIA
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso 
FROM rol r, permiso p 
WHERE r.nombre_rol = 'SECRETARIA'
AND p.categoria IN ('ESTUDIANTES', 'PROFESORES', 'ACADEMICO', 'FINANCIERO')
AND p.nombre_permiso NOT LIKE '%ELIMINAR%';

-- PROFESOR
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso 
FROM rol r, permiso p 
WHERE r.nombre_rol = 'PROFESOR'
AND p.nombre_permiso IN (
    'GESTION_MATERIAS_VER',
    'GESTION_ASISTENCIA_VER', 
    'GESTION_ASISTENCIA_CREAR',
    'GESTION_CALIFICACIONES_VER',
    'GESTION_CALIFICACIONES_CREAR',
    'GESTION_CALIFICACIONES_EDITAR'
);

-- ESTUDIANTE
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso 
FROM rol r, permiso p 
WHERE r.nombre_rol = 'ESTUDIANTE'
AND p.nombre_permiso IN ('GESTION_CALIFICACIONES_VER');

-- DIRECTOR
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso 
FROM rol r, permiso p 
WHERE r.nombre_rol = 'DIRECTOR'
AND p.categoria IN ('ACADEMICO', 'ESTUDIANTES', 'PROFESORES')
AND p.nombre_permiso LIKE '%VER%';

-- =============================================
-- TABLA: usuario
-- =============================================
CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    id_persona INTEGER NOT NULL UNIQUE REFERENCES persona(id_persona) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INTEGER NOT NULL REFERENCES rol(id_rol) ON DELETE RESTRICT,
    ultimo_acceso TIMESTAMP,
    intentos_fallidos INTEGER DEFAULT 0,
    bloqueado_hasta TIMESTAMP,
    estado BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para usuario
CREATE INDEX idx_usuario_username ON usuario(username);
CREATE INDEX idx_usuario_rol ON usuario(id_rol);
CREATE INDEX idx_usuario_estado ON usuario(estado);
CREATE INDEX idx_usuario_persona ON usuario(id_persona);

-- =============================================
-- TABLA: sesion (para control de sesiones activas)
-- =============================================
CREATE TABLE sesion (
    id_sesion UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario INTEGER NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP,
    activa BOOLEAN DEFAULT TRUE
);

-- Índices para sesion
CREATE INDEX idx_sesion_usuario ON sesion(id_usuario);
CREATE INDEX idx_sesion_activa ON sesion(activa);
CREATE INDEX idx_sesion_fecha ON sesion(fecha_inicio);

-- =============================================
-- VISTAS ÚTILES
-- =============================================

-- Vista: resumen_estudiante_completo
CREATE VIEW resumen_estudiante_completo AS
SELECT 
    e.id_estudiante,
    p.nombre,
    p.apellido,
    p.email,
    p.telefono,
    e.codigo_estudiante,
    c.nombre as curso,
    c.nivel,
    pa.nombre as periodo_actual,
    e.promedio_general,
    e.estado_academico,
    i.fecha_inscripcion,
    i.estado as estado_inscripcion
FROM estudiante e
JOIN persona p ON e.id_estudiante = p.id_persona
JOIN inscripcion i ON e.id_estudiante = i.id_estudiante
JOIN curso c ON i.id_curso = c.id_curso
JOIN periodo_academico pa ON i.id_periodo = pa.id_periodo
WHERE i.estado = 'ACTIVA';

-- Vista: resumen_profesor_completo
CREATE VIEW resumen_profesor_completo AS
SELECT 
    pr.id_profesor,
    p.nombre,
    p.apellido,
    p.email,
    p.telefono,
    pr.codigo_profesor,
    pr.especialidad,
    pr.departamento,
    pr.titulo_academico,
    pr.estado_laboral,
    COUNT(ap.id_asignacion) as materias_asignadas
FROM profesor pr
JOIN persona p ON pr.id_profesor = p.id_persona
LEFT JOIN asignacion_profesor ap ON pr.id_profesor = ap.id_profesor 
    AND ap.estado = 'ACTIVA'
GROUP BY pr.id_profesor, p.nombre, p.apellido, p.email, p.telefono, 
         pr.codigo_profesor, pr.especialidad, pr.departamento, 
         pr.titulo_academico, pr.estado_laboral;

-- Vista: rendimiento_academico_estudiante
CREATE VIEW rendimiento_academico_estudiante AS
SELECT 
    e.id_estudiante,
    p.nombre || ' ' || p.apellido as estudiante,
    c.nombre as curso,
    m.nombre as materia,
    pa.nombre as periodo,
    AVG(cal.nota) as promedio_materia,
    COUNT(cal.id_calificacion) as evaluaciones_realizadas,
    MAX(cal.fecha_evaluacion) as ultima_evaluacion
FROM estudiante e
JOIN persona p ON e.id_estudiante = p.id_persona
JOIN inscripcion i ON e.id_estudiante = i.id_estudiante
JOIN curso c ON i.id_curso = c.id_curso
JOIN calificacion cal ON e.id_estudiante = cal.id_estudiante
JOIN materia m ON cal.id_materia = m.id_materia
JOIN periodo_academico pa ON cal.id_periodo = pa.id_periodo
WHERE i.estado = 'ACTIVA'
GROUP BY e.id_estudiante, p.nombre, p.apellido, c.nombre, m.nombre, pa.nombre;

-- Vista: asistencia_por_estudiante
CREATE VIEW asistencia_por_estudiante AS
SELECT 
    e.id_estudiante,
    p.nombre || ' ' || p.apellido as estudiante,
    m.nombre as materia,
    pa.nombre as periodo,
    COUNT(CASE WHEN a.estado = 'PRESENTE' THEN 1 END) as presentes,
    COUNT(CASE WHEN a.estado = 'AUSENTE' THEN 1 END) as ausentes,
    COUNT(CASE WHEN a.estado = 'TARDANZA' THEN 1 END) as tardanzas,
    COUNT(a.id_asistencia) as total_clases,
    ROUND(
        COUNT(CASE WHEN a.estado = 'PRESENTE' THEN 1 END)::DECIMAL * 100 / 
        NULLIF(COUNT(a.id_asistencia), 0), 2
    ) as porcentaje_asistencia
FROM estudiante e
JOIN persona p ON e.id_estudiante = p.id_persona
JOIN asistencia a ON e.id_estudiante = a.id_estudiante
JOIN materia m ON a.id_materia = m.id_materia
JOIN periodo_academico pa ON a.id_periodo = pa.id_periodo
GROUP BY e.id_estudiante, p.nombre, p.apellido, m.nombre, pa.nombre;

-- =============================================
-- FUNCIONES Y PROCEDIMIENTOS ALMACENADOS
-- =============================================

-- Función: Actualizar promedio general de estudiante
CREATE OR REPLACE FUNCTION actualizar_promedio_estudiante(estudiante_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE estudiante 
    SET promedio_general = COALESCE((
        SELECT AVG(nota) 
        FROM calificacion 
        WHERE id_estudiante = estudiante_id
    ), 0.00)
    WHERE id_estudiante = estudiante_id;
END;
$$ LANGUAGE plpgsql;

-- Función: Verificar disponibilidad de profesor en periodo
CREATE OR REPLACE FUNCTION verificar_disponibilidad_profesor(
    profesor_id INTEGER, 
    periodo_id INTEGER, 
    horas_nuevas INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    horas_actuales INTEGER;
    max_horas INTEGER := 40; -- Máximo 40 horas semanales
BEGIN
    SELECT COALESCE(SUM(m.horas_semanales), 0)
    INTO horas_actuales
    FROM asignacion_profesor ap
    JOIN materia m ON ap.id_materia = m.id_materia
    WHERE ap.id_profesor = profesor_id 
    AND ap.id_periodo = periodo_id
    AND ap.estado = 'ACTIVA';
    
    RETURN (horas_actuales + horas_nuevas) <= max_horas;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- TRIGGERS PARA AUTOMATIZACIÓN
-- =============================================

-- Trigger: Actualizar promedio después de insertar/modificar calificación
CREATE OR REPLACE FUNCTION trigger_actualizar_promedio()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM actualizar_promedio_estudiante(NEW.id_estudiante);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calificacion_promedio
    AFTER INSERT OR UPDATE ON calificacion
    FOR EACH ROW EXECUTE FUNCTION trigger_actualizar_promedio();

-- Trigger: Auditoría de cambios en pagos sensibles
CREATE TABLE auditoria_pagos (
    id_auditoria SERIAL PRIMARY KEY,
    id_pago INTEGER,
    accion VARCHAR(10),
    usuario_modificacion INTEGER,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_anterior DECIMAL(10,2),
    monto_nuevo DECIMAL(10,2),
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20)
);

CREATE OR REPLACE FUNCTION trigger_auditoria_pagos()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_pagos 
        (id_pago, accion, usuario_modificacion, monto_anterior, monto_nuevo, estado_anterior, estado_nuevo)
        VALUES (
            OLD.id_pago,
            'UPDATE',
            NULL, -- Se debería obtener del contexto de la sesión
            OLD.monto,
            NEW.monto,
            OLD.estado,
            NEW.estado
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auditoria_pagos_mod
    AFTER UPDATE ON pago
    FOR EACH ROW 
    WHEN (OLD.monto <> NEW.monto OR OLD.estado <> NEW.estado)
    EXECUTE FUNCTION trigger_auditoria_pagos();

-- =============================================
-- DATOS DE PRUEBA (OPCIONAL - SOLO PARA DESARROLLO)
-- =============================================

/*
-- Insertar periodo académico de prueba
INSERT INTO persona (tipo_documento, numero_documento, nombre, apellido, fecha_nacimiento, genero, email, telefono, direccion) 
VALUES 
('DNI', '12345678', 'Juan', 'Pérez', '1990-05-15', 'M', 'juan.perez@email.com', '987654321', 'Av. Principal 123'),
('DNI', '87654321', 'María', 'García', '1985-08-20', 'F', 'maria.garcia@email.com', '987654322', 'Calle Secundaria 456');

-- Insertar estudiante y profesor
INSERT INTO estudiante (id_estudiante, codigo_estudiante, fecha_ingreso) 
VALUES (1, 'EST001', CURRENT_DATE);

INSERT INTO profesor (id_profesor, codigo_profesor, especialidad, fecha_contratacion) 
VALUES (2, 'PROF001', 'Matemáticas', CURRENT_DATE);

-- Insertar curso y materia
INSERT INTO curso (nombre, codigo_curso, nivel, duracion_meses, costo_mensual) 
VALUES ('Secundaria Completa', 'SEC001', 'Secundaria', 12, 200.00);

INSERT INTO materia (nombre, codigo_materia, creditos, horas_semanales, id_curso) 
VALUES ('Matemáticas Avanzadas', 'MAT001', 4, 6, 1);

-- Insertar periodo académico
INSERT INTO periodo_academico (nombre, codigo_periodo, fecha_inicio, fecha_fin) 
VALUES ('Año Académico 2026', '2026-A', '2026-03-01', '2026-12-15');

-- Insertar inscripción
INSERT INTO inscripcion (id_estudiante, id_curso, id_periodo) 
VALUES (1, 1, 1);

-- Insertar asignación de profesor
INSERT INTO asignacion_profesor (id_profesor, id_materia, id_periodo) 
VALUES (2, 1, 1);

-- Insertar usuario admin
INSERT INTO usuario (id_persona, username, password_hash, id_rol) 
VALUES (1, 'admin', '$2b$12$example_hash_here', 1);
*/
