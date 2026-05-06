-- Update the permissions for 'ad2e4239-1849-481b-a224-eab79d0f8481' on "workspaces"

-- DELETE existing read/update to avoid duplicates
DELETE FROM directus_permissions 
WHERE collection = 'workspaces' 
  AND role = 'ad2e4239-1849-481b-a224-eab79d0f8481' 
  AND action IN ('read', 'update');

-- 1) READ permission
INSERT INTO directus_permissions (role, collection, action, permissions) VALUES (
  'ad2e4239-1849-481b-a224-eab79d0f8481', 
  'workspaces', 
  'read', 
  '{
    "_or": [
      {
        "user": {
          "_eq": "$CURRENT_USER"
        }
      },
      {
        "_and": [
          {
            "access_scope": {
              "_eq": "organization"
            }
          },
          {
            "organization": {
              "members": {
                "user": {
                  "_eq": "$CURRENT_USER"
                }
              }
            }
          }
        ]
      },
      {
        "_and": [
          {
            "access_scope": {
              "_eq": "restricted"
            }
          },
          {
            "access_member_ids": {
              "_contains": "$CURRENT_USER"
            }
          },
          {
            "organization": {
              "members": {
                "user": {
                  "_eq": "$CURRENT_USER"
                }
              }
            }
          }
        ]
      }
    ]
  }'
);

-- 2) UPDATE permission
INSERT INTO directus_permissions (role, collection, action, permissions) VALUES (
  'ad2e4239-1849-481b-a224-eab79d0f8481', 
  'workspaces', 
  'update', 
  '{
    "_or": [
      {
        "user": {
          "_eq": "$CURRENT_USER"
        }
      },
      {
        "organization": {
          "owner": {
            "_eq": "$CURRENT_USER"
          }
        }
      },
      {
        "organization": {
          "members": {
            "user": {
              "_eq": "$CURRENT_USER"
            },
            "role": {
              "_eq": "admin"
            }
          }
        }
      }
    ]
  }'
);
