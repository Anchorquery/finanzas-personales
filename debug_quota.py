from googleapiclient.discovery import build
from google.oauth2.service_account import Credentials
from config import GOOGLE_CREDENTIALS_FILE

SCOPES = ['https://www.googleapis.com/auth/drive']

def check_quota():
    try:
        creds = Credentials.from_service_account_file(GOOGLE_CREDENTIALS_FILE, scopes=SCOPES)
        service = build('drive', 'v3', credentials=creds)
        
        about = service.about().get(fields="user, storageQuota").execute()
        
        user = about.get('user', {})
        quota = about.get('storageQuota', {})
        
        print(f"🤖 Usuario Bot (Service Account): {user.get('emailAddress')}")
        print("\n📦 Estado del Almacenamiento:")
        
        limit = int(quota.get('limit', 0))
        usage = int(quota.get('usage', 0))
        
        print(f"   - Límite Total: {limit / (1024**3):.2f} GB")
        print(f"   - Usado:        {usage / (1024**3):.2f} GB")
        
        if limit > 0:
            print(f"   - Libre:        {(limit - usage) / (1024**3):.2f} GB")
        else:
            print("   - ⚠️ Límite no definido o infinito (o 0 si error).")

    except Exception as e:
        print(f"❌ Error consultando cuota: {e}")

if __name__ == "__main__":
    check_quota()
