"""
Servicio para obtener tasas de cambio de ve.dolarapi.com
"""
import requests
import logging

logger = logging.getLogger(__name__)

API_URL = "https://ve.dolarapi.com/v1/dolares"

def get_current_rates() -> dict:
    """
    Obtiene las tasas actuales (Oficial y Paralelo).
    Retorna un dict con ambas tasas y la fecha de actualización.
    """
    try:
        response = requests.get(API_URL, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        rates = {
            "oficial": 0.0,
            "paralelo": 0.0,
            "last_update": ""
        }
        
        # La API retorna una lista de monitores.
        # Buscamos "BCV" (oficial) y "Paralelo" (promedio o específico)
        
        for tasa in data:
            name = tasa.get("fuente", "").lower()
            if name == "oficial":
                rates["oficial"] = tasa.get("promedio", 0.0)
                rates["last_update"] = tasa.get("fechaActualizacion", "")
            elif name == "paralelo": # Promedio paralelo
                rates["paralelo"] = tasa.get("promedio", 0.0)
                
        return rates
        
    except Exception as e:
        logger.error(f"Error consultando DolarAPI: {e}")
        return None
