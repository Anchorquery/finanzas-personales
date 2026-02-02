import drive_manager
import sheets_manager
import google_auth
import logging
from config import GOOGLE_DRIVE_FOLDER_ID
from datetime import datetime

# Configurar logging para ver los detalles de la conexión
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def verify_system():
    print("🔍 Iniciando VERIFICACIÓN de Conexión Google...")
    
    try:
        # 1. Probar servicio de Drive
        print("\n1️⃣ Probando Google Drive...")
        service = drive_manager.get_drive_service()
        print("✅ Servicio Drive inicializado.")
        
        # 2. Listar archivos en la carpeta base
        print(f"\n2️⃣ Listando archivos en carpeta base ({GOOGLE_DRIVE_FOLDER_ID})...")
        results = service.files().list(
            q=f"'{GOOGLE_DRIVE_FOLDER_ID}' in parents and trashed = false",
            fields="files(id, name)"
        ).execute()
        files = results.get('files', [])
        
        if files:
            print(f"✅ Se encontraron {len(files)} archivos:")
            for f in files:
                print(f"   - {f['name']} ({f['id']})")
        else:
            print("⚠️ La carpeta está vacía o no tienes acceso.")
            
        # 3. Probar gspread (Google Sheets)
        print("\n3️⃣ Probando Google Sheets (gspread)...")
        creds = google_auth.get_credentials(scopes=sheets_manager.SCOPES)
        pk = creds.signer.key_id if hasattr(creds.signer, 'key_id') else "Desconocido"
        print(f"✅ Credenciales cargadas. Private Key ID: {pk}")
        
        # Diagnóstico de PEM
        raw_pk = creds._private_key if hasattr(creds, '_private_key') else None
        if raw_pk:
            print(f"📊 Diagnóstico PEM: {len(raw_pk)} caracteres, {raw_pk.count(chr(10))} saltos de línea.")
        
        # 4. Diagnóstico de Visibilidad (Listar todo en la carpeta)
        print(f"\n📂 Inspeccionando carpeta ID: {GOOGLE_DRIVE_FOLDER_ID}")
        print(f"   (Buscando qué archivos VE realmente el bot...)")
        try:
            drv_service = drive_manager.get_drive_service()
            results = drv_service.files().list(
                q=f"'{GOOGLE_DRIVE_FOLDER_ID}' in parents and trashed = false",
                fields="files(id, name, mimeType, owners)",
                pageSize=10,
                includeItemsFromAllDrives=True,
                supportsAllDrives=True
            ).execute()
            files = results.get('files', [])
            
            if not files:
                print("❌ La carpeta está VACÍA para el bot. Confirmar permisos/ID.")
                print("   Email del bot (para compartir): ", creds.service_account_email)
            else:
                print(f"✅ Se encontraron {len(files)} archivos en la carpeta:")
                for f in files:
                    owner_emails = [o.get('emailAddress') for o in f.get('owners', [])]
                    print(f"   📄 '{f['name']}'")
                    print(f"      ID: {f['id']}")
                    print(f"      Tipo: {f['mimeType']}")
                    print(f"      Dueños: {owner_emails}")
                    
        except Exception as e:
            print(f"❌ Error al listar archivos: {e}")

        client = sheets_manager.get_client()
        print("\n✅ Cliente de Sheets inicializado.")
        
        # 4. Intentar abrir la hoja del mes
        now = datetime.now()
        filename = f"Gastos_{now.year}_{now.month:02d}"
        print(f"\n4️⃣ Buscando hoja del mes: {filename}...")
        try:
            ss = sheets_manager.get_monthly_spreadsheet()
            print(f"✅ Hoja encontrada: {ss.title}")
            print(f"🔗 URL: {ss.url}")
        except Exception as e:
            print(f"⚠️ Error buscando/abriendo hoja: {e}")
            print("💡 Esto es normal si el archivo aún no existe en Drive.")

        print("\n✨ VERIFICACIÓN FINALIZADA ✨")
        
    except Exception as e:
        print(f"\n❌ ERROR CRÍTICO durante la verificación: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    verify_system()
