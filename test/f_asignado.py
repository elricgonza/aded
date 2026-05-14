import psycopg2
import random
from datetime import datetime

def get_conexion():
    return psycopg2.connect(
        host="localhost",
        database="dbaded",
        user="uaded",
        password="paded"
    )


def get_materias(gra_id):
    conn = get_conexion()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM materia WHERE gra_id = %s ORDER BY id", (gra_id,))
    materias = cursor.fetchall()
    cursor.close()
    conn.close()
    return materias


def get_cursos():
    conn = get_conexion()
    cursor = conn.cursor()
    cursor.execute("SELECT id, gra_id  FROM curso ORDER BY id ")
    cursos = cursor.fetchall()
    cursor.close()
    conn.close()
    return cursos

def inicia_asignado():
    conn = get_conexion()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM asignado ")
    cursor.execute("TRUNCATE TABLE asignado ")
    print("✓ Tabla 'asignado' limpiada exitosamente")
    cursor.close()
    conn.close()


#print(get_materias(13))
#print(get_cursos())

cxasig= get_conexion()
cursor = cxasig.cursor()

# iterar sobre cursos/materias y generar registros
cursos = get_cursos()
for curso in cursos:
    curso_id = curso[0]
    grado_id = curso[1]
    print(f"\nGenerando registros para curso ID: {curso_id} y {grado_id}...")

    materias = get_materias(grado_id)
    for materia  in materias:
        profe = random.randint(1,31)

        cursor.execute("""
            INSERT INTO asignado (cur_id, mat_id, pro_id, creado, act, usu_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (curso_id, materia, profe, datetime.now(), datetime.now(), 1))

        print(f"Insertado registro {curso_id }: {materia} - {profe}")

# Confirmar cambios
cxasig.commit()
print(f"\n✓ Se insertaron registros exitosamente")

# Verificar
cursor.execute("SELECT COUNT(*) FROM asignado")
total = cursor.fetchone()[0]
print(f"Total registros en tabla: {total}")

# Cerrar conexión
cursor.close()
cxasig.close()
