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
