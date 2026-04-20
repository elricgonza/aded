-- =============================================
-- BASE DE DATOS: GESTIÓN ESCOLAR (PostgreSQL 16+)
-- =============================================

-- 1. Tablas de seguridad (RBAC)
CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,           -- ej: 'admin', 'director', 'profesor', 'alumno', 'tesorero'
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE permisos (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(100) UNIQUE NOT NULL,          -- ej: 'ver_alumnos', 'editar_notas', 'gestionar_pagos'
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_roles (
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (usuario_id, rol_id)
);

CREATE TABLE role_permisos (
    rol_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permiso_id BIGINT NOT NULL REFERENCES permisos(id) ON DELETE CASCADE,
    PRIMARY KEY (rol_id, permiso_id)
);

-- 2. Tablas principales del sistema escolar
CREATE TABLE periodos_academicos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE alumnos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT UNIQUE REFERENCES usuarios(id) ON DELETE SET NULL,  -- relación 1:1 con usuario
    codigo_alumno VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    genero CHAR(1) CHECK (genero IN ('M','F','O')),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE profesores (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT UNIQUE REFERENCES usuarios(id) ON DELETE SET NULL,  -- relación 1:1 con usuario
    codigo_profesor VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE materias (
    id BIGSERIAL PRIMARY KEY,
    codigo_materia VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    creditos SMALLINT DEFAULT 4,
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE cursos (
    id BIGSERIAL PRIMARY KEY,
    materia_id BIGINT NOT NULL REFERENCES materias(id) ON DELETE RESTRICT,
    periodo_id BIGINT NOT NULL REFERENCES periodos_academicos(id) ON DELETE RESTRICT,
    profesor_id BIGINT NOT NULL REFERENCES profesores(id) ON DELETE RESTRICT,
    codigo_curso VARCHAR(30) UNIQUE NOT NULL,
    seccion CHAR(1) NOT NULL,
    horario TEXT,
    aula VARCHAR(50),
    capacidad SMALLINT DEFAULT 40,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE inscripciones (
    id BIGSERIAL PRIMARY KEY,
    alumno_id BIGINT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id BIGINT NOT NULL REFERENCES cursos(id) ON DELETE RESTRICT,
    fecha_inscripcion DATE DEFAULT CURRENT_DATE,
    estado VARCHAR(20) DEFAULT 'activa' CHECK (estado IN ('activa','retirada','finalizada')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(alumno_id, curso_id)
);

CREATE TABLE asistencias (
    id BIGSERIAL PRIMARY KEY,
    inscripcion_id BIGINT NOT NULL REFERENCES inscripciones(id) ON DELETE CASCADE,
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('presente','ausente','tarde','justificado')),
    observacion TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(inscripcion_id, fecha)
);

CREATE TABLE calificaciones (
    id BIGSERIAL PRIMARY KEY,
    inscripcion_id BIGINT NOT NULL REFERENCES inscripciones(id) ON DELETE CASCADE,
    tipo_evaluacion VARCHAR(50) NOT NULL,
    nota NUMERIC(4,2) CHECK (nota BETWEEN 0 AND 100),
    peso SMALLINT DEFAULT 1,
    fecha DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE pagos (
    id BIGSERIAL PRIMARY KEY,
    alumno_id BIGINT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    monto NUMERIC(10,2) NOT NULL,
    fecha_pago DATE DEFAULT CURRENT_DATE,
    concepto VARCHAR(100) NOT NULL,
    estado VARCHAR(20) DEFAULT 'pagado' CHECK (estado IN ('pendiente','pagado','rechazado')),
    referencia VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices de rendimiento
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_alumnos_usuario ON alumnos(usuario_id);
CREATE INDEX idx_profesores_usuario ON profesores(usuario_id);
CREATE INDEX idx_inscripciones_alumno ON inscripciones(alumno_id);
CREATE INDEX idx_inscripciones_curso ON inscripciones(curso_id);
CREATE INDEX idx_pagos_alumno ON pagos(alumno_id);

-- =============================================
-- Datos iniciales de ejemplo (roles y permisos)
-- =============================================
INSERT INTO roles (nombre, descripcion) VALUES
('admin', 'Administrador del sistema - acceso total'),
('director', 'Director académico'),
('profesor', 'Profesor - solo sus cursos'),
('alumno', 'Alumno - ver sus datos'),
('tesorero', 'Gestión de pagos y finanzas');

INSERT INTO permisos (codigo, descripcion) VALUES
('ver_alumnos', 'Ver lista y datos de alumnos'),
('editar_alumnos', 'Crear/editar alumnos'),
('ver_notas', 'Ver calificaciones'),
('editar_notas', 'Editar calificaciones'),
('gestionar_pagos', 'Registrar y ver pagos'),
('ver_asistencias', 'Ver asistencias'),
('gestionar_cursos', 'Crear y asignar cursos'),
('admin_usuarios', 'Gestionar usuarios y roles');

-- Asignar permisos a roles (ejemplo)
INSERT INTO role_permisos (rol_id, permiso_id)
SELECT r.id, p.id
FROM roles r, permisos p
WHERE r.nombre = 'admin';
