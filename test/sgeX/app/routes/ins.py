from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Ins, Est, Cur, Cos
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('ins', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('ins_ver')
def index():
    q    = request.args.get('q', '')
    page = request.args.get('page', 1, type=int)
    query = Ins.query.join(Est, isouter=True).order_by(Est.paterno, Est.nombre)
    if q:
        query = query.filter(
            Est.nombre.ilike(f'%{q}%') | Est.paterno.ilike(f'%{q}%') | Est.materno.ilike(f'%{q}%')
        )
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    return render_template('ins/index.html', items=pagination.items, pagination=pagination, q=q)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('ins_crear')
def nuevo():
    # Estudiantes sin inscripción
    est_inscritos = db.session.query(Ins.est_id).filter(Ins.est_id.isnot(None)).subquery()
    estudiantes = Est.query.filter(~Est.id.in_(est_inscritos), Est.activo == True).order_by(Est.paterno).all()
    cursos = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    if request.method == 'POST':
        est_id = request.form.get('est_id', type=int)
        cur_id = request.form.get('cur_id', type=int)
        # Verificar capacidad
        cur = Cur.query.get(cur_id)
        if cur and cur.capacidad:
            inscriptos = Ins.query.filter_by(cur_id=cur_id, inscrito=True).count()
            if inscriptos >= cur.capacidad:
                flash(f'El curso ya alcanzó su capacidad máxima ({cur.capacidad}).', 'danger')
                return render_template('ins/form.html', obj=None, estudiantes=estudiantes, cursos=cursos, accion='Crear')
        obj = Ins(
            est_id=est_id,
            cur_id=cur_id,
            reserva=bool(request.form.get('reserva')),
            inscrito=bool(request.form.get('inscrito')),
            descu=request.form.get('descu', 0, type=int),
            motivo_descu=request.form.get('motivo_descu', '').strip(),
            abandono=False,
            obs=request.form.get('obs', '').strip(),
            creado=date.today(), act=date.today()
        )
        db.session.add(obj)
        db.session.flush()  # get obj.id
        if obj.inscrito:
            obj.generar_plan_pagos()
        else:
            db.session.commit()
        flash('Inscripción registrada.', 'success')
        return redirect(url_for('ins.index'))
    return render_template('ins/form.html', obj=None, estudiantes=estudiantes, cursos=cursos, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('ins_editar')
def editar(id):
    obj = Ins.query.get_or_404(id)
    estudiantes = Est.query.filter_by(activo=True).order_by(Est.paterno).all()
    cursos = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    if request.method == 'POST':
        era_inscrito = obj.inscrito
        obj.cur_id       = request.form.get('cur_id', type=int)
        obj.reserva      = bool(request.form.get('reserva'))
        obj.inscrito     = bool(request.form.get('inscrito'))
        obj.descu        = request.form.get('descu', 0, type=int)
        obj.motivo_descu = request.form.get('motivo_descu', '').strip()
        obj.abandono     = bool(request.form.get('abandono'))
        obj.obs          = request.form.get('obs', '').strip()
        obj.act          = date.today()
        db.session.flush()
        # Si acaba de ser inscrito: generar plan de pagos
        if obj.inscrito and not era_inscrito:
            obj.generar_plan_pagos()
        else:
            db.session.commit()
        flash('Inscripción actualizada.', 'success')
        return redirect(url_for('ins.index'))
    return render_template('ins/form.html', obj=obj, estudiantes=estudiantes, cursos=cursos, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('ins_eliminar')
def eliminar(id):
    obj = Ins.query.get_or_404(id)
    try:
        db.session.delete(obj)
        db.session.commit()
        flash('Inscripción eliminada.', 'success')
    except Exception:
        db.session.rollback()
        flash('No se puede eliminar.', 'danger')
    return redirect(url_for('ins.index'))


@bp.route('/ver/<int:id>')
@login_required
@requiere_permiso('ins_ver')
def ver(id):
    obj = Ins.query.get_or_404(id)
    return render_template('ins/ver.html', obj=obj)
