La pantalla de **Cursos** ahora tiene un combo **Instrumento** para clasificar los cursos. El paquete es `iffaapp_cursos_instrumento.tar.gz`, con solo 2 archivos: `app/resources.py` y `tests/smoke_test.py`. Pasan las 249 pruebas contra PostgreSQL; no abrí la pantalla en un navegador real.

- **Filtro:** el combo «Instrumento: todos» lista todos los instrumentos y se combina con el filtro de gestión que ya existía. Con la gestión activa por defecto, el filtro por Piano muestra los cursos de Piano de esa gestión, y con «Todas las gestiones» también los de gestiones anteriores.
- **Columna nueva:** la tabla muestra ahora una columna «Instrumento», para ver la clasificación de un vistazo.
- **Búsqueda:** la caja de búsqueda también encuentra por nombre de instrumento. Escribir «piano» trae los cursos de Piano.
- **Valores inválidos:** un valor manipulado del filtro en la URL se ignora y la pantalla no falla.

No hay cambios de base de datos ni dependencias nuevas. Reemplaza los archivos y reinicia el servicio: `sudo systemctl restart ifalfa`.
