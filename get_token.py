import os
import sys

# Add the project root to sys.path
sys.path.append(os.path.abspath(r'C:\Users\Pruebas\Desktop\apps\telegram-bots\finanzas-personales'))

try:
    from config import DIRECTUS_TOKEN, DIRECTUS_URL
    print(f"TOKEN:{DIRECTUS_TOKEN}")
    print(f"URL:{DIRECTUS_URL}")
except Exception as e:
    print(f"Error: {e}")
