steps: 3sep/2026

\i structure
	(~/ric/aded/test/dbaded_fromneon.sql)

En base al orden: 
	~/aded/test/pgbaktable_init/orden_load.txt

\i  (load tables necesarias)
	~/aded/test/pgbaktable_init/necesario_init


================================================cfg render WEB SERVICE
en render, requiere?

en github:
ifa -> private -> public

-en:  dashboard.render.com/web/new
		-Configure in GitHub (redirige a github.com)
		-Repository access:  only select repositories
		 -select elricgonza/ifa
		(aparece adicionado el repositorio - New Web Service ...y continuar...) 

		...
		reeemplaz Deploy/Start Command:
			gunicorn wsgi:app

		Environment Variables ??:
			?-KEY:  DATABASE_URL
			?-VALUE:  postgres://postgres:postgres@db:5432/ifa

 Deploy web service (opción)

 post:

En Environment (opción MANAGE/Environment) opc. princ. izq
	-Add Environment Variables:

		DATABASE_URL
		FLASK_ENV				production
		PYTHON_VERSION	3.14.0
		SECRET_KEY			clavemuys...

yeaaaaaaahhhhhh -- all-fgD  --ilJ

Deploys/Status    Deploy Succeeded

Available at your primary URL:  https://ifa-4xzy.onrender.com

;)


