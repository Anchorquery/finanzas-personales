# 💰 Finanzas Personales — Ecosistema de Gestión Financiera Inteligente

![Banner](docs/assets/banner.png)

**Finanzas Personales** es una solución integral para gestionar tu vida financiera. Combina un backend self-hosted (Directus) con una app móvil modular (Flutter + GetX) e integra Google Gemini para análisis con IA.

---

## 🌟 Características

### 📱 App móvil
- **Multi-perfil**: organizaciones y workspaces compartidos
- **Transacciones**: ingresos/gastos con categorías personalizables, multi-moneda (USD, VES, EUR)
- **OCR de recibos**: captura y analiza facturas con Gemini 2.5 Flash
- **Suscripciones y recurrentes**: gestiona pagos repetitivos
- **Deudas**: lo que debes y lo que te deben
- **Ahorros y presupuestos**
- **Conversión multi-moneda**: tasas BCV (Venezuela), Binance y paralelo

### 🤖 AI Coach
- Análisis de hábitos basado en Google Gemini
- Asistente conversacional con tool calling y human-in-the-loop
- Plan de pasos visible (write_todos pattern)

### 🛡️ Backend
- **Directus CMS** sobre PostgreSQL + Redis
- **Privacidad**: self-hosted, tus datos te pertenecen
- **Docker Compose**: portabilidad y despliegue trivial
- **API**: REST y GraphQL
- **Extensions custom**: BCV rates, scheduler, workspaces access control

---

## 🛠️ Stack

| Componente | Tecnología |
|---|---|
| Frontend | [Flutter](https://flutter.dev/) (GetX) |
| Backend | [Directus](https://directus.io/) (Node.js) |
| DB | PostgreSQL 13 (postgis) |
| Caché | Redis 6 |
| AI | [Google Gemini](https://deepmind.google/technologies/gemini/) via `langchain_google` |
| Infra | Docker Compose |

---

## 📁 Estructura

```
.
├── app_finanzas_mobile/   # App Flutter (GetX architecture)
├── backend/               # Directus + Postgres + Redis (Docker)
│   ├── docker-compose.yaml
│   ├── extensions/        # bcv-rates, bcv-scheduler, workspaces-access
│   └── migrations/        # SQL migrations
├── docs/                  # Documentación técnica
├── .github/workflows/     # CI (analyze, test, docker build)
├── LICENSE
└── README.md
```

---

## 🚀 Inicio rápido

### Backend

```powershell
cd backend
cp .env.example .env
# Edita .env: KEY/SECRET (openssl rand -hex 32), passwords, CORS_ORIGIN
docker compose up -d
# Admin UI → http://localhost:8055/admin
```

Más detalle: [backend/README.md](backend/README.md).

### App móvil

```powershell
cd app_finanzas_mobile
flutter pub get
flutter run
```

Configura la URL del backend en la pantalla de setup inicial. La API key de Gemini se guarda dentro de los settings de la organización en Directus (no en el cliente).

---

## 🧪 Testing

```powershell
cd app_finanzas_mobile
flutter analyze
flutter test
```

Backend:

```powershell
cd backend
docker compose config --quiet
```

CI corre estos comandos en cada PR — ver [.github/workflows/ci.yml](.github/workflows/ci.yml).

---

## 📊 Roadmap

- [x] Gestión transacciones
- [x] Integración Directus
- [x] Multi-moneda con tasas BCV/Binance/paralelo
- [x] OCR recibos (Gemini 2.5 Flash)
- [x] AI Coach con tool calling
- [x] Workspaces compartidos
- [ ] Dashboard avanzado con más visualizaciones
- [ ] Sincronización cifrada extremo-a-extremo
- [ ] Internacionalización completa (.arb files, EN/ES)
- [ ] Crash reporting (Sentry)
- [ ] Backup automatizado backend

---

## 🤝 Contribuir

Ver [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 🛡️ Licencia

MIT — ver [LICENSE](LICENSE).

---

Desarrollado con ❤️ para quienes buscan libertad financiera.
