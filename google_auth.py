import os
import json
import logging
from google.oauth2.service_account import Credentials

logger = logging.getLogger(__name__)

def nuclear_clean_pem(pk: str) -> str:
    """
    Limpia de forma agresiva la clave privada para asegurar un formato PEM válido.
    Elimina dobles escapes, espacios extra y reconstruye las cabeceras.
    """
    if not pk:
        return pk
        
    # 1. Corregir escapes literales comunes (Coolify/Docker issues)
    pk_clean = pk.replace("\\\\n", "\n").replace("\\n", "\n")
    
    # 2. Reconstrucción Nuclear
    try:
        header = "-----BEGIN PRIVATE KEY-----"
        footer = "-----END PRIVATE KEY-----"
        
        if header in pk_clean and footer in pk_clean:
            # Extraer solo el bloque base64 entre cabeceras
            core = pk_clean.split(header)[1].split(footer)[0]
            # Eliminar ABSOLUTAMENTE TODO espacio en blanco, salto de línea o basura
            core_clean = "".join(core.split())
            # Reensamblar con formato estándar perfecto
            return f"{header}\n{core_clean}\n{footer}\n"
    except Exception as e:
        logger.error(f"DEBUG: Error en nuclear_clean_pem: {e}")
        
    return pk_clean

def get_credentials(scopes):
    """
    Obtiene las credenciales de Google desde un archivo o variable de entorno.
    Incluye correcciones para errores comunes de formato en la clave privada.
    """
    # 1. Intentar obtener desde variable de entorno (JSON completo)
    creds_json = os.getenv("GOOGLE_CREDENTIALS_JSON")
    
    if creds_json:
        try:
            logger.info("DEBUG: Usando credenciales desde GOOGLE_CREDENTIALS_JSON")
            info = json.loads(creds_json)
            if "private_key" in info:
                info["private_key"] = nuclear_clean_pem(info["private_key"])
            return Credentials.from_service_account_info(info, scopes=scopes)
        except Exception as e:
            logger.error(f"DEBUG: Error cargando GOOGLE_CREDENTIALS_JSON: {e}")
    
    # 2. Intentar obtener desde archivo
    from config import GOOGLE_CREDENTIALS_FILE
    abs_path = os.path.abspath(GOOGLE_CREDENTIALS_FILE)
    logger.info(f"DEBUG: Intentando cargar credenciales desde: {abs_path}")
    
    if os.path.exists(abs_path):
        try:
            logger.info(f"DEBUG: Archivo encontrado. Cargando...")
            with open(abs_path, 'r') as f:
                content = f.read()
                logger.info(f"DEBUG: Contenido del archivo (primeros 50 caracteres): {content[:50]}...")
                info = json.loads(content)
            
            if "private_key" in info:
                orig_pk = info["private_key"]
                info["private_key"] = nuclear_clean_pem(orig_pk)
                
                if orig_pk != info["private_key"]:
                    logger.info("DEBUG: Se detectaron y corrigieron discrepancias en el formato de la clave.")
                else:
                    logger.info("DEBUG: El formato de la clave ya era perfecto.")
            
            return Credentials.from_service_account_info(info, scopes=scopes)
        except Exception as e:
            logger.error(f"DEBUG: Error cargando archivo de credenciales: {e}")
            raise e
    else:
        error_msg = f"❌ Archivo de credenciales no encontrado: {GOOGLE_CREDENTIALS_FILE}"
        logger.error(error_msg)
        raise FileNotFoundError(error_msg)
