Ya está el botón **Boletín de Calificaciones** en la pantalla de Calificaciones, con el reporte basado en tu imagen. El paquete es `iffaapp_boletin.tar.gz`, con 16 archivos nuevos o modificados. Pasan las 186 pruebas contra PostgreSQL y revisé el PDF generado como imagen.

**Quién lo ve y qué ve**
- El botón aparece para Administrador, Transcriptor y Estudiante, y está oculto para Profesor y Consulta.
- Administrador y Transcriptor eligen la gestión y buscan al alumno por nombre, apellido o C.I., y pueden sacar el boletín de cualquier alumno y gestión.
- El Estudiante elige entre sus propias inscripciones y solo puede ver su boletín; el de otro alumno da 404.
- Cada boletín generado queda registrado en la auditoría.

**El reporte**
- Mantiene la estructura de tu imagen: encabezado con logo, «Boletín de Calificaciones · Gestión», «Datos del estudiante» y la tabla N°, Código, Asignatura, P1–P4, Total, 2T y Literal.
- Los datos salen de la base de datos. El Total es el promedio redondeado.
- Se puede ver en pantalla, imprimir o descargar en PDF.

**Mejoras que agregué sin alterar la esencia**
- Encabezado con las resoluciones ministeriales, La Paz y el lema «Trabajando por la formación musical desde 1975».
- Notas bajo la mínima (51) en rojo, y APROBADO, REPROBADO y PENDIENTE con color. Las notas sin registrar muestran «—» en vez de 0.
- Resumen con materias aprobadas, reprobadas y pendientes, promedio general y situación del estudiante.
- Las materias de arrastre se identifican con su curso.
- Fecha de emisión, líneas de firma (Dirección Académica y Secretaría) y numeración de páginas.

**Para desplegarlo**
1. Reemplaza los archivos, ejecuta `pip install -r requirements.txt` y luego `flask seed`. El seed crea el permiso `nota_boletin` y lo da a Administrador, Transcriptor y Estudiante sin tocar los permisos que ya personalizaste.
2. Para el PDF instala `sudo apt install libpango-1.0-0 libpangoft2-1.0-0`. Sin eso el botón de PDF se oculta, queda «Imprimir» y todo lo demás sigue funcionando.
3. Reinicia: `sudo systemctl restart ifalfa`.

**Datos que no existen en la base de datos**
«Régimen» (ANUALIZADO) y «Carrera» (MÚSICA ACADÉMICA) los tomé como valores fijos configurables en `.env` con `BOLETIN_REGIMEN` y `BOLETIN_CARRERA`. Si quieres que varíen por alumno o grado, habría que agregar esos campos.

Un detalle de la imagen: allí las materias reprobadas muestran 0 en todos los períodos. El boletín muestra las notas realmente registradas.
