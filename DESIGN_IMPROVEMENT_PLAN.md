# Ofix Design Improvement Plan

Date: 2026-05-24

Scope reviewed:

- `DESIGN_DETAILS.md` - currently empty
- `DESIGN.md`
- `AUDITED.md`
- `src/App.vue`
- `src/views/WelcomeView.vue`
- `src/views/DemandDashboard.vue`
- `src/views/OfferDashboard.vue`
- `src/views/ChatEscrowView.vue`
- `src/style.css`

## Executive Summary

Ofix already has a clear product idea: a local services marketplace with two mental models, `DEMANDA` for hiring help and `OFERTA` for offering technical services, wrapped around escrow trust. The current UI has strong personality through glass panels, warm earth tones, rounded controls, map simulations, badges, and detailed prototype data.

The main design risk is that the interface currently feels more decorative than operational. Many surfaces use the same glass-card treatment, long text blocks compete with primary actions, and trust-critical escrow steps are explained in paragraphs instead of being made obvious through status, hierarchy, and progressive disclosure. The improvement plan should preserve the warm Ofix identity while making dashboards denser, easier to scan, more accessible, and more task-oriented.

## Design Direction

Keep:

- Warm, local, trustworthy brand tone.
- Dual-mode identity: orange for client demand and green for provider offer.
- Rounded, tactile controls and approachable copy.
- Escrow as the core differentiator.
- Map privacy concept and approximate-location language.

Adjust:

- Reduce glassmorphism density in dashboards.
- Use fewer large cards and more structured work surfaces.
- Make active jobs, bids, contracts, escrow state, and next action immediately visible.
- Use color as a supporting signal, not the only signal.
- Replace decorative emphasis with stronger information hierarchy.

## Priority 1: Establish A Cleaner App Shell

### Problem

The dashboard views sit inside many repeated glass panels, and the top navigation competes visually with each screen header. On working screens, users need orientation and fast access to tasks more than decorative depth.

### Proposed Changes

- Convert the authenticated app shell into a stable work surface:
  - Fixed top app bar with logo, mode switch, active user, and logout.
  - Page title row directly below, with one primary action per view.
  - Sticky sidebar only on desktop for filters, task lists, or contract summaries.
- Reduce `glass-panel` usage for layout containers. Reserve glass treatment for:
  - Modal dialogs
  - Important status panels
  - Repeated item cards
  - Escrow trust widgets
- Use flatter section backgrounds for dashboards:
  - Main page background: `--bg-arena`
  - Content areas: opaque or near-opaque white/tinted panels
  - Glass only where it communicates "floating" or "secure"

### Expected Impact

- Dashboards feel more professional and easier to scan.
- The brand still feels premium, but task workflows become the primary focus.

## Priority 2: Redesign The Welcome View Around One Clear Conversion Path

### Current Issues

- Hero copy is strong but long.
- The mode selector appears after the primary CTA, so users may register before understanding the two roles.
- The feature cards explain the product, but they read like marketing content instead of a decision path.
- `DESIGN_DETAILS.md` is empty, so there are no additional landing constraints to honor yet.

### Proposed Layout

1. Header:
   - Logo left.
   - `Iniciar sesion` secondary action right.

2. Hero:
   - H1 focused on the product promise: safe local home services through escrow.
   - Short supporting sentence.
   - Primary CTA: `Crear cuenta`
   - Secondary CTA: `Explorar como cliente` / `Explorar como proveedor`

3. Role selection:
   - Two side-by-side role cards on desktop.
   - Each card should explain:
     - Primary job to be done
     - What happens first
     - Escrow benefit
   - Selecting a card should set the active mode directly, not toggle blindly.

4. Trust strip:
   - `Direccion protegida`
   - `Pago en garantia`
   - `Tecnicos verificados`
   - `Evidencia en chat`

5. How it works:
   - Three-step timeline that changes by selected role.
   - Avoid long paragraphs; use one sentence per step.

### Copy Improvements

- Replace abstract labels like `Conexion Local Activa` with outcome-based labels.
- Use `Pago protegido hasta terminar el trabajo` instead of repeatedly saying `Escrow` without context.
- Keep `Escrow` as a secondary technical label.

## Priority 3: Make Client Dashboard A Task Command Center

### Current Issues

- The client dashboard mixes three jobs in one screen:
  - Managing published tasks
  - Searching provider directory
  - Reviewing bids
- The selected task panel appears above the directory, which can push the directory out of view.
- Provider cards carry good detail, but the action hierarchy is weak: rating, response time, category, badges, price, and CTA compete.

### Proposed Information Architecture

Use tabs or segmented navigation inside the client dashboard:

- `Mis tareas`
- `Buscar tecnicos`
- `Mapa`

### `Mis tareas`

- Primary surface for active client work.
- Each task card should show:
  - Status
  - Title
  - Budget
  - Number of bids
  - Next action
  - Urgency
- Selecting a task opens a right-side details panel on desktop and a full-screen sheet on mobile.
- Bids should be compared in a structured table/card layout:
  - Provider
  - Rating
  - Arrival
  - Amount
  - Verification
  - CTA: `Aceptar y fondear garantia`

### `Buscar tecnicos`

- Treat provider search as a directory:
  - Search input at top.
  - Filter chips below search.
  - Results as compact professional cards.
- Provider cards should prioritize:
  - Name and availability
  - Trade/category
  - Rating and completed jobs
  - Estimated response time
  - Starting rate
  - One primary action: `Ver perfil`
  - One secondary action: `Contratar`

### Publish Task Modal

- Convert the long form into a two-step flow:
  - Step 1: Task details and budget
  - Step 2: Location privacy and urgency
- Add a right-side or bottom summary:
  - `Tu direccion exacta no se comparte hasta que fondees la garantia.`
- Make budget optional visually, but explain what happens if omitted.

## Priority 4: Make Provider Dashboard A Work Queue

### Current Issues

- The provider view has useful pieces but lacks prioritization between available work, active contracts, and profile setup.
- Filters occupy a lot of sidebar space.
- Job cards use long descriptions and large visual treatment, making it harder to compare opportunities.
- The profile configuration modal includes identity verification, bio, fee, and category in one dense flow.

### Proposed Information Architecture

Use three clear areas:

- Work queue: nearby jobs and map/list toggle.
- Active contracts: jobs already accepted or pending deposit.
- Profile health: verification, category, rate, response quality.

### Job Feed Cards

Make each job card compact and comparison-friendly:

- Title
- Category
- Budget
- Distance
- Urgency
- Existing bids
- Approximate zone
- CTA: `Revisar`

Move long job descriptions into the details modal.

### Job Details Modal

Use a clear hierarchy:

1. Job summary
2. Privacy-protected location
3. Client budget and urgency
4. Competition and distance
5. Proposal form

The proposal form should show a generated starting proposal as a draft, but visually communicate that the provider should edit it before sending.

### Profile Modal

Split into sections:

- Public profile
- Pricing and category
- Identity verification
- Trust signals

Add a profile completion indicator:

- `70% completo`
- Missing: `Identificacion`, `Biografia`, `Tarifa`

## Priority 5: Redesign Chat Escrow Around Status And Next Action

### Current Issues

- Chat, payment, address unlock, route, review, and completion all live in one view, but the escrow state is not visually dominant enough.
- The right escrow panel explains important trust behavior in text-heavy blocks.
- Payment simulation fields look like real disabled card inputs, which may confuse test users.

### Proposed Layout

Top status bar:

- Contract name
- Amount
- Escrow state
- Next required action

Main layout:

- Left: chat and evidence.
- Right: contract status timeline.

Escrow timeline states:

1. `Acuerdo creado`
2. `Esperando deposito`
3. `Garantia fondeada`
4. `Direccion liberada`
5. `Trabajo terminado`
6. `Fondos liberados`
7. `Resena enviada`

### Role-Specific CTAs

Client:

- Pending deposit: `Fondear garantia`
- Funded: `Liberar pago`
- Completed: `Calificar`

Provider:

- Pending deposit: disabled status, `Espera el deposito antes de salir`
- Funded: `Avisar que voy en camino` and `Marcar terminado`
- Completed: status-only confirmation

### Chat Improvements

- Add a compact contract summary above messages.
- Show evidence photos as attachments with thumbnails and labels.
- Separate system events from user messages:
  - `Garantia fondeada`
  - `Direccion liberada`
  - `Trabajo marcado como terminado`

## Priority 6: Normalize Design Tokens And Component Rules

### Current Issues

- `DESIGN.md` specifies hero title at `46px`, but `WelcomeView.vue` overrides it to `62px` with negative letter spacing.
- Several scoped view styles duplicate layout utilities already present in `style.css`.
- Radii are larger than typical operational UI needs, especially for dashboards.
- The app uses ambient orbs, which make the design feel branded but can reduce the work-focused feel.

### Proposed Token Adjustments

- Keep existing brand tokens, but add operational tokens:
  - `--surface-base`
  - `--surface-raised`
  - `--surface-muted`
  - `--border-subtle`
  - `--shadow-card`
  - `--shadow-modal`
- Add semantic status tokens:
  - `--status-open`
  - `--status-pending`
  - `--status-funded`
  - `--status-completed`
  - `--status-urgent`
- Reduce dashboard card radius to `8px` or `12px`, while preserving larger radii for marketing and modal surfaces.
- Use `--sunset-orange-dark` for text on light backgrounds.
- Keep bright orange only for fills, accents, and decorative highlights.

### Component Rules

- Primary buttons: one per region, one clear action.
- Secondary buttons: neutral, lower visual weight.
- Badges: short status labels only.
- Cards: repeated entities only, not page sections.
- Modals: one task per modal, split long workflows into steps.
- Maps: interactive controls should have labels and selected states.

## Priority 7: Improve Mobile Responsiveness

### Current Issues

- Desktop grids collapse to one column, but long cards, large hero text, and modal content can still feel heavy on mobile.
- Sidebars become stacked content, increasing scroll distance before the main task.
- Large pill buttons and labels can overflow when text grows.

### Proposed Mobile Behavior

- Welcome:
  - Reduce hero height.
  - Use role cards before long feature explanations.
  - Use compact CTAs.
- Dashboards:
  - Convert filters to a bottom sheet or collapsible panel.
  - Put primary content before secondary lists.
  - Use sticky bottom CTA for publish, bid, or fund actions when inside detail flows.
- Chat:
  - Chat first, escrow status as collapsible summary.
  - Payment and completion CTAs sticky at bottom.
- Modals:
  - Full-screen sheets on narrow screens.
  - Keep close action and title sticky.

## Priority 8: Visual Trust And Safety Enhancements

### Current Issues

- Trust is mostly described through paragraphs, badges, and escrow labels.
- The app needs stronger reassurance at decision points: publishing a location, accepting a bid, funding escrow, and releasing payment.

### Proposed Trust Patterns

- Add a reusable `TrustNotice` component for:
  - Location privacy
  - Payment protection
  - Identity verification
  - Evidence storage
- At every money or address moment, show:
  - What is shared now
  - What stays private
  - What happens next
- Make escrow status visual:
  - Stepper
  - Amount locked
  - Release condition
  - Responsible party

## Implementation Roadmap

### Phase 1: Design Foundation

- Populate `DESIGN_DETAILS.md` with current product assumptions, users, and view goals.
- Normalize tokens in `src/style.css`.
- Define reusable component patterns for buttons, badges, cards, modals, status notices, and empty states.
- Align implementation with the existing `AUDITED.md` accessibility findings.

### Phase 2: App Shell And Navigation

- Simplify authenticated app shell.
- Make mode switching explicit and keyboard-accessible.
- Add view-level tabs for client and provider dashboards.
- Reduce top-level glass panel nesting.

### Phase 3: Client Workflow

- Redesign client dashboard around `Mis tareas`, `Buscar tecnicos`, and `Mapa`.
- Convert publish-task modal into a stepped flow.
- Improve bid comparison and acceptance flow.

### Phase 4: Provider Workflow

- Redesign provider dashboard as a work queue.
- Compact job cards.
- Restructure proposal modal.
- Add profile completion and verification status.

### Phase 5: Escrow Chat

- Add escrow status timeline.
- Separate system events from chat messages.
- Clarify role-specific next actions.
- Improve evidence attachment presentation.

### Phase 6: Responsive And Validation Pass

- Test at mobile, tablet, and desktop breakpoints.
- Run keyboard-only checks.
- Run contrast and screen reader checks from `AUDITED.md`.
- Validate text overflow in Spanish labels and long user-generated content.

## Success Metrics

- A new user can choose the correct role in under 10 seconds.
- A client can publish a task without uncertainty about address privacy.
- A client can compare bids without opening every provider profile.
- A provider can identify the best nearby job from the list view without reading full descriptions.
- Both roles can identify the escrow state and next action at a glance.
- Mobile users can complete publish, bid, chat, and escrow actions without excessive scrolling.

## Suggested First Sprint

1. Fill `DESIGN_DETAILS.md` with product goals and view responsibilities.
2. Simplify dashboard shell and remove unnecessary glass nesting.
3. Add dashboard tabs for client and provider workflows.
4. Create a reusable escrow status/timeline component.
5. Convert publish task and profile setup into stepped flows.
6. Apply the critical accessibility fixes from `AUDITED.md` while touching these surfaces.
