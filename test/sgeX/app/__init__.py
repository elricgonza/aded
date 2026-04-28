import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_migrate import Migrate
from dotenv import load_dotenv

load_dotenv()

db = SQLAlchemy()
login_manager = LoginManager()
migrate = Migrate()


def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-key-change-in-prod')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
        'DATABASE_URL', 'postgresql://uaded:password@localhost:5432/dbaded'
    )
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['WTF_CSRF_ENABLED'] = True

    db.init_app(app)
    login_manager.init_app(app)
    migrate.init_app(app, db)

    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Inicia sesión para continuar.'
    login_manager.login_message_category = 'warning'

    from app.models import Usr, Rol, Per, UsrRol, RolPer
    from app.models import Ges, Gra, Mat, Pro, Cur, Asi, Est, Ins, Cal, Cos, Pag

    @login_manager.user_loader
    def load_user(user_id):
        return Usr.query.get(int(user_id))

    # Register blueprints
    from app.routes.auth   import bp as auth_bp
    from app.routes.main   import bp as main_bp
    from app.routes.ges    import bp as ges_bp
    from app.routes.gra    import bp as gra_bp
    from app.routes.mat    import bp as mat_bp
    from app.routes.pro    import bp as pro_bp
    from app.routes.cur    import bp as cur_bp
    from app.routes.asi    import bp as asi_bp
    from app.routes.est    import bp as est_bp
    from app.routes.ins    import bp as ins_bp
    from app.routes.cal    import bp as cal_bp
    from app.routes.cos    import bp as cos_bp
    from app.routes.pag    import bp as pag_bp
    from app.routes.usr    import bp as usr_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(main_bp)
    app.register_blueprint(ges_bp,  url_prefix='/gestiones')
    app.register_blueprint(gra_bp,  url_prefix='/grados')
    app.register_blueprint(mat_bp,  url_prefix='/materias')
    app.register_blueprint(pro_bp,  url_prefix='/profesores')
    app.register_blueprint(cur_bp,  url_prefix='/cursos')
    app.register_blueprint(asi_bp,  url_prefix='/asignaciones')
    app.register_blueprint(est_bp,  url_prefix='/estudiantes')
    app.register_blueprint(ins_bp,  url_prefix='/inscripciones')
    app.register_blueprint(cal_bp,  url_prefix='/calificaciones')
    app.register_blueprint(cos_bp,  url_prefix='/costos')
    app.register_blueprint(pag_bp,  url_prefix='/pagos')
    app.register_blueprint(usr_bp,  url_prefix='/usuarios')

    return app
