# Documento de Contexto y Diseño - Finanzas Personales

## 1. Visión General del Proyecto
**Nombre:** Finanzas Personales
**Descripción:** Una aplicación integral para la gestión de finanzas personales y compartidas, potenciada por Inteligencia Artificial (Gemini) y con integración fluida a través de Telegram.

### Propósito
Facilitar el seguimiento de ingresos y gastos, la creación de presupuestos y el análisis financiero inteligente, permitiendo a los usuarios tomar decisiones informadas sobre su dinero. La aplicación se destaca por su capacidad de registrar transacciones rápidamente vía Telegram y analizarlas en profundidad en la App Móvil.

### Componentes del Sistema
1.  **App Móvil (Flutter):** La interfaz principal para visualización de datos, análisis, configuración y gestión detallada.
2.  **Bot de Telegram (Python):** Interfaz para captura rápida de datos (fotos de recibos, mensajes de texto) y notificaciones instantáneas.
3.  **Backend (Directus + PostgreSQL):** Gestor de contenido y base de datos segura para almacenar toda la información.
4.  **AI Engine (Gemini):** Procesa recibos, categoriza transacciones automáticamente y ofrece consejos financieros (AI Coach).

---

## 2. Pautas de Diseño (Design Guidelines)

### Estilo Visual
*   **Tema:** Dark Mode por defecto (Moderno y elegante).
*   **Paleta de Colores:**
    *   **Fondo:** Tonos oscuros (Negro, Gris Plomo) para reducir fatiga visual.
    *   **Acentos:**
        *   🟢 Verde Neón/Esmeralda: Ingresos, Ahorros, Estado Positivo.
        *   🔴 Rojo/Coral: Gastos, Deudas, Alertas.
        *   🔵 Azul/Violeta: Tecnología, AI Coach, Navegación.
        *   🟡 Amarillo/Ámbar: Advertencias, Pendientes.
*   **Tipografía:** Limpia y legible (ej. Inter, Roboto o Poppins).
*   **Iconografía:** Iconos minimalistas (Outline o Filled según estado).

### Experiencia de Usuario (UX)
*   **Navegación:** Barra de navegación inferior (BottomNavigationBar) para acceso rápido a secciones clave.
*   **Interacción:** Uso de gestos (swipe) para acciones rápidas en listas.
*   **Feedback:** Animaciones sutiles al completar acciones y estados de carga (esqueletos).

---

## 3. Vistas y Funcionalidades (Site Map)

A continuación se detallan las vistas principales de la aplicación móvil y sus funcionalidades:

### 3.1. Autenticación (Auth)
*   **Vista de Login:**
    *   Inicio de sesión con Correo/Contraseña.
    *   Inicio de sesión social (Google).
    *   Enlace a "Recuperar Contraseña".
*   **Funcionalidad:** Gestión segura de sesiones y tokens (JWT).

### 3.2. Tablero Principal (Dashboard)
*   **Resumen Financiero:** Tarjetas con "Saldo Total", "Ingresos del Mes", "Gastos del Mes".
*   **Gráficos Rápidos:** Gráfico de línea o barras mostrando flujo de efectivo reciente.
*   **Actividad Reciente:** Lista corta de las últimas 5 transacciones.
*   **Accesos Directos:** Botones para "Añadir Transacción", "Ver Presupuesto".

### 3.3. Transacciones (Transactions)
*   **Lista General:** Historial completo de movimientos.
    *   **Filtros:** Por fecha (mes/año), categoría, tipo (ingreso/gasto), cuenta.
*   **Detalle de Transacción:**
    *   Monto, Categoría, Fecha, Nota, Foto del recibo (si existe).
    *   Posibilidad de Editar o Eliminar.
*   **Nueva Transacción:** Formulario para ingreso manual.

### 3.4. Espacios de Trabajo (Workspaces)
*   **Selector de Espacio:** Permite cambiar entre finanzas "Personales", "Familiares" o "Negocio".
*   **Gestión:** Crear nuevos espacios, invitar miembros (para espacios compartidos), asignar roles.

### 3.5. Eventos y Calendario (Events)
*   **Vista Calendario:** Visualización de transacciones pasadas y futuras en un calendario.
*   **Próximos Vencimientos:** Lista de facturas o pagos programados cercanos.
*   **Crear Evento:** Programar un pago único o recordatorio.

### 3.6. Presupuestos (Budgets)
*   **Lista de Presupuestos:** Barras de progreso por categoría (ej. "Alimentación: 80% gastado").
*   **Creación/Edición:** Definir límites de gasto mensuales o semanales.
*   **Alertas:** Indicadores visuales cuando se acerca o excede el límite.

### 3.7. Suscripciones (Subscriptions)
*   **Gestor de Recurrentes:** Lista de servicios suscritos (Netflix, Spotify, Gym).
*   **Detalles:** Costo, ciclo de facturación, próxima fecha de cobro.
*   **Análisis:** Costo total mensual/anual en suscripciones.

### 3.8. AI Coach
*   **Chat Financiero:** Interfaz tipo chat para interactuar con Gemini.
*   **Funcionalidades:**
    *   Preguntar "¿Cuánto gasté en comida el mes pasado?".
    *   Pedir consejos de ahorro.
    *   Análisis de patrones de gasto inusuales.

### 3.9. Ahorros y Metas (Savings)
*   **Metas:** Crear objetivos (ej. "Viaje a Japón", "Fondo de Emergencia").
*   **Seguimiento:** Barra de progreso basada en el dinero asignado a cada meta.
*   **Aportes:** Registrar sumas de dinero hacia una meta específica.

### 3.10. Deudas (Debts)
*   **Registro de Deudas:** Préstamos o tarjetas de crédito por pagar.
*   **Estrategia de Pago:** Visualización de saldo restante y fechas límite.

### 3.11. Configuración (Settings)
*   **Perfil:** Editar foto, nombre, correo.
*   **Apariencia:** Alternar temas (Claro/Oscuro/Sistema).
*   **Notificaciones:** Configurar alertas de gastos, presupuestos y resumen semanal.
*   **Seguridad:** Biometría (Huella/FaceID) para abrir la app.
*   **Exportar:** Descargar datos en CSV/PDF.

---

## 4. Tecnologías Clave en Frontend
*   **Framework:** Flutter (Multiplataforma).
*   **Gestión de Estado:** GetX.
*   **Gráficos:** `fl_chart` para visualizaciones atractivas.
*   **Conexión API:** `graphql_flutter` para comunicación eficiente con Directus.
*   **Almacenamiento Local:** `get_storage` para preferencias de usuario.

---

Este documento sirve como referencia base para el diseño UI/UX y el desarrollo de funcionalidades de la aplicación.
