from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Cur, Gra, Ges
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('cur', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('cur_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Cur.query.join(Gra).order_by(Cur.gestion.desc(), Gra.nivel, Gra.grado, Cur.paralelo)
    if q:
        query = query.filter(Cur.curso.ilike(f'%{q}%') | Cur.paralelo.ilike(f'%{q}%'))
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('cur/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('cur_crear')
def nuevo():
    grados = Gra.query.order_by(Gra.nivel, Gra.grado).all()
    if request.method == 'POST':
        obj = Cur(
            curso=request.form.get('curso', '').strip(),
            paralelo=request.form.get('paralelo', '').strip(),
            gra_id=request.form.get('gra_id', type=int),
            aula=request.form.get('aula', '').strip(),
            capacidad=request.form.get('capacidad', type=int),
            gestion=request.form.get('gestion', type=int),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.commit()
        flash('Curso creado.', 'success')
        return redirect(url_for('cur.index'))
    year = date.today().year
    return render_template('cur/form.html', obj=None, grados=grados, year=year, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('cur_editar')
def editar(id):
    obj = Cur.query.get_or_404(id)
    grados = Gra.query.order_by(Gra.nivel, Gra.grado).all()
    if request.method == 'POST':
        obj.curso     = request.form.get('curso', '').strip()
        obj.paralelo  = request.form.get('paralelo', '').strip()
        obj.gra_id    = request.form.get('gra_id', type=int)
        obj.aula      = request.form.get('aula', '').strip()
        obj.capacidad = request.form.get('capacidad', type=int)
        obj.gestion   = request.form.get('gestion', type=int)
        obj.act       = date.today()
        db.session.commit()
        flash('Curso actualizado.', 'success')
        return redirect(url_for('cur.index'))
    return render_template('cur/form.html', obj=obj, grados=grados, year=date.today().year, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('cur_eliminar')
def eliminar(id):
    obj = Cur.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Curso eliminado.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar: tiene registros relacionados.', 'danger')
    return redirect(url_for('cur.index'))
