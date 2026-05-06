# 💰 Finanzas Personales - Ecosistema de Gestión Financiera Inteligente

![Banner](banner.png)

**Finanzas Personales** es una solución integral diseñada para tomar el control total de tu vida financiera. A diferencia de las aplicaciones tradicionales, este ecosistema combina la potencia de un backend robusto y auto-hospedado con una aplicación móvil modular y moderna, integrando Inteligencia Artificial para ofrecer una experiencia de gestión financiera de nivel premium.

---

## 🌟 Características Principales

### 📱 Experiencia Móvil Modular
- **Gestión Multi-Perfil**: Soporte para organizaciones y espacios de trabajo compartidos.
- **Control de Gastos e Ingresos**: Registro detallado con categorías personalizables y soporte multi-moneda (USD, VES, EUR).
- **Escaneo de Recibos**: Procesa tus facturas automáticamente mediante OCR (en desarrollo).
- **Suscripciones y Recurrentes**: Nunca olvides un pago; gestiona tus servicios de streaming y facturas mensuales.
- **Seguimiento de Deudas**: Mantén un registro claro de lo que debes y lo que te deben.

### 🤖 Inteligencia Artificial (AI Coach)
- **Análisis Predictivo**: Basado en Google Gemini, la app analiza tus hábitos de gasto y te ofrece consejos personalizados para ahorrar.
- **Asistente Financiero**: Consulta dudas sobre tu salud financiera en lenguaje natural.

### 🛡️ Backend Empresarial (Self-Hosted)
- **Privacidad Total**: Tus datos te pertenecen. El backend corre sobre **Directus**, dándote control total sobre tu base de datos.
- **Arquitectura Escalable**: Desplegado mediante Docker para una portabilidad sin esfuerzo.
- **API First**: Integración sencilla con otros servicios mediante REST API.

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
| :--- | :--- |
| **Frontend** | [Flutter](https://flutter.dev/) (GetX Architecture) |
| **Backend** | [Directus CMS](https://directus.io/) (Node.js) |
| **Base de Datos** | PostgreSQL / SQLite |
| **AI Engine** | [Google Gemini AI](https://deepmind.google/technologies/gemini/) |
| **Infraestructura** | Docker & Docker Compose |
| **Scripting** | PowerShell / Python (Migración) |

---

## 📁 Estructura del Proyecto

```bash
├── app_finanzas_mobile/   # Aplicación móvil (Flutter)
├── backend/               # Configuración de Directus, Docker y Migraciones
├── docs/                  # Documentación técnica y guías de usuario
├── create_fields.ps1      # Script de automatización para el setup de Directus
└── .env                   # Variables de entorno y configuración sensible
```

---

## 🚀 Guía de Inicio Rápido

### 1. Configuración del Backend
Navega a la carpeta del backend e inicia los servicios:
```powershell
cd backend
docker-compose up -d
```

### 2. Preparar el Schema
Ejecuta el script de automatización para configurar los campos necesarios en Directus:
```powershell
./create_fields.ps1
```

### 3. Ejecutar la App Móvil
Asegúrate de tener Flutter instalado y configurado:
```bash
cd app_finanzas_mobile
flutter pub get
flutter run
```

---

## 📊 Roadmap

- [x] Gestión básica de transacciones.
- [x] Integración con Directus.
- [x] Soporte Multi-moneda.
- [ ] Implementación completa de OCR para recibos.
- [ ] Dashboard avanzado de visualización de datos.
- [ ] Sincronización en la nube cifrada de extremo a extremo.

---

## 🛡️ Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles (próximamente).

---

Desarrollado con ❤️ para todos los que buscan libertad financiera.
