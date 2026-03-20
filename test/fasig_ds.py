import psycopg2
from psycopg2 import sql, Error
import random
from datetime import datetime, timedelta
from decimal import Decimal
import sys

# Configuración de conexión - AJUSTA ESTOS VALORES
DB_CONFIG = {
    'dbname': 'dbaded1',
    'user': 'uaded',
    'password': 'paded',
    'host': 'localhost',
    'port': '5432'
}

class SeguimientoPoblar:
    def __init__(self, db_config):
        self.db_config = db_config
        self.conn = None
        self.cursor = None
        
    def conectar(self):
        """Establece conexión con la base de datos"""
        try:
            self.conn = psycopg2.connect(**self.db_config)
            self.cursor = self.conn.cursor()
            print("✅ Conexión establecida")
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
    
    def verificar_estructura(self):
        """Verifica que las tablas necesarias existan"""
        tablas_necesarias = ['insc', 'alum', 'cur', 'mat', 'asig', 'prof']
        
        for tabla in tablas_necesarias:
            self.cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_name = %s
                );
            """, (tabla,))
            if not self.cursor.fetchone()[0]:
                print(f"❌ La tabla '{tabla}' no existe")
                return False
            print(f"✅ Tabla '{tabla}' existe")
        
        return True
    
    def obtener_datos_inscripciones(self):
        """Obtiene todas las inscripciones con sus datos relacionados"""
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
        print(f"📊 Total inscripciones encontradas: {len(inscripciones)}")
        return inscripciones
    
    def obtener_materias_por_curso(self):
        """Obtiene las materias asignadas a cada curso"""
        self.cursor.execute("""
            SELECT 
                a.cur_id,
                a.mat_id,
                a.prof_id,
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
                'prof_id': row[2],
                'materia': row[3],
                'materia_grado': row[4],
                'profesor': f"{row[5]} {row[6]}" if row[5] else "Sin asignar"
            })
        
        total_materias = sum(len(materias) for materias in materias_por_curso.values())
        print(f"📊 Total cursos con materias asignadas: {len(materias_por_curso)}")
        print(f"📊 Total asignaciones materia-curso: {total_materias}")
        
        return materias_por_curso
    
    def generar_nota(self, fecha_insc, fecha_ini_curso, fecha_fin_curso):
        """Genera notas realistas basadas en fechas y probabilidades"""
        
        # Determinar si el curso ya comenzó
        hoy = datetime.now().date()
        
        if fecha_fin_curso and fecha_fin_curso < hoy:
            # Curso terminado - notas definidas
            # 70% aprueban, 30% reprueban
            aprobado = random.random() < 0.7
            if aprobado:
                ev01 = random.randint(60, 100)
                ev02 = random.randint(60, 100)
                evfin = random.randint(60, 100)
                aprob = 1
            else:
                ev01 = random.randint(0, 59)
                ev02 = random.randint(0, 59)
                evfin = random.randint(0, 59)
                aprob = 0
        elif fecha_ini_curso and fecha_ini_curso > hoy:
            # Curso futuro - sin notas
            ev01 = None
            ev02 = None
            evfin = None
            aprob = None
        else:
            # Curso en progreso - algunas notas pueden existir
            semanas_transcurridas = (hoy - fecha_ini_curso).days // 7 if fecha_ini_curso else 0
            
            if semanas_transcurridas < 4:
                # Solo primera evaluación
                ev01 = random.randint(0, 100) if random.random() < 0.8 else None
                ev02 = None
                evfin = None
                aprob = None
            elif semanas_transcurridas < 8:
                # Dos evaluaciones
                ev01 = random.randint(0, 100) if random.random() < 0.9 else None
                ev02 = random.randint(0, 100) if random.random() < 0.7 else None
                evfin = None
                aprob = None
            else:
                # Todas las evaluaciones
                ev01 = random.randint(0, 100) if random.random() < 0.95 else None
                ev02 = random.randint(0, 100) if random.random() < 0.9 else None
                evfin = random.randint(0, 100) if random.random() < 0.8 else None
                aprob = None
            
            # Si ya tiene las 3 notas, calcular aprobación
            if ev01 is not None and ev02 is not None and evfin is not None:
                promedio = (ev01 + ev02 + evfin) / 3
                aprob = 1 if promedio >= 60 else 0
        
        return ev01, ev02, evfin, aprob
    
    def verificar_registro_existente(self, insc_id, mat_id):
        """Verifica si ya existe un registro SEG para esta inscripción y materia"""
        self.cursor.execute("""
            SELECT id FROM seg 
            WHERE insc_id = %s AND mat_id = %s
        """, (insc_id, mat_id))
        
        return self.cursor.fetchone() is not None
    
    def insertar_seguimiento(self, insc_id, mat_id, ev01, ev02, evfin, aprob):
        """Inserta un registro en la tabla SEG"""
        try:
            self.cursor.execute("""
                INSERT INTO seg (insc_id, mat_id, ev01, ev02, evfin, aprob)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (insc_id, mat_id, ev01, ev02, evfin, aprob))
            
            return self.cursor.fetchone()[0]
        except Error as e:
            print(f"   ❌ Error al insertar seg (insc_id={insc_id}, mat_id={mat_id}): {e}")
            return None
    
    def poblar_seguimiento(self, batch_size=1000, limpiar_existentes=False):
        """Pobla la tabla SEG con datos de seguimiento"""
        
        if limpiar_existentes:
            print("🗑️ Limpiando registros existentes en SEG...")
            self.cursor.execute("DELETE FROM seg")
            self.conn.commit()
            print("   ✅ Limpieza completada")
        
        # Obtener datos necesarios
        print("\n📥 Obteniendo inscripciones...")
        inscripciones = self.obtener_datos_inscripciones()
        
        print("\n📥 Obteniendo materias por curso...")
        materias_por_curso = self.obtener_materias_por_curso()
        
        # Preparar estructura para seguimiento
        seguimientos = []
        total_esperado = 0
        
        print("\n🔄 Preparando datos de seguimiento...")
        
        for insc in inscripciones:
            insc_id = insc[0]
            cur_id = insc[2]
            fecha_insc = insc[3]
            fecha_ini_curso = insc[9]
            fecha_fin_curso = insc[10]
            
            if cur_id not in materias_por_curso:
                print(f"   ⚠️ Curso {cur_id} no tiene materias asignadas - omitiendo inscripción {insc_id}")
                continue
            
            materias_del_curso = materias_por_curso[cur_id]
            
            for materia_info in materias_del_curso:
                mat_id = materia_info['mat_id']
                
                # Verificar si ya existe
                if not limpiar_existentes and self.verificar_registro_existente(insc_id, mat_id):
                    continue
                
                # Generar notas
                ev01, ev02, evfin, aprob = self.generar_nota(
                    fecha_insc, fecha_ini_curso, fecha_fin_curso
                )
                
                seguimientos.append({
                    'insc_id': insc_id,
                    'mat_id': mat_id,
                    'ev01': ev01,
                    'ev02': ev02,
                    'evfin': evfin,
                    'aprob': aprob,
                    'materia': materia_info['materia']
                })
                total_esperado += 1
        
        print(f"\n📊 Total de registros SEG a crear: {total_esperado}")
        
        if total_esperado == 0:
            print("⚠️ No hay registros para insertar")
            return 0
        
        # Insertar en batches
        insertados = 0
        errores = 0
        
        print("\n💾 Insertando registros en batches...")
        
        for i in range(0, len(seguimientos), batch_size):
            batch = seguimientos[i:i + batch_size]
            
            try:
                for seg in batch:
                    seg_id = self.insertar_seguimiento(
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
                    
                    # Mostrar progreso
                    if insertados % 100 == 0:
                        print(f"   Progreso: {insertados}/{total_esperado} registros...")
                
                # Commit después de cada batch
                self.conn.commit()
                print(f"   ✅ Batch {i//batch_size + 1} completado")
                
            except Error as e:
                print(f"   ❌ Error en batch {i//batch_size + 1}: {e}")
                self.conn.rollback()
                errores += len(batch)
        
        print(f"\n✅ ¡Completado! Se insertaron {insertados} registros")
        if errores > 0:
            print(f"⚠️ Errores: {errores} registros no insertados")
        
        return insertados
    
    def generar_resumen_estadistico(self):
        """Genera un resumen estadístico de los datos insertados"""
        
        print("\n" + "=" * 60)
        print("📊 RESUMEN ESTADÍSTICO DE SEGUIMIENTO")
        print("=" * 60)
        
        # Total de registros
        self.cursor.execute("SELECT COUNT(*) FROM seg")
        total = self.cursor.fetchone()[0]
        print(f"\n📌 Total registros SEG: {total}")
        
        # Promedios generales
        self.cursor.execute("""
            SELECT 
                COUNT(*) as total_evaluaciones,
                ROUND(AVG(ev01), 2) as prom_ev01,
                ROUND(AVG(ev02), 2) as prom_ev02,
                ROUND(AVG(evfin), 2) as prom_evfin,
                ROUND(COUNT(CASE WHEN aprob = 1 THEN 1 END) * 100.0 / COUNT(*), 2) as porcentaje_aprobacion
            FROM seg
            WHERE ev01 IS NOT NULL OR ev02 IS NOT NULL OR evfin IS NOT NULL
        """)
        
        stats = self.cursor.fetchone()
        print(f"\n📈 Estadísticas generales (solo registros con notas):")
        print(f"   Total evaluaciones consideradas: {stats[0]}")
        print(f"   Promedio EV01: {stats[1] if stats[1] else 'N/A'}")
        print(f"   Promedio EV02: {stats[2] if stats[2] else 'N/A'}")
        print(f"   Promedio EVFIN: {stats[3] if stats[3] else 'N/A'}")
        print(f"   Tasa de aprobación: {stats[4] if stats[4] else 'N/A'}%")
        
        # Top 5 materias con mejor rendimiento
        self.cursor.execute("""
            SELECT 
                m.materia,
                COUNT(s.id) as total_inscripciones,
                ROUND(AVG((s.ev01 + s.ev02 + s.evfin) / 3), 2) as promedio_general,
                ROUND(COUNT(CASE WHEN s.aprob = 1 THEN 1 END) * 100.0 / COUNT(s.id), 2) as tasa_aprobacion
            FROM seg s
            JOIN mat m ON s.mat_id = m.id
            WHERE s.ev01 IS NOT NULL AND s.ev02 IS NOT NULL AND s.evfin IS NOT NULL
            GROUP BY m.id, m.materia
            ORDER BY promedio_general DESC
            LIMIT 5
        """)
        
        print(f"\n🏆 Top 5 materias con mejor rendimiento:")
        for row in self.cursor.fetchall():
            print(f"   {row[0]}: Promedio={row[2]}, Aprobación={row[3]}% ({row[1]} alumnos)")
        
        # Distribución de aprobación
        self.cursor.execute("""
            SELECT 
                CASE 
                    WHEN aprob = 1 THEN 'Aprobado'
                    WHEN aprob = 0 THEN 'Reprobado'
                    ELSE 'Sin definir'
                END as estado,
                COUNT(*) as cantidad,
                ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM seg), 2) as porcentaje
            FROM seg
            GROUP BY estado
            ORDER BY cantidad DESC
        """)
        
        print(f"\n📊 Distribución de aprobación:")
        for row in self.cursor.fetchall():
            print(f"   {row[0]}: {row[1]} ({row[2]}%)")

def main():
    """Función principal"""
    
    print("=" * 60)
    print("🚀 SCRIPT DE POBLADO DE TABLA SEG (SEGUIMIENTO)")
    print("=" * 60)
    
    # Crear instancia
    poblar = SeguimientoPoblar(DB_CONFIG)
    
    # Conectar
    if not poblar.conectar():
        sys.exit(1)
    
    try:
        # Verificar estructura
        print("\n🔍 Verificando estructura de la base de datos...")
        if not poblar.verificar_estructura():
            sys.exit(1)
        
        # Preguntar si limpiar datos existentes
        limpiar = input("\n¿Deseas eliminar registros existentes en SEG? (s/n): ").lower() == 's'
        
        # Definir tamaño de batch
        try:
            batch_size = int(input("Tamaño de batch para inserción (Enter para 1000): ") or "1000")
        except ValueError:
            batch_size = 1000
        
        # Poblar seguimiento
        total = poblar.poblar_seguimiento(batch_size=batch_size, limpiar_existentes=limpiar)
        
        if total > 0:
            # Generar resumen
            poblar.generar_resumen_estadistico()
        
    except KeyboardInterrupt:
        print("\n⚠️ Proceso interrumpido por el usuario")
        if poblar.conn:
            poblar.conn.rollback()
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
        if poblar.conn:
            poblar.conn.rollback()
    finally:
        poblar.desconectar()

if __name__ == "__main__":
    # Configurar semilla para reproducibilidad
    random.seed(42)
    main()
