Agregué **Procesos → Reportes → Centralizador de Calificaciones**, disponible para Administrador, Transcriptor y Estudiante. El paquete es `iffaapp_centralizador.tar.gz`, con 13 archivos nuevos o modificados. Pasan las 213 pruebas contra PostgreSQL, y abrí el Excel generado en LibreOffice y revisé el PDF como imagen. No probé las pantallas en un navegador real.

**Cómo se usa**
- Eliges gestión y curso, y opcionalmente *Libro N°* y *Folio N°*, y obtienes el reporte en **Excel**, **PDF** apaisado o en pantalla.
- El Excel replica tu formato: hoja **ANVERSO** con el logo del Ministerio, los datos del curso, la nómina y las asignaturas en vertical; y hoja **REVERSO** con las firmas de docentes por asignatura y las estadísticas.
- Los datos salen de la base de datos:
  - **Nómina:** en orden alfabético, con nombre y C.I.
  - **Nota por asignatura:** la calificación final. El segundo turno solo la reemplaza cuando el promedio no alcanza para aprobar.
  - **Estado:** APROBADO, REPROBADO, ABANDONO o EN PROCESO.
  - **Observaciones:** abandono, la observación de la inscripción y las materias de arrastre.
  - **Estadísticas:** conteos y porcentajes; los porcentajes son fórmulas de Excel, como en tu original.

**Mejoras sin alterar la esencia**
- Las notas bajo la mínima salen en rojo y el estado va con color.
- Agregué una fila de promedio por asignatura.
- El logo del instituto aparece junto al del Ministerio.
- La hoja queda lista para imprimir en oficio apaisado.
- Un nombre que empiece con «=» se guarda como texto, para que nunca se ejecute como fórmula en Excel.

**Decisiones mías, para que las revises**
- **El estudiante solo ve su propia fila** (con las estadísticas de todo el curso) y solo los cursos en los que está inscrito, porque la nómina completa muestra C.I. y notas de sus compañeros. Si prefieres que vea todos, pon `CENTRALIZADOR_ESTUDIANTE_VE_TODOS=1` en el `.env`.
- Los **datos que no existen en la base** son configurables en el `.env`: `CENTRALIZADOR_CODIGO_REGISTRO` (80730917), `CENTRALIZADOR_TURNO` (TARDE), `CENTRALIZADOR_CARACTER` (FISCAL), `CENTRALIZADOR_REGIMEN` (ANUAL) y `BOLETIN_CARRERA`. Las R.M. del encabezado están en `app/branding.py`. Libro y Folio los escribes al generar.
- La nómina lista a los **inscritos del curso**. Si un alumno lleva una materia de arrastre de otro grado, no tiene columna propia: se anota en Observaciones.

**Para desplegarlo**
1. Reemplaza los archivos, ejecuta `pip install -r requirements.txt` (ahora incluye `openpyxl`) y luego `flask seed`.
2. El seed crea el permiso `reporte_centralizador` y lo da a Administrador, Transcriptor y Estudiante sin tocar los permisos que ya personalizaste.
3. Reinicia: `sudo systemctl restart ifalfa`.
4. El PDF sigue necesitando WeasyPrint y las librerías `libpango` del paso anterior. Sin ellas se oculta ese botón y quedan Excel y pantalla.
