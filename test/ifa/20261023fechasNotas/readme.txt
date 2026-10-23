Casi todo pasa; el único fallo es del test: pedí el listado como parcial HTMX (solo la tabla), que no incluye la franja de estado. Lo corrijo para pedir la página completa.

El fallo es del test: mi helper enviaba solo un campo, así que los demás (ya habilitados) se borraban al quedar vacíos. Hago que reenvíe los valores actuales.

Las 69 pruebas pasan. Verifico el comportamiento con el archivo dañado/ausente y el formato final del JSON, y actualizo el README.

La opción «Fechas Transcripción Notas» está lista en `iffaapp_fechas_notas.tar.gz`, solo para el rol Administrador. La probé contra PostgreSQL con 69 pruebas, todas correctas.

**Archivos del paquete:** la copia que subiste no tenía aplicada la corrección de Inscripciones del paso anterior, y esta función modifica los mismos archivos. Por eso el paquete incluye también esos cambios (`crud.py`, `resources.py`, `base.html`, `list.html`, `_form.html` y `_search_results.html`). Si ya los habías aplicado, no pasa nada: estos archivos los incluyen.

**Dónde está y qué guarda**
- La pantalla está en **Administración → Fechas Transcripción Notas**. Para cualquier otro usuario devuelve 403 y no aparece en el menú.
- Guarda en `config_notas.json`, en la raíz del proyecto, las 15 claves que pediste. Para cada período (`nota1`, `nota2`, `nota3`, `nota4` y `2t`):
  - `habilitar_X` guarda true o false.
  - `transcripcion_X_inicio` y `transcripcion_X_final` guardan una fecha `AAAA-MM-DD`, o null.
- El archivo se crea solo la primera vez, con todo restringido. Ese usuario del servicio (`www-data`) debe poder escribir en la carpeta del proyecto. La ruta se puede cambiar con `CONFIG_NOTAS_PATH` en el `.env`.
- Al guardar se valida: si un período está habilitado, necesita fecha de inicio y final, y el inicio no puede ser posterior al final. Si hay errores no se guarda nada. Cada cambio queda en la auditoría.

**Cómo se aplica en Calificaciones**
- Con `habilitar_X = true` solo se puede transcribir entre las dos fechas, ambas incluidas. Con `false` queda restringido.
- Fuera de plazo, el campo aparece deshabilitado con el motivo, por ejemplo «Plazo vencido el 31/03/2026». El servidor además conserva el valor actual aunque alguien manipule el formulario.
- El listado de notas muestra el estado de los cinco períodos y, al administrador, un enlace a la configuración.

**Decisiones mías, para que las revises**
- El rol **Administrador no está sujeto** a las restricciones y puede corregir notas en cualquier momento. Profesores y transcriptores sí lo están.
- Si el archivo se daña o sus valores no son válidos, se restringe todo y se registra el error.
- En el archivo, el valor de `habilitar_X` debe ser un booleano real (`true`), no el texto `"true"`.

Con los cambios del paso anterior, reemplaza los archivos del paquete y reinicia el servicio: `sudo systemctl restart ifalfa`.
