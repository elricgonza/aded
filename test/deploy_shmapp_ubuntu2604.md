# Guía de Deploy — shmapp
## Stack: Python 3.15 · Flask · PostgreSQL 18 · Nginx · Gunicorn · Ubuntu 26.04 LTS

---

## Arquitectura de producción

```
Internet → Nginx (puerto 80/443) → Gunicorn (socket Unix) → Flask (shmapp)
                                                                    ↓
                                                           PostgreSQL 18
```

**Nginx** actúa como *reverse proxy*: recibe las peticiones HTTP/HTTPS, sirve los
archivos estáticos directamente y reenvía el resto a Gunicorn.
**Gunicorn** es el servidor WSGI que ejecuta la aplicación Flask con múltiples
*workers*.
**systemd** gestiona el proceso Gunicorn como servicio del sistema.

---

## 0. Convenciones usadas en esta guía

| Variable | Valor de ejemplo | Descripción |
|---|---|---|
| `APP_USER` | `shmapp` | Usuario del sistema operativo (sin privilegios) |
| `APP_DIR` | `/var/www/shmapp` | Directorio raíz de la aplicación |
| `VENV_DIR` | `/var/www/shmapp/venv` | Entorno virtual Python |
| `DB_NAME` | `uaded_db` | Base de datos PostgreSQL |
| `DB_USER` | `uaded` | Rol/usuario PostgreSQL |
| `DB_PASS` | *(definir en .env)* | Contraseña del rol PostgreSQL |
| `SERVER_IP` | `203.0.113.10` | IP pública del servidor |
| `DOMAIN` | `shmapp.ejemplo.com` | Dominio (opcional) |

> Todos los comandos que empiezan con `$` se ejecutan como usuario normal.
> Los que empiezan con `#` requieren `sudo` o ser root.

---

## 1. Preparación del servidor Ubuntu 26.04

### 1.1 Actualizar el sistema

```bash
# apt update && apt upgrade -y
# apt autoremove -y
```

### 1.2 Crear usuario del sistema para la aplicación

```bash
# adduser --system --group --home /var/www/shmapp --shell /bin/bash shmapp
```

Este usuario es el *propietario* de todos los archivos de la aplicación y el que
ejecuta Gunicorn. Nunca se le asigna contraseña de login.

### 1.3 Instalar dependencias del sistema

```bash
# apt install -y \
    python3.15 python3.15-venv python3.15-dev \
    build-essential \
    libpq-dev \
    git \
    nginx \
    curl \
    ufw
```

Verificar la versión de Python:

```bash
$ python3.15 --version
# Python 3.15.x
```

---

## 2. PostgreSQL 18

### 2.1 Instalar PostgreSQL 18

Ubuntu 26.04 incluye PostgreSQL 18 en sus repositorios oficiales:

```bash
# apt install -y postgresql-18 postgresql-client-18
```

Verificar:

```bash
# systemctl status postgresql
$ psql --version
# psql (PostgreSQL) 18.x
```

### 2.2 Crear rol y base de datos

Conectarse como el superusuario `postgres`:

```bash
# su - postgres
```

Dentro del shell de postgres:

```bash
psql -c "CREATE ROLE uaded WITH INHERIT LOGIN ENCRYPTED PASSWORD 'CAMBIA_ESTA_CLAVE';"
psql -c "CREATE DATABASE uaded_db OWNER uaded ENCODING 'UTF8';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE uaded_db TO uaded;"
exit
```

> **Importante:** Reemplaza `CAMBIA_ESTA_CLAVE` por una contraseña segura y
> anótala; la usarás en el archivo `.env`.

### 2.3 Cargar el esquema de la base de datos

Copiar el script de esquema al servidor y ejecutarlo como el rol `uaded`:

```bash
$ psql -U uaded -d uaded_db -h localhost -f /tmp/schema.sql
```

Si el script crea el rol y la BD (ya los creaste), comenta esas líneas primero
o ejecuta sólo la parte desde las secuencias hacia abajo:

```bash
$ psql -U uaded -d uaded_db -h localhost \
    -c "\i /var/www/shmapp/scripts/schema.sql"
```

### 2.4 Ajustar autenticación (pg_hba.conf)

Verificar que `pg_hba.conf` permita conexiones locales con contraseña (`md5` o `scram-sha-256`):

```bash
# nano /etc/postgresql/18/main/pg_hba.conf
```

La línea para IPv4 local debe verse así (método `scram-sha-256` es el recomendado en PG18):

```
host    all    all    127.0.0.1/32    scram-sha-256
```

Recargar PostgreSQL:

```bash
# systemctl reload postgresql
```

Probar la conexión:

```bash
$ psql -U uaded -d uaded_db -h 127.0.0.1 -W
```

---

## 3. Código de la aplicación

### 3.1 Subir el código al servidor

**Opción A — Git (recomendado):**

```bash
# git clone https://github.com/tu-usuario/shmapp.git /var/www/shmapp
# chown -R shmapp:shmapp /var/www/shmapp
```

**Opción B — SCP desde tu máquina local:**

```bash
# En tu máquina local:
scp shmapp_tar.gz usuario@SERVER_IP:/tmp/

# En el servidor:
# tar -xzf /tmp/shmapp_tar.gz -C /var/www/
# mv /var/www/shmapp_original /var/www/shmapp   # ajustar nombre si es necesario
# chown -R shmapp:shmapp /var/www/shmapp
```

Verificar la estructura:

```
/var/www/shmapp/
├── app/
│   ├── __init__.py
│   ├── models.py
│   ├── routes/
│   └── templates/
├── scripts/
│   └── schema.sql
├── config.py
├── wsgi.py          ← punto de entrada de Gunicorn
├── run.py
└── requirements.txt
```

### 3.2 Crear el entorno virtual Python 3.15

```bash
# su - shmapp -s /bin/bash
$ python3.15 -m venv /var/www/shmapp/venv
$ source /var/www/shmapp/venv/bin/activate
(venv) $ pip install --upgrade pip
(venv) $ pip install -r /var/www/shmapp/requirements.txt
(venv) $ deactivate
$ exit
```

Verificar que Gunicorn quedó instalado:

```bash
$ /var/www/shmapp/venv/bin/gunicorn --version
# gunicorn (version 22.0.0)
```

---

## 4. Configuración de variables de entorno

### 4.1 Crear el archivo .env de producción

```bash
# su - shmapp -s /bin/bash
$ nano /var/www/shmapp/.env
```

Contenido del `.env` para producción:

```ini
# ── Flask ─────────────────────────────────────────────────
SECRET_KEY=genera-una-clave-aleatoria-larga-aqui
FLASK_ENV=production
FLASK_APP=wsgi.py

# ── Base de datos ─────────────────────────────────────────
DATABASE_URL=postgresql://uaded:CAMBIA_ESTA_CLAVE@127.0.0.1:5432/uaded_db
```

Para generar una `SECRET_KEY` segura:

```bash
$ python3.15 -c "import secrets; print(secrets.token_hex(32))"
```

Asegurar permisos restrictivos del archivo:

```bash
$ chmod 600 /var/www/shmapp/.env
$ exit
```

---

## 5. Gunicorn — Servidor WSGI

### 5.1 Calcular el número de workers

La regla estándar de Gunicorn es:

```
workers = (2 × núcleos_CPU) + 1
```

Para 2 núcleos: **5 workers**. Puedes consultar los núcleos con:

```bash
$ nproc
```

### 5.2 Prueba manual de Gunicorn

Antes de configurar el servicio, verifica que Gunicorn arranca correctamente:

```bash
# su - shmapp -s /bin/bash
$ cd /var/www/shmapp
$ source venv/bin/activate
(venv) $ gunicorn \
    --workers 5 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    wsgi:app
```

Deberías ver líneas como:

```
[INFO] Starting gunicorn 22.0.0
[INFO] Listening at: http://127.0.0.1:8000
[INFO] Worker booted (pid: XXXXX)
```

Pulsa `Ctrl+C` para detener. Sal del usuario shmapp:

```bash
(venv) $ deactivate
$ exit
```

### 5.3 Crear el servicio systemd

```bash
# nano /etc/systemd/system/shmapp.service
```

Contenido del archivo:

```ini
[Unit]
Description=shmapp — Gunicorn WSGI server
After=network.target postgresql.service
Requires=postgresql.service

[Service]
User=shmapp
Group=shmapp
WorkingDirectory=/var/www/shmapp
EnvironmentFile=/var/www/shmapp/.env
ExecStart=/var/www/shmapp/venv/bin/gunicorn \
    --workers 5 \
    --worker-class sync \
    --bind unix:/var/run/shmapp/gunicorn.sock \
    --timeout 120 \
    --access-logfile /var/log/shmapp/access.log \
    --error-logfile /var/log/shmapp/error.log \
    --log-level info \
    wsgi:app
ExecReload=/bin/kill -s HUP $MAINPID
RuntimeDirectory=shmapp
RuntimeDirectoryMode=0755
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

> El flag `--bind unix:/var/run/shmapp/gunicorn.sock` usa un **socket Unix** en
> lugar de un puerto TCP. Es más rápido para comunicación local y es la práctica
> estándar con Nginx.
> `RuntimeDirectory=shmapp` hace que systemd cree `/var/run/shmapp/` al arrancar
> con los permisos correctos.

### 5.4 Crear el directorio de logs

```bash
# mkdir -p /var/log/shmapp
# chown shmapp:shmapp /var/log/shmapp
```

### 5.5 Activar e iniciar el servicio

```bash
# systemctl daemon-reload
# systemctl enable shmapp
# systemctl start shmapp
# systemctl status shmapp
```

La salida de `status` debe mostrar `active (running)`. Verifica que el socket existe:

```bash
$ ls -la /var/run/shmapp/gunicorn.sock
# srwxrwxrwx 1 shmapp shmapp 0 ... /var/run/shmapp/gunicorn.sock
```

---

## 6. Nginx — Reverse Proxy

### 6.1 Crear el bloque de servidor

```bash
# nano /etc/nginx/sites-available/shmapp
```

Contenido (sin SSL primero, para verificar):

```nginx
upstream shmapp_gunicorn {
    server unix:/var/run/shmapp/gunicorn.sock fail_timeout=0;
}

server {
    listen 80;
    server_name shmapp.ejemplo.com 203.0.113.10;  # ajustar

    client_max_body_size 16M;

    # Logs
    access_log /var/log/nginx/shmapp_access.log;
    error_log  /var/log/nginx/shmapp_error.log;

    # Archivos estáticos (sirve Nginx directamente, sin pasar por Flask)
    location /static/ {
        alias /var/www/shmapp/app/static/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    # Fotos de alumnos/profesores subidas
    location /static/img/fotos/ {
        alias /var/www/shmapp/app/static/img/fotos/;
        expires 7d;
    }

    # Resto de peticiones → Gunicorn
    location / {
        proxy_pass         http://shmapp_gunicorn;
        proxy_redirect     off;

        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;

        proxy_connect_timeout  60s;
        proxy_send_timeout     60s;
        proxy_read_timeout     120s;
    }
}
```

> **Nota sobre Tailwind/HTMX/Alpine.js:** La aplicación los carga desde CDN
> (`cdn.tailwindcss.com`, `unpkg.com`, `cdn.jsdelivr.net`). Nginx no necesita
> hacer nada especial con ellos — el navegador los descarga directamente.

### 6.2 Activar el sitio

```bash
# ln -s /etc/nginx/sites-available/shmapp /etc/nginx/sites-enabled/
# rm -f /etc/nginx/sites-enabled/default  # eliminar sitio por defecto
# nginx -t                                  # verificar sintaxis
# systemctl reload nginx
```

### 6.3 Verificar que la aplicación responde

```bash
$ curl -I http://203.0.113.10/
# HTTP/1.1 200 OK  (o 302 si redirige al login)
```

---

## 7. Firewall (UFW)

```bash
# ufw default deny incoming
# ufw default allow outgoing
# ufw allow ssh
# ufw allow 'Nginx Full'    # abre 80 y 443
# ufw enable
# ufw status
```

---

## 8. HTTPS con Let's Encrypt (si tienes dominio)

Si la aplicación tiene un dominio apuntando al servidor:

```bash
# apt install -y certbot python3-certbot-nginx
# certbot --nginx -d shmapp.ejemplo.com
```

Certbot modifica automáticamente el bloque Nginx para añadir SSL y configura la
renovación automática. Verificar renovación:

```bash
# certbot renew --dry-run
```

---

## 9. Directorio de uploads — permisos

La aplicación guarda fotos en `app/static/img/fotos/`. Verificar que el directorio
existe y que el usuario `shmapp` puede escribir en él:

```bash
# mkdir -p /var/www/shmapp/app/static/img/fotos
# chown -R shmapp:shmapp /var/www/shmapp/app/static/img/fotos
# chmod 755 /var/www/shmapp/app/static/img/fotos
```

---

## 10. Inicialización de datos (opcional)

Si el proyecto incluye el script `scripts/init_db.py` para cargar datos iniciales
(roles, permisos, usuario administrador):

```bash
# su - shmapp -s /bin/bash
$ cd /var/www/shmapp
$ source venv/bin/activate
(venv) $ python scripts/init_db.py
(venv) $ deactivate
$ exit
```

---

## 11. Verificación completa del deploy

```bash
# Servicio Gunicorn activo
systemctl status shmapp

# Nginx activo y sin errores
systemctl status nginx
nginx -t

# Socket Unix presente
ls -la /var/run/shmapp/gunicorn.sock

# Conexión a la BD
su - shmapp -s /bin/bash -c "psql -U uaded -d uaded_db -h 127.0.0.1 -c '\l'"

# Log de errores de la aplicación
tail -f /var/log/shmapp/error.log

# Log de accesos de Nginx
tail -f /var/log/nginx/shmapp_access.log
```

---

## 12. Comandos de mantenimiento del día a día

| Tarea | Comando |
|---|---|
| Reiniciar la aplicación | `systemctl restart shmapp` |
| Recargar sin cortar conexiones | `systemctl reload shmapp` |
| Ver logs de la app en vivo | `journalctl -u shmapp -f` |
| Ver logs de acceso | `tail -f /var/log/shmapp/access.log` |
| Ver errores de la app | `tail -f /var/log/shmapp/error.log` |
| Actualizar el código (git) | `cd /var/www/shmapp && git pull && systemctl restart shmapp` |
| Actualizar dependencias | `source venv/bin/activate && pip install -r requirements.txt && deactivate && systemctl restart shmapp` |
| Backup de la BD | `pg_dump -U uaded -h 127.0.0.1 uaded_db > backup_$(date +%Y%m%d).sql` |

---

## 13. Resumen de archivos creados/modificados

```
/etc/systemd/system/shmapp.service      ← Servicio Gunicorn
/etc/nginx/sites-available/shmapp       ← Configuración Nginx
/etc/nginx/sites-enabled/shmapp         ← Enlace simbólico

/var/www/shmapp/.env                    ← Variables de entorno (SECRET_KEY, DATABASE_URL)
/var/www/shmapp/venv/                   ← Entorno virtual Python 3.15
/var/log/shmapp/                        ← Logs de la aplicación
```

---

## 14. Problemas comunes y soluciones

| Síntoma | Causa probable | Solución |
|---|---|---|
| `502 Bad Gateway` en Nginx | Gunicorn no arrancó o el socket no existe | `systemctl status shmapp` y revisar `/var/log/shmapp/error.log` |
| `500 Internal Server Error` | Error en la app Flask | `journalctl -u shmapp -n 50` para ver el traceback |
| `connection refused` a PostgreSQL | pg_hba.conf no permite conexión local | Revisar `/etc/postgresql/18/main/pg_hba.conf` |
| `ModuleNotFoundError` | Paquete no instalado en el venv | Activar el venv y hacer `pip install -r requirements.txt` |
| Archivos estáticos retornan 404 | Ruta del `alias` en Nginx incorrecta | Verificar que `alias` apunte al directorio real |
| Subida de fotos falla | Permisos del directorio fotos | `chown -R shmapp:shmapp app/static/img/fotos` |
| La app arranca lenta (primera petición) | Normal: Tailwind CDN tarda en cargar | Considerar descargar Tailwind y servirlo localmente en producción |

---

*Guía generada para shmapp · Ubuntu 26.04 LTS · Python 3.15 · PostgreSQL 18 · Nginx + Gunicorn*
