import os
import json
import logging
from google.oauth2.service_account import Credentials

logger = logging.getLogger(__name__)

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
            # Corregir claves privadas malformadas (literal \n)
            if "private_key" in info:
                info["private_key"] = info["private_key"].replace("\\n", "\n")
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
                # El "Invalid JWT Signature" suele ser por escapes incorrectos
                # En Coolify, a veces el archivo guardado tiene doble escape: \\n o incluso \\\\n
                pk = info["private_key"]
                
                # 1. Reemplazar "\\n" (4 chars) o "\\n" (2 chars) por saltos de línea reales
                pk_clean = pk.replace("\\\\n", "\n").replace("\\n", "\n")
                
                # 2. Asegurarse de que no queden escapes residuales y que el formato sea correcto
                info["private_key"] = pk_clean
                
                if pk != pk_clean:
                    logger.info("DEBUG: Se corrigió el formato de la clave privada (doble escape detectado).")
                else:
                    logger.info("DEBUG: No se detectaron secuencias de escape literales en la clave privada.")
            
            return Credentials.from_service_account_info(info, scopes=scopes)
        except Exception as e:
            logger.error(f"DEBUG: Error cargando archivo de credenciales: {e}")
            raise e
    else:
        error_msg = f"❌ Archivo de credenciales no encontrado: {GOOGLE_CREDENTIALS_FILE}"
        logger.error(error_msg)
        raise FileNotFoundError(error_msg)
