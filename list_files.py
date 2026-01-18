from drive_manager import get_drive_service
from config import GOOGLE_DRIVE_FOLDER_ID

def list_folder_contents():
    print(f"📂 Explorando carpeta: {GOOGLE_DRIVE_FOLDER_ID}")
    try:
        service = get_drive_service()
        # Listar TODO sin filtro de nombre
        results = service.files().list(
            q=f"'{GOOGLE_DRIVE_FOLDER_ID}' in parents and trashed=false",
            fields="files(id, name, mimeType)",
            includeItemsFromAllDrives=True,
            supportsAllDrives=True
        ).execute()
        
        files = results.get('files', [])
        
        if not files:
            print("⚠️ La carpeta parece vacía.")
        else:
            print(f"✅ Se encontraron {len(files)} archivos:")
            for f in files:
                print(f" - [Name]: '{f['name']}' | [ID]: {f['id']} | [Type]: {f['mimeType']}")
                
    except Exception as e:
        print(f"❌ Error listando archivos: {e}")

if __name__ == "__main__":
    list_folder_contents()
