La subida ahora sí incluye los parches anteriores. Comparo con mi última versión para ver exactamente qué tiene.

Los ajustes de gestión activa están listos en `iffaapp_gestion_activa.tar.gz`. Pasan las 114 pruebas contra PostgreSQL. Esta vez tu copia ya traía mis parches anteriores, así que el paquete contiene solo los 9 archivos que cambian.

**Gestiones académicas**
- Solo una gestión puede estar «Activa». Al crear o editar otra como activa, el formulario responde «Ya existe una gestión activa (…). Desactive primero la otra.».
- El cambio de gestión es en dos pasos: primero desactivas la vigente y luego activas la nueva.
- La base de datos también lo impide con un índice único (en `schema.sql`). En bases ya creadas hay que ejecutar una vez `psql -h localhost -U uaded -d dbaded -f scripts/migracion_gestion_activa_unica.sql`. Si hoy hubiera más de una activa, el script se detiene y te las lista.

**Gestión activa siempre visible**
- Aparece en el menú lateral, justo encima del usuario conectado: «Gestión activa · 2026 · Plan…». En móvil aparece como una etiqueta en la barra superior.
- Si no hay ninguna activa, muestra «Sin gestión activa» en ámbar. Si por datos antiguos hubiera varias, lo advierte.
- Se ve en todas las pantallas y para todos los usuarios.

**Listados con la gestión activa por defecto**
- **Cursos, Asignaciones y Calificaciones:** muestran por defecto la gestión activa. El combo *Gestión* permite elegir otra o «Todas las gestiones».
- **Inscripciones:** ya lo tenía y quedó con el mismo combo.
- **Edición de registros antiguos:** sigue funcionando, por ejemplo una calificación de una gestión anterior.
- **Resumen del inicio:** los totales de Asignaciones y Calificaciones ahora cuentan solo la gestión activa.

**Solo Administrador**
- Crear, editar y eliminar gestiones es exclusivo del Administrador, aunque otro rol tuviera el permiso asignado. Los demás roles no ven el botón «+ Nuevo» ni «Editar».
- Interpreté la frase de esa manera. Los combos de gestión y el indicador de gestión activa los ven todos los usuarios; si querías que fueran solo para el Administrador, es un cambio pequeño.
- Cambié el valor inicial de «Activa» en el formulario de nueva gestión a desmarcado, para que no choque con la validación.

Además, las pruebas detectaron un fallo mío: la página de error (por ejemplo el rechazo por CSRF en el login) se mostraba a usuarios sin sesión y el indicador de gestión activa fallaba allí. Ya está corregido y el indicador solo aparece con sesión iniciada.

Reemplaza los archivos y reinicia el servicio: `sudo systemctl restart ifalfa`.
