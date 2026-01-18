from drive_manager import search_file_in_folder, get_drive_service
from config import GOOGLE_DRIVE_FOLDER_ID
from datetime import datetime

def debug_search():
    target_name = f"Gastos_{datetime.now().year}_{datetime.now().month:02d}"
    print(f"🔎 Investigando archivo: '{target_name}' en carpeta '{GOOGLE_DRIVE_FOLDER_ID}'")
    
    # Pruba 1: Función Oficial
    print("\n[1] Probando search_file_in_folder()...")
    found_id = search_file_in_folder(GOOGLE_DRIVE_FOLDER_ID, target_name, "application/vnd.google-apps.spreadsheet")
    print(f"👉 Resultado ID: {found_id}")
    
    if found_id:
        print("✅ ¡Encontrado oficialmente!")
        return

    # Prueba 2: Listado y comparación manual
    print("\n[2] Búsqueda manual (Listando todo y comparando strings)...")
    service = get_drive_service()
    results = service.files().list(
        q=f"'{GOOGLE_DRIVE_FOLDER_ID}' in parents and trashed=false",
        fields="files(id, name, mimeType)",
        includeItemsFromAllDrives=True,
        supportsAllDrives=True
    ).execute()
    
    files = results.get('files', [])
    for f in files:
        name_in_drive = f['name']
        print(f"   - Comparando con: '{name_in_drive}' (ID: {f['id']})")
        
        if name_in_drive == target_name:
            print(f"   ✅ ¡MATCH EXACTO de strings! Pero la query filtrada falló.")
        elif name_in_drive.strip() == target_name.strip():
            print(f"   ⚠️ Match con strip() -> Posibles espacios invisibles. Drive: '{repr(name_in_drive)}'")
        else:
            print("     (No match)")

if __name__ == "__main__":
    debug_search()
