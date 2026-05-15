import psycopg2
import random
from datetime import date, timedelta

# ── Configuración de conexión ──────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "dbname":   "dbaded",   # <-- cambia aquí
    "user":     "uaded",     # <-- cambia aquí
    "password": "paded",  # <-- cambia aquí
}

# ── Parámetros del negocio ─────────────────────────────────────────────────────
MAX_ALUMNOS_POR_CURSO = 40   # límite de alumnos por curso
FECHA_BASE            = date(2026, 1, 15)   # fecha mínima de inscripción
FECHA_TOP             = date(2026, 12, 30)  # fecha máxima de inscripción

def fecha_aleatoria(ini: date, fin: date) -> date:
    delta = (fin - ini).days
    return ini + timedelta(days=random.randint(0, delta))

def get_cuotas_por_curso(cur_id):
    cnx = psycopg2.connect(**DB_CONFIG)
    cur = cnx.cursor()
    try:
        cur.execute("select nro_cuota, cuota from costo where cur_id = {cur_id}")
        cuotas = cur.fetchall()
    except psycopg2.Error as e:
        print(f"Error al obtener cuotas para curso {cur_id}: {e}")
        cuotas = []
    finally:
        cur.close()
        cnx.close()
    return cuotas


def poblar_pagos():
    conn = psycopg2.connect(**DB_CONFIG)
    cur  = conn.cursor()

    try:
        # --0 init --
        cur.execute("DELETE FROM pago;")  # limpiar tabla antes de poblar
        cur.execute("ALTER SEQUENCE pago_id_seq RESTART WITH 1;")  # reiniciar secuencia de IDs
        #cur.execute("TRUNCATE TABLE pago;") 

        # ── 1. Leer IDs disponibles ────────────────────────────────────────────
        cur.execute("SELECT a.id, a.cur_id FROM inscrito a, curso b where a.cur_id=b.id and b.gestion=2026 ORDER BY a.id;")
        inscritos = [(r[0], r[1]) for r in cur.fetchall()]          # 
        print(inscritos[:5])  # mostrar primeros 5 para ver formato
        print(inscritos[0][0])
        print(inscritos[0][1])
        print(inscritos[2][0])
        print(inscritos[2][1])

        '''

        # ── 2. Barajar alumnos para asignación aleatoria ───────────────────────
        random.shuffle(alumnos)

        # ── 3. Construir pagos 
        #   · por curso el nro de registros en costo
        pagos = []
        pagado = False
        metodo_pago = ""
        fecha_pago =  Null
        referencia_pago = Null
        obs = ""
        creado        = date.today()
        act           = date.today()
        usu_id        = 1  # usuario ficticio

        pag_id        = 1  # usuario ficticio   

        for inscrito in inscritos:
            ins_id, cur_id = inscrito
            cuotas = get_cuotas_por_curso(cur_id)
            for cuota in cuotas:
                nro_cuota, cuota = cuota

            pagos.append((ins_id, alu_id, cur_id, reserva, pago, descuento, \
                                  motivo_descuento, abandono, obs, creado, act, usu_id))
            pag_id += 1

        # ── 4. Insertar en lotes ───────────────────────────────────────────────
        insert_sql = """
            INSERT INTO pago (id, alu_id, cur_id, reserva, pago, descuento, \
                    motivo_descuento, abandono, obs, creado, act, usu_id)
            VALUES (%s, %s, %s, %s,  %s, %s, %s, %s,  %s, %s, %s, %s)
            ON CONFLICT DO NOTHING;
        """
        cur.executemany(insert_sql, inscripciones)
        conn.commit()

        # ── 5. Reporte ─────────────────────────────────────────────────────────
        cur.execute("SELECT COUNT(*) FROM pago;")
        total = cur.fetchone()[0]

        print(f"✔  Inscripciones insertadas : {len(inscripciones)}")
        print(f"✔  Total en tabla pago       : {total}")
        print(f"   Cursos utilizados         : {len(cursos)}")
        print(f"   Alumnos asignados         : {len(inscripciones)}")
        print(f"   Alumnos sin inscribir     : {len(alumnos) - len(inscripciones)}")
        '''
    except psycopg2.Error as e:
        conn.rollback()
        print(f"✘  Error PostgreSQL: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    poblar_pagos()
