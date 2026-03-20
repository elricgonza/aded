# verificar_estructura.py
"""
Script para verificar la estructura de las tablas antes de poblar SEG
"""

import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', 5432),
    'database': os.getenv('DB_NAME', 'dbaded1'),
    'user': os.getenv('DB_USER', 'uaded'),
    'password': os.getenv('DB_PASSWORD', 'paded')
}

def verificar_estructura():
    """Verifica que todas las tablas necesarias existan y tengan datos"""
    
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    tablas = {
        'ALUM': 'Alumnos',
        'CUR': 'Cursos',
        'INSC': 'Inscripciones',
        'MAT': 'Materias',
        'ASIG': 'Asignaciones',
        'PROF': 'Profesores',
        'SEG': 'Seguimiento'
    }
    
    print("=" * 60)
    print("VERIFICACIÓN DE ESTRUCTURA")
    print("=" * 60)
    
    for tabla, descripcion in tablas.items():
        cursor.execute(f"SELECT COUNT(*) FROM {tabla};")
        count = cursor.fetchone()[0]
        print(f"{descripcion:20} ({tabla:6}): {count:6} registros")
    
    print("\n" + "=" * 60)
    print("VERIFICACIÓN DE RELACIONES")
    print("=" * 60)
    
    # Verificar inscripciones con cursos
    cursor.execute("""
        SELECT COUNT(*)
        FROM INSC i
        LEFT JOIN CUR c ON i.cur_id = c.id
        WHERE c.id IS NULL;
    """)
    huerfanos = cursor.fetchone()[0]
    print(f"Inscripciones sin curso: {huerfanos}")
    
    # Verificar asignaciones
    cursor.execute("""
        SELECT 
            c.id,
            c.paralelo,
            c.gestion,
            COUNT(a.id) as materias_asignadas
        FROM CUR c
        LEFT JOIN ASIG a ON c.id = a.cur_id
        GROUP BY c.id, c.paralelo, c.gestion
        HAVING COUNT(a.id) = 0;
    """)
    
    cursos_sin_materias = cursor.fetchall()
    if cursos_sin_materias:
        print(f"\n⚠ {len(cursos_sin_materias)} cursos sin materias asignadas:")
        for curso in cursos_sin_materias[:5]:
            print(f"  - Curso {curso[0]}: {curso[1]}/{curso[2]}")
    
    # Mostrar ejemplo de datos a procesar
    cursor.execute("""
        SELECT 
            al.nombre || ' ' || al.apellido as alumno,
            c.paralelo,
            c.gestion,
            COUNT(a.mat_id) as materias
        FROM INSC i
        INNER JOIN ALUM al ON i.alum_id = al.id
        INNER JOIN CUR c ON i.cur_id = c.id
        INNER JOIN ASIG a ON c.id = a.cur_id
        GROUP BY i.id, al.nombre, al.apellido, c.paralelo, c.gestion
        LIMIT 5;
    """)
    
    print("\n" + "=" * 60)
    print("EJEMPLO DE DATOS A PROCESAR")
    print("=" * 60)
    print(f"{'Alumno':<25} {'Curso':<15} {'Materias':<10}")
    print("-" * 60)
    
    for row in cursor.fetchall():
        alumno, paralelo, gestion, materias = row
        curso = f"{paralelo}/{gestion}"
        print(f"{alumno:<25} {curso:<15} {materias:<10}")
    
    cursor.close()
    conn.close()


if __name__ == "__main__":
    verificar_estructura()
