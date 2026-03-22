import requests
import json
import sys
import logging

# Configure logging to stdout
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s', stream=sys.stdout)
logger = logging.getLogger()

URL = "http://localhost:8056"
EMAIL = "admin@finanzas.local"
PASSWORD = "admin"
ORG_ID = "4fd243e5-8462-4e60-b2c5-c5c8bdce0457"

def log(msg):
    logger.info(msg)
    sys.stdout.flush()

def login():
    try:
        log(f"Logging in to {URL}...")
        response = requests.post(f"{URL}/auth/login", json={"email": EMAIL, "password": PASSWORD})
        log(f"Login Response: {response.status_code}")
        if response.status_code != 200:
             log(f"Login error: {response.text}")
             return None
        return response.json()['data']['access_token']
    except Exception as e:
        log(f"Login failed: {e}")
        return None

def main():
    token = login()
    if not token:
        log("No token. Exiting.")
        return

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # 1. Get Users
    log("Fetching users...")
    try:
        r_users = requests.get(f"{URL}/users", headers=headers, params={"limit": -1, "fields": "id,email"})
        if r_users.status_code != 200:
             log(f"Users fetch error: {r_users.text}")
             return
        users = r_users.json()['data']
        log(f"Found {len(users)} users.")
    except Exception as e:
        log(f"Error fetching users: {e}")
        return

    # 2. Get Workspaces
    log("Fetching workspaces...")
    try:
        r_ws = requests.get(f"{URL}/items/workspaces", headers=headers, params={"limit": -1, "fields": "id,user,name"})
        if r_ws.status_code != 200:
             log(f"Workspaces fetch error: {r_ws.text}")
             return
        workspaces = r_ws.json()['data']
        log(f"Found {len(workspaces)} workspaces.")
    except Exception as e:
        log(f"Error fetching workspaces: {e}")
        return

    # 3. Analyze
    users_with_ws = set()
    for ws in workspaces:
        u_val = ws.get('user')
        if isinstance(u_val, dict):
            users_with_ws.add(u_val.get('id'))
        elif u_val:
            users_with_ws.add(u_val)

    missing_ws_users = [u for u in users if u['id'] not in users_with_ws]
    
    log(f"Users without workspace: {len(missing_ws_users)}")

    # 4. Create missing
    for user in missing_ws_users:
        log(f"Creating workspace for {user['email']}...")
        payload = {
            "name": "Personal",
            "user": user['id'],
            "organization": ORG_ID,
            "type": "personal",
            "is_active": True,
            "ai_predictive_analysis": False,
            "ai_categorization": True,
            "currency": "USD"
        }
        try:
            r_create = requests.post(f"{URL}/items/workspaces", headers=headers, json=payload)
            if r_create.status_code in [200, 204]:
                log(f"SUCCESS: Workspace created for {user['email']}")
            else:
                log(f"FAILED: Could not create for {user['email']}. Status: {r_create.status_code}. Resp: {r_create.text}")
        except Exception as e:
            log(f"EXCEPTION: {e}")

if __name__ == "__main__":
    main()
