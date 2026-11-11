Agregué **Reportes → Alumnos asignados a Profesor** para Administrador, Profesor y Transcriptor. El paquete es `iffaapp_alumnos_profesor.tar.gz`, con 6 archivos nuevos o modificados. Pasan las 240 pruebas contra PostgreSQL; revisé el PDF y el Excel como imagen, pero no probé las pantallas en un navegador real.

**Uso**
- Se elige la gestión (por defecto la activa) y el profesor.
- Administrador y Transcriptor eligen entre los profesores que tienen asignaciones en esa gestión.
- Un Profesor no elige: siempre obtiene su propio reporte, aunque pida otro.
- Un profesor sin vínculo a su ficha no ve nada.

**El reporte**
- **Título y totales:** el nombre del profesor va como título, con la gestión y totales de alumnos, asignaciones, cursos y materias. Usa el mismo encabezado institucional con logo que los reportes anteriores.
- **Agrupado por curso:** cada curso es una sección con su cantidad de alumnos y asignaciones. Los alumnos van ordenados por apellido paterno, apellido materno y nombre (y luego materia), en orden alfabético en español: sin distinguir tildes y con la ñ después de la n.
- **Columnas:** N°, apellidos y nombres, C.I., materia asignada y curso de inscripción con paralelo.
- **Arrastres:** una materia de otro curso se marca como «arrastre».
- **Exportar:** a PDF A4, a Excel o imprimir desde la pantalla. El Excel trae una hoja con el reporte agrupado y otra, «Datos», plana y con filtros.

**Decisiones mías, para que las revises**
- El agrupador es el **curso donde el profesor dicta la materia**, y la columna «Curso de inscripción» muestra el curso propio del alumno. Normalmente coinciden; difieren en los arrastres.
- Un alumno con dos materias del mismo profesor aparece una vez por materia.
- No se incluyen alumnos que abandonaron.

**Para desplegarlo**
1. Reemplaza los archivos y ejecuta `flask seed`. El seed crea el permiso `reporte_alumnos_profesor` y lo da a Administrador, Profesor y Transcriptor sin tocar los permisos que ya personalizaste.
2. Reinicia: `sudo systemctl restart ifalfa`.
3. No hay dependencias nuevas; el PDF sigue usando WeasyPrint.
