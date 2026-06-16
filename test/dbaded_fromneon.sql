CREATE SCHEMA "public";
CREATE TABLE "alumno" (
	"id" serial PRIMARY KEY,
	"nombre" varchar(100) NOT NULL,
	"paterno" varchar(100),
	"materno" varchar(100),
	"nacimiento" date,
	"masculino" boolean NOT NULL,
	"ci" integer,
	"direccion" varchar(150),
	"email" varchar(100),
	"activo" boolean NOT NULL,
	"obs" varchar(100),
	"usr_id_login" integer,
	"foto_ruta" varchar(150),
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "asignado" (
	"id" serial PRIMARY KEY,
	"cur_id" integer NOT NULL,
	"mat_id" integer NOT NULL,
	"pro_id" integer,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "audit_log" (
	"id" serial PRIMARY KEY,
	"usu_id" integer,
	"usuario" varchar(80) DEFAULT 'anónimo' NOT NULL,
	"accion" varchar(20) NOT NULL,
	"modulo" varchar(50) NOT NULL,
	"entidad_id" integer,
	"detalle" text,
	"ip" varchar(45),
	"endpoint" varchar(150),
	"metodo" varchar(10),
	"status" smallint DEFAULT 200,
	"creado" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "audit_log_accion_check" CHECK (((accion)::text = ANY (ARRAY[('CREATE'::character varying)::text, ('UPDATE'::character varying)::text, ('DELETE'::character varying)::text, ('LOGIN'::character varying)::text, ('LOGOUT'::character varying)::text, ('BULK'::character varying)::text, ('ERROR'::character varying)::text])))
);
CREATE TABLE "costo" (
	"id" serial PRIMARY KEY,
	"cur_id" integer NOT NULL,
	"nro_cuota" smallint NOT NULL,
	"cuota" numeric(10, 2) NOT NULL,
	"obs" varchar(200) NOT NULL,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "curso" (
	"id" serial PRIMARY KEY,
	"curso" varchar(150),
	"paralelo" varchar(50) NOT NULL,
	"gra_id" integer NOT NULL,
	"aula" varchar(50),
	"capacidad" smallint,
	"gestion" smallint NOT NULL,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "gestion" (
	"id" serial PRIMARY KEY,
	"gestion" smallint,
	"plan" varchar(150) NOT NULL,
	"inicio" date NOT NULL,
	"fin" date NOT NULL,
	"activo" boolean NOT NULL,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "grado" (
	"id" serial PRIMARY KEY,
	"grado" varchar(255) NOT NULL,
	"nivel" varchar(150) NOT NULL,
	"ges_id" integer NOT NULL,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "inscrito" (
	"id" serial PRIMARY KEY,
	"alu_id" integer CONSTRAINT "inscrito_alu_id_key" UNIQUE,
	"cur_id" integer,
	"reserva" boolean,
	"inscrito" boolean NOT NULL,
	"descuento" smallint NOT NULL,
	"motivo_descuento" varchar(100),
	"abandono" boolean NOT NULL,
	"obs" varchar(200),
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "materia" (
	"id" serial PRIMARY KEY,
	"materia" varchar(150) NOT NULL,
	"gra_id" integer NOT NULL,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "nota" (
	"id" serial PRIMARY KEY,
	"ins_id" integer NOT NULL,
	"mat_id" integer NOT NULL,
	"nota1" smallint NOT NULL,
	"nota2" smallint NOT NULL,
	"nota3" smallint NOT NULL,
	"nota_final" numeric(5, 1) NOT NULL,
	"nota_aprob" smallint NOT NULL,
	"aprobado" boolean,
	"obs" varchar(150),
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "pago" (
	"id" serial PRIMARY KEY,
	"ins_id" integer NOT NULL,
	"nro_cuota" smallint NOT NULL,
	"cuota" double precision NOT NULL,
	"pagado" boolean,
	"metodo_pago" varchar(50),
	"fecha_pago" timestamp,
	"referencia_pago" varchar(100),
	"obs" varchar(100),
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "permiso" (
	"id" serial PRIMARY KEY,
	"permiso" varchar(50) NOT NULL CONSTRAINT "permiso_permiso_key" UNIQUE,
	"descripcion" varchar(255),
	"creado" timestamp,
	"act" timestamp
);
CREATE TABLE "profesor" (
	"id" serial PRIMARY KEY,
	"nombre" varchar(100) NOT NULL,
	"paterno" varchar(50),
	"materno" varchar(50),
	"masculino" boolean NOT NULL,
	"ci" integer,
	"formacion" varchar(100),
	"email" varchar(100),
	"activo" boolean NOT NULL,
	"usr_id_login" integer,
	"creado" timestamp NOT NULL,
	"act" timestamp NOT NULL,
	"usu_id" integer NOT NULL
);
CREATE TABLE "rol" (
	"id" serial PRIMARY KEY,
	"rol" varchar(50) NOT NULL CONSTRAINT "rol_rol_key" UNIQUE,
	"descripcion" varchar(255),
	"creado" timestamp,
	"act" timestamp
);
CREATE TABLE "rol_permiso" (
	"rol_id" integer,
	"per_id" integer,
	CONSTRAINT "rol_permiso_pkey" PRIMARY KEY("rol_id","per_id")
);
CREATE TABLE "usuario" (
	"id" serial PRIMARY KEY,
	"usuario" varchar(80) NOT NULL CONSTRAINT "usuario_usuario_key" UNIQUE,
	"email" varchar(100) NOT NULL,
	"password" varchar(255) NOT NULL,
	"activo" boolean,
	"last_login" date NOT NULL,
	"creado" timestamp,
	"act" timestamp
);
CREATE TABLE "usuario_rol" (
	"usu_id" integer,
	"rol_id" integer,
	CONSTRAINT "usuario_rol_pkey" PRIMARY KEY("usu_id","rol_id")
);
CREATE UNIQUE INDEX "alumno_pkey" ON "alumno" ("id");
CREATE UNIQUE INDEX "asignado_pkey" ON "asignado" ("id");
CREATE UNIQUE INDEX "audit_log_pkey" ON "audit_log" ("id");
CREATE INDEX "idx_audit_log_accion" ON "audit_log" ("accion");
CREATE INDEX "idx_audit_log_creado" ON "audit_log" ("creado");
CREATE INDEX "idx_audit_log_modulo" ON "audit_log" ("modulo");
CREATE INDEX "idx_audit_log_usu_id" ON "audit_log" ("usu_id");
CREATE UNIQUE INDEX "costo_pkey" ON "costo" ("id");
CREATE UNIQUE INDEX "curso_pkey" ON "curso" ("id");
CREATE UNIQUE INDEX "gestion_pkey" ON "gestion" ("id");
CREATE UNIQUE INDEX "grado_pkey" ON "grado" ("id");
CREATE UNIQUE INDEX "inscrito_alu_id_key" ON "inscrito" ("alu_id");
CREATE UNIQUE INDEX "inscrito_pkey" ON "inscrito" ("id");
CREATE UNIQUE INDEX "materia_pkey" ON "materia" ("id");
CREATE UNIQUE INDEX "nota_pkey" ON "nota" ("id");
CREATE UNIQUE INDEX "pago_pkey" ON "pago" ("id");
CREATE UNIQUE INDEX "permiso_permiso_key" ON "permiso" ("permiso");
CREATE UNIQUE INDEX "permiso_pkey" ON "permiso" ("id");
CREATE UNIQUE INDEX "profesor_pkey" ON "profesor" ("id");
CREATE UNIQUE INDEX "rol_pkey" ON "rol" ("id");
CREATE UNIQUE INDEX "rol_rol_key" ON "rol" ("rol");
CREATE UNIQUE INDEX "rol_permiso_pkey" ON "rol_permiso" ("rol_id","per_id");
CREATE UNIQUE INDEX "usuario_pkey" ON "usuario" ("id");
CREATE UNIQUE INDEX "usuario_usuario_key" ON "usuario" ("usuario");
CREATE UNIQUE INDEX "usuario_rol_pkey" ON "usuario_rol" ("usu_id","rol_id");
ALTER TABLE "asignado" ADD CONSTRAINT "asignado_cur_id_fkey" FOREIGN KEY ("cur_id") REFERENCES "curso"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "asignado" ADD CONSTRAINT "asignado_mat_id_fkey" FOREIGN KEY ("mat_id") REFERENCES "materia"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "asignado" ADD CONSTRAINT "asignado_pro_id_fkey" FOREIGN KEY ("pro_id") REFERENCES "profesor"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_usu_id_fkey" FOREIGN KEY ("usu_id") REFERENCES "usuario"("id") ON DELETE SET NULL;
ALTER TABLE "costo" ADD CONSTRAINT "costo_cur_id_fkey" FOREIGN KEY ("cur_id") REFERENCES "curso"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "curso" ADD CONSTRAINT "curso_gra_id_fkey" FOREIGN KEY ("gra_id") REFERENCES "grado"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "grado" ADD CONSTRAINT "grado_ges_id_fkey" FOREIGN KEY ("ges_id") REFERENCES "gestion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "inscrito" ADD CONSTRAINT "inscrito_alu_id_fkey" FOREIGN KEY ("alu_id") REFERENCES "alumno"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "inscrito" ADD CONSTRAINT "inscrito_cur_id_fkey" FOREIGN KEY ("cur_id") REFERENCES "curso"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "materia" ADD CONSTRAINT "materia_gra_id_fkey" FOREIGN KEY ("gra_id") REFERENCES "grado"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "nota" ADD CONSTRAINT "nota_ins_id_fkey" FOREIGN KEY ("ins_id") REFERENCES "inscrito"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "nota" ADD CONSTRAINT "nota_mat_id_fkey" FOREIGN KEY ("mat_id") REFERENCES "materia"("id");
ALTER TABLE "pago" ADD CONSTRAINT "pago_ins_id_fkey" FOREIGN KEY ("ins_id") REFERENCES "inscrito"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "rol_permiso" ADD CONSTRAINT "rol_permiso_per_id_fkey" FOREIGN KEY ("per_id") REFERENCES "permiso"("id");
ALTER TABLE "rol_permiso" ADD CONSTRAINT "rol_permiso_rol_id_fkey" FOREIGN KEY ("rol_id") REFERENCES "rol"("id");
ALTER TABLE "usuario_rol" ADD CONSTRAINT "usuario_rol_rol_id_fkey" FOREIGN KEY ("rol_id") REFERENCES "rol"("id");
ALTER TABLE "usuario_rol" ADD CONSTRAINT "usuario_rol_usu_id_fkey" FOREIGN KEY ("usu_id") REFERENCES "usuario"("id");
