Se implementó el **Boletín de Calificaciones** según el formato de la imagen adjunta y las reglas de acceso solicitadas.

### Cambios realizados

1. **Botón en la pantalla de Calificaciones**  
   Visible para **Administrador**, **Transcriptor** y **Estudiante** (con permiso `nota_ver`).

2. **Generación del reporte**  
   - Datos tomados de la base (`alumno`, `inscrito`, `curso`, `gestion`, `grado`, `instrumento`, `asignado`, `materia`, `nota`).  
   - Estructura alineada al formato del PDF/imagen: encabezado institucional, datos del estudiante y tabla de notas (P1–P4, Total, 2T, Literal).  
   - Mejoras de usabilidad sin cambiar la esencia: colores para APROBADO/REPROBADO, botón de impresión/PDF, tipografía y bordes limpios, logo institucional.

3. **Flujo por rol**  
   - **Estudiante**: genera directamente su boletín de la gestión activa (si existe inscripción).  
   - **Administrador / Transcriptor**: formulario para elegir gestión y estudiante (búsqueda por nombre o C.I.).

### Archivos a adicionar / modificar

Solo estos (empaquetados en el `.tar.gz`):

| Archivo | Acción |
|---------|--------|
| `app/resources.py` | Modificado (toolbar en recurso `nota`) |
| `app/views.py` | Modificado (rutas `/reportes/boletin` y búsqueda de alumnos) |
| `app/templates/crud/list.html` | Modificado (mostrar toolbar de notas también con permiso de ver) |
| `app/templates/crud/_toolbar_nota.html` | **Nuevo** (botón) |
| `app/templates/reportes/boletin_form.html` | **Nuevo** (selección estudiante/gestión) |
| `app/templates/reportes/boletin_calificaciones.html` | **Nuevo** (plantilla del boletín imprimible) |

### Cómo aplicar

Extraiga el parche sobre la raíz del proyecto (donde está la carpeta `app/`):

```bash
tar -xzf boletin_calificaciones_patch.tar.gz -C /ruta/a/iffaapp
```

Reinicie la aplicación. El botón **Boletín de Calificaciones** aparecerá en el listado de Calificaciones para los roles indicados.

**Archivo entregable:**
