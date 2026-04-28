"""cal.py - Calificaciones"""
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required, current_user
from app.models import Cal, Ins, Mat, Asi, Cur
from app import db
from datetime import date
from app.utils.permisos import requiere_permiso

bp = Blueprint('cal', __name__)
PER_PAGE = 20


@bp.route('/')
@login_required
@requiere_permiso('cal_ver')
def index():
    q    = request.args.get('q', '')
    cur_id = request.args.get('cur_id', type=int)
    page = request.args.get('page', 1, type=int)
    query = Cal.query.join(Ins).join(Ins.estudiante, isouter=True)
    if cur_id:
        query = query.filter(Ins.cur_id == cur_id)
    if q:
        from app.models import Est
        query = query.filter(Est.nombre.ilike(f'%{q}%') | Est.paterno.ilike(f'%{q}%'))
    pagination = query.order_by(Cal.id.desc()).paginate(page=page, per_page=PER_PAGE)
    cursos = Cur.query.order_by(Cur.gestion.desc(), Cur.curso).all()
    return render_template('cal/index.html', items=pagination.items, pagination=pagination,
                           q=q, cur_id=cur_id, cursos=cursos)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('cal_crear')
def nuevo():
    inscripciones = Ins.query.filter_by(inscrito=True).order_by(Ins.id).all()
    if request.method == 'POST':
        ins_id = request.form.get('ins_id', type=int)
        mat_id = request.form.get('mat_id', type=int)
        nota1  = request.form.get('nota1', 0, type=int)
        nota2  = request.form.get('nota2', 0, type=int)
        nota3  = request.form.get('nota3', 0, type=int)
        nota_aprob = request.form.get('nota_aprob', 51, type=int)
        obj = Cal(
            ins_id=ins_id, mat_id=mat_id,
            nota1=nota1, nota2=nota2, nota3=nota3,
            nota_final=0, nota_aprob=nota_aprob,
            obs=request.form.get('obs', '').strip(),
            creado=date.today(), act=date.today()
        )
        obj.calcular_final()
        db.session.add(obj)
        db.session.commit()
        flash('Calificación registrada.', 'success')
        return redirect(url_for('cal.index'))
    return render_template('cal/form.html', obj=None, inscripciones=inscripciones, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('cal_editar')
def editar(id):
    obj = Ins.query.get_or_404(id) if False else Cal.query.get_or_404(id)
    inscripciones = Ins.query.filter_by(inscrito=True).all()
    if request.method == 'POST':
        obj.nota1      = request.form.get('nota1', 0, type=int)
        obj.nota2      = request.form.get('nota2', 0, type=int)
        obj.nota3      = request.form.get('nota3', 0, type=int)
        obj.nota_aprob = request.form.get('nota_aprob', 51, type=int)
        obj.obs        = request.form.get('obs', '').strip()
        obj.act        = date.today()
        obj.calcular_final()
        db.session.commit()
        flash('Calificación actualizada.', 'success')
        return redirect(url_for('cal.index'))
    return render_template('cal/form.html', obj=obj, inscripciones=inscripciones, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('cal_eliminar')
def eliminar(id):
    obj = Cal.query.get_or_404(id)
    db.session.delete(obj)
    db.session.commit()
    flash('Calificación eliminada.', 'success')
    return redirect(url_for('cal.index'))


@bp.route('/materias-por-inscripcion/<int:ins_id>')
@login_required
def materias_por_inscripcion(ins_id):
    """HTMX: retorna materias del grado del curso de la inscripción."""
    ins = Ins.query.get_or_404(ins_id)
    materias = Mat.query.filter_by(gra_id=ins.curso_obj.gra_id).all() if ins.curso_obj else []
    opts = ''.join(f'<option value="{m.id}">{m.materia}</option>' for m in materias)
    return f'<option value="">-- Materia --</option>{opts}'
