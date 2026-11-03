El entorno de pruebas se reinició (se perdieron PostgreSQL y el venv), así que lo reconstruyo antes de implementar el cambio de contraseña, que sí necesito probar contra la base.

Entorno restaurado y la base pasa las 125 pruebas. Ahora implemento el cambio de contraseña complementado: política común, página propia, menú para todos, límite de intentos y auditoría.

Ya está disponible la opción **Cambiar contraseña** para todos los usuarios, en `iffaapp_cambiar_password.tar.gz`, con solo los 8 archivos que cambian. Pasan las 139 pruebas contra PostgreSQL; no probé la página en un navegador, solo las respuestas del servidor.

**Disponible para todos**
- Cualquier usuario con sesión iniciada la ve en el menú lateral, junto a «Cerrar sesión», y también desde *Mi perfil*.
- No pide ningún permiso: la probé con Administrador, Profesor, Estudiante, Transcriptor, Consulta y un usuario sin roles.
- Sin sesión iniciada, la página redirige al login.

**Qué se complementó**
- **Página propia:** reemplaza el formulario que estaba dentro de *Mi perfil*, que ahora muestra usuario, correo y roles, con un botón hacia el cambio de contraseña.
- **Reglas de la nueva contraseña:** entre 8 y 128 caracteres, con letras y números, sin contener el nombre de usuario y distinta de la actual. Hay campo de confirmación, y se pide siempre la contraseña actual.
- **Ayudas en pantalla:** lista de requisitos que se marca en vivo, aviso de si las contraseñas coinciden y opción de mostrar u ocultar.
- **Protección:** tras 5 intentos fallidos con la contraseña actual, ese usuario queda bloqueado 5 minutos.
- **Auditoría:** cada cambio y cada intento fallido quedan registrados. Al cambiarla, la clave anterior deja de servir.
- **Política común:** la misma política se aplica cuando el Administrador crea o cambia contraseñas en **Usuarios**. Una clave como `abcdefgh`, sin números, ahora se rechaza ahí también.

**Un límite que conviene conocer:** al cambiar la contraseña, la sesión actual sigue abierta y las sesiones de ese mismo usuario en otros navegadores no se cierran. Para cerrarlas haría falta un campo nuevo en la base de datos. Si lo quieres, lo agrego.

Mientras probaba, el entorno de trabajo se reinició y tuve que reconstruirlo. Verifiqué que tu versión base pasaba las 125 pruebas anteriores antes de empezar.

Reemplaza los archivos y reinicia el servicio: `sudo systemctl restart ifalfa`.
