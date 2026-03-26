import psycopg2
from faker import Faker
from tqdm import tqdm  # Para barra de progreso

def insertar_datos_realistas(cantidad=2000):
    """Versión con datos más realistas usando Faker"""
    
    # Instalar dependencias:
    # pip install faker tqdm psycopg2-binary
    
    fake = Faker('es_ES')  # Localización española
    DB_CONFIG = {
        'dbname': 'dbaded1',
        'user': 'uaded',
        'password': 'paded',
        'host': 'localhost'
    }
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print(f"🔄 Generando e insertando {cantidad} registros...")
        
        # Usar tqdm para barra de progreso
        for _ in tqdm(range(cantidad)):
            nombre = fake.first_name()
            apellido = fake.last_name()
            
            cursor.execute(
                "INSERT INTO alu (nombre, apellido) VALUES (%s, %s)",
                (nombre, apellido)
            )
        
        conn.commit()
        print(f"✅ ¡Completado! Se insertaron {cantidad} registros")
        
        # Verificar el total
        cursor.execute("SELECT COUNT(*) FROM alu")
        total = cursor.fetchone()[0]
        print(f"📊 Total de registros en tabla: {total}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        if conn:
            conn.rollback()
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    insertar_datos_realistas()
