# -*- coding: utf-8 -*-

# -- dado curso(s) y grado(s) obtener materias de cada grado


import psycopg2 as pg
import psycopg2.extras as pge
import psycopg2.extensions as pge

# conection a base de datos postgres
def get_cx():
    ppg = {'host': 'localhost',  \
        'user': 'uaded', \
        'password': 'paded', \
        'port': '5432', \
        'dbname': 'dbaded1'}
    try:
        cx = pg.connect(**ppg)
        print("cnx postgres ok")
        return cx
    except pg.DatabaseError as e:
        print(e)
        sys.exit()

# -- fill asig
def fill_asig():
    cx1 = get_cx()
    cur1 = cx1.cursor()
    cx2 = get_cx()
    cur2 = cx2.cursor()
    cx3 = get_cx()
    cur3 = cx3.cursor()

    cur1.execute("SELECT * FROM curso where grado_id=1 ")
    for r in cur1.fetchall():
        print(r[1], r[2])

    cx1.close()


if __name__ == "__main__":
    fill_asig()
