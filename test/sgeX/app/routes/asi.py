from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Asi, Cur, Mat, Pro, Gra
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('asi', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('asi_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Asi.query.join(Cur).join(Pro).join(Mat)
    if q:
        query = query.filter(
            Pro.nombre.ilike(f'%{q}%') | Pro.paterno.ilike(f'%{q}%') |
            Mat.materia.ilike(f'%{q}%') | Cur.curso.ilike(f'%{q}%')
        )
    pagination = query.order_by(Cur.gestion.desc(), Cur.curso, Mat.materia).paginate(page=page, per_page=PER_PAGE)
    return render_template('asi/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('asi_crear')
def nuevo():
    cursos    = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    profesores = Pro.query.filter_by(activo=True).order_by(Pro.paterno).all()
    materias  = Mat.query.order_by(Mat.materia).all()
    if request.method == 'POST':
        cur_id = request.form.get('cur_id', type=int)
        mat_id = request.form.get('mat_id', type=int)
        pro_id = request.form.get('pro_id', type=int)
        # Verificar que la materia pertenece al grado del curso
        curso  = Cur.query.get(cur_id)
        materia = Mat.query.get(mat_id)
        if curso and materia and materia.gra_id != curso.gra_id:
            flash('La materia no corresponde al grado del curso seleccionado.', 'danger')
            return render_template('asi/form.html', obj=None, cursos=cursos,
                                   profesores=profesores, materias=materias, accion='Crear')
        obj = Asi(cur_id=cur_id, mat_id=mat_id, pro_id=pro_id,
                  creado=date.today(), act=date.today())
        db.session.add(obj)
        db.session.commit()
        flash('Asignación registrada.', 'success')
        return redirect(url_for('asi.index'))
    return render_template('asi/form.html', obj=None, cursos=cursos,
                           profesores=profesores, materias=materias, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('asi_editar')
def editar(id):
    obj = Asi.query.get_or_404(id)
    cursos    = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    profesores = Pro.query.filter_by(activo=True).order_by(Pro.paterno).all()
    materias  = Mat.query.order_by(Mat.materia).all()
    if request.method == 'POST':
        obj.cur_id = request.form.get('cur_id', type=int)
        obj.mat_id = request.form.get('mat_id', type=int)
        obj.pro_id = request.form.get('pro_id', type=int)
        obj.act    = date.today()
        db.session.commit()
        flash('Asignación actualizada.', 'success')
        return redirect(url_for('asi.index'))
    return render_template('asi/form.html', obj=obj, cursos=cursos,
                           profesores=profesores, materias=materias, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('asi_eliminar')
def eliminar(id):
    obj = Asi.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Asignación eliminada.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar.', 'danger')
    return redirect(url_for('asi.index'))


@bp.route('/materias-por-curso/<int:cur_id>')
@login_required
def materias_por_curso(cur_id):
    """HTMX: filtra materias según el grado del curso seleccionado."""
    curso = Cur.query.get_or_404(cur_id)
    materias = Mat.query.filter_by(gra_id=curso.gra_id).order_by(Mat.materia).all()
    opts = ''.join(f'<option value="{m.id}">{m.materia}</option>' for m in materias)
    return f'<option value="">-- Seleccionar --</option>{opts}'
