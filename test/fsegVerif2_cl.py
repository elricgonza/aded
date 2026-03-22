# verificar_estructura.py
"""
Script para verificar la estructura antes de poblar SEG
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
    """Verifica la estructura y datos antes de poblar"""
    
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    print("=" * 70)
    print("VERIFICACIÓN DE ESTRUCTURA Y DATOS")
    print("=" * 70)
    
    # Verificar tablas
    tablas = ['ALUM', 'CUR', 'INSC', 'MAT', 'ASIG', 'PROF', 'SEG']
    
    print("\n📋 Registros por tabla:")
    print("-" * 70)
    for tabla in tablas:
        cursor.execute(f"SELECT COUNT(*) FROM {tabla};")
        count = cursor.fetchone()[0]
        print(f"{tabla:10}: {count:8} registros")
    
    # Calcular cuántos registros SEG se deben crear
    cursor.execute("""
        SELECT COUNT(*)
        FROM INSC i
        INNER JOIN CUR c ON i.cur_id = c.id
        INNER JOIN ASIG a ON c.id = a.cur_id;
    """)
    registros_esperados = cursor.fetchone()[0]
    
    print(f"\n📊 Registros SEG a crear: {registros_esperados}")
    
    # Ejemplo de datos
    cursor.execute("""
        SELECT 
            al.nombre || ' ' || al.apellido as alumno,
            c.paralelo || '/' || c.gestion as curso,
            m.materia,
            COUNT(*) OVER (PARTITION BY i.id) as total_materias
        FROM INSC i
        INNER JOIN ALUM al ON i.alum_id = al.id
        INNER JOIN CUR c ON i.cur_id = c.id
        INNER JOIN ASIG a ON c.id = a.cur_id
        INNER JOIN MAT m ON a.mat_id = m.id
        LIMIT 10;
    """)
    
    print("\n📚 Ejemplo de datos a procesar:")
    print("-" * 70)
    print(f"{'Alumno':<25} {'Curso':<15} {'Materia':<30}")
    print("-" * 70)
    
    for row in cursor.fetchall():
        print(f"{row[0]:<25} {row[1]:<15} {row[2]:<30}")
    
    # Verificar materias por curso
    cursor.execute("""
        SELECT 
            c.id,
            c.paralelo,
            c.gestion,
            COUNT(a.mat_id) as materias
        FROM CUR c
        LEFT JOIN ASIG a ON c.id = a.cur_id
        GROUP BY c.id, c.paralelo, c.gestion
        ORDER BY materias DESC
        LIMIT 5;
    """)
    
    print("\n📖 Materias asignadas por curso (top 5):")
    print("-" * 70)
    print(f"{'Curso ID':<10} {'Paralelo':<15} {'Gestión':<10} {'Materias':<10}")
    print("-" * 70)
    
    for row in cursor.fetchall():
        print(f"{row[0]:<10} {row[1]:<15} {row[2]:<10} {row[3]:<10}")
    
    cursor.close()
    conn.close()


if __name__ == "__main__":
    verificar_estructura()
