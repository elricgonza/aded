import psycopg2
import random

# Configuración de conexión
conn = psycopg2.connect(
    host="localhost",
    database="dbaded1",
    user="uaded",
    password="paded"
)

cursor = conn.cursor()
# supr

#cursor.execute("DELETE FROM TABLE cos")
#cursor.execute("TRUNCATE TABLE cos")
#print("✓ Tabla 'cos' limpiada exitosamente")    


# Generar e insertar 20 registros
for i in range(1, 10):
    descrip = f"srv_ed _{i}"
    #costo = round(random.uniform(100, 500), 2)
    costo = round(random.choice([100, 200, 300, 400, 500, 600, 700]), 2)
    descu = random.randint(0, 100)
    cuota = costo - (costo * descu / 100) if descu > 0 else costo
    cuota = round(cuota, 1)
    nro = 10
    importe = cuota * nro
    
    cursor.execute("""
        INSERT INTO cos (id, descrip, costo, descu, cuota, nro, importe)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (i, descrip, costo, descu, cuota, nro, importe))
    
    print(f"Insertado registro {i}: {descrip} - ${costo}")

# Confirmar cambios
conn.commit()
print(f"\n✓ Se insertaron 10 registros exitosamente")

# Verificar
cursor.execute("SELECT COUNT(*) FROM cos")
total = cursor.fetchone()[0]
print(f"Total registros en tabla: {total}")

# Cerrar conexión
cursor.close()
conn.close()
