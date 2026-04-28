"""est.py - Estudiantes"""
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Est
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('est', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('est_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Est.query.order_by(Est.paterno, Est.materno, Est.nombre)
    if q:
        query = query.filter(
            Est.nombre.ilike(f'%{q}%') | Est.paterno.ilike(f'%{q}%') |
            Est.materno.ilike(f'%{q}%') | Est.ci.cast(db.String).ilike(f'%{q}%')
        )
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('est/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('est_crear')
def nuevo():
    if request.method == 'POST':
        nac_str = request.form.get('nacimiento', '')
        obj = Est(
            nombre=request.form.get('nombre', '').strip(),
            paterno=request.form.get('paterno', '').strip(),
            materno=request.form.get('materno', '').strip(),
            nacimiento=date.fromisoformat(nac_str) if nac_str else None,
            masculino=request.form.get('masculino') == '1',
            ci=request.form.get('ci', type=int),
            direccion=request.form.get('direccion', '').strip(),
            activo=bool(request.form.get('activo')),
            obs=request.form.get('obs', '').strip(),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Estudiante registrado.', 'success')
        return redirect(url_for('est.index'))
    return render_template('est/form.html', obj=None, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('est_editar')
def editar(id):
    obj = Est.query.get_or_404(id)
    if request.method == 'POST':
        nac_str = request.form.get('nacimiento', '')
        obj.nombre     = request.form.get('nombre', '').strip()
        obj.paterno    = request.form.get('paterno', '').strip()
        obj.materno    = request.form.get('materno', '').strip()
        obj.nacimiento = date.fromisoformat(nac_str) if nac_str else None
        obj.masculino  = request.form.get('masculino') == '1'
        obj.ci         = request.form.get('ci', type=int)
        obj.direccion  = request.form.get('direccion', '').strip()
        obj.activo     = bool(request.form.get('activo'))
        obj.obs        = request.form.get('obs', '').strip()
        obj.act        = date.today()
        db.session.commit()
        flash('Estudiante actualizado.', 'success')
        return redirect(url_for('est.index'))
    return render_template('est/form.html', obj=obj, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('est_eliminar')
def eliminar(id):
    obj = Est.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Estudiante eliminado.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar: tiene inscripción activa.', 'danger')
    return redirect(url_for('est.index'))


@bp.route('/ver/<int:id>')
@login_required
@requiere_permiso('est_ver')
def ver(id):
    obj = Est.query.get_or_404(id)
    return render_template('est/ver.html', obj=obj)
