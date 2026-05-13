import psycopg2
import random

# Configuración de conexión
conn = psycopg2.connect(
    host="localhost",
    database="dbaded",
    user="uaded",
    password="paded"
)

cursor = conn.cursor()

# supr
cursor.execute("DELETE FROM costo")
cursor.execute("TRUNCATE TABLE costo")
print("✓ Tabla 'cos' limpiada exitosamente")    

# lee cursos
cursor.execute("SELECT id FROM curso order by id")
cursos = cursor.fetchall()
print(f"✓ Se encontraron {len(cursos)} cursos disponibles") 

print(cursos)
# iterar sobre cursos y generar registros
while cursos:
    curso_id = cursos.pop(0)[0]
    print(f"\nGenerando registros para curso ID: {curso_id} ")

    for i in range(1, 10):
        cuota = 100 if i < 3 else 120  # Para los primeros 2 registros, cuota fija de 100

        cursor.execute("""
            INSERT INTO costo (id, cur_id, nro_cuota, cuota, obs, creado, act, usu_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (curso_id, i, cuota, 's/o', now(), now(), 1))
        
        print(f"Insertado registro {curso_id }: {i} - ${cuota}")

# Confirmar cambios
conn.commit()
print(f"\n✓ Se insertaron registros exitosamente")

# Verificar
cursor.execute("SELECT COUNT(*) FROM costo")
total = cursor.fetchone()[0]
print(f"Total registros en tabla: {total}")

# Cerrar conexión
cursor.close()
conn.close()
