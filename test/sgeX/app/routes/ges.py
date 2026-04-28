from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Ges
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('ges', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('ges_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Ges.query.order_by(Ges.gestion.desc())
    if q:
        query = query.filter(Ges.plan.ilike(f'%{q}%'))
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('ges/index.html', items=pagination.items,
                           pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('ges_crear')
def nuevo():
    if request.method == 'POST':
        obj = Ges(
            gestion=request.form.get('gestion', type=int),
            plan=request.form.get('plan', '').strip(),
            inicio=date.fromisoformat(request.form['inicio']),
            fin=date.fromisoformat(request.form['fin']),
            activo=bool(request.form.get('activo')),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Gestión creada correctamente.', 'success')
        return redirect(url_for('ges.index'))
    return render_template('ges/form.html', obj=None, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('ges_editar')
def editar(id):
    obj = Ges.query.get_or_404(id)
    if request.method == 'POST':
        obj.gestion = request.form.get('gestion', type=int)
        obj.plan    = request.form.get('plan', '').strip()
        obj.inicio  = date.fromisoformat(request.form['inicio'])
        obj.fin     = date.fromisoformat(request.form['fin'])
        obj.activo  = bool(request.form.get('activo'))
        obj.act     = date.today()
        db.session.commit()
        flash('Gestión actualizada.', 'success')
        return redirect(url_for('ges.index'))
    return render_template('ges/form.html', obj=obj, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('ges_eliminar')
def eliminar(id):
    obj = Ges.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Gestión eliminada.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar: tiene registros relacionados.', 'danger')
    return redirect(url_for('ges.index'))
