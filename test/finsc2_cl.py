import psycopg2
import random
from datetime import date, timedelta

# ── Configuración de conexión ──────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "dbname":   "dbaded1",   # <-- cambia aquí
    "user":     "uaded",     # <-- cambia aquí
    "password": "paded",  # <-- cambia aquí
}

# ── Parámetros del negocio ─────────────────────────────────────────────────────
MAX_ALUMNOS_POR_CURSO = 40   # límite de alumnos por curso
FECHA_BASE            = date(2024, 1, 15)   # fecha mínima de inscripción
FECHA_TOP             = date(2024, 12, 31)  # fecha máxima de inscripción

def fecha_aleatoria(ini: date, fin: date) -> date:
    delta = (fin - ini).days
    return ini + timedelta(days=random.randint(0, delta))

def poblar_inscripciones():
    conn = psycopg2.connect(**DB_CONFIG)
    cur  = conn.cursor()

    try:
        # ── 1. Leer IDs disponibles ────────────────────────────────────────────
        cur.execute("SELECT id FROM cur ORDER BY id;")
        cursos = [r[0] for r in cur.fetchall()]          # 42 cursos

        cur.execute("SELECT id FROM alu ORDER BY id;")
        alumnos = [r[0] for r in cur.fetchall()]          # 2000 alumnos

        cur.execute("SELECT id FROM cos ORDER BY id;")
        costos = [r[0] for r in cur.fetchall()]           # 9 costos

        # ── 2. Barajar alumnos para asignación aleatoria ───────────────────────
        random.shuffle(alumnos)

        # ── 3. Construir inscripciones respetando restricciones ────────────────
        #   · Máximo 40 alumnos por curso
        #   · Un alumno en un solo curso  (garantizado por el shuffle + iteración)
        inscripciones = []
        alumno_iter   = iter(alumnos)
        ins_id        = 1

        for cur_id in cursos:
            for _ in range(MAX_ALUMNOS_POR_CURSO):
                try:
                    alu_id = next(alumno_iter)
                except StopIteration:
                    break   # sin más alumnos disponibles

                cos_id    = random.choice(costos)
                fecha_ins = fecha_aleatoria(FECHA_BASE, FECHA_TOP)

                inscripciones.append((ins_id, alu_id, cur_id, cos_id, fecha_ins))
                ins_id += 1

        # ── 4. Insertar en lotes ───────────────────────────────────────────────
        insert_sql = """
            INSERT INTO ins (id, alu_id, cur_id, cos_id, fecha_ins)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING;
        """
        cur.executemany(insert_sql, inscripciones)
        conn.commit()

        # ── 5. Reporte ─────────────────────────────────────────────────────────
        cur.execute("SELECT COUNT(*) FROM ins;")
        total = cur.fetchone()[0]

        print(f"✔  Inscripciones insertadas : {len(inscripciones)}")
        print(f"✔  Total en tabla ins       : {total}")
        print(f"   Cursos utilizados         : {len(cursos)}")
        print(f"   Alumnos asignados         : {len(inscripciones)}")
        print(f"   Alumnos sin inscribir     : {len(alumnos) - len(inscripciones)}")

    except psycopg2.Error as e:
        conn.rollback()
        print(f"✘  Error PostgreSQL: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    poblar_inscripciones()
