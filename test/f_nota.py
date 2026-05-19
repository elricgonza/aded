# 

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

def poblar_notas():
    conn = psycopg2.connect(**DB_CONFIG)
    cur  = conn.cursor()

    try:
        # --0 init --
        cur.execute("DELETE FROM nota;")  # limpiar tabla antes de poblar
        cur.execute("ALTER SEQUENCE nota_id_seq RESTART WITH 1;")  # reiniciar secuencia de IDs

        # ── 1. Leer IDs disponibles ────────────────────────────────────────────
        sqltxt = '''
            select  ins.id as ins_id,
                mat.id as mat_id 
            from inscrito ins, curso cur, 
                asignado asi, materia mat
            where
                ins.cur_id = cur.id
                and cur.id = asi.cur_id
                and mat.id = asi.mat_id
            order by ins.id, mat.id
        '''
        cur.execute(sqltxt)
        inscritos = [(r[0], r[1]) for r in cur.fetchall()]          # 
        print(inscritos[:5])  # mostrar primeros 5 para ver formato

        # ── 1. Construir pagos 
        #    misma cant q ins 
        notas = []
        nota1, nota2, nota3, nota_final  = 0, 0, 0, 0
        nota_aprob = 51
        aprobado = False
        obs = ""
        creado        = date.today()
        act           = date.today()
        usu_id        = 1  # usuario ficticio

        not_id        = 1

        for inscrito in inscritos:
            ins_id, mat_id = inscrito

            notas.append((not_id, ins_id, mat_id, nota1, nota2, nota3, nota_final, \
                              nota_aprob, aprobado, obs, creado, act, usu_id))
            not_id += 1

            # ── 4. Insertar en lotes ───────────────────────────────────────────────
            insert_sql = """
                INSERT INTO nota (id, ins_id, mat_id, nota1, nota2, nota3, nota_final, \
                    nota_aprob, aprobado, obs, creado, act, usu_id)
                VALUES (%s, %s, %s, %s,  %s, %s, %s, %s,  %s, %s, %s, %s, %s)
                ON CONFLICT DO NOTHING;
            """

        cur.executemany(insert_sql, notas)
        conn.commit()

        # ── 5. Reporte ─────────────────────────────────────────────────────────
        cur.execute("SELECT COUNT(*) FROM nota;")
        total = cur.fetchone()[0]

        print(f"✔  Inscritos : {len(inscritos)}")
        print(f"✔  Total en tabla nota      : {total}")
        print(f"   Alumnos inscritos        : {len(inscritos)}")
    except psycopg2.Error as e:
       conn.rollback()
       print(f"✘  Error PostgreSQL: {e}")
       raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    poblar_notas()
