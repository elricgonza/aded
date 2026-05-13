-- Reiniciar secuencias para todas las tablas que necesites
SELECT setval(pg_get_serial_sequence('profesor', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM profesor;
SELECT setval(pg_get_serial_sequence('alumno', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM alumno;
SELECT setval(pg_get_serial_sequence('curso', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM curso;
SELECT setval(pg_get_serial_sequence('materia', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM materia;
SELECT setval(pg_get_serial_sequence('grado', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM grado;
-- ... añade otras tablas según necesites
