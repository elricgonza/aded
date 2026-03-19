# poblar_inscripciones.py
"""
Script para poblar la tabla INSC asignando alumnos a cursos
con un promedio de 45 alumnos por curso en PostgreSQL
"""

import psycopg2
from psycopg2 import sql
from datetime import datetime, timedelta
import random
import os
from dotenv import load_dotenv

# Cargar variables de entorno si existen
load_dotenv()

# Configuración de la base de datos
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', 5432),
    'database': os.getenv('DB_NAME', 'dbaded1'),
    'user': os.getenv('DB_USER', 'uaded'),
    'password': os.getenv('DB_PASSWORD', 'paded')
}

# Configuración
ALUMNOS_POR_CURSO = 45


def conectar_db():
    """Establece conexión con la base de datos"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✓ Conexión exitosa a la base de datos")
        return conn
    except Exception as e:
        print(f"✗ Error al conectar a la base de datos: {e}")
        raise


def limpiar_tabla_insc(conn):
    """Limpia la tabla INSC antes de poblarla"""
    try:
        cursor = conn.cursor()
        cursor.execute("TRUNCATE TABLE INSC RESTART IDENTITY CASCADE;")
        conn.commit()
        cursor.close()
        print("✓ Tabla INSC limpiada")
    except Exception as e:
        print(f"✗ Error al limpiar tabla INSC: {e}")
        conn.rollback()
        raise


def obtener_alumnos(conn):
    """Obtiene todos los alumnos ordenados por ID"""
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM ALUM ORDER BY id;")
    alumnos = [row[0] for row in cursor.fetchall()]
    cursor.close()
    print(f"✓ Total de alumnos encontrados: {len(alumnos)}")
    return alumnos


def obtener_cursos(conn):
    """Obtiene todos los cursos con sus datos"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT id, fecha_ini 
        FROM CUR 
        ORDER BY id;
    """)
    cursos = cursor.fetchall()
    cursor.close()
    print(f"✓ Total de cursos encontrados: {len(cursos)}")
    return cursos


def generar_fecha_inscripcion(fecha_inicio):
    """Genera una fecha de inscripción aleatoria entre 1-7 días antes del inicio"""
    if fecha_inicio is None:
        return datetime.now().date()
    
    dias_antes = random.randint(1, 7)
    fecha_insc = fecha_inicio - timedelta(days=dias_antes)
    return fecha_insc


def poblar_inscripciones_metodo1(conn):
    """
    Método 1: Usando SQL con CTEs (Common Table Expressions)
    Más eficiente para grandes volúmenes de datos
    """
    print("\n=== Método 1: Usando SQL con CTEs ===")
    
    try:
        cursor = conn.cursor()
        
        query = """
        WITH alumnos_numerados AS (
            SELECT 
                id as alum_id,
                ROW_NUMBER() OVER (ORDER BY id) as alumno_num
            FROM ALUM
        ),
        cursos_numerados AS (
            SELECT 
                id as cur_id,
                fecha_ini,
                ROW_NUMBER() OVER (ORDER BY id) as curso_num
            FROM CUR
        ),
        distribucion AS (
            SELECT 
                a.alum_id,
                c.cur_id,
                c.fecha_ini,
                CEIL(a.alumno_num / %s::numeric) as grupo_curso
            FROM alumnos_numerados a
            CROSS JOIN (SELECT COUNT(*) as total_cursos FROM CUR) tc
            CROSS JOIN cursos_numerados c
            WHERE c.curso_num = CEIL(a.alumno_num / %s::numeric)
                AND CEIL(a.alumno_num / %s::numeric) <= tc.total_cursos
        )
        INSERT INTO INSC (alum_id, cur_id, fecha_insc)
        SELECT 
            d.alum_id,
            d.cur_id,
            d.fecha_ini - INTERVAL '7 days' + 
                (random() * INTERVAL '6 days') as fecha_insc
        FROM distribucion d
        ORDER BY d.cur_id, d.alum_id
        RETURNING id;
        """
        
        cursor.execute(query, (ALUMNOS_POR_CURSO, ALUMNOS_POR_CURSO, ALUMNOS_POR_CURSO))
        registros_insertados = cursor.rowcount
        conn.commit()
        cursor.close()
        
        print(f"✓ Inscripciones creadas: {registros_insertados}")
        return registros_insertados
        
    except Exception as e:
        print(f"✗ Error al poblar inscripciones: {e}")
        conn.rollback()
        raise


def poblar_inscripciones_metodo2(conn):
    """
    Método 2: Usando Python con lógica en memoria
    Más flexible y fácil de entender/modificar
    """
    print("\n=== Método 2: Usando Python ===")
    
    try:
        alumnos = obtener_alumnos(conn)
        cursos = obtener_cursos(conn)
        
        if not alumnos or not cursos:
            print("✗ No hay alumnos o cursos disponibles")
            return 0
        
        # Calcular distribución
        total_cursos = len(cursos)
        inscripciones = []
        
        for idx, alum_id in enumerate(alumnos, start=1):
            # Calcular a qué curso pertenece este alumno
            curso_idx = (idx - 1) // ALUMNOS_POR_CURSO
            
            # Verificar que no excedamos el número de cursos disponibles
            if curso_idx >= total_cursos:
                print(f"⚠ Alumno {alum_id} no tiene curso asignado (excede cursos disponibles)")
                continue
            
            cur_id, fecha_inicio = cursos[curso_idx]
            fecha_insc = generar_fecha_inscripcion(fecha_inicio)
            
            inscripciones.append((alum_id, cur_id, fecha_insc))
        
        # Insertar en batch
        cursor = conn.cursor()
        insert_query = """
            INSERT INTO INSC (alum_id, cur_id, fecha_insc)
            VALUES (%s, %s, %s);
        """
        
        cursor.executemany(insert_query, inscripciones)
        conn.commit()
        registros_insertados = cursor.rowcount
        cursor.close()
        
        print(f"✓ Inscripciones creadas: {registros_insertados}")
        return registros_insertados
        
    except Exception as e:
        print(f"✗ Error al poblar inscripciones: {e}")
        conn.rollback()
        raise


def verificar_distribucion(conn):
    """Muestra estadísticas de la distribución de alumnos por curso"""
    print("\n=== Verificación de Distribución ===")
    
    cursor = conn.cursor()
    
    # Estadísticas por curso
    cursor.execute("""
        SELECT 
            c.id as curso_id,
            c.paralelo,
            c.gestion,
            COUNT(i.id) as total_alumnos
        FROM CUR c
        LEFT JOIN INSC i ON c.id = i.cur_id
        GROUP BY c.id, c.paralelo, c.gestion
        ORDER BY c.id;
    """)
    
    print("\n📊 Alumnos por curso:")
    print("-" * 60)
    print(f"{'Curso ID':<10} {'Paralelo':<10} {'Gestión':<10} {'Alumnos':<10}")
    print("-" * 60)
    
    for row in cursor.fetchall():
        print(f"{row[0]:<10} {row[1]:<10} {row[2]:<10} {row[3]:<10}")
    
    # Resumen general
    cursor.execute("""
        SELECT 
            COUNT(DISTINCT cur_id) as total_cursos,
            COUNT(*) as total_inscripciones,
            ROUND(AVG(alumnos), 2) as promedio_alumnos,
            MIN(alumnos) as minimo_alumnos,
            MAX(alumnos) as maximo_alumnos
        FROM (
            SELECT cur_id, COUNT(*) as alumnos
            FROM INSC
            GROUP BY cur_id
        ) sub;
    """)
    
    stats = cursor.fetchone()
    print("\n📈 Resumen General:")
    print("-" * 60)
    print(f"Total de cursos con alumnos: {stats[0]}")
    print(f"Total de inscripciones: {stats[1]}")
    print(f"Promedio de alumnos por curso: {stats[2]}")
    print(f"Mínimo de alumnos en un curso: {stats[3]}")
    print(f"Máximo de alumnos en un curso: {stats[4]}")
    
    # Verificar alumnos duplicados
    cursor.execute("""
        SELECT alum_id, COUNT(*) as veces_inscrito
        FROM INSC
        GROUP BY alum_id
        HAVING COUNT(*) > 1;
    """)
    
    duplicados = cursor.fetchall()
    if duplicados:
        print(f"\n⚠ ADVERTENCIA: {len(duplicados)} alumnos están inscritos en múltiples cursos")
        for alum_id, veces in duplicados[:5]:  # Mostrar solo los primeros 5
            print(f"  - Alumno ID {alum_id}: {veces} inscripciones")
    else:
        print("\n✓ Todos los alumnos están inscritos en un solo curso")
    
    # Verificar alumnos sin curso
    cursor.execute("""
        SELECT COUNT(*)
        FROM ALUM a
        LEFT JOIN INSC i ON a.id = i.alum_id
        WHERE i.id IS NULL;
    """)
    
    sin_curso = cursor.fetchone()[0]
    if sin_curso > 0:
        print(f"\n⚠ Hay {sin_curso} alumnos sin curso asignado")
    else:
        print("\n✓ Todos los alumnos tienen curso asignado")
    
    cursor.close()


def main():
    """Función principal"""
    print("=" * 60)
    print("SCRIPT DE POBLACIÓN DE INSCRIPCIONES")
    print("=" * 60)
    
    try:
        # Conectar a la base de datos
        conn = conectar_db()
        
        # Limpiar tabla existente
        respuesta = input("\n¿Desea limpiar la tabla INSC antes de poblar? (s/n): ")
        if respuesta.lower() == 's':
            limpiar_tabla_insc(conn)
        
        # Seleccionar método
        print("\nSeleccione el método de población:")
        print("1. SQL con CTEs (más rápido)")
        print("2. Python con lógica en memoria (más flexible)")
        metodo = input("Opción (1 o 2): ")
        
        if metodo == '1':
            poblar_inscripciones_metodo1(conn)
        elif metodo == '2':
            poblar_inscripciones_metodo2(conn)
        else:
            print("✗ Opción inválida")
            return
        
        # Verificar resultados
        verificar_distribucion(conn)
        
        print("\n✓ Proceso completado exitosamente")
        
    except Exception as e:
        print(f"\n✗ Error general: {e}")
        return 1
    
    finally:
        if 'conn' in locals() and conn:
            conn.close()
            print("\n✓ Conexión cerrada")
    
    return 0


if __name__ == "__main__":
    exit(main())
