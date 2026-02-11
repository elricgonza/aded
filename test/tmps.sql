CREATE TABLE public.grado (
    id integer NOT NULL,
    grado character varying(255) NOT NULL,
    id_nivel integer NOT NULL
);
CREATE TABLE public.materia (
    id integer NOT NULL,
    materia character varying(150) NOT NULL,
    id_grado integer NOT NULL
);

CREATE TABLE public.nivel (
    id integer NOT NULL,
    nivel character varying(255) NOT NULL,
    id_plan integer NOT NULL
);
CREATE TABLE public.plan (
    id integer NOT NULL,
    plan character varying(150) NOT NULL
);


