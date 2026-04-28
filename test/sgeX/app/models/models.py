from datetime import date, datetime
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from app import db


# ── Auth Models ────────────────────────────────────────────────────────────────

class Usr(UserMixin, db.Model):
    __tablename__ = 'usr'
    id             = db.Column(db.Integer, primary_key=True)
    usuario        = db.Column(db.String(80), unique=True, nullable=False)
    email          = db.Column(db.String(120), nullable=False)
    password       = db.Column(db.String(255), nullable=False)
    activo         = db.Column(db.Boolean, default=True)
    ultimo_ingreso = db.Column(db.Date, nullable=False, default=date.today)
    creado         = db.Column(db.DateTime, default=datetime.utcnow)
    act            = db.Column(db.DateTime, onupdate=datetime.utcnow)

    roles = db.relationship('Rol', secondary='usr_rol', backref='usuarios', lazy='dynamic')

    def set_password(self, pw):
        self.password = generate_password_hash(pw)

    def check_password(self, pw):
        return check_password_hash(self.password, pw)

    def tiene_rol(self, nombre_rol):
        return self.roles.filter_by(rol=nombre_rol).count() > 0

    def tiene_permiso(self, nombre_permiso):
        for rol in self.roles:
            for per in rol.permisos:
                if per.permiso == nombre_permiso:
                    return True
        return False

    def __repr__(self):
        return f'<Usr {self.usuario}>'


class Rol(db.Model):
    __tablename__ = 'rol'
    id          = db.Column(db.Integer, primary_key=True)
    rol         = db.Column(db.String(50), unique=True, nullable=False)
    descripcion = db.Column(db.String(255))
    creado      = db.Column(db.DateTime, default=datetime.utcnow)
    act         = db.Column(db.Date)

    permisos = db.relationship('Per', secondary='rol_per', backref='roles', lazy='subquery')


class Per(db.Model):
    __tablename__ = 'per'
    id          = db.Column(db.Integer, primary_key=True)
    permiso     = db.Column(db.String(50), unique=True, nullable=False)
    descripcion = db.Column(db.String(255))
    creado      = db.Column(db.DateTime, default=datetime.utcnow)
    act         = db.Column(db.DateTime, onupdate=datetime.utcnow)


class UsrRol(db.Model):
    __tablename__ = 'usr_rol'
    usr_id = db.Column(db.Integer, db.ForeignKey('usr.id'), primary_key=True)
    rol_id = db.Column(db.Integer, db.ForeignKey('rol.id'), primary_key=True)


class RolPer(db.Model):
    __tablename__ = 'rol_per'
    rol_id = db.Column(db.Integer, db.ForeignKey('rol.id'), primary_key=True)
    per_id = db.Column(db.Integer, db.ForeignKey('per.id'), primary_key=True)


# ── Academic Models ────────────────────────────────────────────────────────────

class Ges(db.Model):
    __tablename__ = 'ges'
    id      = db.Column(db.Integer, primary_key=True)
    gestion = db.Column(db.SmallInteger)
    plan    = db.Column(db.String(150), nullable=False)
    inicio  = db.Column(db.Date, nullable=False)
    fin     = db.Column(db.Date, nullable=False)
    activo  = db.Column(db.Boolean, nullable=False, default=True)
    creado  = db.Column(db.Date, nullable=False, default=date.today)
    act     = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    grados = db.relationship('Gra', backref='gestion_obj', lazy='dynamic')

    def __repr__(self):
        return f'<Ges {self.gestion}>'


class Gra(db.Model):
    __tablename__ = 'gra'
    id     = db.Column(db.Integer, primary_key=True)
    grado  = db.Column(db.String(255), nullable=False)
    nivel  = db.Column(db.String(150), nullable=False)
    id_ges = db.Column(db.Integer, db.ForeignKey('ges.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    creado = db.Column(db.Date, nullable=False, default=date.today)
    act    = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    materias = db.relationship('Mat', backref='grado_obj', lazy='dynamic')
    cursos   = db.relationship('Cur', backref='grado_obj', lazy='dynamic')

    def __repr__(self):
        return f'<Gra {self.nivel} - {self.grado}>'


class Mat(db.Model):
    __tablename__ = 'mat'
    id      = db.Column(db.Integer, primary_key=True)
    materia = db.Column(db.String(150), nullable=False)
    gra_id  = db.Column(db.Integer, db.ForeignKey('gra.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    creado  = db.Column(db.Date, nullable=False, default=date.today)
    act     = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    def __repr__(self):
        return f'<Mat {self.materia}>'


class Pro(db.Model):
    __tablename__ = 'pro'
    id        = db.Column(db.Integer, primary_key=True)
    nombre    = db.Column(db.String(100), nullable=False)
    paterno   = db.Column(db.String(50))
    materno   = db.Column(db.String(50))
    formacion = db.Column(db.String(100))
    activo    = db.Column(db.Boolean, nullable=False, default=True)
    creado    = db.Column(db.Date, nullable=False, default=date.today)
    act       = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    @property
    def nombre_completo(self):
        return f'{self.paterno or ""} {self.materno or ""} {self.nombre}'.strip()

    def __repr__(self):
        return f'<Pro {self.nombre_completo}>'


class Cur(db.Model):
    __tablename__ = 'cur'
    id        = db.Column(db.Integer, primary_key=True)
    curso     = db.Column(db.String(150))
    paralelo  = db.Column(db.String(50), nullable=False)
    gra_id    = db.Column(db.Integer, db.ForeignKey('gra.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    aula      = db.Column(db.String(50))
    capacidad = db.Column(db.SmallInteger)
    gestion   = db.Column(db.SmallInteger, nullable=False)
    creado    = db.Column(db.Date, nullable=False, default=date.today)
    act       = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    inscripciones = db.relationship('Ins', backref='curso_obj', lazy='dynamic')
    asignaciones  = db.relationship('Asi', backref='curso_obj', lazy='dynamic')
    costos        = db.relationship('Cos', backref='curso_obj', lazy='dynamic')

    @property
    def nombre_completo(self):
        return f'{self.curso or ""} ({self.paralelo}) - {self.gestion}'

    def __repr__(self):
        return f'<Cur {self.nombre_completo}>'


class Asi(db.Model):
    __tablename__ = 'asi'
    id     = db.Column(db.Integer, primary_key=True)
    cur_id = db.Column(db.Integer, db.ForeignKey('cur.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    mat_id = db.Column(db.Integer, db.ForeignKey('mat.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    pro_id = db.Column(db.Integer, db.ForeignKey('pro.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    creado = db.Column(db.Date, nullable=False, default=date.today)
    act    = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    curso   = db.relationship('Cur', foreign_keys=[cur_id])
    materia = db.relationship('Mat', foreign_keys=[mat_id])
    profesor = db.relationship('Pro', foreign_keys=[pro_id])


class Est(db.Model):
    __tablename__ = 'est'
    id         = db.Column(db.Integer, primary_key=True)
    nombre     = db.Column(db.String(100), nullable=False)
    paterno    = db.Column(db.String(100))
    materno    = db.Column(db.String(100))
    nacimiento = db.Column(db.Date)
    masculino  = db.Column(db.Boolean, nullable=False, default=True)
    ci         = db.Column(db.Integer)
    direccion  = db.Column(db.String(150))
    activo     = db.Column(db.Boolean, nullable=False, default=True)
    obs        = db.Column(db.String(100))
    creado     = db.Column(db.Date, nullable=False, default=date.today)
    act        = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    inscripcion = db.relationship('Ins', backref='estudiante', uselist=False)

    @property
    def nombre_completo(self):
        return f'{self.paterno or ""} {self.materno or ""} {self.nombre}'.strip()

    def __repr__(self):
        return f'<Est {self.nombre_completo}>'


class Ins(db.Model):
    __tablename__ = 'ins'
    id           = db.Column(db.Integer, primary_key=True)
    est_id       = db.Column(db.Integer, db.ForeignKey('est.id', ondelete='SET NULL', onupdate='CASCADE'), unique=True)
    cur_id       = db.Column(db.Integer, db.ForeignKey('cur.id', ondelete='SET NULL', onupdate='CASCADE'))
    reserva      = db.Column(db.Boolean)
    inscrito     = db.Column(db.Boolean, nullable=False, default=False)
    descu        = db.Column(db.SmallInteger, nullable=False, default=0)
    motivo_descu = db.Column(db.String(100))
    abandono     = db.Column(db.Boolean, nullable=False, default=False)
    obs          = db.Column(db.String(200))
    creado       = db.Column(db.Date, nullable=False, default=date.today)
    act          = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    calificaciones = db.relationship('Cal', backref='inscripcion', lazy='dynamic')
    pagos          = db.relationship('Pag', backref='inscripcion', lazy='dynamic')

    def generar_plan_pagos(self):
        """Genera las filas de pago según cos del curso, aplicando descuento."""
        cos = Cos.query.filter_by(cur_id=self.cur_id).first()
        if not cos:
            return
        # Eliminar plan anterior si existe
        Pag.query.filter_by(ins_id=self.id).delete()
        descuento = self.descu or 0
        cuota_con_descu = float(cos.cuota) * (1 - descuento / 100)
        for n in range(1, cos.nro_cuota + 1):
            pago = Pag(
                ins_id=self.id,
                nro_cuota=n,
                cuota=round(cuota_con_descu, 2),
                pagado=False,
                creado=date.today(),
                act=date.today()
            )
            db.session.add(pago)
        db.session.commit()


class Cal(db.Model):
    __tablename__ = 'cal'
    id          = db.Column(db.Integer, primary_key=True)
    ins_id      = db.Column(db.Integer, db.ForeignKey('ins.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    mat_id      = db.Column(db.Integer, db.ForeignKey('mat.id'), nullable=False)
    nota1       = db.Column(db.SmallInteger, nullable=False, default=0)
    nota2       = db.Column(db.SmallInteger, nullable=False, default=0)
    nota3       = db.Column(db.SmallInteger, nullable=False, default=0)
    nota_final  = db.Column(db.Numeric(5, 1), nullable=False, default=0)
    nota_aprob  = db.Column(db.SmallInteger, nullable=False, default=51)
    aprobado    = db.Column(db.Boolean)
    obs         = db.Column(db.String(150))
    creado      = db.Column(db.Date, nullable=False, default=date.today)
    act         = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    materia = db.relationship('Mat', foreign_keys=[mat_id])

    def calcular_final(self):
        self.nota_final = round((self.nota1 + self.nota2 + self.nota3) / 3, 1)
        self.aprobado = float(self.nota_final) >= self.nota_aprob


class Cos(db.Model):
    __tablename__ = 'cos'
    id        = db.Column(db.Integer, primary_key=True)
    cur_id    = db.Column(db.Integer, db.ForeignKey('cur.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    nro_cuota = db.Column(db.SmallInteger, nullable=False)
    cuota     = db.Column(db.Numeric(10, 2), nullable=False)
    obs       = db.Column(db.String(200), nullable=False)
    creado    = db.Column(db.Date, nullable=False, default=date.today)
    act       = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)

    def __repr__(self):
        return f'<Cos {self.nro_cuota} cuotas x {self.cuota}>'


class Pag(db.Model):
    __tablename__ = 'pag'
    id             = db.Column(db.Integer, primary_key=True)
    ins_id         = db.Column(db.Integer, db.ForeignKey('ins.id', ondelete='RESTRICT', onupdate='CASCADE'), nullable=False)
    nro_cuota      = db.Column(db.SmallInteger, nullable=False)
    cuota          = db.Column(db.Float, nullable=False)
    pagado         = db.Column(db.Boolean, default=False)
    fecha_pago     = db.Column(db.Date)
    monto_pagado   = db.Column(db.Float)
    metodo_pago    = db.Column(db.String(50))
    nro_comprobante= db.Column(db.String(50))
    obs            = db.Column(db.String(100))
    creado         = db.Column(db.Date, nullable=False, default=date.today)
    act            = db.Column(db.Date, nullable=False, default=date.today, onupdate=date.today)
