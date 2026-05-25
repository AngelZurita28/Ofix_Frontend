<script setup lang="ts">
import { useStore } from './store';
import WelcomeView from './views/WelcomeView.vue';
import DemandDashboard from './views/DemandDashboard.vue';
import OfferDashboard from './views/OfferDashboard.vue';
import ChatEscrowView from './views/ChatEscrowView.vue';
import { LogOut } from 'lucide-vue-next';

const { state, toggleMode, logout, navigateTo } = useStore();
</script>

<template>
  <div
    id="main-app"
    :class="{ 'is-landing-view': state.currentView === 'welcome', 'is-function-view': state.currentView !== 'welcome' }"
  >
    <!-- Persistent mode light: full backdrop on landing, navbar halo in function views -->
    <div :class="['ambient-orbs', state.currentView === 'welcome' ? 'landing-light' : 'function-light']">
      <div class="orb orb-primary"></div>
      <div class="orb orb-secondary"></div>
    </div>

    <!-- Master Header -->
    <header v-if="state.currentView !== 'welcome'" class="app-navbar glass-panel">
      <div class="navbar-mode-light" aria-hidden="true"></div>
      <!-- Left side: Brand -->
      <div class="brand-logo" @click="navigateTo('welcome')">
        <img src="/src/assets/ofix.svg" alt="Ofix" class="brand-logo-img" />
      </div>

      <!-- Center: Suspended Switch Pill (6.A of DESIGN.md) -->
      <div class="mode-switch-wrapper">
        <div class="mode-switch-base glass-panel-sm" @click="toggleMode">
          <div :class="['mode-slider', state.activeMode.toLowerCase()]"></div>
          <span :class="['mode-label-btn', { active: state.activeMode === 'DEMANDA' }]">
            Contratar Tareas
          </span>
          <span :class="['mode-label-btn', { active: state.activeMode === 'OFERTA' }]">
            Ofrecer Oficio
          </span>
        </div>
      </div>

      <!-- Right side: Session details -->
      <div class="user-session-section">
        <template v-if="state.user">
          <div class="flex items-center gap-2 mr-4 text-xs font-semibold text-dark">
            <span class="avatar-letter-circle">
              {{ state.user.name.charAt(0) }}
            </span>
            <span class="user-display-name">{{ state.user.name }}</span>
          </div>
          <button @click="logout" class="secondary-btn icon-only-nav-btn" title="Cerrar Sesión">
            <LogOut :size="14" />
          </button>
        </template>
        <template v-else>
          <button @click="navigateTo('auth')" class="secondary-btn text-xs py-2">
            Iniciar Sesión
          </button>
        </template>
      </div>
    </header>

    <!-- Main Content Area -->
    <main class="app-main-content">
      <Transition name="fade" mode="out-in">
        <WelcomeView v-if="state.currentView === 'welcome'" />
        <DemandDashboard v-else-if="state.currentView === 'demand-dashboard'" />
        <OfferDashboard v-else-if="state.currentView === 'offer-dashboard'" />
        <ChatEscrowView v-else-if="state.currentView === 'chat-escrow'" />
      </Transition>
    </main>

    <!-- Footer Bar -->
    <!-- <footer class="app-footer">
      <div class="footer-inner glass-panel-sm">
        <p class="body-text text-xs">© 2026 Ofix (Terra) Conexión Local. Desarrollado con 🧡 para fines de prototipo y validación visual.</p>
        <div class="flex gap-4">
          <a href="#CHECKLIST.md" class="text-xs text-muted hover-accent">CHECKLIST.md</a>
          <span class="text-xs text-muted">|</span>
          <span class="text-xs text-muted">Stripe Mock Activado 🔒</span>
        </div>
      </div>
    </footer> -->
  </div>
</template>

<style>
/* Reset and base utilities */
#main-app {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  padding: 20px 20px 80px 20px;
  position: relative;
  z-index: 1;
}

.app-navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  border-radius: var(--radius-pill); /* Pill shaped navbar floating at top */
  margin-bottom: 24px;
  position: relative;
  overflow: visible;
  z-index: 2;
}

.navbar-mode-light {
  position: absolute;
  inset: -18px -26px;
  border-radius: var(--radius-pill);
  background:
    radial-gradient(ellipse at 50% 50%, var(--accent) 0, transparent 44%),
    radial-gradient(ellipse at 50% 50%, var(--accent-light) 0, transparent 72%);
  filter: blur(22px);
  opacity: 0.42;
  pointer-events: none;
  z-index: -1;
  animation: navbarHaloTravel 9s ease-in-out infinite alternate;
}

.navbar-mode-light::after {
  content: '';
  position: absolute;
  inset: 12px 18px;
  border-radius: inherit;
  border: 1px solid color-mix(in srgb, var(--accent) 35%, transparent);
  box-shadow:
    0 0 28px var(--accent-glow),
    0 14px 52px color-mix(in srgb, var(--accent) 18%, transparent);
  opacity: 0.8;
}

@keyframes navbarHaloTravel {
  from {
    transform: translate3d(0, 0, 0) scaleX(0.98);
  }
  to {
    transform: translate3d(0, 2px, 0) scaleX(1.02);
  }
}

@media (prefers-reduced-motion: reduce) {
  .navbar-mode-light {
    animation: none;
  }
}

.brand-logo {
  display: flex;
  align-items: center;
  cursor: pointer;
}

.brand-logo-img {
  height: 28px;
  object-fit: contain;
  display: block;
  transition: opacity 0.2s ease;
}

.brand-logo-img:hover {
  opacity: 0.9;
}

/* Suspended switch pill */
.mode-switch-wrapper {
  position: relative;
}

.mode-switch-base {
  display: flex;
  position: relative;
  background-color: rgba(24, 27, 25, 0.05);
  border-radius: var(--radius-pill);
  padding: 4px;
  cursor: pointer;
  align-items: center;
  border: 1px solid var(--frost-border);
  box-shadow: 0 4px 12px -4px var(--clay-shadow);
  user-select: none;
}

.mode-label-btn {
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 600;
  color: var(--text-muted);
  padding: 8px 18px;
  border-radius: var(--radius-pill);
  z-index: 2;
  transition: color 0.4s ease;
}

.mode-label-btn.active {
  color: #ffffff;
}

.mode-slider {
  position: absolute;
  top: 4px;
  bottom: 4px;
  border-radius: var(--radius-pill);
  z-index: 1;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.mode-slider.demanda {
  left: 4px;
  right: 50%;
  background-color: var(--sunset-orange);
}

.mode-slider.oferta {
  left: 50%;
  right: 4px;
  background-color: var(--verde-terraria);
}

.user-session-section {
  display: flex;
  align-items: center;
}

.avatar-letter-circle {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background-color: var(--accent);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  box-shadow: 0 2px 6px var(--accent-glow);
}

.icon-only-nav-btn {
  padding: 8px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.app-main-content {
  flex-grow: 1;
  width: 100%;
}

.app-footer {
  position: fixed;
  bottom: 12px;
  left: 20px;
  right: 20px;
  z-index: 100;
  display: flex;
  justify-content: center;
  pointer-events: none;
}

.footer-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  max-width: 1160px;
  padding: 10px 24px;
  border-radius: var(--radius-pill);
  background-color: rgba(255, 255, 255, 0.8);
  border: 1px solid var(--frost-border);
  box-shadow: 0 4px 16px -4px var(--clay-shadow);
  pointer-events: auto;
}

.hover-accent:hover {
  color: var(--accent);
  text-decoration: underline;
}

.hidden {
  display: none !important;
}

@media (max-width: 768px) {
  .app-footer {
    display: none;
  }
  .app-navbar {
    flex-direction: column;
    gap: 12px;
    border-radius: var(--radius-md);
  }
  .navbar-mode-light {
    inset: -14px -12px;
    border-radius: var(--radius-lg);
  }
  .user-display-name {
    display: none;
  }
}
</style>
