CREATE ROLE uaded WITH 
	INHERIT
	LOGIN
	ENCRYPTED PASSWORD 'Bolivia2026-';

-- object: public.alumno | type: TABLE --
-- DROP TABLE IF EXISTS public.alumno CASCADE;
CREATE TABLE public.alumno (
	id SERIAL NOT NULL,
	nombre character varying(100) NOT NULL,
	paterno character varying(100),
	materno character varying(100),
	nacimiento date,
	masculino boolean NOT NULL,
	ci integer,
	direccion character varying(150),
	email character varying(100),
	activo boolean NOT NULL,
	obs character varying(100),
	usr_id_login integer,
	foto_ruta character varying(150),
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT alumno_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.alumno OWNER TO uaded;
-- ddl-end --

-- object: public.asignado | type: TABLE --
-- DROP TABLE IF EXISTS public.asignado CASCADE;
CREATE TABLE public.asignado (
	id SERIAL NOT NULL,
	cur_id integer NOT NULL,
	mat_id integer NOT NULL,
	pro_id integer,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT asignado_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.asignado OWNER TO uaded;
-- ddl-end --

-- object: public.costo | type: TABLE --
-- DROP TABLE IF EXISTS public.costo CASCADE;
CREATE TABLE public.costo (
	id SERIAL NOT NULL,
	cur_id integer NOT NULL,
	nro_cuota smallint NOT NULL,
	cuota numeric(10,2) NOT NULL,
	obs character varying(200) NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT costo_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.costo OWNER TO uaded;
-- ddl-end --

-- object: public.curso | type: TABLE --
-- DROP TABLE IF EXISTS public.curso CASCADE;
CREATE TABLE public.curso (
	id SERIAL NOT NULL,
	curso character varying(150),
	paralelo character varying(50) NOT NULL,
	gra_id integer NOT NULL,
	aula character varying(50),
	capacidad smallint,
	gestion smallint NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT curso_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.curso OWNER TO uaded;
-- ddl-end --

-- object: public.gestion | type: TABLE --
-- DROP TABLE IF EXISTS public.gestion CASCADE;
CREATE TABLE public.gestion (
	id SERIAL NOT NULL,
	gestion smallint,
	plan character varying(150) NOT NULL,
	inicio date NOT NULL,
	fin date NOT NULL,
	activo boolean NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT gestion_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.gestion OWNER TO uaded;
-- ddl-end --

-- object: public.grado | type: TABLE --
-- DROP TABLE IF EXISTS public.grado CASCADE;
CREATE TABLE public.grado (
	id SERIAL NOT NULL,
	grado character varying(255) NOT NULL,
	nivel character varying(150) NOT NULL,
	ges_id integer NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT grado_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.grado OWNER TO uaded;
-- ddl-end --

-- object: public.inscrito | type: TABLE --
-- DROP TABLE IF EXISTS public.inscrito CASCADE;
CREATE TABLE public.inscrito (
	id SERIAL NOT NULL,
	alu_id integer,
	cur_id integer,
	reserva boolean,
	inscrito boolean NOT NULL,
	descuento smallint NOT NULL,
	motivo_descuento character varying(100),
	abandono boolean NOT NULL,
	obs character varying(200),
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT inscrito_alu_id_key UNIQUE (alu_id),
	CONSTRAINT inscrito_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.inscrito OWNER TO uaded;
-- ddl-end --

-- object: public.materia | type: TABLE --
-- DROP TABLE IF EXISTS public.materia CASCADE;
CREATE TABLE public.materia (
	id SERIAL NOT NULL,
	materia character varying(150) NOT NULL,
	gra_id integer NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT materia_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.materia OWNER TO uaded;
-- ddl-end --

-- object: public.nota | type: TABLE --
-- DROP TABLE IF EXISTS public.nota CASCADE;
CREATE TABLE public.nota (
	id SERIAL NOT NULL,
	ins_id integer NOT NULL,
	mat_id integer NOT NULL,
	nota1 smallint NOT NULL,
	nota2 smallint NOT NULL,
	nota3 smallint NOT NULL,
	nota_final numeric(5,1) NOT NULL,
	nota_aprob smallint NOT NULL,
	aprobado boolean,
	obs character varying(150),
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT nota_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.nota OWNER TO uaded;
-- ddl-end --

-- object: public.pago | type: TABLE --
-- DROP TABLE IF EXISTS public.pago CASCADE;
CREATE TABLE public.pago (
	id SERIAL NOT NULL,
	ins_id integer NOT NULL,
	nro_cuota smallint NOT NULL,
	cuota double precision NOT NULL,
	pagado boolean,
	metodo_pago character varying(50),
	fecha_pago timestamp,
	referencia_pago character varying(100),
	obs character varying(100),
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT pago_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.pago OWNER TO uaded;
-- ddl-end --

-- object: public.permiso | type: TABLE --
-- DROP TABLE IF EXISTS public.permiso CASCADE;
CREATE TABLE public.permiso (
	id SERIAL NOT NULL,
	permiso character varying(50) NOT NULL,
	descripcion character varying(255),
	creado timestamp,
	act timestamp,
	CONSTRAINT permiso_permiso_key UNIQUE (permiso),
	CONSTRAINT permiso_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.permiso OWNER TO uaded;
-- ddl-end --

-- object: public.profesor | type: TABLE --
-- DROP TABLE IF EXISTS public.profesor CASCADE;
CREATE TABLE public.profesor (
	id SERIAL NOT NULL,
	nombre character varying(100) NOT NULL,
	paterno character varying(50),
	materno character varying(50),
	masculino boolean NOT NULL,
	ci integer,
	formacion character varying(100),
	email character varying(100),
	activo boolean NOT NULL,
	usr_id_login integer,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT profesor_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.profesor OWNER TO uaded;
-- ddl-end --

-- object: public.rol | type: TABLE --
-- DROP TABLE IF EXISTS public.rol CASCADE;
CREATE TABLE public.rol (
	id SERIAL NOT NULL,
	rol character varying(50) NOT NULL,
	descripcion character varying(255),
	creado timestamp,
	act timestamp,
	CONSTRAINT rol_pkey PRIMARY KEY (id),
	CONSTRAINT rol_rol_key UNIQUE (rol)

);
-- ddl-end --
ALTER TABLE public.rol OWNER TO uaded;
-- ddl-end --

-- object: public.rol_permiso | type: TABLE --
-- DROP TABLE IF EXISTS public.rol_permiso CASCADE;
CREATE TABLE public.rol_permiso (
	rol_id integer NOT NULL,
	per_id integer NOT NULL,
	CONSTRAINT rol_permiso_pkey PRIMARY KEY (rol_id,per_id)

);
-- ddl-end --
ALTER TABLE public.rol_permiso OWNER TO uaded;
-- ddl-end --

-- object: public.usuario | type: TABLE --
-- DROP TABLE IF EXISTS public.usuario CASCADE;
CREATE TABLE public.usuario (
	id SERIAL NOT NULL,
	usuario character varying(80) NOT NULL,
	email character varying(100) NOT NULL,
	password character varying(255) NOT NULL,
	activo boolean,
	last_login date NOT NULL,
	creado timestamp,
	act timestamp,
	CONSTRAINT usuario_pkey PRIMARY KEY (id),
	CONSTRAINT usuario_usuario_key UNIQUE (usuario)

);
-- ddl-end --
ALTER TABLE public.usuario OWNER TO uaded;
-- ddl-end --

-- object: public.usuario_rol | type: TABLE --
-- DROP TABLE IF EXISTS public.usuario_rol CASCADE;
CREATE TABLE public.usuario_rol (
	usu_id integer NOT NULL,
	rol_id integer NOT NULL,
	CONSTRAINT usuario_rol_pkey PRIMARY KEY (usu_id,rol_id)

);
-- ddl-end --
ALTER TABLE public.usuario_rol OWNER TO uaded;
-- ddl-end --

-- object: public.audit_log | type: TABLE --
-- DROP TABLE IF EXISTS public.audit_log CASCADE;
CREATE TABLE public.audit_log (
	id SERIAL NOT NULL,
	usu_id integer,
	usuario character varying(80) NOT NULL DEFAULT 'anónimo',
	accion character varying(20) NOT NULL,
	modulo character varying(50) NOT NULL,
	entidad_id integer,
	detalle text,
	ip character varying(45),
	endpoint character varying(150),
	metodo character varying(10),
	status smallint DEFAULT 200,
	creado timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT audit_log_accion_check CHECK (((accion)::text = ANY ((ARRAY['CREATE'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying, 'LOGIN'::character varying, 'LOGOUT'::character varying, 'BULK'::character varying, 'ERROR'::character varying])::text[]))),
	CONSTRAINT audit_log_pkey PRIMARY KEY (id)

);
-- ddl-end --
COMMENT ON TABLE public.audit_log IS E'Registro de auditoría de acciones del sistema';
-- ddl-end --
COMMENT ON COLUMN public.audit_log.accion IS E'Tipo de acción: CREATE, UPDATE, DELETE, LOGIN, LOGOUT, BULK, ERROR';
-- ddl-end --
COMMENT ON COLUMN public.audit_log.modulo IS E'Módulo del sistema: grado, materia, alumno, pago, etc.';
-- ddl-end --
COMMENT ON COLUMN public.audit_log.detalle IS E'JSON con detalles relevantes de la acción';
-- ddl-end --
ALTER TABLE public.audit_log OWNER TO uaded;
-- ddl-end --

-- object: idx_audit_log_usu_id | type: INDEX --
-- DROP INDEX IF EXISTS public.idx_audit_log_usu_id CASCADE;
CREATE INDEX idx_audit_log_usu_id ON public.audit_log
	USING btree
	(
	  usu_id
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: idx_audit_log_creado | type: INDEX --
-- DROP INDEX IF EXISTS public.idx_audit_log_creado CASCADE;
CREATE INDEX idx_audit_log_creado ON public.audit_log
	USING btree
	(
	  creado
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: idx_audit_log_accion | type: INDEX --
-- DROP INDEX IF EXISTS public.idx_audit_log_accion CASCADE;
CREATE INDEX idx_audit_log_accion ON public.audit_log
	USING btree
	(
	  accion
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: idx_audit_log_modulo | type: INDEX --
-- DROP INDEX IF EXISTS public.idx_audit_log_modulo CASCADE;
CREATE INDEX idx_audit_log_modulo ON public.audit_log
	USING btree
	(
	  modulo
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: asignado_cur_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.asignado DROP CONSTRAINT IF EXISTS asignado_cur_id_fkey CASCADE;
ALTER TABLE public.asignado ADD CONSTRAINT asignado_cur_id_fkey FOREIGN KEY (cur_id)
REFERENCES public.curso (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: asignado_mat_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.asignado DROP CONSTRAINT IF EXISTS asignado_mat_id_fkey CASCADE;
ALTER TABLE public.asignado ADD CONSTRAINT asignado_mat_id_fkey FOREIGN KEY (mat_id)
REFERENCES public.materia (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: asignado_pro_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.asignado DROP CONSTRAINT IF EXISTS asignado_pro_id_fkey CASCADE;
ALTER TABLE public.asignado ADD CONSTRAINT asignado_pro_id_fkey FOREIGN KEY (pro_id)
REFERENCES public.profesor (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: costo_cur_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.costo DROP CONSTRAINT IF EXISTS costo_cur_id_fkey CASCADE;
ALTER TABLE public.costo ADD CONSTRAINT costo_cur_id_fkey FOREIGN KEY (cur_id)
REFERENCES public.curso (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: curso_gra_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.curso DROP CONSTRAINT IF EXISTS curso_gra_id_fkey CASCADE;
ALTER TABLE public.curso ADD CONSTRAINT curso_gra_id_fkey FOREIGN KEY (gra_id)
REFERENCES public.grado (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: grado_ges_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.grado DROP CONSTRAINT IF EXISTS grado_ges_id_fkey CASCADE;
ALTER TABLE public.grado ADD CONSTRAINT grado_ges_id_fkey FOREIGN KEY (ges_id)
REFERENCES public.gestion (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: inscrito_alu_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.inscrito DROP CONSTRAINT IF EXISTS inscrito_alu_id_fkey CASCADE;
ALTER TABLE public.inscrito ADD CONSTRAINT inscrito_alu_id_fkey FOREIGN KEY (alu_id)
REFERENCES public.alumno (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: inscrito_cur_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.inscrito DROP CONSTRAINT IF EXISTS inscrito_cur_id_fkey CASCADE;
ALTER TABLE public.inscrito ADD CONSTRAINT inscrito_cur_id_fkey FOREIGN KEY (cur_id)
REFERENCES public.curso (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: materia_gra_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.materia DROP CONSTRAINT IF EXISTS materia_gra_id_fkey CASCADE;
ALTER TABLE public.materia ADD CONSTRAINT materia_gra_id_fkey FOREIGN KEY (gra_id)
REFERENCES public.grado (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: nota_ins_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.nota DROP CONSTRAINT IF EXISTS nota_ins_id_fkey CASCADE;
ALTER TABLE public.nota ADD CONSTRAINT nota_ins_id_fkey FOREIGN KEY (ins_id)
REFERENCES public.inscrito (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: nota_mat_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.nota DROP CONSTRAINT IF EXISTS nota_mat_id_fkey CASCADE;
ALTER TABLE public.nota ADD CONSTRAINT nota_mat_id_fkey FOREIGN KEY (mat_id)
REFERENCES public.materia (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: pago_ins_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.pago DROP CONSTRAINT IF EXISTS pago_ins_id_fkey CASCADE;
ALTER TABLE public.pago ADD CONSTRAINT pago_ins_id_fkey FOREIGN KEY (ins_id)
REFERENCES public.inscrito (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: rol_permiso_per_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.rol_permiso DROP CONSTRAINT IF EXISTS rol_permiso_per_id_fkey CASCADE;
ALTER TABLE public.rol_permiso ADD CONSTRAINT rol_permiso_per_id_fkey FOREIGN KEY (per_id)
REFERENCES public.permiso (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: rol_permiso_rol_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.rol_permiso DROP CONSTRAINT IF EXISTS rol_permiso_rol_id_fkey CASCADE;
ALTER TABLE public.rol_permiso ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id)
REFERENCES public.rol (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: usuario_rol_rol_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.usuario_rol DROP CONSTRAINT IF EXISTS usuario_rol_rol_id_fkey CASCADE;
ALTER TABLE public.usuario_rol ADD CONSTRAINT usuario_rol_rol_id_fkey FOREIGN KEY (rol_id)
REFERENCES public.rol (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: usuario_rol_usu_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.usuario_rol DROP CONSTRAINT IF EXISTS usuario_rol_usu_id_fkey CASCADE;
ALTER TABLE public.usuario_rol ADD CONSTRAINT usuario_rol_usu_id_fkey FOREIGN KEY (usu_id)
REFERENCES public.usuario (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: audit_log_usu_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.audit_log DROP CONSTRAINT IF EXISTS audit_log_usu_id_fkey CASCADE;
ALTER TABLE public.audit_log ADD CONSTRAINT audit_log_usu_id_fkey FOREIGN KEY (usu_id)
REFERENCES public.usuario (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE NO ACTION;
-- ddl-end --