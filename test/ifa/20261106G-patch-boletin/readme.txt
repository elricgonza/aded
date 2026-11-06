El fallo venía de registrar en `audit_log` la acción `REPORT`, que **no está permitida** por el constraint de la base de datos. Solo se admiten: `CREATE`, `UPDATE`, `DELETE`, `LOGIN`, `LOGOUT`, `BULK`, `ERROR`.

**Corrección:** se eliminó el registro de auditoría al generar el boletín (es una operación de solo lectura). Con eso el reporte se genera sin el `IntegrityError`.

Vuelve a desplegar el parche actualizado (incluye el `views.py` corregido):




```bash
tar -xzf boletin_calificaciones_patch.tar.gz -C /ruta/a/iffaapp
```

Reinicia la aplicación e intenta de nuevo generar el boletín.
