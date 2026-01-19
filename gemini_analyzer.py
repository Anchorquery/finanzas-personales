"""
Analizador de imágenes de comprobantes bancarios usando Google Gemini
"""
import google.generativeai as genai
import json
import re
from config import GEMINI_API_KEY

# Configurar Gemini
genai.configure(api_key=GEMINI_API_KEY)

# Prompt para extracción de datos
EXTRACTION_PROMPT = """Analiza esta imagen de un comprobante bancario venezolano y extrae la información.

Debes identificar el tipo de comprobante (Pago Móvil, Transferencia, Débito, Depósito, etc.) y extraer todos los datos disponibles.

Responde ÚNICAMENTE con un JSON válido con esta estructura (usa null para campos no disponibles):

{
    "tipo": "Pago Móvil | Transferencia | Débito | Depósito | Otro",
    "monto": 12345.67,
    "moneda": "Bs",
    "fecha": "2026-01-15",
    "hora": "14:30",
    "referencia": "123456789",
    "banco_origen": "Nombre del banco",
    "banco_destino": "Nombre del banco destino",
    "cuenta_origen": "****1234",
    "beneficiario": "Teléfono o nombre",
    "documento": "V-12345678 o J-12345678",
    "concepto": "Descripción si existe",
    "categoria_sugerida": "supermercado | comida | transporte | salud | hogar | ropa | tech | entretenimiento | diezmos | educacion | regalos | otros"
}

IMPORTANTE:
- El monto debe ser un número decimal (sin puntos de miles, usa punto como decimal)
- La fecha debe estar en formato YYYY-MM-DD
- Para categoria_sugerida, infiere basándote en el concepto, beneficiario o tipo de operación
- Si ves "Diezmos" en el concepto, la categoría es "diezmos"
- Si no puedes determinar algo, usa null
"""




def process_gemini_response(response) -> dict:
    """Procesa la respuesta raw de Gemini a JSON."""
    try:
        response_text = response.text.strip()
        
        # Limpiar respuesta (a veces viene con ```json ... ```)
        if response_text.startswith("```"):
            response_text = re.sub(r'^```\w*\n?', '', response_text)
            response_text = re.sub(r'\n?```$', '', response_text)
        
        # Parsear JSON
        data = json.loads(response_text)
        
        return {
            "success": True,
            "data": data
        }
    except json.JSONDecodeError as e:
        return {
            "success": False,
            "error": f"Error al parsear respuesta: {str(e)}"
        }




def analyze_text(text: str) -> dict:
    """
    Analiza texto natural de un gasto y extrae los datos.
    """
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        prompt = f"""{EXTRACTION_PROMPT}

Aquí está el texto del reporte de gasto:
"{text}"
"""
        response = model.generate_content(prompt)
        return process_gemini_response(response)
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error al analizar texto: {str(e)}"
        }  




def analyze_receipt(image_bytes: bytes, caption: str = None) -> dict:
    """
    Analiza una imagen de comprobante bancario y extrae los datos.
    Soporta un caption opcional para ayudar a la IA.
    """
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        prompt = EXTRACTION_PROMPT
        if caption:
            prompt += f"\n\nContexto adicional (Caption del usuario): \"{caption}\""

        image_part = {
            "mime_type": "image/jpeg",
            "data": image_bytes
        }
        
        response = model.generate_content([prompt, image_part])
        return process_gemini_response(response)
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error al analizar imagen: {str(e)}"
        }

def analyze_voice(audio_bytes: bytes) -> dict:
    """
    Analiza una nota de voz y extrae datos de gasto/ingreso.
    Gemini 2.0 soporta audio nativo.
    """
    try:
        model = genai.GenerativeModel('gemini-2.0-flash-exp')
        
        prompt = """Escucha este audio donde alguien describe un gasto o ingreso.
Extrae la información y responde SOLO con JSON:

{
    "tipo": "Gasto | Ingreso",
    "monto": 12345.67,
    "moneda": "Bs | USD",
    "concepto": "descripción del gasto",
    "categoria_sugerida": "comida | transporte | salud | hogar | otros",
    "fecha": "YYYY-MM-DD" (usa la fecha de hoy si no se menciona)
}

Si no puedes entender el audio o no hay datos financieros, responde:
{"success": false, "error": "No se detectó información de gasto"}
"""
        
        audio_part = {
            "mime_type": "audio/ogg",
            "data": audio_bytes
        }
        
        response = model.generate_content([prompt, audio_part])
        result = process_gemini_response(response)
        
        # Si viene de voz, marcar como tal
        if result.get("success"):
            result["data"]["source"] = "voice"
        
        return result
        
    except Exception as e:
        return {
            "success": False,
            "error": f"Error al analizar audio: {str(e)}"
        }


def format_receipt_message(data: dict) -> str:
    """
    Formatea los datos del comprobante para mostrar en Telegram.
    
    Args:
        data: Diccionario con los datos extraídos
        
    Returns:
        Mensaje formateado
    """
    msg_parts = ["📋 *Datos del Comprobante*\n"]
    
    if data.get("tipo"):
        msg_parts.append(f"📌 *Tipo:* {data['tipo']}")
    
    if data.get("monto"):
        monto = data['monto']
        moneda = data.get('moneda', 'Bs')
        # Formatear monto con separador de miles
        monto_fmt = f"{monto:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
        msg_parts.append(f"💵 *Monto:* {monto_fmt} {moneda}")
    
    if data.get("fecha"):
        fecha = data['fecha']
        hora = data.get('hora', '')
        if hora:
            msg_parts.append(f"📅 *Fecha:* {fecha} {hora}")
        else:
            msg_parts.append(f"📅 *Fecha:* {fecha}")
    
    if data.get("banco_origen"):
        msg_parts.append(f"🏦 *Banco Origen:* {data['banco_origen']}")
    
    if data.get("banco_destino"):
        msg_parts.append(f"🏦 *Banco Destino:* {data['banco_destino']}")
    
    if data.get("referencia"):
        msg_parts.append(f"🔢 *Referencia:* `{data['referencia']}`")
    
    if data.get("beneficiario"):
        msg_parts.append(f"👤 *Beneficiario:* {data['beneficiario']}")
    
    if data.get("concepto"):
        msg_parts.append(f"📝 *Concepto:* {data['concepto']}")
    
    if data.get("categoria_sugerida"):
        from config import CATEGORIA_MAP
        cat = CATEGORIA_MAP.get(data['categoria_sugerida'], data['categoria_sugerida'])
        msg_parts.append(f"\n🏷️ *Categoría sugerida:* {cat}")
    
    return "\n".join(msg_parts)

def get_financial_advice(summary_data: dict) -> str:
    """
    Usa Gemini para dar 3 consejos de ahorro basados en el resumen.
    """
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        prompt = f"""
        Actúa como un Coach Financiero experto. 
        Analiza los siguientes gastos mensuales de una familia y da 3 consejos (TIPS) CONCRETOS y accionables para ahorrar el próximo mes.
        
        DATOS DEL MES:
        - Total Gastado: ${summary_data['total_usd']:.2f}
        - Total Ingresos: ${summary_data.get('total_ingresos', 0):.2f}
        - Gastos por Categoría: {summary_data['by_category']}
        
        SÉ BREVE. Usa emojis. Cada consejo debe ser una frase corta.
        No des introducciones ni conclusiones. Solo los 3 consejos.
        """
        
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        return "💡 Sigue registrando tus gastos para recibir consejos personalizados pronto."

def answer_financial_question(question: str, summary_data: dict, savings_data: list = None) -> str:
    """
    Asistente conversacional IA: responde preguntas naturales sobre finanzas.
    Ej: "¿Cuánto gasté en comida este mes?"
    """
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        context = f"""
Datos financieros del usuario este mes:
- Total gastado: ${summary_data.get('total_usd', 0):.2f}
- Total ingresos: ${summary_data.get('total_ingresos', 0):.2f}
- Balance: ${summary_data.get('total_ingresos', 0) - summary_data.get('total_usd', 0):.2f}
- Gastos por categoría: {summary_data.get('by_category', {})}
- Número de transacciones: {summary_data.get('count', 0)}
"""
        if savings_data:
            context += f"\nMetas de ahorro: {savings_data}"
        
        prompt = f"""Eres un asistente financiero amigable. Responde la pregunta del usuario basándote en sus datos.
Sé CONCISO y DIRECTO. Usa emojis. Responde en español.
Si la pregunta no tiene que ver con finanzas, di que solo puedes ayudar con temas financieros.

{context}

PREGUNTA DEL USUARIO: "{question}"

Responde en 2-3 oraciones máximo.
"""
        
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        return f"❌ Error al procesar tu pregunta: {str(e)}"

def analyze_spending_trends(data: list) -> dict:
    """
    Analiza tendencias en los gastos y detecta patrones.
    """
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        prompt = f"""Analiza estos gastos y detecta tendencias importantes.
Responde en JSON:
{{
    "tendencia_general": "subiendo | bajando | estable",
    "categoria_creciente": "categoria que más creció",
    "categoria_decreciente": "categoria que menos se gasta",
    "patron_detectado": "descripción breve del patrón más notable",
    "recomendacion": "una recomendación corta"
}}

DATOS: {data[:30]}
"""
        
        response = model.generate_content(prompt)
        return process_gemini_response(response)
    except Exception as e:
        return {"success": False, "error": str(e)}

def generate_savings_projection(current_saved: float, goal: float, monthly_rate: float) -> dict:
    """
    Calcula proyección de ahorro.
    """
    if monthly_rate <= 0:
        return {"months_remaining": None, "message": "Necesitas comenzar a ahorrar para proyectar."}
    
    remaining = goal - current_saved
    if remaining <= 0:
        return {"months_remaining": 0, "message": "¡Ya alcanzaste tu meta! 🎉"}
    
    months = remaining / monthly_rate
    
    return {
        "months_remaining": round(months, 1),
        "message": f"A este ritmo (${monthly_rate:.2f}/mes), alcanzarás tu meta en {months:.1f} meses.",
        "projected_date": None  # Se puede calcular con datetime
    }
