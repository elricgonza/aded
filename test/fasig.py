# -*- coding: utf-8 -*-

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


if __name__ == "__main__":
    cx = get_cx()
    cur = cx.cursor()
    cur.execute("SELECT * FROM mat where grado_id = 1")
    for r in cur.fetchall():
        print(r)
    cur.close()
    cx.close()

