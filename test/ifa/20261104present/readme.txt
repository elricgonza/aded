Vista previa revisada: el menú con logo, la barra superior, las tablas y los formularios quedan coherentes y alineados. Repito la suite completa con los últimos ajustes y preparo el paquete.

El rediseño de la aplicación con el logo y los colores institucionales está listo en `iffaapp_presentacion.tar.gz`, con los 28 archivos nuevos o modificados. Pasan las 164 pruebas, incluida una que comprueba que el HTML de las pantallas está bien formado. No pude abrir un navegador real, así que revisé el aspecto con una vista previa aproximada (Tailwind compilado y renderizado con WeasyPrint): el menú, las tablas, el login y el formulario se ven coherentes, pero las animaciones y los menús desplegables no los pude verificar.

**Logo**
- Está aplicado en el menú lateral (versión blanca sobre el azul), en el login, en el panel de inicio como marca de agua, en las páginas de error y como favicon.
- El logo es transparente. Generé versiones recortadas en `app/static/img/` y dejé el original intacto como `logo.png`.
- La identidad institucional se define en un solo lugar, `app/branding.py`. Al ver tu imagen de colores corregí el texto de la marca: «Instituto de Formación Artística · Luis Felipe Arce».

**Colores y presentación**
- La paleta sigue los colores de tu imagen: azul marino `#193B68` y cian `#0390C6`.
- **Menú lateral:** con íconos por sección y la opción activa resaltada. El texto largo de «Asignaciones (profesor · materia · alumno · curso)» ahora se muestra como «Asignaciones».
- **Barra superior:** gestión activa a la izquierda y menú de usuario con «Mi perfil» y «Cerrar sesión».
- **Páginas y tablas:** tipografía Inter, encabezado con ícono, buscador y filtros en una tarjeta, tablas con filas alternadas, etiquetas Sí/No y paginación uniforme.
- **Formularios:** encabezado y pie fijos, con campos alineados.
- **Calificaciones:** una nota sin calificar ahora muestra «—» en «Aprobado», en vez de «No» (que parecía reprobado).
- **Pantallas con estilo nuevo:** panel de inicio, login, perfil, cambiar contraseña y fechas de transcripción.

**Reportes futuros**
- Cualquier pantalla se imprime ya con un encabezado institucional con logo, nombre y gestión (Ctrl+P), y sin el menú ni los botones.
- Para reportes nuevos dejé `reportes/_base.html` y `reportes/_encabezado.html`, con el logo incrustado, listos para HTML o PDF. Para PDF o Excel generados por código, `branding.logo_path()` da la ruta del logo.

**Cambiar contraseña:** vi que habías comentado ese enlace del menú lateral. Respeté tu decisión y no lo volví a agregar: sigue accesible desde el menú de usuario, en «Mi perfil», que tiene el botón. Si prefieres otro lugar, es un ajuste pequeño.

Reemplaza los archivos y reinicia el servicio: `sudo systemctl restart ifalfa`.
