import psycopg2
from psycopg2 import sql, Error
import random
from datetime import datetime, timedelta
from collections import defaultdict

# Configuración de conexión - AJUSTA ESTOS VALORES
DB_CONFIG = {
    'dbname': 'dbaded1',
    'user': 'uaded',
    'password': 'paded',
    'host': 'localhost',
    'port': '5432'
}

def verificar_tablas(cursor):
    """Verifica que las tablas necesarias existan y tengan datos"""
    
    # Verificar tabla ALUM
    cursor.execute("SELECT COUNT(*) FROM alum")
    total_alumnos = cursor.fetchone()[0]
    print(f"📊 Total alumnos disponibles: {total_alumnos}")
    
    if total_alumnos == 0:
        raise Exception("❌ No hay alumnos en la tabla ALUM. Primero debes poblar ALUM.")
    
    # Verificar tabla CUR
    cursor.execute("""
        SELECT c.id, c.gra_id, c.paralelo, c.gestion, 
               COUNT(i.id) as inscritos_actuales
        FROM cur c
        LEFT JOIN insc i ON c.id = i.cur_id
        GROUP BY c.id, c.gra_id, c.paralelo, c.gestion
        ORDER BY c.id
    """)
    
    cursos = cursor.fetchall()
    print(f"📊 Total cursos disponibles: {len(cursos)}")
    
    if len(cursos) == 0:
        raise Exception("❌ No hay cursos en la tabla CUR. Primero debes poblar CUR.")
    
    # Mostrar información de cursos
    print("\n📋 Cursos disponibles:")
    for curso in cursos:
        print(f"   Curso ID: {curso[0]} - Grado: {curso[1]} - Paralelo: {curso[2]} - Gestión: {curso[3]} - Inscritos actuales: {curso[4]}")
    
    return cursos, total_alumnos

def generar_distribucion_alumnos(cursos, total_alumnos, promedio_deseado=45):
    """
    Distribuye los alumnos entre los cursos
    Retorna un diccionario {curso_id: [lista_alumnos_ids]}
    """
    
    num_cursos = len(cursos)
    total_alumnos_a_inscribir = min(total_alumnos, num_cursos * promedio_deseado)
    
    print(f"\n🔄 Planificando distribución de {total_alumnos_a_inscribir} alumnos en {num_cursos} cursos...")
    
    # Obtener lista de todos los IDs de alumnos
    cursor.execute("SELECT id FROM alum ORDER BY id")
    todos_alumnos = [row[0] for row in cursor.fetchall()]
    
    # Mezclar aleatoriamente los alumnos
    random.shuffle(todos_alumnos)
    
    # Calcular distribución
    alumnos_por_curso = total_alumnos_a_inscribir // num_cursos
    alumnos_extra = total_alumnos_a_inscribir % num_cursos
    
    print(f"   📈 Alumnos por curso (base): {alumnos_por_curso}")
    print(f"   🔢 Cursos con 1 alumno extra: {alumnos_extra}")
    
    # Distribuir alumnos
    distribucion = {}
    indice_alumno = 0
    
    for i, curso in enumerate(cursos):
        curso_id = curso[0]
        # Asignar alumnos base + posible extra
        cantidad_para_este_curso = alumnos_por_curso + (1 if i < alumnos_extra else 0)
        
        # Seleccionar alumnos para este curso
        alumnos_asignados = todos_alumnos[indice_alumno:indice_alumno + cantidad_para_este_curso]
        distribucion[curso_id] = alumnos_asignados
        indice_alumno += cantidad_para_este_curso
        
        print(f"   Curso {curso_id}: {len(alumnos_asignados)} alumnos asignados")
    
    return distribucion

def generar_fecha_inscripcion(curso):
    """
    Genera una fecha de inscripción válida dentro del rango del curso
    curso: tupla con (id, gra_id, paralelo, gestion, fecha_ini, fecha_fin, inscritos_actuales)
    """
    fecha_ini = curso[4]
    fecha_fin = curso[5]
    
    if fecha_ini and fecha_fin:
        # Generar fecha aleatoria entre fecha_ini y fecha_fin
        dias_diferencia = (fecha_fin - fecha_ini).days
        dias_aleatorios = random.randint(0, max(0, dias_diferencia))
        fecha_insc = fecha_ini + timedelta(days=dias_aleatorios)
    else:
        # Si no hay fechas definidas, usar fecha actual
        fecha_insc = datetime.now().date()
    
    return fecha_insc

def insertar_inscripciones(distribucion, cursos_info):
    """Inserta las inscripciones en la base de datos"""
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("\n💾 Insertando inscripciones...")
        
        total_inscritos = 0
        inscripciones_por_curso = defaultdict(int)
        
        # Diccionario para acceder rápido a la información del curso
        cursos_dict = {curso[0]: curso for curso in cursos_info}
        
        for curso_id, alumnos_ids in distribucion.items():
            curso_info = cursos_dict[curso_id]
            
            for alumno_id in alumnos_ids:
                # Verificar que el alumno no esté ya inscrito en este curso
                cursor.execute("""
                    SELECT id FROM insc 
                    WHERE alum_id = %s AND cur_id = %s
                """, (alumno_id, curso_id))
                
                if cursor.fetchone():
                    print(f"   ⚠️ Alumno {alumno_id} ya está inscrito en curso {curso_id}, omitiendo...")
                    continue
                
                # Generar fecha de inscripción
                fecha_insc = generar_fecha_inscripcion(curso_info)
                
                # Insertar inscripción
                cursor.execute("""
                    INSERT INTO insc (alum_id, cur_id, fecha_insc)
                    VALUES (%s, %s, %s)
                    RETURNING id
                """, (alumno_id, curso_id, fecha_insc))
                
                insc_id = cursor.fetchone()[0]
                total_inscritos += 1
                inscripciones_por_curso[curso_id] += 1
                
                # Mostrar progreso cada 100 inscripciones
                if total_inscritos % 100 == 0:
                    print(f"   Progreso: {total_inscritos} inscripciones realizadas...")
        
        # Confirmar transacción
        conn.commit()
        
        print(f"\n✅ ¡Éxito! Se insertaron {total_inscritos} inscripciones")
        
        # Mostrar resumen por curso
        print("\n📊 Resumen de inscripciones por curso:")
        for curso_id, cantidad in inscripciones_por_curso.items():
            print(f"   Curso {curso_id}: {cantidad} alumnos inscritos")
        
        return total_inscritos
        
    except Error as e:
        print(f"❌ Error de PostgreSQL: {e}")
        if conn:
            conn.rollback()
        return 0
    except Exception as e:
        print(f"❌ Error general: {e}")
        if conn:
            conn.rollback()
        return 0
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
            print("🔌 Conexión cerrada")

def limpiar_inscripciones_existentes(confirmar=False):
    """
    Opcional: Limpiar inscripciones existentes antes de insertar nuevas
    """
    if not confirmar:
        return
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM insc")
        total_existentes = cursor.fetchone()[0]
        
        if total_existentes > 0:
            respuesta = input(f"⚠️ Hay {total_existentes} inscripciones existentes. ¿Eliminar? (s/n): ")
            if respuesta.lower() == 's':
                cursor.execute("DELETE FROM insc")
                conn.commit()
                print(f"🗑️ Se eliminaron {total_existentes} inscripciones existentes")
        
    except Exception as e:
        print(f"Error al limpiar: {e}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

def main():
    """Función principal"""
    
    print("=" * 60)
    print("🚀 SCRIPT DE POBLADO DE INSCRIPCIONES")
    print("=" * 60)
    
    # Preguntar si limpiar inscripciones existentes
    limpiar = input("\n¿Deseas eliminar inscripciones existentes antes de continuar? (s/n): ").lower() == 's'
    if limpiar:
        limpiar_inscripciones_existentes(confirmar=True)
    
    try:
        # Conectar y verificar tablas
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Verificar tablas y obtener información
        global cursor_global
        cursor_global = cursor
        cursos_info, total_alumnos = verificar_tablas(cursor)
        
        # Preguntar promedio deseado
        try:
            promedio = int(input(f"\n📈 ¿Cuál es el promedio de alumnos por curso deseado? (Enter para 45): ") or "45")
        except ValueError:
            promedio = 45
            print(f"   Usando promedio por defecto: {promedio}")
        
        # Generar distribución de alumnos
        distribucion = generar_distribucion_alumnos(cursos_info, total_alumnos, promedio)
        
        # Cerrar cursor de verificación (la conexión se reabrirá en insertar_inscripciones)
        cursor.close()
        conn.close()
        
        # Insertar inscripciones
        total_insertados = insertar_inscripciones(distribucion, cursos_info)
        
        # Mostrar estadísticas finales
        print("\n" + "=" * 60)
        print("📈 ESTADÍSTICAS FINALES")
        print("=" * 60)
        
        # Reabrir conexión para verificar resultados
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT 
                c.id as curso_id,
                c.gra_id as grado,
                c.paralelo,
                c.gestion,
                COUNT(i.id) as total_inscritos
            FROM cur c
            LEFT JOIN insc i ON c.id = i.cur_id
            GROUP BY c.id, c.gra_id, c.paralelo, c.gestion
            ORDER BY total_inscritos DESC
        """)
        
        resultados = cursor.fetchall()
        print("\n📊 Inscripciones finales por curso:")
        total_general = 0
        for r in resultados:
            print(f"   Curso {r[0]} (Grado {r[1]} {r[2]} - {r[3]}): {r[4]} alumnos")
            total_general += r[4]
        
        print(f"\n   TOTAL GENERAL: {total_general} inscripciones")
        
        # Mostrar distribución de fechas
        cursor.execute("""
            SELECT 
                MIN(fecha_insc) as fecha_min,
                MAX(fecha_insc) as fecha_max,
                COUNT(*) as total
            FROM insc
        """)
        fechas = cursor.fetchone()
        print(f"\n📅 Rango de fechas de inscripción:")
        print(f"   Desde: {fechas[0]}")
        print(f"   Hasta: {fechas[1]}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error en la ejecución principal: {e}")

if __name__ == "__main__":
    # Configurar semilla aleatoria para reproducibilidad
    random.seed(42)  # Puedes cambiar o quitar esta línea
    
    main()
