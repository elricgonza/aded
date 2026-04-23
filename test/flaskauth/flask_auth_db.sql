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
-- -- object: flask_auth_db | type: DATABASE --
-- -- DROP DATABASE IF EXISTS flask_auth_db;
-- CREATE DATABASE flask_auth_db
-- 	ENCODING = 'UTF8'
-- 	LC_COLLATE = 'en_US.UTF-8'
-- 	LC_CTYPE = 'en_US.UTF-8'
-- 	TABLESPACE = pg_default
-- 	OWNER = flask_user;
-- -- ddl-end --
-- 

-- object: public.users_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.users_id_seq CASCADE;
CREATE SEQUENCE public.users_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE public.users_id_seq OWNER TO flask_user;
-- ddl-end --

-- object: public.users | type: TABLE --
-- DROP TABLE IF EXISTS public.users CASCADE;
CREATE TABLE public.users (
	id integer NOT NULL DEFAULT nextval('public.users_id_seq'::regclass),
	username character varying(80) NOT NULL,
	email character varying(120) NOT NULL,
	password_hash character varying(255) NOT NULL,
	is_active boolean,
	created_at timestamp,
	updated_at timestamp,
	CONSTRAINT users_pkey PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.users OWNER TO flask_user;
-- ddl-end --

-- object: ix_users_username | type: INDEX --
-- DROP INDEX IF EXISTS public.ix_users_username CASCADE;
CREATE UNIQUE INDEX ix_users_username ON public.users
	USING btree
	(
	  username
	)
	WITH (FILLFACTOR = 90);
-- ddl-end --

-- object: public.roles_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.roles_id_seq CASCADE;
CREATE SEQUENCE public.roles_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE public.roles_id_seq OWNER TO flask_user;
-- ddl-end --

-- object: public.roles | type: TABLE --
-- DROP TABLE IF EXISTS public.roles CASCADE;
CREATE TABLE public.roles (
	id integer NOT NULL DEFAULT nextval('public.roles_id_seq'::regclass),
	name character varying(50) NOT NULL,
	description character varying(255),
	created_at timestamp,
	CONSTRAINT roles_pkey PRIMARY KEY (id),
	CONSTRAINT roles_name_key UNIQUE (name)

);
-- ddl-end --
ALTER TABLE public.roles OWNER TO flask_user;
-- ddl-end --

-- object: public.permissions_id_seq | type: SEQUENCE --
-- DROP SEQUENCE IF EXISTS public.permissions_id_seq CASCADE;
CREATE SEQUENCE public.permissions_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START WITH 1
	CACHE 1
	NO CYCLE
	OWNED BY NONE;
-- ddl-end --
ALTER SEQUENCE public.permissions_id_seq OWNER TO flask_user;
-- ddl-end --

-- object: public.permissions | type: TABLE --
-- DROP TABLE IF EXISTS public.permissions CASCADE;
CREATE TABLE public.permissions (
	id integer NOT NULL DEFAULT nextval('public.permissions_id_seq'::regclass),
	name character varying(50) NOT NULL,
	description character varying(255),
	created_at timestamp,
	CONSTRAINT permissions_pkey PRIMARY KEY (id),
	CONSTRAINT permissions_name_key UNIQUE (name)

);
-- ddl-end --
ALTER TABLE public.permissions OWNER TO flask_user;
-- ddl-end --

-- object: public.user_roles | type: TABLE --
-- DROP TABLE IF EXISTS public.user_roles CASCADE;
CREATE TABLE public.user_roles (
	user_id integer NOT NULL,
	role_id integer NOT NULL,
	CONSTRAINT user_roles_pkey PRIMARY KEY (user_id,role_id)

);
-- ddl-end --
ALTER TABLE public.user_roles OWNER TO flask_user;
-- ddl-end --

-- object: public.role_permissions | type: TABLE --
-- DROP TABLE IF EXISTS public.role_permissions CASCADE;
CREATE TABLE public.role_permissions (
	role_id integer NOT NULL,
	permission_id integer NOT NULL,
	CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id,permission_id)

);
-- ddl-end --
ALTER TABLE public.role_permissions OWNER TO flask_user;
-- ddl-end --

-- object: user_roles_user_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_roles_user_id_fkey CASCADE;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: user_roles_role_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_fkey CASCADE;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id)
REFERENCES public.roles (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: role_permissions_role_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_role_id_fkey CASCADE;
ALTER TABLE public.role_permissions ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id)
REFERENCES public.roles (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: role_permissions_permission_id_fkey | type: CONSTRAINT --
-- ALTER TABLE public.role_permissions DROP CONSTRAINT IF EXISTS role_permissions_permission_id_fkey CASCADE;
ALTER TABLE public.role_permissions ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id)
REFERENCES public.permissions (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


