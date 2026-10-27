Las reglas de **1ro. y 2do. Técnico Medio** están en `iffaapp_tecnico_medio.tar.gz`. Las probé con 86 pruebas contra PostgreSQL y pasan todas, incluidos los escenarios de arrastres y requisitos.

El archivo que subiste vuelve a no traer los parches de Inscripciones ni de Fechas de transcripción. Por eso el paquete incluye todos los archivos que difieren de tu copia (15 en total), no solo los de esta función. Si ya los tenías aplicados, no hay conflicto.

**Cómo se comporta (grados del mismo instrumento; «aprobada» = nota aprobada en cualquier inscripción previa del alumno)**

| Al inscribir en… | Se asigna automáticamente | Se puede agregar a mano |
|---|---|---|
| **1ro. Técnico Medio** | Las materias de 1ro que aún no aprobó | Materias de 2do, si hay un curso de 2do habilitado en la gestión vigente y sus requisitos están aprobados |
| **2do., con todo 1ro aprobado** | Todas las de 2do que aún no aprobó | Materias de 2do con requisitos aprobados |
| **2do., con 1ro incompleto** | Nada | Los arrastres de 1ro no aprobados y las de 2do cuyos requisitos estén aprobados |

- **Asignaciones:** el selector de materia solo muestra las permitidas para el inscrito elegido, y los arrastres aparecen marcados. El servidor valida lo mismo, con el motivo concreto: requisito sin aprobar, materia ya aprobada, o curso de ese grado no habilitado.
- **Curso de la materia:** una materia de otro grado se cursa en un curso de ese grado de la gestión vigente (se prefiere el mismo paralelo). Así el profesor de esa materia ve a esos alumnos en sus calificaciones.
- **Solo Administrador:** inscribir, editar y asignar materias en cursos de 1ro. y 2do. Técnico Medio. Otro rol recibe «solo puede gestionarlas el Administrador». Los demás grados siguen funcionando como antes.

**Decisiones mías, para que las revises**
- Interpreté «habilitado sólo para Administrador» como que estas operaciones son exclusivas del Administrador, y no como que toda la opción Inscripciones lo sea. Si querías lo segundo, es un ajuste pequeño.
- Los grados se reconocen por nombre; tolero diferencias de tildes, mayúsculas y puntos (por ejemplo «1ro Tecnico Medio»).
- La asignación automática ocurre solo la primera vez que se inscribe. Editar la inscripción después no vuelve a agregar materias, para no resucitar las que se eliminaron.
- Si el alumno de 2do tiene 1ro incompleto, no asigno los arrastres automáticamente: lo dejé manual porque tu texto dice «debe permitir asignar». Si prefieres que se asignen solos, también es sencillo.

Con los parches anteriores, reemplaza los archivos y reinicia el servicio: `sudo systemctl restart ifalfa`.
