from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Pro
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('pro', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('pro_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Pro.query.order_by(Pro.paterno, Pro.materno, Pro.nombre)
    if q:
        query = query.filter(
            Pro.nombre.ilike(f'%{q}%') | Pro.paterno.ilike(f'%{q}%') | Pro.materno.ilike(f'%{q}%')
        )
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('pro/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('pro_crear')
def nuevo():
    if request.method == 'POST':
        obj = Pro(
            nombre=request.form.get('nombre', '').strip(),
            paterno=request.form.get('paterno', '').strip(),
            materno=request.form.get('materno', '').strip(),
            formacion=request.form.get('formacion', '').strip(),
            activo=bool(request.form.get('activo')),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Profesor registrado.', 'success')
        return redirect(url_for('pro.index'))
    return render_template('pro/form.html', obj=None, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('pro_editar')
def editar(id):
    obj = Pro.query.get_or_404(id)
    if request.method == 'POST':
        obj.nombre    = request.form.get('nombre', '').strip()
        obj.paterno   = request.form.get('paterno', '').strip()
        obj.materno   = request.form.get('materno', '').strip()
        obj.formacion = request.form.get('formacion', '').strip()
        obj.activo    = bool(request.form.get('activo'))
        obj.act       = date.today()
        db.session.commit()
        flash('Profesor actualizado.', 'success')
        return redirect(url_for('pro.index'))
    return render_template('pro/form.html', obj=obj, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('pro_eliminar')
def eliminar(id):
    obj = Pro.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Profesor eliminado.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar: tiene asignaciones activas.', 'danger')
    return redirect(url_for('pro.index'))
