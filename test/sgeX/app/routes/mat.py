"""mat.py"""
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Mat, Gra
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('mat', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('mat_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Mat.query.join(Gra).order_by(Gra.nivel, Gra.grado, Mat.materia)
    if q:
        query = query.filter(Mat.materia.ilike(f'%{q}%'))
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('mat/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('mat_crear')
def nuevo():
    grados = Gra.query.order_by(Gra.nivel, Gra.grado).all()
    if request.method == 'POST':
        obj = Mat(
            materia=request.form.get('materia', '').strip(),
            gra_id=request.form.get('gra_id', type=int),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Materia creada.', 'success')
        return redirect(url_for('mat.index'))
    return render_template('mat/form.html', obj=None, grados=grados, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('mat_editar')
def editar(id):
    obj = Mat.query.get_or_404(id)
    grados = Gra.query.order_by(Gra.nivel, Gra.grado).all()
    if request.method == 'POST':
        obj.materia = request.form.get('materia', '').strip()
        obj.gra_id  = request.form.get('gra_id', type=int)
        obj.act     = date.today()
        db.session.commit()
        flash('Materia actualizada.', 'success')
        return redirect(url_for('mat.index'))
    return render_template('mat/form.html', obj=obj, grados=grados, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('mat_eliminar')
def eliminar(id):
    obj = Mat.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Materia eliminada.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar: tiene registros relacionados.', 'danger')
    return redirect(url_for('mat.index'))
