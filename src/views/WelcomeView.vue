<script setup lang="ts">
import { ref } from 'vue';
import { useStore } from '../store';
import { 
  ArrowRight, ShieldCheck, HeartHandshake, Zap, MapPin, 
  Mail, Lock, Phone, User, X 
} from 'lucide-vue-next';

const { state, toggleMode, login, register } = useStore();

// Modal State
const isAuthModalOpen = ref(false);
const isRegister = ref(false);

// Form States
const email = ref('');
const password = ref('');
const name = ref('');
const phone = ref('');
const selectedRole = ref<'DEMANDA' | 'OFERTA'>(state.activeMode);

// Form errors
const errors = ref({
  name: '',
  email: '',
  phone: '',
  password: ''
});

const openAuthModal = (registerMode = false) => {
  isRegister.value = registerMode;
  selectedRole.value = state.activeMode;
  errors.value = { name: '', email: '', phone: '', password: '' };
  isAuthModalOpen.value = true;
};

const closeAuthModal = () => {
  isAuthModalOpen.value = false;
};

const validateForm = () => {
  let isValid = true;
  errors.value = { name: '', email: '', phone: '', password: '' };

  if (isRegister.value) {
    if (!name.value.trim()) {
      errors.value.name = 'El nombre es obligatorio';
      isValid = false;
    } else if (/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/.test(name.value)) {
      errors.value.name = 'El nombre solo debe contener letras';
      isValid = false;
    }

    if (!phone.value.trim()) {
      errors.value.phone = 'El teléfono es obligatorio';
      isValid = false;
    } else if (!/^\d{10}$/.test(phone.value.replace(/\s+/g, ''))) {
      errors.value.phone = 'Debe ser un número de 10 dígitos';
      isValid = false;
    }
  }

  if (!email.value.trim()) {
    errors.value.email = 'El correo electrónico es obligatorio';
    isValid = false;
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
    errors.value.email = 'Correo electrónico no válido';
    isValid = false;
  }

  if (!password.value) {
    errors.value.password = 'La contraseña es obligatoria';
    isValid = false;
  } else if (password.value.length < 6) {
    errors.value.password = 'Debe tener al menos 6 caracteres';
    isValid = false;
  }

  return isValid;
};

const handleSubmit = () => {
  if (!validateForm()) return;

  if (isRegister.value) {
    register(name.value, email.value, phone.value, selectedRole.value);
  } else {
    login(email.value, selectedRole.value);
  }
};

const selectRole = (role: 'DEMANDA' | 'OFERTA') => {
  selectedRole.value = role;
};
</script>

<template>
  <div class="welcome-container">
    <!-- Portada Header (Floating brand identity and inline login button) -->
    <div class="portada-header">
      <div class="brand-logo">
        <img src="/src/assets/ofix.svg" alt="Ofix" class="brand-logo-img" />
      </div>
      <button @click="openAuthModal(false)" class="secondary-btn text-xs py-2 px-4">
        Iniciar Sesión
      </button>
    </div>

    <!-- General Message / Hero Portada Section (Now acts as a full cover, not a card) -->
    <section class="general-intro-section text-center">
      <div class="intro-badge mb-6">
        <span>🤝 Conexión Local y Garantía Fiduciaria Escrow</span>
      </div>
      
      <h1 class="hero-title mb-6">
        La forma más <span class="accent-text">segura y confiable</span> de contratar servicios en tu vecindario
      </h1>
      
      <p class="body-text max-w-2xl mx-auto mb-10 text-lg">
        Conectamos las necesidades de tu hogar con profesionales de tu zona bajo una <strong>garantía fiduciaria Escrow</strong> blindada.
      </p>

      <button @click="openAuthModal(true)" class="premium-btn mx-auto">
        <span>Comenzar ahora</span>
        <span class="icon-circle">
          <ArrowRight :size="18" />
        </span>
      </button>
    </section>

    <!-- Mode Selector Switch Centered Directly Below Intro -->
    <div class="landing-switch-wrapper text-center">
      <h3 class="switch-title mb-4 font-semibold text-muted text-xs uppercase tracking-wider">
        Selecciona un modo para explorar su funcionamiento
      </h3>
      <div class="mode-switch-base glass-panel-sm mx-auto" @click="toggleMode">
        <div :class="['mode-slider', state.activeMode.toLowerCase()]"></div>
        <span :class="['mode-label-btn', { active: state.activeMode === 'DEMANDA' }]">
          Contratar Tareas
        </span>
        <span :class="['mode-label-btn', { active: state.activeMode === 'OFERTA' }]">
          Ofrecer Oficio
        </span>
      </div>
    </div>

    <!-- Mode-Specific Details Block (Shifts content based on activeMode selection) -->
    <div class="mode-details-section">
      <div class="text-center mb-10">
        <span class="badge badge-success mb-2">
          {{ state.activeMode === 'DEMANDA' ? 'Modo Cliente' : 'Modo Proveedor Técnico' }}
        </span>
        <h2 class="section-title">
          <template v-if="state.activeMode === 'DEMANDA'">
            Resuelve problemas de tu hogar con tranquilidad
          </template>
          <template v-else>
            Haz crecer tu oficio con seguridad y libertad
          </template>
        </h2>
        <p class="body-text max-w-xl mx-auto mt-2">
          <template v-if="state.activeMode === 'DEMANDA'">
            Describe lo que necesitas, compara ofertas de profesionales verificados en tu zona y mantén tu presupuesto seguro hasta confirmar que todo quedó perfecto.
          </template>
          <template v-else>
            Accede al tablón de necesidades en tu vecindario, envía propuestas personalizadas y asegura el cobro de tus honorarios al 100% antes de salir de casa.
          </template>
        </p>
      </div>

      <!-- Features Glass Grid -->
      <div class="features-grid">
        <div class="glass-panel text-left">
          <div class="feature-icon bg-sunset">
            <Zap :size="24" class="icon-orange" />
          </div>
          <h3 class="card-title mb-2">
            <template v-if="state.activeMode === 'DEMANDA'">
              1. Publica en segundos
            </template>
            <template v-else>
              1. Busca en tu mapa
            </template>
          </h3>
          <p class="body-text">
            <template v-if="state.activeMode === 'DEMANDA'">
              Describe lo que necesitas, fija un presupuesto estimado e indica el nivel de urgencia de tu tarea.
            </template>
            <template v-else>
              Accede al tablón de tareas locales. Ofix oculta la dirección exacta para proteger la privacidad del cliente.
            </template>
          </p>
        </div>

        <div class="glass-panel text-left">
          <div class="feature-icon bg-sage">
            <HeartHandshake :size="24" class="icon-green" />
          </div>
          <h3 class="card-title mb-2">
            <template v-if="state.activeMode === 'DEMANDA'">
              2. Elige al experto
            </template>
            <template v-else>
              2. Envía tu cotización
            </template>
          </h3>
          <p class="body-text">
            <template v-if="state.activeMode === 'DEMANDA'">
              Revisa las propuestas de técnicos verificados en tu zona. Compara calificaciones, reseñas y portafolios de fotos.
            </template>
            <template v-else>
              Escribe tu propuesta técnica, propón tu tarifa o acepta el presupuesto del cliente y fija tu tiempo de llegada.
            </template>
          </p>
        </div>

        <div class="glass-panel text-left">
          <div class="feature-icon bg-obsidian">
            <ShieldCheck :size="24" class="icon-white" />
          </div>
          <h3 class="card-title mb-2">
            3. Depósito de Garantía (Escrow)
          </h3>
          <p class="body-text">
            <template v-if="state.activeMode === 'DEMANDA'">
              Tu pago se resguarda de forma segura en Escrow. Solo se libera al proveedor cuando marcas el trabajo como completado con éxito.
            </template>
            <template v-else>
              El cliente deposita los fondos en garantía antes de que salgas a trabajar. Al terminar, liberas el saldo directo a tu cuenta.
            </template>
          </p>
        </div>
      </div>
    </div>

    <!-- Local Map Promotion Card -->
    <div class="glass-panel map-promo-panel">
      <div class="map-promo-content text-left">
        <span class="badge badge-success mb-4">
          <MapPin :size="12" class="mr-1" /> Conexión Local Activa
        </span>
        <h2 class="section-title mb-4">Vecinos ayudando a vecinos</h2>
        <p class="body-text mb-6">
          Ofix mapea en tiempo real a los proveedores y clientes en tu comunidad. Usamos círculos de geolocalización difuminados de 1.5 km para cuidar tu ubicación, liberándola únicamente cuando hay un trato de confianza activo y garantizado.
        </p>
        <button @click="openAuthModal(false)" class="secondary-btn">
          Ver directorio local
        </button>
      </div>
      <div class="map-promo-visual">
        <div class="simulated-map-circle">
          <div class="simulated-pin pin-1"></div>
          <div class="simulated-pin pin-2"></div>
          <div class="simulated-pulse-area"></div>
        </div>
      </div>
    </div>

    <!-- FLOATING GLASSMORPHIC LOGIN/REGISTER MODAL -->
    <div v-if="isAuthModalOpen" class="modal-overlay" @click.self="closeAuthModal">
      <div class="modal-content glass-panel auth-modal-card text-left">
        <button @click="closeAuthModal" class="close-btn-round">
          <X :size="18" />
        </button>

        <!-- Tabs -->
        <div class="auth-tabs mb-6">
          <button 
            :class="['tab-btn', { active: !isRegister }]" 
            @click="isRegister = false"
          >
            Iniciar Sesión
          </button>
          <button 
            :class="['tab-btn', { active: isRegister }]" 
            @click="isRegister = true"
          >
            Crear Cuenta
          </button>
        </div>

        <h2 class="section-title text-center mb-2">
          {{ isRegister ? 'Únete a Ofix' : 'Te damos la bienvenida' }}
        </h2>
        <p class="body-text text-center mb-6 text-sm">
          {{ isRegister ? 'Completa tus datos para empezar de manera segura' : 'Accede a tu cuenta de prototipo con cualquier dato' }}
        </p>

        <form @submit.prevent="handleSubmit" class="auth-form">
          <!-- Name (Register Only) -->
          <div v-if="isRegister" class="form-group mb-4">
            <label class="form-label">Nombre Completo</label>
            <div class="pill-input">
              <User :size="18" class="input-icon" />
              <input 
                v-model="name" 
                type="text" 
                placeholder="Juan Pérez" 
                required
              />
            </div>
            <span v-if="errors.name" class="error-msg">{{ errors.name }}</span>
          </div>

          <!-- Email -->
          <div class="form-group mb-4">
            <label class="form-label">Correo Electrónico</label>
            <div class="pill-input">
              <Mail :size="18" class="input-icon" />
              <input 
                v-model="email" 
                type="email" 
                placeholder="correo@ejemplo.com" 
                required
              />
            </div>
            <span v-if="errors.email" class="error-msg">{{ errors.email }}</span>
          </div>

          <!-- Phone (Register Only) -->
          <div v-if="isRegister" class="form-group mb-4">
            <label class="form-label">Teléfono de Contacto</label>
            <div class="pill-input">
              <Phone :size="18" class="input-icon" />
              <input 
                v-model="phone" 
                type="tel" 
                placeholder="5512345678" 
                required
              />
            </div>
            <span v-if="errors.phone" class="error-msg">{{ errors.phone }}</span>
          </div>

          <!-- Password -->
          <div class="form-group mb-6">
            <label class="form-label">Contraseña</label>
            <div class="pill-input">
              <Lock :size="18" class="input-icon" />
              <input 
                v-model="password" 
                type="password" 
                placeholder="••••••••" 
                required
              />
            </div>
            <span v-if="errors.password" class="error-msg">{{ errors.password }}</span>
          </div>

          <!-- Role Selector Dual Card -->
          <div class="role-selector-container mb-6">
            <label class="form-label block text-left mb-2 text-xs font-semibold text-muted">¿Cuál es tu intención de ingreso?</label>
            <div class="role-cards">
              <!-- Demand Card -->
              <div 
                :class="['role-card', 'demand-card', { selected: selectedRole === 'DEMANDA' }]"
                @click="selectRole('DEMANDA')"
              >
                <div class="role-check"></div>
                <h4 class="role-title">Contratar ayuda</h4>
                <p class="role-desc">Tengo un problema en casa y busco un técnico de confianza.</p>
              </div>
              
              <!-- Offer Card -->
              <div 
                :class="['role-card', 'offer-card', { selected: selectedRole === 'OFERTA' }]"
                @click="selectRole('OFERTA')"
              >
                <div class="role-check"></div>
                <h4 class="role-title">Ofrecer servicios</h4>
                <p class="role-desc">Tengo un oficio técnico y busco trabajos cercanos.</p>
              </div>
            </div>
          </div>

          <!-- Action Button -->
          <button type="submit" class="premium-btn w-full">
            <span>{{ isRegister ? 'Crear Cuenta y Entrar' : 'Iniciar Sesión' }}</span>
            <span class="icon-circle">
              <ArrowRight :size="18" />
            </span>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.welcome-container {
  display: flex;
  flex-direction: column;
  gap: 40px;
  padding: 0 0 60px 0;
  position: relative;
}

/* Portada Floating Header */
.portada-header {
  position: absolute;
  top: 10px;
  left: 0;
  right: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  z-index: 100;
  animation: slideDown 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
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

/* General Intro Section / Portada Section */
.general-intro-section {
  min-height: 65vh; /* Occupies 2/3 of viewport height */
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 100px 24px 40px 24px; /* Spacious top padding for floating logo */
  border: none;
  background: transparent;
  box-shadow: none;
  position: relative;
  overflow: hidden;
  animation: fadeInUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.intro-badge {
  display: inline-block;
  padding: 6px 14px;
  background-color: var(--accent-light);
  color: var(--accent);
  font-family: var(--font-display);
  font-weight: 600;
  font-size: 12px;
  border-radius: var(--radius-pill);
  transition: all 0.4s ease;
}

.hero-title {
  font-family: var(--font-display);
  font-size: 62px; /* High-impact display size */
  font-weight: 800;
  letter-spacing: -0.04em; /* Tight letter-spacing for premium editorial punch */
  line-height: 1.1;
  max-width: 950px;
}

.general-intro-section .body-text {
  font-size: 21px;
  line-height: 1.65;
  max-width: 800px;
  color: var(--text-muted);
}

.mb-6 { margin-bottom: 24px; }
.mb-8 { margin-bottom: 32px; }
.mb-2 { margin-bottom: 8px; }
.mb-4 { margin-bottom: 16px; }
.mb-10 { margin-bottom: 40px; }
.mx-auto { margin-left: auto; margin-right: auto; }
.text-center { text-align: center; }
.text-left { text-align: left; }
.max-w-xl { max-w: 580px; }
.max-w-2xl { max-w: 720px; }
.text-lg { font-size: 18px; line-height: 1.6; }

.accent-text {
  color: var(--accent);
  font-weight: 800;
  transition: color 0.4s ease;
}

/* Landing Switch Wrapper */
.landing-switch-wrapper {
  padding: 10px 0;
  animation: fadeInUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both;
}

.switch-title {
  font-size: 11px;
  letter-spacing: 0.1em;
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
  width: fit-content;
  max-width: 100%;
}

.mode-label-btn {
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 600;
  color: var(--text-muted);
  padding: 10px 24px;
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

/* Mode details section */
.mode-details-section {
  animation: fadeIn 0.6s ease-in-out;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-top: 20px;
}

.feature-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
}

.bg-sunset { background-color: var(--accent-light); }
.bg-sage { background-color: var(--accent-light); }
.bg-obsidian { background-color: var(--obsidian-ceramic); }

.icon-orange { color: var(--sunset-orange); }
.icon-green { color: var(--verde-terraria); }
.icon-white { color: #ffffff; }

/* Map Promo Panel */
.map-promo-panel {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 40px;
  padding: 40px;
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.map-promo-content {
  flex: 1;
}

.map-promo-visual {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 240px;
}

.simulated-map-circle {
  width: 220px;
  height: 220px;
  border-radius: 50%;
  background: radial-gradient(circle, #EBE3DA 0%, #DED6CD 100%);
  border: 1px solid var(--frost-border);
  position: relative;
  box-shadow: inset 0 4px 10px rgba(0,0,0,0.05), 0 10px 24px -10px var(--clay-shadow);
}

.simulated-pin {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  border: 2px solid #ffffff;
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

.pin-1 {
  background-color: var(--sunset-orange);
  top: 30%;
  left: 40%;
}

.pin-2 {
  background-color: var(--verde-terraria);
  top: 60%;
  left: 70%;
}

.simulated-pulse-area {
  position: absolute;
  top: 20%;
  left: 20%;
  width: 100px;
  height: 100px;
  border-radius: 50%;
  border: 1px dashed var(--accent);
  background-color: var(--accent-glow);
  opacity: 0.4;
  animation: floatCircle 4s ease-in-out infinite alternate;
}

/* Modal specific styles */
.auth-modal-card {
  width: 100%;
  max-width: 500px;
  border-radius: var(--radius-lg);
  padding: 40px 32px;
  position: relative;
}

.close-btn-round {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 1px solid var(--frost-border);
  background: rgba(255, 255, 255, 0.4);
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  outline: none; /* Removes outline completely */
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}

.close-btn-round:hover {
  background: #ffffff;
  color: var(--accent);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.close-btn-round:focus {
  outline: none; /* Ensures no outline when active */
}

.auth-tabs {
  display: flex;
  background-color: rgba(24, 27, 25, 0.05);
  border-radius: var(--radius-pill);
  padding: 4px;
}

.tab-btn {
  flex: 1;
  background: transparent;
  border: none;
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 500;
  color: var(--text-muted);
  padding: 10px 16px;
  border-radius: var(--radius-pill);
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab-btn.active {
  background-color: #ffffff;
  color: var(--text-dark);
  box-shadow: 0 4px 12px -4px var(--clay-shadow);
}

.auth-form {
  display: flex;
  flex-direction: column;
}

.form-group {
  display: flex;
  flex-direction: column;
  text-align: left;
}

.form-label {
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 500;
  color: var(--text-muted);
  margin-bottom: 6px;
  padding-left: 12px;
}

.input-icon {
  color: #a19890;
}

.error-msg {
  color: #d32f2f;
  font-size: 11px;
  margin-top: 4px;
  padding-left: 12px;
}

.role-cards {
  display: flex;
  gap: 16px;
  flex-direction: row;
}

.role-card {
  flex: 1;
  border: 1px solid var(--frost-border);
  border-radius: var(--radius-md);
  padding: 16px;
  background-color: rgba(255, 255, 255, 0.4);
  cursor: pointer;
  position: relative;
  text-align: left;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.role-card:hover {
  background-color: rgba(255, 255, 255, 0.6);
  border-color: var(--accent);
}

.role-card.selected {
  background-color: #ffffff;
  border-color: var(--accent);
  box-shadow: 0 8px 24px -8px var(--clay-shadow);
}

.role-check {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid var(--frost-border);
  position: absolute;
  top: 16px;
  right: 16px;
  transition: all 0.3s ease;
}

.role-card.selected .role-check {
  border-color: var(--accent);
  background-color: var(--accent);
}

.role-card.selected .role-check::after {
  content: '';
  position: absolute;
  top: 3px;
  left: 3px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: #ffffff;
}

.role-title {
  font-family: var(--font-display);
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 4px;
  color: var(--text-dark);
}

.role-desc {
  font-size: 11px;
  color: var(--text-muted);
  line-height: 1.4;
}

/* Animations */
@keyframes floatCircle {
  0% { transform: translateY(-5px) scale(0.95); }
  100% { transform: translateY(5px) scale(1.05); }
}

@keyframes slideDown {
  from { transform: translateY(-20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes fadeInUp {
  from { transform: translateY(30px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.98); }
  to { opacity: 1; transform: scale(1); }
}

@media (max-width: 768px) {
  .welcome-container {
    padding: 10px 10px 40px 10px;
  }
  
  .hero-title {
    font-size: 34px;
    line-height: 1.15;
  }
  
  .general-intro-section {
    padding: 60px 16px 30px 16px;
    min-height: auto;
  }
  
  .map-promo-panel {
    flex-direction: column;
    padding: 24px;
  }
  
  .map-promo-visual {
    min-height: 180px;
  }
  
  .role-cards {
    flex-direction: column;
    gap: 12px;
  }
}
</style>
