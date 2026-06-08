SELECT setval(pg_get_serial_sequence('nota', 'id'), COALESCE((SELECT MAX(id) FROM nota), 0) + 1, false);
