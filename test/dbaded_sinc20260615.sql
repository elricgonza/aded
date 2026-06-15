CREATE TABLE public.alumno (
	id integer NOT NULL DEFAULT nextval('public.alumno_id_seq'::regclass),
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

ALTER TABLE public.alumno OWNER TO uaded;


CREATE SEQUENCE public.asignado_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.asignado_id_seq OWNER TO uaded;


CREATE TABLE public.asignado (
	id integer NOT NULL DEFAULT nextval('public.asignado_id_seq'::regclass),
	cur_id integer NOT NULL,
	mat_id integer NOT NULL,
	pro_id integer,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT asignado_pkey PRIMARY KEY (id)

);

ALTER TABLE public.asignado OWNER TO uaded;


CREATE SEQUENCE public.costo_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.costo_id_seq OWNER TO uaded;


CREATE TABLE public.costo (
	id integer NOT NULL DEFAULT nextval('public.costo_id_seq'::regclass),
	cur_id integer NOT NULL,
	nro_cuota smallint NOT NULL,
	cuota numeric(10,2) NOT NULL,
	obs character varying(200) NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT costo_pkey PRIMARY KEY (id)

);

ALTER TABLE public.costo OWNER TO uaded;


CREATE SEQUENCE public.curso_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.curso_id_seq OWNER TO uaded;


CREATE TABLE public.curso (
	id integer NOT NULL DEFAULT nextval('public.curso_id_seq'::regclass),
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

ALTER TABLE public.curso OWNER TO uaded;


CREATE SEQUENCE public.gestion_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.gestion_id_seq OWNER TO uaded;


CREATE TABLE public.gestion (
	id integer NOT NULL DEFAULT nextval('public.gestion_id_seq'::regclass),
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

ALTER TABLE public.gestion OWNER TO uaded;


CREATE SEQUENCE public.grado_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.grado_id_seq OWNER TO uaded;


CREATE TABLE public.grado (
	id integer NOT NULL DEFAULT nextval('public.grado_id_seq'::regclass),
	grado character varying(255) NOT NULL,
	nivel character varying(150) NOT NULL,
	ges_id integer NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT grado_pkey PRIMARY KEY (id)

);

ALTER TABLE public.grado OWNER TO uaded;


CREATE SEQUENCE public.inscrito_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.inscrito_id_seq OWNER TO uaded;


CREATE TABLE public.inscrito (
	id integer NOT NULL DEFAULT nextval('public.inscrito_id_seq'::regclass),
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

ALTER TABLE public.inscrito OWNER TO uaded;


CREATE SEQUENCE public.materia_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.materia_id_seq OWNER TO uaded;


CREATE TABLE public.materia (
	id integer NOT NULL DEFAULT nextval('public.materia_id_seq'::regclass),
	materia character varying(150) NOT NULL,
	gra_id integer NOT NULL,
	creado timestamp NOT NULL,
	act timestamp NOT NULL,
	usu_id integer NOT NULL,
	CONSTRAINT materia_pkey PRIMARY KEY (id)

);

ALTER TABLE public.materia OWNER TO uaded;


CREATE SEQUENCE public.nota_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.nota_id_seq OWNER TO uaded;


CREATE TABLE public.nota (
	id integer NOT NULL DEFAULT nextval('public.nota_id_seq'::regclass),
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

ALTER TABLE public.nota OWNER TO uaded;


CREATE SEQUENCE public.pago_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.pago_id_seq OWNER TO uaded;


CREATE TABLE public.pago (
	id integer NOT NULL DEFAULT nextval('public.pago_id_seq'::regclass),
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

ALTER TABLE public.pago OWNER TO uaded;


CREATE SEQUENCE public.permiso_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.permiso_id_seq OWNER TO uaded;


CREATE TABLE public.permiso (
	id integer NOT NULL DEFAULT nextval('public.permiso_id_seq'::regclass),
	permiso character varying(50) NOT NULL,
	descripcion character varying(255),
	creado timestamp,
	act timestamp,
	CONSTRAINT permiso_permiso_key UNIQUE (permiso),
	CONSTRAINT permiso_pkey PRIMARY KEY (id)

);

ALTER TABLE public.permiso OWNER TO uaded;


CREATE SEQUENCE public.profesor_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.profesor_id_seq OWNER TO uaded;


CREATE TABLE public.profesor (
	id integer NOT NULL DEFAULT nextval('public.profesor_id_seq'::regclass),
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

ALTER TABLE public.profesor OWNER TO uaded;


CREATE SEQUENCE public.rol_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.rol_id_seq OWNER TO uaded;


CREATE TABLE public.rol (
	id integer NOT NULL DEFAULT nextval('public.rol_id_seq'::regclass),
	rol character varying(50) NOT NULL,
	descripcion character varying(255),
	creado timestamp,
	act timestamp,
	CONSTRAINT rol_pkey PRIMARY KEY (id),
	CONSTRAINT rol_rol_key UNIQUE (rol)

);

ALTER TABLE public.rol OWNER TO uaded;


CREATE TABLE public.rol_permiso (
	rol_id integer NOT NULL,
	per_id integer NOT NULL,
	CONSTRAINT rol_permiso_pkey PRIMARY KEY (rol_id,per_id)

);

ALTER TABLE public.rol_permiso OWNER TO uaded;


CREATE SEQUENCE public.usuario_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.usuario_id_seq OWNER TO uaded;


CREATE TABLE public.usuario (
	id integer NOT NULL DEFAULT nextval('public.usuario_id_seq'::regclass),
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

ALTER TABLE public.usuario OWNER TO uaded;


CREATE TABLE public.usuario_rol (
	usu_id integer NOT NULL,
	rol_id integer NOT NULL,
	CONSTRAINT usuario_rol_pkey PRIMARY KEY (usu_id,rol_id)

);

ALTER TABLE public.usuario_rol OWNER TO uaded;


CREATE SEQUENCE public.audit_log_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;

ALTER SEQUENCE public.audit_log_id_seq OWNER TO uaded;


CREATE TABLE public.audit_log (
	id integer NOT NULL DEFAULT nextval('public.audit_log_id_seq'::regclass),
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

COMMENT ON TABLE public.audit_log IS E'Registro de auditoría de acciones del sistema';

COMMENT ON COLUMN public.audit_log.accion IS E'Tipo de acción: CREATE, UPDATE, DELETE, LOGIN, LOGOUT, BULK, ERROR';

COMMENT ON COLUMN public.audit_log.modulo IS E'Módulo del sistema: grado, materia, alumno, pago, etc.';

COMMENT ON COLUMN public.audit_log.detalle IS E'JSON con detalles relevantes de la acción';

ALTER TABLE public.audit_log OWNER TO uaded;


CREATE INDEX idx_audit_log_usu_id ON public.audit_log
	USING btree
	(
	  usu_id
	)
	WITH (FILLFACTOR = 90);


CREATE INDEX idx_audit_log_creado ON public.audit_log
	USING btree
	(
	  creado
	)
	WITH (FILLFACTOR = 90);


CREATE INDEX idx_audit_log_accion ON public.audit_log
	USING btree
	(
	  accion
	)
	WITH (FILLFACTOR = 90);
CREATE INDEX idx_audit_log_modulo ON public.audit_log
	USING btree
	(
	  modulo
	)
	WITH (FILLFACTOR = 90);


ALTER TABLE public.asignado ADD CONSTRAINT asignado_cur_id_fkey FOREIGN KEY (cur_id)
REFERENCES public.curso (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.asignado ADD CONSTRAINT asignado_mat_id_fkey FOREIGN KEY (mat_id)
REFERENCES public.materia (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.asignado ADD CONSTRAINT asignado_pro_id_fkey FOREIGN KEY (pro_id)
REFERENCES public.profesor (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.costo ADD CONSTRAINT costo_cur_id_fkey FOREIGN KEY (cur_id)
REFERENCES public.curso (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.curso ADD CONSTRAINT curso_gra_id_fkey FOREIGN KEY (gra_id)
REFERENCES public.grado (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.grado ADD CONSTRAINT grado_ges_id_fkey FOREIGN KEY (ges_id)
REFERENCES public.gestion (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.inscrito ADD CONSTRAINT inscrito_alu_id_fkey FOREIGN KEY (alu_id)
REFERENCES public.alumno (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE public.inscrito ADD CONSTRAINT inscrito_cur_id_fkey FOREIGN KEY (cur_id)
REFERENCES public.curso (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE public.materia ADD CONSTRAINT materia_gra_id_fkey FOREIGN KEY (gra_id)
REFERENCES public.grado (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.nota ADD CONSTRAINT nota_ins_id_fkey FOREIGN KEY (ins_id)
REFERENCES public.inscrito (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.nota ADD CONSTRAINT nota_mat_id_fkey FOREIGN KEY (mat_id)
REFERENCES public.materia (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE public.pago ADD CONSTRAINT pago_ins_id_fkey FOREIGN KEY (ins_id)
REFERENCES public.inscrito (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE public.rol_permiso ADD CONSTRAINT rol_permiso_per_id_fkey FOREIGN KEY (per_id)
REFERENCES public.permiso (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE public.rol_permiso ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id)
REFERENCES public.rol (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE public.usuario_rol ADD CONSTRAINT usuario_rol_rol_id_fkey FOREIGN KEY (rol_id)
REFERENCES public.rol (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE public.usuario_rol ADD CONSTRAINT usuario_rol_usu_id_fkey FOREIGN KEY (usu_id)
REFERENCES public.usuario (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE public.audit_log ADD CONSTRAINT audit_log_usu_id_fkey FOREIGN KEY (usu_id)
REFERENCES public.usuario (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE NO ACTION;
