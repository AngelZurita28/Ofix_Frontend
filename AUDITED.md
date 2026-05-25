# Accessibility Audit - OfiixFrontend

Date: 2026-05-24

Scope reviewed:

- `index.html`
- `src/App.vue`
- `src/views/WelcomeView.vue`
- `src/views/DemandDashboard.vue`
- `src/views/OfferDashboard.vue`
- `src/views/ChatEscrowView.vue`
- `src/style.css`

Method:

- Static code review against WCAG 2.2 A/AA guidance from the `accessibility` skill.
- Checked view templates, form markup, custom controls, modal behavior, icon buttons, image alternatives, focus styling, color contrast, motion, and keyboard operability.
- No browser, screen reader, Lighthouse, or axe run was performed in this pass.

## Executive Summary

The app has a good accessibility baseline in a few areas: `index.html` declares `lang="es"`, most primary actions use native `<button>` elements, many images include `alt`, and form fields are visually labeled.

However, the current views are not WCAG 2.2 AA ready. The most important blockers are keyboard-inaccessible clickable `<div>` controls, labels that are not programmatically associated with form fields, removed/missing focus indicators, custom modals without dialog semantics or focus management, and multiple icon-only controls without accessible names.

## Priority Findings

### Critical: Non-keyboard clickable controls

Impact: Keyboard and switch-device users cannot operate several important workflows.

WCAG:

- 2.1.1 Keyboard
- 2.4.3 Focus Order
- 4.1.2 Name, Role, Value

Examples:

- `src/App.vue:23` brand logo is a clickable `<div>`.
- `src/App.vue:29` mode switch is a clickable `<div>`.
- `src/views/WelcomeView.vue:136` landing mode switch is a clickable `<div>`.
- `src/views/WelcomeView.vue:356` and `src/views/WelcomeView.vue:366` role cards are clickable `<div>` elements.
- `src/views/DemandDashboard.vue:181` task sidebar cards are clickable `<div>` elements.
- `src/views/DemandDashboard.vue:422` map pins are clickable `<div>` elements.
- `src/views/OfferDashboard.vue:185` contract cards are clickable `<div>` elements.
- `src/views/OfferDashboard.vue:334` privacy map circles are clickable `<div>` elements.

Recommended fix:

- Convert clickable cards, switches, logo actions, and pins to native `<button type="button">` where possible.
- For true radio-like choices, use native radio inputs or `role="radiogroup"` with real buttons and `aria-pressed`.
- If a non-native element is unavoidable, add `role="button"`, `tabindex="0"`, and Enter/Space keyboard handlers.

### Critical: Form labels are not programmatically connected

Impact: Screen readers may not announce labels for inputs, selects, and textareas.

WCAG:

- 1.3.1 Info and Relationships
- 3.3.2 Labels or Instructions
- 4.1.2 Name, Role, Value

Examples:

- `src/views/WelcomeView.vue:292`, `307`, `322`, `337`
- `src/views/DemandDashboard.vue:207`, `220`, `462`, `475`, `484`, `497`, `517`, `530`, `642`, `654`, `667`
- `src/views/OfferDashboard.vue:208`, `222`, `237`, `415`, `428`, `439`, `477`, `488`, `499`, `515`
- `src/views/ChatEscrowView.vue:202`, `210`, `216`, `355`, `370`

Recommended fix:

- Add stable `id` attributes to each form control and matching `for` attributes to labels.
- For grouped controls such as role selection, star rating, and urgency checkboxes, use `<fieldset>` and `<legend>`.
- Add `autocomplete` attributes to login/register fields, for example `email`, `current-password`, `new-password`, `name`, and `tel`.

### Critical: Focus indicators are removed or incomplete

Impact: Keyboard users can lose track of focus.

WCAG:

- 2.4.7 Focus Visible
- 2.4.11 Focus Not Obscured
- 1.4.11 Non-text Contrast

Examples:

- `src/style.css:197` removes outline from inputs inside `.pill-input`.
- `src/style.css:505` removes outline from range inputs.
- `src/views/WelcomeView.vue:675` and `src/views/WelcomeView.vue:686` remove focus outlines from close buttons.
- `src/views/DemandDashboard.vue:1142` and `src/views/OfferDashboard.vue:915` remove outlines from range sliders.
- There is no global `:focus-visible` replacement for buttons, links, custom controls, or map pins.

Recommended fix:

- Add a global focus style such as:

```css
:where(button, a, input, select, textarea, [tabindex]):focus-visible {
  outline: 3px solid var(--accent-text);
  outline-offset: 3px;
}

:where(button, a, input, select, textarea, [tabindex]) {
  scroll-margin-top: 96px;
  scroll-margin-bottom: 96px;
}
```

- Remove local `outline: none` rules unless they are replaced with an accessible `:focus-visible` style.

### Critical: Modals lack dialog semantics and focus management

Impact: Screen reader and keyboard users may not know a modal opened, may tab behind it, and may not have focus restored after closing.

WCAG:

- 2.1.2 No Keyboard Trap
- 2.4.3 Focus Order
- 2.4.7 Focus Visible
- 4.1.2 Name, Role, Value

Examples:

- `src/views/WelcomeView.vue:260`
- `src/views/DemandDashboard.vue:449`, `553`, `629`
- `src/views/OfferDashboard.vue:360`, `464`
- `src/views/ChatEscrowView.vue:340`

Recommended fix:

- Add `role="dialog"`, `aria-modal="true"`, and `aria-labelledby` to each modal container.
- Move focus into the modal when it opens.
- Trap Tab focus while the modal is open.
- Support Escape to close.
- Restore focus to the triggering control after close.
- Hide or inert the background content while the modal is active.

### Serious: Icon-only buttons need accessible names

Impact: Screen reader users hear generic "button" or an unclear title-dependent name.

WCAG:

- 1.1.1 Non-text Content
- 2.4.6 Headings and Labels
- 4.1.2 Name, Role, Value

Examples:

- Close buttons such as `src/views/WelcomeView.vue:262`, `src/views/DemandDashboard.vue:253`, `555`, `635`, `src/views/OfferDashboard.vue:362`, `470`, and `src/views/ChatEscrowView.vue:346`.
- `src/App.vue:49` logout icon button uses `title`, but should have `aria-label`.
- `src/views/ChatEscrowView.vue:157` photo evidence icon button uses `title`, but should have `aria-label`.
- `src/views/ChatEscrowView.vue:170` send button has only an icon.

Recommended fix:

- Add explicit labels, for example `aria-label="Cerrar modal"`, `aria-label="Cerrar sesión"`, `aria-label="Enviar mensaje"`, and `aria-label="Adjuntar evidencia fotográfica"`.
- Mark decorative icons with `aria-hidden="true"` where possible.

### Serious: Dynamic errors and status changes are not announced

Impact: Screen reader users may miss validation failures, successful saves, incoming proposals, sent messages, and payment status changes.

WCAG:

- 3.3.1 Error Identification
- 3.3.3 Error Suggestion
- 4.1.3 Status Messages

Examples:

- `src/views/WelcomeView.vue:301`, `316`, `331`, `346` show errors visually but inputs do not use `aria-invalid` or `aria-describedby`.
- `src/views/DemandDashboard.vue:69` and `src/views/OfferDashboard.vue:86` use `alert()`.
- `src/views/OfferDashboard.vue:545` success toast is not a live region.
- `src/views/ChatEscrowView.vue:135` chat history receives dynamic messages but no live region announces new content.
- `src/views/ChatEscrowView.vue:225` payment loading/status changes are visual only.

Recommended fix:

- Connect each error message with `aria-describedby`.
- Set `aria-invalid="true"` when validation fails.
- Use `role="alert"` for immediate errors.
- Use `aria-live="polite"` or `role="status"` for success toasts, chat updates, and payment state updates.

### Serious: Some text and UI colors do not meet AA contrast

Impact: Low-vision users may not be able to read labels, badges, icons, map text, and star states.

WCAG:

- 1.4.3 Contrast Minimum
- 1.4.11 Non-text Contrast

Measured examples from current variables:

- `#FF8235` on `#FDEEE3`: 2.18:1
- `#FF8235` on `#F3ECE5`: 2.11:1
- `#FF8235` on white: 2.47:1
- `#D8D0C4` on `#F3ECE5`: 1.31:1
- `#97C59F` on `#F3ECE5`: 1.66:1

Code examples:

- `src/style.css:13` defines `--sunset-orange: #FF8235`.
- `src/style.css:295` uses `--sunset-orange` for warning badge text.
- `src/views/ChatEscrowView.vue:624` uses `#D8D0C4` for empty stars.
- Green/orange icon and map pin states often rely on these colors without text alternatives.

Recommended fix:

- Use `--sunset-orange-dark: #C54B00` for text and meaningful UI states on light backgrounds.
- Keep `#FF8235` for decorative fills only when meaning is also conveyed by text.
- Darken disabled/empty star color or add text labels such as `aria-label="3 de 5 estrellas"`.

### Serious: Motion and animation do not respect reduced-motion preferences

Impact: Users with vestibular disorders may experience discomfort.

WCAG:

- 2.3.3 Animation from Interactions
- 2.2.2 Pause, Stop, Hide where applicable

Examples:

- `src/style.css:59` applies global transitions to all elements.
- `src/style.css:321`, `396`, `429`, and `src/views/OfferDashboard.vue:792`, `833`, `860`, `905` define animations.
- `src/views/DemandDashboard.vue:1132` and `src/views/WelcomeView.vue:648` animate map/visual elements.

Recommended fix:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Moderate: Heading structure and landmarks need tightening

Impact: Screen reader users may have a less predictable page outline.

WCAG:

- 1.3.1 Info and Relationships
- 2.4.1 Bypass Blocks
- 2.4.6 Headings and Labels

Examples:

- `src/App.vue:66` uses `<main>`, which is good.
- `src/App.vue:14` uses `<header>`, which is good.
- There is no skip link before repeated navigation.
- Dashboard root sections are mostly `<div>` containers rather than named `<section>`/`aside>` landmarks.
- Some card headings use `h3`/`h4` based on visual size rather than document hierarchy.

Recommended fix:

- Add a skip link targeting the main content.
- Give `<main>` an `id`, for example `id="main-content"`.
- Use `<aside aria-label="Filtros">` for filter sidebars.
- Use `<section aria-labelledby="...">` for major dashboard regions.

### Moderate: Star rating selector needs radio semantics

Impact: Screen reader users do not know the current rating or that the five buttons represent one choice.

WCAG:

- 1.3.1 Info and Relationships
- 4.1.2 Name, Role, Value

Example:

- `src/views/ChatEscrowView.vue:355` through `src/views/ChatEscrowView.vue:363`

Recommended fix:

- Prefer a radio group with five radio inputs and labels.
- If using buttons, wrap in `role="radiogroup"` and expose `aria-pressed` or `aria-checked` with clear labels such as `aria-label="Calificar 4 de 5 estrellas"`.

### Moderate: File upload control is visually separated from the native input

Impact: The hidden file input may be hard to discover or operate in some assistive technology combinations.

WCAG:

- 2.1.1 Keyboard
- 3.3.2 Labels or Instructions
- 4.1.2 Name, Role, Value

Example:

- `src/views/OfferDashboard.vue:524` and `src/views/OfferDashboard.vue:530`

Recommended fix:

- Keep the native input accessible rather than `display: none`, or use a visually hidden pattern.
- Add `accept=".pdf,.jpg,.jpeg,.png"`.
- Provide `aria-describedby` for format and size requirements.

### Moderate: Image alternatives are inconsistent

Impact: Some images have generic or missing alternatives.

WCAG:

- 1.1.1 Non-text Content

Examples:

- `src/views/OfferDashboard.vue:154` provider profile image has no `alt`.
- `src/views/DemandDashboard.vue:296` uses generic `alt="Provider Avatar"`.
- `src/views/DemandDashboard.vue:428` pin avatar has no `alt`; it is probably decorative and should use `alt=""`.
- `src/views/DemandDashboard.vue:580` portfolio images all use generic `alt="Trabajo de portafolio"` and may need more specific descriptions if they communicate work quality.

Recommended fix:

- Use meaningful alt text when the image identifies a provider.
- Use `alt=""` for decorative avatars inside controls that already include text names.
- For portfolios, use specific alt text if data exists; otherwise consider `alt=""` plus visible context.

## View-by-view Notes

### `WelcomeView.vue`

Key issues:

- Landing mode switch and role cards are mouse-only custom controls.
- Auth modal lacks dialog semantics and focus management.
- Form labels are visual only.
- Error messages are not connected to inputs.
- Close button has no accessible name and focus outline is explicitly removed.

Recommended first fixes:

1. Convert role cards into radio inputs or accessible buttons.
2. Add IDs, labels, `autocomplete`, `aria-invalid`, and `aria-describedby` to auth fields.
3. Implement a reusable accessible modal pattern.

### `DemandDashboard.vue`

Key issues:

- Sidebar task cards and map pins are clickable `<div>` elements.
- Publishing, provider profile, and direct-hire modals need dialog semantics and focus handling.
- Search input and filters need programmatic labels.
- Provider/map images need better alt behavior.

Recommended first fixes:

1. Convert task cards and map pins to buttons.
2. Add accessible names to close buttons.
3. Add proper labels to search/filter/job forms.

### `OfferDashboard.vue`

Key issues:

- Contract cards and privacy circles are clickable `<div>` elements.
- Profile and job-detail modals need dialog semantics and focus handling.
- File upload needs a more accessible hidden-input pattern.
- Success toast needs `role="status"` or `aria-live`.

Recommended first fixes:

1. Convert contract cards and map privacy circles to buttons.
2. Make profile and bid forms programmatically labeled.
3. Announce success and validation states through live regions.

### `ChatEscrowView.vue`

Key issues:

- Chat send/photo icon buttons need `aria-label`.
- Chat updates are not announced.
- Payment state changes are visual only.
- Review modal and star selector need accessible semantics.
- Disabled mock payment inputs have labels that are not associated and may add noisy tab/reading behavior.

Recommended first fixes:

1. Add accessible names to icon buttons.
2. Add live regions for chat/payment/status updates.
3. Rebuild star rating as a radio group.

## Positive Findings

- `index.html:2` sets `lang="es"`.
- `index.html:5` includes a responsive viewport meta tag.
- Most primary CTAs are native `<button>` elements.
- Several content images already have useful alt text, such as provider avatars in `src/views/DemandDashboard.vue:374`.
- The app uses `<main>` in `src/App.vue:66`.
- Text color `#5E544C` on `#F3ECE5` has approximately 6.30:1 contrast, which is suitable for normal body text.

## Recommended Fix Order

1. Add a global `:focus-visible` style and remove `outline: none` rules.
2. Convert clickable `<div>` controls to buttons or proper form controls.
3. Add `for`/`id` label associations and error descriptions to all forms.
4. Implement a shared accessible modal pattern.
5. Add accessible names to icon-only buttons.
6. Add live regions for validation, toast, chat, payment, and async status changes.
7. Replace low-contrast text colors with accessible variants.
8. Add `prefers-reduced-motion` CSS.
9. Add skip link and strengthen landmarks.
10. Run automated and manual testing.

## Suggested Test Checklist

- Run `npm run build` to verify the app still compiles after fixes.
- Run Lighthouse accessibility on the local app.
- Run axe on the local app.
- Tab through every view with keyboard only.
- Confirm Enter/Space activates every interactive control.
- Open and close every modal with keyboard only.
- Verify focus moves into each modal and returns to the trigger after close.
- Test at 200% browser zoom.
- Test with `prefers-reduced-motion: reduce`.
- Test with a screen reader on the auth flow, task publishing flow, bid flow, chat flow, and review flow.

