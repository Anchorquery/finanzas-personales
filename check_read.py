from drive_manager import search_file_in_folder, get_drive_service
from config import GOOGLE_DRIVE_FOLDER_ID

def check_read_access():
    print(f"📂 Verificando acceso a carpeta: {GOOGLE_DRIVE_FOLDER_ID}")
    try:
        service = get_drive_service()
        # Intentar listar archivos en la carpeta
        results = service.files().list(
            q=f"'{GOOGLE_DRIVE_FOLDER_ID}' in parents",
            pageSize=5,
            fields="files(id, name, owners)",
            supportsAllDrives=True,
            includeItemsFromAllDrives=True
        ).execute()
        
        files = results.get('files', [])
        print(f"✅ Acceso de LECTURA confirmado. Se encontraron {len(files)} archivos:")
        for f in files:
            print(f" - {f['name']} (Owner: {f.get('owners', [{}])[0].get('emailAddress', 'Unknown')})")
            
    except Exception as e:
        print(f"❌ Error de LECTURA: {e}")

if __name__ == "__main__":
    check_read_access()
