<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed, nextTick } from 'vue';
import { useStore } from '../store';
import {
  ArrowLeft,
  ArrowRight,
  BadgeCheck,
  ChevronDown,
  CircleDollarSign,
  ClipboardList,
  HeartHandshake,
  Layers,
  Lock,
  MapPin,
  MessageCircle,
  Rocket,
  Search,
  Send,
  Server,
  Shield,
  ShieldCheck,
  Sparkles,
  Star,
  Store,
  TrendingUp,
  Users,
  Wrench,
  Zap,
} from 'lucide-vue-next';

const { navigateTo } = useStore();

const currentSlide = ref(0);
const totalSlides = 7;
const scrollContainerRef = ref<HTMLElement | null>(null);
const isTransitioning = ref(false);

// Active mode auto-toggle for the interactive hero mockup
type LandingMode = 'DEMANDA' | 'OFERTA';
const activeMode = ref<LandingMode>('DEMANDA');
const isDemandMode = computed(() => activeMode.value === 'DEMANDA');

const currentModeData = computed(() => {
  return {
    previewLabel: activeMode.value === 'DEMANDA' ? 'Solicitud de tarea' : 'Oportunidad cercana',
    previewStatus: activeMode.value === 'DEMANDA' ? '3 propuestas' : 'Pendiente de aceptación',
  };
});

let mockupTimer: any = null;

const goToSlide = (index: number) => {
  if (isTransitioning.value) return;
  if (index < 0 || index >= totalSlides) return;

  isTransitioning.value = true;
  currentSlide.value = index;

  // We DO NOT scroll the container or elements anymore.
  // The absolute transition coordinates do all the work, keeping the browser window layout locked.

  setTimeout(() => {
    isTransitioning.value = false;
  }, 700);
};

const nextSlide = () => goToSlide(currentSlide.value + 1);
const prevSlide = () => goToSlide(currentSlide.value - 1);

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'ArrowDown' || e.key === 'ArrowRight' || e.key === ' ') {
    e.preventDefault();
    nextSlide();
  } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft') {
    e.preventDefault();
    prevSlide();
  } else if (e.key === 'Escape') {
    navigateTo('welcome');
  }
};

const handleWheel = (e: WheelEvent) => {
  e.preventDefault();
  if (isTransitioning.value) return;

  if (e.deltaY > 30) {
    nextSlide();
  } else if (e.deltaY < -30) {
    prevSlide();
  }
};

// Touch handling
let touchStartY = 0;
const handleTouchStart = (e: TouchEvent) => {
  touchStartY = e.touches[0].clientY;
};

const handleTouchEnd = (e: TouchEvent) => {
  if (isTransitioning.value) return;
  const deltaY = touchStartY - e.changedTouches[0].clientY;
  if (Math.abs(deltaY) > 50) {
    if (deltaY > 0) nextSlide();
    else prevSlide();
  }
};

onMounted(() => {
  document.addEventListener('keydown', handleKeydown);
  
  // Lock body scroll completely to prevent layout displacement
  document.body.style.overflow = 'hidden';

  // Toggle the active switch mockup mode every 3.5s
  mockupTimer = setInterval(() => {
    activeMode.value = activeMode.value === 'DEMANDA' ? 'OFERTA' : 'DEMANDA';
  }, 3500);

  nextTick(() => {
    const container = scrollContainerRef.value;
    if (container) {
      container.addEventListener('wheel', handleWheel, { passive: false });
      container.addEventListener('touchstart', handleTouchStart, { passive: true });
      container.addEventListener('touchend', handleTouchEnd, { passive: true });
    }
  });
});

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown);
  
  // Restore body scroll
  document.body.style.overflow = '';

  if (mockupTimer) clearInterval(mockupTimer);

  const container = scrollContainerRef.value;
  if (container) {
    container.removeEventListener('wheel', handleWheel);
    container.removeEventListener('touchstart', handleTouchStart);
    container.removeEventListener('touchend', handleTouchEnd);
  }
});

const slideLabels = [
  'Inicio',
  'Solución',
  'Funcionamiento',
  'Seguridad',
  'Proveedores',
  'Finanzas',
  'Cierre',
];
</script>

<template>
  <div class="pres-root">
    <!-- Grain overlay -->
    <div class="pres-grain" aria-hidden="true"></div>

    <!-- Floating nav indicator -->
    <nav class="pres-nav" aria-label="Navegación de presentación">
      <button
        class="pres-back-btn"
        type="button"
        @click="navigateTo('welcome')"
        aria-label="Volver al inicio"
      >
        <ArrowLeft :size="16" />
      </button>

      <div class="pres-dots">
        <button
          v-for="(label, i) in slideLabels"
          :key="i"
          type="button"
          :class="['pres-dot', { active: currentSlide === i }]"
          :aria-label="`Ir a sección ${label}`"
          @click="goToSlide(i)"
        >
          <span class="dot-pip"></span>
          <span class="dot-label">{{ label }}</span>
        </button>
      </div>

      <span class="pres-counter">{{ currentSlide + 1 }}/{{ totalSlides }}</span>
    </nav>

    <!-- Scroll-snap container -->
    <div ref="scrollContainerRef" class="pres-scroll-container">

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 0 — INTRO & PROBLEM (ORANGE)                     -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-orange', { 'slide-active': currentSlide === 0 }]" data-slide="0">
        <div class="slide-content slide-intro-hero">
          <div class="intro-copy-hero">
            <div class="pres-badge">
              <Sparkles :size="13" />
              <span>INNOVATEC 2026</span>
            </div>

            <h1 class="slide-hero-title">
              ¿Se te averió el auto?<br />¿Falló tu computadora?
            </h1>

            <p class="slide-lede">
              Ante estos imprevistos cotidianos, surge un gran reto en nuestras comunidades: la enorme dificultad
              para encontrar asistencia <strong>rápida, honesta y segura.</strong>
            </p>

            <div class="intro-team">
              <div class="team-chip">
                <Users :size="16" />
                <span>Fernanda Ramos & Ángel Zurita</span>
              </div>
              <div class="team-chip">
                <Layers :size="16" />
                <span>Categoría: Soluciones digitales</span>
              </div>
            </div>
          </div>

          <div class="hero-orbit" aria-hidden="true">
            <div class="orbit-card orbit-card-demand">
              <ClipboardList :size="18" />
              <span>Contratar</span>
              <strong>Buscar o solicitar tarea</strong>
            </div>
            
            <div class="hero-device glass-panel">
              <div class="device-topline">
                <span class="status-dot"></span>
                <span>Ofiix switch activo</span>
              </div>
              <div class="device-switch">
                <span :class="{ active: isDemandMode }">Contratar</span>
                <span :class="{ active: !isDemandMode }">Ofrecer</span>
                <div :class="['device-slider', activeMode.toLowerCase()]"></div>
              </div>
              <div class="device-map">
                <div class="map-line line-a"></div>
                <div class="map-line line-b"></div>
                <div class="map-zone"></div>
                <span class="map-pin-home"><MapPin :size="16" /></span>
                <span class="map-pin-pro"><Wrench :size="15" /></span>
              </div>
              <div class="device-bottom">
                <span>{{ currentModeData.previewLabel }}</span>
                <strong>{{ currentModeData.previewStatus }}</strong>
              </div>
            </div>

            <div class="orbit-card orbit-card-offer">
              <Store :size="18" />
              <span>Ofrecer</span>
              <strong>Postularse a trabajos</strong>
            </div>
          </div>
        </div>

        <!-- <button class="scroll-hint" @click="nextSlide" aria-label="Siguiente sección">
          <ChevronDown :size="22" />
        </button> -->
      </section>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 1 — THE SOLUTION (GREEN)                         -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-green', { 'slide-active': currentSlide === 1 }]" data-slide="1">
        <div class="slide-content slide-solution-lectura">
          <div class="solution-heading">
            <div class="pres-badge">
              <Rocket :size="13" />
              <span>La solución</span>
            </div>

            <h2 class="slide-hero-title">
              Ofiix: conecta necesidades con oficios.
            </h2>

            <p class="slide-lede">
              Una plataforma web pensada para ofrecer una experiencia rápida y fluida,
              con un backend robusto de alto rendimiento y almacenamiento de datos ágil.
            </p>
          </div>

          <div class="communication-grid">
            <article class="glass-panel communication-card intent-card">
              <span class="communication-label">FRONTEND</span>
              <h3>Vue.js</h3>
              <p class="body-text">
                Construimos una interfaz dinámica y fluida para responder al instante a cada interacción, eliminando tiempos de espera molestos.
              </p>
              <div class="example-cloud">
                <span>Reactividad total</span>
                <span>Filtros avanzados</span>
                <span>Mapas interactivos</span>
                <span>Estética premium</span>
              </div>
            </article>

            <article class="glass-panel communication-card surface-card">
              <span class="communication-label">BACKEND</span>
              <h3>Node.js</h3>
              <p class="body-text">
                Una arquitectura robusta basada en JavaScript en el servidor que procesa múltiples solicitudes concurrentes a gran velocidad.
              </p>
              <div class="surface-token">
                <Server :size="22" />
                <strong>Rendimiento & Costos mínimos</strong>
              </div>
            </article>

            <div class="module-stack">
              <article class="module-note">
                <span>Base de Datos</span>
                <h4>MongoDB</h4>
                <p>Almacenamiento de información flexible, seguro y optimizado en la nube para escalar sin límites.</p>
              </article>
              <article class="module-note">
                <span>Confianza local</span>
                <h4>Transparencia total</h4>
                <p>Soporte de reputación real, perfiles comerciales y validación vecinal para un trato honesto.</p>
              </article>
            </div>
          </div>
        </div>
      </section>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 2 — HOW IT WORKS (ORANGE)                        -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-orange', { 'slide-active': currentSlide === 2 }]" data-slide="2">
        <div class="slide-content slide-how-hero">
          <div class="how-heading">
            <div class="pres-badge">
              <Zap :size="13" />
              <span>Funcionamiento</span>
            </div>

            <h2 class="slide-hero-title">
              Tú tienes el control.
            </h2>

            <p class="slide-lede">
              Entra a la plataforma, publica lo que necesitas y elige la mejor opción.
              Los proveedores cercanos te enviarán propuestas detalladas.
            </p>
          </div>

          <div class="how-steps-premium">
            <div class="how-step-premium glass-panel">
              <span class="step-num-badge">1</span>
              <div class="step-icon-premium">
                <Search :size="26" />
              </div>
              <h3>Publica tu necesidad</h3>
              <p>Arreglar un enchufe, pintar una pared, revisar el aire o reparar imprevistos en tu hogar.</p>
              <div class="step-meta">Define tu presupuesto</div>
            </div>

            <div class="how-step-connector-premium" aria-hidden="true">
              <ArrowRight :size="22" />
            </div>

            <div class="how-step-premium glass-panel">
              <span class="step-num-badge">2</span>
              <div class="step-icon-premium">
                <Send :size="26" />
              </div>
              <h3>Recibe propuestas</h3>
              <p>Profesionales de tu zona verán tu tarea y te enviarán cotizaciones con precios y explicaciones.</p>
              <div class="step-meta">Compara perfiles al instante</div>
            </div>

            <div class="how-step-connector-premium" aria-hidden="true">
              <ArrowRight :size="22" />
            </div>

            <div class="how-step-premium glass-panel">
              <span class="step-num-badge">3</span>
              <span class="premium-step-badge">
                <Sparkles :size="10" />
                Confianza
              </span>
              <div class="step-icon-premium">
                <BadgeCheck :size="26" />
              </div>
              <h3>Elige con transparencia</h3>
              <p>Revisa perfiles, fotos de trabajos anteriores, reputación y opiniones reales de vecinos.</p>
              <div class="step-meta">Pago protegido por Escrow</div>
            </div>
          </div>
        </div>
      </section>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 3 — SECURITY & TRUST (GREEN)                     -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-green', { 'slide-active': currentSlide === 3 }]" data-slide="3">
        <div class="slide-content slide-security-hero">
          <div class="security-layout-premium">
            <div class="security-copy-premium">
              <div class="pres-badge">
                <Shield :size="13" />
                <span>Seguridad y confianza</span>
              </div>

              <h2 class="slide-hero-title">
                Tu dinero y privacidad, protegidos.
              </h2>

              <p class="slide-lede">
                Al aceptar una cotización, pagas de forma práctica y segura con OpenPay.
                Gracias a nuestro método <strong>Escrow</strong>, el dinero se guarda de forma segura en la plataforma
                y solo se libera al proveedor cuando estés completamente satisfecho.
              </p>
            </div>

            <div class="security-grid-premium">
              <article class="glass-panel security-card-premium">
                <div class="sec-icon-circle">
                  <ShieldCheck :size="24" />
                </div>
                <h3>Garantía Escrow</h3>
                <p>El pago queda en resguardo fiduciario en la plataforma y se libera únicamente al completarse el trabajo.</p>
              </article>

              <article class="glass-panel security-card-premium">
                <div class="sec-icon-circle">
                  <CircleDollarSign :size="24" />
                </div>
                <h3>OpenPay integrado</h3>
                <p>Procesador mexicano líder que permite transacciones rápidas por tarjeta de crédito, débito o transferencias.</p>
              </article>

              <article class="glass-panel security-card-premium">
                <div class="sec-icon-circle">
                  <MapPin :size="24" />
                </div>
                <h3>Dirección protegida</h3>
                <p>Tu ubicación exacta nunca es visible en el mapa; se comparte de forma segura solo tras concretar el acuerdo.</p>
              </article>

              <article class="glass-panel security-card-premium">
                <div class="sec-icon-circle">
                  <MessageCircle :size="24" />
                </div>
                <h3>Chat contextual</h3>
                <p>La solicitud, cotización, mensajería y la liberación del pago viven de manera integrada en un solo flujo.</p>
              </article>
            </div>
          </div>
        </div>
      </section>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 4 — VALUE FOR PROVIDERS (ORANGE)                  -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-orange', { 'slide-active': currentSlide === 4 }]" data-slide="4">
        <div class="slide-content slide-provider-hero">
          <div class="provider-layout-premium">
            <div class="provider-visual-premium">
              <div class="provider-board-premium glass-panel">
                <div class="board-header-premium">
                  <span class="board-label-premium">Tablón de Necesidades</span>
                  <span class="live-indicator">
                    <span class="live-dot"></span>
                    En tiempo real
                  </span>
                </div>
                
                <div class="board-item-premium">
                  <div class="job-icon plomeria"><Wrench :size="16" /></div>
                  <div class="job-info">
                    <strong>Fuga de agua — Zona Centro</strong>
                    <span>Urgente • Vecino ofrece $650</span>
                  </div>
                  <span class="price-pill">$650/hr</span>
                </div>

                <div class="board-item-premium">
                  <div class="job-icon electricidad"><Zap :size="16" /></div>
                  <div class="job-info">
                    <strong>Cortocorticuito — Col. Del Valle</strong>
                    <span>Hoy mismo • Vecino ofrece $800</span>
                  </div>
                  <span class="price-pill">$800/hr</span>
                </div>

                <div class="board-item-premium">
                  <div class="job-icon carpinteria"><Wrench :size="16" /></div>
                  <div class="job-info">
                    <strong>Puerta caída — Col. Coyoacán</strong>
                    <span>Programado • Vecino ofrece $500</span>
                  </div>
                  <span class="price-pill">$500/hr</span>
                </div>
              </div>

              <!-- Extra visual support element: orbit card -->
              <div class="provider-orbit-badge glass-panel">
                <ShieldCheck :size="18" />
                <span>Cobro Garantizado</span>
                <strong>Escrow Activo</strong>
              </div>
            </div>

            <div class="provider-copy-premium">
              <div class="pres-badge">
                <Star :size="13" />
                <span>Valor para el proveedor</span>
              </div>

              <h2 class="slide-hero-title">
                Haz crecer tu negocio. Sin esperar llamadas.
              </h2>

              <p class="slide-body">
                Si eres plomero, carpintero, electricista o tienes cualquier oficio, accede al tablón de necesidades activas de vecinos cercanos que necesitan ayuda hoy mismo.
              </p>

              <div class="provider-perks-premium">
                <div class="perk-premium">
                  <div class="perk-icon-wrapper"><HeartHandshake :size="18" /></div>
                  <span><strong>Tus reglas, tu precio:</strong> Envía propuestas personalizadas y acuerda tarifas justas directamente.</span>
                </div>
                <div class="perk-premium">
                  <div class="perk-icon-wrapper"><Lock :size="18" /></div>
                  <span><strong>Garantía de cobro:</strong> Tus honorarios se pre-pagan y aseguran mediante Escrow antes de salir de casa.</span>
                </div>
                <div class="perk-premium">
                  <div class="perk-icon-wrapper"><Sparkles :size="18" /></div>
                  <span><strong>Libertad absoluta:</strong> Administra tus tiempos, sé tu propio jefe y aumenta tus ingresos diarios.</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 5 — FINANCIAL VIABILITY (GREEN)                   -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-green', { 'slide-active': currentSlide === 5 }]" data-slide="5">
        <div class="slide-content slide-finance-hero">
          <div class="finance-heading">
            <div class="pres-badge">
              <TrendingUp :size="13" />
              <span>Análisis financiero</span>
            </div>

            <h2 class="slide-hero-title">
              Un modelo rentable y escalable.
            </h2>

            <p class="slide-lede">
              Costos fijos mensuales optimizados y un esquema de monetización claro
              que garantizan la sustentabilidad y el crecimiento comercial del proyecto.
            </p>
          </div>

          <div class="finance-grid-premium">
            <div class="finance-card-premium glass-panel finance-costs-premium">
              <span class="card-kicker">PRESUPUESTO</span>
              <h3>Costos Fijos Mensuales</h3>
              <div class="cost-summary">
                <strong class="finance-total-premium">$13,000 MXN</strong>
                <span>Presupuesto mensual operativo</span>
              </div>
              <ul class="cost-list-premium">
                <li>
                  <div class="cost-name"><span>•</span> Operador digital</div>
                  <strong class="cost-value">$7,000</strong>
                </li>
                <li>
                  <div class="cost-name"><span>•</span> Mantenimiento de servidor</div>
                  <strong class="cost-value">$3,000</strong>
                </li>
                <li>
                  <div class="cost-name"><span>•</span> Soporte legal y contable</div>
                  <strong class="cost-value">$2,500</strong>
                </li>
                <li>
                  <div class="cost-name"><span>•</span> Dominio y servicios web</div>
                  <strong class="cost-value">$500</strong>
                </li>
              </ul>
            </div>

            <div class="finance-card-premium glass-panel surface-card-premium">
              <span class="card-kicker line-white">MONETIZACIÓN</span>
              <h3>Esquema transaccional</h3>
              <div class="monetization-row-premium">
                <div class="monet-item-premium">
                  <span>Ticket promedio</span>
                  <strong>$400 <small>MXN</small></strong>
                </div>
                <div class="monet-item-premium highlight-monet">
                  <span>Comisión Ofiix</span>
                  <strong class="accent-text-green">15%</strong>
                </div>
              </div>
              <div class="net-token-premium">
                <CircleDollarSign :size="20" />
                <div>
                  <strong>$43 MXN ganancia neta</strong>
                  <span>Por servicio (libre de comisión OpenPay)</span>
                </div>
              </div>
            </div>

            <div class="finance-card-premium glass-panel finance-breakeven-premium">
              <span class="card-kicker">EQUILIBRIO</span>
              <h3>Punto de Equilibrio</h3>
              <div class="breakeven-content-premium">
                <strong class="breakeven-number-premium">303</strong>
                <span class="breakeven-label-premium">Servicios mensuales</span>
              </div>
              <p class="breakeven-description-premium">
                Al superar esta cantidad mensual de servicios, Ofiix cubre la totalidad de sus gastos y se convierte en una solución rentable.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- SLIDE 6 — CLOSING CTA (ORANGE)                         -->
      <!-- ═══════════════════════════════════════════════════════ -->
      <section :class="['pres-slide', 'slide-orange', { 'slide-active': currentSlide === 6 }]" data-slide="6">
        <div class="slide-content slide-closing-hero">
          <div class="closing-glow-premium" aria-hidden="true"></div>

          <div class="pres-badge">
            <Sparkles :size="13" />
            <span>Cierre</span>
          </div>

          <h2 class="slide-hero-title slide-closing-title-premium">
            La tecnología debe servir para apoyarnos entre nosotros.
          </h2>

          <p class="slide-lede slide-lede-centered-premium">
            Es hora de dejar atrás la incertidumbre, fortalecer la economía de nuestras colonias
            y empezar a solucionar las cosas con un solo clic. Tu comunidad está lista para ayudarte.
          </p>

          <div class="closing-ctas-premium">
            <button class="premium-btn" @click="navigateTo('welcome')">
              <span>¿Necesitas reparar algo?</span>
              <span class="icon-circle">
                <ArrowRight :size="18" />
              </span>
            </button>
            <button class="secondary-btn" @click="navigateTo('welcome')">
              ¿Quieres ofrecer tus servicios?
            </button>
          </div>

          <p class="closing-thanks-premium">Muchas gracias.</p>
        </div>
      </section>

    </div>
  </div>
</template>

<style scoped>
/* ─────────────────────────────────────────
   ROOT & LAYOUT
   ───────────────────────────────────────── */
.pres-root {
  position: fixed;
  inset: 0;
  z-index: 200;
  background-color: var(--bg-arena);
  overflow: hidden;
}

.pres-grain {
  position: absolute;
  inset: 0;
  z-index: 1;
  pointer-events: none;
  opacity: 0.14;
  background-image:
    linear-gradient(90deg, rgba(24, 27, 25, 0.04) 1px, transparent 1px),
    linear-gradient(rgba(24, 27, 25, 0.035) 1px, transparent 1px);
  background-size: 54px 54px;
  mask-image: linear-gradient(to bottom, black, transparent 85%);
}

.pres-scroll-container {
  position: relative;
  z-index: 2;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

/* ─────────────────────────────────────────
   FLOATING NAV
   ───────────────────────────────────────── */
.pres-nav {
  position: fixed;
  top: 16px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 300;
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 8px 14px 8px 8px;
  border-radius: var(--radius-pill);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.76), rgba(255, 255, 255, 0.38)),
    var(--frost-bg);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--frost-border);
  box-shadow: 0 18px 44px -28px rgba(24, 27, 25, 0.3);
  animation: slideDown 0.55s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.pres-back-btn {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border: 1px solid var(--frost-border);
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.55);
  color: var(--text-dark);
  cursor: pointer;
  transition: all 0.25s ease;
}

.pres-back-btn:hover {
  background: #ffffff;
  color: var(--sunset-orange);
  border-color: var(--sunset-orange);
}

.pres-dots {
  display: flex;
  align-items: center;
  gap: 4px;
}

.pres-dot {
  position: relative;
  display: flex;
  align-items: center;
  gap: 6px;
  border: 0;
  background: transparent;
  padding: 6px 8px;
  border-radius: var(--radius-pill);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.dot-pip {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: rgba(24, 27, 25, 0.18);
  transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}

.dot-label {
  font-family: var(--font-display);
  font-size: 0;
  font-weight: 700;
  color: var(--text-muted);
  white-space: nowrap;
  overflow: hidden;
  max-width: 0;
  opacity: 0;
  transition: all 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}

.pres-dot.active .dot-pip {
  width: 10px;
  height: 10px;
  background: var(--sunset-orange);
  box-shadow: 0 0 0 4px rgba(255, 130, 53, 0.2);
}

.pres-dot.active .dot-label {
  font-size: 12px;
  max-width: 100px;
  opacity: 1;
}

.pres-dot:hover .dot-pip {
  background: var(--sunset-orange);
}

.pres-counter {
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 700;
  color: var(--text-muted);
  padding-left: 6px;
  border-left: 1px solid var(--frost-border);
}

/* ─────────────────────────────────────────
   SLIDES BASE (Visual lock, overflow control, custom scrollbars)
   ───────────────────────────────────────── */
.pres-slide {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 90px 40px 30px; /* Optimized padding to prevent vertical overflows */
  opacity: 0;
  transform: translateY(60px) scale(0.97);
  transition: opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1),
              transform 0.6s cubic-bezier(0.16, 1, 0.3, 1);
  pointer-events: none;
  overflow-x: hidden; /* Prevent horizontal bottom scrollbar completely */
  overflow-y: auto;   /* Graceful vertical scrolling for short screens */
}

.pres-slide::before {
  content: '';
  position: absolute;
  width: 50vw;
  height: 50vw;
  border-radius: 50%;
  filter: blur(140px);
  opacity: 0;
  transition: opacity 0.8s ease;
  pointer-events: none;
}

/* Active slide */
.pres-slide[data-slide] {
  z-index: 1;
}

.pres-slide.slide-active {
  opacity: 1;
  transform: translateY(0) scale(1);
  pointer-events: auto;
  z-index: 10;
}

.pres-slide.slide-active::before {
  opacity: 0.35;
}

.slide-content {
  max-width: 1160px;
  width: 100%;
  animation: fadeInUp 0.75s cubic-bezier(0.16, 1, 0.3, 1) both;
}

/* Premium custom scrollbar styling to look extremely clean */
.pres-slide::-webkit-scrollbar {
  width: 6px;
}

.pres-slide::-webkit-scrollbar-track {
  background: transparent;
}

.pres-slide::-webkit-scrollbar-thumb {
  background: rgba(24, 27, 25, 0.12);
  border-radius: 10px;
}

.pres-slide::-webkit-scrollbar-thumb:hover {
  background: rgba(24, 27, 25, 0.24);
}

.slide-green::-webkit-scrollbar-thumb {
  background: rgba(59, 96, 67, 0.15);
}

.slide-green::-webkit-scrollbar-thumb:hover {
  background: rgba(59, 96, 67, 0.3);
}

/* ─────────────────────────────────────────
   THEME VARIANTS (Scoping active accent variables)
   ───────────────────────────────────────── */
.slide-orange {
  --accent: var(--sunset-orange);
  --accent-text: var(--sunset-orange-dark);
  --accent-light: var(--clay-glow);
  --accent-glow: rgba(255, 130, 53, 0.22);
}

.slide-green {
  --accent: var(--verde-terraria);
  --accent-text: var(--verde-terraria);
  --accent-light: var(--sage-wash);
  --accent-glow: rgba(59, 96, 67, 0.22);
}

.slide-orange::before {
  background: var(--sunset-orange);
  top: -10vw;
  right: -15vw;
}

.slide-green::before {
  background: var(--verde-terraria);
  bottom: -10vw;
  left: -15vw;
}

/* ─────────────────────────────────────────
   BADGES (Matches WelcomeView badges)
   ───────────────────────────────────────── */
.pres-badge {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 8px 14px;
  border-radius: var(--radius-pill);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--accent-text);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.68), rgba(255, 255, 255, 0.22)),
    var(--accent-light);
  border: 1px solid color-mix(in srgb, var(--accent) 24%, transparent);
}

/* ─────────────────────────────────────────
   TYPOGRAPHY (Direct Match to WelcomeView .hero-title)
   ───────────────────────────────────────── */
.slide-hero-title {
  max-width: 880px;
  margin: 12px 0 16px; /* Optimized heading margin to save vertical space */
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: clamp(38px, 6.2vw, 76px);
  font-weight: 800;
  line-height: 0.96;
  letter-spacing: -0.01em;
}

.slide-orange .slide-hero-title {
  color: var(--text-dark);
}

.slide-green .slide-hero-title {
  color: var(--text-dark);
}

.slide-lede {
  max-width: 740px;
  color: var(--text-muted);
  font-size: clamp(16px, 1.8vw, 21px);
  line-height: 1.54;
  margin-bottom: 16px; /* Tighter margins to fit layouts perfectly */
}

.slide-lede strong {
  color: var(--text-dark);
}

.slide-body {
  color: var(--text-muted);
  font-size: clamp(15px, 1.6vw, 18px);
  line-height: 1.58;
}

.slide-body strong {
  color: var(--text-dark);
}

/* ─────────────────────────────────────────
   SLIDE 0 — INTRO WITH HERO ORBIT DEVICE
   ───────────────────────────────────────── */
.slide-intro-hero {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(360px, 0.88fr);
  align-items: center;
  gap: clamp(28px, 5vw, 80px);
}

.intro-copy-hero {
  max-width: 680px;
}

.intro-team {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 20px;
}

.team-chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.52);
  border: 1px solid var(--frost-border);
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 700;
}

/* Hero Orbit Component Styles */
.hero-orbit {
  position: relative;
  min-height: 520px;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: floatIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.08s both;
}

.hero-orbit::before {
  content: '';
  position: absolute;
  width: min(440px, 80vw);
  aspect-ratio: 1;
  border-radius: 50%;
  background:
    radial-gradient(circle at 50% 42%, var(--accent-glow), transparent 58%),
    conic-gradient(from 180deg, rgba(255, 130, 53, 0.16), rgba(59, 96, 67, 0.16), rgba(255, 255, 255, 0.08), rgba(255, 130, 53, 0.16));
  filter: blur(6px);
  opacity: 0.85;
}

.hero-device {
  position: relative;
  width: min(320px, 85vw);
  min-height: 420px;
  padding: 16px;
  border-radius: 30px;
  transform: rotate(-1.5deg);
  box-shadow:
    0 28px 74px -38px rgba(24, 27, 25, 0.45),
    inset 0 1px 0 rgba(255, 255, 255, 0.82);
}

.device-topline,
.device-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 700;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 0 6px var(--accent-glow);
  transition: background-color 0.3s ease;
}

.device-switch {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
  margin: 16px 0;
  padding: 4px;
  border-radius: var(--radius-pill);
  background: rgba(24, 27, 25, 0.06);
}

.device-switch span {
  position: relative;
  z-index: 2;
  text-align: center;
  padding: 9px 6px;
  border-radius: var(--radius-pill);
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 800;
  transition: color 0.3s ease;
}

.device-switch span.active {
  color: #ffffff;
}

.device-slider {
  position: absolute;
  top: 4px;
  bottom: 4px;
  width: calc(50% - 4px);
  border-radius: var(--radius-pill);
  background: var(--accent);
  box-shadow: 0 8px 18px -10px var(--accent);
  transition: transform 0.42s cubic-bezier(0.16, 1, 0.3, 1), background-color 0.3s ease;
}

.device-slider.demanda {
  transform: translateX(0);
}

.device-slider.oferta {
  transform: translateX(100%);
}

.device-map {
  position: relative;
  height: 230px;
  overflow: hidden;
  border-radius: 22px;
  background:
    radial-gradient(circle at 32% 35%, var(--accent-glow), transparent 26%),
    linear-gradient(135deg, #ebe3da, #f8f3ed);
  border: 1px solid rgba(255, 255, 255, 0.72);
  box-shadow: inset 0 12px 30px rgba(105, 95, 87, 0.09);
}

.map-line {
  position: absolute;
  border-radius: var(--radius-pill);
  background: rgba(105, 95, 87, 0.11);
}

.line-a {
  width: 280px;
  height: 28px;
  top: 50px;
  left: -30px;
  transform: rotate(-18deg);
}

.line-b {
  width: 220px;
  height: 22px;
  bottom: 50px;
  right: -40px;
  transform: rotate(32deg);
}

.map-zone {
  position: absolute;
  width: 110px;
  height: 110px;
  left: 60px;
  top: 50px;
  border-radius: 50%;
  border: 1px dashed var(--accent);
  background: var(--accent-glow);
  animation: pulseSoft 3.8s ease-in-out infinite alternate;
  transition: border-color 0.3s ease, background-color 0.3s ease;
}

.map-pin-home,
.map-pin-pro {
  position: absolute;
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 10px 20px -8px rgba(24, 27, 25, 0.42);
  transition: background-color 0.3s ease;
}

.map-pin-home {
  top: 86px;
  left: 100px;
}

.map-pin-pro {
  right: 56px;
  bottom: 54px;
  background: var(--obsidian-ceramic);
}

.device-bottom {
  margin-top: 14px;
}

.device-bottom strong {
  color: var(--text-dark);
}

.orbit-card {
  position: absolute;
  z-index: 2;
  display: grid;
  gap: 4px;
  min-width: 140px;
  padding: 12px 14px;
  border-radius: 18px;
  border: 1px solid var(--frost-border);
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  box-shadow: 0 16px 38px -28px rgba(24, 27, 25, 0.38);
  font-family: var(--font-display);
}

.orbit-card span {
  color: var(--text-muted);
  font-size: 11px;
  font-weight: 700;
}

.orbit-card strong {
  color: var(--text-dark);
  font-size: 13px;
}

.orbit-card-demand {
  top: 48px;
  left: -20px;
  color: var(--sunset-orange-dark);
}

.orbit-card-offer {
  right: -20px;
  bottom: 60px;
  color: var(--verde-terraria);
}

/* ─────────────────────────────────────────
   SLIDE 1 — "LECTURA DEL PRODUCTO" GRID
   ───────────────────────────────────────── */
.slide-solution-lectura {
  display: grid;
  gap: clamp(20px, 3.8vw, 36px);
}

.solution-heading {
  max-width: 820px;
}

.communication-grid {
  display: grid;
  grid-template-columns: minmax(0, 0.95fr) minmax(0, 0.95fr) minmax(290px, 0.78fr);
  gap: 16px;
  align-items: stretch;
}

.communication-card {
  display: flex;
  flex-direction: column;
  min-height: 260px; /* Reduced to ensure vertical layout fits perfectly */
  padding: 20px; /* Optimized padding */
  border-radius: 24px;
  box-shadow: 0 16px 40px -28px rgba(24, 27, 25, 0.35);
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s ease;
}

.communication-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 24px 50px -24px rgba(24, 27, 25, 0.42);
}

.communication-label {
  width: fit-content;
  color: var(--accent-text);
  background: var(--accent-light);
  border: 1px solid color-mix(in srgb, var(--accent) 22%, transparent);
  border-radius: var(--radius-pill);
  padding: 6px 10px;
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

.communication-card h3 {
  margin: 14px 0 8px; /* Tighter margins */
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: clamp(24px, 3vw, 34px);
  font-weight: 800;
  line-height: 1.1;
}

.example-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: auto;
  padding-top: 16px;
}

.example-cloud span {
  border: 1px solid rgba(255, 255, 255, 0.72);
  border-radius: var(--radius-pill);
  padding: 7px 10px;
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.52);
  font-size: 11px;
  font-weight: 800;
  white-space: nowrap;
}

.surface-card {
  background:
    linear-gradient(145deg, rgba(24, 27, 25, 0.88), rgba(24, 27, 25, 0.72)),
    var(--obsidian-ceramic);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.surface-card .communication-label {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.12);
  border-color: rgba(255, 255, 255, 0.18);
}

.surface-card h3,
.surface-card .body-text {
  color: #ffffff;
}

.surface-card .body-text {
  opacity: 0.74;
}

.surface-token {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 10px;
  align-items: center;
  margin-top: auto;
  padding: 11px 13px;
  border-radius: 18px;
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 10px 22px -10px var(--accent);
}

.surface-token strong {
  font-family: var(--font-display);
  font-size: 13.5px;
  line-height: 1.25;
}

.module-stack {
  display: grid;
  gap: 12px;
}

.module-note {
  padding: 14px 16px; /* Optimized padding */
  border: 1px solid var(--frost-border);
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.52);
  transition: all 0.25s ease;
}

.module-note:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateX(4px);
}

.module-note span {
  display: block;
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 10px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.module-note h4 {
  margin: 4px 0 3px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 16.5px;
  line-height: 1.2;
}

.module-note p {
  color: var(--text-muted);
  font-size: 12.5px;
  line-height: 1.38;
}

/* ─────────────────────────────────────────
   SLIDE 2 — HOW IT WORKS
   ───────────────────────────────────────── */
.slide-how-hero {
  display: grid;
  gap: clamp(20px, 3.8vw, 36px);
  text-align: center;
}

.how-heading {
  max-width: 820px;
  margin: 0 auto;
}

.how-steps-premium {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
  margin-top: 10px;
  width: 100%;
}

.how-step-premium {
  flex: 1;
  max-width: 320px;
  padding: 24px 20px; /* Highly optimized card padding */
  text-align: center;
  position: relative;
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s ease;
  min-height: 220px; /* Optimized height */
  display: flex;
  flex-direction: column;
  align-items: center;
}

.how-step-premium:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 45px -24px rgba(24, 27, 25, 0.35);
}

.step-num-badge {
  position: absolute;
  top: -12px;
  left: 22px;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--accent);
  color: #ffffff;
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 800;
  display: grid;
  place-items: center;
  box-shadow: 0 6px 14px -4px var(--accent);
}

.premium-step-badge {
  position: absolute;
  top: -12px;
  right: 22px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 5px 9px;
  border-radius: var(--radius-pill);
  background: var(--accent-light);
  border: 1px solid var(--accent);
  color: var(--accent-text);
  font-size: 9px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.step-icon-premium {
  display: grid;
  place-items: center;
  width: 58px;
  height: 58px;
  margin-bottom: 16px;
  border-radius: 18px;
  color: #ffffff;
  background: var(--obsidian-ceramic);
  box-shadow: 0 12px 24px -14px rgba(24, 27, 25, 0.5);
}

.how-step-premium h3 {
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 18px;
  font-weight: 800;
  margin-bottom: 10px;
}

.how-step-premium p {
  color: var(--text-muted);
  font-size: 13px;
  line-height: 1.48;
}

.step-meta {
  margin-top: auto;
  padding-top: 14px;
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 800;
  color: var(--accent-text);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.how-step-connector-premium {
  color: var(--accent);
  opacity: 0.48;
  flex-shrink: 0;
  animation: pulseConnector 2s infinite ease-in-out;
}

/* ─────────────────────────────────────────
   SLIDE 3 — SECURITY
   ───────────────────────────────────────── */
.slide-security-hero {
  display: grid;
  align-items: center;
}

.security-layout-premium {
  display: grid;
  grid-template-columns: minmax(0, 0.92fr) 1.08fr;
  gap: clamp(24px, 4vw, 56px);
  align-items: center;
}

.security-copy-premium {
  max-width: 500px;
}

.security-grid-premium {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
}

.security-card-premium {
  padding: 18px; /* Tighter padding to prevent overflow */
  border-radius: 22px;
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s ease;
}

.security-card-premium:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 36px -20px rgba(24, 27, 25, 0.35);
}

.sec-icon-circle {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 14px;
  background: var(--accent-light);
  color: var(--accent);
  margin-bottom: 12px;
}

.security-card-premium h3 {
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 15.5px;
  font-weight: 800;
  margin-bottom: 6px;
}

.security-card-premium p {
  color: var(--text-muted);
  font-size: 12.5px;
  line-height: 1.42;
}

/* ─────────────────────────────────────────
   SLIDE 4 — PROVIDER VALUE WITH JOB BOARD
   ───────────────────────────────────────── */
.slide-provider-hero {
  display: grid;
  align-items: center;
}

.provider-layout-premium {
  display: grid;
  grid-template-columns: minmax(320px, 0.88fr) minmax(0, 1.12fr);
  gap: clamp(28px, 5vw, 68px);
  align-items: center;
}

.provider-visual-premium {
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.provider-board-premium {
  padding: 20px; /* Optimized padding */
  border-radius: 26px;
  box-shadow: 0 24px 60px -34px rgba(24, 27, 25, 0.35);
}

.board-header-premium {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.board-label-premium {
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.live-indicator {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #3b6043;
  font-size: 11px;
  font-weight: 800;
  background: rgba(59, 96, 67, 0.08);
  border-radius: var(--radius-pill);
  padding: 4px 8px;
}

.live-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #3b6043;
  animation: pulseLive 1.8s infinite;
}

.board-item-premium {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 12px;
  padding: 10px 12px; /* Tight padding to prevent height issues */
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.55);
  border: 1px solid rgba(255, 255, 255, 0.6);
  margin-bottom: 8px;
  transition: all 0.25s ease;
}

.board-item-premium:hover {
  background: rgba(255, 255, 255, 0.85);
  transform: translateX(4px);
}

.board-item-premium:last-child {
  margin-bottom: 0;
}

.job-icon {
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  border-radius: 10px;
  color: #ffffff;
}

.job-icon.plomeria { background: var(--sunset-orange); }
.job-icon.electricidad { background: var(--obsidian-ceramic); }
.job-icon.carpinteria { background: var(--verde-terraria); }

.job-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.job-info strong {
  color: var(--text-dark);
  font-size: 13px;
  font-weight: 700;
}

.job-info span {
  color: var(--text-muted);
  font-size: 11px;
}

.price-pill {
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 800;
  background: var(--accent-light);
  border: 1px solid color-mix(in srgb, var(--accent) 18%, transparent);
  border-radius: var(--radius-pill);
  padding: 5px 9px;
  white-space: nowrap;
}

.provider-orbit-badge {
  position: absolute;
  right: -24px;
  bottom: -16px;
  z-index: 5;
  display: grid;
  gap: 3px;
  padding: 10px 12px;
  border-radius: 16px;
  box-shadow: 0 14px 28px -18px rgba(24, 27, 25, 0.38);
  font-family: var(--font-display);
  min-width: 130px;
  transform: rotate(2deg);
}

.provider-orbit-badge svg {
  color: var(--accent);
}

.provider-orbit-badge span {
  color: var(--text-muted);
  font-size: 10px;
  font-weight: 700;
}

.provider-orbit-badge strong {
  color: var(--text-dark);
  font-size: 12px;
}

.provider-copy-premium {
  max-width: 540px;
}

.provider-perks-premium {
  display: grid;
  gap: 14px;
  margin-top: 24px;
}

.perk-premium {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 12px;
  align-items: start;
}

.perk-icon-wrapper {
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  border-radius: 10px;
  background: var(--accent-light);
  color: var(--accent);
  margin-top: 1px;
}

.perk-premium span {
  color: var(--text-muted);
  font-size: 14px;
  line-height: 1.48;
}

.perk-premium strong {
  color: var(--text-dark);
}

/* ─────────────────────────────────────────
   SLIDE 5 — FINANCIALS
   ───────────────────────────────────────── */
.slide-finance-hero {
  display: grid;
  gap: clamp(16px, 3.5vw, 32px);
}

.finance-heading {
  max-width: 820px;
}

.finance-grid-premium {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
  width: 100%;
}

.finance-card-premium {
  padding: 22px 18px; /* Tighter padding for vertical clearance */
  border-radius: 26px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 16px 40px -28px rgba(24, 27, 25, 0.35);
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s ease;
}

.finance-card-premium:hover {
  transform: translateY(-4px);
  box-shadow: 0 22px 50px -24px rgba(24, 27, 25, 0.4);
}

.card-kicker {
  display: block;
  width: fit-content;
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 10px;
  font-weight: 900;
  letter-spacing: 0.08em;
  margin-bottom: 10px;
  background: var(--accent-light);
  padding: 4px 8px;
  border-radius: var(--radius-pill);
}

.card-kicker.line-white {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.12);
}

.finance-card-premium h3 {
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 17px;
  font-weight: 800;
  margin-bottom: 12px;
}

.cost-summary {
  margin-bottom: 12px;
}

.finance-total-premium {
  display: block;
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 32px;
  font-weight: 800;
  line-height: 1.1;
}

.cost-summary span {
  color: var(--text-muted);
  font-size: 11px;
}

.cost-list-premium {
  list-style: none;
  display: grid;
  gap: 5px;
  margin-top: auto;
}

.cost-list-premium li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 8px; /* Tighter margins */
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.52);
  font-size: 12px;
}

.cost-name {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-muted);
}

.cost-name span {
  color: var(--accent);
}

.cost-value {
  color: var(--text-dark);
  font-family: var(--font-display);
  font-weight: 700;
}

/* Obsidian Monetization Card */
.surface-card-premium {
  background:
    linear-gradient(145deg, rgba(24, 27, 25, 0.88), rgba(24, 27, 25, 0.72)),
    var(--obsidian-ceramic);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.surface-card-premium h3 {
  color: #ffffff;
}

.monetization-row-premium {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 16px;
}

.monet-item-premium {
  display: flex;
  flex-direction: column;
  gap: 3px;
  padding: 10px 12px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.monet-item-premium span {
  color: rgba(255, 255, 255, 0.6);
  font-size: 11px;
}

.monet-item-premium strong {
  color: #ffffff;
  font-family: var(--font-display);
  font-size: 22px;
  font-weight: 800;
  line-height: 1;
}

.monet-item-premium strong small {
  font-size: 12px;
  font-weight: 500;
}

.monet-item-premium.highlight-monet {
  background: rgba(59, 96, 67, 0.16);
  border-color: rgba(59, 96, 67, 0.24);
}

.accent-text-green {
  color: var(--verde-brote) !important;
}

.net-token-premium {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 10px;
  align-items: center;
  padding: 11px 13px;
  border-radius: 18px;
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 8px 22px -10px var(--accent);
  margin-top: auto;
}

.net-token-premium strong {
  display: block;
  font-family: var(--font-display);
  font-size: 13.5px;
}

.net-token-premium span {
  font-size: 10.5px;
  opacity: 0.8;
}

/* Breakeven Card */
.finance-breakeven-premium {
  justify-content: space-between;
}

.breakeven-content-premium {
  margin: 6px 0 10px; /* Reduced vertical space */
}

.breakeven-number-premium {
  display: block;
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 46px;
  font-weight: 800;
  line-height: 1;
}

.breakeven-label-premium {
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 800;
}

.breakeven-description-premium {
  color: var(--text-muted);
  font-size: 13px;
  line-height: 1.45;
  margin-top: auto;
}

/* ─────────────────────────────────────────
   SLIDE 6 — CLOSING (Premium glow & massive titles)
   ───────────────────────────────────────── */
.slide-closing-hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  position: relative;
  width: 100%;
}

.closing-glow-premium {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255, 130, 53, 0.22), transparent 70%);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
  animation: pulseSoftGlow 4s ease-in-out infinite alternate;
}

.slide-closing-title-premium {
  margin: 14px auto; /* Reduced margin */
  max-width: 920px;
  line-height: 1.02;
  font-size: clamp(34px, 5.8vw, 68px);
}

.slide-lede-centered-premium {
  text-align: center;
  margin-left: auto;
  margin-right: auto;
  max-width: 700px;
  margin-bottom: 24px; /* Reduced margin */
}

.closing-ctas-premium {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-wrap: wrap;
  justify-content: center;
  position: relative;
  z-index: 10;
}

.closing-thanks-premium {
  margin-top: 48px;
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 18px;
  font-weight: 700;
  opacity: 0.7;
  position: relative;
  z-index: 10;
}

/* ─────────────────────────────────────────
   ANIMATIONS
   ───────────────────────────────────────── */
@keyframes slideDown {
  from { transform: translateX(-50%) translateY(-20px); opacity: 0; }
  to { transform: translateX(-50%) translateY(0); opacity: 1; }
}

@keyframes bounceDown {
  0%, 100% { transform: translateX(-50%) translateY(0); }
  50% { transform: translateX(-50%) translateY(8px); }
}

@keyframes pulseSoft {
  0%, 100% { transform: scale(1); opacity: 0.8; }
  50% { transform: scale(1.04); opacity: 0.95; }
}

@keyframes pulseLive {
  0%, 100% { transform: scale(1); opacity: 0.4; }
  50% { transform: scale(1.12); opacity: 1; }
}

@keyframes pulseConnector {
  0%, 100% { transform: translateX(0); opacity: 0.35; }
  50% { transform: translateX(4px); opacity: 0.7; }
}

@keyframes pulseSoftGlow {
  from { opacity: 0.4; transform: translate(-50%, -50%) scale(0.95); }
  to { opacity: 0.8; transform: translate(-50%, -50%) scale(1.1); }
}

@keyframes fadeInUp {
  from { transform: translateY(30px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes floatIn {
  from { transform: translateY(40px) rotate(-3deg); opacity: 0; }
  to { transform: translateY(0) rotate(-1.5deg); opacity: 1; }
}

/* ─────────────────────────────────────────
   RESPONSIVE
   ───────────────────────────────────────── */
@media (max-width: 980px) {
  .slide-intro-hero {
    grid-template-columns: 1fr;
    text-align: center;
    justify-items: center;
    gap: 34px;
  }

  .intro-copy-hero {
    max-width: 100%;
  }

  .intro-team {
    justify-content: center;
  }

  .hero-orbit {
    min-height: 480px;
    width: 100%;
    max-width: 440px;
    transform: scale(0.9); /* Scale down slightly on medium viewports */
  }

  .orbit-card-demand {
    left: 0;
  }

  .orbit-card-offer {
    right: 0;
  }

  .communication-grid {
    grid-template-columns: 1fr;
    max-width: 500px;
    margin: 0 auto;
  }

  .communication-card {
    min-height: auto;
  }

  .how-steps-premium {
    flex-direction: column;
    gap: 16px;
  }

  .how-step-premium {
    max-width: 100%;
    min-height: auto;
  }

  .how-step-connector-premium {
    transform: rotate(90deg);
    padding: 6px 0;
  }

  .security-layout-premium,
  .provider-layout-premium {
    grid-template-columns: 1fr;
    gap: 34px;
  }

  .provider-visual-premium {
    max-width: 400px;
    margin: 0 auto;
    width: 100%;
  }

  .finance-grid-premium {
    grid-template-columns: 1fr;
    max-width: 420px;
    margin: 0 auto;
  }

  .pres-slide {
    padding: 80px 20px 30px;
  }
}

@media (max-width: 720px) {
  .slide-hero-title {
    font-size: clamp(30px, 8.5vw, 48px);
  }

  .pres-nav {
    top: 8px;
    gap: 8px;
    padding: 6px 10px 6px 6px;
  }

  .dot-label {
    display: none;
  }

  .pres-dot.active .dot-label {
    display: none;
  }

  .hero-orbit {
    transform: scale(0.8); /* Scale down more on mobile */
  }

  .hero-device {
    width: min(280px, 85vw);
    min-height: 380px;
  }

  .device-map {
    height: 200px;
  }

  .slide-closing-title-premium {
    font-size: clamp(28px, 8vw, 44px);
  }
}

@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
</style>
