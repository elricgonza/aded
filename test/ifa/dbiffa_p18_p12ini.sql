--
-- PostgreSQL database dump
--

\restrict tUkmUnUpC7UVDXUHPqaQ37qY3AdqhCzDVbIdd95LbhQYgnYo1yvGH7fe1achGbh

-- Dumped from database version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.6 (Ubuntu 18.6-0ubuntu0.26.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: alumno_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."alumno_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."alumno_id_seq" OWNER TO "uaded";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: alumno; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."alumno" (
    "id" integer DEFAULT "nextval"('"public"."alumno_id_seq"'::"regclass") NOT NULL,
    "nombre" character varying(100) NOT NULL,
    "paterno" character varying(100),
    "materno" character varying(100),
    "nacimiento" "date",
    "masculino" boolean NOT NULL,
    "ci" integer,
    "direccion" character varying(150),
    "email" character varying(100),
    "activo" boolean NOT NULL,
    "obs" character varying(100),
    "usr_id_login" integer,
    "foto_ruta" character varying(150),
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL
);


ALTER TABLE "public"."alumno" OWNER TO "uaded";

--
-- Name: asignado_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."asignado_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."asignado_id_seq" OWNER TO "uaded";

--
-- Name: asignado; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."asignado" (
    "id" integer DEFAULT "nextval"('"public"."asignado_id_seq"'::"regclass") NOT NULL,
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_inscrito" integer NOT NULL,
    "id_curso" integer NOT NULL,
    "id_materia" integer NOT NULL,
    "id_profesor" integer
);


ALTER TABLE "public"."asignado" OWNER TO "uaded";

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."audit_log_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."audit_log_id_seq" OWNER TO "uaded";

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."audit_log" (
    "id" integer DEFAULT "nextval"('"public"."audit_log_id_seq"'::"regclass") NOT NULL,
    "usuario" character varying(80) DEFAULT 'anónimo'::character varying NOT NULL,
    "accion" character varying(20) NOT NULL,
    "modulo" character varying(50) NOT NULL,
    "entidad_id" integer,
    "detalle" "text",
    "ip" character varying(45),
    "endpoint" character varying(150),
    "metodo" character varying(10),
    "status" smallint DEFAULT 200,
    "creado" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "id_usuario" integer,
    CONSTRAINT "audit_log_accion_check" CHECK ((("accion")::"text" = ANY ((ARRAY['CREATE'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying, 'LOGIN'::character varying, 'LOGOUT'::character varying, 'BULK'::character varying, 'ERROR'::character varying])::"text"[])))
);


ALTER TABLE "public"."audit_log" OWNER TO "uaded";

--
-- Name: TABLE "audit_log"; Type: COMMENT; Schema: public; Owner: uaded
--

COMMENT ON TABLE "public"."audit_log" IS 'Registro de auditoría de acciones del sistema';


--
-- Name: COLUMN "audit_log"."accion"; Type: COMMENT; Schema: public; Owner: uaded
--

COMMENT ON COLUMN "public"."audit_log"."accion" IS 'Tipo de acción: CREATE, UPDATE, DELETE, LOGIN, LOGOUT, BULK, ERROR';


--
-- Name: COLUMN "audit_log"."modulo"; Type: COMMENT; Schema: public; Owner: uaded
--

COMMENT ON COLUMN "public"."audit_log"."modulo" IS 'Módulo del sistema: grado, materia, alumno, pago, etc.';


--
-- Name: COLUMN "audit_log"."detalle"; Type: COMMENT; Schema: public; Owner: uaded
--

COMMENT ON COLUMN "public"."audit_log"."detalle" IS 'JSON con detalles relevantes de la acción';


--
-- Name: curso_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."curso_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."curso_id_seq" OWNER TO "uaded";

--
-- Name: curso; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."curso" (
    "id" integer DEFAULT "nextval"('"public"."curso_id_seq"'::"regclass") NOT NULL,
    "curso" character varying(150),
    "paralelo" character varying(50) NOT NULL,
    "aula" character varying(50),
    "capacidad" smallint,
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_gestion" integer NOT NULL,
    "id_grado" integer NOT NULL
);


ALTER TABLE "public"."curso" OWNER TO "uaded";

--
-- Name: gestion_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."gestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."gestion_id_seq" OWNER TO "uaded";

--
-- Name: gestion; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."gestion" (
    "id" integer DEFAULT "nextval"('"public"."gestion_id_seq"'::"regclass") NOT NULL,
    "gestion" smallint,
    "plan" character varying(150) NOT NULL,
    "inicio" "date" NOT NULL,
    "fin" "date" NOT NULL,
    "activo" boolean NOT NULL,
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL
);


ALTER TABLE "public"."gestion" OWNER TO "uaded";

--
-- Name: grado_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."grado_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."grado_id_seq" OWNER TO "uaded";

--
-- Name: grado; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."grado" (
    "id" integer DEFAULT "nextval"('"public"."grado_id_seq"'::"regclass") NOT NULL,
    "grado" character varying(255) NOT NULL,
    "nivel" character varying(150) NOT NULL,
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_instrumento" integer NOT NULL
);


ALTER TABLE "public"."grado" OWNER TO "uaded";

--
-- Name: inscrito_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."inscrito_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."inscrito_id_seq" OWNER TO "uaded";

--
-- Name: inscrito; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."inscrito" (
    "id" integer DEFAULT "nextval"('"public"."inscrito_id_seq"'::"regclass") NOT NULL,
    "reserva" boolean,
    "inscrito" boolean NOT NULL,
    "descuento" smallint NOT NULL,
    "motivo_descuento" character varying(100),
    "abandono" boolean NOT NULL,
    "obs" character varying(200),
    "otras_materias" boolean DEFAULT false NOT NULL,
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_alumno" integer NOT NULL,
    "id_curso" integer NOT NULL,
    "id_instrumento" integer NOT NULL,
    CONSTRAINT "inscrito_descuento_chk" CHECK ((("descuento" >= 0) AND ("descuento" <= 100)))
);


ALTER TABLE "public"."inscrito" OWNER TO "uaded";

--
-- Name: instrumento_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."instrumento_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."instrumento_id_seq" OWNER TO "uaded";

--
-- Name: instrumento; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."instrumento" (
    "id" integer DEFAULT "nextval"('"public"."instrumento_id_seq"'::"regclass") NOT NULL,
    "instrumento" character varying(150) NOT NULL,
    "area" character varying(50),
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL
);


ALTER TABLE "public"."instrumento" OWNER TO "uaded";

--
-- Name: materia_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."materia_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."materia_id_seq" OWNER TO "uaded";

--
-- Name: materia; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."materia" (
    "id" integer DEFAULT "nextval"('"public"."materia_id_seq"'::"regclass") NOT NULL,
    "materia" character varying(150) NOT NULL,
    "sigla" character varying(20),
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_grado" integer NOT NULL
);


ALTER TABLE "public"."materia" OWNER TO "uaded";

--
-- Name: nota_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."nota_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."nota_id_seq" OWNER TO "uaded";

--
-- Name: nota; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."nota" (
    "id" integer DEFAULT "nextval"('"public"."nota_id_seq"'::"regclass") NOT NULL,
    "nota1" smallint,
    "nota2" smallint,
    "nota3" smallint,
    "nota4" smallint,
    "nota_final" numeric(5,1),
    "2t" smallint,
    "nota_aprob" smallint,
    "aprobado" boolean,
    "obs" character varying(150),
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_asignado" integer NOT NULL
);


ALTER TABLE "public"."nota" OWNER TO "uaded";

--
-- Name: pago_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."pago_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pago_id_seq" OWNER TO "uaded";

--
-- Name: pago; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."pago" (
    "id" integer DEFAULT "nextval"('"public"."pago_id_seq"'::"regclass") NOT NULL,
    "cuota" double precision NOT NULL,
    "pagado" boolean,
    "metodo_pago" character varying(50),
    "fecha_pago" timestamp without time zone,
    "referencia_pago" character varying(100),
    "obs" character varying(100),
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL,
    "id_inscrito" integer NOT NULL
);


ALTER TABLE "public"."pago" OWNER TO "uaded";

--
-- Name: permiso_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."permiso_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."permiso_id_seq" OWNER TO "uaded";

--
-- Name: permiso; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."permiso" (
    "id" integer DEFAULT "nextval"('"public"."permiso_id_seq"'::"regclass") NOT NULL,
    "permiso" character varying(50) NOT NULL,
    "descripcion" character varying(255),
    "creado" timestamp without time zone,
    "act" timestamp without time zone
);


ALTER TABLE "public"."permiso" OWNER TO "uaded";

--
-- Name: profesor_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."profesor_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."profesor_id_seq" OWNER TO "uaded";

--
-- Name: profesor; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."profesor" (
    "id" integer DEFAULT "nextval"('"public"."profesor_id_seq"'::"regclass") NOT NULL,
    "nombre" character varying(100) NOT NULL,
    "paterno" character varying(50),
    "materno" character varying(50),
    "masculino" boolean NOT NULL,
    "ci" integer,
    "formacion" character varying(100),
    "email" character varying(100),
    "activo" boolean NOT NULL,
    "usr_id_login" integer,
    "creado" timestamp without time zone NOT NULL,
    "act" timestamp without time zone NOT NULL,
    "id_usuario" integer NOT NULL
);


ALTER TABLE "public"."profesor" OWNER TO "uaded";

--
-- Name: requisito; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."requisito" (
    "id_materia" integer NOT NULL,
    "id_materia_req" integer NOT NULL,
    CONSTRAINT "requisito_distintos" CHECK (("id_materia" <> "id_materia_req"))
);


ALTER TABLE "public"."requisito" OWNER TO "uaded";

--
-- Name: rol_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."rol_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."rol_id_seq" OWNER TO "uaded";

--
-- Name: rol; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."rol" (
    "id" integer DEFAULT "nextval"('"public"."rol_id_seq"'::"regclass") NOT NULL,
    "rol" character varying(50) NOT NULL,
    "descripcion" character varying(255),
    "creado" timestamp without time zone,
    "act" timestamp without time zone
);


ALTER TABLE "public"."rol" OWNER TO "uaded";

--
-- Name: rol_permiso; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."rol_permiso" (
    "id_rol" integer NOT NULL,
    "id_permiso" integer NOT NULL
);


ALTER TABLE "public"."rol_permiso" OWNER TO "uaded";

--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: uaded
--

CREATE SEQUENCE "public"."usuario_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."usuario_id_seq" OWNER TO "uaded";

--
-- Name: usuario; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."usuario" (
    "id" integer DEFAULT "nextval"('"public"."usuario_id_seq"'::"regclass") NOT NULL,
    "usuario" character varying(80) NOT NULL,
    "email" character varying(100) NOT NULL,
    "password" character varying(255) NOT NULL,
    "activo" boolean,
    "last_login" "date" DEFAULT CURRENT_DATE NOT NULL,
    "creado" timestamp without time zone,
    "act" timestamp without time zone
);


ALTER TABLE "public"."usuario" OWNER TO "uaded";

--
-- Name: usuario_rol; Type: TABLE; Schema: public; Owner: uaded
--

CREATE TABLE "public"."usuario_rol" (
    "id_usuario" integer NOT NULL,
    "id_rol" integer NOT NULL
);


ALTER TABLE "public"."usuario_rol" OWNER TO "uaded";

--
-- Data for Name: alumno; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."alumno" ("id", "nombre", "paterno", "materno", "nacimiento", "masculino", "ci", "direccion", "email", "activo", "obs", "usr_id_login", "foto_ruta", "creado", "act", "id_usuario") FROM stdin;
1	Juancito	Pinto	Lopez	2019-11-05	t	112233	Miraflores C.7 #234	\N	t	\N	\N	\N	2026-10-21 14:59:25.532208	2026-10-21 14:59:25.532212	1
2	Genoveva	Rios	Flores	2017-05-07	f	887766	Sopocachi C. Abdon Saavedra #989	grios@gmail.com	t	\N	\N	\N	2026-10-21 15:01:36.619454	2026-10-21 15:01:36.619458	1
3	Elliete	Santa Cruz	Loza	2021-07-20	f	998877	C.Satélite Av. Tinku #8787	elliete@gm.com	t	\N	\N	\N	2026-10-21 15:02:43.447653	2026-10-21 15:03:52.953449	1
4	Agustin Ian	Puma	Valverde	2022-03-20	t	123456	V.Adela El Alto C.4  #898	\N	t	\N	\N	\N	2026-10-21 15:04:59.371757	2026-10-21 15:04:59.371762	1
5	Mariano	Melgarejillo	Burrillo	2015-05-04	t	998877	\N	mmb@gm.com	t	\N	\N	\N	2026-10-21 15:07:17.831631	2026-10-21 15:07:17.831636	1
\.


--
-- Data for Name: asignado; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."asignado" ("id", "creado", "act", "id_usuario", "id_inscrito", "id_curso", "id_materia", "id_profesor") FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."audit_log" ("id", "usuario", "accion", "modulo", "entidad_id", "detalle", "ip", "endpoint", "metodo", "status", "creado", "id_usuario") FROM stdin;
1	admin	LOGIN	auth	1	{"ok": true}	127.0.0.1	auth.login	POST	200	2026-10-20 15:13:40.981007	1
2	admin	CREATE	gestion	1	{"registro": "2026 - Técnico Superior"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:00:59.222455	1
3	admin	CREATE	instrumento	1	{"registro": "Piano"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:02:18.964464	1
4	admin	CREATE	instrumento	2	{"registro": "Violín"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:04:51.917054	1
5	admin	CREATE	instrumento	3	{"registro": "Guitarra"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:05:32.332301	1
6	admin	CREATE	instrumento	4	{"registro": "Cello"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:17:33.1298	1
7	admin	CREATE	instrumento	5	{"registro": "Trompeta"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:17:46.147749	1
8	admin	CREATE	grado	1	{"registro": "1ro. Inicial (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:32:26.352503	1
9	admin	CREATE	grado	2	{"registro": "2do. Inicial (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:32:52.309599	1
10	admin	CREATE	grado	3	{"registro": "1ro. Básico (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:35:33.689086	1
11	admin	CREATE	grado	4	{"registro": "2do. Básico (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:35:58.00369	1
12	admin	CREATE	grado	5	{"registro": "3ro. Básico (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:36:30.234844	1
13	admin	CREATE	grado	6	{"registro": "1ro. Intermedio (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:37:16.732182	1
14	admin	CREATE	grado	7	{"registro": "2do. Intermedio (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:37:37.344952	1
15	admin	CREATE	grado	8	{"registro": "3ro. Intermedio (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:37:59.001609	1
16	admin	CREATE	grado	9	{"registro": "1ro. Técnico Medio (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:38:52.43391	1
17	admin	CREATE	grado	10	{"registro": "2do. Técnico Medio (Piano)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:39:12.945905	1
18	admin	CREATE	materia	1	{"registro": "LENGUAJE MUSICAL INICIAL I (1ro. Inicial)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:42:03.487396	1
19	admin	CREATE	materia	2	{"registro": "INSTRUMENTO DE ESPECIALIDAD I (2do. Inicial)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:46:32.885535	1
20	admin	UPDATE	materia	2	{"registro": "INSTRUMENTO DE ESPECIALIDAD I (2do. Inicial)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:49:05.898882	1
21	admin	CREATE	materia	3	{"registro": "LENGUAJE MUSICAL INICIAL II (2do. Inicial)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:50:52.394893	1
22	admin	CREATE	materia	4	{"registro": "INSTRUMENTO DE ESPECIALIDAD II (2do. Inicial)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:51:51.179621	1
23	admin	CREATE	materia	5	{"registro": "PRACTICA COLECTIVA INICIAL I (2do. Inicial)"}	127.0.0.1	crud.guardar	POST	200	2026-10-20 16:52:28.164406	1
24	admin	LOGIN	auth	\N	{"ok": false, "usuario": "admin"}	127.0.0.1	auth.login	POST	401	2026-10-21 10:39:00.787809	\N
25	admin	LOGIN	auth	1	{"ok": true}	127.0.0.1	auth.login	POST	200	2026-10-21 10:39:14.087772	1
26	admin	CREATE	materia	6	{"registro": "LENGUAJE MUSICAL BASICO I (1ro. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 10:49:46.469419	1
27	admin	CREATE	materia	7	{"registro": "INSTRUMENTO DE ESPECIALIDAD IV (1ro. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 10:51:10.732345	1
28	admin	CREATE	materia	8	{"registro": "PRACTICA COLECTIVA BASICA I (1ro. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:00:44.108633	1
29	admin	CREATE	materia	9	{"registro": "LENGUAJE MUSICAL BASICO II (2do. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:02:07.415548	1
30	admin	CREATE	materia	10	{"registro": "INSTRUMENTO DE ESPECIALIDAD V (2do. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:03:16.272041	1
31	admin	CREATE	materia	11	{"registro": "PRACTICA COLECTIVA BASICA II (2do. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:03:47.70866	1
32	admin	CREATE	materia	12	{"registro": "LENGUAJE MUSICAL BASICO III (3ro. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:05:30.738261	1
33	admin	CREATE	materia	13	{"registro": "INSTRUMENTO DE ESPECIALIDAD VI (3ro. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:06:07.608307	1
34	admin	CREATE	materia	14	{"registro": "PRACTICA COLECTIVA BASICA III (3ro. Básico)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:07:24.009774	1
35	admin	CREATE	materia	15	{"registro": "LENGUAJE MUSICAL INTERMEDIO III (3ro. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:11:56.435146	1
36	admin	CREATE	materia	16	{"registro": "INSTRUMENTO DE ESPECIALIDAD IX (3ro. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:13:03.152828	1
37	admin	CREATE	materia	17	{"registro": "PRACTICA COLECTIVA INTERMEDIA III (3ro. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:14:23.456478	1
38	admin	CREATE	materia	18	{"registro": "INSTRUMENTO DE ESPECIALIDAD I (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:18:01.025127	1
39	admin	CREATE	materia	19	{"registro": "PRACTICA DE CONJUNTOS I (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:18:26.309439	1
40	admin	CREATE	materia	20	{"registro": "TEORIA DEL SONIDO (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:18:51.403028	1
41	admin	CREATE	materia	21	{"registro": "ARMONIA I (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:19:21.752726	1
42	admin	CREATE	materia	22	{"registro": "ARMONIA I (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:19:21.912522	1
43	admin	DELETE	materia	21	{"registro": "ARMONIA I (1ro. Técnico Medio)"}	127.0.0.1	crud.eliminar	POST	200	2026-10-21 11:19:43.802757	1
44	admin	CREATE	materia	23	{"registro": "LENGUAJES  MUSICALES SUPERIORES (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:20:11.790079	1
45	admin	CREATE	materia	24	{"registro": "PSICOPEDAGOGIA DE LA MUSICA (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:21:01.726227	1
46	admin	UPDATE	materia	24	{"registro": "PSICOPEDAGOGIA DE LA MUSICA (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:23:33.542973	1
47	admin	CREATE	materia	25	{"registro": "INSTRUMENTO COMPLEMENTARIO (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:24:39.759981	1
48	admin	CREATE	materia	26	{"registro": "INFORMATICA MUSICAL (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:25:20.626644	1
49	admin	CREATE	materia	27	{"registro": "INFORMATICA MUSICAL (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:25:48.778049	1
50	admin	UPDATE	materia	23	{"registro": "LENGUAJES  MUSICALES SUPERIORES (1ro. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:28:06.642529	1
51	admin	DELETE	materia	26	{"registro": "INFORMATICA MUSICAL (2do. Técnico Medio)"}	127.0.0.1	crud.eliminar	POST	200	2026-10-21 11:34:00.415101	1
52	admin	CREATE	materia	28	{"registro": "LENGUAJE MUSICAL INTERMEDIO I (1ro. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:37:40.613527	1
54	admin	CREATE	materia	30	{"registro": "PRACTICA COLECTIVA INTERMEDIA I (1ro. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:38:35.494015	1
56	admin	CREATE	materia	32	{"registro": "INSTRUMENTO DE ESPECIALIDAD VIII (2do. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:41:54.978201	1
59	admin	CREATE	materia	35	{"registro": "PRACTICA DE CONJUNTOS II (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:48:48.773713	1
61	admin	CREATE	materia	37	{"registro": "ARMONIA II (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:58:49.860256	1
63	admin	CREATE	materia	39	{"registro": "HISTORIA DE LA MUSICA I (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:00:53.466336	1
65	admin	CREATE	materia	41	{"registro": "TEORIA COMPLEMENTARIA (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:02:48.497246	1
67	admin	CREATE	curso	2	{"registro": "PRIMERO INICIAL B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:29:53.886495	1
68	admin	CREATE	curso	3	{"registro": "SEGUNDO INICIAL A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:32:29.91215	1
69	admin	CREATE	curso	4	{"registro": "SEGUNDO INICIAL A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:32:29.946337	1
70	admin	DELETE	curso	4	{"registro": "SEGUNDO INICIAL A / 2026"}	127.0.0.1	crud.eliminar	POST	200	2026-10-21 12:32:36.894142	1
72	admin	CREATE	curso	6	{"registro": "PRIMERO BASICO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:34:18.684392	1
74	admin	CREATE	curso	8	{"registro": "SEGUNDO BÁSICO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:35:34.055244	1
53	admin	CREATE	materia	29	{"registro": "INSTRUMENTO DE ESPECIALIDAD VII (1ro. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:38:10.61747	1
55	admin	CREATE	materia	31	{"registro": "LENGUAJE MUSICAL INTERMEDIO II (2do. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:40:46.495093	1
57	admin	CREATE	materia	33	{"registro": "PRACTICA COLECTIVA INTERMEDIA II (2do. Intermedio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:42:42.053307	1
58	admin	CREATE	materia	34	{"registro": "INSTRUMENTO DE ESPECIALIDAD II (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:47:21.528957	1
60	admin	CREATE	materia	36	{"registro": "MUSICA DE CAMARA (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:49:30.98875	1
62	admin	CREATE	materia	38	{"registro": "FORMAS Y ANALISIS MUSICAL I (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 11:59:59.098557	1
64	admin	CREATE	materia	40	{"registro": "INSTRUMENTO COMPLEMENTARIO II (2do. Técnico Medio)"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:02:18.54251	1
66	admin	CREATE	curso	1	{"registro": "PRIMERO INICIAL A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:29:16.075711	1
71	admin	CREATE	curso	5	{"registro": "SEGUNDO INICIAL B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:32:57.602961	1
73	admin	CREATE	curso	7	{"registro": "PRIMERO BASICO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:34:46.000146	1
75	admin	UPDATE	curso	6	{"registro": "PRIMERO BÁSICO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:35:59.259953	1
76	admin	UPDATE	curso	7	{"registro": "PRIMERO BÁSICO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:38:16.555135	1
77	admin	UPDATE	curso	7	{"registro": "PRIMERO BÁSICO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:38:16.601379	1
78	admin	CREATE	curso	9	{"registro": "SEGUNDO BÁSICO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:40:09.418359	1
79	admin	CREATE	curso	10	{"registro": "TERCERO BÁSICO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:41:07.737158	1
80	admin	CREATE	curso	11	{"registro": "TERCERO BÁSICO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:41:46.058528	1
81	admin	CREATE	curso	12	{"registro": "PRIMERO INTERMEDIO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:49:25.482615	1
82	admin	CREATE	curso	13	{"registro": "PRIMERO INTERMEDIO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:50:17.358684	1
83	admin	CREATE	curso	14	{"registro": "SEGUNDO INTERMEDIO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:51:24.977779	1
84	admin	CREATE	curso	15	{"registro": "SEGUNDO INTERMEDIO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:52:57.565252	1
85	admin	CREATE	curso	16	{"registro": "TERCERO INTERMEDIO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:53:32.129609	1
86	admin	CREATE	curso	17	{"registro": "TERCERO INTERMEDIO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 12:53:58.939997	1
87	admin	CREATE	curso	18	{"registro": "PRIMERO TÉCNICO MEDIO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 14:43:34.438579	1
88	admin	CREATE	curso	19	{"registro": "PRIMERO TÉCNICO MEDIO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 14:45:12.050766	1
89	admin	CREATE	curso	20	{"registro": "SEGUNDO TÉCNICO MEDIO A / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 14:46:53.829274	1
90	admin	UPDATE	gestion	1	{"registro": "2026 - Técnico Medio"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 14:49:13.709029	1
91	admin	CREATE	curso	21	{"registro": "SEGUNDO TÉCNICO MEDIO B / 2026"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 14:51:30.254594	1
92	admin	CREATE	alumno	1	{"registro": "Pinto Lopez Juancito"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 14:59:26.452479	1
93	admin	CREATE	alumno	2	{"registro": "Rios Flores Genoveva"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:01:36.620591	1
94	admin	CREATE	alumno	3	{"registro": "Santa Elliete"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:02:43.449084	1
95	admin	UPDATE	alumno	3	{"registro": "Santa Cruz Loza Elliete"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:03:53.039547	1
96	admin	CREATE	alumno	4	{"registro": "Puma Valverde Agustin Ian"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:04:59.372736	1
97	admin	CREATE	alumno	5	{"registro": "Melgarejillo Burrillo Mariano"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:07:17.832694	1
98	admin	CREATE	profesor	1	{"registro": "Rodriguez Ortíz Francisco"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:26:45.403371	1
99	admin	CREATE	usuario	2	{"registro": "frodriguez"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:28:03.200428	1
100	frodriguez	LOGIN	auth	2	{"ok": true}	127.0.0.1	auth.login	POST	200	2026-10-21 15:29:12.322911	2
101	frodriguez	LOGIN	auth	2	{"ok": true}	127.0.0.1	auth.login	POST	200	2026-10-21 15:29:15.428967	2
102	admin	UPDATE	profesor	1	{"registro": "Rodriguez Ortíz Francisco"}	127.0.0.1	crud.guardar	POST	200	2026-10-21 15:32:00.720501	1
103	admin	LOGIN	auth	1	{"ok": true}	127.0.0.1	auth.login	POST	200	2026-10-22 09:52:57.255675	1
\.


--
-- Data for Name: curso; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."curso" ("id", "curso", "paralelo", "aula", "capacidad", "creado", "act", "id_usuario", "id_gestion", "id_grado") FROM stdin;
1	PRIMERO INICIAL	A	\N	\N	2026-10-21 12:29:16.044345	2026-10-21 12:29:16.04435	1	1	1
2	PRIMERO INICIAL	B	\N	\N	2026-10-21 12:29:53.883979	2026-10-21 12:29:53.883983	1	1	1
3	SEGUNDO INICIAL	A	\N	\N	2026-10-21 12:32:29.910469	2026-10-21 12:32:29.910474	1	1	2
5	SEGUNDO INICIAL	B	\N	\N	2026-10-21 12:32:57.600935	2026-10-21 12:32:57.60094	1	1	2
8	SEGUNDO BÁSICO	A	\N	\N	2026-10-21 12:35:34.053394	2026-10-21 12:35:34.053397	1	1	4
6	PRIMERO BÁSICO	A	\N	\N	2026-10-21 12:34:18.682454	2026-10-21 12:35:59.257394	1	1	3
7	PRIMERO BÁSICO	B	\N	\N	2026-10-21 12:34:45.998577	2026-10-21 12:38:16.553426	1	1	3
9	SEGUNDO BÁSICO	B	\N	\N	2026-10-21 12:40:09.416613	2026-10-21 12:40:09.416617	1	1	4
10	TERCERO BÁSICO	A	\N	\N	2026-10-21 12:41:07.735586	2026-10-21 12:41:07.73559	1	1	5
11	TERCERO BÁSICO	B	\N	\N	2026-10-21 12:41:46.055432	2026-10-21 12:41:46.055437	1	1	5
12	PRIMERO INTERMEDIO	A	\N	\N	2026-10-21 12:49:25.480435	2026-10-21 12:49:25.48044	1	1	6
13	PRIMERO INTERMEDIO	B	\N	\N	2026-10-21 12:50:17.357208	2026-10-21 12:50:17.357212	1	1	6
14	SEGUNDO INTERMEDIO	A	\N	\N	2026-10-21 12:51:24.970996	2026-10-21 12:51:24.970999	1	1	7
15	SEGUNDO INTERMEDIO	B	\N	\N	2026-10-21 12:52:57.563497	2026-10-21 12:52:57.563505	1	1	7
16	TERCERO INTERMEDIO	A	\N	\N	2026-10-21 12:53:32.125899	2026-10-21 12:53:32.125905	1	1	8
17	TERCERO INTERMEDIO	B	\N	\N	2026-10-21 12:53:58.937067	2026-10-21 12:53:58.937073	1	1	8
18	PRIMERO TÉCNICO MEDIO	A	\N	\N	2026-10-21 14:43:34.388371	2026-10-21 14:43:34.388375	1	1	9
19	PRIMERO TÉCNICO MEDIO	B	\N	\N	2026-10-21 14:45:12.048721	2026-10-21 14:45:12.048726	1	1	9
20	SEGUNDO TÉCNICO MEDIO	A	\N	\N	2026-10-21 14:46:53.825908	2026-10-21 14:46:53.825912	1	1	10
21	SEGUNDO TÉCNICO MEDIO	B	\N	\N	2026-10-21 14:51:30.252254	2026-10-21 14:51:30.252258	1	1	10
\.


--
-- Data for Name: gestion; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."gestion" ("id", "gestion", "plan", "inicio", "fin", "activo", "creado", "act", "id_usuario") FROM stdin;
1	2026	Técnico Medio	2026-01-05	2026-11-30	t	2026-10-20 16:00:59.219996	2026-10-21 14:49:11.22864	1
\.


--
-- Data for Name: grado; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."grado" ("id", "grado", "nivel", "creado", "act", "id_usuario", "id_instrumento") FROM stdin;
1	1ro. Inicial	Inicial	2026-10-20 16:32:26.349282	2026-10-20 16:32:26.349289	1	1
2	2do. Inicial	Inicial	2026-10-20 16:32:52.30802	2026-10-20 16:32:52.308024	1	1
3	1ro. Básico	Básico	2026-10-20 16:35:33.68664	2026-10-20 16:35:33.686645	1	1
4	2do. Básico	Básico	2026-10-20 16:35:58.001913	2026-10-20 16:35:58.001917	1	1
5	3ro. Básico	Básico	2026-10-20 16:36:30.23306	2026-10-20 16:36:30.233065	1	1
6	1ro. Intermedio	Intermedio	2026-10-20 16:37:16.730435	2026-10-20 16:37:16.73044	1	1
7	2do. Intermedio	Intermedio	2026-10-20 16:37:37.343383	2026-10-20 16:37:37.343387	1	1
8	3ro. Intermedio	Intermedio	2026-10-20 16:37:58.999989	2026-10-20 16:37:58.999993	1	1
9	1ro. Técnico Medio	Técnico Medio	2026-10-20 16:38:52.432316	2026-10-20 16:38:52.43232	1	1
10	2do. Técnico Medio	Técnico Medio	2026-10-20 16:39:12.944377	2026-10-20 16:39:12.944382	1	1
\.


--
-- Data for Name: inscrito; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."inscrito" ("id", "reserva", "inscrito", "descuento", "motivo_descuento", "abandono", "obs", "otras_materias", "creado", "act", "id_usuario", "id_alumno", "id_curso", "id_instrumento") FROM stdin;
\.


--
-- Data for Name: instrumento; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."instrumento" ("id", "instrumento", "area", "creado", "act", "id_usuario") FROM stdin;
1	Piano	Teclas	2026-10-20 16:02:18.961986	2026-10-20 16:02:18.961992	1
2	Violín	\N	2026-10-20 16:04:51.915827	2026-10-20 16:04:51.915831	1
3	Guitarra	\N	2026-10-20 16:05:32.331109	2026-10-20 16:05:32.331114	1
4	Cello	\N	2026-10-20 16:17:33.128406	2026-10-20 16:17:33.128412	1
5	Trompeta	\N	2026-10-20 16:17:46.146727	2026-10-20 16:17:46.146731	1
\.


--
-- Data for Name: materia; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."materia" ("id", "materia", "sigla", "creado", "act", "id_usuario", "id_grado") FROM stdin;
1	LENGUAJE MUSICAL INICIAL I	LMI1	2026-10-20 16:42:03.484521	2026-10-20 16:42:03.484526	1	1
2	INSTRUMENTO DE ESPECIALIDAD I	IE1	2026-10-20 16:46:32.884095	2026-10-20 16:49:05.896969	1	1
3	LENGUAJE MUSICAL INICIAL II	LMI2	2026-10-20 16:50:52.393406	2026-10-20 16:50:52.39341	1	2
4	INSTRUMENTO DE ESPECIALIDAD II	IE2	2026-10-20 16:51:51.178079	2026-10-20 16:51:51.178083	1	2
5	PRACTICA COLECTIVA INICIAL I	PCI1	2026-10-20 16:52:28.162915	2026-10-20 16:52:28.162919	1	2
6	LENGUAJE MUSICAL BASICO I	LMB1	2026-10-21 10:49:46.439887	2026-10-21 10:49:46.439892	1	3
7	INSTRUMENTO DE ESPECIALIDAD IV	IE4	2026-10-21 10:51:10.73068	2026-10-21 10:51:10.730684	1	3
8	PRACTICA COLECTIVA BASICA I	PCB1	2026-10-21 11:00:44.106849	2026-10-21 11:00:44.106854	1	3
9	LENGUAJE MUSICAL BASICO II	LMB2	2026-10-21 11:02:07.413717	2026-10-21 11:02:07.413721	1	4
10	INSTRUMENTO DE ESPECIALIDAD V	IE5	2026-10-21 11:03:16.270326	2026-10-21 11:03:16.27033	1	4
11	PRACTICA COLECTIVA BASICA II	PCB2	2026-10-21 11:03:47.70592	2026-10-21 11:03:47.705926	1	4
12	LENGUAJE MUSICAL BASICO III	LMB3	2026-10-21 11:05:30.7364	2026-10-21 11:05:30.736405	1	5
13	INSTRUMENTO DE ESPECIALIDAD VI	IE6	2026-10-21 11:06:07.606599	2026-10-21 11:06:07.606604	1	5
14	PRACTICA COLECTIVA BASICA III	PCB3	2026-10-21 11:07:24.00824	2026-10-21 11:07:24.008245	1	5
15	LENGUAJE MUSICAL INTERMEDIO III	LMI3	2026-10-21 11:11:56.433417	2026-10-21 11:11:56.433422	1	8
16	INSTRUMENTO DE ESPECIALIDAD IX	IE9	2026-10-21 11:13:03.150954	2026-10-21 11:13:03.150959	1	8
17	PRACTICA COLECTIVA INTERMEDIA III	PCI3	2026-10-21 11:14:23.454921	2026-10-21 11:14:23.454925	1	8
18	INSTRUMENTO DE ESPECIALIDAD I	IE1	2026-10-21 11:18:01.023533	2026-10-21 11:18:01.023538	1	9
19	PRACTICA DE CONJUNTOS I	PC1	2026-10-21 11:18:26.307814	2026-10-21 11:18:26.307818	1	9
20	TEORIA DEL SONIDO	TS	2026-10-21 11:18:51.401451	2026-10-21 11:18:51.401455	1	9
22	ARMONIA I	A1	2026-10-21 11:19:21.910591	2026-10-21 11:19:21.910596	1	9
24	PSICOPEDAGOGIA DE LA MUSICA	PM	2026-10-21 11:21:01.724778	2026-10-21 11:23:33.539985	1	9
25	INSTRUMENTO COMPLEMENTARIO	IC	2026-10-21 11:24:39.757531	2026-10-21 11:24:39.757535	1	9
27	INFORMATICA MUSICAL	IM	2026-10-21 11:25:48.774696	2026-10-21 11:25:48.774702	1	9
23	LENGUAJES  MUSICALES SUPERIORES	LMS	2026-10-21 11:20:11.788412	2026-10-21 11:28:06.640626	1	9
28	LENGUAJE MUSICAL INTERMEDIO I	LMI1	2026-10-21 11:37:40.611978	2026-10-21 11:37:40.611982	1	6
29	INSTRUMENTO DE ESPECIALIDAD VII	IE7	2026-10-21 11:38:10.615916	2026-10-21 11:38:10.61592	1	6
30	PRACTICA COLECTIVA INTERMEDIA I	PCI1	2026-10-21 11:38:35.492342	2026-10-21 11:38:35.492346	1	6
31	LENGUAJE MUSICAL INTERMEDIO II	LMI2	2026-10-21 11:40:46.493265	2026-10-21 11:40:46.493269	1	7
32	INSTRUMENTO DE ESPECIALIDAD VIII	IE8	2026-10-21 11:41:54.976592	2026-10-21 11:41:54.976596	1	7
33	PRACTICA COLECTIVA INTERMEDIA II	PCI2	2026-10-21 11:42:42.05159	2026-10-21 11:42:42.051595	1	7
34	INSTRUMENTO DE ESPECIALIDAD II	IE2	2026-10-21 11:47:21.525966	2026-10-21 11:47:21.52597	1	10
35	PRACTICA DE CONJUNTOS II	PC2	2026-10-21 11:48:48.771498	2026-10-21 11:48:48.771502	1	10
36	MUSICA DE CAMARA	MC	2026-10-21 11:49:30.987153	2026-10-21 11:49:30.987157	1	10
37	ARMONIA II	A2	2026-10-21 11:58:49.85798	2026-10-21 11:58:49.857985	1	10
38	FORMAS Y ANALISIS MUSICAL I	FAM1	2026-10-21 11:59:59.096811	2026-10-21 11:59:59.096816	1	10
39	HISTORIA DE LA MUSICA I	HM1	2026-10-21 12:00:53.464707	2026-10-21 12:00:53.464711	1	10
40	INSTRUMENTO COMPLEMENTARIO II	IC2	2026-10-21 12:02:18.540298	2026-10-21 12:02:18.540302	1	10
41	TEORIA COMPLEMENTARIA	TC	2026-10-21 12:02:48.495219	2026-10-21 12:02:48.495224	1	10
\.


--
-- Data for Name: nota; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."nota" ("id", "nota1", "nota2", "nota3", "nota4", "nota_final", "2t", "nota_aprob", "aprobado", "obs", "creado", "act", "id_usuario", "id_asignado") FROM stdin;
\.


--
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."pago" ("id", "cuota", "pagado", "metodo_pago", "fecha_pago", "referencia_pago", "obs", "creado", "act", "id_usuario", "id_inscrito") FROM stdin;
\.


--
-- Data for Name: permiso; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."permiso" ("id", "permiso", "descripcion", "creado", "act") FROM stdin;
1	gestion_ver	Ver · Gestiones académicas	2026-10-20 15:08:28.494882	2026-10-20 15:08:28.494887
2	gestion_crear	Crear · Gestiones académicas	2026-10-20 15:08:28.497851	2026-10-20 15:08:28.497855
3	gestion_editar	Editar · Gestiones académicas	2026-10-20 15:08:28.499572	2026-10-20 15:08:28.499575
4	gestion_eliminar	Eliminar · Gestiones académicas	2026-10-20 15:08:28.501217	2026-10-20 15:08:28.50122
5	instrumento_ver	Ver · Instrumentos	2026-10-20 15:08:28.502834	2026-10-20 15:08:28.502836
6	instrumento_crear	Crear · Instrumentos	2026-10-20 15:08:28.504691	2026-10-20 15:08:28.504693
7	instrumento_editar	Editar · Instrumentos	2026-10-20 15:08:28.506502	2026-10-20 15:08:28.506504
8	instrumento_eliminar	Eliminar · Instrumentos	2026-10-20 15:08:28.507954	2026-10-20 15:08:28.507956
9	grado_ver	Ver · Grados	2026-10-20 15:08:28.509427	2026-10-20 15:08:28.50943
10	grado_crear	Crear · Grados	2026-10-20 15:08:28.510962	2026-10-20 15:08:28.510964
11	grado_editar	Editar · Grados	2026-10-20 15:08:28.512482	2026-10-20 15:08:28.512484
12	grado_eliminar	Eliminar · Grados	2026-10-20 15:08:28.513985	2026-10-20 15:08:28.513988
13	materia_ver	Ver · Materias y requisitos	2026-10-20 15:08:28.515441	2026-10-20 15:08:28.515443
14	materia_crear	Crear · Materias y requisitos	2026-10-20 15:08:28.516911	2026-10-20 15:08:28.516913
15	materia_editar	Editar · Materias y requisitos	2026-10-20 15:08:28.518339	2026-10-20 15:08:28.518342
16	materia_eliminar	Eliminar · Materias y requisitos	2026-10-20 15:08:28.519808	2026-10-20 15:08:28.51981
17	curso_ver	Ver · Cursos	2026-10-20 15:08:28.521364	2026-10-20 15:08:28.521367
18	curso_crear	Crear · Cursos	2026-10-20 15:08:28.52288	2026-10-20 15:08:28.522883
19	curso_editar	Editar · Cursos	2026-10-20 15:08:28.524271	2026-10-20 15:08:28.524273
20	curso_eliminar	Eliminar · Cursos	2026-10-20 15:08:28.525602	2026-10-20 15:08:28.525604
21	profesor_ver	Ver · Profesores	2026-10-20 15:08:28.526918	2026-10-20 15:08:28.52692
22	profesor_crear	Crear · Profesores	2026-10-20 15:08:28.528226	2026-10-20 15:08:28.528228
23	profesor_editar	Editar · Profesores	2026-10-20 15:08:28.529589	2026-10-20 15:08:28.529592
24	profesor_eliminar	Eliminar · Profesores	2026-10-20 15:08:28.530888	2026-10-20 15:08:28.53089
25	alumno_ver	Ver · Alumnos	2026-10-20 15:08:28.532205	2026-10-20 15:08:28.532207
26	alumno_crear	Crear · Alumnos	2026-10-20 15:08:28.533606	2026-10-20 15:08:28.533609
27	alumno_editar	Editar · Alumnos	2026-10-20 15:08:28.535077	2026-10-20 15:08:28.53508
28	alumno_eliminar	Eliminar · Alumnos	2026-10-20 15:08:28.536427	2026-10-20 15:08:28.536429
29	inscrito_ver	Ver · Inscripciones	2026-10-20 15:08:28.53784	2026-10-20 15:08:28.537842
30	inscrito_crear	Crear · Inscripciones	2026-10-20 15:08:28.539227	2026-10-20 15:08:28.539229
31	inscrito_editar	Editar · Inscripciones	2026-10-20 15:08:28.540589	2026-10-20 15:08:28.540591
32	inscrito_eliminar	Eliminar · Inscripciones	2026-10-20 15:08:28.541966	2026-10-20 15:08:28.541968
33	asignado_ver	Ver · Asignaciones (profesor · materia · alumno · curso)	2026-10-20 15:08:28.543337	2026-10-20 15:08:28.543339
34	asignado_crear	Crear · Asignaciones (profesor · materia · alumno · curso)	2026-10-20 15:08:28.54469	2026-10-20 15:08:28.544693
35	asignado_editar	Editar · Asignaciones (profesor · materia · alumno · curso)	2026-10-20 15:08:28.546037	2026-10-20 15:08:28.546039
36	asignado_eliminar	Eliminar · Asignaciones (profesor · materia · alumno · curso)	2026-10-20 15:08:28.547407	2026-10-20 15:08:28.547409
37	nota_ver	Ver · Calificaciones	2026-10-20 15:08:28.548758	2026-10-20 15:08:28.54876
38	nota_editar	Editar · Calificaciones	2026-10-20 15:08:28.550078	2026-10-20 15:08:28.550081
39	pago_ver	Ver · Pagos	2026-10-20 15:08:28.551374	2026-10-20 15:08:28.551376
40	pago_editar	Editar · Pagos	2026-10-20 15:08:28.552714	2026-10-20 15:08:28.552717
41	usuario_ver	Ver · Usuarios	2026-10-20 15:08:28.55404	2026-10-20 15:08:28.554042
42	usuario_crear	Crear · Usuarios	2026-10-20 15:08:28.55535	2026-10-20 15:08:28.555353
43	usuario_editar	Editar · Usuarios	2026-10-20 15:08:28.556685	2026-10-20 15:08:28.556688
44	usuario_eliminar	Eliminar · Usuarios	2026-10-20 15:08:28.558044	2026-10-20 15:08:28.558047
45	rol_ver	Ver · Roles y permisos	2026-10-20 15:08:28.559572	2026-10-20 15:08:28.559575
46	rol_crear	Crear · Roles y permisos	2026-10-20 15:08:28.560857	2026-10-20 15:08:28.56086
47	rol_editar	Editar · Roles y permisos	2026-10-20 15:08:28.562245	2026-10-20 15:08:28.562247
48	rol_eliminar	Eliminar · Roles y permisos	2026-10-20 15:08:28.563541	2026-10-20 15:08:28.563544
49	permiso_ver	Ver · Catálogo de permisos	2026-10-20 15:08:28.564949	2026-10-20 15:08:28.564951
50	permiso_editar	Editar · Catálogo de permisos	2026-10-20 15:08:28.567134	2026-10-20 15:08:28.567138
51	auditoria_ver	Ver · Registro de auditoría	2026-10-20 15:08:28.569059	2026-10-20 15:08:28.569063
\.


--
-- Data for Name: profesor; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."profesor" ("id", "nombre", "paterno", "materno", "masculino", "ci", "formacion", "email", "activo", "usr_id_login", "creado", "act", "id_usuario") FROM stdin;
1	Francisco	Rodriguez	Ortíz	t	7654321	Especialista en Teclas	frodriguez@gmail.com	t	2	2026-10-21 15:26:45.358661	2026-10-21 15:32:00.7126	1
\.


--
-- Data for Name: requisito; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."requisito" ("id_materia", "id_materia_req") FROM stdin;
34	18
35	19
37	22
40	25
\.


--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."rol" ("id", "rol", "descripcion", "creado", "act") FROM stdin;
1	Administrador	Acceso total al sistema	2026-10-20 15:08:28.574473	2026-10-20 15:08:28.574476
2	Consulta	Solo lectura de la información académica y de pagos	2026-10-20 15:08:28.589197	2026-10-20 15:08:28.589201
3	Transcriptor	Registra alumnos, inscripciones, asignaciones y notas	2026-10-20 15:08:28.595731	2026-10-20 15:08:28.595734
4	Profesor	Califica y consulta únicamente sus materias asignadas	2026-10-20 15:08:28.602272	2026-10-20 15:08:28.602275
5	Estudiante	Consulta sus propias inscripciones, notas y pagos	2026-10-20 15:08:28.607851	2026-10-20 15:08:28.607853
\.


--
-- Data for Name: rol_permiso; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."rol_permiso" ("id_rol", "id_permiso") FROM stdin;
1	16
1	8
1	2
1	45
1	38
1	31
1	24
1	17
1	9
1	3
1	46
1	39
1	32
1	25
1	18
1	10
1	4
1	47
1	40
1	33
1	26
1	19
1	12
1	11
1	48
1	41
1	34
1	27
1	20
1	13
1	5
1	49
1	42
1	35
1	28
1	21
1	14
1	6
1	1
1	50
1	43
1	36
1	29
1	22
1	15
1	7
1	51
1	44
1	37
1	30
1	23
2	25
2	33
2	9
2	13
2	21
2	1
2	29
2	5
2	39
2	37
2	17
3	35
3	21
3	30
3	38
3	26
3	5
3	31
3	9
3	34
3	17
3	37
3	25
3	1
3	29
3	27
3	33
3	13
4	17
4	38
4	29
4	5
4	9
4	13
4	25
4	1
4	37
4	33
5	39
5	29
5	33
5	37
5	25
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."usuario" ("id", "usuario", "email", "password", "activo", "last_login", "creado", "act") FROM stdin;
2	frodriguez	frodriguez@gmail.com	scrypt:32768:8:1$yaYQQH17GHIQa86d$df64c051953d1d4bce5612f385700c8983042fd4fb5a76c8f98038b0a1787ccee171ece09c851b496a56f97b6fcdacc23d8b3d93293779947bdd23fdb71b8d82	t	2026-10-21	2026-10-21 15:28:03.150354	2026-10-21 15:28:03.150356
1	admin	admin@ifalfa.edu	scrypt:32768:8:1$wsjWFYyPS44jMLdt$8006a06439ba1ed54b04614307851d38279f5c09a810ff3721647fb30113f30fd9e3322a24a021201b41fa8e08dd180081e9a43067a6090b24093ee1ec8ec4c1	t	2026-10-22	2026-10-20 15:12:04.813126	2026-10-22 09:52:57.447796
\.


--
-- Data for Name: usuario_rol; Type: TABLE DATA; Schema: public; Owner: uaded
--

COPY "public"."usuario_rol" ("id_usuario", "id_rol") FROM stdin;
1	1
2	4
\.


--
-- Name: alumno_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."alumno_id_seq"', 5, true);


--
-- Name: asignado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."asignado_id_seq"', 1, false);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."audit_log_id_seq"', 103, true);


--
-- Name: curso_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."curso_id_seq"', 21, true);


--
-- Name: gestion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."gestion_id_seq"', 1, true);


--
-- Name: grado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."grado_id_seq"', 10, true);


--
-- Name: inscrito_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."inscrito_id_seq"', 1, false);


--
-- Name: instrumento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."instrumento_id_seq"', 5, true);


--
-- Name: materia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."materia_id_seq"', 41, true);


--
-- Name: nota_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."nota_id_seq"', 1, false);


--
-- Name: pago_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."pago_id_seq"', 1, false);


--
-- Name: permiso_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."permiso_id_seq"', 51, true);


--
-- Name: profesor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."profesor_id_seq"', 1, true);


--
-- Name: rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."rol_id_seq"', 5, true);


--
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: uaded
--

SELECT pg_catalog.setval('"public"."usuario_id_seq"', 2, true);


--
-- Name: alumno alumno_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."alumno"
    ADD CONSTRAINT "alumno_pkey" PRIMARY KEY ("id");


--
-- Name: asignado asignado_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."asignado"
    ADD CONSTRAINT "asignado_pkey" PRIMARY KEY ("id");


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."audit_log"
    ADD CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id");


--
-- Name: curso curso_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."curso"
    ADD CONSTRAINT "curso_pkey" PRIMARY KEY ("id");


--
-- Name: gestion gestion_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."gestion"
    ADD CONSTRAINT "gestion_pkey" PRIMARY KEY ("id");


--
-- Name: grado grado_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."grado"
    ADD CONSTRAINT "grado_pkey" PRIMARY KEY ("id");


--
-- Name: inscrito inscrito_pk; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."inscrito"
    ADD CONSTRAINT "inscrito_pk" PRIMARY KEY ("id");


--
-- Name: instrumento instrumento_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."instrumento"
    ADD CONSTRAINT "instrumento_pkey" PRIMARY KEY ("id");


--
-- Name: materia materia_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."materia"
    ADD CONSTRAINT "materia_pkey" PRIMARY KEY ("id");


--
-- Name: nota nota_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."nota"
    ADD CONSTRAINT "nota_pkey" PRIMARY KEY ("id");


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."pago"
    ADD CONSTRAINT "pago_pkey" PRIMARY KEY ("id");


--
-- Name: permiso permiso_permiso_key; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."permiso"
    ADD CONSTRAINT "permiso_permiso_key" UNIQUE ("permiso");


--
-- Name: permiso permiso_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."permiso"
    ADD CONSTRAINT "permiso_pkey" PRIMARY KEY ("id");


--
-- Name: profesor profesor_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."profesor"
    ADD CONSTRAINT "profesor_pkey" PRIMARY KEY ("id");


--
-- Name: rol_permiso rol_permiso_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."rol_permiso"
    ADD CONSTRAINT "rol_permiso_pkey" PRIMARY KEY ("id_rol", "id_permiso");


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."rol"
    ADD CONSTRAINT "rol_pkey" PRIMARY KEY ("id");


--
-- Name: rol rol_rol_key; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."rol"
    ADD CONSTRAINT "rol_rol_key" UNIQUE ("rol");


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_pkey" PRIMARY KEY ("id");


--
-- Name: usuario_rol usuario_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."usuario_rol"
    ADD CONSTRAINT "usuario_rol_pkey" PRIMARY KEY ("id_usuario", "id_rol");


--
-- Name: usuario usuario_usuario_key; Type: CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_usuario_key" UNIQUE ("usuario");


--
-- Name: idx_alumno_login; Type: INDEX; Schema: public; Owner: uaded
--

CREATE UNIQUE INDEX "idx_alumno_login" ON "public"."alumno" USING "btree" ("usr_id_login") WHERE ("usr_id_login" IS NOT NULL);


--
-- Name: idx_asignado_curso_mat; Type: INDEX; Schema: public; Owner: uaded
--

CREATE INDEX "idx_asignado_curso_mat" ON "public"."asignado" USING "btree" ("id_curso", "id_materia");


--
-- Name: idx_asignado_ins_mat; Type: INDEX; Schema: public; Owner: uaded
--

CREATE UNIQUE INDEX "idx_asignado_ins_mat" ON "public"."asignado" USING "btree" ("id_inscrito", "id_materia");


--
-- Name: idx_asignado_profesor; Type: INDEX; Schema: public; Owner: uaded
--

CREATE INDEX "idx_asignado_profesor" ON "public"."asignado" USING "btree" ("id_profesor");


--
-- Name: idx_audit_log_accion; Type: INDEX; Schema: public; Owner: uaded
--

CREATE INDEX "idx_audit_log_accion" ON "public"."audit_log" USING "btree" ("accion") WITH ("fillfactor"='90');


--
-- Name: idx_audit_log_creado; Type: INDEX; Schema: public; Owner: uaded
--

CREATE INDEX "idx_audit_log_creado" ON "public"."audit_log" USING "btree" ("creado") WITH ("fillfactor"='90');


--
-- Name: idx_audit_log_modulo; Type: INDEX; Schema: public; Owner: uaded
--

CREATE INDEX "idx_audit_log_modulo" ON "public"."audit_log" USING "btree" ("modulo") WITH ("fillfactor"='90');


--
-- Name: idx_inscrito_alumno_curso; Type: INDEX; Schema: public; Owner: uaded
--

CREATE UNIQUE INDEX "idx_inscrito_alumno_curso" ON "public"."inscrito" USING "btree" ("id_alumno", "id_curso");


--
-- Name: idx_nota_asignado; Type: INDEX; Schema: public; Owner: uaded
--

CREATE UNIQUE INDEX "idx_nota_asignado" ON "public"."nota" USING "btree" ("id_asignado");


--
-- Name: idx_pago_inscrito; Type: INDEX; Schema: public; Owner: uaded
--

CREATE INDEX "idx_pago_inscrito" ON "public"."pago" USING "btree" ("id_inscrito");


--
-- Name: idx_profesor_login; Type: INDEX; Schema: public; Owner: uaded
--

CREATE UNIQUE INDEX "idx_profesor_login" ON "public"."profesor" USING "btree" ("usr_id_login") WHERE ("usr_id_login" IS NOT NULL);


--
-- Name: idx_uniq_req; Type: INDEX; Schema: public; Owner: uaded
--

CREATE UNIQUE INDEX "idx_uniq_req" ON "public"."requisito" USING "btree" ("id_materia", "id_materia_req");


--
-- Name: inscrito alumno_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."inscrito"
    ADD CONSTRAINT "alumno_fk" FOREIGN KEY ("id_alumno") REFERENCES "public"."alumno"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: nota asignado_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."nota"
    ADD CONSTRAINT "asignado_fk" FOREIGN KEY ("id_asignado") REFERENCES "public"."asignado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: asignado curso_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."asignado"
    ADD CONSTRAINT "curso_fk" FOREIGN KEY ("id_curso") REFERENCES "public"."curso"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: inscrito curso_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."inscrito"
    ADD CONSTRAINT "curso_fk" FOREIGN KEY ("id_curso") REFERENCES "public"."curso"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: curso gestion_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."curso"
    ADD CONSTRAINT "gestion_fk" FOREIGN KEY ("id_gestion") REFERENCES "public"."gestion"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: curso grado_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."curso"
    ADD CONSTRAINT "grado_fk" FOREIGN KEY ("id_grado") REFERENCES "public"."grado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: materia grado_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."materia"
    ADD CONSTRAINT "grado_fk" FOREIGN KEY ("id_grado") REFERENCES "public"."grado"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: asignado inscrito_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."asignado"
    ADD CONSTRAINT "inscrito_fk" FOREIGN KEY ("id_inscrito") REFERENCES "public"."inscrito"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: pago inscrito_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."pago"
    ADD CONSTRAINT "inscrito_fk" FOREIGN KEY ("id_inscrito") REFERENCES "public"."inscrito"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: grado instrumento_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."grado"
    ADD CONSTRAINT "instrumento_fk" FOREIGN KEY ("id_instrumento") REFERENCES "public"."instrumento"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: inscrito instrumento_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."inscrito"
    ADD CONSTRAINT "instrumento_fk" FOREIGN KEY ("id_instrumento") REFERENCES "public"."instrumento"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: asignado materia_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."asignado"
    ADD CONSTRAINT "materia_fk" FOREIGN KEY ("id_materia") REFERENCES "public"."materia"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requisito materia_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."requisito"
    ADD CONSTRAINT "materia_fk" FOREIGN KEY ("id_materia") REFERENCES "public"."materia"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: requisito materia_req_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."requisito"
    ADD CONSTRAINT "materia_req_fk" FOREIGN KEY ("id_materia_req") REFERENCES "public"."materia"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: asignado profesor_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."asignado"
    ADD CONSTRAINT "profesor_fk" FOREIGN KEY ("id_profesor") REFERENCES "public"."profesor"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rol_permiso rol_permiso_per_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."rol_permiso"
    ADD CONSTRAINT "rol_permiso_per_id_fkey" FOREIGN KEY ("id_permiso") REFERENCES "public"."permiso"("id");


--
-- Name: rol_permiso rol_permiso_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."rol_permiso"
    ADD CONSTRAINT "rol_permiso_rol_id_fkey" FOREIGN KEY ("id_rol") REFERENCES "public"."rol"("id");


--
-- Name: audit_log usuario_fk; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."audit_log"
    ADD CONSTRAINT "usuario_fk" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id") MATCH FULL ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: usuario_rol usuario_rol_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."usuario_rol"
    ADD CONSTRAINT "usuario_rol_rol_id_fkey" FOREIGN KEY ("id_rol") REFERENCES "public"."rol"("id");


--
-- Name: usuario_rol usuario_rol_usu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: uaded
--

ALTER TABLE ONLY "public"."usuario_rol"
    ADD CONSTRAINT "usuario_rol_usu_id_fkey" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id");


--
-- PostgreSQL database dump complete
--

--\unrestrict tUkmUnUpC7UVDXUHPqaQ37qY3AdqhCzDVbIdd95LbhQYgnYo1yvGH7fe1achGbh

