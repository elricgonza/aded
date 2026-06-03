SELECT setval(pg_get_serial_sequence('tu_tabla', 'id'), COALESCE((SELECT MAX(id) FROM tu_tabla), 0) + 1, false);
