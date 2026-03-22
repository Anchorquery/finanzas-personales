import requests
import json
import sys

url = "http://localhost:8056"
login_data = {
    "email": "admin@finanzas.local",
    "password": "admin"
}

output = []

def log(msg):
    output.append(msg)
    print(msg)

log(f"Connecting to {url}...")
try:
    # 1. Login
    response = requests.post(f"{url}/auth/login", json=login_data)
    log(f"Login Status: {response.status_code}")
    
    if response.status_code != 200:
        log(f"Login Error: {response.text}")
        sys.exit(1)

    token = response.json()["data"]["access_token"]
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # 2. Get Users
    # limit=-1 fetches all (check directus version, sometimes -1 or 20000)
    users_response = requests.get(f"{url}/users", headers=headers, params={"limit": "-1", "status": "active"})
    log(f"Users Status: {users_response.status_code}")
    
    if users_response.status_code != 200:
        log(f"Users Error: {users_response.text}")
        sys.exit(1)

    users = users_response.json()["data"]
    log(f"Found {len(users)} active users.")

    # 3. Get Workspaces
    # Using /items/workspaces endpoint
    workspaces_response = requests.get(f"{url}/items/workspaces", headers=headers, params={"limit": "-1"})
    log(f"Workspaces Status: {workspaces_response.status_code}")
    
    if workspaces_response.status_code != 200:
        log(f"Workspaces Error: {workspaces_response.text}")
        # Proceed assuming empty or retry? Better to stop to avoid duplicate creation if fetch failed
        sys.exit(1)

    workspaces = workspaces_response.json()["data"]
    log(f"Found {len(workspaces)} workspaces.")

    # Map user_id -> list of workspaces
    user_workspaces = {}
    for w in workspaces:
        # directus stores user as ID (string) or object depending on query. default is ID.
        u_id = w.get("user")
        if isinstance(u_id, dict):
             u_id = u_id.get("id")
        
        if u_id:
            if u_id not in user_workspaces:
                user_workspaces[u_id] = []
            user_workspaces[u_id].append(w)

    # 4. Check and Create
    for user in users:
        user_id = user["id"]
        user_email = user["email"]
        
        # Skip if user already has a workspace
        if user_id in user_workspaces and len(user_workspaces[user_id]) > 0:
            log(f"User {user_email} already has {len(user_workspaces[user_id])} workspace(s). Skipping.")
            continue

        log(f"User {user_email} ({user_id}) has NO workspace. Creating...")
        
        # Create Workspace
        new_workspace = {
            "name": "Espacio Personal",
            "type": "personal",
            "description": "Espacio creado automáticamente por migración",
            "is_active": True,
            "user": user_id,
            "currency": "USD",
             # "color_value": 0xFF2B4BEE, # Optional
        }
        
        create_res = requests.post(f"{url}/items/workspaces", headers=headers, json=new_workspace)
        if create_res.status_code in [200, 204]:
            log(f"SUCCESS: Created workspace for {user_email}")
        else:
            log(f"ERROR: Failed to create workspace for {user_email}: {create_res.text}")

except Exception as e:
    log(f"Exception: {e}")

with open("users_discovery.txt", "w") as f:
    f.write("\n".join(output))
