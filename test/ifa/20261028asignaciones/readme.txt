Mismo patrón: la subida trae la base sin parches, así que trabajo sobre mi versión acumulada. Primero la lógica de cursos candidatos en `services.py`.

Los ajustes a «+ Nuevo» de Asignaciones están en `iffaapp_asignaciones.tar.gz`. Pasan las 99 pruebas contra PostgreSQL. No pude abrir un navegador aquí, así que verifiqué las respuestas HTTP y el HTML que se genera, no la interacción real del formulario.

Tu copia volvió a llegar sin los parches anteriores, así que el paquete trae todos los archivos que difieren de ella (16), no solo los de esta función. Si ya los tenías aplicados, no hay conflicto.

**Lo que cambia en «+ Nuevo»**
- **Combo «Inscrito»:** lista solo a los inscritos de la gestión activa que están confirmados y no abandonaron, en orden alfabético. El servidor rechaza un inscrito de otra gestión aunque se manipule el formulario.
- **Nuevo campo «Curso»**, entre el inscrito y la materia. El orden es **Inscrito → Curso → Materia**.
  - **Un solo curso posible:** si solo hay uno, se preselecciona y las materias se cargan solas. Es el caso «asigna directamente».
  - **Varios cursos del grado menor:** en Técnico Medio, si un alumno de 2do tiene un arrastre y existen «PRIMERO TECNICO MEDIO A», «B», etc., debes elegir el curso. Si no lo haces, el servidor responde «Existen varios cursos de ese grado: seleccione el curso».
  - **Qué cursos aparecen:** el propio (si aún tiene materias asignables) y los de otros grados con materias pendientes, siempre en la gestión vigente.
  - **Otros grados:** el curso es solo el de la inscripción, sin elección.
- **Combo «Materia»:** muestra solo las pendientes o permitidas del curso elegido. Los arrastres aparecen marcados y quedan excluidas las ya aprobadas y las de 2do con requisitos sin aprobar. El arrastre se guarda en el curso que elegiste.
- **Solo Administrador:** la gestión de asignaciones de 1ro. y 2do. Técnico Medio sigue exclusiva del Administrador, igual que en el paso anterior.

Un detalle de diseño: al cambiar el inscrito, el servidor devuelve la lista de cursos y reinicia la de materias en la misma respuesta (`hx-swap-oob`), sin lógica de JavaScript extra.

Con los parches anteriores, reemplaza los archivos y reinicia el servicio: `sudo systemctl restart ifalfa`.
