# poblar_seguimiento.py
"""
Script para poblar la tabla SEG (Seguimiento)
Crea registros de seguimiento para cada alumno inscrito en un curso,
considerando todas las materias asignadas a ese curso.
"""

import psycopg2
from psycopg2 import sql
import random
import os
from dotenv import load_dotenv

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
GENERAR_NOTAS_ALEATORIAS = True  # Cambiar a False si solo quieres NULL
NOTA_MINIMA = 0
NOTA_MAXIMA = 100
NOTA_APROBACION = 51
PROBABILIDAD_APROBACION = 0.80  # 80% de probabilidad de aprobar


def conectar_db():
    """Establece conexión con la base de datos"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✓ Conexión exitosa a la base de datos")
        return conn
    except Exception as e:
        print(f"✗ Error al conectar a la base de datos: {e}")
        raise


def limpiar_tabla_seg(conn):
    """Limpia la tabla SEG antes de poblarla"""
    try:
        cursor = conn.cursor()
        cursor.execute("TRUNCATE TABLE SEG RESTART IDENTITY CASCADE;")
        conn.commit()
        cursor.close()
        print("✓ Tabla SEG limpiada")
    except Exception as e:
        print(f"✗ Error al limpiar tabla SEG: {e}")
        conn.rollback()
        raise


def generar_notas():
    """
    Genera notas aleatorias para un alumno
    Retorna: (ev01, ev02, evfin, aprob)
    """
    if not GENERAR_NOTAS_ALEATORIAS:
        return (None, None, None, None)
    
    # Decidir si el alumno aprobará o no
    aprobara = random.random() < PROBABILIDAD_APROBACION
    
    if aprobara:
        # Generar notas que llevan a la aprobación
        ev01 = random.randint(NOTA_APROBACION, NOTA_MAXIMA)
        ev02 = random.randint(NOTA_APROBACION, NOTA_MAXIMA)
        evfin = random.randint(NOTA_APROBACION, NOTA_MAXIMA)
        aprob = True
    else:
        # Generar notas que llevan a la reprobación
        # Al menos una evaluación baja
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


def obtener_inscripciones_con_materias(conn):
    """
    Obtiene todas las inscripciones con sus materias asignadas
    Retorna: lista de (insc_id, cur_id, alum_id, mat_id, materia_nombre)
    """
    cursor = conn.cursor()
    
    query = """
        SELECT DISTINCT
            i.id as ins_id,
            i.cur_id,
            i.alu_id,
            a.mat_id,
            m.materia as materia_nombre,
            al.nombre || ' ' || al.apellido as alumno,
            c.paralelo,
            c.gestion
        FROM INS i
        INNER JOIN CUR c ON i.cur_id = c.id
        INNER JOIN ASI a ON c.id = a.cur_id
        INNER JOIN MAT m ON a.mat_id = m.id
        INNER JOIN ALU al ON i.alu_id = al.id
        ORDER BY i.id, a.mat_id;
    """
    
    cursor.execute(query)
    resultados = cursor.fetchall()
    cursor.close()
    
    print(f"✓ Total de registros de seguimiento a crear: {len(resultados)}")
    
    return resultados


def poblar_seg_metodo1_sql(conn):
    """
    Método 1: Usando SQL puro con INSERT directo
    Más rápido para grandes volúmenes
    """
    print("\n=== Método 1: Usando SQL puro ===")
    
    try:
        cursor = conn.cursor()
        
        if GENERAR_NOTAS_ALEATORIAS:
            # Con notas aleatorias (requiere función en PostgreSQL)
            # Primero crear la función si no existe
            cursor.execute("""
                CREATE OR REPLACE FUNCTION generar_nota_aleatoria(min_nota INT, max_nota INT)
                RETURNS INT AS $$
                BEGIN
                    RETURN FLOOR(RANDOM() * (max_nota - min_nota + 1) + min_nota);
                END;
                $$ LANGUAGE plpgsql;
            """)
            
            query = """
                INSERT INTO SEG (insc_id, ev01, ev02, evfin, aprob)
                SELECT DISTINCT
                    i.id as insc_id,
                    generar_nota_aleatoria(%s, %s) as ev01,
                    generar_nota_aleatoria(%s, %s) as ev02,
                    generar_nota_aleatoria(%s, %s) as evfin,
                    CASE 
                        WHEN generar_nota_aleatoria(%s, %s) >= %s THEN TRUE 
                        ELSE FALSE 
                    END as aprob
                FROM INSC i
                INNER JOIN CUR c ON i.cur_id = c.id
                INNER JOIN ASIG a ON c.id = a.cur_id
                INNER JOIN MAT m ON a.mat_id = m.id
                ORDER BY i.id
                RETURNING id;
            """
            
            cursor.execute(query, (
                NOTA_MINIMA, NOTA_MAXIMA,  # ev01
                NOTA_MINIMA, NOTA_MAXIMA,  # ev02
                NOTA_MINIMA, NOTA_MAXIMA,  # evfin
                NOTA_MINIMA, NOTA_MAXIMA,  # para aprob
                NOTA_APROBACION
            ))
        else:
            # Sin notas (todo NULL)
            query = """
                INSERT INTO SEG (insc_id, ev01, ev02, evfin, aprob)
                SELECT DISTINCT
                    i.id as insc_id,
                    NULL as ev01,
                    NULL as ev02,
                    NULL as evfin,
                    NULL as aprob
                FROM INSC i
                INNER JOIN CUR c ON i.cur_id = c.id
                INNER JOIN ASIG a ON c.id = a.cur_id
                INNER JOIN MAT m ON a.mat_id = m.id
                ORDER BY i.id
                RETURNING id;
            """
            
            cursor.execute(query)
        
        registros_insertados = cursor.rowcount
        conn.commit()
        cursor.close()
        
        print(f"✓ Registros de seguimiento creados: {registros_insertados}")
        return registros_insertados
        
    except Exception as e:
        print(f"✗ Error al poblar seguimiento: {e}")
        conn.rollback()
        raise


def poblar_seg_metodo2_python(conn):
    """
    Método 2: Usando Python con control total sobre las notas
    Más flexible y permite lógica personalizada
    """
    print("\n=== Método 2: Usando Python ===")
    
    try:
        # Obtener todas las inscripciones con sus materias
        inscripciones_materias = obtener_inscripciones_con_materias(conn)
        
        if not inscripciones_materias:
            print("✗ No hay inscripciones o materias asignadas")
            return 0
        
        # Generar registros de seguimiento
        registros_seg = []
        
        print("\nGenerando registros de seguimiento...")
        for idx, (insc_id, cur_id, alum_id, mat_id, materia, alumno, paralelo, gestion) in enumerate(inscripciones_materias, start=1):
            ev01, ev02, evfin, aprob = generar_notas()
            registros_seg.append((insc_id, mat_id, ev01, ev02, evfin, aprob))
            
            # Mostrar progreso cada 100 registros
            if idx % 100 == 0:
                print(f"  Procesados: {idx}/{len(inscripciones_materias)}")
        
        # Insertar en batch
        cursor = conn.cursor()
        insert_query = """
            INSERT INTO SEG (ins_id, mat_id, ev01, ev02, evfin, aprob)
            VALUES (%s, %s, %s, %s, %s);
        """
        
        cursor.executemany(insert_query, registros_seg)
        conn.commit()
        registros_insertados = cursor.rowcount
        cursor.close()
        
        print(f"\n✓ Registros de seguimiento creados: {registros_insertados}")
        return registros_insertados
        
    except Exception as e:
        print(f"✗ Error al poblar seguimiento: {e}")
        conn.rollback()
        raise


def poblar_seg_metodo3_detallado(conn):
    """
    Método 3: Versión detallada con información por cada registro
    Útil para debugging y entender el proceso
    """
    print("\n=== Método 3: Versión Detallada ===")
    
    try:
        # Obtener todas las inscripciones con sus materias
        inscripciones_materias = obtener_inscripciones_con_materias(conn)
        
        if not inscripciones_materias:
            print("✗ No hay inscripciones o materias asignadas")
            return 0
        
        cursor = conn.cursor()
        insert_query = """
            INSERT INTO SEG (insc_id, ev01, ev02, evfin, aprob)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id;
        """
        
        registros_insertados = 0
        registros_por_alumno = {}
        
        print("\nCreando registros de seguimiento...")
        for insc_id, cur_id, alum_id, mat_id, materia, alumno, paralelo, gestion in inscripciones_materias:
            ev01, ev02, evfin, aprob = generar_notas()
            
            cursor.execute(insert_query, (insc_id, ev01, ev02, evfin, aprob))
            seg_id = cursor.fetchone()[0]
            registros_insertados += 1
            
            # Contabilizar por alumno
            if alumno not in registros_por_alumno:
                registros_por_alumno[alumno] = 0
            registros_por_alumno[alumno] += 1
            
            # Mostrar algunos ejemplos
            if registros_insertados <= 10:
                print(f"  [{seg_id}] {alumno} - {materia} | Ev1:{ev01} Ev2:{ev02} Final:{evfin} Aprobado:{aprob}")
        
        conn.commit()
        cursor.close()
        
        print(f"\n✓ Total de registros creados: {registros_insertados}")
        print(f"✓ Alumnos procesados: {len(registros_por_alumno)}")
        
        # Mostrar alumnos con más materias
        top_alumnos = sorted(registros_por_alumno.items(), key=lambda x: x[1], reverse=True)[:5]
        print("\n📚 Top 5 alumnos con más materias:")
        for alumno, cantidad in top_alumnos:
            print(f"  - {alumno}: {cantidad} materias")
        
        return registros_insertados
        
    except Exception as e:
        print(f"✗ Error al poblar seguimiento: {e}")
        conn.rollback()
        raise


def verificar_seguimiento(conn):
    """Muestra estadísticas del seguimiento creado"""
    print("\n=== Verificación de Seguimiento ===")
    
    cursor = conn.cursor()
    
    # Estadísticas generales
    cursor.execute("""
        SELECT 
            COUNT(*) as total_registros,
            COUNT(DISTINCT insc_id) as total_inscripciones,
            COUNT(CASE WHEN aprob = TRUE THEN 1 END) as aprobados,
            COUNT(CASE WHEN aprob = FALSE THEN 1 END) as reprobados,
            COUNT(CASE WHEN aprob IS NULL THEN 1 END) as sin_calificar,
            ROUND(AVG(ev01), 2) as promedio_ev01,
            ROUND(AVG(ev02), 2) as promedio_ev02,
            ROUND(AVG(evfin), 2) as promedio_evfin
        FROM SEG;
    """)
    
    stats = cursor.fetchone()
    print("\n📊 Estadísticas Generales:")
    print("-" * 70)
    print(f"Total de registros en SEG: {stats[0]}")
    print(f"Inscripciones únicas: {stats[1]}")
    print(f"Materias aprobadas: {stats[2]}")
    print(f"Materias reprobadas: {stats[3]}")
    print(f"Sin calificar: {stats[4]}")
    if stats[5] is not None:
        print(f"Promedio Evaluación 1: {stats[5]}")
        print(f"Promedio Evaluación 2: {stats[6]}")
        print(f"Promedio Evaluación Final: {stats[7]}")
    
    # Registros por alumno
    cursor.execute("""
        SELECT 
            al.nombre || ' ' || al.apellido as alumno,
            COUNT(s.id) as total_materias,
            COUNT(CASE WHEN s.aprob = TRUE THEN 1 END) as aprobadas,
            COUNT(CASE WHEN s.aprob = FALSE THEN 1 END) as reprobadas
        FROM INSC i
        INNER JOIN ALUM al ON i.alum_id = al.id
        INNER JOIN SEG s ON i.id = s.insc_id
        GROUP BY al.id, al.nombre, al.apellido
        ORDER BY total_materias DESC
        LIMIT 10;
    """)
    
    print("\n📚 Top 10 Alumnos con más materias:")
    print("-" * 70)
    print(f"{'Alumno':<30} {'Materias':<10} {'Aprobadas':<12} {'Reprobadas':<12}")
    print("-" * 70)
    
    for row in cursor.fetchall():
        print(f"{row[0]:<30} {row[1]:<10} {row[2]:<12} {row[3]:<12}")
    
    # Materias por curso
    cursor.execute("""
        SELECT 
            c.id,
            c.paralelo,
            c.gestion,
            COUNT(DISTINCT i.alum_id) as alumnos,
            COUNT(DISTINCT asig.mat_id) as materias,
            COUNT(s.id) as total_seguimientos
        FROM CUR c
        INNER JOIN INSC i ON c.id = i.cur_id
        INNER JOIN ASIG asig ON c.id = asig.cur_id
        LEFT JOIN SEG s ON i.id = s.insc_id
        GROUP BY c.id, c.paralelo, c.gestion
        ORDER BY c.id
        LIMIT 10;
    """)
    
    print("\n📖 Seguimiento por Curso (primeros 10):")
    print("-" * 80)
    print(f"{'Curso':<8} {'Paralelo':<10} {'Gestión':<10} {'Alumnos':<10} {'Materias':<10} {'Seguimientos':<15}")
    print("-" * 80)
    
    for row in cursor.fetchall():
        print(f"{row[0]:<8} {row[1]:<10} {row[2]:<10} {row[3]:<10} {row[4]:<10} {row[5]:<15}")
    
    # Verificar integridad
    cursor.execute("""
        SELECT COUNT(*)
        FROM INSC i
        INNER JOIN CUR c ON i.cur_id = c.id
        INNER JOIN ASIG a ON c.id = a.cur_id
        LEFT JOIN SEG s ON i.id = s.insc_id
        WHERE s.id IS NULL;
    """)
    
    faltantes = cursor.fetchone()[0]
    if faltantes > 0:
        print(f"\n⚠ ADVERTENCIA: Hay {faltantes} combinaciones inscripción-materia sin seguimiento")
    else:
        print("\n✓ Todas las inscripciones tienen sus seguimientos correspondientes")
    
    cursor.close()


def exportar_reporte(conn, archivo='reporte_seguimiento.txt'):
    """Exporta un reporte detallado a archivo de texto"""
    print(f"\n=== Generando reporte en {archivo} ===")
    
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            al.nombre || ' ' || al.apellido as alumno,
            c.paralelo,
            c.gestion,
            m.materia,
            s.ev01,
            s.ev02,
            s.evfin,
            CASE 
                WHEN s.aprob = TRUE THEN 'APROBADO'
                WHEN s.aprob = FALSE THEN 'REPROBADO'
                ELSE 'SIN CALIFICAR'
            END as estado
        FROM SEG s
        INNER JOIN INSC i ON s.insc_id = i.id
        INNER JOIN ALUM al ON i.alum_id = al.id
        INNER JOIN CUR c ON i.cur_id = c.id
        INNER JOIN ASIG a ON c.id = a.cur_id
        INNER JOIN MAT m ON a.mat_id = m.id
        ORDER BY al.apellido, al.nombre, m.materia;
    """)
    
    with open(archivo, 'w', encoding='utf-8') as f:
        f.write("=" * 100 + "\n")
        f.write("REPORTE DE SEGUIMIENTO ACADÉMICO\n")
        f.write("=" * 100 + "\n\n")
        
        f.write(f"{'Alumno':<30} {'Curso':<15} {'Materia':<25} {'Ev1':<6} {'Ev2':<6} {'Final':<6} {'Estado':<15}\n")
        f.write("-" * 100 + "\n")
        
        for row in cursor.fetchall():
            alumno, paralelo, gestion, materia, ev01, ev02, evfin, estado = row
            curso = f"{paralelo}/{gestion}"
            ev01_str = str(ev01) if ev01 is not None else "-"
            ev02_str = str(ev02) if ev02 is not None else "-"
            evfin_str = str(evfin) if evfin is not None else "-"
            
            f.write(f"{alumno:<30} {curso:<15} {materia:<25} {ev01_str:<6} {ev02_str:<6} {evfin_str:<6} {estado:<15}\n")
    
    cursor.close()
    print(f"✓ Reporte generado: {archivo}")


def main():
    """Función principal"""
    print("=" * 70)
    print("SCRIPT DE POBLACIÓN DE SEGUIMIENTO (SEG)")
    print("=" * 70)
    
    try:
        # Conectar a la base de datos
        conn = conectar_db()
        
        # Limpiar tabla existente
        respuesta = input("\n¿Desea limpiar la tabla SEG antes de poblar? (s/n): ")
        if respuesta.lower() == 's':
            limpiar_tabla_seg(conn)
        
        # Seleccionar método
        print("\nSeleccione el método de población:")
        print("1. SQL puro (más rápido)")
        print("2. Python con control total (recomendado)")
        print("3. Python detallado (para debugging)")
        metodo = input("Opción (1, 2 o 3): ")
        
        if metodo == '1':
            poblar_seg_metodo1_sql(conn)
        elif metodo == '2':
            poblar_seg_metodo2_python(conn)
        elif metodo == '3':
            poblar_seg_metodo3_detallado(conn)
        else:
            print("✗ Opción inválida")
            return 1
        
        # Verificar resultados
        verificar_seguimiento(conn)
        
        # Exportar reporte
        respuesta = input("\n¿Desea generar un reporte en archivo de texto? (s/n): ")
        if respuesta.lower() == 's':
            exportar_reporte(conn)
        
        print("\n✓ Proceso completado exitosamente")
        
    except Exception as e:
        print(f"\n✗ Error general: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    finally:
        if 'conn' in locals() and conn:
            conn.close()
            print("\n✓ Conexión cerrada")
    
    return 0


if __name__ == "__main__":
    exit(main())
