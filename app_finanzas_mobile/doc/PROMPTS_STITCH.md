# Prompts Google Stitch — FinVault

Cada prompt va listo para pegar en Google Stitch (o cualquier text-to-UI). Si el módulo tiene mobile + desktop, hay dos prompts.

---

## 0. Sistema de diseño compartido (pegar como contexto previo si Stitch lo soporta)

```
Design system: FinVault — premium fintech app, LIGHT MODE ONLY.

Palette:
- Primary violet: #7C3AED, hover/dark: #630ED4, container bg: #EDE9FE.
- Surface: #FFFFFF, page bg: #F8FAFC, soft container: #F1F0FB.
- Border: #EDEAF6, input border: #E2E0F7, hairline: #F1F0FB.
- Text on surface: #1A1C1C, secondary: #4A4455, hint: #7B7487.
- Income / positive: #059669 (emerald 600), expense / negative: #DC2626 (red 600).
- Warning / events: #F59E0B, AI: #8B5CF6, info / bank: #3B82F6.

Typography: Inter. Headlines tight (-0.5px letter-spacing), weights 600/700. Body 14-16px, weight 400-500.

Shape & elevation:
- Radius: chips 999, inputs 12, cards 16, modals 20.
- Shadow violet glow on hero cards: 0 20px 50px -12px rgba(99,14,212,0.08).
- Atmospheric: radial #7C3AED 6% center, two blob blurs top-left + bottom-right.

Layout:
- Mobile <1024px: single column, bottom nav, padded 16px.
- Desktop >=1024px: sidebar 260px + content max 1280px, padding 32px.

Mood: clean, airy, premium. Linear (light) + Mercury + Ramp references. Never dark.
```

---

# P1 — CORE FINANCIERO

## 1. Dashboard (audit / refresh)

### Mobile
```
Mobile dashboard for FinVault personal finance app, light fintech style.

Top app bar: workspace pill (avatar 24px + name + chevron) on left, notification bell + user avatar 32px on right.

Hero balance card: violet #7C3AED gradient bg, white text, 24px padding, radius 20. Top row: label "BALANCE TOTAL" letter-spacing 1.5px + currency segmented toggle (USD / VES / EUR). Big number 42px weight 700. Below: monthly net change with up/down arrow + percentage, color emerald or red.

KPI grid 2 columns: two glass tiles (radius 16, border #EDEAF6, white bg). Each tile: icon 36 in tinted square (emerald for income, red for expense), label "Ingresos" / "Gastos" 12px, value 22px weight 700, sub-text vs last month.

Quick actions row: 3 horizontal pill buttons (Gastos / Presupuestos / Ahorros), each with icon + label, pill bg #F1F0FB, icon violet.

Accounts panel: section header "MIS CUENTAS" + "Ver todas" link violet. Card list: each row = bank icon round 40, account name + last 4 digits, balance right aligned.

Weekly flow chart: card radius 16, header "Flujo semanal", bar chart 7 bars (Mon-Sun), violet bars for net positive, red for negative, faded grid lines.

Recent transactions: section header + "Ver todas" link. List of 4 transactions, each = category icon round 36 tinted, name + category small, amount right colored (green/red).

Bottom nav floating: pill bg white, radius 28, shadow violet 10%, 5 items (Dashboard / Stats / Add+ violet circle / Coach / Settings).
```

### Desktop
```
Desktop dashboard for FinVault, light fintech style, 1280px max width.

Top bar: title "Dashboard" 28px weight 700 + search input 320px + bell + user pill (avatar + name + chevron).

Hero balance card full-width: violet gradient bg, padded 32. Left side: BALANCE TOTAL label + 56px number + currency conversion pills (EUR / VES with live rate). Right side: net monthly KPI + tiny sparkline.

KPI row 4 horizontal cards: Ingresos / Gastos / Ahorros / Disponible. Each card radius 16 border #EDEAF6, 24 padding, icon top-left tinted square, label 13px, value 24px weight 700, trend percent.

Grid 2 columns (2/3 + 1/3):
LEFT 2/3:
- Weekly Flow chart card 16 radius, height 320, bar chart 7 bars + legend.
- Recent transactions table: columns Fecha | Categoría | Cuenta | Monto, zebra rows, hover violet 5%.
RIGHT 1/3:
- Accounts panel: 4 account cards stacked, each with logo + name + balance.
- Quick actions: 3 vertical buttons (Añadir gasto / Transferir / Ajustar).
- AI tip card: small violet glow, sparkle icon, AI insight text + "Hablar con Coach" link.

Sidebar persistent 260px on left: FinVault logo + "Nueva Transacción" violet CTA + nav items grouped Principal / Finanzas / Herramientas / Cuenta.
```

---

## 2. Stats / Analytics

### Mobile
```
Mobile stats screen for FinVault, light fintech.

Top bar: back arrow + "Estadísticas" + filter icon.

Period selector: pill row 3 options (Semana / Mes / Año), active violet bg + white text.

Headline KPI card: white bg, padded 20, label "GASTOS DEL MES", big 36px violet number, comparison vs last month chip below.

Donut chart card: 240 height, 6 categories color-coded, center label total + currency, right side legend list (color dot + name + percent).

Top categories list: 5 cards horizontal, each = category icon 40 tinted bg, name, amount, progress bar fraction of total.

Trend line chart card: dual-line income vs expense, x-axis weeks, y-axis amount, emerald + red.

Heatmap card: spending intensity calendar grid month view, violet shades.
```

### Desktop
```
Desktop stats / analytics for FinVault, light fintech, grid 2x2.

Sticky top filters: period selector + workspace selector + export CSV button.

Grid 2x2 charts (24 gap):
- Top-left: donut chart with category breakdown, legend right.
- Top-right: line chart income vs expense over 12 months.
- Bottom-left: bar chart top 10 categories descending.
- Bottom-right: stacked area chart by account.

Below grid: full-width table "Detalle por categoría" with columns Categoría / Gastado / Presupuesto / % usado / Tendencia (sparkline). Sortable headers.

Sidebar persistent left.
```

---

## 3. Transactions (lista)

### Mobile
```
Mobile transactions list for FinVault, light fintech.

Top: search bar pill bg #F8FAFC + filter icon button (radius 12 border).

Filter chips horizontal scroll: Todos / Ingresos / Gastos / Transferencias / Esta semana. Active violet pill.

Date group sections: section header date "Hoy", "Ayer", "Esta semana" #7B7487 letter-spaced.

Transaction row: card radius 12 white border #EDEAF6, 56 height, padded 16. Layout: category icon round 40 tinted left, middle text (merchant name 14 weight 600 + category 12 #7B7487), right amount color +emerald or -red 16 weight 700.

Swipe actions: red delete + violet edit.

FAB bottom-right: violet circle 56, icon plus, shadow violet 35%.
```

### Desktop
```
Desktop transactions table for FinVault, light fintech.

Top toolbar: search input 400px + filter chips + period dropdown + "Nueva transacción" violet button.

Sidebar filters left 240px: account multi-select, category list checkboxes, amount range slider, type radio.

Main table: columns Fecha | Descripción | Categoría chip | Cuenta | Monto. Header sticky, sort icons. Rows 52 height, hover bg #F8FAFC, click expands inline detail.

Bulk actions: when rows checked, floating action bar bottom: "Etiquetar", "Categorizar", "Eliminar".

Pagination footer + total count.
```

---

## 4. Add Transaction (modal/route)

### Mobile fullscreen
```
Mobile add transaction screen for FinVault, light fintech.

Top: cancel text-button left + "Nuevo gasto" title + save icon right.

Type segmented top: 3 options (Gasto / Ingreso / Transferencia), selected pill violet bg.

Amount hero: bg #F1F0FB radius 20, padded 32 center. Currency symbol 28 violet + amount 56 weight 700. Numpad below custom: 4 rows, soft white buttons radius 16, last row = decimal + delete + ok violet.

Fields card list:
- Categoría: row with icon + name + chevron, tap opens picker bottom sheet.
- Cuenta: same pattern.
- Fecha: same with calendar icon.
- Descripción: input with pen icon.
- Adjuntar foto: button outlined violet "Escanear ticket".

Bottom fixed: violet CTA "Guardar" 56 height + radius 14.
```

### Desktop modal
```
Desktop add transaction modal for FinVault, light fintech, 560px wide, radius 20, white bg, shadow violet 10%.

Header: title "Nueva transacción" + close X.

Tabs row: Gasto / Ingreso / Transferencia, active underline violet 2px.

2-column grid inside modal:
LEFT:
- Amount big input violet 36 with currency symbol prefix.
- Date picker calendar input.
- Category dropdown with icon prefix.
RIGHT:
- Account dropdown.
- Description textarea 3 rows.
- "Adjuntar comprobante" outlined dashed dropzone.

Footer: "Cancelar" text-button + "Guardar" violet 12 radius 14.
```

---

## 5. Expenses (lista)

```
Mobile expenses screen for FinVault, light fintech.

Top: "Gastos" title + period dropdown chip.

Total spent hero: red gradient soft card radius 20, label "Gastado este mes" + amount 42 weight 700, sub "X% más vs mes anterior" with arrow.

Categories grid 2 cols: each card 16 radius white border, category icon tinted, name, amount, mini progress bar to budget limit, warning chip if over.

Recent expenses list below: same row pattern as transactions but red amounts.

FAB violet "Nuevo gasto".
```

```
Desktop expenses for FinVault, light fintech.

Layout 2/3 + 1/3:
LEFT: 
- Hero red gradient card with total spent + comparison.
- Bar chart top 10 categories.
- Table latest expenses sortable.
RIGHT:
- Filter sidebar: categories checkboxes, accounts, amount slider.
- Budget alerts panel: list of categories over 80% with progress bars.
```

---

## 6. Incomes (lista)

```
Mobile incomes screen for FinVault, light fintech.

Top: "Ingresos" title + period dropdown.

Total earned hero: emerald gradient soft card, label "Ingresos del mes" + amount 42 weight 700, sub "vs mes anterior" arrow.

Income sources grid 2 cols: each card radius 16 white, source icon (briefcase = salary, dollar = freelance, gift = bonus), name, amount, frequency chip (Mensual / Quincenal / Único).

Recent incomes list emerald amounts.

FAB violet "Nuevo ingreso".
```

```
Desktop incomes for FinVault, light fintech, similar to expenses pattern but emerald accent.

Hero emerald gradient + chart bar income by source + table.

Sidebar: filter by source, recurring vs one-time, account destination.
```

---

## 7. Budgets

```
Mobile budgets screen for FinVault, light fintech.

Top: "Presupuestos" + period dropdown + add button.

Summary card: total presupuesto vs gastado, big progress ring 120px center violet, label percent inside, total amounts top.

Budget cards list: each card radius 16 white border, category icon + name top, big amount progress bar 8px height (color = violet if under, amber 60-90%, red over), spent / total amounts, days remaining chip right.

Alert section if any over budget: red banner top.

FAB violet "Nuevo presupuesto".
```

```
Desktop budgets for FinVault, light fintech.

Top KPIs: 4 chips total budget / spent / remaining / alerts count.

Table layout: Categoría | Presupuesto | Gastado | Restante | Progreso (bar) | Acciones. Sortable, click row expands sparkline trend last 6 months.

Right panel: budget recommendations card (AI) with violet glow + auto-suggest CTA.
```

---

## 8. Savings (metas)

```
Mobile savings screen for FinVault, light fintech.

Top: "Mis Metas" + add button.

Big total saved card: emerald gradient, total ahorrado + meta total, progress ring 120 center.

Goals grid 2 cols: each card radius 16 white border, emoji or icon big top-left, goal name, target amount + saved amount, progress bar emerald, days/months left chip, "Aportar" mini button.

Empty state: illustration violet + "Crea tu primera meta" CTA.
```

```
Desktop savings overview for FinVault, light fintech.

Grid 3 cols of goal cards same pattern, hover lift + violet glow.

Right panel: AI suggestion "Podrías ahorrar X cambiando Y" + "Aplicar" button.

Sticky header total saved + add goal CTA.
```

---

## 9. Saving detail

```
Saving goal detail for FinVault, light fintech, mobile + desktop.

Header section: large goal emoji/illustration on emerald gradient bg, goal name 28 weight 700, target amount.

Progress ring big center: 200px circle, percent inside, saved / target below.

Quick action row: "Aportar" violet CTA + "Retirar" outlined + "Ajustar meta" text.

Timeline list of contributions: date + amount + source account.

Projection chart: line predicting goal completion date based on average contribution.

Settings card bottom: deadline, monthly target, alerts toggle.
```

---

## 10. Create savings goal (wizard)

```
3-step wizard create savings goal for FinVault, light fintech.

Step 1: "¿Qué quieres lograr?" — input goal name + emoji picker + target amount big violet input.
Step 2: "¿Cuándo?" — date picker for deadline + auto-calculate monthly target chip.
Step 3: "¿Desde dónde?" — origin account picker + monthly auto-transfer toggle.

Top step pills + back/next bottom bar, light theme.
```

---

## 11. Debts

```
Mobile debts screen for FinVault, light fintech.

Top: "Deudas" + add button.

Total pending card: red gradient soft, total deuda 42 weight 700, próximo pago chip with date.

Debts grid 1 col cards: each card radius 16 white border, lender icon + name, current balance + original amount, progress bar (paid/total) red→emerald, next due date + amount, "Pagar" mini violet CTA.

Color rule: overdue red border, due-soon amber, on-track default.

FAB violet "Nueva deuda".
```

```
Desktop debts for FinVault, light fintech.

Table view: Acreedor | Deuda actual | Mensualidad | Próximo pago | Progreso | Acciones.

Charts top: total deuda evolution line chart + pie distribution by lender.

Right panel: calculator simulation "Si pagas X más al mes terminas en Y meses".
```

---

## 12. Add debt

```
Add debt form for FinVault, light fintech.

Sections collapsible:
1. Datos básicos: acreedor name + tipo (Tarjeta / Préstamo / Hipoteca / Personal) chips + monto inicial + saldo actual.
2. Términos: tasa interés % input + plazo meses + cuota mensual auto-calc.
3. Cronograma: visual amortization table + total intereses + total a pagar.

Live calculator preview on right (desktop) or sticky bottom (mobile).

Bottom: "Crear deuda" violet CTA.
```

---

## 13. Recurring movements

```
Recurring movements screen for FinVault, light fintech.

Top: "Recurrentes" + add button.

Tabs: Activos / Pausados / Todos.

Cards list each row: icon + name + amount, frequency badge (Diario / Semanal / Mensual), next date, toggle active/paused right.

Group by frequency or category options chip.

FAB violet add new.
```

---

## 14. Subscriptions

```
Subscriptions tracker for FinVault, light fintech.

Top: "Suscripciones" title.

Hero card: total mensual amount + count of active subscriptions + "Ver gasto anual" link.

Cards grid 2 cols: service logo (Netflix / Spotify / etc.) + name + monthly price + next renewal date chip + cancel link.

Add subscription FAB violet.

Empty state: illustration + "Conecta tu correo para detectar suscripciones".
```

---

## 15. Account detail

```
Account detail screen for FinVault, light fintech.

Header sticky: account icon + name + bank + balance huge 42 weight 700, gradient violet bg.

Tabs row: Movimientos / Estadísticas / Configuración.

Movimientos tab: transactions list filtered by this account, group by date.

Estadísticas tab: charts in/out, monthly average, balance evolution line.

Configuración tab: name input, type chips, color picker, archive toggle, delete danger.
```

---

# P1 — ITEMS + RECEIPTS

## 16. Transaction items

```
Transaction items screen for FinVault, light fintech.

Top: "Detalle de compra" + scanner icon button right.

Receipt header: merchant name + date + total amount + payment method chip.

Items table: Producto | Cantidad | Precio unitario | Subtotal. Compact rows, alternating bg.

Totals footer: subtotal + impuestos + total bold.

Actions: "Editar items" violet CTA + "Compartir" outlined.
```

---

## 17. Add items (editor)

```
Bulk items editor for FinVault, light fintech.

Editable grid: 4 columns Producto / Cantidad / Precio / Categoría. Keyboard shortcuts hint top: Tab next, Enter new row.

Each row: text input producto, numeric qty, currency price, dropdown category.

Sticky bottom: totals + save violet CTA.

Mobile: same but vertical stacked rows with drag handle reorder.
```

---

## 18. Item evolution

```
Item price evolution chart for FinVault, light fintech.

Header: product name + current price + change percent badge.

Big line chart 320 height, 12 months x-axis, price y-axis, violet line + emerald min point + red max point dots.

Stats row: min / max / avg / current 4 KPI cards.

Purchase history list below: date + store + price + diff vs previous.
```

---

## 19. Scan receipt

```
Mobile scan receipt for FinVault, light fintech.

Camera fullscreen viewfinder + ticket guide rectangle overlay violet outline + flash toggle + flip camera.

Bottom controls: gallery thumbnail + shutter button violet 80px circle + retry icon.

After capture: preview screen with "OCR en proceso" violet spinner + extracted items list editable below + "Guardar" CTA.
```

```
Desktop scan receipt for FinVault, light fintech.

Big dropzone center: dashed violet border radius 20, icon receipt 80px, "Arrastra tu ticket aquí" + "o haz click para subir" link.

Right preview pane after upload: image preview + OCR extracted fields editable.

CTA "Procesar" violet.
```

---

# P2 — COLABORACIÓN

## 20. Events (calendar of shared expenses)

```
Mobile events screen for FinVault, light fintech.

Top: "Eventos" + add button.

Active events cards horizontal scroll: each card radius 16 violet gradient soft, event emoji + name + dates + total gastado + members avatars stack 3-5.

Past events list below: simpler card with name + total + close icon.

FAB violet add event.
```

```
Desktop events calendar for FinVault, light fintech.

Top: month nav arrows + "+" add event.

Calendar grid month view: days cells, event dots colored, hover shows event chips.

Right panel selected event detail: name, dates, members, total spent, breakdown by category, settle up CTA.
```

---

## 21. Create event

```
Create event modal for FinVault, light fintech.

Fields:
- Event name + emoji picker.
- Date range picker.
- Type chips (Viaje / Fiesta / Casa / Proyecto).
- Currency picker.
- Members multi-select with search + invite by email.
- Budget optional.

CTA "Crear evento" violet.
```

---

## 22. Workspaces list

```
Workspaces list for FinVault, light fintech.

Header: "Mis Workspaces" + create button.

Cards grid 2-3 cols: each workspace card radius 16 white border, workspace avatar/emoji top-left, name + type chip, members count + total balance, "Entrar" CTA.

Default workspace badge violet.

FAB / button create.
```

---

## 23. Create workspace

```
Create workspace modal for FinVault, light fintech.

Step 1: name input + emoji/color picker.
Step 2: type chips (Personal / Familiar / Negocio).
Step 3: currency picker + initial accounts.

Live preview card right side mirroring choices.

CTA violet "Crear workspace".
```

---

## 24. Workspace settings

```
Workspace settings for FinVault, light fintech.

Tabs sidebar (desktop) or top tabs (mobile): General / Miembros / Moneda / Categorías / Peligro.

General: name input, emoji, description, default toggle.

Miembros: list with avatar + role chip (Owner / Admin / Member / Viewer), invite by email, transfer ownership.

Moneda: base currency dropdown + conversion table editable.

Categorías: full CRUD list of categories with color/icon.

Peligro: archive workspace + delete with confirmation.
```

---

## 25. Members + roles

```
Members management for FinVault, light fintech.

Top: "Miembros" + invite button.

Search input + role filter.

Table desktop / cards mobile: avatar + name + email + role dropdown + last active + 3-dot menu (transfer / kick).

Invitations pending section: email + role + status chip (Pendiente / Aceptada / Rechazada) + resend button.
```

---

## 26. Currency settings

```
Currency settings for FinVault, light fintech.

Section base currency: big chip dropdown + flag icon.

Conversion table: 6 currencies row, current rate, manual override toggle, last updated.

Auto-update toggle + source (BCV / Open Exchange Rates / Manual).

Live preview: "1 USD = X" card with primary currency.
```

---

## 27. Organizations list

```
Organizations list for FinVault, light fintech.

Cards grid: each org card with name + workspaces count + members count + total assets.

Switch active org button per card.

FAB create new org.
```

---

## 28. Org detail

```
Organization detail for FinVault, light fintech.

Header: org name + edit pen + members avatars stack.

Tree view of workspaces children: indented list with expand/collapse, totals per branch.

KPIs row: total orgs assets + total members + active workspaces.

Settings link bottom.
```

---

## 29. Invitations

```
Invitations screen for FinVault, light fintech.

Tabs: Recibidas / Enviadas.

Recibidas list cards: org/workspace logo + inviter name + role offered chip + accept violet CTA + reject ghost button.

Enviadas list: email + status chip + resend + cancel.

Empty states with violet illustration.
```

---

# P2 — AI + CONFIG

## 30. AI Coach chat

```
Mobile AI Coach chat for FinVault, light fintech.

Top: avatar coach (violet circle with sparkle icon) + "Coach" + clear conversation button.

Chat area: alternating bubbles. Bot bubble white border #EDEAF6 radius 16 + sparkle small avatar. User bubble violet bg + white text, right-aligned.

Action chips inside bot messages: "Mostrar gastos", "Crear meta" — tap shoots structured action.

Bottom: input pill bg white border + mic icon + send violet circle.

Pending HITL approval card: yellow ribbon + "Aprobar" + "Rechazar" buttons.
```

```
Desktop AI Coach 3 columns for FinVault, light fintech.

LEFT 280px: conversations history list + new chat violet CTA.

CENTER: chat area same bubble pattern, scroll, input bar bottom.

RIGHT 320px: tabs Todos / Tools / Context. Todos panel = task list bot generated with checkboxes. Tools = list of available actions. Context = current workspace info + relevant data shown to AI.
```

---

## 31. AI Settings

```
AI Settings for FinVault, light fintech.

Sections:
- Provider: chip selector (Gemini / OpenAI / Claude) + connection status dot.
- API Key: password input with show/hide + test connection button.
- Model: dropdown (Pro / Flash / Ultra).
- Temperature: slider 0-1.
- Features toggles: "Sugerencias proactivas", "Análisis automático recibos", "Alertas inteligentes", "HITL para acciones críticas".

Footer: "Probar configuración" violet outlined.
```

---

## 32. Settings hub

```
Settings hub for FinVault, light fintech.

Mobile: vertical list of category cards (Cuenta / Notificaciones / Privacidad / IA / Apariencia / Conexiones / Soporte / Acerca de). Each row icon tinted + name + chevron right.

Desktop: 2-column layout, LEFT 280 sidebar with categories, RIGHT detail panel with selected category form.

User profile card top: avatar 64 + name + email + plan badge violet.
```

---

## 33. Security

```
Security view for FinVault, light fintech.

Sections:
- PIN: toggle "Bloquear app con PIN" + change PIN button.
- Biometría: toggle Face ID / Touch ID with platform icon.
- Sesiones activas: table device + location + last active + revoke link.
- Histórico: login attempts table with success/fail chips.
- Danger: cerrar todas sesiones + eliminar cuenta.

Use red accents for destructive actions, violet for primary toggles.
```

---

## 34. Profile

```
Profile view for FinVault, light fintech.

Header centered: avatar circle 120px with edit pen overlay, name 28 weight 700, email below, plan badge violet "Premium" or "Free".

Form fields card: nombre input, email read-only with verified check, teléfono, idioma dropdown, zona horaria.

Stats row 3 cards: cuentas / workspaces / días en FinVault.

Danger zone bottom card red border: "Eliminar mi cuenta" outlined red.
```

---

# COMPONENTES COMPARTIDOS

## 35. Empty state component

```
Empty state component for FinVault, light fintech.

Centered: illustration 160px (violet abstract orbit + small ghost dots), title 18 weight 600 #1A1C1C, description 14 #4A4455 line-height 1.5, CTA violet button.

Variants: "No hay datos", "Sin conexión", "Acceso denegado", "Error".
```

## 36. Loading skeleton

```
Loading skeleton component for FinVault, light fintech.

Soft shimmer animation #F1F0FB → #FFFFFF → #F1F0FB.

Variants: card skeleton (radius 16, padded), list-row skeleton (avatar circle + 2 lines), chart skeleton (axis lines + bars), KPI skeleton (icon + value + sub).
```

## 37. Toast / Snackbar

```
Snackbar toasts for FinVault, light fintech.

Pill radius 12, padded 16, shadow.

Variants:
- Success: emerald icon check, white bg, emerald left border 3px.
- Warning: amber icon, white bg.
- Error: red icon, white bg.
- Info: violet icon sparkle, white bg.
- AI: violet glow shadow + sparkle.

Slide-in from bottom mobile, top-right desktop.
```

## 38. Modal sheet

```
Modal sheet for FinVault, light fintech.

Mobile bottom sheet: radius top 24, drag handle 36x4 #EDEAF6, white bg, padded 24, max 80% screen height.

Desktop centered dialog: 480-720 wide, radius 20, white bg, shadow violet 10%, padded 32.

Header: title 20 weight 700 + close X icon top-right.

Footer sticky bottom: cancel ghost + primary violet CTA.
```

## 39. Filter sidebar

```
Filter sidebar component for FinVault, light fintech.

Width 260, white bg, border-right #EDEAF6, padded 20.

Sections collapsible:
- Categorías checkboxes with icons.
- Cuentas multi-select.
- Rango fechas date pickers.
- Monto range slider violet.
- Tipo radio buttons.

Bottom sticky: "Limpiar" ghost + "Aplicar" violet CTA + active count badge.
```

## 40. Category picker

```
Category picker bottom sheet / popover for FinVault, light fintech.

Search input top.

Grid 4 cols of category tiles: icon round 48 tinted bg, name 12 below, tap to select.

Grouped sections: Frecuentes / Gastos / Ingresos / Inversiones.

Create new category link bottom: "+ Crear categoría" violet.
```

## 41. Currency selector

```
Currency selector component for FinVault, light fintech.

Pill input with flag emoji + code + chevron, opens popover with list of currencies (flag + code + name) searchable.

Selected item check violet on right.
```

## 42. Date range picker

```
Date range picker for FinVault, light fintech.

Trigger pill input with calendar icon + "Últimos 30 días" label.

Popover: 2 month calendar side-by-side desktop / 1 month mobile, range highlight bg violet 10%, edges violet bold, today dot.

Quick chips top: Hoy / Esta semana / Este mes / Últimos 30 / Personalizado.

Footer: aplicar violet CTA.
```

## 43. Data table

```
Data table component for FinVault, light fintech.

Header row: sticky, bg #F8FAFC, text 12 weight 600 #7B7487 uppercase letter-spacing 0.5px, sort chevrons.

Body rows: 52 height, border-bottom #EDEAF6, hover bg #F8FAFC, click row violet bg 5%.

Cells: text 14 #1A1C1C.

Pagination footer: page numbers + per page selector + total count.

Empty state row + loading skeleton variants.
```

## 44. Sidebar menu / Nav rail

```
Sidebar persistent menu for FinVault, light fintech.

Width 260 expanded / 64 collapsed.

Header: FinVault logo violet square + name + toggle collapse arrow.

Org name secondary text small + chevron to switch.

"Nueva Transacción" violet CTA button.

Nav grouped: PRINCIPAL (Dashboard, Stats, AI Coach), FINANZAS (Ingresos, Gastos, Presupuestos, Ahorros, Deudas, Suscripciones), HERRAMIENTAS (Transacciones, Recurrentes, Eventos, Workspaces), CUENTA (Mi Perfil, Organización, Ajustes).

Each item: icon 19 + label 13. Active: bg #EDE9FE + text + icon violet + 5px dot right. Hover: bg #F8FAFC.
```

## 45. Bottom navigation

```
Bottom nav for FinVault mobile, light fintech.

Floating pill radius 28, bg white, border #EDEAF6, shadow violet 10%, margin 16 sides + 16 bottom, padded 20 x 12.

5 items: Dashboard icon, Stats icon, ADD violet circle 52 with shadow, Coach icon, Settings icon.

Active item: icon violet, bg #EDE9FE circle 40 behind.

Inactive: icon #7B7487.
```

---

# USO

Copia el bloque **Sistema de diseño compartido (§0)** primero como contexto en Stitch, luego copia el prompt específico de la vista que vas a generar. Si Stitch permite seed images, sube los screenshots `doc/diseno/Loguin - rgistro- onboarding/*/screen.png` como referencia visual de paleta + tono.

Para coherencia: genera primero los **Componentes compartidos (§§35-45)** y úsalos como librería de referencia antes de las vistas grandes.

---

# BATCH 2 — Prompts pendientes prioritarios

Generados a partir de auditoría 2026-05-30. Cada bloque incluye contexto de datos reales del controller para que Stitch entienda qué campos animar.

## 46. Add Transaction — Modal (mobile fullscreen + desktop dialog)

Reemplaza `lib/modules/transactions/views/add_transaction_view.dart` + `lib/core/widgets/transactions/add_transaction_modal.dart`. Conecta a `TransactionsController` (`amountString`, `selectedType`, `selectedCategoryId`, `selectedDate`, `note`, `selectedImage`, `submitTransaction()`, `appendDigit/deleteDigit/clearAmount`).

### Mobile (fullscreen route)
```
Mobile add transaction screen for FinVault, light fintech, fullscreen.

Top sticky bar 64px height, white bg + bottom border #EDEAF6: left = "Cancelar" text-button #4A4455, center title "Nueva transacción" 16px weight 700 #1A1C1C, right = "Guardar" filled button violet 36px height pill radius 12.

Type segmented control top, bg #F1F0FB radius 999 padding 4px, three pill tabs equal width: Gasto / Ingreso / Transferencia. Active pill = bg #7C3AED + text white weight 700 + shadow violet 25%. Inactive = transparent + text #4A4455 500.

Amount hero card: bg #F1F0FB radius 24 padding 32 center, label "MONTO" letter-spacing 1.5 weight 700 #7B7487, big amount line below: currency symbol "$" 28px weight 600 violet on left + amount 56px weight 800 violet center letter-spacing -1. Subtle helper text below if zero: "Toca para escribir" 12px hint.

Custom numpad below (replaces system keyboard): 4 rows of 3 keys each. Keys = white bg radius 16 height 60 + shadow soft, text 22px weight 600 #1A1C1C. Row 1: 1 2 3. Row 2: 4 5 6. Row 3: 7 8 9. Row 4: . 0 ← (backspace icon). Last row has decimal point + zero + backspace. Tap = scale 0.95 + haptic.

Fields list section below numpad, white bg radius 16 border #EDEAF6 padding 16:
- Row 1 "Categoría": left avatar 36 round violet 10% + category icon, text "Comida" weight 600, right chevron #7B7487. Tap opens bottom sheet category picker (grid 4-col).
- Row 2 "Cuenta": same pattern, "Cuenta Principal".
- Row 3 "Fecha": calendar icon left, "Hoy, 30 May 2026", right chevron.
- Row 4 "Descripción": pen icon left, free text input collapsed, hint "Añade una nota".
- Row 5 "Adjuntar comprobante": dashed border outlined, icon receipt_long + text "Escanear o subir ticket" violet. If image already selected, show 80x80 thumbnail with X overlay top-right to remove.

Sticky bottom (no scaffold bottom-nav, this is fullscreen): primary CTA "Guardar transacción" 56 height pill radius 14 violet + shadow 35%. Loading state = circular spinner inside.
```

### Desktop (centered dialog)
```
Desktop add transaction dialog for FinVault, light fintech, 720px wide, radius 20, white bg, shadow violet 10%, padded 32. Backdrop blurred dark 30%.

Header row: title "Nueva transacción" 22 weight 700 #1A1C1C + close X icon top-right 24px.

Tabs row 3 tabs (Gasto / Ingreso / Transferencia) with underline active state violet 2px, text 14 weight 600. No background pills on desktop — just bottom underline.

2-column grid form, gap 24:

LEFT column:
- Amount big input: label "MONTO" small uppercase + violet input 48px height with $ prefix violet 28px weight 700 + amount input 32px weight 800. Background #F8FAFC radius 12 border #E2E0F7 focus violet ring.
- Date picker: label "FECHA" + input pill with calendar icon + "30 May 2026" text + chevron. Click opens popover calendar.
- Category dropdown: label "CATEGORÍA" + select with icon prefix (category icon) + name + chevron. Click opens dropdown with grid of categories.

RIGHT column:
- Account dropdown: label "CUENTA" + select with bank icon + "Cuenta Principal" + balance hint.
- Description textarea: label "DESCRIPCIÓN (OPCIONAL)" + 4-row textarea radius 12 border #E2E0F7 placeholder hint.
- Attach receipt dropzone: dashed border #E2E0F7 radius 16 padded 24, center icon receipt + text "Arrastra un ticket o haz click para subir" + small "JPG, PNG hasta 5MB" hint. If image attached, show preview + remove X.

Footer sticky bottom right: "Cancelar" ghost text-button #4A4455 + "Guardar transacción" violet button 14px weight 700 + shadow.

Keyboard shortcuts hint top-right corner small: "⌘ + Enter para guardar" 11px #7B7487.
```

---

## 47. Expenses (lista) — mobile + desktop

Reemplaza `lib/modules/expenses/views/expenses_view.dart`. Controller esperado: `ExpensesController` con `transactions` filtrado type='expense', `loadExpenses`, KPIs `totalThisMonth`, `totalLastMonth`, categories breakdown. Si no existe controller, agrupa de `TransactionsController.transactions.where(t => t.type == 'expense')`.

### Mobile
```
Mobile expenses screen for FinVault, light fintech.

Top header 64 white + bottom border #EDEAF6: title "Gastos" weight 700 + period dropdown chip right (radius 999 bg #F1F0FB "Este mes" + chevron).

Hero red gradient card: gradient red 600 to red 500 + soft, radius 24 padded 24, label "GASTADO ESTE MES" letter-spacing 1.4 weight 700 white 80% opacity, big amount 42 weight 800 white, sub row: arrow up/down icon + "+12% vs mes anterior" white 80%.

Categories grid 2 cols gap 12: each card white radius 16 border #EDEAF6 padding 14:
- Category icon round 36 tinted bg (each color from chart palette)
- Name 13.5 weight 700 #1A1C1C
- Amount 12 weight 600 #4A4455
- Mini progress bar 4px height to budget limit (if budget exists), violet under / amber warning / red over
- If over budget: small chip "Sobre" 10px weight 700 red

"ÚLTIMOS GASTOS" section label 11px letter-spacing 1.4 weight 700 #7B7487 + "Ver todos" link violet right.

Expenses list cards same pattern as TransactionsView row (icon round 40 + name/category + amount red right).

FAB bottom-right violet 56 circle "Nuevo gasto" with shadow.
```

### Desktop
```
Desktop expenses screen for FinVault, light fintech, content area only (sidebar handled by shell).

Header row: title "Gastos" 32 weight 700 + period dropdown right + "Nuevo gasto" violet button.

Hero row: 2-col grid:
- LEFT (2/3): red gradient card "Gastado este mes" + big amount 56 + comparison vs last month + small line chart sparkline 7 days
- RIGHT (1/3): "Alertas presupuestos" card list of categories over 80% with progress bars + "Ver presupuestos" link

Bar chart card full-width: "Top 10 categorías" horizontal bar chart descending, x-axis amount, y-axis category names left, bars colored from violet to lighter shades.

Below: 2-col gap 20:
- LEFT (2/3): Table "Últimos gastos" columns Fecha | Concepto | Categoría chip | Cuenta | Monto. Sortable. Click row expands inline detail with receipt thumbnail if exists.
- RIGHT (1/3): "Filtros rápidos" sidebar — categorías checkboxes scrollable + accounts checkboxes + amount range slider + apply violet btn.
```

---

## 48. Incomes (lista) — mobile + desktop

Reemplaza `lib/modules/incomes/views/incomes_view.dart`. Controller: `IncomesController` con `transactions` filtrado type='income' + `incomePlans` (esperados recurrentes).

### Mobile
```
Mobile incomes screen for FinVault, light fintech.

Top header 64 white + bottom border: title "Ingresos" weight 700 + period dropdown chip + add button right.

Hero emerald gradient card: gradient emerald 600 to emerald 500 soft, radius 24 padded 24, label "RECIBIDO ESTE MES" weight 700 white 80%, big amount 42 weight 800 white, sub "+8% vs mes anterior" with up arrow.

"FUENTES DE INGRESO" section label + "Ver todas" link.

Income sources grid 2 cols cards: each card white radius 16 border #EDEAF6 padded 14:
- Source icon round 36 emerald 10% bg with briefcase (salary) / handshake (freelance) / gift (bonus) / dividends icon
- Source name 13.5 weight 700
- Amount 14 weight 800 emerald
- Frequency chip below: pill bg #F1F0FB "Mensual" / "Quincenal" / "Único" 10px weight 600 #4A4455

"ÚLTIMOS INGRESOS" section label + list of transaction rows emerald amounts.

FAB bottom-right violet "Nuevo ingreso".
```

### Desktop
```
Desktop incomes screen for FinVault, light fintech, content area only.

Header: title "Ingresos" 32 weight 700 + period dropdown + "Nuevo ingreso" violet button.

Top KPI row 4 cards equal: Total recibido / Promedio mensual / Fuentes activas / Próximo ingreso (with date chip). Each KPI card pattern from §1 dashboard.

Grid 2-col gap 20:
- LEFT (2/3): "Ingresos por fuente" stacked bar chart 12 months, legend bottom showing each source color.
- RIGHT (1/3): "Próximos ingresos recurrentes" list cards — each row = source icon + name + amount emerald + days remaining chip.

Below: Table "Movimientos de ingreso" columns Fecha | Fuente | Cuenta destino | Frecuencia chip | Monto emerald. Sortable + filter by source dropdown header.
```

---

## 49. Savings (metas) — mobile + desktop

Reemplaza `lib/modules/savings/views/savings_view.dart`. Controller: `SavingsController` con `goals` (name, target, saved, deadline).

### Mobile
```
Mobile savings goals screen for FinVault, light fintech.

Top header: "Mis Metas" weight 700 + add button violet right.

Hero card emerald gradient soft: "AHORRADO TOTAL" + big amount 42 weight 800 + "Meta global $X" + center progress ring 100px emerald.

Goals grid 2 cols cards: each white radius 16 border #EDEAF6 padded 16:
- Top: emoji or icon 32 + 3-dot menu top-right
- Name 14 weight 700
- "$saved / $target" amounts
- Progress bar emerald 6px height
- Days/months left chip below (color: emerald if on track, amber if tight, red if late)
- "+ Aportar" mini button violet outlined

Empty state if no goals: illustration ahorro + violet CTA "Crea tu primera meta".

FAB violet "Nueva meta".
```

### Desktop
```
Desktop savings overview for FinVault, light fintech.

Header: "Mis Metas" 32 + total saved chip + "Nueva meta" violet button.

Top KPI row: Total ahorrado / Metas activas / Meta más cercana / Promedio mensual.

Grid 3 cols of goal cards same pattern as mobile but larger (radius 16 padded 24, hover lift + violet glow + scale 1.02). Each card includes target deadline chip + monthly required amount.

Right floating panel: "AI Sugiere" violet glow card with sparkle icon + "Podrías ahorrar X cambiando Y" + "Aplicar" CTA.

Bottom: "Próximos hitos" timeline horizontal showing next 3 deadlines with dates + progress markers.
```

---

## 50. Debts (deudas) — mobile + desktop

Reemplaza `lib/modules/debts/views/debts_view.dart`. Controller: `DebtsController` con `debts` (lender, original, balance, monthlyPayment, nextDue, interestRate).

### Mobile
```
Mobile debts screen for FinVault, light fintech.

Top header: "Deudas" weight 700 + add button violet right.

Total pending card red soft: "DEUDA TOTAL" + big amount 42 weight 800 red 600 + "Próximo pago en X días" chip below.

Debts list cards stacked: each white radius 16 border colored by status (overdue red 2px / due-soon amber 2px / on-track #EDEAF6 1px):
- Top row: lender icon round 40 + lender name 14 weight 700 + balance amount 14 weight 800 right red
- Progress bar showing paid/total: red → emerald fill
- "$paid de $original" sub text
- Bottom row: next payment date chip + "Pagar" mini violet CTA

FAB violet "Nueva deuda".
```

### Desktop
```
Desktop debts management for FinVault, light fintech.

Header: "Deudas" 32 + "Nueva deuda" violet button.

KPI row 4 cards: Total pendiente red / Cuota mensual / Próximo pago / Tasa promedio.

Charts row 2-col:
- Line chart "Evolución total deuda" 12 months violet line going down ideally
- Pie chart "Distribución por acreedor" violet shades

Table "Detalle de deudas" columns Acreedor | Deuda actual | Mensualidad | Próximo pago | Progreso bar | Tasa | Acciones. Sortable. Click expands row with amortization preview.

Right floating calculator card: "Simulador de pago extra" — input "Pago adicional mensual" + result "Terminas en X meses, ahorras $Y en intereses" + "Aplicar a deuda" dropdown.
```

---

## 51. Subscriptions — mobile + desktop

Reemplaza `lib/modules/subscriptions/views/subscriptions_view.dart`. Controller: `SubscriptionsController` con `subscriptions` (name, amount, billingCycle, nextRenewal, logo, category).

### Mobile
```
Mobile subscriptions tracker for FinVault, light fintech.

Top header: "Suscripciones" + add button violet.

Hero card violet soft gradient: "MENSUAL TOTAL" + big amount 42 + sub "Anual: $X" + "X suscripciones activas" chip.

Cards grid 2 cols: each card white radius 16 border #EDEAF6 padded 14:
- Service logo 36x36 round (Netflix red / Spotify green / Disney+ blue / generic violet) or initials avatar tinted
- Service name 14 weight 700
- Monthly price 12 weight 600
- Next renewal chip: "Renueva en 5d" or "Renueva el 15 Jun"
- Cancel link bottom small red

Empty state: illustration + "Detecta tus suscripciones conectando tu correo" + CTA violet.

FAB violet add new.
```

### Desktop
```
Desktop subscriptions for FinVault, light fintech.

Header: "Suscripciones" 32 + "Detectar automáticamente" outlined + "Nueva suscripción" violet.

KPI row: Total mensual / Total anual / Activas / Próximas renovaciones esta semana.

Grid 3 cols cards same pattern, hover lift + violet ring on hover.

Right panel timeline: "Renovaciones próximas" calendar view next 30 days with service dots on day cells. Click dot = popover with service details + cancel option.

Bottom chart: "Gasto histórico suscripciones" 12 months stacked area by service.
```

---

## 52. Recurring movements — mobile + desktop

Reemplaza `lib/modules/recurring/views/recurring_view.dart`. Controller: `RecurringController` con `movements` (name, amount, type, frequency, nextDate, active).

```
Mobile recurring screen for FinVault, light fintech.

Top header: "Recurrentes" weight 700 + add button violet.

Tabs sticky below header: pill segmented "Activos / Pausados / Todos" same pattern as Stats period selector.

Cards list each row white radius 14 border #EDEAF6 padded 14:
- Left: type icon round 36 (emerald for income / red for expense)
- Middle: name 14 weight 700 + amount 13 weight 600 colored
- Right column: frequency badge "Mensual" pill #F1F0FB 10px + next date "5 Jun" 11px hint
- Far right: toggle switch active/paused (when off, card opacity 60%)

Group by frequency option chip top: "Agrupar por frecuencia" toggle.

FAB violet add new.
```

```
Desktop recurring for FinVault, light fintech.

Header: "Movimientos recurrentes" 32 + "Nuevo recurrente" violet button.

Tabs sticky below: same 3 tabs.

Table layout: Tipo icon | Nombre | Categoría chip | Monto colored | Frecuencia badge | Próxima fecha | Activo switch | Acciones (edit/delete). Sortable.

Right panel timeline: "Próximas 30 días" vertical timeline with date markers + recurring item cards aligned.

Bottom KPI strip: total ingresos recurrentes / total gastos recurrentes / flujo neto recurrente / próximo pago + amount.
```

---

## 53. AI Coach chat — mobile + desktop

Reemplaza `lib/modules/ai_coach/views/ai_coach_view.dart`. Conecta a langchain conversation, HITL approvals, todos panel.

### Mobile
```
Mobile AI Coach chat for FinVault, light fintech.

Top sticky header 64: avatar coach round 36 violet bg with sparkle icon + "Coach" 16 weight 700 + 3-dot menu right (clear / settings / help).

Welcome card if no messages: violet soft card centered with sparkle 64 icon + greeting "¡Hola! Soy tu coach financiero" + 3 suggested prompts as pills (Crea una meta / Analiza mis gastos / Predice mi balance).

Chat scroll area:
- Bot bubble: white bg radius 16 border #EDEAF6 padded 14, alignment left, max-width 80%, with small avatar sparkle 28 round violet to the left top.
- User bubble: violet 600 bg + white text, radius 16 (top-right corner sharper), padded 14, alignment right, max-width 80%.
- Inline action chips inside bot bubble: pill outlined violet text "Mostrar gastos" / "Crear meta" — tap fires structured action.
- Thinking state: bot bubble with 3 animated dots violet pulsing.

HITL approval card variant: yellow ribbon top "Acción pendiente de aprobación", card white border amber, action description + diff preview + "Aprobar" violet CTA + "Rechazar" ghost button.

Bottom input bar sticky: pill bg white border #E2E0F7 radius 999 padded 12, mic icon left + text input + send violet circle 36 right (or stop button when streaming).
```

### Desktop
```
Desktop AI Coach 3-column for FinVault, light fintech.

LEFT 280px: "Conversaciones" header + "Nueva" violet btn + search input + list of past chats (each row: title 13 weight 600 + last message preview 11 hint + relative time 10).

CENTER: chat area same bubble pattern as mobile but max-width 720px centered. Sticky input bar bottom.

RIGHT 320px: tabs at top "Todos / Tools / Contexto":
- Todos tab: AI-generated task list with checkboxes (e.g. "Revisar presupuesto Comida", "Crear meta vacaciones"), each row checkbox + text + small "marcar hecho" link.
- Tools tab: list of available actions cards (Create transaction / Generate report / Set alert / etc.) with icon + name + "Ejecutar" link.
- Contexto tab: snapshot card with current workspace + active goals + recent transactions count + "Refrescar" link. Helps user see what AI sees.
```

---

## 54. Settings hub + AI Settings + Security + Profile

Reemplazan `settings_view.dart` + `ai_settings_view.dart` + `security_view.dart` + `profile_view.dart`.

### Settings hub
```
Settings hub for FinVault, light fintech.

Mobile:
- Header "Ajustes" sticky.
- User card top: avatar 56 round + name 16 weight 700 + email 12 hint + plan badge violet "Premium" / "Free".
- Categories vertical list cards: each row icon 36 tinted bg + name 14 weight 600 + sub-label 12 hint + chevron right. Categories: Cuenta / Notificaciones / Privacidad e IA / Apariencia / Conexiones / Soporte / Acerca de.
- Tap row = navigate to detail page.

Desktop:
- 2-col layout: LEFT 280 sidebar with category list (active row violet bg + border-right 4px primary). RIGHT detail panel with selected category form (white card max-width 720 padded 32).
- Top: same user card centered max-width 720 with edit pen.
```

### AI Settings
```
AI Settings detail page for FinVault, light fintech.

Sections cards each radius 16 border #EDEAF6 padded 24:

Card 1 "Proveedor":
- Chip row Gemini / OpenAI / Anthropic (active filled violet).
- Connection status: green dot "Conectado" / red dot "Sin conexión".

Card 2 "API Key":
- Password input with eye toggle.
- "Probar conexión" outlined violet button + result chip.

Card 3 "Modelo":
- Dropdown Pro / Flash / Ultra.
- Temperature slider 0-1 with violet track.

Card 4 "Funciones":
- 4 toggle rows: "Sugerencias proactivas" / "Análisis automático recibos" / "Alertas inteligentes" / "HITL para acciones críticas".
- Each toggle = switch active violet.

Footer: "Restablecer" ghost + "Guardar cambios" violet primary.
```

### Security
```
Security view for FinVault, light fintech.

Top section "Acceso":
- Toggle "Bloquear app con PIN" → if on, "Cambiar PIN" link below.
- Toggle "Face ID / Touch ID" with platform icon.

Section "Sesiones activas":
- Table desktop / cards mobile: device icon + name (Chrome on Windows / iPhone) + location/IP + last active relative time + "Revocar" red text link.

Section "Histórico de accesos":
- Table: date + device + IP + result chip (Success emerald / Failed red).

Section "Zona peligrosa" red border:
- "Cerrar todas las sesiones" red outlined.
- "Eliminar mi cuenta permanentemente" red filled with confirmation modal flow.
```

### Profile
```
Profile view for FinVault, light fintech.

Header centered:
- Avatar circle 120 with violet glow border + pen edit overlay bottom-right.
- Name 28 weight 700.
- Email 14 hint + verified check icon emerald.
- Plan badge violet "Premium" / outlined "Free".

Form card centered max-width 640:
- Nombre input.
- Email read-only with verified icon.
- Teléfono input with country code prefix.
- Idioma dropdown (es / en).
- Zona horaria dropdown.

Stats row 3 mini cards: Cuentas activas / Workspaces / Días en FinVault. Each card icon + count + label.

Danger zone bottom card red border padded 20:
- "Eliminar mi cuenta" outlined red full-width.
```

---

## 55. Workspaces + Organizations + Invitations + Members

Reemplaza `lib/modules/workspaces/views/*` + `organizations/*` + `invitations/*`.

### Workspaces list (mobile + desktop)
```
Workspaces screen for FinVault, light fintech.

Mobile:
- Header "Mis Workspaces" + add button violet.
- Cards grid 1 col stacked: each white radius 16 border #EDEAF6 padded 16:
  - Workspace avatar emoji 48 + name 16 weight 700 + type chip (Personal / Familiar / Negocio) colored
  - "X miembros • $balance total" sub
  - "Entrar" violet CTA
  - If current workspace: violet ring 2px border + "Activo" badge
- FAB violet add.

Desktop:
- Header + add button.
- Cards grid 3 cols same pattern, hover lift.
- Side filter: search + type filter chips + sort dropdown.
```

### Create workspace (wizard 3 steps)
```
Create workspace wizard for FinVault, light fintech.

Pattern: modal desktop 560 wide / fullscreen mobile.

Step 1 "Identidad":
- Emoji picker row (12 emoji grid) + custom emoji input.
- Color picker row (6 violet shades).
- Name input.

Step 2 "Tipo":
- 3 selectable cards (Personal / Familiar / Negocio) — copy from onboarding workspace step pattern.

Step 3 "Moneda y cuentas":
- Currency dropdown.
- Initial accounts checklist: "Efectivo" / "Cuenta bancaria" / "Tarjeta crédito" — checked items create accounts.

Live preview right side desktop: workspace card showing live updates as user fills form.

Footer: Back + Continue + final "Crear workspace" violet.
```

### Workspace settings (tabs)
```
Workspace settings for FinVault, light fintech.

Tabs row: General / Miembros / Moneda / Categorías / Zona peligrosa.

General tab:
- Workspace name input + emoji picker.
- Description textarea.
- "Establecer como predeterminado" toggle.

Miembros tab:
- Search bar + invite by email button.
- Table desktop / cards mobile: avatar + name + email + role dropdown (Owner / Admin / Member / Viewer) + last active + 3-dot menu.
- Pending invitations section below: email + role + status chip + resend.

Moneda tab:
- Base currency big dropdown + flag.
- Conversion table editable: 6 currencies + manual override toggle per row.
- Auto-update toggle + source select (BCV / Open Exchange / Manual).

Categorías tab:
- CRUD list: each row icon + name + color picker + edit + delete.
- "Restaurar predeterminadas" link bottom.

Peligro tab (red accents):
- "Archivar workspace" outlined red.
- "Eliminar workspace" filled red with confirmation modal.
```

### Organizations list + detail
```
Organizations for FinVault, light fintech.

List view:
- Header "Organizaciones" + create button.
- Cards 2 cols: org name + workspaces count + members count + total assets + "Cambiar a activa" CTA.
- Active org has violet ring.

Detail view:
- Header: org name + edit pen + members avatars stack (5 max + N more).
- KPI row: workspaces count / members count / total assets / monthly volume.
- Tree view of workspaces (indented, expand/collapse).
- Settings link bottom.
```

### Invitations
```
Invitations for FinVault, light fintech.

Tabs: Recibidas / Enviadas.

Recibidas:
- Cards list: org/workspace logo + inviter name "Juan te invitó a..." + role chip + accept violet CTA + reject ghost.
- Empty state with illustration if none.

Enviadas:
- List: email + role + status chip (Pendiente amber / Aceptada emerald / Rechazada red) + resend + cancel.
- Search bar top.
```

---

## 56. Scan Receipt + Upload File

Reemplaza `lib/modules/scan_receipt/views/*`.

### Mobile scan
```
Mobile scan receipt for FinVault, light fintech.

Camera fullscreen view with viewfinder overlay rounded violet rectangle (target zone for ticket). Top: flash toggle + close X. Bottom controls: gallery thumbnail picker left + shutter big violet 80 circle center + flip camera right.

After capture: preview screen sliding up — image preview top half + scrollable extracted items list bottom with editable fields (merchant, date, total, items table). "Guardar como transacción" violet CTA bottom + "Volver a tomar" outlined.

OCR processing state: dimmed overlay + "Analizando ticket..." with sparkle spinner + estimated time "<3s".
```

### Desktop upload
```
Desktop upload file for FinVault, light fintech.

Big dropzone center: dashed violet border radius 24, padding 64, icon receipt_long 80 violet, headline "Arrastra tu ticket aquí" + sub "o haz click para seleccionar archivo" link violet. Accepts PNG/JPG/PDF.

Sidebar right after upload (sliding panel): image preview top + OCR extracted form below with all editable fields (merchant / date / category dropdown / total / items table). Save violet CTA bottom + cancel ghost.

History list left: "Tickets recientes" — thumbnails 60x60 with status chip (Procesado / Pendiente / Error).
```

---

## 57. Events (gastos compartidos)

Reemplaza `lib/modules/events/views/*`.

### Mobile
```
Mobile events for FinVault, light fintech.

Header "Eventos" + add button.

Active events horizontal scroll cards (top): each card 280 wide violet gradient soft, emoji big + event name + date range + total spent + members avatars stack 3 + 2 more.

"PASADOS" section label + simpler list cards each row: emoji + name + date + total + close icon if archivable.

Empty state with illustration + violet CTA "Crea tu primer evento".

FAB violet add.
```

### Desktop
```
Desktop events calendar for FinVault, light fintech.

Header + create button.

Layout 2-col:
- LEFT 2/3: calendar month view grid 7-col, events shown as colored dots on day cells, hover popover with event summary.
- RIGHT 1/3: "Eventos próximos" list cards stacked with avatars + countdown chip.

Bottom: selected event detail panel sliding up — name, dates, members, total spent breakdown by category pie + settle-up calculation showing who owes whom.
```

### Create event
```
Create event modal for FinVault, light fintech, 560 wide desktop / fullscreen mobile.

Fields stacked:
- Emoji picker row + event name input.
- Date range picker (start + end).
- Type chips: Viaje / Fiesta / Casa / Proyecto / Otro.
- Currency selector.
- Members multi-select: chips with avatars + invite by email link + "Solo yo" toggle.
- Optional budget input.

Footer: Cancel + "Crear evento" violet.
```

---

# OPORTUNIDADES DETECTADAS (audit 2026-05-30)

Cosas para mejorar mientras rediseñas (no son views nuevas, son mejoras a flujos existentes):

| Problema | Fix sugerido |
|---|---|
| Numpad custom en AddTransactionView dificulta input rápido en desktop | Usar TextField nativo en desktop, numpad solo en mobile |
| `TemplatesGrid` widget huérfano tras rewrite TransactionsView | Borrar o reintegrar como "Plantillas rápidas" en `_MobileTransactions` antes del listado |
| Snackbars no light-themed | Auditar `SnackbarService` para usar paleta violet + colores semánticos consistentes |
| Modal "Workspace selector" del dashboard probablemente dark | Refactor a light pattern modal usando `_lightDialog` helper de `budgets_controller.dart` |
| Dialogs en otros controllers (savings/debts/incomes/expenses) probablemente dark | Extraer `_lightDialog` + `_lightAmountInput` + `_lightInputDecoration` a `core/widgets/dialogs/light_dialog.dart` y reusar |
| Iconos por categoría duplicados en 3 vistas (`_iconForTx`, `_iconForBudget`, `_iconForCategory`) | Extraer a `core/utils/category_icons.dart` |
| Charts CustomPainters duplicados (`_RingPainter`, `_DonutPainter`, `_LineChartPainter`, `_AreaPainter`) | Extraer a `core/widgets/charts/` para reuso en Savings/Debts |
| Período selector duplicado entre StatsView y TransactionsView | Extraer a `core/widgets/period_selector.dart` |
| Empty states duplicados con variantes ligeras | Componente `EmptyState({icon, title, subtitle, ctaLabel, onCta})` en core |
| FAB extended + FAB redondo duplicados | Componente `core/widgets/violet_fab.dart` con variantes |
| Active workspace null → views renderizan blanco sin mensaje | Wrapper "RequireWorkspace" que muestre empty + "Crear workspace" CTA |
| Browser tab title se cambia tras login (de "FinVault" → controller del current view) | Documento title hook por route en `GetMaterialApp.routingCallback` |

Recomendado refactor wave después del batch de views: componentes compartidos primero, reduce LOC ~30% en próximas vistas.
