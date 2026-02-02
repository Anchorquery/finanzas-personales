"""
Bot de Telegram Financiero 360°
Multimoneda, Gráficos, Drive y Categorías Dinámicas
"""
import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, BotCommand, InputMediaPhoto
from datetime import datetime
from telegram.ext import (
    Application, 
    CommandHandler, 
    MessageHandler, 
    CallbackQueryHandler,
    ContextTypes,
    filters
)
import drive_manager
from sheets_manager import get_monthly_spreadsheet # Necesario para reporte
import visualizer
import io
import pandas as pd

# Definir estados
LOGGING_EXPENSE = 1
import sheets_manager
from gemini_analyzer import analyze_receipt, analyze_text, analyze_voice, format_receipt_message, get_financial_advice

# Configurar logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Silenciar advertencia de cache de Google API (innecesaria con oauth2client moderno)
logging.getLogger('googleapiclient.discovery_cache').setLevel(logging.ERROR)

from config import TELEGRAM_BOT_TOKEN

# Almacén temporal
pending_data = {}

import currency_service
import database  # SQLite local

# Función helper para registrar chat
async def register_chat_if_new(update: Update):
    """Registra el chat en SQLite si es nuevo."""
    try:
        chat = update.effective_chat
        database.register_chat(
            chat_id=chat.id,
            chat_type=chat.type,
            chat_title=chat.title or chat.first_name or "Privado"
        )
    except: pass

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await register_chat_if_new(update)  # Registrar chat
    rate = sheets_manager.get_exchange_rate()
    source = sheets_manager.get_rate_source()
    await update.message.reply_text(
        f"💰 *¡Bienvenido a tu Asistente Financiero 360°!* 🚀\n\n"
        f"Soy una IA diseñada para ayudarte a tomar el control total de tus finanzas familiares directamente desde Telegram.\n\n"
        f"📌 *Estado Actual:*\n"
        f"💵 Tasa activa: *{rate} Bs/$*\n"
        f"🏛️ Fuente: *{source}* (Actualizada cada 1h)\n\n"
        f"--- 🛠️ **¿QUÉ PUEDO HACER POR TI?** ---\n\n"
        f"📸 **Registro Inteligente:** Envía una foto de un recibo o pago móvil. Analizaré el monto, banco y concepto automáticamente. _Tip: Añade un comentario a la foto para ayudarme con la categoría._\n\n"
        f"✍️ **Registro por Texto:** Escribe algo como: 'Hoy gasté 500bs en medicina' y lo anotaré.\n\n"
        f"📈 **Análisis Avanzado (/analisis):** Genero 3 gráficos detallados (Categorías, Balance y Tendencia) y te doy consejos de ahorro con IA (Gemini).\n\n"
        f"💰 **Ahorros e Hitos (/ahorro):** Gestiona tus metas (ej: `/ahorro Casa 100000`). ¡Configura hitos con `/hitos` y celebraremos juntos cada avance del 10%, 25% o lo que tú elijas! 🎉\n\n"
        f"💾 **Sincronización Total:** Todo se guarda en tu **Google Sheets** mensual (`Gastos_YYYY_MM`) y las fotos van directo a tu **Google Drive**.\n\n"
        f"⚙️ **Personalización:** Puedes activar el *Auto-Guardado* desde la pestaña 'Configuracion' de tu Excel para que registre todo sin preguntar.\n\n"
        f"💡 _Escribe /ayuda en cualquier momento para ver la lista de comandos._",
        parse_mode="Markdown"
    )

async def set_rate_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    msg = await update.message.reply_text("🔄 Consultando DolarAPI...")
    rates = currency_service.get_current_rates()
    current_rate = sheets_manager.get_exchange_rate()
    if not rates:
        await msg.edit_text(f"⚠️ Error conectando API.\nTasa actual: {current_rate} Bs/$")
        return
    bcv = rates.get("oficial", 0)
    paralelo = rates.get("paralelo", 0)
    keyboard = [
        [InlineKeyboardButton(f"🏛️ BCV: {bcv}", callback_data=f"setrate_BCV_{bcv}")],
        [InlineKeyboardButton(f"💸 Paralelo: {paralelo}", callback_data=f"setrate_PARALELO_{paralelo}")],
        [InlineKeyboardButton("✖️ Cancelar", callback_data="discard_rate")]
    ]
    await msg.edit_text(
        f"💵 **Configuración de Tasa**\n\nActual: *{current_rate} Bs/$*\n\nValores actuales:\n- BCV: {bcv}\n- Paralelo: {paralelo}\n\nSelecciona cual usar:",
        parse_mode="Markdown",
        reply_markup=InlineKeyboardMarkup(keyboard)
    )

async def summary_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Alias para /analisis"""
    return await analisis_command(update, context)

async def comparar_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Comparativa mensual: este mes vs anterior."""
    msg = await update.message.reply_text("📊 Generando comparativa mensual...")
    
    try:
        now = datetime.now()
        current = sheets_manager.get_monthly_summary(now.year, now.month)
        
        # Obtener mes anterior
        if now.month == 1:
            prev_year, prev_month = now.year - 1, 12
        else:
            prev_year, prev_month = now.year, now.month - 1
        
        previous = sheets_manager.get_monthly_summary(prev_year, prev_month)
        
        if not current or not previous:
            await msg.edit_text("❌ No hay datos suficientes para comparar (necesito al menos 2 meses).")
            return
        
        chart = visualizer.generate_monthly_comparison(current, previous)
        
        if chart:
            diff = current['total_usd'] - previous['total_usd']
            emoji = "📈" if diff > 0 else "📉"
            caption = f"{emoji} *Comparativa Mensual*\n\n"
            caption += f"📅 Este mes: ${current['total_usd']:,.2f}\n"
            caption += f"📅 Mes anterior: ${previous['total_usd']:,.2f}\n"
            caption += f"💰 Diferencia: ${diff:+,.2f}"
            
            await update.message.reply_photo(photo=chart, caption=caption, parse_mode="Markdown")
            await msg.delete()
        else:
            await msg.edit_text("❌ No se pudo generar la comparativa.")
            
    except Exception as e:
        await msg.edit_text(f"❌ Error: {e}")

async def weekly_summary_job(context: ContextTypes.DEFAULT_TYPE):
    """Envía resumen semanal cada lunes."""
    logger.info("Ejecutando resumen semanal...")
    
    try:
        summary = sheets_manager.get_monthly_summary()
        if not summary or summary['count'] == 0:
            return
        
        # Calcular semana actual (día 1-7, 8-14, etc.)
        day = datetime.now().day
        week_num = (day - 1) // 7 + 1
        
        msg = f"📅 *RESUMEN SEMANAL (Semana {week_num})*\n\n"
        msg += f"💸 Gastos acumulados: *${summary['total_usd']:,.2f}*\n"
        msg += f"💵 Ingresos acumulados: *${summary['total_ingresos']:,.2f}*\n"
        msg += f"⚖️ Balance: *${summary['total_ingresos'] - summary['total_usd']:,.2f}*\n\n"
        
        # Top 3 categorías
        if summary['by_category']:
            sorted_cats = sorted(summary['by_category'].items(), key=lambda x: x[1], reverse=True)[:3]
            msg += "🏆 *Top 3 Categorías:*\n"
            for cat, amount in sorted_cats:
                msg += f"• {cat}: ${amount:,.2f}\n"
        
        msg += "\n💪 ¡Sigue registrando para mantener el control!"
        
        # Enviar a todos los chats registrados
        chats = database.get_all_chats()
        for chat in chats:
            try:
                await context.bot.send_message(chat['chat_id'], msg, parse_mode="Markdown")
            except Exception as e:
                logger.warning(f"No se pudo enviar resumen a chat {chat['chat_id']}: {e}")
        
    except Exception as e:
        logger.error(f"Error en weekly_summary_job: {e}")

async def handle_voice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Procesar notas de voz con Gemini."""
    msg = await update.message.reply_text("🎤 Escuchando y analizando...")
    
    try:
        voice = update.message.voice
        file = await context.bot.get_file(voice.file_id)
        voice_bytes = await file.download_as_bytearray()
        
        result = analyze_voice(bytes(voice_bytes))
        
        if not result.get("success"):
            await msg.edit_text(f"❌ No pude entender el audio: {result.get('error', 'Error desconocido')}")
            return
        
        data = result["data"]
        
        # Formatear mensaje
        is_income = data.get("tipo", "").lower() == "ingreso"
        tipo_emoji = "💵" if is_income else "💸"
        
        formatted = f"{tipo_emoji} *{'INGRESO' if is_income else 'GASTO'} por VOZ*\n\n"
        formatted += f"💰 Monto: *{data.get('monto', 0)} {data.get('moneda', 'Bs')}*\n"
        formatted += f"📝 Concepto: {data.get('concepto', 'N/A')}\n"
        formatted += f"🏷️ Categoría: {data.get('categoria_sugerida', 'otros')}\n"
        
        # Crear botones
        rate = sheets_manager.get_exchange_rate()
        monto = data.get('monto', 0)
        moneda = data.get('moneda', 'Bs')
        est_usd = monto if moneda.lower() in ['usd', '$'] else monto / rate
        formatted += f"\n💵 *Estimado:* ${est_usd:,.2f}"
        
        # Guardar en pending
        reply_msg = await msg.edit_text(formatted, parse_mode="Markdown")
        pending_key = f"{update.effective_chat.id}:{reply_msg.message_id}"
        
        pending_data[pending_key] = {
            "data": data,
            "image_bytes": None,
            "user": update.effective_user.first_name
        }
        
        keyboard = [
            [InlineKeyboardButton("✅ Guardar" + (" Ingreso" if is_income else " Gasto"), 
                                 callback_data=f"{'save_inc' if is_income else 'save_exp'}:{pending_key}")],
            [InlineKeyboardButton("❌ Descartar", callback_data=f"disc:{pending_key}")]
        ]
        
        await reply_msg.edit_reply_markup(reply_markup=InlineKeyboardMarkup(keyboard))
        
    except Exception as e:
        await msg.edit_text(f"❌ Error procesando audio: {e}")

async def hoja_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Muestra el link a la hoja de gastos actual."""
    url = sheets_manager.get_sheet_url()
    if url:
        now = datetime.now()
        await update.message.reply_text(
            f"📊 *Hoja de Gastos Actual*\n\n"
            f"📅 Mes: *{now.strftime('%B %Y')}*\n"
            f"🔗 [Abrir en Google Sheets]({url})",
            parse_mode="Markdown",
            disable_web_page_preview=True
        )
    else:
        logger.warning("DEBUG: hoja_command failed - sheets_manager.get_sheet_url() returned None")
        await update.message.reply_text("❌ No se pudo obtener el enlace de la hoja.")

async def analisis_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Dashboard completo con gráficos e IA coaching."""
    msg = await update.message.reply_text("📊 Generando análisis detallado...")
    summary = sheets_manager.get_monthly_summary()
    
    if not summary or summary['count'] == 0:
        await msg.edit_text("❌ No hay datos suficientes para el análisis.")
        return

    # 1. Gráfico de Torta (Categorías)
    pie = visualizer.generate_pie_chart(summary['by_category'])
    
    # 2. Gráfico de Barras (Ingresos vs Gastos)
    bars = visualizer.generate_comparison_chart(summary['total_usd'], summary['total_ingresos'])
    
    # 3. Gráfico de Tendencia
    trend = visualizer.generate_daily_trend(summary['daily_trend'])
    
    # 4. Top 5 Gastos (NUEVO)
    top5 = visualizer.generate_top5_expenses(summary.get('all_expenses', summary['daily_trend']))
    
    # 5. Distribución por Día de Semana (NUEVO)
    weekday = visualizer.generate_weekday_distribution(summary['daily_trend'])
    
    media = [
        InputMediaPhoto(pie, caption=f"📉 *Gasto por Categoría*\nTotal: ${summary['total_usd']:,.2f}", parse_mode="Markdown"),
        InputMediaPhoto(bars, caption=f"⚖️ *Balance:* ${summary['total_ingresos'] - summary['total_usd']:,.2f}"),
        InputMediaPhoto(trend, caption="📈 *Tendencia Diaria*")
    ]
    
    # Añadir nuevas gráficas si se generaron
    if top5:
        media.append(InputMediaPhoto(top5, caption="💸 *Top 5 Gastos Más Altos*"))
    if weekday:
        media.append(InputMediaPhoto(weekday, caption="📅 *¿Qué días gastas más?*"))
    
    await update.message.reply_media_group(media=media)
    
    # AHORROS
    savings = sheets_manager.get_savings()
    if savings:
        sav_msg = "💰 *Progreso de Ahorros:*\n"
        for s in savings:
            sav_msg += f"• {s['Meta']}: {s['Porcentaje']} de ${float(s['Objetivo USD']):,.0f}\n"
        await update.message.reply_text(sav_msg, parse_mode="Markdown")
    
    # AI COACHING
    advice = get_financial_advice(summary)
    await update.message.reply_text(f"🤖 *Consejos del Coach (IA):*\n\n{advice}", parse_mode="Markdown")
    await msg.delete()

async def add_category_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not context.args:
        await update.message.reply_text("⚠️ Uso: `/nueva <Nombre>`")
        return
    new_cat = " ".join(context.args)
    if sheets_manager.add_category(new_cat):
        await update.message.reply_text(f"✅ Categoría *{new_cat}* creada.", parse_mode="Markdown")

async def show_categories(update: Update, context: ContextTypes.DEFAULT_TYPE):
    cats = sheets_manager.get_categories()
    await update.message.reply_text(f"🏷️ *Categorías:*\n\n" + "\n".join([f"• {c}" for c in cats]), parse_mode="Markdown")

async def budget_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not context.args or len(context.args) < 2:
        await update.message.reply_text("⚠️ Uso: `/presupuesto Comida 200`", parse_mode="Markdown")
        return
    try:
        amount = float(context.args[-1])
        category = " ".join(context.args[:-1])
        if sheets_manager.set_budget(category, amount):
            await update.message.reply_text(f"✅ Presupuesto para *{category}* fijado en *${amount}*", parse_mode="Markdown")
        else:
            await update.message.reply_text("❌ Error guardando presupuesto.")
    except ValueError:
        await update.message.reply_text("⚠️ El monto debe ser un número.")
    except ValueError:
        await update.message.reply_text("⚠️ El monto debe ser un número.")
    except Exception as e:
        logger.error(f"DEBUG: Error in budget_command: {str(e)}", exc_info=True)
        await update.message.reply_text("❌ Error inesperado guardando presupuesto.")

async def ahorro_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Gestión de ahorros: /ahorro Meta 500 o /ahorro +Meta 50"""
    if not context.args:
        # Mostrar ahorros actuales
        savings = sheets_manager.get_savings()
        if not savings:
            await update.message.reply_text("💡 No tienes metas de ahorro. Crea una con `/ahorro Nombre MontoObjetivo`.")
            return
        msg = "💰 *Tus Metas de Ahorro:*\n\n"
        for s in savings:
            msg += f"• *{s['Meta']}:* ${float(s['Ahorrado Actual']):,.2f} / ${float(s['Objetivo USD']):,.2f} ({s['Porcentaje']})\n"
        await update.message.reply_text(msg, parse_mode="Markdown")
        return

    try:
        # Verificar si el monto (último arg) tiene signo explícito (+/-)
        # o si el nombre (primer arg) tiene signo (sintaxis vieja)
        target_arg = context.args[-1]
        is_amount_signed = target_arg.startswith("+") or target_arg.startswith("-")
        
        if is_amount_signed or context.args[0].startswith("+") or context.args[0].startswith("-"):
            # AÑADIR/RESTAR
            if is_amount_signed:
                # Caso: /ahorro Meta +50
                amount = float(target_arg) # float() maneja "+50" y "-50"
                name = " ".join(context.args[:-1])
            else:
                # Caso: /ahorro +Meta 50 (Legacy)
                prefix = context.args[0][0]
                name = context.args[0][1:]
                amount = float(context.args[1])
                if prefix == "-": amount = -amount
            
            user = update.effective_user.first_name
            res = sheets_manager.add_savings(name, amount, user)
            if res["success"]:
                action = "aumenta" if amount > 0 else "disminuye"
                msg = f"✅ ¡{name} {action}! Nuevo total: *${res['new_total']:,.2f}* ({res['new_pct']:.1f}%)"
                if res["reached_milestone"] and amount > 0:
                    msg += f"\n\n🎊 ⭐ ¡HITOS ALCANZADO! ⭐ 🎊\nHas superado el *{res['reached_milestone']}%* de tu meta para {name}. ¡Sigue así!"
                await update.message.reply_text(msg, parse_mode="Markdown")
            else:
                await update.message.reply_text(f"❌ No encontré la meta '{name}'.")
        else:
            # Nueva meta o actualización: /ahorro Vacaciones 1000
            if len(context.args) < 2:
                raise ValueError("Falta monto")
            amount = float(context.args[-1])
            name = " ".join(context.args[:-1])
            if sheets_manager.set_savings_goal(name, amount):
                await update.message.reply_text(f"🎯 Meta *{name}* fijada en *${amount}*.", parse_mode="Markdown")
    except:
        await update.message.reply_text("⚠️ Uso:\n- `/ahorro Nombre Monto` (Crear)\n- `/ahorro +Nombre Monto` (Ahorrar)\n- `/ahorro -Nombre Monto` (Retirar)", parse_mode="Markdown")

async def hitos_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Configurar hitos: /hitos Casa 10,25,50,75,100"""
    if not context.args or len(context.args) < 2:
        await update.message.reply_text("⚠️ Uso: `/hitos NombreMeta 10,25,50,75,100`", parse_mode="Markdown")
        return
    
    hitos = context.args[-1]
    name = " ".join(context.args[:-1])
    
    if sheets_manager.set_milestones(name, hitos):
        await update.message.reply_text(f"✅ Hitos para *{name}* configurados: {hitos}%", parse_mode="Markdown")
    else:
        await update.message.reply_text(f"❌ No encontré la meta '{name}'.")

async def deuda_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Registrar deuda: /deuda Persona Monto FechaRetorno (YYYY-MM-DD)"""
    if not context.args or len(context.args) < 3:
        await update.message.reply_text("⚠️ Uso: `/deuda Juan 50 2024-02-15`", parse_mode="Markdown")
        return
    try:
        date_ret = context.args[-1]
        amount = float(context.args[-2])
        name = " ".join(context.args[:-2])
        user = update.effective_user.first_name
        if sheets_manager.add_debtor(name, amount, date_ret, user):
            await update.message.reply_text(f"📝 Deuda de *{name}* registrada por *${amount}* para el *{date_ret}*.\n👤 Responsable: *{user}*", parse_mode="Markdown")
        else:
            await update.message.reply_text("❌ Error registrando deuda.")
    except:
        await update.message.reply_text("⚠️ Asegúrate que el monto sea un número y la fecha YYYY-MM-DD.")

async def pagado_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Marcar como pagado: /pagado Persona"""
    if not context.args:
        # Mostrar deudas pendientes
        debts = sheets_manager.get_pending_debts()
        if not debts:
            await update.message.reply_text("✅ No tienes deudas pendientes por cobrar.")
            return
        msg = "📋 *Deudas Pendientes:*\n\n"
        for d in debts:
            msg += f"• *{d['Persona']}:* ${float(d['Monto Préstamo']):,.2f} (Vence: {d['Fecha Retorno']})\n"
        await update.message.reply_text(msg, parse_mode="Markdown")
        return
    
    name = " ".join(context.args)
    if sheets_manager.mark_debt_as_paid(name):
        await update.message.reply_text(f"💰 ¡Cobrado! Deuda de *{name}* marcada como pagada.", parse_mode="Markdown")
    else:
        await update.message.reply_text(f"❌ No encontré deuda pendiente de '{name}'.")

async def debt_reminder_job(context: ContextTypes.DEFAULT_TYPE):
    """Revisar deudas diarias y notificar vencimientos."""
    logger.info("Ejecutando verificador de deudas...")
    debts = sheets_manager.get_pending_debts()
    today = datetime.now().strftime("%Y-%m-%d")
    
    for d in debts:
        if d['Fecha Retorno'] == today:
            msg = f"📅 *RECORDATORIO DE DEUDA*\n\n⚠️ Hoy vence el préstamo de *{d['Persona']}*\n💰 Monto: *${float(d['Monto Préstamo']):,.2f}*\n\nUsa `/pagado {d['Persona']}` cuando lo cobres."
            
            # Enviar a todos los chats registrados
            chats = database.get_all_chats()
            for chat in chats:
                try:
                    await context.bot.send_message(chat['chat_id'], msg, parse_mode="Markdown")
                except Exception as e:
                    logger.warning(f"No se pudo enviar a chat {chat['chat_id']}: {e}")

async def smart_alerts_job(context: ContextTypes.DEFAULT_TYPE):
    """Alertas inteligentes: inactividad, gastos inusuales, metas estancadas."""
    logger.info("Ejecutando alertas inteligentes...")
    
    try:
        # Obtener datos del mes
        summary = sheets_manager.get_monthly_summary()
        if not summary or summary['count'] == 0:
            return
        
        alerts = []
        
        # 1. ALERTA DE INACTIVIDAD (sin gastos en 3+ días)
        if summary['daily_trend']:
            from datetime import timedelta
            last_expense_date = None
            for t in reversed(summary['daily_trend']):
                try:
                    last_expense_date = datetime.strptime(str(t['Fecha']), "%Y-%m-%d")
                    break
                except: continue
            
            if last_expense_date:
                days_inactive = (datetime.now() - last_expense_date).days
                if days_inactive >= 3:
                    alerts.append(f"📭 *Sin actividad*: Llevas {days_inactive} días sin registrar gastos. ¿Todo bien?")
        
        # 2. ALERTA DE GASTO INUSUAL (último gasto > 3x promedio)
        if summary['daily_trend'] and len(summary['daily_trend']) > 5:
            amounts = [float(str(t.get('Monto USD', 0)).replace(',', '.')) for t in summary['daily_trend']]
            avg = sum(amounts[:-1]) / len(amounts[:-1]) if len(amounts) > 1 else 0
            last_amount = amounts[-1] if amounts else 0
            
            if avg > 0 and last_amount > avg * 3:
                alerts.append(f"⚠️ *Gasto inusual*: Tu último gasto (${last_amount:,.2f}) es {last_amount/avg:.1f}x mayor que tu promedio.")
        
        # 3. ALERTA DE PRESUPUESTO CRÍTICO (>90%)
        budgets = sheets_manager.get_all_budgets()
        for cat, budget in budgets.items():
            spent = summary['by_category'].get(cat, 0)
            if budget > 0:
                pct = (spent / budget) * 100
                if pct >= 90:
                    alerts.append(f"🔴 *Presupuesto crítico*: {cat} al {pct:.0f}% (${spent:,.2f}/${budget:,.2f})")
        
        # 4. ALERTA DE META DE AHORRO ESTANCADA
        savings = sheets_manager.get_savings()
        for s in savings:
            try:
                last_update = s.get('Ultima Act', '')
                if last_update:
                    last_date = datetime.strptime(last_update[:10], "%Y-%m-%d")
                    days_stale = (datetime.now() - last_date).days
                    if days_stale >= 14:
                        alerts.append(f"💤 *Meta estancada*: '{s['Meta']}' no ha crecido en {days_stale} días.")
            except: continue
        
        # Enviar alertas a todos los chats registrados
        if alerts:
            full_msg = "🔔 *ALERTAS INTELIGENTES*\n\n" + "\n\n".join(alerts)
            chats = database.get_all_chats()
            for chat in chats:
                try:
                    await context.bot.send_message(chat['chat_id'], full_msg, parse_mode="Markdown")
                except Exception as e:
                    logger.warning(f"No se pudo enviar alerta a chat {chat['chat_id']}: {e}")
        
    except Exception as e:
        logger.error(f"Error en smart_alerts_job: {e}")

async def recurrente_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Configurar gasto recurrente: /recurrente Netflix 15 25"""
    try:
        if len(context.args) < 3:
            await update.message.reply_text("⚠️ Uso: `/recurrente Nombre Monto DiaDelMes`\nEj: `/recurrente Netflix 15.0 25`", parse_mode="Markdown")
            return
        
        name = context.args[0]
        amount = float(context.args[1])
        day = int(context.args[2])
        
        if not (1 <= day <= 31):
            await update.message.reply_text("⚠️ El día debe ser entre 1 y 31.")
            return

        if sheets_manager.add_recurring(name, amount, day):
            await update.message.reply_text(f"🔄 Pago recurrente de *{name}* (${amount}) programado para el día *{day}* de cada mes.", parse_mode="Markdown")
        else:
            await update.message.reply_text("❌ Error guardando recurrente.")
    except Exception as e:
        await update.message.reply_text(f"⚠️ Error de formato: {e}")

async def recurring_check_job(context: ContextTypes.DEFAULT_TYPE):
    """Revisar si hay pagos recurrentes hoy."""
    logger.info("Verificando pagos recurrentes...")
    to_pay = sheets_manager.check_recurring() # Devuelve lista de {row, data}
    
    if not to_pay: return
    
    # Necesitamos un chat_id para notificar. Usaremos el último conocido o broadcast a admins?
    # Limitación: Jobs no tienen update.effective_chat. 
    # Solución: En un bot real, guardar chat_id en DB. Aquí hardcodeamos alerta o log.
    # Pero el comando /start guarda el chat_id? No tenemos DB simple para eso.
    # Asumiremos que el usuario interactúa mucho y usamos el contexto global o notify si tuviéramos chat_id.
    # TRUCO: Si el usuario usa el bot, podemos intentar enviar al último chat activo si lo guardáramos.
    # Por ahora solo LOGS hasta que tengamos chat_id persistence.
    
    for item in to_pay:
        p = item["data"]
        msg = f"🔔 *RECORDATORIO DE PAGO RECURRENTE*\n\n" \
              f"🗓️ Es día {p['Dia']}! Toca pagar: *{p['Nombre']}* (${p['Monto']})\n" \
              f"¿Ya lo pagaste? Usa el botón abajo para registrarlo."
        
        # Como no tenemos chat_id fiable en este scope simple, solo logueamos.
        # MEJORA: Guardar CHAT_ID en sheets_manager.config cuando alguien usa /start
        logger.warning(f"RECURRENTE: TOCA PAGAR {p['Nombre']}")

async def reporte_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Generar reporte Excel."""
    msg = await update.message.reply_text("📊 Generando reporte Excel...")
    try:
        ss = sheets_manager.get_monthly_spreadsheet() 
        # Traer todo
        g_recs = ss.worksheet("Gastos").get_all_records()
        i_recs = ss.worksheet("Ingresos").get_all_records()
        
        # Crear Excel en memoria
        wb = pd.ExcelWriter("reporte.xlsx", engine="openpyxl")
        
        if g_recs:
            df_g = pd.DataFrame(g_recs)
            df_g.to_excel(wb, sheet_name="Gastos", index=False)
            
        if i_recs:
            df_i = pd.DataFrame(i_recs)
            df_i.to_excel(wb, sheet_name="Ingresos", index=False)
            
        # Guardar buffer
        buf = io.BytesIO()
        wb.book.save(buf)
        wb.close()
        buf.seek(0)
        
        fname = f"Reporte_{datetime.now().strftime('%Y_%m')}.xlsx"
        await update.message.reply_document(document=buf, filename=fname, caption="Aquí tienes tu reporte mensual 📄")
        await msg.delete()
    except Exception as e:
        await msg.edit_text(f"❌ Error generando reporte: {e}")

async def consejo_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Auditoría financiera con IA sobre últimos gastos."""
    msg = await update.message.reply_text("🕵️ Auditando tus gastos con IA... Espere.")
    try:
        ss = sheets_manager.get_monthly_spreadsheet()
        sheet = ss.worksheet("Gastos")
        # Obtener últimos 30
        all_vals = sheet.get_all_values()
        headers = all_vals[0]
        data = all_vals[1:]
        last_30 = data[-30:] if len(data) > 30 else data
        
        if not last_30:
            await msg.edit_text("❌ No hay suficientes gastos para auditar.")
            return

        # Formatear para Gemini
        text_data = "Fecha | Concepto | Monto USD | Categoria\n"
        for r in last_30:
            # Índices: Fecha(0), Monto USD(5), Concepto(12), Categoria(13). Ojo índices varían, usar map simple
            # O mejor, usar los headers para ser dinámico si get_all_records falló o es lento. 
            # Usamos índices fijos de sheets_manager:
            # Gastos: Fecha(0), ..., Monto USD(5), ..., Concepto(12), Categoria(13)
            try:
                # Comprobación de seguridad de índices
                row_txt = f"{r[0]} | {r[12] if len(r)>12 else ''} | {r[5] if len(r)>5 else ''} | {r[13] if len(r)>13 else ''}"
                text_data += row_txt + "\n"
            except: continue
            
        prompt = f"""Actúa como un auditor financiero experto. Analiza estos últimos gastos de una familia en Venezuela y busca:
1. Patrones de gasto excesivo.
2. Gastos hormiga detectados.
3. Suscripciones ocultas o repetidas.
4. Oportunidades de ahorro.
DAME UN REPORTE CONCRETO Y DIRECTO (Bullet points).
DATOS:
{text_data}"""

        response = gemini_analyzer.model.generate_content(prompt)
        advice = response.text
        
        await msg.edit_text(f"🕵️ *INFORME DE AUDITORÍA:*\n\n{advice}", parse_mode="Markdown")
        
    except Exception as e:
        await msg.edit_text(f"❌ Error en auditoría: {e}")

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "❓ *Ayuda del Bot*\n\n"
        "/start - Menú y bienvenida\n"
        "/tasa - Configurar tasa Bs/$\n"
        "/analisis - Dashboard completo e IA\n"
        "/presupuesto <Cat> <Monto> - Limitar gastos\n"
        "/categorias - Ver categorías\n"
        "/nueva <Nombre> - Crear categoría\n\n"
        "💡 Envía una **foto del recibo** para registrarlo automáticamente.",
        parse_mode="Markdown"
    )

async def update_rates_job(context: ContextTypes.DEFAULT_TYPE):
    """Tarea horaria para actualizar tasas"""
    logger.info("Ejecutando actualización de tasa automática...")
    rates = currency_service.get_current_rates()
    if not rates: return
    bcv = rates.get("oficial", 0)
    paralelo = rates.get("paralelo", 0)
    current_rate = sheets_manager.get_exchange_rate()
    source = sheets_manager.get_rate_source()
    new_rate = bcv if source == "BCV" else paralelo if source == "PARALELO" else None
    
    if new_rate and abs(new_rate - current_rate) > 0.01:
        sheets_manager.set_exchange_rate(new_rate, source, bcv=bcv, paralelo=paralelo)
        logger.info(f"Tasa actualizada automáticamente a {new_rate} ({source})")
    else:
        sheets_manager.set_exchange_rate(current_rate, source, bcv=bcv, paralelo=paralelo)

async def handle_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    msg = await update.message.reply_text("🔄 Analizando imagen...")
    caption = update.message.caption
    photo = update.message.photo[-1]
    file = await context.bot.get_file(photo.file_id)
    image_bytes = await file.download_as_bytearray()
    
    result = analyze_receipt(bytes(image_bytes), caption=caption)
    await msg.delete()
    if result["success"]:
        await process_analysis_result(update, result["data"], bytes(image_bytes))
    else:
        await update.message.reply_text("❌ No pude leer la imagen.")

async def handle_text(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.message.text.startswith("/"): return
    msg = await update.message.reply_text("🤔 Analizando texto...")
    result = analyze_text(update.message.text)
    await msg.delete()
    if result["success"]:
        await process_analysis_result(update, result["data"], None)

async def process_analysis_result(update: Update, data: dict, image_bytes: bytes = None):
    """Punto de entrada tras el análisis: decide si guarda directo o pregunta."""
    # Verificar si el usuario quiere auto-guardado
    conf_required = sheets_manager.is_confirmation_required()
    
    if not conf_required:
        # GUARDADO DIRECTO
        await update.effective_message.reply_text("💾 Guardando automáticamente...")
        drive_link = ""
        if image_bytes:
            try:
                fname = f"AUTO_{data.get('monto')}.jpg"
                drive_link = drive_manager.upload_receipt(image_bytes, fname, data.get("fecha"))
            except Exception as e:
                logger.error(f"Error subiendo a Drive: {e}")
                await update.effective_message.reply_text(f"⚠️ No se pudo subir la imagen a Drive: {e}")
        
        user = update.effective_user.first_name
        success, res_msg = sheets_manager.add_transaction(data, user, drive_link, is_income=False)
        
        if success:
            msg = f"✅ Guardado automático exitoso!\n👤 Responsable: *{user}*"
            alert = sheets_manager.check_budget_alert(data.get("categoria", ""))
            if alert and alert['alert'] != "green":
                msg += f"\n\n⚠️ *PRESUPUESTO:* Vas al {alert['pct']:.1f}% en {data.get('categoria')}"
            await update.effective_message.reply_text(msg, parse_mode="Markdown")
        else:
            await update.effective_message.reply_text(f"❌ Error: {res_msg}")
        return

    # MODALIDAD MANUAL (Botones)
    rate = sheets_manager.get_exchange_rate()
    monto = data.get('monto', 0)
    moneda = data.get('moneda', 'Bs')
    est_usd = monto if moneda.lower() in ['usd', '$'] else monto / rate
    formatted_msg = format_receipt_message(data)
    formatted_msg += f"\n\n💵 *Estimado:* ${est_usd:,.2f} (Tasa: {rate})"
    
    # Usamos ID de mensaje de respuesta para el pending_key para evitar colisiones
    reply_msg = await update.effective_message.reply_text("...") # Placeholder
    pending_key = f"{update.effective_chat.id}:{reply_msg.message_id}"
    
    pending_data[pending_key] = {
        "data": data, "image_bytes": image_bytes, "user": update.effective_user.first_name
    }
    
    keyboard = [
        [InlineKeyboardButton("✅ Guardar Gasto", callback_data=f"save_exp_{pending_key}"), InlineKeyboardButton("💰 Es Ingreso", callback_data=f"save_inc_{pending_key}")],
        [InlineKeyboardButton("🏷️ Categoría", callback_data=f"cat_{pending_key}"), InlineKeyboardButton("❌ Descartar", callback_data=f"disc_{pending_key}")]
    ]
    await reply_msg.edit_text(formatted_msg, parse_mode="Markdown", reply_markup=InlineKeyboardMarkup(keyboard))

async def handle_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    parts = query.data.split("_")
    action = parts[0]
    
    if action in ["save", "save_exp", "save_inc"]:
        # Manejar save_exp_... y save_inc_...
        is_income = (action == "save_inc")
        # pending_key siempre es el último elemento ahora (separado por :)
        pending_key = parts[-1]
        
        if pending_key not in pending_data:
            await query.edit_message_text("❌ Error: Datos perdidos. Por favor re-envía la imagen.")
            return
            
        expense = pending_data[pending_key]
        await query.edit_message_text(f"💾 Guardando {'Ingreso' if is_income else 'Gasto'}...")
        
        drive_link = ""
        if expense["image_bytes"]:
            try:
                fname = f"{'IN' if is_income else 'OUT'}_{expense['data'].get('monto')}.jpg"
                drive_link = drive_manager.upload_receipt(expense["image_bytes"], fname, expense['data'].get("fecha"))
            except Exception as e:
                logger.error(f"Error subiendo a Drive: {e}")
                await query.edit_message_text(f"⚠️ Error subiendo imagen: {e}. Guardando datos...")
        
        success, res_msg = sheets_manager.add_transaction(expense["data"], expense["user"], drive_link, is_income)
        if success:
            msg = f"✅ Guardado con éxito!\n👤 Responsable: *{expense['user']}*"
            if not is_income:
                alert = sheets_manager.check_budget_alert(expense["data"].get("categoria", ""))
                if alert and alert['alert'] != "green":
                    msg += f"\n\n⚠️ *PRESUPUESTO:* Vas al {alert['pct']:.1f}% en {expense['data'].get('categoria')}"
            
            # Verificar pagos recurrentes
            if not is_income and "pago recurrente" in str(expense["data"].get("concepto", "")).lower():
                 # Si viene de un job recurrente, marcar como pagado (necesitaríamos lógica extra, 
                 # por ahora el job lo marca directo al detectar el gasto, o mejor, el job envía el gasto y marca pagado)
                 pass
                 
            await query.edit_message_text(msg, parse_mode="Markdown")
        else:
            await query.edit_message_text(f"❌ Error: {res_msg}")
        
        del pending_data[pending_key]

    elif action == "disc":
        pending_key = parts[-1]
        if pending_key in pending_data: del pending_data[pending_key]
        await query.edit_message_text("🗑️ Operación cancelada.")

    elif action == "setrate":
        source, rate_val = parts[1], float(parts[2])
        rates = currency_service.get_current_rates()
        bcv = rates.get("oficial", 0) if rates else 0
        paralelo = rates.get("paralelo", 0) if rates else 0
        sheets_manager.set_exchange_rate(rate_val, source, bcv=bcv, paralelo=paralelo)
        await query.edit_message_text(f"✅ Tasa fijada en {rate_val} ({source})")

    elif action == "cat":
        pending_key = parts[-1]
        cats = sheets_manager.get_categories()
        kb = [[InlineKeyboardButton(c, callback_data=f"setcat_{c}_{pending_key}")] for c in cats[:15]]
        await query.edit_message_text("🏷️ Selecciona categoría:", reply_markup=InlineKeyboardMarkup(kb))

    elif action == "setcat":
        # setcat_Categoria_Key
        key = parts[-1]
        cat = "_".join(parts[1:-1])
        
        if key in pending_data:
            pending_data[key]["data"]["categoria"] = cat
            # Refrescar mensaje
            rate = sheets_manager.get_exchange_rate()
            data = pending_data[key]["data"]
            monto = data.get('monto', 0)
            moneda = data.get('moneda', 'Bs')
            est_usd = monto if moneda.lower() in ['usd', '$'] else monto / rate
            formatted = format_receipt_message(data)
            formatted += f"\n\n💵 *Estimado:* ${est_usd:,.2f} (Tasa: {rate})"
            keyboard = [
                [InlineKeyboardButton("✅ Guardar Gasto", callback_data=f"save_exp_{key}"), InlineKeyboardButton("💰 Es Ingreso", callback_data=f"save_inc_{key}")],
                [InlineKeyboardButton("🏷️ Categoría", callback_data=f"cat_{key}"), InlineKeyboardButton("❌ Descartar", callback_data=f"disc_{key}")]
            ]
            await query.edit_message_text(formatted, parse_mode="Markdown", reply_markup=InlineKeyboardMarkup(keyboard))

    elif action == "dup":
        # dup_confirm_ID o dup_cancel
        subaction = parts[1] if len(parts) > 1 else ""
        
        if subaction == "cancel":
            await query.edit_message_text("🗑️ Duplicación cancelada.")
        elif subaction == "confirm":
            gasto_id = int(parts[2]) if len(parts) > 2 else None
            
            if not gasto_id:
                await query.edit_message_text("❌ Error: ID de gasto no válido.")
                return
            
            # Obtener gasto original
            gastos = database.get_gastos_mes()
            gasto_original = None
            for g in gastos:
                if g.get('id') == gasto_id:
                    gasto_original = g
                    break
            
            if not gasto_original:
                await query.edit_message_text("❌ Error: Gasto original no encontrado.")
                return
            
            # Registrar duplicado
            user_name = query.from_user.first_name
            data = {
                "fecha": datetime.now().strftime("%Y-%m-%d"),
                "monto": gasto_original['monto_usd'],
                "moneda": "USD",
                "concepto": gasto_original.get('concepto', ''),
                "categoria": gasto_original.get('categoria', 'Otros')
            }
            
            success, res_msg = sheets_manager.add_transaction(data, user_name, "", is_income=False)
            
            if success:
                database.get_or_create_user(query.from_user.id, user_name)
                database.update_streak(query.from_user.id)
                await query.edit_message_text(
                    f"✅ *Gasto duplicado*\n\n"
                    f"💵 ${gasto_original['monto_usd']:.2f} en {gasto_original.get('categoria', 'Otros')}\n"
                    f"👤 {user_name}",
                    parse_mode="Markdown"
                )
            else:
                await query.edit_message_text(f"❌ Error: {res_msg}")

async def post_init(application: Application):
    commands = [
        BotCommand("start", "🏠 Inicio"),
        BotCommand("hoja", "🔗 Ver Hoja de Gastos"),
        BotCommand("tasa", "💵 Tasa Bs/$"),
        BotCommand("analisis", "📈 Análisis e IA"),
        BotCommand("resumen", "📊 Resumen rápido"),
        BotCommand("presupuesto", "📊 /presupuesto <Cat> <Monto>"),
        BotCommand("ahorro", "💰 /ahorro <Meta> <Monto>"),
        BotCommand("hitos", "⭐ /hitos <Meta> <10,25...>%"),
        BotCommand("deuda", "📝 /deuda <Pers> <Monto> <Fecha>"),
        BotCommand("pagado", "💰 /pagado [Pers]"),
        BotCommand("recurrente", "🔄 /recurrente <Nom> <$$> <Día>"),
        BotCommand("reporte", "📄 /reporte Excel"),
        BotCommand("consejo", "🕵️ /consejo Auditoría"),
        BotCommand("comparar", "🔄 Comparar con mes anterior"),
        BotCommand("g", "⚡ /g Monto Categoria (Rápido)"),
        BotCommand("score", "🎯 Tu puntaje financiero"),
        BotCommand("logros", "🏆 Ver logros"),
        BotCommand("ranking", "👨‍👩‍👧‍👦 Ranking familiar"),
        BotCommand("silencio", "🔕 Modo silencioso"),
        BotCommand("reto", "🎯 Retos mensuales"),
        # V7.0
        BotCommand("f", "📌 /f <atajo> (Gasto fijado)"),
        BotCommand("preguntar", "🤖 Pregunta a la IA"),
        BotCommand("limite", "💰 Límite diario"),
        BotCommand("tendencias", "📈 Análisis de tendencias"),
        BotCommand("proyeccion", "📊 Proyección de ahorro"),
        BotCommand("email", "📧 Reportes por email"),
        BotCommand("tag", "🏷️ Gastos por etiqueta"),
        # Pendientes completados
        BotCommand("csv", "📥 Importar gastos CSV"),
        BotCommand("anos", "📅 Comparar años"),
        BotCommand("galeria", "📸 Galería de recibos"),
        BotCommand("duplicar", "🔁 Repetir último gasto"),
        BotCommand("webapp", "📱 Dashboard Visual"),
        BotCommand("nueva", "🆕 /nueva <NombreCat>")
    ]
    await application.bot.set_my_commands(commands)
    # Asegurar visibilidad en grupos
    from telegram import BotCommandScopeAllPrivateChats, BotCommandScopeAllGroupChats
    await application.bot.set_my_commands(commands, scope=BotCommandScopeAllPrivateChats())
    await application.bot.set_my_commands(commands, scope=BotCommandScopeAllGroupChats())
    application.job_queue.run_repeating(update_rates_job, interval=3600, first=10)
    application.job_queue.run_daily(debt_reminder_job, time=datetime.strptime("09:00", "%H:%M").time())
    application.job_queue.run_daily(recurring_check_job, time=datetime.strptime("08:00", "%H:%M").time())
    application.job_queue.run_daily(smart_alerts_job, time=datetime.strptime("10:00", "%H:%M").time())
    # Resumen semanal cada lunes a las 9am
    from datetime import time as dt_time
    application.job_queue.run_daily(weekly_summary_job, time=dt_time(9, 0), days=(0,))  # 0 = Lunes
    # Recordatorio de presupuesto los días 1, 15 y 30
    application.job_queue.run_daily(budget_reminder_job, time=dt_time(10, 30))

# ==================== COMANDOS DE GAMIFICACIÓN ====================

async def gasto_rapido_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/g - Registro rápido: /g 50 comida"""
    await register_chat_if_new(update)
    
    if not context.args or len(context.args) < 2:
        await update.message.reply_text("⚡ *Gasto Rápido*\n\nUso: `/g 50 comida`\nO: `/g 25.50 taxi almuerzo`", parse_mode="Markdown")
        return
    
    try:
        monto = float(context.args[0])
        categoria = context.args[1].capitalize()
        concepto = " ".join(context.args[2:]) if len(context.args) > 2 else categoria
        
        user_id = update.effective_user.id
        user_name = update.effective_user.first_name
        
        # Crear perfil si no existe
        database.get_or_create_user(user_id, user_name)
        
        # Verificar modo silencioso
        silent = database.is_silent_mode(user_id)
        
        data = {
            "fecha": datetime.now().strftime("%Y-%m-%d"),
            "monto": monto,
            "moneda": "USD",
            "concepto": concepto,
            "categoria": categoria
        }
        
        success, msg = sheets_manager.add_transaction(data, user_name, "", is_income=False)
        
        if success:
            # Actualizar streak y verificar logros
            streak_info = database.update_streak(user_id)
            nuevos_logros = database.check_and_award_logros(user_id)
            
            if silent:
                await update.message.reply_text("✅", parse_mode="Markdown")
            else:
                response = f"⚡ *${monto:.2f}* en _{categoria}_"
                if streak_info and streak_info['nuevo_dia']:
                    response += f" | 🔥 Racha: {streak_info['streak']}"
                
                for logro in nuevos_logros:
                    response += f"\n\n🏆 *¡LOGRO DESBLOQUEADO!*\n{logro['icono']} {logro['nombre']}"
                
                await update.message.reply_text(response, parse_mode="Markdown")
        else:
            await update.message.reply_text(f"❌ Error: {msg}")
            
    except ValueError:
        await update.message.reply_text("⚠️ El primer argumento debe ser un número.")

async def score_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/score - Ver puntaje financiero."""
    user_id = update.effective_user.id
    user_name = update.effective_user.first_name
    
    database.get_or_create_user(user_id, user_name)
    score = database.calculate_score_financiero(user_id)
    stats = database.get_user_stats(user_id)
    
    # Barra visual
    filled = int(score / 10)
    bar = "█" * filled + "░" * (10 - filled)
    
    # Emoji según score
    if score >= 80: emoji = "🌟"
    elif score >= 60: emoji = "👍"
    elif score >= 40: emoji = "😐"
    else: emoji = "😰"
    
    msg = f"{emoji} *Tu Score Financiero*\n\n"
    msg += f"[{bar}] *{score}/100*\n\n"
    msg += f"🔥 Racha actual: *{stats.get('streak_actual', 0)}* días\n"
    msg += f"📝 Gastos registrados: *{stats.get('total_gastos_registrados', 0)}*\n"
    msg += f"⭐ Experiencia: *{stats.get('experiencia', 0)}* pts\n"
    msg += f"🏆 Logros: *{stats.get('logros_count', 0)}*\n\n"
    
    # Consejos
    if score < 50:
        msg += "💡 _Registra más gastos y configura presupuestos para mejorar._"
    elif score < 80:
        msg += "💡 _¡Vas bien! Mantén la racha y ahorra más._"
    else:
        msg += "💡 _¡Excelente! Tienes finanzas saludables._"
    
    await update.message.reply_text(msg, parse_mode="Markdown")

async def logros_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/logros - Ver logros desbloqueados y pendientes."""
    user_id = update.effective_user.id
    stats = database.get_user_stats(user_id)
    
    if not stats:
        await update.message.reply_text("❌ Primero registra un gasto para crear tu perfil.")
        return
    
    conn = database.get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM logros ORDER BY puntos")
    todos_logros = [dict(row) for row in cursor.fetchall()]
    conn.close()
    
    desbloqueados = [l['codigo'] for l in stats.get('logros', [])]
    
    msg = "🏆 *Tus Logros*\n\n"
    
    for logro in todos_logros:
        if logro['codigo'] in desbloqueados:
            msg += f"✅ {logro['icono']} *{logro['nombre']}* (+{logro['puntos']}pts)\n"
        else:
            msg += f"🔒 {logro['icono']} _{logro['nombre']}_\n"
    
    msg += f"\n_Desbloqueados: {len(desbloqueados)}/{len(todos_logros)}_"
    
    await update.message.reply_text(msg, parse_mode="Markdown")

async def ranking_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/ranking - Ver ranking familiar por score."""
    ranking = database.get_ranking()
    
    if not ranking:
        await update.message.reply_text("📊 No hay suficientes usuarios para mostrar ranking.")
        return
    
    msg = "👨‍👩‍👧‍👦 *Ranking Familiar*\n\n"
    
    medals = ["🥇", "🥈", "🥉"]
    for i, user in enumerate(ranking):
        medal = medals[i] if i < 3 else f"{i+1}."
        nombre = user['nombre'] or "Anónimo"
        msg += f"{medal} *{nombre}*: {user['score_financiero']}pts"
        if user['streak_actual'] and user['streak_actual'] > 0:
            msg += f" 🔥{user['streak_actual']}"
        msg += "\n"
    
    await update.message.reply_text(msg, parse_mode="Markdown")

async def silencio_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/silencio - Toggle modo silencioso."""
    user_id = update.effective_user.id
    database.get_or_create_user(user_id, update.effective_user.first_name)
    
    current = database.is_silent_mode(user_id)
    new_mode = not current
    database.set_silent_mode(user_id, new_mode)
    
    if new_mode:
        await update.message.reply_text("🔕 *Modo silencioso activado*\n\nAhora `/g` solo responderá con ✅", parse_mode="Markdown")
    else:
        await update.message.reply_text("🔔 *Modo silencioso desactivado*\n\nVerás respuestas completas.", parse_mode="Markdown")

async def reto_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/reto - Ver o crear retos mensuales."""
    if not context.args:
        # Mostrar retos activos
        retos = database.get_retos_activos()
        if not retos:
            await update.message.reply_text(
                "🎯 *Retos Mensuales*\n\n"
                "No hay retos este mes.\n\n"
                "Crear uno: `/reto crear \"Gastar menos de 200 en comida\" comida 200`",
                parse_mode="Markdown"
            )
            return
        
        msg = "🎯 *Retos Mensuales*\n\n"
        for r in retos:
            msg += f"• *{r['titulo']}*\n  Meta: ${r['meta_valor']}"
            if r['categoria']:
                msg += f" en {r['categoria']}"
            msg += "\n\n"
        
        await update.message.reply_text(msg, parse_mode="Markdown")
    
    elif context.args[0] == "crear" and len(context.args) >= 4:
        titulo = context.args[1]
        categoria = context.args[2] if len(context.args) > 3 else None
        try:
            meta = float(context.args[-1])
            if database.create_reto_mensual(titulo, "", "gasto_max", meta, categoria):
                await update.message.reply_text(f"✅ Reto creado: *{titulo}*", parse_mode="Markdown")
            else:
                await update.message.reply_text("❌ Error creando reto.")
        except:
            await update.message.reply_text("⚠️ Formato: `/reto crear \"Título\" categoria monto`", parse_mode="Markdown")

# ==================== COMANDOS V7.0 ====================

async def fijado_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/f - Gasto fijado ultra-rápido o gestión de atajos."""
    user_id = update.effective_user.id
    user_name = update.effective_user.first_name
    
    if not context.args:
        # Mostrar atajos disponibles
        fijados = database.get_gastos_fijados(user_id)
        if not fijados:
            await update.message.reply_text(
                "📌 *Gastos Fijados*\n\n"
                "No tienes atajos configurados.\n\n"
                "Crear uno: `/f crear café 2.50 comida`\n"
                "Usar: `/f café` → Registra $2.50 en Comida",
                parse_mode="Markdown"
            )
            return
        
        msg = "📌 *Tus Gastos Fijados*\n\n"
        for f in fijados:
            msg += f"• `/f {f['atajo']}` → ${f['monto']:.2f} ({f['categoria']})\n"
        msg += "\n_Usa `/f borrar <atajo>` para eliminar_"
        await update.message.reply_text(msg, parse_mode="Markdown")
        return
    
    action = context.args[0].lower()
    
    if action == "crear" and len(context.args) >= 4:
        # /f crear café 2.50 comida
        atajo = context.args[1]
        try:
            monto = float(context.args[2])
            categoria = context.args[3].capitalize()
            if database.add_gasto_fijado(user_id, atajo, monto, categoria):
                await update.message.reply_text(f"✅ Atajo creado: `/f {atajo}` → ${monto:.2f} en {categoria}", parse_mode="Markdown")
            else:
                await update.message.reply_text("❌ Error creando atajo.")
        except:
            await update.message.reply_text("⚠️ Formato: `/f crear <atajo> <monto> <categoria>`", parse_mode="Markdown")
    
    elif action == "borrar" and len(context.args) >= 2:
        atajo = context.args[1]
        if database.delete_gasto_fijado(user_id, atajo):
            await update.message.reply_text(f"🗑️ Atajo `{atajo}` eliminado.", parse_mode="Markdown")
        else:
            await update.message.reply_text(f"❌ No encontré el atajo `{atajo}`.", parse_mode="Markdown")
    
    else:
        # Usar un atajo existente
        atajo = context.args[0]
        fijado = database.get_gasto_fijado(user_id, atajo)
        
        if not fijado:
            await update.message.reply_text(f"❌ Atajo `{atajo}` no existe. Usa `/f` para ver los disponibles.", parse_mode="Markdown")
            return
        
        # Registrar el gasto
        data = {
            "fecha": datetime.now().strftime("%Y-%m-%d"),
            "monto": fijado['monto'],
            "moneda": "USD",
            "concepto": fijado['concepto'],
            "categoria": fijado['categoria']
        }
        
        success, msg = sheets_manager.add_transaction(data, user_name, "", is_income=False)
        
        if success:
            database.get_or_create_user(user_id, user_name)
            streak_info = database.update_streak(user_id)
            
            # Verificar límite
            limite_check = database.check_limite_gasto(user_id)
            
            response = f"⚡ *${fijado['monto']:.2f}* en _{fijado['categoria']}_"
            if streak_info and streak_info['nuevo_dia']:
                response += f" | 🔥{streak_info['streak']}"
            
            if limite_check and limite_check['pct'] >= 80:
                response += f"\n\n⚠️ *ALERTA:* Llevas ${limite_check['spent_today']:.2f} hoy ({limite_check['pct']:.0f}% de tu límite)"
            
            await update.message.reply_text(response, parse_mode="Markdown")
        else:
            await update.message.reply_text(f"❌ Error: {msg}")

async def preguntar_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/preguntar - Asistente conversacional IA."""
    from gemini_analyzer import answer_financial_question
    
    if not context.args:
        await update.message.reply_text(
            "🤖 *Asistente Financiero*\n\n"
            "Pregúntame lo que quieras:\n"
            "• `/preguntar ¿Cuánto gasté en comida?`\n"
            "• `/preguntar ¿Cómo van mis ahorros?`\n"
            "• `/preguntar ¿Estoy gastando mucho?`",
            parse_mode="Markdown"
        )
        return
    
    question = " ".join(context.args)
    msg = await update.message.reply_text("🤔 Pensando...")
    
    try:
        summary = sheets_manager.get_monthly_summary()
        savings = sheets_manager.get_savings()
        
        answer = answer_financial_question(question, summary, savings)
        await msg.edit_text(f"🤖 {answer}", parse_mode="Markdown")
    except Exception as e:
        await msg.edit_text(f"❌ Error: {e}")

async def limite_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/limite - Configurar límite de gasto diario."""
    user_id = update.effective_user.id
    
    if not context.args:
        # Ver límite actual
        limite = database.get_limite_gasto(user_id)
        check = database.check_limite_gasto(user_id)
        
        if not limite or limite['limite_diario'] <= 0:
            await update.message.reply_text(
                "💰 *Límite de Gasto*\n\n"
                "No tienes límite configurado.\n"
                "Usa: `/limite 50` para establecer $50/día",
                parse_mode="Markdown"
            )
            return
        
        msg = f"💰 *Tu Límite Diario:* ${limite['limite_diario']:.2f}\n\n"
        if check:
            filled = int(check['pct'] / 10)
            bar = "█" * min(filled, 10) + "░" * max(0, 10 - filled)
            msg += f"Hoy: [{bar}] ${check['spent_today']:.2f} ({check['pct']:.0f}%)"
            if check['exceeded']:
                msg += "\n\n🚨 *¡LÍMITE EXCEDIDO!*"
        
        await update.message.reply_text(msg, parse_mode="Markdown")
        return
    
    try:
        limite = float(context.args[0])
        database.get_or_create_user(user_id, update.effective_user.first_name)
        if database.set_limite_gasto(user_id, limite_diario=limite):
            await update.message.reply_text(f"✅ Límite diario fijado en *${limite:.2f}*", parse_mode="Markdown")
        else:
            await update.message.reply_text("❌ Error guardando límite.")
    except:
        await update.message.reply_text("⚠️ Uso: `/limite 50`", parse_mode="Markdown")

async def email_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/email - Configurar email para reportes."""
    user_id = update.effective_user.id
    
    if not context.args:
        await update.message.reply_text(
            "📧 *Reportes por Email*\n\n"
            "Configura tu email para recibir resúmenes:\n"
            "• `/email tucorreo@gmail.com` (semanal)\n"
            "• `/email tucorreo@gmail.com mensual`",
            parse_mode="Markdown"
        )
        return
    
    email = context.args[0]
    frecuencia = context.args[1] if len(context.args) > 1 else "semanal"
    
    if "@" not in email:
        await update.message.reply_text("⚠️ Email inválido.")
        return
    
    if database.set_email_reporte(user_id, email, frecuencia):
        await update.message.reply_text(
            f"✅ Email configurado: *{email}*\n"
            f"📅 Frecuencia: *{frecuencia}*\n\n"
            "_Recibirás reportes automáticos._",
            parse_mode="Markdown"
        )
    else:
        await update.message.reply_text("❌ Error guardando email.")

async def tag_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/tag - Ver gastos por etiqueta."""
    if not context.args:
        await update.message.reply_text(
            "🏷️ *Etiquetas*\n\n"
            "Ver gastos por tag: `/tag viaje`\n\n"
            "Para añadir tags, incluye #hashtag en tu mensaje:\n"
            "_'Gasté 50 en hotel #viaje #trabajo'_",
            parse_mode="Markdown"
        )
        return
    
    tag = context.args[0].replace("#", "")
    gastos = database.get_gastos_by_tag(tag)
    
    if not gastos:
        await update.message.reply_text(f"🏷️ No hay gastos con el tag `#{tag}`", parse_mode="Markdown")
        return
    
    total = sum(g['monto_usd'] or 0 for g in gastos)
    msg = f"🏷️ *Gastos con #{tag}*\n\n"
    
    for g in gastos[:10]:
        msg += f"• {g['fecha']}: ${g['monto_usd']:.2f} - {g['concepto']}\n"
    
    msg += f"\n*Total:* ${total:.2f} ({len(gastos)} gastos)"
    await update.message.reply_text(msg, parse_mode="Markdown")

async def tendencias_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/tendencias - Análisis de tendencias con IA."""
    from gemini_analyzer import analyze_spending_trends
    
    msg = await update.message.reply_text("📊 Analizando tendencias...")
    
    try:
        summary = sheets_manager.get_monthly_summary()
        if not summary or not summary.get('daily_trend'):
            await msg.edit_text("❌ No hay suficientes datos para analizar tendencias.")
            return
        
        result = analyze_spending_trends(summary['daily_trend'])
        
        if not result.get('success'):
            await msg.edit_text("❌ Error analizando tendencias.")
            return
        
        data = result['data']
        response = "📈 *Análisis de Tendencias*\n\n"
        response += f"📊 Tendencia general: *{data.get('tendencia_general', 'N/A')}*\n"
        response += f"⬆️ Categoría que crece: *{data.get('categoria_creciente', 'N/A')}*\n"
        response += f"⬇️ Categoría que baja: *{data.get('categoria_decreciente', 'N/A')}*\n\n"
        response += f"🔍 *Patrón detectado:*\n_{data.get('patron_detectado', 'N/A')}_\n\n"
        response += f"💡 *Recomendación:*\n{data.get('recomendacion', 'N/A')}"
        
        await msg.edit_text(response, parse_mode="Markdown")
    except Exception as e:
        await msg.edit_text(f"❌ Error: {e}")

async def proyeccion_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/proyeccion - Proyección de ahorro."""
    from gemini_analyzer import generate_savings_projection
    
    savings = sheets_manager.get_savings()
    if not savings:
        await update.message.reply_text("💡 No tienes metas de ahorro. Crea una con `/ahorro Nombre Monto`.", parse_mode="Markdown")
        return
    
    msg = "💰 *Proyección de Ahorros*\n\n"
    
    for s in savings:
        try:
            current = float(s.get('Ahorrado Actual', 0))
            goal = float(s.get('Objetivo USD', 0))
            
            # Estimar tasa mensual (simplificado)
            monthly_rate = current / 3 if current > 0 else 0  # Asume 3 meses de actividad
            
            proj = generate_savings_projection(current, goal, monthly_rate)
            msg += f"🎯 *{s['Meta']}*\n"
            msg += f"   Actual: ${current:,.2f} / ${goal:,.2f}\n"
            msg += f"   📅 {proj['message']}\n\n"
        except:
            continue
    
    await update.message.reply_text(msg, parse_mode="Markdown")

async def csv_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/csv - Importar gastos desde archivo CSV."""
    if not update.message.document:
        await update.message.reply_text(
            "📥 *Importar CSV*\n\n"
            "Envía un archivo CSV con este formato:\n"
            "```\nfecha,monto,categoria,concepto\n2026-01-15,50.00,Comida,Almuerzo\n```\n\n"
            "Adjunta el archivo como documento respondiendo a este mensaje.",
            parse_mode="Markdown"
        )
        return
    
    try:
        doc = update.message.document
        if not doc.file_name.endswith('.csv'):
            await update.message.reply_text("⚠️ Solo acepto archivos .csv")
            return
        
        msg = await update.message.reply_text("📊 Procesando CSV...")
        
        file = await context.bot.get_file(doc.file_id)
        csv_bytes = await file.download_as_bytearray()
        content = csv_bytes.decode('utf-8')
        
        import csv
        from io import StringIO
        
        reader = csv.DictReader(StringIO(content))
        imported = 0
        errors = 0
        
        user_name = update.effective_user.first_name
        
        for row in reader:
            try:
                data = {
                    "fecha": row.get('fecha', datetime.now().strftime("%Y-%m-%d")),
                    "monto": float(row.get('monto', 0)),
                    "moneda": row.get('moneda', 'USD'),
                    "concepto": row.get('concepto', row.get('descripcion', '')),
                    "categoria": row.get('categoria', 'Otros')
                }
                
                success, _ = sheets_manager.add_transaction(data, user_name, "", is_income=False)
                if success:
                    imported += 1
                else:
                    errors += 1
            except:
                errors += 1
        
        await msg.edit_text(
            f"✅ *Importación Completada*\n\n"
            f"📊 Importados: *{imported}* gastos\n"
            f"❌ Errores: *{errors}*",
            parse_mode="Markdown"
        )
        
    except Exception as e:
        await update.message.reply_text(f"❌ Error procesando CSV: {e}")

async def anos_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/años - Comparar gastos por mes del año."""
    msg = await update.message.reply_text("📅 Generando comparativa anual...")
    
    try:
        now = datetime.now()
        data_by_month = {}
        
        # Obtener datos de los últimos 12 meses
        for i in range(12):
            month = now.month - i
            year = now.year
            if month <= 0:
                month += 12
                year -= 1
            
            try:
                summary = sheets_manager.get_monthly_summary(year, month)
                if summary:
                    key = f"{year}-{month:02d}"
                    data_by_month[key] = summary.get('total_usd', 0)
            except:
                continue
        
        if len(data_by_month) < 2:
            await msg.edit_text("❌ No hay suficientes datos para comparar (necesito al menos 2 meses).")
            return
        
        # Ordenar por fecha
        data_by_month = dict(sorted(data_by_month.items()))
        
        chart = visualizer.generate_yearly_comparison(data_by_month)
        
        if chart:
            total = sum(data_by_month.values())
            avg = total / len(data_by_month)
            
            caption = f"📅 *Comparativa Anual*\n\n"
            caption += f"📊 Total {len(data_by_month)} meses: *${total:,.2f}*\n"
            caption += f"📈 Promedio mensual: *${avg:,.2f}*"
            
            await update.message.reply_photo(photo=chart, caption=caption, parse_mode="Markdown")
            await msg.delete()
        else:
            await msg.edit_text("❌ No se pudo generar el gráfico.")
            
    except Exception as e:
        await msg.edit_text(f"❌ Error: {e}")

async def galeria_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/galeria - Ver recibos guardados en Drive."""
    msg = await update.message.reply_text("📸 Buscando recibos...")
    
    try:
        # Obtener lista de imágenes del mes desde Drive
        files = drive_manager.list_receipts()
        
        if not files:
            await msg.edit_text("📭 No hay recibos guardados este mes.")
            return
        
        response = "📸 *Galería de Recibos*\n\n"
        for i, f in enumerate(files[:20], 1):
            response += f"{i}. [{f['name']}]({f['webViewLink']})\n"
        
        response += f"\n_Total: {len(files)} recibos_"
        
        await msg.edit_text(response, parse_mode="Markdown", disable_web_page_preview=True)
        
    except Exception as e:
        await msg.edit_text(f"❌ Error: {e}")

async def duplicar_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """/duplicar - Repetir el último gasto registrado."""
    user_id = update.effective_user.id
    user_name = update.effective_user.first_name
    
    try:
        # Obtener último gasto del usuario desde SQLite
        gastos = database.get_gastos_mes()
        
        if not gastos:
            await update.message.reply_text("❌ No hay gastos que duplicar.")
            return
        
        # Encontrar el último gasto del usuario
        ultimo = None
        for g in gastos:
            if g.get('responsable', '').lower() == user_name.lower():
                ultimo = g
                break
        
        if not ultimo:
            ultimo = gastos[0]  # Si no encuentra del usuario, tomar el más reciente
        
        # Crear nuevo gasto con fecha de hoy
        data = {
            "fecha": datetime.now().strftime("%Y-%m-%d"),
            "monto": ultimo['monto_usd'],
            "moneda": "USD",
            "concepto": ultimo.get('concepto', ''),
            "categoria": ultimo.get('categoria', 'Otros')
        }
        
        keyboard = [
            [InlineKeyboardButton("✅ Confirmar", callback_data=f"dup_confirm_{ultimo['id']}")],
            [InlineKeyboardButton("❌ Cancelar", callback_data="dup_cancel")]
        ]
        
        await update.message.reply_text(
            f"🔁 *Duplicar Gasto*\n\n"
            f"💵 Monto: *${ultimo['monto_usd']:.2f}*\n"
            f"📝 Concepto: {ultimo.get('concepto', 'N/A')}\n"
            f"🏷️ Categoría: {ultimo.get('categoria', 'Otros')}\n\n"
            f"¿Registrar este gasto hoy?",
            parse_mode="Markdown",
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
        
    except Exception as e:
        await update.message.reply_text(f"❌ Error: {e}")

async def budget_reminder_job(context: ContextTypes.DEFAULT_TYPE):
    """Recordatorio de actualización de presupuesto los días 1, 15 y 30."""
    day = datetime.now().day
    
    # Solo ejecutar los días 1, 15 y 30
    if day not in [1, 15, 30]:
        return
    
    logger.info(f"Ejecutando recordatorio de presupuesto (día {day})...")
    
    try:
        # Mensaje según el día
        if day == 1:
            msg = "📅 *¡NUEVO MES!*\n\n"
            msg += "¿Ya actualizaste tus presupuestos para este mes?\n\n"
            msg += "📊 Usa `/presupuesto Categoría Monto` para configurar límites.\n"
            msg += "📝 Ejemplo: `/presupuesto Comida 500`"
        elif day == 15:
            msg = "📆 *MITAD DE MES*\n\n"
            msg += "¿Cómo van tus gastos? Revisa si estás dentro del presupuesto.\n\n"
            msg += "📊 Usa `/analisis` para ver tu progreso.\n"
            msg += "💰 Usa `/presupuesto` para ajustar si es necesario."
        else:  # day == 30
            msg = "🗓️ *FIN DE MES*\n\n"
            msg += "¡Últimos días! ¿Lograste tus objetivos?\n\n"
            msg += "📊 Usa `/reporte` para descargar el resumen del mes.\n"
            msg += "🎯 Usa `/ahorro` para revisar tus metas."
        
        # Enviar a todos los chats registrados
        chats = database.get_all_chats()
        for chat in chats:
            try:
                await context.bot.send_message(chat['chat_id'], msg, parse_mode="Markdown")
            except Exception as e:
                logger.warning(f"No se pudo enviar recordatorio a chat {chat['chat_id']}: {e}")
                
    except Exception as e:
        logger.error(f"Error en budget_reminder_job: {e}")

async def webapp_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Enviar botón para abrir Web App."""
    # NOTA: Para que esto funcione, necesitas hostear webapp/index.html en una URL pública
    # y configurarla en @BotFather -> Bot Settings -> Menu Button
    # Por ahora, enviamos instrucciones
    await update.message.reply_text(
        "📱 *Dashboard Web App*\n\n"
        "Para activar el dashboard visual:\n"
        "1. Sube tu bot a Coolify\n"
        "2. En @BotFather -> Bot Settings -> Menu Button\n"
        "3. Configura la URL: `https://tu-dominio.com/webapp/`\n\n"
        "Una vez configurado, verás un botón 📊 en el menú del chat que abrirá el dashboard.",
        parse_mode="Markdown"
    )

def main():
    print("🤖 Bot Financiero 360 Iniciado...")
    application = Application.builder().token(TELEGRAM_BOT_TOKEN).post_init(post_init).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("hoja", hoja_command))
    application.add_handler(CommandHandler("tasa", set_rate_command))
    application.add_handler(CommandHandler("analisis", analisis_command))
    application.add_handler(CommandHandler("resumen", summary_command))
    application.add_handler(CommandHandler("nueva", add_category_command))
    application.add_handler(CommandHandler("presupuesto", budget_command))
    application.add_handler(CommandHandler("ahorro", ahorro_command))
    application.add_handler(CommandHandler("hitos", hitos_command))
    application.add_handler(CommandHandler("hitos", hitos_command))
    application.add_handler(CommandHandler("deuda", deuda_command))
    application.add_handler(CommandHandler("pagado", pagado_command))
    application.add_handler(CommandHandler("recurrente", recurrente_command))
    application.add_handler(CommandHandler("reporte", reporte_command))
    application.add_handler(CommandHandler("consejo", consejo_command))
    application.add_handler(CommandHandler("webapp", webapp_command))
    application.add_handler(CommandHandler("comparar", comparar_command))
    # Gamificación
    application.add_handler(CommandHandler("g", gasto_rapido_command))
    application.add_handler(CommandHandler("score", score_command))
    application.add_handler(CommandHandler("logros", logros_command))
    application.add_handler(CommandHandler("ranking", ranking_command))
    application.add_handler(CommandHandler("silencio", silencio_command))
    application.add_handler(CommandHandler("reto", reto_command))
    # V7.0 - Productividad y Análisis
    application.add_handler(CommandHandler("f", fijado_command))
    application.add_handler(CommandHandler("preguntar", preguntar_command))
    application.add_handler(CommandHandler("limite", limite_command))
    application.add_handler(CommandHandler("email", email_command))
    application.add_handler(CommandHandler("tag", tag_command))
    application.add_handler(CommandHandler("tendencias", tendencias_command))
    application.add_handler(CommandHandler("proyeccion", proyeccion_command))
    # Pendientes V7.0
    application.add_handler(CommandHandler("csv", csv_command))
    application.add_handler(CommandHandler("anos", anos_command))
    application.add_handler(CommandHandler("galeria", galeria_command))
    application.add_handler(CommandHandler("duplicar", duplicar_command))
    # Mensajes y documentos
    application.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    application.add_handler(MessageHandler(filters.VOICE, handle_voice))
    application.add_handler(MessageHandler(filters.Document.ALL, csv_command))  # Para importar CSV
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text))
    application.add_handler(CallbackQueryHandler(handle_callback))
    application.run_polling()

if __name__ == "__main__":
    main()
