## Arquitectura Decidida: Flutter + Directus

### Stack Tecnológico
- **Frontend**: Flutter (Aplicación Móvil)
- **Backend**: Directus (CMS Headless) ejecutándose en Docker
- **Base de Datos**: PostgreSQL (PostGIS) ejecutándose en Docker
- **Integración**: Bot de Python (Wrapper legado -> API de Directus)

### Estructura del Proyecto
- root/
  - `backend/`: Docker Compose y configuración de Directus
  - `app_finanzas/`: Proyecto Flutter
  - `bot.py`: Bot existente (será refactorizado)

### Paso 1: Backend (Directus)
- [x] Crear `docker-compose.yml` (Puerto 8056)
- [x] Iniciar contenedores (`docker compose up -d`)
- [x] Configurar Colecciones:
    - `transactions`: amount, category, concept, date, type, receipt_image (archivo), account
    - `accounts`: name, type, currency, initial_balance
    - `categories`: name, icon, budget
    - `users`: extendiendo `directus_users`

### Paso 2: Frontend (Flutter)
- [ ] Inicializar proyecto: `flutter create app_finanzas`
- [ ] Dependencias clave: `get`, `graphql_flutter`, `get_storage`, `fl_chart`
- [ ] Estructura de carpetas (Patrón GetX):
    - `lib/modules/`: Módulos por funcionalidad (Binding, Controller, View)
    - `lib/routes/`: AppPages y AppRoutes
    - `lib/data/`: Servicios (GraphQL) y Modelos
- [ ] Configuración Inicial: `GetMaterialApp`, `GraphQLConfig`, `Get.put(DirectusService)`

### Paso 3: Migración del Bot
- [ ] Crear adaptador Python para escribir en la API de Directus en lugar de Google Sheets.
