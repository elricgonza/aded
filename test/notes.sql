---dif MATCH SIMPLE vs MATCH FULL---
-- mismo comportamiento cuando no son claves compuestas
-- cuando son claves compuestas, MATCH SIMPLE permite que una de las columnas sea NULL, 
-- mientras que MATCH FULL requiere que todas las columnas sean no NULL para que la restricción se aplique.

ALTER TABLE public.nivel ADD CONSTRAINT nivel_id_plan_fkey FOREIGN KEY (id_plan)
REFERENCES public.plan (id) MATCH SIMPLE
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE public.seg ADD CONSTRAINT insc_fk FOREIGN KEY (id_insc)
REFERENCES public.insc (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

---dif al crear un índice con:  CONCURRENTLY y UNIQUE---
1. CONCURRENTLY (La forma de crearlo)
Se refiere al momento de la creación del índice.

Sin CONCURRENTLY (Por defecto): Crea el índice rápidamente, pero bloquea la tabla contra escrituras (INSERT, UPDATE, DELETE) mientras se construye. Esto puede dejar tu aplicación en pausa por minutos u horas en tablas grandes.

Con CONCURRENTLY: Crea el índice sin bloquear las escrituras. La tabla sigue disponible para operaciones normales.

Contras: Es más lento y consume más recursos porque hace dos escaneos de la tabla.

Riesgo: Puede quedar en estado "INVALID" si falla a medio construir.

2. UNIQUE (La regla del índice)
Se refiere a la restricción de datos que impone el índice.

Sin UNIQUE: Permite valores duplicados en la columna indexada.

Con UNIQUE: Garantiza que no haya dos filas con el mismo valor en la columna (o combinación de columnas).

En resumen:

Usas UNIQUE para evitar duplicados.
Usas CONCURRENTLY para evitar caídas del servicio mientras creas el índice.
---
