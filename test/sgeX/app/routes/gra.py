"""gra.py - Grados"""
from flask import Blueprint, render_template, redirect, url_for, flash, request, jsonify
from flask_login import login_required
from app.models import Gra, Ges, Mat
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('gra', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('gra_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Gra.query.join(Ges).order_by(Ges.gestion.desc(), Gra.nivel, Gra.grado)
    if q:
        query = query.filter(Gra.grado.ilike(f'%{q}%') | Gra.nivel.ilike(f'%{q}%'))
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('gra/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('gra_crear')
def nuevo():
    gestiones = Ges.query.filter_by(activo=True).order_by(Ges.gestion.desc()).all()
    if request.method == 'POST':
        obj = Gra(
            grado=request.form.get('grado', '').strip(),
            nivel=request.form.get('nivel', '').strip(),
            id_ges=request.form.get('id_ges', type=int),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Grado creado.', 'success')
        return redirect(url_for('gra.index'))
    return render_template('gra/form.html', obj=None, gestiones=gestiones, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('gra_editar')
def editar(id):
    obj = Gra.query.get_or_404(id)
    gestiones = Ges.query.filter_by(activo=True).order_by(Ges.gestion.desc()).all()
    if request.method == 'POST':
        obj.grado  = request.form.get('grado', '').strip()
        obj.nivel  = request.form.get('nivel', '').strip()
        obj.id_ges = request.form.get('id_ges', type=int)
        obj.act    = date.today()
        db.session.commit()
        flash('Grado actualizado.', 'success')
        return redirect(url_for('gra.index'))
    return render_template('gra/form.html', obj=obj, gestiones=gestiones, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('gra_eliminar')
def eliminar(id):
    obj = Gra.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Grado eliminado.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar: tiene registros relacionados.', 'danger')
    return redirect(url_for('gra.index'))


@bp.route('/materias/<int:gra_id>')
@login_required
def materias_por_grado(gra_id):
    """Endpoint HTMX: retorna opciones <option> de materias de un grado."""
    materias = Mat.query.filter_by(gra_id=gra_id).all()
    return ''.join(f'<option value="{m.id}">{m.materia}</option>' for m in materias)
