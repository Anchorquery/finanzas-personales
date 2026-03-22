# Ruta de Planificación Mejorada: Finanzas Personales & Grupales (Directus + Flutter)

Hemos analizado tu propuesta de planificación. Dado que ya tenemos una dirección tecnológica clara (Directus/Flutter) y el proyecto es una herramienta interna/producto propio (no necesariamente una Startup buscando inversores inmediatos), he optimizado el plan para enfocarnos en **Arquitectura Sólida** y **Definición de Producto**, reduciendo la carga de tareas de "Negocio/Venta" que podrían distraer del desarrollo inicial.

## Objetivos del Plan
1.  **Validar el Modelo "Organización Céntrica"**: Asegurar que la privacidad (Personal) y colaboración (Grupal) coexistan sin fugas de datos.
2.  **Definir la Experiencia de Usuario (UX)**: Cómo se siente cambiar de "Mi Bóveda" a "Gastos de Casa".
3.  **Especificar la Arquitectura Técnica**: Estándares de código, seguridad y patrones.

---

## FASE 1: Definición del Producto (El "Qué" y "Cómo")

### 1.1 Contexto del Sistema y Flujos (Skill: `c4-context`)
En lugar de un diagrama genérico, definiremos el **Modelo Mental del Usuario**:
*   **Persona**: Usuario Administrador vs Usuario Miembro.
*   **Sistemas**: App Móvil, Bot Telegram, Directus API, Gemini AI.
*   **Interacciones Clave**: "Invitar a Org", "Crear Workspace", "Registrar Gasto Privado".
*   **Acción**: Generar diagrama C4 Context actualizado con la nueva jerarquía.

### 1.2 Historias de Usuario "Core" (Skill: `brainstorming` / `concise-planning`)
Desglosaremos las funcionalidades en historias implementables.
*   *Como usuario, quiero tener un espacio 'Personal' que nadie más vea.*
*   *Como administrador de una Org, quiero invitar a mi pareja para que vea el workspace 'Casa'.*

---

## FASE 2: Arquitectura Técnica (El "Plano Maestro")

### 2.1 Decisiones de Arquitectura (Skill: `architecture`) - *Ya Avanzado*
Refinaremos las decisiones ya tomadas:
*   **Backend**: Directus (Postgres). ¿Por qué? Rapidez y flexibilidad relacional.
*   **Frontend**: Flutter + GetX (GraphQL). ¿Por qué? Rendimiento y simplicidad.
*   **Privacidad**: Row Level Security (RLS) vs Lógica de App. (Decisión crítica: usaremos Filtros de Permisos de Directus).

### 2.2 Diseño de Software Detallado (Skill: `software-architecture`)
Estructura de Carpetas y Patrones en Flutter:
*   Definición estricta de `GetX Pattern`.
*   Manejo de **"Scope Switcher"** (Cambio de contexto Personal/Org) en el estado global.
*   Estrategia de **Offline-First** (si aplica) o caché agresivo con GraphQL.

---

## FASE 3: Ejecución (Manos a la Obra)

### 3.1 Configuración Inicial (Skill: `conductor-setup` / `environment-setup-guide`)
*   Setup del entorno Docker (Directus).
*   Scaffold del proyecto Flutter.
*   Configuración de Linter y CI/CD básico (GitHub Actions).

### 3.2 Implementación Modular
*   Módulo 1: Auth & Org Management.
*   Módulo 2: Workspaces.
*   Módulo 3: Transacciones & Dashboard.

---

**Nota sobre Skills**: Usaré los skills disponibles en `./backend/.agent/skills/skills` para guiar cada paso. Si algún archivo falta, aplicaré mi conocimiento experto en su lugar respetando la metodología.
