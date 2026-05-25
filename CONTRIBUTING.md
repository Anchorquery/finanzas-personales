# Contributing

Gracias por contribuir a Finanzas Personales.

## Setup local

1. Backend:
   ```powershell
   cd backend
   cp .env.example .env  # edita valores
   docker compose up -d
   ```
2. App móvil:
   ```powershell
   cd app_finanzas_mobile
   flutter pub get
   flutter run
   ```

## Workflow

- Crear branch desde `main`: `feat/<scope>` | `fix/<scope>` | `docs/<scope>`
- Commits estilo [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Antes de PR:
  - `cd app_finanzas_mobile && flutter analyze` (cero issues)
  - `flutter test` verde
  - Backend: `docker compose config --quiet` valida
- PR contra `main`, descripción con qué + por qué + cómo probar

## Estilo código

- Flutter: ver `app_finanzas_mobile/analysis_options.yaml` (flutter_lints)
- Dart: `dart format .`
- Indentación: 2 spaces (Dart, YAML, JSON); 4 spaces (Python, SQL); ver `.editorconfig`
- Líneas máx 100 chars en Dart
- Identificadores y código en inglés; UI strings y comentarios técnicos en español

## Tests

- Unit tests `app_finanzas_mobile/test/`
- Integration tests contra Directus local (no mocks de servicios críticos)
- Cobertura mínima para nuevo módulo: controllers + services

## Reportar bugs / pedir features

Abre un issue en GitHub con:
- Pasos para reproducir
- Versión Flutter (`flutter --version`), versión Directus, OS
- Logs relevantes (sanea credenciales)

## Seguridad

Vulnerabilidades: NO abras issue público. Email al maintainer.
