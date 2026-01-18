import gspread
from google.oauth2.service_account import Credentials
import os
from dotenv import load_dotenv

load_dotenv()

SCOPES = ['https://www.googleapis.com/auth/spreadsheets', 'https://www.googleapis.com/auth/drive']
CREDS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "credentials.json")

def check_connection():
    try:
        if not os.path.exists(CREDS_FILE):
            print(f"❌ Archivo credentials.json no encontrado en: {CREDS_FILE}")
            return

        creds = Credentials.from_service_account_file(CREDS_FILE, scopes=SCOPES)
        client = gspread.authorize(creds)
        
        print(f"✅ Autenticado como: {creds.service_account_email}")
        
        sheet_id = os.getenv("GOOGLE_SHEET_ID")
        if not sheet_id:
            print("❌ GOOGLE_SHEET_ID está vacío en .env")
            print("🔍 Buscando hojas compartidas con este bot...")
            # Listar spreadsheets disponibles (limitado)
            # Nota: list_spreadsheet_files() devuelve archivos de Drive
            # Pero requiere uso de drive api o gspread client specific methods if available.
            # gspread openall() might work
            try:
                sheets = client.openall()
                if sheets:
                    print(f"📄 Hojas encontradas ({len(sheets)}):")
                    for s in sheets:
                        print(f" - {s.title} (ID: {s.id})")
                else:
                    print("⚠️ No encontré ninguna hoja compartida con el bot.")
            except Exception as e:
                print(f"Error listando hojas: {e}")
            
        else:
            print(f"🔹 Intentando conectar a ID: {sheet_id}")
            try:
                sh = client.open_by_key(sheet_id)
                print(f"✅ Conectado exitosamente a: {sh.title}")
            except Exception as e:
                print(f"❌ Error conectando a la hoja: {e}")

    except Exception as e:
        print(f"❌ Error General: {e}")

if __name__ == "__main__":
    check_connection()
