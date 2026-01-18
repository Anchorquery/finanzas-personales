"""
Gestor de Google Drive para subir y organizar comprobantes
"""
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseUpload
from google.oauth2.service_account import Credentials
import io
from datetime import datetime
from config import GOOGLE_DRIVE_FOLDER_ID, GOOGLE_CREDENTIALS_FILE

# Scopes necesarios (ya incluidos en sheets_manager, pero explícitos aquí)
SCOPES = ['https://www.googleapis.com/auth/drive']

_drive_service = None

def get_drive_service():
    """Obtiene el servicio de Drive autenticado."""
    global _drive_service
    if _drive_service is None:
        creds = Credentials.from_service_account_file(
            GOOGLE_CREDENTIALS_FILE,
            scopes=SCOPES
        )
        _drive_service = build('drive', 'v3', credentials=creds)
    return _drive_service


def find_folder(service, name: str, parent_id: str) -> str:
    """Busca una carpeta por nombre dentro de otra."""
    query = f"mimeType='application/vnd.google-apps.folder' and name='{name}' and '{parent_id}' in parents and trashed=false"
    results = service.files().list(q=query, fields="files(id, name)").execute()
    files = results.get('files', [])
    if files:
        return files[0]['id']
    return None


def create_folder(service, name: str, parent_id: str) -> str:
    """Crea una carpeta dentro de otra."""
    file_metadata = {
        'name': name,
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': [parent_id]
    }
    file = service.files().create(body=file_metadata, fields='id').execute()
    return file.get('id')


def get_target_folder(date_obj: datetime) -> str:
    """
    Obtiene (o crea) la estructura de carpetas Año/Mes.
    Retorna el ID de la carpeta del mes donde se debe guardar.
    """
    service = get_drive_service()
    
    # Carpeta Año
    year_str = str(date_obj.year)
    year_folder_id = find_folder(service, year_str, GOOGLE_DRIVE_FOLDER_ID)
    if not year_folder_id:
        year_folder_id = create_folder(service, year_str, GOOGLE_DRIVE_FOLDER_ID)
        
    # Carpeta Mes (01_Enero, 02_Febrero...)
    meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    month_str = f"{date_obj.month:02d}_{meses[date_obj.month - 1]}"
    
    month_folder_id = find_folder(service, month_str, year_folder_id)
    if not month_folder_id:
        month_folder_id = create_folder(service, month_str, year_folder_id)
        
    return month_folder_id


def upload_receipt(image_bytes: bytes, filename: str, date_str: str = None) -> str:
    """
    Sube la imagen a Drive en la carpeta correspondiente.
    
    Args:
        image_bytes: Contenido de la imagen
        filename: Nombre base del archivo
        date_str: Fecha del gasto (YYYY-MM-DD) para organizar
        
    Returns:
        Link visualizable del archivo (webViewLink)
    """
    try:
        service = get_drive_service()
        
        # Determinar fecha para la carpeta
        if date_str:
            try:
                date_obj = datetime.strptime(date_str, "%Y-%m-%d")
            except:
                date_obj = datetime.now()
        else:
            date_obj = datetime.now()
            
        target_folder_id = get_target_folder(date_obj)
        
        # Preparar archivo
        file_metadata = {
            'name': filename,
            'parents': [target_folder_id]
        }
        
        media = MediaIoBaseUpload(
            io.BytesIO(image_bytes),
            mimetype='image/jpeg',
            resumable=True
        )
        
        file = service.files().create(
            body=file_metadata,
            media_body=media,
            fields='id, webViewLink, webContentLink'
        ).execute()
        
        return file.get('webViewLink')
        
    except Exception as e:
        print(f"Error al subir a Drive: {e}")
        return None

def search_file_in_folder(folder_id: str, filename: str, mime_type: str = None) -> str:
    """
    Busca un archivo por nombre exacto dentro de una carpeta.
    Retorna el ID del archivo o None.
    """
    try:
        query = f"'{folder_id}' in parents and name = '{filename}' and trashed = false"
        if mime_type:
            query += f" and mimeType = '{mime_type}'"
            
        service = get_drive_service()
        results = service.files().list(
            q=query,
            fields="files(id, name)",
            includeItemsFromAllDrives=True,
            supportsAllDrives=True
        ).execute()
        
        files = results.get('files', [])
        if files:
            return files[0]['id']
        return None
    except Exception as e:
        print(f"Error buscando archivo en Drive: {e}")
        return None

def copy_file(file_id: str, new_name: str, parent_folder_id: str) -> str:
    """
    Copia un archivo existente y lo coloca en una carpeta.
    Retorna el ID del nuevo archivo.
    """
    try:
        service = get_drive_service()
        file_metadata = {
            'name': new_name,
            'parents': [parent_folder_id]
        }
        file = service.files().copy(
            fileId=file_id,
            body=file_metadata,
            supportsAllDrives=True
        ).execute()
        return file.get('id')
    except Exception as e:
        print(f"Error copiando archivo en Drive: {e}")
        return None

def create_spreadsheet(name: str, folder_id: str) -> str:
    """
    Crea una nueva hoja de cálculo vacía en la carpeta especificada.
    Retorna el ID del archivo.
    """
    try:
        service = get_drive_service()
        file_metadata = {
            'name': name,
            'parents': [folder_id],
            'mimeType': 'application/vnd.google-apps.spreadsheet'
        }
        file = service.files().create(
            body=file_metadata,
            fields='id',
            supportsAllDrives=True
        ).execute()
        return file.get('id')
    except Exception as e:
        print(f"Error creando Spreadsheet: {e}")
        return None


