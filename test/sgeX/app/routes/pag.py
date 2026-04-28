from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Cos, Cur
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('cos', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('cos_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Cos.query.join(Cur).order_by(Cur.gestion.desc(), Cur.curso)
    if q:
        query = query.filter(Cos.obs.ilike(f'%{q}%') | Cur.curso.ilike(f'%{q}%'))
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('cos/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('cos_crear')
def nuevo():
    cursos = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    if request.method == 'POST':
        obj = Cos(
            cur_id=request.form.get('cur_id', type=int),
            nro_cuota=request.form.get('nro_cuota', type=int),
            cuota=request.form.get('cuota', type=float),
            obs=request.form.get('obs', '').strip(),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Costo registrado.', 'success')
        return redirect(url_for('cos.index'))
    return render_template('cos/form.html', obj=None, cursos=cursos, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('cos_editar')
def editar(id):
    obj = Cos.query.get_or_404(id)
    cursos = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    if request.method == 'POST':
        obj.cur_id    = request.form.get('cur_id', type=int)
        obj.nro_cuota = request.form.get('nro_cuota', type=int)
        obj.cuota     = request.form.get('cuota', type=float)
        obj.obs       = request.form.get('obs', '').strip()
        obj.act       = date.today()
        db.session.commit()
        flash('Costo actualizado.', 'success')
        return redirect(url_for('cos.index'))
    return render_template('cos/form.html', obj=obj, cursos=cursos, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('cos_eliminar')
def eliminar(id):
    obj = Cos.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Costo eliminado.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar.', 'danger')
    return redirect(url_for('cos.index'))
