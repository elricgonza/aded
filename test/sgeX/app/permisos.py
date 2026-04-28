from functools import wraps
from flask import abort
from flask_login import current_user


def requiere_permiso(permiso):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            if not current_user.tiene_permiso(permiso):
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator


def requiere_rol(rol):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            if not current_user.tiene_rol(rol):
                abort(403)
            return f(*args, **kwargs)
        return decorated
    return decorator


# Permisos estándar por módulo
PERMISOS = {
    'ges':  ['ges_ver', 'ges_crear', 'ges_editar', 'ges_eliminar'],
    'gra':  ['gra_ver', 'gra_crear', 'gra_editar', 'gra_eliminar'],
    'mat':  ['mat_ver', 'mat_crear', 'mat_editar', 'mat_eliminar'],
    'pro':  ['pro_ver', 'pro_crear', 'pro_editar', 'pro_eliminar'],
    'cur':  ['cur_ver', 'cur_crear', 'cur_editar', 'cur_eliminar'],
    'asi':  ['asi_ver', 'asi_crear', 'asi_editar', 'asi_eliminar'],
    'est':  ['est_ver', 'est_crear', 'est_editar', 'est_eliminar'],
    'ins':  ['ins_ver', 'ins_crear', 'ins_editar', 'ins_eliminar'],
    'cal':  ['cal_ver', 'cal_crear', 'cal_editar', 'cal_eliminar'],
    'cos':  ['cos_ver', 'cos_crear', 'cos_editar', 'cos_eliminar'],
    'pag':  ['pag_ver', 'pag_crear', 'pag_editar', 'pag_eliminar'],
    'usr':  ['usr_ver', 'usr_crear', 'usr_editar', 'usr_eliminar'],
}


# Permisos por rol predefinido
ROLES_PERMISOS = {
    'Administrador': [p for perms in PERMISOS.values() for p in perms],
    'Profesor': [
        'cal_ver', 'cal_crear', 'cal_editar',
        'est_ver', 'ins_ver', 'asi_ver',
    ],
    'Estudiante': [
        'cal_ver', 'ins_ver', 'pag_ver',
    ],
    'Consulta': [
        'ges_ver', 'gra_ver', 'mat_ver', 'pro_ver', 'cur_ver',
        'asi_ver', 'est_ver', 'ins_ver', 'cal_ver', 'cos_ver', 'pag_ver',
    ],
    'Transcripcion': [
        'cal_ver', 'cal_crear', 'cal_editar',
        'est_ver', 'ins_ver', 'cur_ver',
    ],
}
