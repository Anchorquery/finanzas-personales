"""
Configuración del Bot de Gastos Familiares
"""
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Telegram
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

# Gemini
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# Google Sheets
GOOGLE_SHEET_ID = os.getenv("GOOGLE_SHEET_ID")
# Construir ruta absoluta al archivo de credenciales
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
GOOGLE_CREDENTIALS_FILE = os.path.join(BASE_DIR, os.getenv("GOOGLE_CREDENTIALS_FILE", "credentials.json"))

# Google Drive
GOOGLE_DRIVE_FOLDER_ID = os.getenv("GOOGLE_DRIVE_FOLDER_ID")


# Categorías de gastos disponibles
CATEGORIAS = [
    "🛒 Supermercado",
    "🍔 Comida/Restaurantes",
    "⛽ Gasolina/Transporte",
    "💊 Salud/Farmacia",
    "🏠 Hogar/Servicios",
    "👔 Ropa/Personal",
    "📱 Tecnología",
    "🎉 Entretenimiento",
    "⛪ Diezmos/Ofrendas",
    "📚 Educación",
    "🎁 Regalos",
    "💰 Otros"
]

# Mapeo de categorías cortas para callbacks
CATEGORIA_MAP = {
    "supermercado": "🛒 Supermercado",
    "comida": "🍔 Comida/Restaurantes",
    "transporte": "⛽ Gasolina/Transporte",
    "salud": "💊 Salud/Farmacia",
    "hogar": "🏠 Hogar/Servicios",
    "ropa": "👔 Ropa/Personal",
    "tech": "📱 Tecnología",
    "entretenimiento": "🎉 Entretenimiento",
    "diezmos": "⛪ Diezmos/Ofrendas",
    "educacion": "📚 Educación",
    "regalos": "🎁 Regalos",
    "otros": "💰 Otros"
}
