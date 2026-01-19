"""
Base de Datos Local SQLite
Sincroniza con Google Sheets para respaldo y funcionalidades offline.
"""
import sqlite3
import os
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

# Ruta de la base de datos
DB_PATH = os.path.join(os.path.dirname(__file__), "finanzas.db")

def get_connection():
    """Obtiene conexión a SQLite."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # Para acceder por nombre de columna
    return conn

def init_database():
    """Inicializa todas las tablas."""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Tabla de Gastos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS gastos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            concepto TEXT,
            monto_original REAL,
            moneda TEXT DEFAULT 'Bs',
            monto_usd REAL,
            categoria TEXT,
            referencia TEXT,
            responsable TEXT,
            imagen_url TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            synced_to_sheets INTEGER DEFAULT 1
        )
    """)
    
    # Tabla de Ingresos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ingresos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            concepto TEXT,
            monto_original REAL,
            moneda TEXT DEFAULT 'Bs',
            monto_usd REAL,
            categoria TEXT,
            responsable TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            synced_to_sheets INTEGER DEFAULT 1
        )
    """)
    
    # Tabla de Ahorros
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ahorros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meta TEXT UNIQUE NOT NULL,
            objetivo_usd REAL DEFAULT 0,
            ahorrado_actual REAL DEFAULT 0,
            porcentaje TEXT,
            hitos TEXT,
            ultima_actualizacion TEXT,
            ultimo_usuario TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Movimientos de Ahorro (historial)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ahorro_movimientos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meta TEXT NOT NULL,
            monto REAL NOT NULL,
            tipo TEXT CHECK(tipo IN ('deposito', 'retiro')),
            usuario TEXT,
            fecha TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Deudas
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS deudas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            persona TEXT NOT NULL,
            monto REAL NOT NULL,
            fecha_prestamo TEXT,
            fecha_retorno TEXT,
            responsable TEXT,
            estado TEXT DEFAULT 'pendiente',
            fecha_pago TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Gastos Recurrentes
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS recurrentes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            monto REAL NOT NULL,
            dia_pago INTEGER,
            ultimo_pago TEXT,
            activo INTEGER DEFAULT 1,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Chats (para notificaciones)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS chats (
            id INTEGER PRIMARY KEY,
            chat_id INTEGER UNIQUE NOT NULL,
            chat_type TEXT,
            chat_title TEXT,
            registered_at TEXT DEFAULT CURRENT_TIMESTAMP,
            notifications_enabled INTEGER DEFAULT 1
        )
    """)
    
    # Tabla de Configuración
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS configuracion (
            clave TEXT PRIMARY KEY,
            valor TEXT,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Presupuestos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS presupuestos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoria TEXT UNIQUE NOT NULL,
            limite REAL NOT NULL,
            mes TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Cache de Tasas
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasas_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fuente TEXT NOT NULL,
            tasa REAL NOT NULL,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    conn.close()
    logger.info("Base de datos SQLite inicializada correctamente.")

# ==================== GASTOS ====================

def add_gasto(fecha, concepto, monto_original, moneda, monto_usd, categoria, referencia, responsable, imagen_url=None):
    """Guarda un gasto en SQLite."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO gastos (fecha, concepto, monto_original, moneda, monto_usd, categoria, referencia, responsable, imagen_url)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (fecha, concepto, monto_original, moneda, monto_usd, categoria, referencia, responsable, imagen_url))
        conn.commit()
        gasto_id = cursor.lastrowid
        conn.close()
        return gasto_id
    except Exception as e:
        logger.error(f"Error add_gasto SQLite: {e}")
        return None

def get_gastos_mes(year=None, month=None):
    """Obtiene gastos del mes."""
    if not year: year = datetime.now().year
    if not month: month = datetime.now().month
    
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT * FROM gastos 
        WHERE strftime('%Y', fecha) = ? AND strftime('%m', fecha) = ?
        ORDER BY fecha DESC
    """, (str(year), f"{month:02d}"))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

def check_duplicate_gasto(fecha, monto, referencia=None):
    """Verifica si ya existe un gasto similar."""
    conn = get_connection()
    cursor = conn.cursor()
    
    if referencia:
        cursor.execute("SELECT id FROM gastos WHERE referencia = ?", (referencia,))
    else:
        cursor.execute("SELECT id FROM gastos WHERE fecha = ? AND monto_usd = ?", (fecha, monto))
    
    result = cursor.fetchone()
    conn.close()
    return result is not None

# ==================== INGRESOS ====================

def add_ingreso(fecha, concepto, monto_original, moneda, monto_usd, categoria, responsable):
    """Guarda un ingreso en SQLite."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO ingresos (fecha, concepto, monto_original, moneda, monto_usd, categoria, responsable)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (fecha, concepto, monto_original, moneda, monto_usd, categoria, responsable))
        conn.commit()
        ingreso_id = cursor.lastrowid
        conn.close()
        return ingreso_id
    except Exception as e:
        logger.error(f"Error add_ingreso SQLite: {e}")
        return None

def get_ingresos_mes(year=None, month=None):
    """Obtiene ingresos del mes."""
    if not year: year = datetime.now().year
    if not month: month = datetime.now().month
    
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT * FROM ingresos 
        WHERE strftime('%Y', fecha) = ? AND strftime('%m', fecha) = ?
        ORDER BY fecha DESC
    """, (str(year), f"{month:02d}"))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

# ==================== AHORROS ====================

def upsert_ahorro(meta, objetivo=None, ahorrado=None, usuario=None):
    """Crea o actualiza una meta de ahorro."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        
        # Verificar si existe
        cursor.execute("SELECT * FROM ahorros WHERE LOWER(meta) = LOWER(?)", (meta,))
        existing = cursor.fetchone()
        
        now = datetime.now().strftime("%Y-%m-%d %H:%M")
        
        if existing:
            # Actualizar
            if ahorrado is not None:
                new_total = existing['ahorrado_actual'] + ahorrado
                pct = (new_total / existing['objetivo_usd'] * 100) if existing['objetivo_usd'] > 0 else 0
                cursor.execute("""
                    UPDATE ahorros SET ahorrado_actual = ?, porcentaje = ?, ultima_actualizacion = ?, ultimo_usuario = ?
                    WHERE id = ?
                """, (new_total, f"{pct:.1f}%", now, usuario, existing['id']))
                
                # Registrar movimiento
                tipo = 'deposito' if ahorrado > 0 else 'retiro'
                cursor.execute("""
                    INSERT INTO ahorro_movimientos (meta, monto, tipo, usuario)
                    VALUES (?, ?, ?, ?)
                """, (meta, abs(ahorrado), tipo, usuario))
        else:
            # Crear nuevo
            cursor.execute("""
                INSERT INTO ahorros (meta, objetivo_usd, ahorrado_actual, porcentaje, ultima_actualizacion, ultimo_usuario)
                VALUES (?, ?, ?, '0%', ?, ?)
            """, (meta, objetivo or 0, ahorrado or 0, now, usuario))
        
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        logger.error(f"Error upsert_ahorro SQLite: {e}")
        return False

def get_ahorros():
    """Obtiene todas las metas de ahorro."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM ahorros ORDER BY meta")
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

def get_movimientos_ahorro(meta):
    """Obtiene historial de movimientos de una meta."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT * FROM ahorro_movimientos 
        WHERE LOWER(meta) = LOWER(?)
        ORDER BY fecha DESC
    """, (meta,))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

# ==================== DEUDAS ====================

def add_deuda(persona, monto, fecha_retorno, responsable):
    """Registra una deuda."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO deudas (persona, monto, fecha_prestamo, fecha_retorno, responsable)
            VALUES (?, ?, ?, ?, ?)
        """, (persona, monto, datetime.now().strftime("%Y-%m-%d"), fecha_retorno, responsable))
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        logger.error(f"Error add_deuda SQLite: {e}")
        return False

def get_deudas_pendientes():
    """Obtiene deudas pendientes."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM deudas WHERE estado = 'pendiente' ORDER BY fecha_retorno")
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

def marcar_deuda_pagada(persona):
    """Marca una deuda como pagada."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE deudas SET estado = 'pagado', fecha_pago = ?
            WHERE LOWER(persona) = LOWER(?) AND estado = 'pendiente'
        """, (datetime.now().strftime("%Y-%m-%d"), persona))
        affected = cursor.rowcount
        conn.commit()
        conn.close()
        return affected > 0
    except Exception as e:
        logger.error(f"Error marcar_deuda_pagada SQLite: {e}")
        return False

# ==================== CHATS ====================

def register_chat(chat_id, chat_type="group", chat_title=None):
    """Registra un chat para recibir notificaciones."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO chats (chat_id, chat_type, chat_title, registered_at)
            VALUES (?, ?, ?, ?)
        """, (chat_id, chat_type, chat_title, datetime.now().strftime("%Y-%m-%d %H:%M")))
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        logger.error(f"Error register_chat SQLite: {e}")
        return False

def get_all_chats():
    """Obtiene todos los chats registrados."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM chats WHERE notifications_enabled = 1")
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

# ==================== CONFIGURACIÓN ====================

def set_config(clave, valor):
    """Guarda una configuración."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO configuracion (clave, valor, updated_at)
            VALUES (?, ?, ?)
        """, (clave, str(valor), datetime.now().strftime("%Y-%m-%d %H:%M")))
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        logger.error(f"Error set_config SQLite: {e}")
        return False

def get_config(clave, default=None):
    """Obtiene una configuración."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT valor FROM configuracion WHERE clave = ?", (clave,))
    row = cursor.fetchone()
    conn.close()
    return row['valor'] if row else default

# ==================== RESUMEN ====================

def get_resumen_mes(year=None, month=None):
    """Obtiene resumen del mes desde SQLite."""
    gastos = get_gastos_mes(year, month)
    ingresos = get_ingresos_mes(year, month)
    
    total_gastos = sum(g['monto_usd'] or 0 for g in gastos)
    total_ingresos = sum(i['monto_usd'] or 0 for i in ingresos)
    
    # Gastos por categoría
    by_category = {}
    for g in gastos:
        cat = g['categoria'] or 'Otros'
        by_category[cat] = by_category.get(cat, 0) + (g['monto_usd'] or 0)
    
    return {
        'total_gastos': total_gastos,
        'total_ingresos': total_ingresos,
        'balance': total_ingresos - total_gastos,
        'by_category': by_category,
        'count_gastos': len(gastos),
        'count_ingresos': len(ingresos)
    }

# Inicializar DB al importar
init_database()

# ==================== GAMIFICACIÓN ====================

def init_gamification_tables():
    """Inicializa tablas de gamificación."""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Tabla de Usuarios (perfiles individuales)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            telegram_id INTEGER UNIQUE NOT NULL,
            nombre TEXT,
            streak_actual INTEGER DEFAULT 0,
            mejor_streak INTEGER DEFAULT 0,
            ultimo_registro TEXT,
            score_financiero INTEGER DEFAULT 50,
            total_gastos_registrados INTEGER DEFAULT 0,
            nivel INTEGER DEFAULT 1,
            experiencia INTEGER DEFAULT 0,
            limite_diario REAL DEFAULT 0,
            silent_mode INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de Logros/Badges
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS logros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT UNIQUE NOT NULL,
            nombre TEXT NOT NULL,
            descripcion TEXT,
            icono TEXT,
            puntos INTEGER DEFAULT 10
        )
    """)
    
    # Tabla de Logros Desbloqueados
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuario_logros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            telegram_id INTEGER NOT NULL,
            logro_codigo TEXT NOT NULL,
            fecha_desbloqueo TEXT DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(telegram_id, logro_codigo)
        )
    """)
    
    # Tabla de Retos Mensuales
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS retos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mes TEXT NOT NULL,
            titulo TEXT NOT NULL,
            descripcion TEXT,
            tipo TEXT,
            meta_valor REAL,
            categoria TEXT,
            activo INTEGER DEFAULT 1
        )
    """)
    
    # Insertar logros predefinidos
    logros_default = [
        ("primer_gasto", "Primer Paso", "Registra tu primer gasto", "🎯", 10),
        ("streak_7", "Constante", "7 días seguidos registrando", "🔥", 25),
        ("streak_30", "Imparable", "30 días seguidos registrando", "💪", 100),
        ("ahorro_100", "Primer Ahorro", "Ahorra tus primeros $100", "💰", 50),
        ("ahorro_1000", "Ahorrador Pro", "Ahorra $1,000", "🏆", 200),
        ("presupuesto_ok", "Disciplinado", "Termina un mes dentro del presupuesto", "📊", 75),
        ("score_80", "Finanzas Sanas", "Alcanza score financiero de 80+", "⭐", 100),
        ("gastos_50", "Registrador", "Registra 50 gastos", "📝", 30),
        ("gastos_200", "Experto", "Registra 200 gastos", "🎖️", 100),
        ("voz_primero", "Manos Libres", "Registra un gasto por voz", "🎤", 15),
    ]
    
    for codigo, nombre, desc, icono, puntos in logros_default:
        cursor.execute("""
            INSERT OR IGNORE INTO logros (codigo, nombre, descripcion, icono, puntos)
            VALUES (?, ?, ?, ?, ?)
        """, (codigo, nombre, desc, icono, puntos))
    
    conn.commit()
    conn.close()

# Inicializar gamificación también
init_gamification_tables()

def get_or_create_user(telegram_id, nombre=None):
    """Obtiene o crea un perfil de usuario."""
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM usuarios WHERE telegram_id = ?", (telegram_id,))
    user = cursor.fetchone()
    
    if not user:
        cursor.execute("""
            INSERT INTO usuarios (telegram_id, nombre, ultimo_registro)
            VALUES (?, ?, ?)
        """, (telegram_id, nombre, datetime.now().strftime("%Y-%m-%d")))
        conn.commit()
        cursor.execute("SELECT * FROM usuarios WHERE telegram_id = ?", (telegram_id,))
        user = cursor.fetchone()
    
    conn.close()
    return dict(user) if user else None

def update_streak(telegram_id):
    """Actualiza la racha de registro del usuario."""
    from datetime import timedelta
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM usuarios WHERE telegram_id = ?", (telegram_id,))
    user = cursor.fetchone()
    
    if not user:
        conn.close()
        return None
    
    today = datetime.now().strftime("%Y-%m-%d")
    ultimo = user['ultimo_registro'] or ""
    streak = user['streak_actual'] or 0
    mejor = user['mejor_streak'] or 0
    
    if ultimo == today:
        conn.close()
        return {'streak': streak, 'mejor': mejor, 'nuevo_dia': False}
    
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    
    if ultimo == yesterday:
        streak += 1
    else:
        streak = 1
    
    if streak > mejor:
        mejor = streak
    
    cursor.execute("""
        UPDATE usuarios SET streak_actual = ?, mejor_streak = ?, ultimo_registro = ?,
        total_gastos_registrados = total_gastos_registrados + 1
        WHERE telegram_id = ?
    """, (streak, mejor, today, telegram_id))
    conn.commit()
    conn.close()
    
    return {'streak': streak, 'mejor': mejor, 'nuevo_dia': True}

def get_user_stats(telegram_id):
    """Obtiene estadísticas del usuario."""
    user = get_or_create_user(telegram_id)
    if not user:
        return None
    
    conn = get_connection()
    cursor = conn.cursor()
    
    cursor.execute("SELECT COUNT(*) as count FROM usuario_logros WHERE telegram_id = ?", (telegram_id,))
    logros_count = cursor.fetchone()['count']
    
    cursor.execute("""
        SELECT l.* FROM logros l
        JOIN usuario_logros ul ON l.codigo = ul.logro_codigo
        WHERE ul.telegram_id = ?
    """, (telegram_id,))
    logros = [dict(row) for row in cursor.fetchall()]
    
    conn.close()
    
    return {**user, 'logros_count': logros_count, 'logros': logros}

def check_and_award_logros(telegram_id):
    """Verifica y otorga logros desbloqueados."""
    conn = get_connection()
    cursor = conn.cursor()
    
    user = get_or_create_user(telegram_id)
    if not user:
        return []
    
    nuevos_logros = []
    
    checks = [
        ("primer_gasto", user['total_gastos_registrados'] >= 1),
        ("gastos_50", user['total_gastos_registrados'] >= 50),
        ("gastos_200", user['total_gastos_registrados'] >= 200),
        ("streak_7", (user['mejor_streak'] or 0) >= 7),
        ("streak_30", (user['mejor_streak'] or 0) >= 30),
        ("score_80", (user['score_financiero'] or 0) >= 80),
    ]
    
    for codigo, condicion in checks:
        if condicion:
            cursor.execute("""
                INSERT OR IGNORE INTO usuario_logros (telegram_id, logro_codigo)
                VALUES (?, ?)
            """, (telegram_id, codigo))
            if cursor.rowcount > 0:
                cursor.execute("SELECT * FROM logros WHERE codigo = ?", (codigo,))
                logro = cursor.fetchone()
                if logro:
                    nuevos_logros.append(dict(logro))
                    cursor.execute("""
                        UPDATE usuarios SET experiencia = experiencia + ?
                        WHERE telegram_id = ?
                    """, (logro['puntos'], telegram_id))
    
    conn.commit()
    conn.close()
    return nuevos_logros

def calculate_score_financiero(telegram_id):
    """Calcula el score financiero del usuario (0-100)."""
    conn = get_connection()
    cursor = conn.cursor()
    
    now = datetime.now()
    year, month = now.year, now.month
    
    cursor.execute("""
        SELECT COALESCE(SUM(monto_usd), 0) as total FROM gastos
        WHERE strftime('%Y', fecha) = ? AND strftime('%m', fecha) = ?
    """, (str(year), f"{month:02d}"))
    total_gastos = cursor.fetchone()['total']
    
    cursor.execute("""
        SELECT COALESCE(SUM(monto_usd), 0) as total FROM ingresos
        WHERE strftime('%Y', fecha) = ? AND strftime('%m', fecha) = ?
    """, (str(year), f"{month:02d}"))
    total_ingresos = cursor.fetchone()['total']
    
    cursor.execute("SELECT * FROM usuarios WHERE telegram_id = ?", (telegram_id,))
    user = cursor.fetchone()
    
    score = 50
    
    if total_ingresos > 0:
        ratio = total_gastos / total_ingresos
        if ratio < 0.8: score += 20
        elif ratio < 1.0: score += 10
        else: score -= 15
    
    if user and (user['streak_actual'] or 0) >= 7: score += 10
    elif user and (user['streak_actual'] or 0) >= 3: score += 5
    
    cursor.execute("SELECT COUNT(*) as count FROM ahorros WHERE ahorrado_actual > 0")
    if cursor.fetchone()['count'] > 0: score += 10
    
    cursor.execute("SELECT COUNT(*) as count FROM presupuestos WHERE limite > 0")
    if cursor.fetchone()['count'] > 0: score += 10
    
    score = max(0, min(100, score))
    
    if user:
        cursor.execute("UPDATE usuarios SET score_financiero = ? WHERE telegram_id = ?", (score, telegram_id))
        conn.commit()
    
    conn.close()
    return score

def get_ranking():
    """Obtiene ranking de usuarios por score."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT nombre, score_financiero, streak_actual, total_gastos_registrados, experiencia
        FROM usuarios ORDER BY score_financiero DESC, experiencia DESC LIMIT 10
    """)
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

def set_silent_mode(telegram_id, silent=True):
    """Activa/desactiva modo silencioso para un usuario."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("UPDATE usuarios SET silent_mode = ? WHERE telegram_id = ?", (1 if silent else 0, telegram_id))
        conn.commit()
        conn.close()
        return True
    except:
        return False

def is_silent_mode(telegram_id):
    """Verifica si un usuario tiene modo silencioso."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT silent_mode FROM usuarios WHERE telegram_id = ?", (telegram_id,))
    row = cursor.fetchone()
    conn.close()
    return row and row['silent_mode'] == 1

def get_retos_activos():
    """Obtiene retos activos del mes."""
    mes = datetime.now().strftime("%Y-%m")
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM retos WHERE mes = ? AND activo = 1", (mes,))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

def create_reto_mensual(titulo, descripcion, tipo, meta_valor, categoria=None):
    """Crea un reto mensual."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        mes = datetime.now().strftime("%Y-%m")
        cursor.execute("""
            INSERT INTO retos (mes, titulo, descripcion, tipo, meta_valor, categoria)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (mes, titulo, descripcion, tipo, meta_valor, categoria))
        conn.commit()
        conn.close()
        return True
    except:
        return False

# ==================== GASTOS FIJADOS ====================

def init_productivity_tables():
    """Inicializa tablas de productividad."""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Tabla de Gastos Fijados (atajos)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS gastos_fijados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            telegram_id INTEGER NOT NULL,
            atajo TEXT NOT NULL,
            monto REAL NOT NULL,
            categoria TEXT,
            concepto TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(telegram_id, atajo)
        )
    """)
    
    # Tabla de Tags
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS gasto_tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gasto_id INTEGER NOT NULL,
            tag TEXT NOT NULL,
            UNIQUE(gasto_id, tag)
        )
    """)
    
    # Tabla de Límites de Gasto
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS limites_gasto (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            telegram_id INTEGER UNIQUE NOT NULL,
            limite_diario REAL DEFAULT 0,
            limite_semanal REAL DEFAULT 0,
            alerta_enabled INTEGER DEFAULT 1
        )
    """)
    
    # Tabla de Emails para reportes
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS emails_reporte (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            telegram_id INTEGER UNIQUE NOT NULL,
            email TEXT NOT NULL,
            frecuencia TEXT DEFAULT 'semanal',
            activo INTEGER DEFAULT 1
        )
    """)
    
    conn.commit()
    conn.close()

# Inicializar nuevas tablas
init_productivity_tables()

# Gastos Fijados
def add_gasto_fijado(telegram_id, atajo, monto, categoria, concepto=None):
    """Añade un gasto fijado (atajo)."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO gastos_fijados (telegram_id, atajo, monto, categoria, concepto)
            VALUES (?, ?, ?, ?, ?)
        """, (telegram_id, atajo.lower(), monto, categoria, concepto or categoria))
        conn.commit()
        conn.close()
        return True
    except:
        return False

def get_gasto_fijado(telegram_id, atajo):
    """Obtiene un gasto fijado por atajo."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM gastos_fijados WHERE telegram_id = ? AND atajo = ?", (telegram_id, atajo.lower()))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_gastos_fijados(telegram_id):
    """Obtiene todos los gastos fijados de un usuario."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM gastos_fijados WHERE telegram_id = ? ORDER BY atajo", (telegram_id,))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

def delete_gasto_fijado(telegram_id, atajo):
    """Elimina un gasto fijado."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM gastos_fijados WHERE telegram_id = ? AND atajo = ?", (telegram_id, atajo.lower()))
        affected = cursor.rowcount
        conn.commit()
        conn.close()
        return affected > 0
    except:
        return False

# Tags
def add_tag_to_gasto(gasto_id, tag):
    """Añade un tag a un gasto."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT OR IGNORE INTO gasto_tags (gasto_id, tag) VALUES (?, ?)", (gasto_id, tag.lower()))
        conn.commit()
        conn.close()
        return True
    except:
        return False

def get_gastos_by_tag(tag):
    """Obtiene gastos por tag."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT g.* FROM gastos g
        JOIN gasto_tags t ON g.id = t.gasto_id
        WHERE t.tag = ?
        ORDER BY g.fecha DESC
    """, (tag.lower(),))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]

# Límites de Gasto
def set_limite_gasto(telegram_id, limite_diario=None, limite_semanal=None):
    """Configura límites de gasto para un usuario."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO limites_gasto (telegram_id, limite_diario, limite_semanal)
            VALUES (?, ?, ?)
        """, (telegram_id, limite_diario or 0, limite_semanal or 0))
        conn.commit()
        conn.close()
        return True
    except:
        return False

def get_limite_gasto(telegram_id):
    """Obtiene límites de gasto de un usuario."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM limites_gasto WHERE telegram_id = ?", (telegram_id,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def check_limite_gasto(telegram_id):
    """Verifica si el usuario está cerca del límite diario."""
    limite = get_limite_gasto(telegram_id)
    if not limite or limite['limite_diario'] <= 0:
        return None
    
    today = datetime.now().strftime("%Y-%m-%d")
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT COALESCE(SUM(monto_usd), 0) as total FROM gastos
        WHERE fecha = ? AND responsable IN (
            SELECT nombre FROM usuarios WHERE telegram_id = ?
        )
    """, (today, telegram_id))
    spent_today = cursor.fetchone()['total']
    conn.close()
    
    pct = (spent_today / limite['limite_diario']) * 100
    return {
        'spent_today': spent_today,
        'limite': limite['limite_diario'],
        'pct': pct,
        'exceeded': spent_today >= limite['limite_diario']
    }

# Email para reportes
def set_email_reporte(telegram_id, email, frecuencia='semanal'):
    """Configura email para recibir reportes."""
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO emails_reporte (telegram_id, email, frecuencia, activo)
            VALUES (?, ?, ?, 1)
        """, (telegram_id, email, frecuencia))
        conn.commit()
        conn.close()
        return True
    except:
        return False

def get_emails_for_report(frecuencia='semanal'):
    """Obtiene emails activos para enviar reportes."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM emails_reporte WHERE activo = 1 AND frecuencia = ?", (frecuencia,))
    rows = cursor.fetchall()
    conn.close()
    return [dict(row) for row in rows]
