# -*- coding: utf-8 -*-

# dado curso(s) y grado(s) obtener materias de cada grado
# fill - asig además con prof

import psycopg2 as pg
import psycopg2.extras as pge
import psycopg2.extensions as pge
import random

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
    cr1 = cx1.cursor()
    cx2 = get_cx()
    cr2 = cx2.cursor()
    cx3 = get_cx()
    cr3 = cx3.cursor()
    cx4 = get_cx()
    cr4 = cx4.cursor()

    #init asig
    cr4.execute("DELETE FROM asig")
    cx4.commit()

    cr1.execute("SELECT * FROM cur order by id ")
    for r in cr1.fetchall():
        print(r[0], r[1], r[2])
        cr2.execute("SELECT * FROM mat where gra_id=%s", (r[1],))
        for r2 in cr2.fetchall():
            print(r2[0], r2[1], r2[2])
            prof_id = random.randint(1, 29)  # get prof aleatoriamente
            print(prof_id)
            cr3.execute(f"SELECT * FROM prof where id={prof_id}")
            for r3 in cr3.fetchall():
                print(r3[0], r3[1], r3[2])
                cr4 = cx4.cursor()
                cr4.execute("INSERT INTO asig (cur_id, mat_id, prof_id) VALUES (%s, %s, %s)", (r[0], r2[0], r3[0]))
                cx4.commit()
                cr4.close()

    cx1.close()


if __name__ == "__main__":
    fill_asig()
