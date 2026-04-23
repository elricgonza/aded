-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.9.2
-- PostgreSQL version: 12.0
-- Project Site: pgmodeler.io
-- Model Author: ---

-- object: appgeo | type: ROLE --
-- DROP ROLE IF EXISTS appgeo;
CREATE ROLE appgeo WITH 
	INHERIT
	LOGIN
	ENCRYPTED PASSWORD '********';
-- ddl-end --

-- object: flask_user | type: ROLE --
-- DROP ROLE IF EXISTS flask_user;
CREATE ROLE flask_user WITH 
	INHERIT
	LOGIN
	ENCRYPTED PASSWORD '********';
-- ddl-end --

-- object: uaded | type: ROLE --
-- DROP ROLE IF EXISTS uaded;
CREATE ROLE uaded WITH 
	INHERIT
	LOGIN
	ENCRYPTED PASSWORD '********';
-- ddl-end --


-- Database creation must be done outside a multicommand file.
-- These commands were put in this file only as a convenience.
-- -- object: authtest | type: DATABASE --
-- -- DROP DATABASE IF EXISTS authtest;
-- CREATE DATABASE authtest
-- 	ENCODING = 'UTF8'
-- 	LC_COLLATE = 'en_US.UTF-8'
-- 	LC_CTYPE = 'en_US.UTF-8'
-- 	TABLESPACE = pg_default
-- 	OWNER = postgres;
-- -- ddl-end --
-- 

-- object: public.usr_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.usr_id_seq CASCADE;
CREATE SEQUENCE public.usr_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE public.usr_id_seq OWNER TO uaded;
-- ddl-end --

-- object: public.usr | type: TABLE --
-- DROP TABLE IF EXISTS public.usr CASCADE;
CREATE TABLE public.usr (
	id integer NOT NULL DEFAULT nextval('public.usr_id_seq'::regclass),
	usuario character varying(80) NOT NULL,
	email character varying(120) NOT NULL,
	password character varying(255) NOT NULL,
	activo boolean,
	ultimo_ingreso date NOT NULL,
	creado timestamp,
	act timestamp,
	CONSTRAINT usr_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.usr OWNER TO uaded;
-- ddl-end --

-- object: ix_usr_usuario | type: INDEX --
-- DROP INDEX IF EXISTS public.ix_usr_usuario CASCADE;
CREATE UNIQUE INDEX ix_usr_usuario ON public.usr
	USING btree
	(
	  usuario
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: public.rol_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.rol_id_seq CASCADE;
CREATE SEQUENCE public.rol_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE public.rol_id_seq OWNER TO uaded;
-- ddl-end --

-- object: public.rol | type: TABLE --
-- DROP TABLE IF EXISTS public.rol CASCADE;
CREATE TABLE public.rol (
	id integer NOT NULL DEFAULT nextval('public.rol_id_seq'::regclass),
	rol character varying(50) NOT NULL,
	descripcion character varying(255),
	creado timestamp,
	act date,
	CONSTRAINT rol_pkey PRIMARY KEY (id),
	CONSTRAINT rol_rol_key UNIQUE (rol)

);
-- ddl-end --
ALTER TABLE public.rol OWNER TO uaded;
-- ddl-end --

-- object: public.per_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.per_id_seq CASCADE;
CREATE SEQUENCE public.per_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE public.per_id_seq OWNER TO uaded;
-- ddl-end --

-- object: public.per | type: TABLE --
-- DROP TABLE IF EXISTS public.per CASCADE;
CREATE TABLE public.per (
	id integer NOT NULL DEFAULT nextval('public.per_id_seq'::regclass),
	permiso character varying(50) NOT NULL,
	descripcion character varying(255),
	creado timestamp,
	act timestamp,
	CONSTRAINT per_pkey PRIMARY KEY (id),
	CONSTRAINT per_permiso_key UNIQUE (permiso)

);
-- ddl-end --
ALTER TABLE public.per OWNER TO uaded;
-- ddl-end --

-- object: public.usr_rol | type: TABLE --
-- DROP TABLE IF EXISTS public.usr_rol CASCADE;
CREATE TABLE public.usr_rol (
	usr_id integer NOT NULL,
	rol_id integer NOT NULL,
	CONSTRAINT usr_rol_pkey PRIMARY KEY (usr_id,rol_id)

);
-- ddl-end --
ALTER TABLE public.usr_rol OWNER TO uaded;
-- ddl-end --

-- object: public.rol_per | type: TABLE --
-- DROP TABLE IF EXISTS public.rol_per CASCADE;
CREATE TABLE public.rol_per (
	rol_id integer NOT NULL,
	per_id integer NOT NULL,
	CONSTRAINT rol_per_pkey PRIMARY KEY (rol_id,per_id)

);
-- ddl-end --
ALTER TABLE public.rol_per OWNER TO uaded;
-- ddl-end --

-- object: usr_rol_usr_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.usr_rol DROP CONSTRAINT IF EXISTS usr_rol_usr_id_fkey CASCADE;
ALTER TABLE public.usr_rol ADD CONSTRAINT usr_rol_usr_id_fkey FOREIGN KEY (usr_id)
REFERENCES public.usr (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: usr_rol_rol_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.usr_rol DROP CONSTRAINT IF EXISTS usr_rol_rol_id_fkey CASCADE;
ALTER TABLE public.usr_rol ADD CONSTRAINT usr_rol_rol_id_fkey FOREIGN KEY (rol_id)
REFERENCES public.rol (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: rol_per_rol_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.rol_per DROP CONSTRAINT IF EXISTS rol_per_rol_id_fkey CASCADE;
ALTER TABLE public.rol_per ADD CONSTRAINT rol_per_rol_id_fkey FOREIGN KEY (rol_id)
REFERENCES public.rol (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: rol_per_per_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.rol_per DROP CONSTRAINT IF EXISTS rol_per_per_id_fkey CASCADE;
ALTER TABLE public.rol_per ADD CONSTRAINT rol_per_per_id_fkey FOREIGN KEY (per_id)
REFERENCES public.per (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


