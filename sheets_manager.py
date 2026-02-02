"""
Gestor de Google Sheets: Archivos Mensuales (Gastos_YYYY_MM)
"""
import gspread
from google.oauth2.service_account import Credentials
import google_auth
from datetime import datetime, timedelta
import drive_manager
from config import GOOGLE_CREDENTIALS_FILE, GOOGLE_DRIVE_FOLDER_ID
import logging
import database  # SQLite local

logger = logging.getLogger(__name__)

SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

_client = None

def get_client():
    global _client
    if _client is None:
        try:
            creds = google_auth.get_credentials(scopes=SCOPES)
            _client = gspread.authorize(creds)
            logger.info("DEBUG: Google client initialized successfully")
        except Exception as e:
            logger.error(f"DEBUG: ERROR initializing Google client: {str(e)}", exc_info=True)
            raise e
    return _client

def get_monthly_spreadsheet(year: int = None, month: int = None):
    """
    Obtiene el Spreadsheet del mes especificado.
    Nombre esperado: Gastos_YYYY_MM
    """
    if not year: year = datetime.now().year
    if not month: month = datetime.now().month
    
    filename = f"Gastos_{year}_{month:02d}"
    logger.info(f"DEBUG: Attempting to get spreadsheet: {filename}")
    
    # 1. Buscar archivo
    try:
        drive_service = drive_manager.get_drive_service()
        file_id = drive_manager.search_file_in_folder(GOOGLE_DRIVE_FOLDER_ID, filename, "application/vnd.google-apps.spreadsheet")
        logger.info(f"DEBUG: drive_manager.search_file_in_folder returned file_id: {file_id}")
    except Exception as e:
        logger.error(f"DEBUG: ERROR in search_file_in_folder/get_drive_service: {str(e)}", exc_info=True)
        raise e
    
    # Fallback: Espacio al inicio
    if not file_id:
        logger.warning(f"DEBUG: File '{filename}' not found. Trying with leading space.")
        file_id = drive_manager.search_file_in_folder(GOOGLE_DRIVE_FOLDER_ID, f" {filename}", "application/vnd.google-apps.spreadsheet")
        logger.info(f"DEBUG: lead-space search returned: {file_id}")
    
    if not file_id:
        # MODO MANUAL: No podemos crear archios (Cuota 0).
        # Lanzamos error descriptivo para que el usuario sepa qué hacer.
        raise Exception(
            f"❌ No existe el archivo '{filename}'.\n"
            f"Por favor, créalo manualmente en la carpeta de Drive y déjalo vacío.\n"
            f"El bot lo detectará y configurará automáticamente."
        )
        
    client = get_client()
    spreadsheet = client.open_by_key(file_id)
    
    # 2. Inicializar estructura si es nuevo (o está vacío)
    init_standard_sheets(spreadsheet)
    
    # 3. Intentar migrar config del mes anterior SI este archivo está "nuevo" (solo tiene hojas default)
    # Una forma simple de saber si es "nuevo" para nosotros es chequear si ya tiene Tasa configurada.
    try:
        if get_exchange_rate(spreadsheet) == 1.0 and get_rate_source(spreadsheet) == "MANUAL":
             # Intentar traer del mes anterior
             try_migrate_from_previous_month(year, month, spreadsheet)
    except: pass
    
    return spreadsheet

def get_sheet_url(year: int = None, month: int = None) -> str:
    """Retorna el URL de la hoja mensual actual."""
    try:
        ss = get_monthly_spreadsheet(year, month)
        return ss.url
    except Exception as e:
        logger.error(f"Error get_sheet_url: {e}")
        return None

def try_migrate_from_previous_month(year, month, current_ss):
    """Copia tasa, categorías y presupuestos del mes anterior si existen."""
    try:
        prev_date = datetime(year, month, 1) - timedelta(days=1)
        prev_filename = f"Gastos_{prev_date.year}_{prev_date.month:02d}"
        
        prev_id = drive_manager.search_file_in_folder(GOOGLE_DRIVE_FOLDER_ID, prev_filename, "application/vnd.google-apps.spreadsheet")
        if not prev_id: return # No hay mes anterior
        
        client = get_client()
        prev_ss = client.open_by_key(prev_id)
        
        # 1. Copiar Tasa
        try:
            ws_conf = prev_ss.worksheet("Configuracion")
            tasa = ws_conf.acell('B2').value
            source = ws_conf.acell('B3').value # Asumiendo row 3
            if tasa:
                set_exchange_rate(float(tasa.replace(",", ".")), source or "MANUAL", current_ss)
        except: pass

        # 2. Copiar Categorías
        try:
            ws_cat = prev_ss.worksheet("Categorias")
            cats = ws_cat.get_all_values()
            if len(cats) > 1:
                cur_cat = current_ss.worksheet("Categorias")
                cur_cat.clear()
                cur_cat.update("A1", cats)
        except: pass
        
        # 3. Copiar Presupuestos
        try:
            ws_pres = prev_ss.worksheet("Presupuestos")
            pres = ws_pres.get_all_values()
            if len(pres) > 1:
                cur_pres = current_ss.worksheet("Presupuestos")
                # Copiar solo Categoría y Límite (cols A y B), resetear Gastado (Col C) a 0
                import copy
                new_pres = []
                for row in pres:
                    if row[0] == "Categoría": new_pres.append(row)
                    else: new_pres.append([row[0], row[1], 0])
                
                cur_pres.clear()
                cur_pres.update("A1", new_pres)
        except: pass

        logger.info(f"Datos migrados de {prev_filename} a {current_ss.title}")
        
    except Exception as e:
        logger.error(f"Error migrando datos: {e}")

def init_standard_sheets(spreadsheet):
    """Crea la estructura base de hojas."""
    # 1. Gastos
    try: spreadsheet.worksheet("Gastos")
    except: 
        ws = spreadsheet.add_worksheet("Gastos", 1000, 20)
        ws.update("A1", [["Fecha", "Hora", "Tipo", "Monto Original", "Moneda", "Monto USD", "Tasa Usada", "Banco Origen", "Banco Destino", "Referencia", "Beneficiario", "Documento", "Concepto", "Categoría", "Registrado por", "Fecha Registro", "Imagen"]])
    
    # 2. Ingresos
    try: spreadsheet.worksheet("Ingresos")
    except:
        ws = spreadsheet.add_worksheet("Ingresos", 1000, 10)
        ws.update("A1", [["Fecha", "Concepto", "Monto Original", "Moneda", "Monto USD", "Tasa Usada", "Categoría", "Registrado por", "Imagen"]])

    # 3. Categorias
    try: spreadsheet.worksheet("Categorias")
    except:
        ws = spreadsheet.add_worksheet("Categorias", 100, 2)
        ws.update("A1", [["Nombre", "Keywords"], ["🛒 Supermercado", ""], ["🍔 Comida", ""], ["⛽ Transporte", ""], ["🏠 Hogar", ""], ["💰 Otros", ""]])
    
    # 4. Configuracion
    ws_config = None
    try: ws_config = spreadsheet.worksheet("Configuracion")
    except:
        ws_config = spreadsheet.add_worksheet("Configuracion", 20, 2)
        ws_config.update("A1", [["Clave", "Valor"], ["TASA_USD", "1.0"], ["TASA_SOURCE", "MANUAL"], ["CONFIRMACION_REQUERIDA", "SI"]])
    
    # Asegurar claves nuevas en hojas existentes
    try:
        if ws_config:
            existing_keys = ws_config.col_values(1)
            updates = []
            if "CONFIRMACION_REQUERIDA" not in existing_keys:
                updates.append(["CONFIRMACION_REQUERIDA", "SI"])
            
            if updates:
                for row in updates: ws_config.append_row(row)
    except: pass

    # 5. Presupuestos
    try: spreadsheet.worksheet("Presupuestos")
    except:
        ws = spreadsheet.add_worksheet("Presupuestos", 50, 3)
        ws.update("A1", [["Categoría", "Límite USD", "Gastado Actual"]])
    
    # 6. Ahorros
    try: spreadsheet.worksheet("Ahorros")
    except:
        ws = spreadsheet.add_worksheet("Ahorros", 20, 7)
        ws.update("A1", [["Meta", "Objetivo USD", "Ahorrado Actual", "Porcentaje", "Hitos (%)", "Ultima Act", "Usuario"]])
    
    # 7. Deudores
    try: spreadsheet.worksheet("Deudores")
    except:
        ws = spreadsheet.add_worksheet("Deudores", 50, 6)
        ws.update("A1", [["Persona", "Monto Préstamo", "Fecha Préstamo", "Fecha Retorno", "Estado", "Registrado por"]])

    # 8. Recurrentes
    try: spreadsheet.worksheet("Recurrentes")
    except:
        ws = spreadsheet.add_worksheet("Recurrentes", 20, 5)
        ws.update("A1", [["Nombre", "Monto", "Dia", "UltimoPago", "Activo"]])
    
    # Eliminar hoja default si existe ("Sheet1" o "Hoja 1")
    for name in ["Sheet1", "Hoja 1"]:
        try:
            ws_to_del = spreadsheet.worksheet(name)
            # Solo borrar si hay más de una hoja (gspread/Google no permite borrar la única hoja)
            if len(spreadsheet.worksheets()) > 1:
                spreadsheet.del_worksheet(ws_to_del)
        except: pass


# --- WRAPPERS DE ACCESO ---

def get_transaction_sheet(is_income=False):
    ss = get_monthly_spreadsheet()
    name = "Ingresos" if is_income else "Gastos"
    return ss.worksheet(name)

def get_config_sheet(ss=None):
    if not ss: ss = get_monthly_spreadsheet() 
    return ss.worksheet("Configuracion")

def get_budget_sheet(ss=None):
    if not ss: ss = get_monthly_spreadsheet()
    return ss.worksheet("Presupuestos")
    
def get_categories_sheet(ss=None):
    if not ss: ss = get_monthly_spreadsheet()
    return ss.worksheet("Categorias")


# --- OPERACIONES ---

def get_exchange_rate(ss=None) -> float:
    try:
        sheet = get_config_sheet(ss)
        val = sheet.acell('B2').value 
        return float(val.replace(",", ".")) if val else 1.0
    except Exception as e: 
        logger.error(f"DEBUG: Error in get_exchange_rate: {str(e)}")
        return 1.0

def set_exchange_rate(rate: float, source: str = "MANUAL", ss=None, bcv: float = 0, paralelo: float = 0) -> tuple[bool, str]:
    try:
        sheet = get_config_sheet(ss)
        
        # Guardar tasa activa
        cell = sheet.find("TASA_USD")
        if cell: sheet.update_acell(f"B{cell.row}", rate)
        else: sheet.append_row(["TASA_USD", rate])
        
        # Guardar fuente activa
        cell = sheet.find("TASA_SOURCE")
        if cell: sheet.update_acell(f"B{cell.row}", source)
        else: sheet.append_row(["TASA_SOURCE", source])
        
        # Guardar valores de ambas para referencia
        if bcv > 0:
            cell = sheet.find("RATE_BCV")
            if cell: sheet.update_acell(f"B{cell.row}", bcv)
            else: sheet.append_row(["RATE_BCV", bcv])
            
        if paralelo > 0:
            cell = sheet.find("RATE_PARALELO")
            if cell: sheet.update_acell(f"B{cell.row}", paralelo)
            else: sheet.append_row(["RATE_PARALELO", paralelo])
            
        return True, "OK"
    except Exception as e: return False, str(e)

def get_all_config(ss=None) -> dict:
    try:
        sheet = get_config_sheet(ss)
        data = sheet.get_all_values()
        return {row[0]: row[1] for row in data if len(row) >= 2}
    except: return {}

def get_rate_source(ss=None) -> str:
    try:
        sheet = get_config_sheet(ss)
        cell = sheet.find("TASA_SOURCE")
        return sheet.cell(cell.row, 2).value if cell else "MANUAL"
    except: return "MANUAL"

def is_confirmation_required(ss=None) -> bool:
    try:
        sheet = get_config_sheet(ss)
        cell = sheet.find("CONFIRMACION_REQUERIDA")
        val = sheet.cell(cell.row, 2).value if cell else "SI"
        return val.upper() == "SI"
    except: return True

def get_categories() -> list:
    try:
        sheet = get_categories_sheet()
        vals = sheet.col_values(1)
        return vals[1:] if len(vals) > 1 else []
    except: return []

def add_category(name: str) -> bool:
    try:
        sheet = get_categories_sheet()
        existing = sheet.col_values(1)
        if name in existing: return True
        sheet.append_row([name])
        return True
    except: return False

def add_transaction(data: dict, user: str, image_link: str = "", is_income: bool = False) -> tuple[bool, str]:
    try:
        # Aquí forzamos usar el SS del mes de la FECHA de transacción
        date_str = data.get("fecha")
        if not date_str: date_str = datetime.now().strftime("%Y-%m-%d")
        dt = datetime.strptime(date_str, "%Y-%m-%d")
        
        # Buscar SS específico de la fecha
        ss = get_monthly_spreadsheet(dt.year, dt.month)
        tasa = get_exchange_rate(ss)
        
        sheet = ss.worksheet("Ingresos" if is_income else "Gastos")
        
        # --- VERIFICACIÓN DE DUPLICADOS ---
        # Definir índices de columnas según la hoja (0-indexed para lista de valores, 1-indexed para gspread finds)
        # Ingresos: Fecha(0), Concepto(1), Monto(2)
        # Gastos: Fecha(0), Referencia(9), Monto(3), Concepto(12)
        
        all_records = sheet.get_all_values() # Traer todo para verificar en memoria (más rápido que múltiples llamadas API)
        # Saltamos header
        records = all_records[1:] if len(all_records) > 1 else []
        
        ref_nueva = str(data.get("referencia", "")).strip()
        monto_nuevo = float(data.get("monto", 0))
        concepto_nuevo = str(data.get("concepto", "")).strip().lower()
        
        is_duplicate = False
        
        for row in records:
            if not row: continue
            
            # Chequeo por REFERENCIA (Solo Gastos, col J -> index 9)
            if not is_income and ref_nueva and len(row) > 9:
                ref_existente = str(row[9]).strip()
                if ref_nueva == ref_existente:
                    is_duplicate = True
                    break
            
            # Chequeo por FECHA + MONTO + CONCEPTO (Fallback)
            # Ingresos: Fecha(0), Concepto(1), Monto(2)
            # Gastos: Fecha(0), Monto(3), Concepto(12)
            try:
                row_fecha = row[0]
                if is_income:
                    row_monto = float(str(row[2]).replace(",", "."))
                    row_concepto = str(row[1]).strip().lower()
                else:
                    row_monto = float(str(row[3]).replace(",", "."))
                    row_concepto = str(row[12]).strip().lower() if len(row) > 12 else ""
                
                if row_fecha == date_str and abs(row_monto - monto_nuevo) < 0.01:
                    # Si coincide fecha y monto, verificamos concepto (si ambos tienen concepto)
                    if concepto_nuevo and row_concepto:
                        if concepto_nuevo == row_concepto or concepto_nuevo in row_concepto:
                            is_duplicate = True
                            break
                    else:
                        # Si no hay concepto para desempatar, asumimos duplicado si es mismo monto/fecha
                        # (Ojo: esto podría bloquear gastos idénticos legítimos el mismo día, pero es seguro por ahora)
                        is_duplicate = True
                        break
            except: continue

        if is_duplicate:
            return False, "⚠️ Transacción duplicada (Referencia o Datos idénticos ya existen)."

        monto_orig = float(data.get("monto", 0))
        moneda = data.get("moneda", "Bs")
        
        if moneda.lower() in ["usd", "$", "us", "dolar", "doblar", "dólares"]:
            monto_usd = monto_orig
            tasa_usada = 1.0
        else:
            monto_usd = round(monto_orig / tasa, 2)
            tasa_usada = tasa
            
        now = datetime.now()
        
        if is_income:
            row = [
                date_str,
                data.get("concepto", "Ingreso Manual"),
                monto_orig,
                moneda,
                monto_usd,
                tasa_usada,
                data.get("categoria", "General"),
                user,
                image_link
            ]
        else:
            cat = data.get("categoria", "Otros")
            row = [
                date_str,
                data.get("hora", ""),
                data.get("tipo", ""),
                monto_orig,
                moneda,
                monto_usd,
                tasa_usada,
                data.get("banco_origen", ""),
                data.get("banco_destino", ""),
                data.get("referencia", ""),
                data.get("beneficiario", ""),
                data.get("documento", ""),
                data.get("concepto", ""),
                cat,
                user,
                now.strftime("%Y-%m-%d %H:%M:%S"),
                image_link
            ]
            
        sheet.append_row(row, value_input_option='USER_ENTERED')
        
        # Sincronizar con SQLite
        try:
            if is_income:
                database.add_ingreso(
                    fecha=date_str,
                    concepto=data.get("concepto", "Ingreso"),
                    monto_original=monto_orig,
                    moneda=moneda,
                    monto_usd=monto_usd,
                    categoria=data.get("categoria", "General"),
                    responsable=user
                )
            else:
                database.add_gasto(
                    fecha=date_str,
                    concepto=data.get("concepto", ""),
                    monto_original=monto_orig,
                    moneda=moneda,
                    monto_usd=monto_usd,
                    categoria=data.get("categoria", "Otros"),
                    referencia=data.get("referencia", ""),
                    responsable=user,
                    imagen_url=image_link
                )
        except Exception as db_err:
            logger.warning(f"Error sync SQLite (no crítico): {db_err}")
        
        return True, "OK"
    except Exception as e:
        logger.error(f"Error add_transaction: {e}")
        return False, str(e)

def get_monthly_summary(year: int = None, month: int = None, ss = None) -> dict:
    try:
        if not ss:
            if not year: year = datetime.now().year
            if not month: month = datetime.now().month
            # Intentar obtener hojas de ese mes.
            try:
                ss = get_monthly_spreadsheet(year, month)
            except:
                return None # No hay datos
        
        # 1. Procesar GASTOS
        sheet_g = ss.worksheet("Gastos")
        records_g = sheet_g.get_all_records()
        
        total_gastos = 0
        by_category = {}
        daily_trend = []
        
        for row in records_g:
            try:
                val = row.get("Monto USD")
                if not val: continue
                val = float(str(val).replace(",", "."))
                
                cat = row.get("Categoría", "Otros")
                by_category[cat] = by_category.get(cat, 0) + val
                total_gastos += val
                
                daily_trend.append({
                    "Fecha": row.get("Fecha"),
                    "Monto USD": val
                })
            except: continue
            
        # 2. Procesar INGRESOS
        total_ingresos = 0
        try:
            sheet_i = ss.worksheet("Ingresos")
            records_i = sheet_i.get_all_records()
            for row in records_i:
                try:
                    val = row.get("Monto USD")
                    if val: total_ingresos += float(str(val).replace(",", "."))
                except: continue
        except: pass # Si no hay hoja de ingresos aún
            
        return {
            "total_usd": total_gastos,
            "total_ingresos": total_ingresos,
            "by_category": by_category,
            "daily_trend": daily_trend,
            "count": len(records_g),
            "year": year or datetime.now().year,
            "month": month or datetime.now().month
        }
    except Exception as e:
        logger.error(f"Error summary: {e}")
        return None

# --- PRESUPUESTOS ---

def set_budget(category: str, amount: float) -> bool:
    try:
        sheet = get_budget_sheet()
        cell = sheet.find(category)
        if cell:
            sheet.update_acell(f"B{cell.row}", amount)
        else:
            sheet.append_row([category, amount, 0])
        return True
    except Exception as e:
        logger.error(f"Error set_budget: {e}")
        return False

def get_all_budgets() -> dict:
    """Retorna todos los presupuestos como {categoria: monto}."""
    try:
        sheet = get_budget_sheet()
        records = sheet.get_all_records()
        budgets = {}
        for r in records:
            cat = r.get("Categoría") or r.get("Categoria")
            limit = r.get("Límite") or r.get("Limite") or r.get("Monto")
            if cat and limit:
                budgets[cat] = float(str(limit).replace(",", "."))
        return budgets
    except Exception as e:
        logger.error(f"Error get_all_budgets: {e}")
        return {}

def check_budget_alert(category: str) -> dict:
    try:
        now = datetime.now()
        ss = get_monthly_spreadsheet(now.year, now.month) # Del mes actual
        bsheet = ss.worksheet("Presupuestos")
        cell = bsheet.find(category)
        if not cell: return None
        
        limit = float(bsheet.cell(cell.row, 2).value.replace(",", "."))
        
        summary = get_monthly_summary(ss=ss) # Pass ss to avoid re-fetching
        spent = summary['by_category'].get(category, 0)
        
        pct = (spent / limit) * 100
        
        return {
            "limit": limit,
            "spent": spent,
            "pct": pct,
            "alert": "red" if pct >= 100 else "yellow" if pct >= 80 else "green"
        }
    except: return None

# --- AHORROS ---

def set_savings_goal(name: str, amount: float) -> bool:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Ahorros")
        cell = sheet.find(name)
        if cell:
            sheet.update_acell(f"B{cell.row}", amount)
        else:
            sheet.append_row([name, amount, 0, "0%"])
        return True
    except Exception as e:
        logger.error(f"Error set_savings_goal: {e}")
        return False

def add_savings(name: str, amount: float, user: str = "Desconocido") -> dict:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Ahorros")
        
        # Verificar cabeceras para compatibilidad
        try:
            if sheet.cell(1, 6).value != "Ultima Act":
                sheet.update_cell(1, 6, "Ultima Act")
                sheet.update_cell(1, 7, "Usuario")
        except: pass
        
        # Búsqueda manual insensible a mayúsculas
        records = sheet.get_all_records()
        row_idx = -1
        current_data = {}
        
        name_clean = name.strip().lower()
        
        for i, r in enumerate(records):
            if str(r.get("Meta")).strip().lower() == name_clean:
                row_idx = i + 2 # Header + 1-based
                current_data = r
                break
        
        if row_idx == -1: return {"success": False}
        
        # Calcular nuevos valores
        current_saved = float(str(current_data.get("Ahorrado Actual", 0)).replace(",", ".")) if current_data.get("Ahorrado Actual") != "" else 0.0
        target = float(str(current_data.get("Objetivo USD", 0)).replace(",", "."))
        
        new_total = current_saved + amount
        new_pct = (new_total / target * 100) if target > 0 else 0
        
        # Hitos
        milestones_str = str(current_data.get("Hitos (%)", ""))
        reached = None
        if milestones_str:
            ms = [int(x.strip()) for x in milestones_str.split(",") if x.strip().isdigit()]
            ms.sort()
            # Verificar si cruzamos un hito (hacia arriba)
            old_pct = (current_saved / target * 100) if target > 0 else 0
            for m in ms:
                if old_pct < m <= new_pct:
                    reached = m
        
        # Actualizar celda C (Ahorrado) y D (Porcentaje)
        sheet.update_acell(f"C{row_idx}", new_total)
        sheet.update_acell(f"D{row_idx}", f"{new_pct:.1f}%")
        
        # Actualizar trazabilidad (F y G)
        now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
        sheet.update_acell(f"F{row_idx}", now_str) # Col 6
        sheet.update_acell(f"G{row_idx}", user)    # Col 7
        
        return {
            "success": True, 
            "new_total": new_total, 
            "new_pct": new_pct,
            "reached_milestone": reached
        }
    except Exception as e:
        logger.error(f"Error add_savings: {e}")
        return {"success": False}

# --- RECURRENTES ---

def add_recurring(name: str, amount: float, day: int) -> bool:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Recurrentes")
        sheet.append_row([name, amount, day, "", "SI"])
        return True
    except: return False

def check_recurring() -> list:
    """Retorna lista de pagos a realizar HOY."""
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Recurrentes")
        records = sheet.get_all_records()
        today_day = datetime.now().day
        today_str = datetime.now().strftime("%Y-%m-%d")
        to_pay = []
        
        for i, r in enumerate(records):
            if r.get("Activo") != "SI": continue
            if int(r.get("Dia")) == today_day:
                last_payment = str(r.get("UltimoPago"))
                # Si no se ha pagado este mes (asumiendo check mensual simple)
                # O si last_payment es viejo (mes anterior)
                should_pay = False
                if not last_payment: should_pay = True
                else:
                    try:
                        lp_date = datetime.strptime(last_payment, "%Y-%m-%d")
                        if lp_date.month != datetime.now().month:
                            should_pay = True
                    except: should_pay = True
                
                if should_pay:
                    to_pay.append({"row": i+2, "data": r})
                    
        return to_pay
    except: return []

def mark_recurring_paid(row: int):
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Recurrentes")
        sheet.update_acell(f"D{row}", datetime.now().strftime("%Y-%m-%d"))
    except: pass

def set_milestones(name: str, hitos: str) -> bool:
    """Configura los hitos (ej: '25,50,75,100') para una meta."""
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Ahorros")
        cell = sheet.find(name)
        if not cell: return False
        sheet.update_acell(f"E{cell.row}", hitos)
        return True
    except: return False

def get_savings() -> list:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Ahorros")
        return sheet.get_all_records()
    except: return []

# --- DEUDORES ---

def add_debtor(name: str, amount: float, return_date: str, user: str) -> bool:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Deudores")
        now = datetime.now().strftime("%Y-%m-%d")
        sheet.append_row([name, amount, now, return_date, "PENDIENTE", user])
        return True
    except Exception as e:
        logger.error(f"Error add_debtor: {e}")
        return False

def get_pending_debts() -> list:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Deudores")
        records = sheet.get_all_records()
        return [r for r in records if r.get("Estado") == "PENDIENTE"]
    except: return []

def mark_debt_as_paid(name: str) -> bool:
    try:
        ss = get_monthly_spreadsheet()
        sheet = ss.worksheet("Deudores")
        cell = sheet.find(name)
        if not cell: return False
        
        # Verificar estado actual antes de marcar como pagado
        row_vals = sheet.row_values(cell.row)
        if row_vals[4] == "PAGADO": return True
        
        sheet.update_acell(f"E{cell.row}", "PAGADO")
        return True
    except: return False
