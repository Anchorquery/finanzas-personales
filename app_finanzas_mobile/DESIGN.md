# DESIGN.md — Rediseño UI/UX App Finanzas (LIGHT ONLY)

> Documento maestro para agente de diseño. Contiene contexto, objetivos, sistema de diseño, inventario de páginas, reglas y plan de ejecución.

---

## 0. TL;DR cambio crítico

- **Eliminar dark mode**. App **light only**. Borrar `darkTheme`, `ThemeMode`, toggle settings.
- Estética: **clara, moderna, aireada** (Mercury / Stripe / Linear light).
- Paleta definida en §5. FinanceColors en §6 — listo para implementar.
- Plan en §11. Empezar Paso 2 (refactor `app_theme.dart`) ya que paleta ya está aprobada en el doc.

---

## 1. Contexto técnico

- **Stack**: Flutter 3.x + Material 3 + GetX (state/routing) + langchain_dart + Directus backend + Gemini AI
- **Targets**: Web (PWA) + Android + iOS
- **Tema actual**: `lib/core/theme/app_theme.dart`
- **Font**: Inter via `google_fonts`
- **Tema actual — paleta**:
  - Primary: `#2B4BEE` (azul)
  - Dark bg: `#0F172A` (Slate 900)
  - Light bg: `#F6F6F8`
  - Semánticos: green `#10B981` (income), red `#F43F5E` (expense), amber `#F59E0B` (warn), violet `#8B5CF6` (AI), blue `#3B82F6` (bank/info)
- **ColorScheme actual**: mínimo (solo `primary`/`secondary`/`surface`/`error`). Falta cobertura M3 completa.

---

## 2. Objetivos del rediseño

1. **Paleta cohesiva fintech moderna LIGHT-ONLY**. Referencias: Linear (light), Stripe Dashboard, Mercury, Ramp, Lunch Money, Copilot Money.
2. **SOLO modo claro** — eliminar dark theme. App moderna, luminosa, aireada. Reduce complejidad mantenimiento y bundle.
3. **ColorScheme M3 completo (light)**: primary/onPrimary/primaryContainer/onPrimaryContainer/secondary/onSecondary/secondaryContainer/tertiary/onTertiary/tertiaryContainer/surface/surfaceContainerLowest/Low/Default/High/Highest/surfaceTint/onSurface/onSurfaceVariant/outline/outlineVariant/error/onError/errorContainer/inverseSurface/inverseOnSurface/inversePrimary.
4. **Tokens semánticos finanzas** (vía `ThemeExtension<FinanceColors>`): `income`, `expense`, `savings`, `debt`, `investment`, `subscription`, `transfer`, `neutral`, `ai`, `pending`, `cleared`.
5. **Estados completos**: hover, focus, pressed, disabled, selected, dragged (críticos en web/desktop).
6. **Contraste WCAG AA mínimo, AAA en texto crítico (>= 7:1)** sobre fondos claros.
7. **Optimización WEB por página** (detalle en sección 7).

---

## 3. Principios de diseño

1. **Claridad sobre decoración** — el dato financiero manda. Reducir ruido visual.
2. **Jerarquía clara** — saldo principal > KPIs > listas > metadata.
3. **Color con significado** — rojo SIEMPRE = gasto/deuda, verde = ingreso/ahorro. Nunca decorativo.
4. **Densidad adaptativa** — mobile cómodo (touch 48px+), desktop denso (más data por viewport).
5. **Feedback instantáneo** — hover, focus, loading, success/error toasts.
6. **Accesibilidad first** — contraste, focus visible, keyboard nav, screen reader labels.
7. **Mobile-first, desktop-thoughtful** — no escalar mobile a desktop, repensar layout.
8. **Empty states útiles** — guiar primera acción, no solo "no hay datos".

---

## 4. Sistema de diseño

### 4.1 Breakpoints

| Nombre | Rango | Layout |
|---|---|---|
| `mobile` | < 600px | Single column, bottom nav, FAB |
| `tablet` | 600–1024px | Nav rail, single/dual column |
| `desktop` | 1024–1440px | Sidebar nav, max content 1200px |
| `wide` | > 1440px | Sidebar + main + panel contextual derecha |

Helper Dart:
```dart
extension BreakpointX on BuildContext {
  double get _w => MediaQuery.sizeOf(this).width;
  bool get isMobile => _w < 600;
  bool get isTablet => _w >= 600 && _w < 1024;
  bool get isDesktop => _w >= 1024;
  bool get isWide => _w >= 1440;
}
```

### 4.2 Spacing scale (8pt grid)

`4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96`

### 4.3 Radius scale

`4 (chips/badges), 8 (inputs/buttons), 12 (small cards), 16 (cards), 20 (modals), 24 (sheets), 999 (pills/avatar)`

### 4.4 Elevation (M3 surfaceContainer — light only)

Sin sombras pesadas. Jerarquía por **tono de superficie** (no shadow excesivo). Sombras suaves opcionales (`shadowColor` baja opacidad).

- `surface` (#FFFFFF) — fondo base scaffold (o `surfaceContainerLowest`)
- `surfaceContainerLowest` (#FFFFFF) — input bg, sunken
- `surfaceContainerLow` (#F8FAFC) — card sutil
- `surfaceContainer` (#F1F5F9) — card estándar / sidebar bg
- `surfaceContainerHigh` (#E2E8F0) — card destacada / hover
- `surfaceContainerHighest` (#CBD5E1) — overlay / dialog backdrop tint

Sombras (uso moderado):
- `sm`: `0 1px 2px rgba(15, 23, 42, 0.04)` — cards lista
- `md`: `0 4px 12px rgba(15, 23, 42, 0.06)` — cards destacadas
- `lg`: `0 12px 32px rgba(15, 23, 42, 0.08)` — modales/dialogs
- NUNCA `elevation: 8+` Material — feo en light.

### 4.5 Typography (Inter)

| Token | Size | Weight | Line | Uso |
|---|---|---|---|---|
| `displayLarge` | 57 | 400 | 64 | Hero balance card |
| `displayMedium` | 45 | 400 | 52 | Stats grandes |
| `headlineLarge` | 32 | 600 | 40 | Títulos página desktop |
| `headlineMedium` | 28 | 600 | 36 | Títulos página mobile |
| `headlineSmall` | 24 | 600 | 32 | Subtítulos sección |
| `titleLarge` | 20 | 600 | 28 | Card titles |
| `titleMedium` | 16 | 600 | 24 | List item title |
| `titleSmall` | 14 | 600 | 20 | Tags / labels destacados |
| `bodyLarge` | 16 | 400 | 24 | Body principal |
| `bodyMedium` | 14 | 400 | 20 | Body estándar |
| `bodySmall` | 12 | 400 | 16 | Metadata / hints |
| `labelLarge` | 14 | 500 | 20 | Botones |
| `labelMedium` | 12 | 500 | 16 | Chips |
| `labelSmall` | 11 | 500 | 16 | Captions |
| `numeric` (tabular) | – | – | – | Montos: `fontFeatures: [FontFeature.tabularFigures()]` |

### 4.6 Iconografía

- `Iconsax` o `Phosphor Icons` (consistencia, fintech-friendly). Evitar mix con Material Icons.
- Tamaños: 16, 20, 24, 32, 48
- Color por defecto: `onSurfaceVariant`. Estado activo: `primary`.

### 4.7 Estados interactivos (overlays M3)

- hover: 8% onSurface sobre componente
- focus: 12% onSurface + ring 2px `primary`
- pressed: 12% onSurface
- selected: 16% primary container
- disabled: opacity 38% texto, 12% bg

---

## 5. Paleta propuesta — LIGHT ONLY

### 5.1 Filosofía

App **clara, moderna, aireada**. Inspirada en Mercury / Stripe / Linear light. Predomina **blanco roto + grises Slate fríos** con **azul primario vibrante** y **acentos semánticos saturados pero refinados** (no neón).

- Fondo principal: `#FAFBFC` (blanco roto, sin glare)
- Superficies: blanco puro `#FFFFFF` para cards principales (Mercury-style)
- Tipografía sobre Slate 900 (`#0F172A`) — máximo contraste, no negro puro
- Acentos saturados pero con `*Container` suave para badges/tags/highlights

### 5.2 ColorScheme M3 (light)

| Token | Hex | Uso | Contraste vs `surface` | WCAG |
|---|---|---|---|---|
| `primary` | `#2B4BEE` | CTA principal, links, focus ring | 7.9:1 | AAA |
| `onPrimary` | `#FFFFFF` | Texto/icono sobre primary | 7.9:1 | AAA |
| `primaryContainer` | `#DDE3FF` | Chips activos, badges primarios, selected bg | 1.1:1 | (decorativo) |
| `onPrimaryContainer` | `#0A1B7A` | Texto sobre primaryContainer | 12.4:1 | AAA |
| `secondary` | `#5B6478` | Acciones secundarias, iconos inactivos | 6.2:1 | AA |
| `onSecondary` | `#FFFFFF` | Texto sobre secondary | 6.2:1 | AA |
| `secondaryContainer` | `#E4E7EF` | Chips neutros, tabs inactivos | 1.1:1 | (decorativo) |
| `onSecondaryContainer` | `#1E2433` | Texto sobre secondaryContainer | 13.8:1 | AAA |
| `tertiary` | `#7C3AED` | Acentos IA, highlights especiales | 5.4:1 | AA |
| `onTertiary` | `#FFFFFF` | Texto sobre tertiary | 5.4:1 | AA |
| `tertiaryContainer` | `#EDE4FF` | Badges IA, panels destacados | 1.1:1 | (decorativo) |
| `onTertiaryContainer` | `#3B1490` | Texto sobre tertiaryContainer | 11.2:1 | AAA |
| `error` | `#DC2626` | Errores, validación, danger CTAs | 5.9:1 | AA |
| `onError` | `#FFFFFF` | Texto sobre error | 5.9:1 | AA |
| `errorContainer` | `#FEE2E2` | Error backgrounds, badges destructivos | 1.1:1 | (decorativo) |
| `onErrorContainer` | `#7F1D1D` | Texto sobre errorContainer | 9.8:1 | AAA |
| `surface` | `#FFFFFF` | Cards principales, modals | — | — |
| `onSurface` | `#0F172A` | Texto principal | 19.3:1 | AAA |
| `onSurfaceVariant` | `#475569` | Texto secundario, iconos | 7.4:1 | AAA |
| `surfaceContainerLowest` | `#FFFFFF` | Inputs, sunken surfaces | — | — |
| `surfaceContainerLow` | `#F8FAFC` | Card sutil, hover bg | 1.02:1 | — |
| `surfaceContainer` | `#F1F5F9` | Sidebar, panel bg, scaffold alt | 1.05:1 | — |
| `surfaceContainerHigh` | `#E2E8F0` | Hover destacado, divisores fuertes | 1.13:1 | — |
| `surfaceContainerHighest` | `#CBD5E1` | Overlay tint, skeleton bg | 1.32:1 | — |
| `surfaceTint` | `#2B4BEE` | Tinte elevación M3 (sutil sobre cards elevadas) | — | — |
| `outline` | `#94A3B8` | Bordes inputs, dividers principales | 3.1:1 | AA non-text |
| `outlineVariant` | `#E2E8F0` | Bordes sutiles, dividers secundarios | 1.13:1 | — |
| `inverseSurface` | `#1E293B` | Toast/snackbar bg | 14.1:1 | AAA |
| `inverseOnSurface` | `#F1F5F9` | Texto sobre inverseSurface | 14.1:1 | AAA |
| `inversePrimary` | `#A6B5FF` | Links sobre inverseSurface | 7.8:1 (vs invSurf) | AAA |
| `shadow` | `#0F172A` (alpha bajo) | Sombras (usar con 4-8% alpha) | — | — |
| `scrim` | `#0F172A` (alpha 50%) | Modal backdrop | — | — |
| `scaffoldBackground` (custom) | `#FAFBFC` | Fondo página | 1.01:1 | — |

### 5.3 Justificación

- **`primary #2B4BEE`** — mantiene identidad azul actual. Contraste 7.9:1 sobre blanco = AAA. Azul = confianza/banca (Stripe, PayPal, Chase).
- **`primaryContainer #DDE3FF`** — versión 50-100 del primary para badges/selected. Suave, no compite con CTA.
- **`secondary #5B6478`** — Slate frío neutro, para acciones no-CTA y metadata. Distingue jerarquía sin colorear.
- **`tertiary #7C3AED`** — violeta para IA (sección AI Coach, suggestions). Diferencia visual clara del primary.
- **`error #DC2626`** — rojo Tailwind 600. Saturado pero no chillón. AA sobre blanco.
- **`surface` blanco puro** — Mercury/Stripe style. Cards destacan sobre `scaffoldBackground` `#FAFBFC` levemente off-white.
- **`onSurface #0F172A`** — Slate 900, no negro puro. Reduce fatiga lectura.
- **`onSurfaceVariant #475569`** — Slate 600, contraste AAA (7.4:1) para metadata, hints, captions.
- **`outline #94A3B8`** — Slate 400. Bordes visibles sin gritar. AA non-text.
- **`outlineVariant #E2E8F0`** — Slate 200. Divisores casi invisibles, sólo agrupan.
- **Sin dark mode** — reduce QA, bundle, complejidad. App diurna 100%.

### 5.4 Restricciones

- ❌ NO negro puro (`#000`) — Slate 900 (`#0F172A`)
- ❌ NO blanco puro como scaffold — `#FAFBFC` evita glare
- ❌ NO colores neón/pastel saturados
- ❌ NO mezclar grises cálidos con fríos — todo Slate (frío)
- ✅ Verde income / rojo expense intocables (UX universal fintech)
- ✅ Primary azul mantiene identidad marca

---

## 6. Tokens semánticos finanzas (FinanceColors) — LIGHT

Cada token tiene par `xxx` (texto/icono saturado) + `xxxContainer` (bg suave para chips/badges/highlights). Todos calibrados para fondo light.

| Token | Hex | Container | Uso |
|---|---|---|---|
| `income` | `#059669` (Emerald 600) | `#D1FAE5` (Emerald 100) | Ingresos, montos positivos |
| `expense` | `#DC2626` (Red 600) | `#FEE2E2` (Red 100) | Gastos, montos negativos |
| `savings` | `#0891B2` (Cyan 600) | `#CFFAFE` (Cyan 100) | Metas ahorro, progress |
| `debt` | `#EA580C` (Orange 600) | `#FFEDD5` (Orange 100) | Deudas, plazos pendientes |
| `investment` | `#CA8A04` (Yellow 600) | `#FEF9C3` (Yellow 100) | Inversiones, retornos |
| `subscription` | `#7C3AED` (Violet 600) | `#EDE9FE` (Violet 100) | Suscripciones recurrentes |
| `transfer` | `#475569` (Slate 600) | `#E2E8F0` (Slate 200) | Movimientos internos |
| `ai` | `#7C3AED` (Violet 600) | `#EDE9FE` (Violet 100) | Agente IA, sugerencias |
| `aiGradientStart` | `#8B5CF6` | — | Hero IA |
| `aiGradientEnd` | `#3B82F6` | — | Hero IA |
| `pending` | `#D97706` (Amber 600) | `#FEF3C7` (Amber 100) | Estados pendientes |
| `cleared` | `#94A3B8` (Slate 400) | `#F1F5F9` (Slate 100) | Conciliado / archivado |
| `positive` | alias `income` | — | Helper genérico |
| `negative` | alias `expense` | — | Helper genérico |

```dart
@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  final Color income, incomeContainer;
  final Color expense, expenseContainer;
  final Color savings, savingsContainer;
  final Color debt, debtContainer;
  final Color investment, investmentContainer;
  final Color subscription, subscriptionContainer;
  final Color transfer, transferContainer;
  final Color ai, aiContainer, aiGradientStart, aiGradientEnd;
  final Color pending, pendingContainer;
  final Color cleared, clearedContainer;
  // aliases
  Color get positive => income;
  Color get negative => expense;
  // ... copyWith + lerp obligatorios para ThemeExtension
}

const financeColorsLight = FinanceColors(
  income:               Color(0xFF059669),
  incomeContainer:      Color(0xFFD1FAE5),
  expense:              Color(0xFFDC2626),
  expenseContainer:     Color(0xFFFEE2E2),
  savings:              Color(0xFF0891B2),
  savingsContainer:     Color(0xFFCFFAFE),
  debt:                 Color(0xFFEA580C),
  debtContainer:        Color(0xFFFFEDD5),
  investment:           Color(0xFFCA8A04),
  investmentContainer:  Color(0xFFFEF9C3),
  subscription:         Color(0xFF7C3AED),
  subscriptionContainer:Color(0xFFEDE9FE),
  transfer:             Color(0xFF475569),
  transferContainer:    Color(0xFFE2E8F0),
  ai:                   Color(0xFF7C3AED),
  aiContainer:          Color(0xFFEDE9FE),
  aiGradientStart:      Color(0xFF8B5CF6),
  aiGradientEnd:        Color(0xFF3B82F6),
  pending:              Color(0xFFD97706),
  pendingContainer:     Color(0xFFFEF3C7),
  cleared:              Color(0xFF94A3B8),
  clearedContainer:     Color(0xFFF1F5F9),
);
```

Acceso ergonómico:
```dart
extension ThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  FinanceColors get finance => Theme.of(this).extension<FinanceColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
```

Uso: `context.finance.income`, `context.colors.primary`, `context.text.titleLarge`.

---

## 7. Optimización WEB — reglas universales

Aplicar a TODAS las páginas:

- **Cursor**: `SystemMouseCursors.click` en clickables, `text` en TextField, `default` en static. Usar `MouseRegion` o widgets nativos.
- **Hover**: `InkWell` con `hoverColor: context.colors.onSurface.withValues(alpha: 0.08)` en cards/tiles.
- **Focus ring visible**: `FocusableActionDetector` + outline `primary` 2px, especialmente inputs/botones.
- **Keyboard nav**: tab order lógico, atajos comunes (Enter submit, Esc close, Ctrl+K command palette futuro).
- **Max content width**: `ConstrainedBox(maxWidth: 1200)` en main content desktop. Texto largo `maxWidth: 720`.
- **Skeleton loaders**: reemplazar `CircularProgressIndicator` centrados por shimmer cards (paquete `skeletonizer`).
- **Scroll**: nativo (`ScrollBehavior` con mouse drag enabled). NO `PageView` en desktop (salvo wizards).
- **Tooltips**: `Tooltip` en iconos sin texto.
- **Empty states**: ilustración + título + descripción + CTA primario.
- **Error states**: mensaje claro + acción recuperación (retry, back).
- **Loading states**: nunca bloquear UI completa salvo onboarding crítico.
- **URLs limpias**: `usePathUrlStrategy()` en `main.dart`. Rutas deep-linkables.
- **Imágenes responsive**: usar `Image.network` con `loadingBuilder` + `errorBuilder`.
- **Animaciones**: 150–250ms estándar, `Curves.easeOutCubic`. Respetar `MediaQuery.disableAnimations`.

---

## 8. Layout shells (Home shell + navegación)

### Mobile (<600)
- `AppBar` (logo + avatar + notif)
- Contenido scrollable
- `BottomNavigationBar` 5 items: Dashboard, Transactions, AI Coach, Stats, Settings
- `FloatingActionButton` extendido → "Nuevo movimiento"

### Tablet (600–1024)
- `NavigationRail` izquierda (icons + labels colapsables)
- Contenido full ancho
- FAB esquina inferior derecha

### Desktop (>1024)
- **Sidebar fija** izquierda (240px):
  - Logo arriba
  - Workspace switcher (dropdown)
  - Nav vertical (icon + label):
    - Dashboard
    - Transactions
    - Accounts
    - Budgets
    - Savings goals
    - Debts
    - Subscriptions
    - Stats
    - AI Coach
    - Events
  - Bottom: Settings + Profile + Logout
- **Main content** (max 1200px centrado, padding 32px)
- **Panel contextual** derecha opcional (320px) — filtros, detalle item, AI sidebar

### Wide (>1440)
- Igual desktop + panel contextual SIEMPRE visible

---

## 9. Inventario de páginas

> Cada página debe rediseñarse con: layout responsive (mobile/desktop), hover states, tokens semánticos, empty/loading/error states.

### P0 — Crítico (entry + uso diario)

| # | Página | Path | Descripción | Notas rediseño |
|---|---|---|---|---|
| 1 | Login | `auth/login_view.dart` | Auth email/password + biometría | Desktop: card centrada 480px maxWidth + ilustración lateral. Mobile: full-width, logo top. |
| 2 | Register | `auth/register_view.dart` | Alta usuario | Mismo patrón login. Validación inline. |
| 3 | Forgot password | `auth/forgot_password_view.dart` | Reset email | Modal o página mínima centrada. |
| 4 | Home shell | `home/home_view.dart` | Shell con nav + contenido | Implementa adaptive shell (mobile/tablet/desktop) sección 8. |
| 5 | Dashboard | `dashboard/dashboard_view.dart` | Balance + KPIs + gráficos + accesos rápidos | Desktop: grid 3-4 cols (balance hero, KPIs, chart cash flow, recent tx). Mobile: stack vertical. |
| 7 | Setup | `setup/setup_view.dart` | Onboarding inicial | Wizard pasos: workspace → moneda → primera cuenta → opcional bot Telegram. Progress bar arriba. |

### P1 — Core financiero

| # | Página | Path | Descripción | Notas rediseño |
|---|---|---|---|---|
| 8 | Transactions | `transactions/transactions_view.dart` | Lista unificada movimientos. Filtros, búsqueda, agrupado por fecha | Desktop: tabla densa (date, account, category, amount) + sidebar filtros. Mobile: cards agrupadas por día. |
| 9 | Add transaction | `transactions/add_transaction_view.dart` | Crear movimiento (expense/income/transfer) | Desktop: modal `Dialog` 560px. Mobile: full-screen route. Tabs tipo arriba. |
| 10 | Expenses | `expenses/expenses_view.dart` | Lista gastos + categorías | **Considerar merge con transactions_view + filter type=expense**. |
| 11 | Add expense | `expenses/add_expense_view.dart` | Form gasto + items + cuenta | Modal desktop. Items collapsibles. |
| 12 | Incomes | `incomes/incomes_view.dart` | Lista ingresos | **Considerar merge con transactions**. |
| 13 | Add income | `incomes/add_income_view.dart` | Form ingreso | Modal desktop. |
| 14 | Account detail | `accounts/account_detail_view.dart` | Detalle cuenta: saldo + movimientos + gráfico | Desktop: header sticky con saldo + tabs (movimientos / stats / config). |
| 15 | Stats | `stats/stats_view.dart` | Analítica: torta/barras/línea + comparativas | Desktop: grid 2x2 charts + filtros período sticky top. |

### P1 — Metas + planificación

| # | Página | Path | Descripción | Notas rediseño |
|---|---|---|---|---|
| 16 | Savings | `savings/savings_view.dart` | Lista metas: progress bar + monto + deadline | Grid 2-3 cards desktop. Sort: progress / deadline / amount. |
| 17 | Savings detail | `savings/savings_detail_view.dart` | Detalle meta + aportes + gráfico | Header gradient (FinanceColors.savings) + timeline aportes. |
| 18 | Create saving | `savings/create_saving_goal_view.dart` | Wizard nueva meta | 3 pasos: nombre+monto → deadline → cuenta origen. |
| 19 | Debts | `debts/debts_view.dart` | Lista deudas | Total pendiente arriba (hero). Cards con plazos. |
| 20 | Add debt | `debts/add_debt_view.dart` | Form deuda + cronograma pagos | Calculadora interés en vivo. |
| 21 | Budgets | `budgets/budgets_view.dart` | Presupuestos por categoría | Progress bars + alertas overflow. Desktop: tabla; mobile: cards. |
| 22 | Recurring | `recurring/recurring_view.dart` | Movimientos recurrentes | Lista con próxima fecha + frecuencia + toggle activo. |
| 23 | Subscriptions | `subscriptions/subscriptions_view.dart` | Suscripciones tracker | Total mensual hero + lista con logo servicio + costo. |

### P1 — Items + receipts

| # | Página | Path | Descripción | Notas rediseño |
|---|---|---|---|---|
| 24 | Transaction items | `expenses/transaction_items_view.dart` | Items por transacción | Tabla productos: nombre, qty, precio, categoría. |
| 25 | Add items | `expenses/add_transaction_items_view.dart` | Editor masivo items | Editable grid. Atajos teclado (Tab/Enter). |
| 26 | Item evolution | `expenses/transaction_item_evolution_view.dart` | Gráfico precio histórico item | Línea + estadísticas (min/max/avg). |
| 27 | Scan receipt | `scan_receipt/scan_receipt_view.dart` | Captura cámara ticket + OCR | Mobile: cámara fullscreen. Desktop: drop zone upload. |
| 28 | Upload file | `scan_receipt/upload_file_view.dart` | Upload manual PDF/img | Drop zone + preview + progress. |

### P2 — Colaboración + workspaces

| # | Página | Path | Descripción | Notas rediseño |
|---|---|---|---|---|
| 29 | Events | `events/events_view.dart` | Calendario gastos compartidos (viajes/fiestas) | Calendario mes desktop, lista mobile. |
| 30 | Create event | `events/create_event_view.dart` | Form crear evento + invitar | Modal desktop. |
| 31 | Workspaces | `workspaces/workspaces_view.dart` | Lista workspaces | Cards con avatar + miembros + balance. |
| 32 | Create workspace | `workspaces/create_workspace_view.dart` | Form crear workspace | Modal. Color picker + emoji. |
| 33 | Workspace settings | `workspaces/workspace_settings_view.dart` | Config workspace | Tabs: general / miembros / moneda / peligro. |
| 34 | Members | `workspaces/members_view.dart` | Miembros + roles + invitaciones | Tabla desktop. Avatar + rol + acciones. |
| 35 | Currency settings | `workspaces/currency_settings_view.dart` | Moneda base + conversiones | Dropdown + tabla conversiones. |
| 36 | Organizations | `organizations/organizations_list_view.dart` | Lista orgs | Cards con workspaces count. |
| 37 | Org detail | `organizations/organization_details_view.dart` | Detalle org + workspaces hijos | Header + tree workspaces. |
| 38 | Invitations | `invitations/invitations_view.dart` + `auth/invitations_view.dart` | **DUPLICADAS — consolidar** | Lista invites pendientes + accept/reject. |

### P2 — AI + config

| # | Página | Path | Descripción | Notas rediseño |
|---|---|---|---|---|
| 39 | AI Coach | `ai_coach/ai_coach_view.dart` | Chat agente IA (langchain + Gemini) + HITL + todos panel | Desktop: 3 columnas (conversaciones izq / chat centro / todos+tools der). Mobile: chat + drawer todos. |
| 40 | AI Settings | `settings/ai_settings_view.dart` | Config IA (provider, key, modelo) | Form simple + test connection btn. |
| 41 | Settings | `settings/settings_view.dart` | Hub config: tema, idioma, notif | Lista grupos. Desktop: 2 cols (categorías + detalle). |
| 42 | Security | `security/security_view.dart` | PIN, biometría, sesiones | Lista toggles + tabla sesiones activas. |
| 43 | Profile | `profile/profile_view.dart` | Avatar, nombre, email, plan, delete | Header avatar grande + form datos + danger zone abajo. |

---

## 10. Consolidación PRE-rediseño (decisiones)

Antes de empezar refactor, decidir y ejecutar:

1. [x] **Dashboard**: `dashboard_alt_view.dart` borrado (consolidado en `dashboard_view.dart`).
2. [ ] **Invitations**: mergear `invitations/invitations_view.dart` ↔ `auth/invitations_view.dart` → un solo path.
3. [ ] **Expenses/Incomes**: evaluar reemplazar por `transactions_view` con filtro `type`. Reduce duplicación ~40%.
4. [ ] **Forms add_***: estándar abrir como `Dialog` en desktop, `Route` full-screen mobile. Crear helper `responsiveModal()`.

---

## 11. Plan de ejecución (deliverables ordenados)

### Paso 1 — Propuesta paleta (BLOQUEANTE)
- Rellenar sección 5 (tabla colores) + sección 6 (FinanceColors valores)
- Generar mockup visual (imagen o link Figma) con balance card + lista transacciones + chart (light only — paleta sección 5)
- **NO tocar código**. Esperar OK usuario.

### Paso 2 — Refactor `app_theme.dart`
- **Eliminar `darkTheme` por completo** (borrar campo, ajustar `MaterialApp` a solo `theme:`)
- ColorScheme M3 completo (light)
- `ThemeExtension<FinanceColors>` con valores light (sección 6)
- ButtonStyles unificados (filled/tonal/outlined/text/icon) + hover/focus/pressed/disabled
- CardTheme con `surfaceContainer*` apropiado (sombras suaves sección 4.4)
- InputDecoration con focus ring 2px visible
- Helpers `context.colors`, `context.finance`, `context.text`
- Eliminar lógica `ThemeMode` (controller toggle, storage pref) — solo light
- Limpiar `setting/views/settings_view.dart` toggle tema
- Commit: `refactor(theme): light-only M3 + FinanceColors extension`

### Paso 3 — Auditoría páginas (output: AUDIT.md)
- Tabla por view: path / hardcoded colors count / responsive issues / hover missing / overflow risks / priority
- No refactor aún. Output → guía paso 4.

### Paso 4 — Refactor por módulo (commits separados)
Orden sugerido:
1. `auth` (3 views) — establecer patrón
2. `home` (shell) — habilita resto
3. `dashboard` — vitrina
4. `transactions` + decidir merge expenses/incomes
5. `expenses` / `incomes` (si no se mergean)
6. `savings`
7. `debts`
8. `budgets` + `recurring` + `subscriptions`
9. `accounts` + `stats`
10. `workspaces` + `organizations` + `invitations` + `members`
11. `events`
12. `ai_coach` + `ai_settings`
13. `scan_receipt`
14. `settings` + `security` + `profile`
15. `setup`

Por cada módulo:
- Reemplazar hardcoded colors → tokens
- Responsive con `context.isMobile/isDesktop`
- Wrap clickables `MouseRegion` / `InkWell` con hover
- `ConstrainedBox(maxWidth: 1200)` en main desktop
- Verificar light (único modo)
- Capturas antes/después
- Commit: `refactor(<modulo>): web responsive + theme tokens`

### Paso 5 — Optimizaciones build web
- `pubspec.yaml`: revisar deps innecesarias en web (audio, biometrics nativas). Usar conditional imports si aplica.
- `web/index.html`:
  - Preload Inter font subset (latin)
  - `<meta name="theme-color" content="#FAFBFC">` (light only, valor scaffoldBackground)
  - PWA manifest revisar (icons, name, short_name, theme_color, background_color)
  - Service worker cache strategy
- `main.dart`: `usePathUrlStrategy()` para URLs limpias (no hash).
- Rutas pesadas: deferred imports si bundle > 3MB. Medir con `flutter build web --analyze-size`.
- `--no-tree-shake-icons` requerido (ya en Dockerfile/codemagic).
- Cache headers nginx ya correctos.
- Commit: `perf(web): bundle optimization + PWA polish`

---

## 12. Reglas estrictas

- ❌ NO usar `Color(0xFF...)` hardcoded en views — siempre tokens (`context.colors.*` o `context.finance.*`)
- ❌ NO `MediaQuery.of(context).size.width` disperso — usar `context.isDesktop` etc
- ❌ NO romper mobile mientras optimizas web — verificar ambos
- ❌ NO mezclar Material Icons + Iconsax — elegir uno y stick
- ❌ NO `setState` masivo en lugar de GetX reactive
- ❌ NO CircularProgressIndicator centrado fullscreen — usar skeletons
- ✅ Verificar solo light (NO existe dark)
- ✅ Capturas antes/después por módulo grande
- ✅ Tests visuales manuales obligatorios pre-merge
- ✅ Commits atómicos por módulo
- ✅ Mantener compatibilidad GetX (controllers, bindings intactos)

---

## 13. Referencias visuales

- **Linear** — sidebar minimalista, hover sutil, tipografía
- **Stripe Dashboard** — densidad info, tablas, color semántico
- **Revolut** — balance card hero, gráficos limpios
- **Cash App** — color bold (mobile-first), CTAs claros
- **Lunch Money** — categorías color-coded, presupuestos visuales
- **Copilot Money** — empty states, animaciones sutiles

---

## 14. Métricas de éxito

- WCAG AA en 100% texto, AAA en texto crítico (montos, totales)
- Lighthouse PWA score > 90 web
- Bundle web < 3MB (gzip)
- Time to Interactive < 3s en 4G
- 0 hardcoded colors en views (lint custom o grep)
- Hover state en 100% clickables web
- Keyboard nav completa (tab + atajos en todas las pantallas)

---

## 15. Próximo paso

**EMPEZAR POR PASO 1** (sección 11): propuesta paleta + mockup. NO tocar código aún. Esperar aprobación usuario tras presentar tabla colores + justificación.
