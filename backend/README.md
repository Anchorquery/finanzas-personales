# Backend — Directus + Postgres + Redis

Self-hosted backend for Finanzas Personales. Directus headless CMS sobre PostgreSQL con caché Redis. Custom extensions para BCV exchange rates y workspaces access control.

## Quick start

```powershell
# 1. Copia env vars
cp .env.example .env
# Edita .env con valores fuertes (KEY/SECRET via: openssl rand -hex 32)

# 2. Levanta stack
docker compose up -d

# 3. Verifica salud
docker compose ps
curl http://localhost:8055/server/health
```

Admin UI: http://localhost:8055/admin

## Estructura

```
backend/
├── docker-compose.yaml      # Stack: Directus + Postgres + Redis
├── Dockerfile               # Directus image con extensions/migrations
├── .env.example             # Plantilla variables entorno
├── extensions/              # Custom Directus extensions
│   ├── bcv-rates/           # Endpoint tasas BCV Venezuela
│   ├── bcv-scheduler/       # Job cron actualización BCV
│   └── workspaces-access/   # Hook control acceso workspaces
├── migrations/              # SQL migrations
│   ├── 20260322_workspace_access.sql
│   └── update_workspaces_permissions.sql
└── uploads/                 # Volumen Directus uploads (gitignored)
```

## Migraciones SQL

Migraciones se montan en `/directus/migrations` y Directus las aplica al iniciar.

Aplicar manualmente:

```powershell
docker compose exec finanzas_db psql -U directus -d directus -f /directus/migrations/20260322_workspace_access.sql
```

Verificar aplicadas:

```powershell
docker compose exec finanzas_db psql -U directus -d directus -c "\dt"
```

## Backup Postgres

```powershell
# Dump
docker compose exec finanzas_db pg_dump -U directus directus > backup_$(Get-Date -Format yyyyMMdd).sql

# Restore
Get-Content backup.sql | docker compose exec -T finanzas_db psql -U directus -d directus
```

Programar backup diario: usar Task Scheduler Windows o cron Linux apuntando al comando dump.

## Extensiones custom

| Extension | Tipo | Función |
|-----------|------|---------|
| `bcv-rates` | endpoint | Expone `/bcv-rates` con tasas USD/EUR del BCV |
| `bcv-scheduler` | hook | Actualiza tasas BCV cada N horas |
| `workspaces-access` | hook | Filtra colecciones por workspace del usuario |

Rebuild tras cambiar código extension:

```powershell
docker compose build finanzas_directus
docker compose up -d finanzas_directus
```

## Hardening producción

- [ ] Rotar `KEY`, `SECRET`, `ADMIN_PASSWORD`, `DB_PASSWORD` (todos via `.env`, nunca commit)
- [ ] `CORS_ORIGIN` con dominios reales, no `*`
- [ ] Reverse proxy con TLS (Caddy / Nginx)
- [ ] Postgres no expone puerto al host
- [ ] Backup automatizado offsite
- [ ] `LOG_LEVEL=warn` o `error`
- [ ] Renovar imagen base mensualmente (postgis:13-master, redis:6-alpine)

## Troubleshooting

**Directus no arranca:** revisa `docker compose logs finanzas_directus`. Causa común: `KEY`/`SECRET` no seteados (compose ahora falla rápido).

**Migraciones no aplican:** confirma montaje `./migrations:/directus/migrations` activo.

**Tasas BCV no actualizan:** `docker compose logs finanzas_directus | grep bcv`.
