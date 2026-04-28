from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required
from app.models import Usr, Rol, Per, UsrRol, RolPer
from app import db
from datetime import date, datetime
from app.utils.permisos import requiere_permiso, PERMISOS, ROLES_PERMISOS

bp = Blueprint('usr', __name__)
PER_PAGE = 15


@bp.route('/')
@login_required
@requiere_permiso('usr_ver')
def index():
    page  = request.args.get('page', 1, type=int)
    query = Usr.query.order_by(Usr.usuario)
    pagination = query.paginate(page=page, per_page=PER_PAGE)
    roles = Rol.query.order_by(Rol.rol).all()
    return render_template('usr/index.html', items=pagination.items, pagination=pagination, roles=roles)


@bp.route('/nuevo', methods=['GET', 'POST'])
@login_required
@requiere_permiso('usr_crear')
def nuevo():
    roles = Rol.query.order_by(Rol.rol).all()
    if request.method == 'POST':
        pw = request.form.get('password', '')
        usr = Usr(
            usuario=request.form.get('usuario', '').strip(),
            email=request.form.get('email', '').strip(),
            activo=bool(request.form.get('activo')),
            ultimo_ingreso=date.today(),
            creado=datetime.utcnow()
        )
        usr.set_password(pw)
        db.session.add(usr)
        db.session.flush()
        rol_ids = request.form.getlist('roles', type=int)
        for rid in rol_ids:
            db.session.add(UsrRol(usr_id=usr.id, rol_id=rid))
        db.session.commit()
        flash('Usuario creado.', 'success')
        return redirect(url_for('usr.index'))
    return render_template('usr/form.html', obj=None, roles=roles, accion='Crear')


@bp.route('/editar/<int:id>', methods=['GET', 'POST'])
@login_required
@requiere_permiso('usr_editar')
def editar(id):
    usr   = Usr.query.get_or_404(id)
    roles = Rol.query.order_by(Rol.rol).all()
    if request.method == 'POST':
        usr.usuario = request.form.get('usuario', '').strip()
        usr.email   = request.form.get('email', '').strip()
        usr.activo  = bool(request.form.get('activo'))
        usr.act     = datetime.utcnow()
        pw = request.form.get('password', '')
        if pw:
            usr.set_password(pw)
        UsrRol.query.filter_by(usr_id=usr.id).delete()
        for rid in request.form.getlist('roles', type=int):
            db.session.add(UsrRol(usr_id=usr.id, rol_id=rid))
        db.session.commit()
        flash('Usuario actualizado.', 'success')
        return redirect(url_for('usr.index'))
    return render_template('usr/form.html', obj=usr, roles=roles, accion='Editar')


@bp.route('/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('usr_eliminar')
def eliminar(id):
    usr = Usr.query.get_or_404(id)
    UsrRol.query.filter_by(usr_id=usr.id).delete()
    db.session.delete(usr)
    db.session.commit()
    flash('Usuario eliminado.', 'success')
    return redirect(url_for('usr.index'))


# ── Roles ──────────────────────────────────────────────────────────────────────

@bp.route('/roles')
@login_required
@requiere_permiso('usr_ver')
def roles():
    items = Rol.query.order_by(Rol.rol).all()
    permisos = Per.query.order_by(Per.permiso).all()
    return render_template('usr/roles.html', items=items, permisos=permisos)


@bp.route('/roles/nuevo', methods=['POST'])
@login_required
@requiere_permiso('usr_crear')
def rol_nuevo():
    nombre = request.form.get('rol', '').strip()
    if not nombre:
        flash('Nombre de rol requerido.', 'danger')
        return redirect(url_for('usr.roles'))
    rol = Rol(rol=nombre, descripcion=request.form.get('descripcion', ''),
              creado=datetime.utcnow())
    db.session.add(rol)
    db.session.flush()
    for pid in request.form.getlist('permisos', type=int):
        db.session.add(RolPer(rol_id=rol.id, per_id=pid))
    db.session.commit()
    flash('Rol creado.', 'success')
    return redirect(url_for('usr.roles'))


@bp.route('/roles/eliminar/<int:id>', methods=['POST'])
@login_required
@requiere_permiso('usr_eliminar')
def rol_eliminar(id):
    rol = Rol.query.get_or_404(id)
    RolPer.query.filter_by(rol_id=id).delete()
    UsrRol.query.filter_by(rol_id=id).delete()
    db.session.delete(rol)
    db.session.commit()
    flash('Rol eliminado.', 'success')
    return redirect(url_for('usr.roles'))


@bp.route('/inicializar-datos')
@login_required
@requiere_permiso('usr_crear')
def inicializar_datos():
    """Crea roles, permisos y usuario admin si no existen."""
    from app.utils.permisos import PERMISOS, ROLES_PERMISOS
    # Crear permisos
    todos_permisos = [p for perms in PERMISOS.values() for p in perms]
    for nombre_p in todos_permisos:
        if not Per.query.filter_by(permiso=nombre_p).first():
            db.session.add(Per(permiso=nombre_p, descripcion=nombre_p))
    db.session.commit()
    # Crear roles y asignar permisos
    for nombre_rol, lista_permisos in ROLES_PERMISOS.items():
        rol = Rol.query.filter_by(rol=nombre_rol).first()
        if not rol:
            rol = Rol(rol=nombre_rol, descripcion=f'Rol {nombre_rol}', creado=datetime.utcnow())
            db.session.add(rol)
            db.session.flush()
        RolPer.query.filter_by(rol_id=rol.id).delete()
        for perm_nombre in lista_permisos:
            per = Per.query.filter_by(permiso=perm_nombre).first()
            if per:
                db.session.add(RolPer(rol_id=rol.id, per_id=per.id))
    db.session.commit()
    # Crear admin si no existe
    if not Usr.query.filter_by(usuario='admin').first():
        admin = Usr(
            usuario='admin', email='admin@escuela.edu',
            activo=True, ultimo_ingreso=date.today(), creado=datetime.utcnow()
        )
        admin.set_password('Admin1234!')
        db.session.add(admin)
        db.session.flush()
        rol_admin = Rol.query.filter_by(rol='Administrador').first()
        if rol_admin:
            db.session.add(UsrRol(usr_id=admin.id, rol_id=rol_admin.id))
        db.session.commit()
        flash('Usuario admin creado (admin / Admin1234!). Cambia la contraseña.', 'warning')
    flash('Roles y permisos inicializados.', 'success')
    return redirect(url_for('usr.index'))
