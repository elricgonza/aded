import psycopg2
from psycopg2 import sql, Error
import random
from datetime import datetime, timedelta
import sys
from tqdm import tqdm  # Para barra de progreso (opcional)

# Configuración de conexión - AJUSTA ESTOS VALORES
DB_CONFIG = {
    'dbname': 'dbaded1',
    'user': 'uaded',
    'password': 'paded',
    'host': 'localhost',
    'port': '5432'
}

class PobladorSEG:
    def __init__(self, db_config):
        self.db_config = db_config
        self.conn = None
        self.cursor = None
        
    def conectar(self):
        """Establece conexión con la base de datos"""
        try:
            self.conn = psycopg2.connect(**self.db_config)
            self.cursor = self.conn.cursor()
            print("✅ Conexión establecida con PostgreSQL")
            return True
        except Error as e:
            print(f"❌ Error de conexión: {e}")
            return False
    
    def desconectar(self):
        """Cierra la conexión"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            print("🔌 Conexión cerrada")
    
    def verificar_tablas(self):
        """Verifica que todas las tablas necesarias existan"""
        tablas = ['insc', 'alum', 'cur', 'mat', 'asig', 'prof']
        
        print("\n🔍 Verificando tablas existentes...")
        for tabla in tablas:
            try:
                self.cursor.execute("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_name = %s
                    );
                """, (tabla,))
                existe = self.cursor.fetchone()[0]
                if existe:
                    # Obtener cantidad de registros
                    self.cursor.execute(f"SELECT COUNT(*) FROM {tabla}")
                    count = self.cursor.fetchone()[0]
                    print(f"   ✅ Tabla '{tabla}' existe ({count} registros)")
                else:
                    print(f"   ❌ Tabla '{tabla}' NO existe")
                    return False
            except Error as e:
                print(f"   ❌ Error verificando tabla '{tabla}': {e}")
                return False
        return True
    
    def obtener_inscripciones(self):
        """Obtiene todas las inscripciones con información del curso"""
        self.cursor.execute("""
            SELECT 
                i.id as insc_id,
                i.alum_id,
                i.cur_id,
                i.fecha_insc,
                a.nombre as alum_nombre,
                a.apellido as alum_apellido,
                c.gra_id,
                c.paralelo,
                c.gestion,
                c.fecha_ini,
                c.fecha_fin
            FROM insc i
            JOIN alum a ON i.alum_id = a.id
            JOIN cur c ON i.cur_id = c.id
            ORDER BY i.id
        """)
        
        inscripciones = self.cursor.fetchall()
        print(f"\n📊 Total inscripciones encontradas: {len(inscripciones)}")
        return inscripciones
    
    def obtener_materias_por_curso(self):
        """Obtiene las materias asignadas a cada curso"""
        self.cursor.execute("""
            SELECT 
                a.cur_id,
                a.mat_id,
                m.materia,
                m.gra_id as materia_grado,
                p.nombre as prof_nombre,
                p.apellido as prof_apellido
            FROM asig a
            JOIN mat m ON a.mat_id = m.id
            LEFT JOIN prof p ON a.prof_id = p.id
            ORDER BY a.cur_id, m.materia
        """)
        
        materias_por_curso = {}
        resultados = self.cursor.fetchall()
        
        for row in resultados:
            cur_id = row[0]
            if cur_id not in materias_por_curso:
                materias_por_curso[cur_id] = []
            
            materias_por_curso[cur_id].append({
                'mat_id': row[1],
                'materia': row[2],
                'materia_grado': row[3],
                'profesor': f"{row[4]} {row[5]}" if row[4] else "Sin asignar"
            })
        
        total_materias = sum(len(materias) for materias in materias_por_curso.values())
        print(f"📊 Cursos con materias asignadas: {len(materias_por_curso)}")
        print(f"📊 Total asignaciones materia-curso: {total_materias}")
        
        return materias_por_curso
    
    def calcular_estado_curso(self, fecha_ini, fecha_fin):
        """
        Determina el estado del curso basado en las fechas
        Retorna: 'futuro', 'en_curso', 'finalizado'
        """
        hoy = datetime.now().date()
        
        if not fecha_ini:
            return 'sin_fecha'
        
        if fecha_ini > hoy:
            return 'futuro'
        elif fecha_fin and fecha_fin < hoy:
            return 'finalizado'
        else:
            return 'en_curso'
    
    def generar_notas(self, estado_curso, semanas_transcurridas=None):
        """
        Genera notas realistas según el estado del curso
        """
        if estado_curso == 'futuro':
            # Curso aún no comenzó - todas las notas NULL
            return None, None, None, None
        
        elif estado_curso == 'finalizado':
            # Curso terminado - notas definidas
            # 70% aprueban, 30% reprueban
            aprobado = random.random() < 0.7
            
            if aprobado:
                # Notas de aprobación (60-100)
                ev01 = random.randint(60, 100)
                ev02 = random.randint(60, 100)
                evfin = random.randint(60, 100)
                aprob = 1
            else:
                # Notas de reprobación (0-59)
                ev01 = random.randint(0, 59)
                ev02 = random.randint(0, 59)
                evfin = random.randint(0, 59)
                aprob = 0
            
            return ev01, ev02, evfin, aprob
        
        elif estado_curso == 'en_curso':
            # Curso en progreso - notas parciales
            if semanas_transcurridas is None:
                semanas_transcurridas = random.randint(1, 16)
            
            if semanas_transcurridas < 5:
                # Primer bimestre: solo EV01 disponible
                ev01 = random.randint(0, 100) if random.random() < 0.9 else None
                ev02 = None
                evfin = None
                aprob = None
            elif semanas_transcurridas < 10:
                # Segundo bimestre: EV01 y EV02 disponibles
                ev01 = random.randint(0, 100) if random.random() < 0.95 else None
                ev02 = random.randint(0, 100) if random.random() < 0.9 else None
                evfin = None
                aprob = None
            else:
                # Tercer bimestre en adelante: todas las evaluaciones
                ev01 = random.randint(0, 100) if random.random() < 0.98 else None
                ev02 = random.randint(0, 100) if random.random() < 0.95 else None
                evfin = random.randint(0, 100) if random.random() < 0.8 else None
                aprob = None
                
                # Si ya tiene las 3 notas, calcular aprobación
                if ev01 is not None and ev02 is not None and evfin is not None:
                    promedio = (ev01 + ev02 + evfin) / 3
                    aprob = 1 if promedio >= 60 else 0
            
            return ev01, ev02, evfin, aprob
        
        else:  # sin_fecha
            # Curso sin fechas definidas
            return None, None, None, None
    
    def registrar_ya_existe(self, insc_id, mat_id):
        """Verifica si ya existe un registro SEG para esta inscripción y materia"""
        self.cursor.execute("""
            SELECT id FROM seg 
            WHERE insc_id = %s AND mat_id = %s
        """, (insc_id, mat_id))
        return self.cursor.fetchone() is not None
    
    def insertar_registro_seg(self, insc_id, mat_id, ev01, ev02, evfin, aprob):
        """Inserta un registro en la tabla SEG"""
        try:
            self.cursor.execute("""
                INSERT INTO seg (insc_id, mat_id, ev01, ev02, evfin, aprob)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (insc_id, mat_id, ev01, ev02, evfin, aprob))
            return self.cursor.fetchone()[0]
        except Error as e:
            print(f"   ❌ Error al insertar (insc={insc_id}, mat={mat_id}): {e}")
            return None
    
    def calcular_semanas_transcurridas(self, fecha_ini, fecha_insc=None):
        """Calcula las semanas transcurridas desde el inicio del curso"""
        hoy = datetime.now().date()
        
        if fecha_ini and fecha_ini <= hoy:
            if fecha_insc:
                # Si hay fecha de inscripción, considerar desde la inscripción
                fecha_inicio = max(fecha_ini, fecha_insc)
            else:
                fecha_inicio = fecha_ini
            
            dias_transcurridos = (hoy - fecha_inicio).days
            return max(1, dias_transcurridos // 7)  # Mínimo 1 semana
        return 1
    
    def poblar_seg(self, limpiar_existentes=False, batch_size=500):
        """Pobla la tabla SEG con datos de seguimiento"""
        
        if limpiar_existentes:
            print("\n🗑️ Eliminando registros existentes en SEG...")
            self.cursor.execute("SELECT COUNT(*) FROM seg")
            existentes = self.cursor.fetchone()[0]
            if existentes > 0:
                self.cursor.execute("DELETE FROM seg")
                self.conn.commit()
                print(f"   ✅ Se eliminaron {existentes} registros")
        
        # Obtener datos necesarios
        inscripciones = self.obtener_inscripciones()
        materias_por_curso = self.obtener_materias_por_curso()
        
        if not inscripciones:
            print("⚠️ No hay inscripciones para procesar")
            return 0
        
        # Preparar datos a insertar
        datos_insertar = []
        cursos_sin_materias = set()
        
        print("\n🔄 Procesando inscripciones...")
        
        for insc in inscripciones:
            insc_id = insc[0]
            cur_id = insc[2]
            fecha_insc = insc[3]
            fecha_ini_curso = insc[9]
            fecha_fin_curso = insc[10]
            
            # Verificar si el curso tiene materias asignadas
            if cur_id not in materias_por_curso:
                cursos_sin_materias.add(cur_id)
                continue
            
            # Determinar estado del curso
            estado_curso = self.calcular_estado_curso(fecha_ini_curso, fecha_fin_curso)
            
            # Calcular semanas transcurridas si el curso está en progreso
            semanas = None
            if estado_curso == 'en_curso':
                semanas = self.calcular_semanas_transcurridas(fecha_ini_curso, fecha_insc)
            
            # Generar notas para cada materia
            for materia_info in materias_por_curso[cur_id]:
                mat_id = materia_info['mat_id']
                
                # Verificar si ya existe (si no estamos limpiando)
                if not limpiar_existentes and self.registrar_ya_existe(insc_id, mat_id):
                    continue
                
                # Generar notas
                ev01, ev02, evfin, aprob = self.generar_notas(estado_curso, semanas)
                
                datos_insertar.append({
                    'insc_id': insc_id,
                    'mat_id': mat_id,
                    'ev01': ev01,
                    'ev02': ev02,
                    'evfin': evfin,
                    'aprob': aprob,
                    'materia': materia_info['materia'],
                    'curso': cur_id
                })
        
        # Reportar cursos sin materias
        if cursos_sin_materias:
            print(f"\n⚠️ Advertencia: {len(cursos_sin_materias)} cursos no tienen materias asignadas")
            print(f"   IDs de cursos sin materias: {sorted(list(cursos_sin_materias))[:10]}")
        
        total_esperado = len(datos_insertar)
        print(f"\n📊 Total de registros SEG a crear: {total_esperado}")
        
        if total_esperado == 0:
            print("⚠️ No hay registros para insertar")
            return 0
        
        # Insertar en batches
        insertados = 0
        errores = 0
        
        print(f"\n💾 Insertando registros (batch size: {batch_size})...")
        
        for i in range(0, len(datos_insertar), batch_size):
            batch = datos_insertar[i:i + batch_size]
            
            try:
                for seg in batch:
                    seg_id = self.insertar_registro_seg(
                        seg['insc_id'],
                        seg['mat_id'],
                        seg['ev01'],
                        seg['ev02'],
                        seg['evfin'],
                        seg['aprob']
                    )
                    
                    if seg_id:
                        insertados += 1
                    else:
                        errores += 1
                
                # Commit después de cada batch
                self.conn.commit()
                
                # Mostrar progreso
                progreso = (i + len(batch)) / total_esperado * 100
                print(f"   Progreso: {insertados}/{total_esperado} registros ({progreso:.1f}%)")
                
            except Error as e:
                print(f"   ❌ Error en batch: {e}")
                self.conn.rollback()
                errores += len(batch)
        
        print(f"\n✅ ¡Completado!")
        print(f"   ✅ Registros insertados: {insertados}")
        if errores > 0:
            print(f"   ⚠️ Registros con error: {errores}")
        
        return insertados
    
    def mostrar_resumen(self):
        """Muestra un resumen estadístico de los datos insertados"""
        
        print("\n" + "=" * 70)
        print("📊 RESUMEN ESTADÍSTICO - TABLA SEG")
        print("=" * 70)
        
        # Total de registros
        self.cursor.execute("SELECT COUNT(*) FROM seg")
        total = self.cursor.fetchone()[0]
        print(f"\n📌 Total registros en SEG: {total}")
        
        if total == 0:
            print("⚠️ No hay registros para mostrar")
            return
        
        # Estadísticas generales
        self.cursor.execute("""
            SELECT 
                COUNT(*) as total,
                COUNT(ev01) as con_ev01,
                COUNT(ev02) as con_ev02,
                COUNT(evfin) as con_evfin,
                ROUND(AVG(ev01), 2) as prom_ev01,
                ROUND(AVG(ev02), 2) as prom_ev02,
                ROUND(AVG(evfin), 2) as prom_evfin,
                COUNT(CASE WHEN aprob = 1 THEN 1 END) as aprobados,
                COUNT(CASE WHEN aprob = 0 THEN 1 END) as reprobados,
                COUNT(CASE WHEN aprob IS NULL THEN 1 END) as sin_definir
            FROM seg
        """)
        
        stats = self.cursor.fetchone()
        
        print(f"\n📈 Estadísticas generales:")
        print(f"   Registros con EV01: {stats[1]} ({stats[1]*100/stats[0]:.1f}%) - Promedio: {stats[4] or 'N/A'}")
        print(f"   Registros con EV02: {stats[2]} ({stats[2]*100/stats[0]:.1f}%) - Promedio: {stats[5] or 'N/A'}")
        print(f"   Registros con EVFIN: {stats[3]} ({stats[3]*100/stats[0]:.1f}%) - Promedio: {stats[6] or 'N/A'}")
        
        # Distribución de aprobación
        print(f"\n📊 Distribución de aprobación:")
        print(f"   Aprobados: {stats[7] or 0} ({((stats[7] or 0)*100/stats[0]):.1f}%)")
        print(f"   Reprobados: {stats[8] or 0} ({((stats[8] or 0)*100/stats[0]):.1f}%)")
        print(f"   Sin definir: {stats[9] or 0} ({((stats[9] or 0)*100/stats[0]):.1f}%)")
        
        # Top 5 materias con mejor rendimiento
        self.cursor.execute("""
            SELECT 
                m.materia,
                COUNT(s.id) as total_inscripciones,
                ROUND(AVG((s.ev01 + s.ev02 + s.evfin) / 3), 2) as promedio_general,
                ROUND(COUNT(CASE WHEN s.aprob = 1 THEN 1 END) * 100.0 / NULLIF(COUNT(CASE WHEN s.aprob IS NOT NULL THEN 1 END), 0), 2) as tasa_aprobacion
            FROM seg s
            JOIN mat m ON s.mat_id = m.id
            WHERE s.ev01 IS NOT NULL AND s.ev02 IS NOT NULL AND s.evfin IS NOT NULL
            GROUP BY m.id, m.materia
            ORDER BY promedio_general DESC
            LIMIT 5
        """)
        
        top_materias = self.cursor.fetchall()
        if top_materias:
            print(f"\n🏆 Top 5 materias con mejor rendimiento:")
            for row in top_materias:
                print(f"   📚 {row[0]}: Promedio={row[2]}, Aprobación={row[3]}% ({row[1]} alumnos)")
        
        # Distribución por estado de curso
        self.cursor.execute("""
            SELECT 
                CASE 
                    WHEN c.fecha_ini > CURRENT_DATE THEN 'Futuro'
                    WHEN c.fecha_fin < CURRENT_DATE THEN 'Finalizado'
                    ELSE 'En curso'
                END as estado_curso,
                COUNT(s.id) as total_registros,
                ROUND(AVG(CASE WHEN s.aprob IS NOT NULL THEN 1 ELSE 0 END) * 100, 2) as porcentaje_definidos
            FROM seg s
            JOIN insc i ON s.insc_id = i.id
            JOIN cur c ON i.cur_id = c.id
            GROUP BY estado_curso
            ORDER BY total_registros DESC
        """)
        
        print(f"\n📅 Distribución por estado del curso:")
        for row in self.cursor.fetchall():
            print(f"   {row[0]}: {row[1]} registros - {row[2]}% con notas definidas")

def main():
    """Función principal"""
    
    print("=" * 70)
    print("🚀 SCRIPT DE POBLADO DE TABLA SEG (SEGUIMIENTO ACADÉMICO)")
    print("=" * 70)
    
    # Crear instancia del poblador
    poblador = PobladorSEG(DB_CONFIG)
    
    # Conectar a la base de datos
    if not poblador.conectar():
        sys.exit(1)
    
    try:
        # Verificar tablas
        if not poblador.verificar_tablas():
            print("\n❌ No se pueden continuar porque faltan tablas")
            sys.exit(1)
        
        # Configuración
        print("\n⚙️ Configuración:")
        
        # Preguntar si limpiar datos existentes
        limpiar = input("¿Eliminar registros existentes en SEG? (s/n): ").lower() == 's'
        
        # Preguntar tamaño de batch
        try:
            batch_size = int(input("Tamaño de batch (Enter para 500): ") or "500")
            if batch_size <= 0:
                batch_size = 500
        except ValueError:
            batch_size = 500
        
        print(f"\n{'='*70}")
        print("🚀 Iniciando proceso de población...")
        print(f"{'='*70}")
        
        # Poblar la tabla SEG
        total_insertados = poblador.poblar_seg(
            limpiar_existentes=limpiar,
            batch_size=batch_size
        )
        
        if total_insertados > 0:
            # Mostrar resumen estadístico
            poblador.mostrar_resumen()
        
    except KeyboardInterrupt:
        print("\n⚠️ Proceso interrumpido por el usuario")
        if poblador.conn:
            poblador.conn.rollback()
    except Exception as e:
        print(f"\n❌ Error inesperado: {e}")
        import traceback
        traceback.print_exc()
        if poblador.conn:
            poblador.conn.rollback()
    finally:
        poblador.desconectar()

if __name__ == "__main__":
    # Configurar semilla para reproducibilidad (opcional)
    # random.seed(42)  # Descomentar para resultados reproducibles
    main()
