@echo off
echo Granting permissions to Role "Finanzas App User" (ad2e4239-1849-481b-a224-eab79d0f8481)...

REM Grant create permission on directus_users for Public (optional, but needed for registration if not using custom endpoint)
REM Actually, we are using the public role to CREATE users, but assigning them a specific role.
REM The "Public" role ID is implied (null) or we need to find it. Public role usually has no ID in DB (it's built-in) or is a specific row.
REM LIMITATION: We can't easy change Public permissions via SQL without knowing Public Role ID. 
REM However, we can grant permissions to the NEW role (Finanzas App User) so they can use the app after login.

set ROLE_ID=ad2e4239-1849-481b-a224-eab79d0f8481

echo Granting App access to user...
docker exec -i finanzas_db psql -U directus -d directus -c "INSERT INTO directus_permissions (role, collection, action, permissions) VALUES ('%ROLE_ID%', 'transactions', 'read', '{}');"
docker exec -i finanzas_db psql -U directus -d directus -c "INSERT INTO directus_permissions (role, collection, action, permissions) VALUES ('%ROLE_ID%', 'transactions', 'create', '{\"user_created\": {\"_eq\": \"$CURRENT_USER\"}}');"
docker exec -i finanzas_db psql -U directus -d directus -c "INSERT INTO directus_permissions (role, collection, action, permissions) VALUES ('%ROLE_ID%', 'transactions', 'update', '{\"user_created\": {\"_eq\": \"$CURRENT_USER\"}}');"
docker exec -i finanzas_db psql -U directus -d directus -c "INSERT INTO directus_permissions (role, collection, action, permissions) VALUES ('%ROLE_ID%', 'transactions', 'delete', '{\"user_created\": {\"_eq\": \"$CURRENT_USER\"}}');"

echo Permissions granted (Basic transactions CRUD).
