from flask import Blueprint, render_template
from flask_login import login_required
from app.models import Est, Ins, Pro, Cur, Pag, Mat
from app import db

bp = Blueprint('main', __name__)


@bp.route('/')
@login_required
def dashboard():
    class Stats:
        estudiantes      = Est.query.count()
        inscripciones    = Ins.query.filter_by(inscrito=True).count()
        profesores       = Pro.query.filter_by(activo=True).count()
        cursos           = Cur.query.count()
        pagos_pendientes = Pag.query.filter_by(pagado=False).count()
        materias         = Mat.query.count()

    ultimas_inscripciones = (
        Ins.query
        .filter_by(inscrito=True)
        .order_by(Ins.creado.desc())
        .limit(6)
        .all()
    )
    pagos_pendientes = (
        Pag.query
        .filter_by(pagado=False)
        .order_by(Pag.creado.asc())
        .limit(6)
        .all()
    )
    return render_template(
        'main/dashboard.html',
        stats=Stats(),
        ultimas_inscripciones=ultimas_inscripciones,
        pagos_pendientes=pagos_pendientes,
    )
