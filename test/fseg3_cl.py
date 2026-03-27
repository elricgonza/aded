# poblar_seguimiento.py
"""
Script para poblar la tabla SEG (Seguimiento)
Crea registros de seguimiento para cada alumno inscrito,
con cada materia asignada al curso correspondiente.
"""

import psycopg2
from psycopg2 import sql
import random
import os
from dotenv import load_dotenv
from datetime import datetime

# Cargar variables de entorno
load_dotenv()

# Configuración de la base de datos
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', 5432),
    'database': os.getenv('DB_NAME', 'dbaded1'),
    'user': os.getenv('DB_USER', 'uaded'),
    'password': os.getenv('DB_PASSWORD', 'paded')
}

# Configuración de notas
GENERAR_NOTAS_ALEATORIAS = True
NOTA_MINIMA = 0
NOTA_MAXIMA = 100
NOTA_APROBACION = 51
PROBABILIDAD_APROBACION = 0.75


def conectar_db():
    """Establece conexión con la base de datos"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✓ Conexión exitosa a la base de datos")
        return conn
    except Exception as e:
        print(f"✗ Error al conectar: {e}")
        raise


def limpiar_tabla_seg(conn):
    """Limpia la tabla SEG antes de poblarla"""
    try:
        cursor = conn.cursor()
        cursor.execute("TRUNCATE TABLE seg RESTART IDENTITY CASCADE;")
        conn.commit()
        cursor.close()
        print("✓ Tabla SEG limpiada")
    except Exception as e:
        print(f"✗ Error al limpiar tabla SEG: {e}")
        conn.rollback()
        raise


def verificar_datos_previos(conn):
    """Verifica los datos existentes en las tablas"""
    cursor = conn.cursor()
    
    print("\n" + "=" * 70)
    print("VERIFICACIÓN DE DATOS EXISTENTES")
    print("=" * 70)
    
    # Verificar tablas
    tablas = {
        'alu': 'Alumnos',
        'cur': 'Cursos', 
        'ins': 'Inscripciones',
        'mat': 'Materias',
        'asi': 'Asignaciones',
        'pro': 'Profesores',
        'seg': 'Seguimiento'
    }
    
    print("\n📋 Registros por tabla:")
    print("-" * 70)
    for tabla, descripcion in tablas.items():
        cursor.execute(f"SELECT COUNT(*) FROM {tabla};")
        count = cursor.fetchone()[0]
        print(f"{descripcion:20} ({tabla:6}): {count:8} registros")
    
    # Calcular registros esperados para SEG
    cursor.execute("""
        SELECT COUNT(*)
        FROM ins i
        INNER JOIN cur c ON i.cur_id = c.id
        INNER JOIN asi a ON c.id = a.cur_id;
    """)
    registros_esperados = cursor.fetchone()[0]
    
    print(f"\n📊 Registros SEG esperados: {registros_esperados}")
    
    # Mostrar ejemplo de inscripciones
    cursor.execute("""
        SELECT 
            i.id as ins_id,
            al.nombre || ' ' || al.apellido as alumno,
            c.paralelo,
            c.gestion,
            COUNT(a.mat_id) as total_materias
        FROM ins i
        INNER JOIN alu al ON i.alu_id = al.id
        INNER JOIN cur c ON i.cur_id = c.id
        INNER JOIN asi a ON c.id = a.cur_id
        GROUP BY i.id, al.nombre, al.apellido, c.paralelo, c.gestion
        ORDER BY i.id
        LIMIT 10;
    """)
    
    print("\n📚 Ejemplo de inscripciones (primeras 10):")
    print("-" * 70)
    print(f"{'Ins ID':<8} {'Alumno':<30} {'Curso':<15} {'Materias':<10}")
    print("-" * 70)
    
    for row in cursor.fetchall():
        curso = f"{row[2]}/{row[3]}"
        print(f"{row[0]:<8} {row[1]:<30} {curso:<15} {row[4]:<10}")
    
    cursor.close()
    return registros_esperados


def generar_notas():
    """
    Genera notas aleatorias
    Retorna: (ev01, ev02, evfin, aprob)
    """
    if not GENERAR_NOTAS_ALEATORIAS:
        return (None, None, None, None)
    
    aprobara = random.random() < PROBABILIDAD_APROBACION
    
    if aprobara:
        ev01 = random.randint(NOTA_APROBACION, NOTA_MAXIMA)
        ev02 = random.randint(NOTA_APROBACION, NOTA_MAXIMA)
        evfin = random.randint(NOTA_APROBACION, NOTA_MAXIMA)
        aprob = True
    else:
        opciones = [
            (random.randint(NOTA_MINIMA, NOTA_APROBACION - 1), 
             random.randint(NOTA_MINIMA, NOTA_MAXIMA),
             random.randint(NOTA_MINIMA, NOTA_MAXIMA)),
            (random.randint(NOTA_MINIMA, NOTA_MAXIMA),
             random.randint(NOTA_MINIMA, NOTA_APROBACION - 1),
             random.randint(NOTA_MINIMA, NOTA_MAXIMA)),
            (random.randint(NOTA_MINIMA, NOTA_MAXIMA),
             random.randint(NOTA_MINIMA, NOTA_MAXIMA),
             random.randint(NOTA_MINIMA, NOTA_APROBACION - 1))
        ]
        ev01, ev02, evfin = random.choice(opciones)
        aprob = False
    
    return (ev01, ev02, evfin, aprob)


def poblar_seg_metodo_sql(conn):
    """
    Método 1: Usando SQL puro (más rápido)
    """
    print("\n=== Método 1: SQL Puro ===")
    
    try:
        cursor = conn.cursor()
        
        if GENERAR_NOTAS_ALEATORIAS:
            # Crear función auxiliar
            cursor.execute("""
                CREATE OR REPLACE FUNCTION generar_nota(min_val INT, max_val INT)
                RETURNS INT AS $$
                BEGIN
                    RETURN FLOOR(RANDOM() * (max_val - min_val + 1) + min_val);
                END;
                $$ LANGUAGE plpgsql;
            """)
            
            query = """
                INSERT INTO seg (ins_id, mat_id, ev01, ev02, evfin, aprob)
                SELECT DISTINCT
                    i.id as ins_id,
                    a.mat_id,
                    generar_nota(%s, %s) as ev01,
                    generar_nota(%s, %s) as ev02,
                    generar_nota(%s, %s) as evfin,
                    CASE 
                        WHEN generar_nota(%s, %s) >= %s THEN TRUE 
                        ELSE FALSE 
                    END as aprob
                FROM ins i
                INNER JOIN cur c ON i.cur_id = c.id
                INNER JOIN asi a ON c.id = a.cur_id
                ORDER BY i.id, a.mat_id
                RETURNING id;
            """
            
            cursor.execute(query, (
                NOTA_MINIMA, NOTA_MAXIMA,
                NOTA_MINIMA, NOTA_MAXIMA,
                NOTA_MINIMA, NOTA_MAXIMA,
                NOTA_MINIMA, NOTA_MAXIMA,
                NOTA_APROBACION
            ))
        else:
            query = """
                INSERT INTO seg (ins_id, mat_id, ev01, ev02, evfin, aprob)
                SELECT DISTINCT
                    i.id as ins_id,
                    a.mat_id,
                    NULL, NULL, NULL, NULL
                FROM ins i
                INNER JOIN cur c ON i.cur_id = c.id
                INNER JOIN asi a ON c.id = a.cur_id
                ORDER BY i.id, a.mat_id
                RETURNING id;
            """
            cursor.execute(query)
        
        registros = cursor.rowcount
        conn.commit()
        cursor.close()
        
        print(f"✓ Registros creados: {registros}")
        return registros
        
    except Exception as e:
        print(f"✗ Error: {e}")
        conn.rollback()
        raise


def poblar_seg_metodo_python(conn):
    """
    Método 2: Usando Python con control detallado
    """
    print("\n=== Método 2: Python con Control ===")
    
    try:
        cursor = conn.cursor()
        
        # Obtener datos
        cursor.execute("""
            SELECT DISTINCT
                i.id as ins_id,
                a.mat_id,
                al.nombre || ' ' || al.apellido as alumno,
                m.materia,
                c.paralelo,
                c.gestion
            FROM ins i
            INNER JOIN alu al ON i.alu_id = al.id
            INNER JOIN cur c ON i.cur_id = c.id
            INNER JOIN asi a ON c.id = a.cur_id
            INNER JOIN mat m ON a.mat_id = m.id
            ORDER BY i.id, a.mat_id;
        """)
        
        datos = cursor.fetchall()
        print(f"✓ Registros a procesar: {len(datos)}")
        
        # Generar registros
        registros_seg = []
        
        print("\nGenerando registros...")
        for idx, (ins_id, mat_id, alumno, materia, paralelo, gestion) in enumerate(datos, 1):
            ev01, ev02, evfin, aprob = generar_notas()
            registros_seg.append((ins_id, mat_id, ev01, ev02, evfin, aprob))
            
            if idx % 500 == 0:
                print(f"  Procesados: {idx}/{len(datos)}")
        
        # Insertar en batch
        insert_query = """
            INSERT INTO seg (ins_id, mat_id, ev01, ev02, evfin, aprob)
            VALUES (%s, %s, %s, %s, %s, %s);
        """
        
        cursor.executemany(insert_query, registros_seg)
        conn.commit()
        
        registros = cursor.rowcount
        cursor.close()
        
        print(f"\n✓ Registros creados: {registros}")
        return registros
        
    except Exception as e:
        print(f"✗ Error: {e}")
        conn.rollback()
        raise


def poblar_seg_metodo_detallado(conn):
    """
    Método 3: Versión detallada con estadísticas
    """
    print("\n=== Método 3: Detallado con Estadísticas ===")
    
    try:
        cursor = conn.cursor()
        
        # Obtener datos
        cursor.execute("""
            SELECT DISTINCT
                i.id as ins_id,
                a.mat_id,
                al.nombre || ' ' || al.apellido as alumno,
                m.materia,
                c.paralelo || '/' || c.gestion as curso
            FROM ins i
            INNER JOIN alu al ON i.alu_id = al.id
            INNER JOIN cur c ON i.cur_id = c.id
            INNER JOIN asi a ON c.id = a.cur_id
            INNER JOIN mat m ON a.mat_id = m.id
            ORDER BY i.id, a.mat_id;
        """)
        
        datos = cursor.fetchall()
        
        insert_query = """
            INSERT INTO seg (ins_id, mat_id, ev01, ev02, evfin, aprob)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING id;
        """
        
        registros = 0
        stats = {
            'total': 0,
            'aprobados': 0,
            'reprobados': 0,
            'suma_notas': 0
        }
        
        print(f"\nProcesando {len(datos)} registros...")
        
        for idx, (ins_id, mat_id, alumno, materia, curso) in enumerate(datos, 1):
            ev01, ev02, evfin, aprob = generar_notas()
            
            cursor.execute(insert_query, (ins_id, mat_id, ev01, ev02, evfin, aprob))
            seg_id = cursor.fetchone()[0]
            registros += 1
            
            stats['total'] += 1
            if aprob == True:
                stats['aprobados'] += 1
            elif aprob == False:
                stats['reprobados'] += 1
            if evfin:
                stats['suma_notas'] += evfin
            
            # Mostrar primeros 10
            if registros <= 10:
                estado = '✓' if aprob else '✗' if aprob == False else '-'
                print(f"  [{seg_id:5}] {alumno:30} | {materia:25} | {estado}")
            
            if idx % 500 == 0:
                print(f"  Progreso: {idx}/{len(datos)}")
        
        conn.commit()
        cursor.close()
        
        print(f"\n✓ Total de registros: {registros}")
        
        if GENERAR_NOTAS_ALEATORIAS:
            promedio = stats['suma_notas'] / stats['total'] if stats['total'] > 0 else 0
            print(f"  - Aprobados: {stats['aprobados']}")
            print(f"  - Reprobados: {stats['reprobados']}")
            print(f"  - Promedio final: {promedio:.2f}")
        
        return registros
        
    except Exception as e:
        print(f"✗ Error: {e}")
        conn.rollback()
        raise


def verificar_seguimiento(conn):
    """Verifica el seguimiento creado"""
    print("\n" + "=" * 70)
    print("VERIFICACIÓN DE SEGUIMIENTO")
    print("=" * 70)
    
    cursor = conn.cursor()
    
    # Estadísticas generales
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(DISTINCT ins_id) as inscripciones,
            COUNT(DISTINCT mat_id) as materias,
            COUNT(CASE WHEN aprob = TRUE THEN 1 END) as aprobados,
            COUNT(CASE WHEN aprob = FALSE THEN 1 END) as reprobados,
            COUNT(CASE WHEN aprob IS NULL THEN 1 END) as sin_calificar,
            ROUND(AVG(ev01), 2) as prom_ev01,
            ROUND(AVG(ev02), 2) as prom_ev02,
            ROUND(AVG(evfin), 2) as prom_evfin
        FROM seg;
    """)
    
    stats = cursor.fetchone()
    
    print("\n📊 Estadísticas Generales:")
    print("-" * 70)
    print(f"Total de registros: {stats[0]}")
    print(f"Inscripciones únicas: {stats[1]}")
    print(f"Materias diferentes: {stats[2]}")
    print(f"Registros aprobados: {stats[3]}")
    print(f"Registros reprobados: {stats[4]}")
    print(f"Sin calificar: {stats[5]}")
    
    if stats[6] is not None:
        print(f"Promedio Ev01: {stats[6]}")
        print(f"Promedio Ev02: {stats[7]}")
        print(f"Promedio EvFin: {stats[8]}")
    
    # Top alumnos
    cursor.execute("""
        SELECT 
            al.nombre || ' ' || al.apellido as alumno,
            COUNT(s.id) as materias,
            COUNT(CASE WHEN s.aprob = TRUE THEN 1 END) as aprobadas,
            COUNT(CASE WHEN s.aprob = FALSE THEN 1 END) as reprobadas,
            ROUND(AVG(s.evfin), 2) as promedio
        FROM ins i
        INNER JOIN alu al ON i.alu_id = al.id
        INNER JOIN seg s ON i.id = s.ins_id
        GROUP BY al.id, al.nombre, al.apellido
        ORDER BY promedio DESC NULLS LAST
        LIMIT 10;
    """)
    
    print("\n🏆 Top 10 Alumnos (mejor promedio):")
    print("-" * 90)
    print(f"{'Alumno':<35} {'Materias':<10} {'Aprobadas':<12} {'Reprobadas':<12} {'Promedio':<10}")
    print("-" * 90)
    
    for row in cursor.fetchall():
        prom = f"{row[4]:.2f}" if row[4] else "-"
        print(f"{row[0]:<35} {row[1]:<10} {row[2]:<12} {row[3]:<12} {prom:<10}")
    
    # Distribución por materia
    cursor.execute("""
        SELECT 
            m.materia,
            COUNT(s.id) as alumnos,
            COUNT(CASE WHEN s.aprob = TRUE THEN 1 END) as aprobados,
            ROUND(AVG(s.evfin), 2) as promedio
        FROM seg s
        INNER JOIN mat m ON s.mat_id = m.id
        GROUP BY m.id, m.materia
        ORDER BY alumnos DESC
        LIMIT 10;
    """)
    
    print("\n📚 Top 10 Materias (más alumnos):")
    print("-" * 80)
    print(f"{'Materia':<40} {'Alumnos':<10} {'Aprobados':<12} {'Promedio':<10}")
    print("-" * 80)
    
    for row in cursor.fetchall():
        prom = f"{row[3]:.2f}" if row[3] else "-"
        print(f"{row[0]:<40} {row[1]:<10} {row[2]:<12} {prom:<10}")
    
    # Verificar integridad
    cursor.execute("""
        SELECT COUNT(*)
        FROM ins i
        INNER JOIN cur c ON i.cur_id = c.id
        INNER JOIN asi a ON c.id = a.cur_id
        LEFT JOIN seg s ON i.id = s.ins_id AND a.mat_id = s.mat_id
        WHERE s.id IS NULL;
    """)
    
    faltantes = cursor.fetchone()[0]
    
    if faltantes > 0:
        print(f"\n⚠ ADVERTENCIA: {faltantes} combinaciones sin seguimiento")
    else:
        print("\n✓ Integridad verificada: Todas las inscripciones tienen seguimiento completo")
    
    cursor.close()


def exportar_reporte(conn, archivo='reporte_seguimiento.txt'):
    """Exporta reporte detallado"""
    print(f"\n=== Generando reporte: {archivo} ===")
    
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            al.nombre || ' ' || al.apellido as alumno,
            c.paralelo || '/' || c.gestion as curso,
            m.materia,
            s.ev01,
            s.ev02,
            s.evfin,
            CASE 
                WHEN s.aprob = TRUE THEN 'APROBADO'
                WHEN s.aprob = FALSE THEN 'REPROBADO'
                ELSE 'PENDIENTE'
            END as estado
        FROM seg s
        INNER JOIN ins i ON s.ins_id = i.id
        INNER JOIN alu al ON i.alu_id = al.id
        INNER JOIN cur c ON i.cur_id = c.id
        INNER JOIN mat m ON s.mat_id = m.id
        ORDER BY al.apellido, al.nombre, m.materia;
    """)
    
    with open(archivo, 'w', encoding='utf-8') as f:
        f.write("=" * 100 + "\n")
        f.write("REPORTE DE SEGUIMIENTO ACADÉMICO\n")
        f.write(f"Generado: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=" * 100 + "\n\n")
        
        f.write(f"{'Alumno':<35} {'Curso':<12} {'Materia':<30} {'Ev1':<5} {'Ev2':<5} {'Final':<6} {'Estado':<12}\n")
        f.write("-" * 100 + "\n")
        
        for row in cursor.fetchall():
            alumno, curso, materia, ev01, ev02, evfin, estado = row
            ev01_str = str(ev01) if ev01 else "-"
            ev02_str = str(ev02) if ev02 else "-"
            evfin_str = str(evfin) if evfin else "-"
            
            f.write(f"{alumno:<35} {curso:<12} {materia:<30} {ev01_str:<5} {ev02_str:<5} {evfin_str:<6} {estado:<12}\n")
    
    cursor.close()
    print(f"✓ Reporte generado")


def main():
    """Función principal"""
    print("=" * 70)
    print("SCRIPT DE POBLACIÓN DE SEGUIMIENTO (SEG)")
    print("=" * 70)
    
    try:
        conn = conectar_db()
        
        # Verificar datos
        registros_esperados = verificar_datos_previos(conn)
        
        # Limpiar tabla
        respuesta = input("\n¿Limpiar tabla SEG antes de poblar? (s/n): ")
        if respuesta.lower() == 's':
            limpiar_tabla_seg(conn)
        
        # Seleccionar método
        print("\nMétodos de población:")
        print("1. SQL puro (más rápido)")
        print("2. Python con control")
        print("3. Python detallado (con estadísticas)")
        metodo = input("Seleccione (1-3): ")
        
        if metodo == '1':
            poblar_seg_metodo_sql(conn)
        elif metodo == '2':
            poblar_seg_metodo_python(conn)
        elif metodo == '3':
            poblar_seg_metodo_detallado(conn)
        else:
            print("✗ Opción inválida")
            return 1
        
        # Verificar
        verificar_seguimiento(conn)
        
        # Exportar
        respuesta = input("\n¿Generar reporte en archivo? (s/n): ")
        if respuesta.lower() == 's':
            exportar_reporte(conn)
        
        print("\n✓ Proceso completado")
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    finally:
        if 'conn' in locals():
            conn.close()
            print("\n✓ Conexión cerrada")
    
    return 0


if __name__ == "__main__":
    exit(main())
