-- ============================================================================
-- SISTEMA DE GESTIÓN ESCOLAR
-- Base de Datos PostgreSQL
-- ============================================================================

-- Crear extensiones útiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. CATÁLOGOS BASE
-- ============================================================================

-- GESTION (Períodos escolares)
CREATE TABLE gestion (
    id SERIAL PRIMARY KEY,
    anio SMALLINT NOT NULL,
    periodo VARCHAR(50) NOT NULL, -- '1er Semestre', '2do Semestre', 'Anual'
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT gestion_uq UNIQUE(anio, periodo),
    CONSTRAINT gestion_fechas_ck CHECK (fecha_fin > fecha_inicio)
);

-- GRADO (Niveles educativos)
CREATE TABLE grado (
    id SERIAL PRIMARY KEY,
    nivel VARCHAR(50) NOT NULL, -- 'Primaria', 'Secundaria'
    grado VARCHAR(50) NOT NULL, -- '1ro', '2do', '3ro', etc.
    orden SMALLINT NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT grado_uq UNIQUE(nivel, grado)
);

-- MATERIA
CREATE TABLE materia (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    grado_id INTEGER REFERENCES grado(id),
    area VARCHAR(100), -- 'Matemáticas', 'Ciencias', 'Lenguaje', etc.
    horas_semanales SMALLINT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. PERSONAS
-- ============================================================================

-- TUTOR (Padres/Apoderados)
CREATE TABLE tutor (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    ci VARCHAR(20),
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    ocupacion VARCHAR(100),
    parentesco VARCHAR(50), -- 'Padre', 'Madre', 'Tutor', etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ESTUDIANTE
CREATE TABLE estudiante (
    id SERIAL PRIMARY KEY,
    codigo_estudiante VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    ci VARCHAR(20) UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) CHECK (genero IN ('M', 'F')),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    foto_url VARCHAR(255),
    tutor_id INTEGER REFERENCES tutor(id),
    fecha_ingreso DATE DEFAULT CURRENT_DATE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PROFESOR
CREATE TABLE profesor (
    id SERIAL PRIMARY KEY,
    codigo_profesor VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    ci VARCHAR(20) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) CHECK (genero IN ('M', 'F')),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    formacion VARCHAR(200), -- 'Licenciatura en Matemáticas', etc.
    especialidad VARCHAR(200),
    fecha_contratacion DATE DEFAULT CURRENT_DATE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. ORGANIZACIÓN ACADÉMICA
-- ============================================================================

-- CURSO
CREATE TABLE curso (
    id SERIAL PRIMARY KEY,
    grado_id INTEGER NOT NULL REFERENCES grado(id),
    paralelo VARCHAR(50) NOT NULL,
    gestion_id INTEGER NOT NULL REFERENCES gestion(id),
    aula VARCHAR(50),
    turno VARCHAR(20) CHECK (turno IN ('Mañana', 'Tarde', 'Noche')),
    capacidad_maxima SMALLINT DEFAULT 40,
    profesor_tutor_id INTEGER REFERENCES profesor(id),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT curso_uq UNIQUE(grado_id, paralelo, gestion_id)
);

-- INSCRIPCION
CREATE TABLE inscripcion (
    id SERIAL PRIMARY KEY,
    estudiante_id INTEGER NOT NULL REFERENCES estudiante(id),
    curso_id INTEGER NOT NULL REFERENCES curso(id),
    gestion_id INTEGER NOT NULL REFERENCES gestion(id),
    fecha_inscripcion DATE DEFAULT CURRENT_DATE,
    estado VARCHAR(20) DEFAULT 'Activo' CHECK (estado IN ('Activo', 'Retirado', 'Trasladado', 'Finalizado')),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT inscripcion_uq UNIQUE(estudiante_id, gestion_id)
);

-- ASIGNACION (Profesor-Materia-Curso)
CREATE TABLE asignacion (
    id SERIAL PRIMARY KEY,
    curso_id INTEGER NOT NULL REFERENCES curso(id),
    materia_id INTEGER NOT NULL REFERENCES materia(id),
    profesor_id INTEGER NOT NULL REFERENCES profesor(id),
    gestion_id INTEGER NOT NULL REFERENCES gestion(id),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT asignacion_uq UNIQUE(curso_id, materia_id, gestion_id)
);

-- ============================================================================
-- 4. ACADÉMICO
-- ============================================================================

-- SEGUIMIENTO (Calificaciones)
CREATE TABLE seguimiento (
    id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER NOT NULL REFERENCES inscripcion(id),
    materia_id INTEGER NOT NULL REFERENCES materia(id),
    asignacion_id INTEGER REFERENCES asignacion(id),
    bimestre SMALLINT CHECK (bimestre BETWEEN 1 AND 4),
    evaluacion_1 SMALLINT CHECK (evaluacion_1 BETWEEN 0 AND 100),
    evaluacion_2 SMALLINT CHECK (evaluacion_2 BETWEEN 0 AND 100),
    evaluacion_3 SMALLINT CHECK (evaluacion_3 BETWEEN 0 AND 100),
    promedio_bimestre NUMERIC(5,2),
    promedio_final NUMERIC(5,2),
    aprobado BOOLEAN,
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT seguimiento_uq UNIQUE(inscripcion_id, materia_id, bimestre)
);

-- ASISTENCIA
CREATE TABLE asistencia (
    id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER NOT NULL REFERENCES inscripcion(id),
    asignacion_id INTEGER REFERENCES asignacion(id),
    fecha DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'Presente' CHECK (estado IN ('Presente', 'Ausente', 'Tardanza', 'Justificado')),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT asistencia_uq UNIQUE(inscripcion_id, asignacion_id, fecha)
);

-- HORARIO
CREATE TABLE horario (
    id SERIAL PRIMARY KEY,
    asignacion_id INTEGER NOT NULL REFERENCES asignacion(id),
    dia_semana SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7), -- 1=Lunes, 7=Domingo
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    aula VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT horario_ck CHECK (hora_fin > hora_inicio)
);

-- ============================================================================
-- 5. FINANCIERO
-- ============================================================================

-- CONCEPTO_PAGO
CREATE TABLE concepto_pago (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    monto_base NUMERIC(10,2) NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('Único', 'Mensual', 'Anual', 'Variable')),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PAGO
CREATE TABLE pago (
    id SERIAL PRIMARY KEY,
    inscripcion_id INTEGER NOT NULL REFERENCES inscripcion(id),
    concepto_pago_id INTEGER NOT NULL REFERENCES concepto_pago(id),
    monto NUMERIC(10,2) NOT NULL,
    descuento NUMERIC(10,2) DEFAULT 0,
    monto_total NUMERIC(10,2) NOT NULL,
    fecha_pago DATE,
    fecha_vencimiento DATE,
    mes_correspondiente SMALLINT CHECK (mes_correspondiente BETWEEN 1 AND 12),
    metodo_pago VARCHAR(30) CHECK (metodo_pago IN ('Efectivo', 'Transferencia', 'Tarjeta', 'QR')),
    numero_comprobante VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Pagado', 'Vencido', 'Anulado')),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 6. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================================

-- Estudiante
CREATE INDEX idx_estudiante_activo ON estudiante(activo);
CREATE INDEX idx_estudiante_tutor ON estudiante(tutor_id);

-- Inscripción
CREATE INDEX idx_inscripcion_estudiante ON inscripcion(estudiante_id);
CREATE INDEX idx_inscripcion_curso ON inscripcion(curso_id);
CREATE INDEX idx_inscripcion_gestion ON inscripcion(gestion_id);
CREATE INDEX idx_inscripcion_estado ON inscripcion(estado);

-- Asignación
CREATE INDEX idx_asignacion_curso ON asignacion(curso_id);
CREATE INDEX idx_asignacion_materia ON asignacion(materia_id);
CREATE INDEX idx_asignacion_profesor ON asignacion(profesor_id);

-- Seguimiento
CREATE INDEX idx_seguimiento_inscripcion ON seguimiento(inscripcion_id);
CREATE INDEX idx_seguimiento_materia ON seguimiento(materia_id);
CREATE INDEX idx_seguimiento_bimestre ON seguimiento(bimestre);

-- Asistencia
CREATE INDEX idx_asistencia_inscripcion ON asistencia(inscripcion_id);
CREATE INDEX idx_asistencia_fecha ON asistencia(fecha);
CREATE INDEX idx_asistencia_estado ON asistencia(estado);

-- Pago
CREATE INDEX idx_pago_inscripcion ON pago(inscripcion_id);
CREATE INDEX idx_pago_estado ON pago(estado);
CREATE INDEX idx_pago_fecha_pago ON pago(fecha_pago);
CREATE INDEX idx_pago_mes ON pago(mes_correspondiente);

-- ============================================================================
-- 7. TRIGGERS Y FUNCIONES
-- ============================================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas que necesitan updated_at
CREATE TRIGGER trg_inscripcion_updated
    BEFORE UPDATE ON inscripcion
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_timestamp();

CREATE TRIGGER trg_seguimiento_updated
    BEFORE UPDATE ON seguimiento
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_timestamp();

CREATE TRIGGER trg_pago_updated
    BEFORE UPDATE ON pago
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_timestamp();

-- Función para calcular promedio en seguimiento
CREATE OR REPLACE FUNCTION calcular_promedio_seguimiento()
RETURNS TRIGGER AS $$
BEGIN
    -- Calcular promedio del bimestre
    NEW.promedio_bimestre = (
        COALESCE(NEW.evaluacion_1, 0) + 
        COALESCE(NEW.evaluacion_2, 0) + 
        COALESCE(NEW.evaluacion_3, 0)
    ) / 3.0;
    
    -- Determinar si aprobó (nota >= 51)
    NEW.aprobado = (NEW.promedio_bimestre >= 51);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_seguimiento_calcular_promedio
    BEFORE INSERT OR UPDATE ON seguimiento
    FOR EACH ROW
    EXECUTE FUNCTION calcular_promedio_seguimiento();

-- Función para calcular monto total del pago
CREATE OR REPLACE FUNCTION calcular_monto_total_pago()
RETURNS TRIGGER AS $$
BEGIN
    NEW.monto_total = NEW.monto - COALESCE(NEW.descuento, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pago_calcular_total
    BEFORE INSERT OR UPDATE ON pago
    FOR EACH ROW
    EXECUTE FUNCTION calcular_monto_total_pago();

-- ============================================================================
-- COMENTARIOS EN TABLAS
-- ============================================================================

COMMENT ON TABLE gestion IS 'Períodos escolares (años y semestres)';
COMMENT ON TABLE grado IS 'Niveles educativos (primaria, secundaria, etc.)';
COMMENT ON TABLE materia IS 'Asignaturas del plan de estudios';
COMMENT ON TABLE estudiante IS 'Información de los estudiantes';
COMMENT ON TABLE profesor IS 'Información de los profesores';
COMMENT ON TABLE tutor IS 'Padres/apoderados de los estudiantes';
COMMENT ON TABLE curso IS 'Cursos organizados por grado y paralelo';
COMMENT ON TABLE inscripcion IS 'Inscripción de estudiantes en cursos';
COMMENT ON TABLE asignacion IS 'Asignación de profesores a materias en cursos';
COMMENT ON TABLE seguimiento IS 'Calificaciones y seguimiento académico';
COMMENT ON TABLE asistencia IS 'Control de asistencia de estudiantes';
COMMENT ON TABLE horario IS 'Horarios de clases';
COMMENT ON TABLE concepto_pago IS 'Tipos de conceptos de pago';
COMMENT ON TABLE pago IS 'Registro de pagos de estudiantes';
