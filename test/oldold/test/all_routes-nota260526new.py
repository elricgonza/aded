python3 - << 'PYEOF'
with open('/home/ric/aded/test/260525old/test/all_routes.py', 'r') as f:
    content = f.read()

old = """nota_bp = Blueprint('nota', __name__, url_prefix='/nota')

@nota_bp.route('/')
@login_required
@permission_required('nota_ver')
def index():
    cur_id = request.args.get('cur_id', type=int)
    cursos = Curso.query.order_by(Curso.gestion.desc(), Curso.paralelo).all()
    notas  = []
    if cur_id:
        notas = (Nota.query
                 .join(Inscrito).filter(Inscrito.cur_id == cur_id)
                 .join(Materia).join(Alumno, Inscrito.alu_id == Alumno.id)
                 .order_by(Alumno.paterno, Materia.materia).all())
    return render_template('nota/index.html', notas=notas, cursos=cursos, cur_id=cur_id)

@nota_bp.route('/nueva', methods=['GET', 'POST'])
@login_required
@permission_required('nota_crear')
def nueva():
    inscritos = Inscrito.query.filter_by(inscrito=True).all()
    materias  = Materia.query.all()
    if request.method == 'POST':
        n1 = int(request.form.get('nota1', 0))
        n2 = int(request.form.get('nota2', 0))
        n3 = int(request.form.get('nota3', 0))
        nota_final = round((n1 + n2 + n3) / 3, 1)
        aprob = int(request.form.get('nota_aprob', 51))
        n = Nota(
            ins_id=int(request.form['ins_id']), mat_id=int(request.form['mat_id']),
            nota1=n1, nota2=n2, nota3=n3,
            nota_final=nota_final, nota_aprob=aprob,
            aprobado=nota_final >= aprob,
            obs=request.form.get('obs'),
            creado=date.today(), act=date.today(), usu_id=current_user.id
        )
        db.session.add(n); db.session.commit()
        flash('Nota registrada.', 'success')
        return redirect(url_for('nota.index'))
    return render_template('nota/form.html', nota=None, inscritos=inscritos, materias=materias)

@nota_bp.route('/<int:id>/editar', methods=['GET', 'POST'])
@login_required
@permission_required('nota_editar')
def editar(id):
    n = Nota.query.get_or_404(id)
    inscritos = Inscrito.query.filter_by(inscrito=True).all()
    materias  = Materia.query.all()
    if request.method == 'POST':
        n.nota1 = int(request.form.get('nota1', 0))
        n.nota2 = int(request.form.get('nota2', 0))
        n.nota3 = int(request.form.get('nota3', 0))
        n.nota_final = round((n.nota1 + n.nota2 + n.nota3) / 3, 1)
        n.nota_aprob = int(request.form.get('nota_aprob', 51))
        n.aprobado = n.nota_final >= n.nota_aprob
        n.obs = request.form.get('obs'); n.act = date.today()
        db.session.commit(); flash('Nota actualizada.', 'success')
        return redirect(url_for('nota.index'))
    return render_template('nota/form.html', nota=n, inscritos=inscritos, materias=materias)"""

new = """nota_bp = Blueprint('nota', __name__, url_prefix='/nota')


def _profesor_actual():
    \"\"\"Retorna el Profesor vinculado al usuario en sesión, o None.\"\"\"
    return Profesor.query.filter_by(usr_id_login=current_user.id).first()


def _asignaciones_profesor(profesor):
    \"\"\"Retorna la lista de Asignado del profesor o [] si no existe.\"\"\"
    if not profesor:
        return []
    return Asignado.query.filter_by(pro_id=profesor.id).all()


def _puede_editar_nota(nota):
    \"\"\"Verifica si el usuario en sesión puede editar esta nota específica.\"\"\"
    # admin y transcriptor: sin restricción
    if current_user.has_role('administrador') or current_user.has_role('transcriptor'):
        return True
    if current_user.has_role('profesor'):
        profesor = _profesor_actual()
        if not profesor:
            return False
        # Debe tener Asignado con ese cur_id + mat_id
        cur_id = nota.inscrito.cur_id
        return Asignado.query.filter_by(
            pro_id=profesor.id,
            cur_id=cur_id,
            mat_id=nota.mat_id
        ).first() is not None
    return False


@nota_bp.route('/')
@login_required
@permission_required('nota_ver')
def index():
    es_profesor = current_user.has_role('profesor')
    profesor    = _profesor_actual() if es_profesor else None

    cur_id = request.args.get('cur_id', type=int)
    mat_id = request.args.get('mat_id', type=int)
    q      = request.args.get('q', '').strip()
    page   = request.args.get('page', 1, type=int)

    # Cursos disponibles según rol
    if es_profesor and profesor:
        asig_ids = [a.cur_id for a in _asignaciones_profesor(profesor)]
        cursos   = Curso.query.filter(Curso.id.in_(asig_ids)).order_by(
                       Curso.gestion.desc(), Curso.paralelo).all()
        # Si el profesor no seleccionó curso, auto-seleccionar el primero
        if not cur_id and cursos:
            cur_id = cursos[0].id
    else:
        cursos = Curso.query.order_by(Curso.gestion.desc(), Curso.paralelo).all()

    # Materias disponibles para el filtro (filtradas por curso si aplica)
    if cur_id and es_profesor and profesor:
        mat_ids  = [a.mat_id for a in Asignado.query.filter_by(
                       pro_id=profesor.id, cur_id=cur_id).all()]
        materias = Materia.query.filter(Materia.id.in_(mat_ids)).order_by(Materia.materia).all()
    elif cur_id:
        mat_ids  = [a.mat_id for a in Asignado.query.filter_by(cur_id=cur_id).all()]
        materias = Materia.query.filter(Materia.id.in_(mat_ids)).order_by(Materia.materia).all()
    else:
        materias = []

    # Query base
    query = (Nota.query
             .join(Inscrito, Nota.ins_id == Inscrito.id)
             .join(Alumno,   Inscrito.alu_id == Alumno.id)
             .join(Materia,  Nota.mat_id == Materia.id))

    if cur_id:
        query = query.filter(Inscrito.cur_id == cur_id)

    # Restricción adicional para profesor: solo sus materias asignadas en ese curso
    if es_profesor and profesor and cur_id:
        query = query.filter(Nota.mat_id.in_([m.id for m in materias]))

    if mat_id:
        query = query.filter(Nota.mat_id == mat_id)

    if q:
        query = query.filter(
            db.or_(
                Alumno.nombre.ilike(f'%{q}%'),
                Alumno.paterno.ilike(f'%{q}%'),
                Alumno.materno.ilike(f'%{q}%'),
                Materia.materia.ilike(f'%{q}%'),
            )
        )

    query = query.order_by(Alumno.paterno, Alumno.nombre, Materia.materia)
    pagination = query.paginate(page=page, per_page=PER_PAGE, error_out=False)

    return render_template('nota/index.html',
                           notas=pagination.items,
                           pagination=pagination,
                           cursos=cursos,
                           materias=materias,
                           cur_id=cur_id,
                           mat_id=mat_id,
                           q=q,
                           total=pagination.total,
                           es_profesor=es_profesor,
                           profesor=profesor)


@nota_bp.route('/nueva', methods=['GET', 'POST'])
@login_required
@permission_required('nota_crear')
def nueva():
    es_profesor = current_user.has_role('profesor')
    profesor    = _profesor_actual() if es_profesor else None

    if es_profesor and not profesor:
        flash('Su usuario no tiene un profesor vinculado. Contacte al administrador.', 'danger')
        return redirect(url_for('nota.index'))

    if es_profesor:
        asignaciones = _asignaciones_profesor(profesor)
        cur_ids  = list({a.cur_id for a in asignaciones})
        mat_ids  = list({a.mat_id for a in asignaciones})
        inscritos = (Inscrito.query
                     .filter(Inscrito.inscrito == True, Inscrito.cur_id.in_(cur_ids))
                     .all())
        materias  = Materia.query.filter(Materia.id.in_(mat_ids)).order_by(Materia.materia).all()
        # pares válidos (cur_id, mat_id) para validar en POST
        pares_validos = {(a.cur_id, a.mat_id) for a in asignaciones}
    else:
        inscritos = Inscrito.query.filter_by(inscrito=True).all()
        materias  = Materia.query.order_by(Materia.materia).all()
        pares_validos = None

    if request.method == 'POST':
        ins_id = int(request.form['ins_id'])
        mat_id = int(request.form['mat_id'])

        # Validar restricción de profesor
        if es_profesor and pares_validos:
            ins = Inscrito.query.get(ins_id)
            if not ins or (ins.cur_id, mat_id) not in pares_validos:
                flash('No tiene permiso para registrar notas en esa combinación de curso/materia.', 'danger')
                return redirect(url_for('nota.index'))

        n1 = int(request.form.get('nota1', 0))
        n2 = int(request.form.get('nota2', 0))
        n3 = int(request.form.get('nota3', 0))
        nota_final = round((n1 + n2 + n3) / 3, 1)
        aprob = int(request.form.get('nota_aprob', 51))
        n = Nota(
            ins_id=ins_id, mat_id=mat_id,
            nota1=n1, nota2=n2, nota3=n3,
            nota_final=nota_final, nota_aprob=aprob,
            aprobado=nota_final >= aprob,
            obs=request.form.get('obs'),
            creado=date.today(), act=date.today(), usu_id=current_user.id
        )
        db.session.add(n); db.session.commit()
        flash('Nota registrada.', 'success')
        return redirect(url_for('nota.index'))

    return render_template('nota/form.html', nota=None,
                           inscritos=inscritos, materias=materias,
                           es_profesor=es_profesor)


@nota_bp.route('/<int:id>/editar', methods=['GET', 'POST'])
@login_required
@permission_required('nota_editar')
def editar(id):
    n = Nota.query.get_or_404(id)

    if not _puede_editar_nota(n):
        flash('No tiene permiso para editar esta calificación.', 'danger')
        return redirect(url_for('nota.index'))

    es_profesor = current_user.has_role('profesor')
    profesor    = _profesor_actual() if es_profesor else None

    if es_profesor and profesor:
        asignaciones = _asignaciones_profesor(profesor)
        cur_ids  = list({a.cur_id for a in asignaciones})
        mat_ids  = list({a.mat_id for a in asignaciones})
        inscritos = (Inscrito.query
                     .filter(Inscrito.inscrito == True, Inscrito.cur_id.in_(cur_ids))
                     .all())
        materias  = Materia.query.filter(Materia.id.in_(mat_ids)).order_by(Materia.materia).all()
        pares_validos = {(a.cur_id, a.mat_id) for a in asignaciones}
    else:
        inscritos = Inscrito.query.filter_by(inscrito=True).all()
        materias  = Materia.query.order_by(Materia.materia).all()
        pares_validos = None

    if request.method == 'POST':
        if es_profesor and pares_validos:
            ins = Inscrito.query.get(n.ins_id)
            mat_id_post = int(request.form.get('mat_id', n.mat_id))
            if not ins or (ins.cur_id, mat_id_post) not in pares_validos:
                flash('No tiene permiso para editar notas en esa combinación de curso/materia.', 'danger')
                return redirect(url_for('nota.index'))

        n.nota1      = int(request.form.get('nota1', 0))
        n.nota2      = int(request.form.get('nota2', 0))
        n.nota3      = int(request.form.get('nota3', 0))
        n.nota_final = round((n.nota1 + n.nota2 + n.nota3) / 3, 1)
        n.nota_aprob = int(request.form.get('nota_aprob', 51))
        n.aprobado   = n.nota_final >= n.nota_aprob
        n.obs        = request.form.get('obs')
        n.act        = date.today()
        db.session.commit()
        flash('Nota actualizada.', 'success')
        return redirect(url_for('nota.index', cur_id=n.inscrito.cur_id))

    return render_template('nota/form.html', nota=n,
                           inscritos=inscritos, materias=materias,
                           es_profesor=es_profesor)"""

if old in content:
    content = content.replace(old, new)
    with open('/home/ric/aded/test/260525old/test/all_routes.py', 'w') as f:
        f.write(content)
    print("OK")
else:
    print("NOT FOUND")
PYEOF
