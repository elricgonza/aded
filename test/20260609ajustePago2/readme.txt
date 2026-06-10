La diferencia clave es:

Antes: si tiene algún pago pagado → omitir todo.
Ahora: los pagos pagados no se tocan, pero igual se completan las cuotas faltantes para ese alumno.
Edited 2 files, ran a commandEdited 2 files, ran a commandAhora ajusto el bloque de cuotas existentes para excluir del cálculo de faltantes solo los nro_cuota que ya están pagados, y agregar únicamente los realmente ausentes:Update cuotas_existentes to use all existing nro_cuota (paid or not) so missing ones are correctly identifiedUpdate cuotas_existentes to use all existing nro_cuota (paid or not) so missing ones are correctly identifiedAhora actualizo el log_accion y el render_template del POST para eliminar omitidos_pago:Update log_accion and render_template to remove omitidos_pagoUpdate log_accion and render_template to remove omitidos_pagoAhora actualizo el template para eliminar el contador "Con pago registrado" y reflejar la nueva lógica:Ran 3 commandsRan 3 commandsQueda el bloque del GET — el contador con_pago_pagado ya no se usa en el template. Lo limpio:Ran 2 commands, edited a file, read a fileRan 2 commands, edited a file, read a file2 archivos modificados:
ArchivoDestinoall_routes.pyapp/routes/all_routes.pyactualiza_plan.htmlapp/templates/pago/actualiza_plan.html

Cambio de lógica aplicado — la nueva regla por alumno es:

Se obtienen todos los nro_cuota ya existentes en pago (pagados o no) → ninguno se toca.
Se calcula la diferencia contra los nro_cuota definidos en costo para su curso.
Si hay cuotas faltantes → se crean solo esas, con estado pagado=False y descuento aplicado si corresponde.
En el mensaje de detalle se informa cuántas cuotas pagadas tenía el alumno y cuántas se añadieron, por ejemplo: "2 cuota(s) añadida(s) (1 cuota(s) pagada(s) conservada(s) sin cambios)".
El resumen de resultados ahora tiene 3 contadores: Actualizados / Ya completos / Sin costos definidos (se eliminó el de "Con pago registrado" que ya no aplica).
