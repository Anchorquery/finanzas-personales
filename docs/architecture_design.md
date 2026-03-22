# Documento de Diseño de Arquitectura

## 1. Arquitectura Backend (Directus)

### Esquema de Base de Datos (Relacional)

Usaremos Directus para gestionar las siguientes tablas de PostgreSQL.

#### **Colecciones**

1.  **transactions**
    - `id` (UUID, PK)
    - `amount` (Decimal, precisión: 10, escala: 2)
    - `type` (String: 'income' | 'expense')
    - `category` (M2O -> categories.id)
    - `concept` (String, nullable)
    - `date` (DateTime, default: now)
    - `user_created` (M2O -> directus_users.id)
    - `receipt_image` (Relación Imagen/Archivo)
    - `status` (String: 'completed', 'pending')
    - `workspace` (M2O -> workspaces.id, nullable) -- Null = Personal
    - `account` (M2O -> accounts.id, nullable) -- Null = External/Cash? No, should be required ideally but nullable for migration.
    - `account` (M2O -> accounts.id)

2.  **accounts**
    - `id` (UUID, PK)
    - `name` (String, requerido)
    - `type` (String: 'bank', 'cash', 'card', 'other')
    - `currency` (String, default: 'USD')
    - `initial_balance` (Decimal)
    - `workspace` (M2O -> workspaces.id, nullable) -- Null = Personal

2.  **categories**
    - `id` (UUID, PK)
    - `name` (String, requerido)
    - `icon` (String, emoji o código de icono)
    - `color` (String, código hex)
    - `budget_limit` (Decimal, nullable)
    - `type` (String: 'income' | 'expense' | 'both')
    - `workspace` (M2O -> workspaces.id, nullable) -- Null = Global/Personal

3.  **organizations** (Entidad Raíz)
    - `id` (UUID, PK)
    - `name` (String, ej: 'Familia Pérez', 'My Finances')
    - `owner` (M2O -> directus_users.id)

4.  **workspaces** (Hijos de Org)
    - `id` (UUID, PK)
    - `organization` (M2O -> organizations.id)
    - `name` (String)
    - `type` (String: 'personal' | 'shared') -- 'personal' se crea automáticamente
    - `icon` (String, nullable)

5.  **organization_members** (Personas en la Org)
    - `id` (UUID, PK)
    - `organization` (M2O -> organizations.id)
    - `user` (M2O -> directus_users.id)
    - `role` (String: 'admin', 'member')

5.  **accounts** (Cuentas Financieras)
    - `id` (UUID, PK)
    - `name` (String, ej: 'Bank of America', 'Cartera')
    - `type` (String: 'cash' | 'bank' | 'credit_card' | 'investment')
    - `currency` (String, default: 'USD')
    - `initial_balance` (Decimal, nullable)
    - `workspace` (M2O -> workspaces.id)

#### **Relaciones**
- `workspaces.organization` -> `organizations.id`
- `transactions.workspace` -> `workspaces.id`
- `transactions.account` -> `accounts.id`
- `accounts.workspace` -> `workspaces.id`

#### **Seguridad y Permisos (La Lógica de la "Bóveda")**
- **Alcance 1: Espacio de Trabajo Personal**
  - Regla: `workspace.type` = 'personal'.
  - **Acceso**: SOLO el Usuario propietario del Espacio de Trabajo Personal (definido por un campo `owner` en el workspace o enlace de usuario) puede verlo. Incluso los Admins de la Org no pueden ver los espacios personales de otros.
  
- **Alcance 2: Espacios de Trabajo Compartidos**
  - Regla: `workspace.type` = 'shared'.
  - **Acceso**: Visible para `organization_members` a quienes se les concede acceso (o todos los miembros, según preferencia).

---

## 2. Arquitectura Frontend (Flutter)

### Patrón de Arquitectura: Patrón GetX

Usaremos **GetX** para la Gestión de Estado, Enrutamiento e Inyección de Dependencias. Esto proporciona un enfoque más simple y con menos código repetitivo (boilerplate).

#### **Estructura de Carpetas (Patrón GetX)**

```
lib/
├── main.dart                  # Punto de entrada, GetMaterialApp
├── config/
│   ├── theme.dart             # Tema de UI
│   ├── routes/
│   │   ├── app_pages.dart     # Definiciones de GetPage
│   │   └── app_routes.dart    # Constantes de nombres de rutas
│   └── constants.dart         # URLs de API
├── core/
│   ├── api/                   # Cliente GraphQL (graphql_flutter)
│   └── utils/                 # Helpers / Utilidades
├── modules/                   # Organizado por funcionalidad (Vista + Controlador + Binding)
│   ├── auth/
│   │   ├── auth_binding.dart
│   │   ├── auth_controller.dart
│   │   └── auth_view.dart
│   ├── dashboard/
│   │   ├── dashboard_binding.dart
│   │   ├── dashboard_controller.dart
│   │   └── dashboard_view.dart
│   ├── transactions/
│   │   ├── transaction_binding.dart
│   │   ├── transaction_controller.dart
│   │   └── transaction_view.dart
│   └── workspaces/
│       ├── workspace_binding.dart
│       ├── workspace_controller.dart
│       └── workspace_switcher_view.dart
├── data/                      # Repositorios/Servicios Globales
│   ├── models/                
│   ├── providers/             # Proveedores GraphQL
│   └── services/              # Servicio Directus (GraphQL)
└── global_widgets/            # Widgets reutilizables
```

### Librerías Clave
- **Core**: `get` (Estado, Auth, Nav, DI)
- **Redes**: `graphql_flutter` (Cliente GraphQL)
- **Almacenamiento**: `get_storage` (Datos simples persistentes como tokens)
- **Modelos**: `json_serializable` (opcional, o simple `fromJson`)
- **Gráficos**: `fl_chart`

## 3. Estrategia de Integración
- **Adaptador del Bot**: Un script en Python (`cms_service.py`) consultará la API de Directus. Cuando un usuario envíe un recibo a Telegram, el bot lo enviará a Gemini (existente), luego ejecutará una **Mutación GraphQL** a `Directus /graphql`.
