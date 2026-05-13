import psycopg2
from psycopg2 import sql
import random
from datetime import datetime, timedelta
from faker import Faker

# Inicializar Faker para datos realistas en español
fake = Faker('es_ES')

# Configuración de la base de datos
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'dbaded',
    'user': 'uaded',
    'password': 'paded'
}

def generate_alumno():
    """Genera un registro de alumno con datos realistas"""
    
    # Fecha de nacimiento entre 15 y 70 años atrás
    años_atras = random.randint(15, 70)
    nacimiento = fake.date_of_birth(minimum_age=15, maximum_age=70)
    
    # Fecha de creación (entre 0 y 5 años atrás)
    creado = fake.date_between(start_date='-5y', end_date='today')
    
    # Fecha de actualización (entre creado y hoy)
    act = fake.date_between(start_date=creado, end_date='today')
    
    # Género (True = masculino, False = femenino)
    masculino = random.choice([True, False])
    
    # Determinar nombre según género
    if masculino:
        nombre = fake.first_name_male()
    else:
        nombre = fake.first_name_female()
    
    # Generar email basado en nombre y apellidos
    paterno = fake.last_name()
    materno = fake.last_name()
    email = f"{nombre.lower()}.{paterno.lower()}@{random.choice(['gmail.com', 'hotmail.com', 'yahoo.com', 'outlook.com'])}"
    

    #    'usu_id': random.randint(1, 100)

    return {
        'nombre': nombre,
        'paterno': paterno,
        'materno': materno,
        'nacimiento': nacimiento,
        'masculino': masculino,
        'ci': random.randint(1000000, 9999999),  # CI entre 1M y 10M
        'direccion': fake.address().replace('\n', ', ')[:150],
        'email': email[:100],
        'activo': random.choice([True, True, True, False]),  # 75% activos
        'obs': fake.sentence(nb_words=10)[:100] if random.random() > 0.7 else None,
        'usr_id_login': random.randint(1, 50) if random.random() > 0.3 else None,
        'foto_ruta': f"/fotos/alumnos/{random.randint(1000, 9999)}.jpg" if random.random() > 0.5 else None,
        'creado': creado,
        'act': act,
        'usu_id': 1  # Asumimos que el usuario con ID 1 es el creador
    }

def insert_alumnos(n=2000, batch_size=100):
    """Inserta n registros en la tabla alumno usando batches"""
    
    conn = None
    cursor = None
    
    try:
        # Conectar a PostgreSQL
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print(f"Conectado a la base de datos: {DB_CONFIG['database']}")
        print(f"Generando {n} registros...")
        
        # SQL para insertar
        insert_query = """
            INSERT INTO alumno (
                nombre, paterno, materno, nacimiento, masculino, ci, 
                direccion, email, activo, obs, usr_id_login, foto_ruta, 
                creado, act, usu_id
            ) VALUES (
                %(nombre)s, %(paterno)s, %(materno)s, %(nacimiento)s, 
                %(masculino)s, %(ci)s, %(direccion)s, %(email)s, %(activo)s, 
                %(obs)s, %(usr_id_login)s, %(foto_ruta)s, %(creado)s, %(act)s, %(usu_id)s
            )
        """
        
        registros_insertados = 0
        
        # Insertar en batches para mejor rendimiento
        for i in range(0, n, batch_size):
            batch_data = []
            for j in range(min(batch_size, n - i)):
                alumno = generate_alumno()
                batch_data.append(alumno)
            
            # Ejecutar batch
            cursor.executemany(insert_query, batch_data)
            conn.commit()
            
            registros_insertados += len(batch_data)
            print(f"Progreso: {registros_insertados}/{n} registros insertados")
        
        print(f"\n✅ ¡Completado! Se insertaron {registros_insertados} registros.")
        
        # Verificar el resultado
        cursor.execute("SELECT COUNT(*) FROM alumno")
        total = cursor.fetchone()[0]
        print(f"Total de registros en la tabla: {total}")
        
        # Mostrar algunos ejemplos
        print("\n--- Ejemplos de registros insertados ---")
        cursor.execute("""
            SELECT id, nombre, paterno, materno, email, activo 
            FROM alumno 
            ORDER BY id DESC 
            LIMIT 5
        """)
        for row in cursor.fetchall():
            print(f"ID: {row[0]} | {row[1]} {row[2]} {row[3]} | Email: {row[4]} | Activo: {row[5]}")
        
    except psycopg2.Error as e:
        print(f"❌ Error de base de datos: {e}")
        if conn:
            conn.rollback()
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
            print("\n🔌 Conexión cerrada.")

def clear_table():
    """Opcional: Limpiar la tabla antes de insertar"""
    confirm = input("¿Eliminar todos los registros existentes? (s/n): ")
    if confirm.lower() == 's':
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        cursor.execute("TRUNCATE TABLE alumno RESTART IDENTITY CASCADE")
        conn.commit()
        cursor.close()
        conn.close()
        print("✅ Tabla limpiada.")

if __name__ == "__main__":
    print("=== POBLADOR DE TABLA ALUMNO ===\n")
    
    # Opcional: limpiar tabla
    clear_table()
    
    # Insertar 2000 registros
    insert_alumnos(n=2000, batch_size=100)
