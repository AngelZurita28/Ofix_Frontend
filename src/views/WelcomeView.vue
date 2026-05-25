<script setup lang="ts">
import { computed, ref } from 'vue';
import { useStore } from '../store';
import {
  ArrowRight,
  BadgeCheck,
  CircleDollarSign,
  ClipboardList,
  Clock,
  EyeOff,
  HeartHandshake,
  Lock,
  Mail,
  MapPin,
  MapPinned,
  MessageCircle,
  Navigation,
  Phone,
  Search,
  Send,
  ShieldCheck,
  Sparkles,
  Star,
  Store,
  User,
  Wrench,
  X
} from 'lucide-vue-next';

type LandingMode = 'DEMANDA' | 'OFERTA';

const { state, setMode, login, register } = useStore();

const isAuthModalOpen = ref(false);
const isRegister = ref(false);

const email = ref('');
const password = ref('');
const name = ref('');
const phone = ref('');
const selectedRole = ref<LandingMode>(state.activeMode);

const errors = ref({
  name: '',
  email: '',
  phone: '',
  password: ''
});

const modeCopy = {
  DEMANDA: {
    badge: 'Modo Necesito',
    eyebrow: 'Publica una necesidad, recibe postulaciones locales',
    title: 'Cuando algo urge en casa, Ofix convierte tu necesidad en un trabajo claro.',
    highlight: 'Tablon de tareas',
    question: '¿Que necesitas resolver hoy?',
    promise:
      'El usuario no empieza buscando perfiles. Empieza contando un problema concreto y Ofix lo convierte en una solicitud estructurada para que otros puedan postularse.',
    surfaceTitle: 'La pantalla se comporta como un tablon vivo',
    surfaceText:
      'Ordena tareas por urgencia, presupuesto, categoria y cercania aproximada. La informacion importante es la necesidad, no el vendedor.',
    primaryObject: 'Tarea publicada',
    examples: ['Fuga en cocina', 'Instalar minisplit', 'Maquillaje para evento', 'Reparar porton'],
    modules: [
      {
        label: 'Entrada',
        title: 'Formulario narrativo',
        text: 'Captura problema, fotos, presupuesto estimado, horario y urgencia sin pedir la direccion exacta desde el inicio.'
      },
      {
        label: 'Vista',
        title: 'Postulaciones comparables',
        text: 'Cada proveedor responde con llegada estimada, precio, propuesta tecnica y señales de reputacion.'
      },
      {
        label: 'Decision',
        title: 'Aceptar antes de revelar',
        text: 'La direccion fina se desbloquea despues del acuerdo, con el pago en garantia listo para activar la visita.'
      }
    ],
    description:
      'Crea una tarea con presupuesto, urgencia y zona aproximada. Los proveedores cercanos se postulan y solo revelas tu direccion exacta cuando ya existe un trato aceptado.',
    cta: 'Publicar mi necesidad',
    secondary: 'Ver como se protege mi ubicacion',
    previewTitle: 'Fuga debajo de tarja',
    previewLabel: 'Tarea publicada',
    previewMeta: 'Zona Centro, Monclova',
    previewPrice: '$650 MXN',
    previewStatus: '3 postulantes',
    locationPublic: 'Zona Centro, Monclova',
    locationPrivate: 'Direccion exacta bloqueada',
    boardTitle: 'Postulaciones entrantes',
    boardItems: [
      'Mateo G. puede llegar en 25 min',
      'Valeria S. confirma refacciones',
      'Alejandro R. sugiere visita manana'
    ],
    metrics: [
      { value: '1.5 km', label: 'radio visible' },
      { value: '3 pasos', label: 'para publicar' },
      { value: 'Escrow', label: 'pago resguardado' }
    ],
    flow: [
      {
        icon: ClipboardList,
        title: 'Describe la tarea',
        text: 'Problema, fotos, presupuesto estimado y nivel de urgencia.'
      },
      {
        icon: Search,
        title: 'Compara postulantes',
        text: 'Recibe propuestas de talento cercano con reputacion y tiempos.'
      },
      {
        icon: EyeOff,
        title: 'Privacidad por fases',
        text: 'Primero se muestra la zona. La direccion exacta se libera al aceptar.'
      }
    ],
    rail: [
      'Publicacion con presupuesto',
      'Postulacion de proveedores',
      'Aceptacion y deposito Escrow',
      'Direccion exacta desbloqueada'
    ]
  },
  OFERTA: {
    badge: 'Modo Ofrezco',
    eyebrow: 'Explora talento, perfiles y negocios mexicanos',
    title: 'Cuando buscas calidad, Ofix te deja explorar quien sabe resolverlo.',
    highlight: 'Directorio de perfiles',
    question: '¿Quien puede hacerlo mejor?',
    promise:
      'El usuario no publica primero. Explora talento local, compara perfiles y contacta directamente a quien ya demuestra experiencia.',
    surfaceTitle: 'La pantalla se comporta como un catalogo de talento',
    surfaceText:
      'Prioriza categorias, portafolios, reseñas, disponibilidad y precios. La informacion importante es la capacidad comprobable del proveedor.',
    primaryObject: 'Perfil de proveedor',
    examples: ['Plomeria', 'Construccion', 'Maquillaje', 'Clases particulares'],
    modules: [
      {
        label: 'Entrada',
        title: 'Busqueda por categoria',
        text: 'Permite explorar oficios, servicios fisicos o virtuales, negocios pequeños y talento independiente por zona.'
      },
      {
        label: 'Vista',
        title: 'Perfiles con evidencia',
        text: 'Muestra galeria, reseñas, trabajos completados, precio base, tiempo de respuesta e insignias de confianza.'
      },
      {
        label: 'Decision',
        title: 'Oferta directa contextual',
        text: 'El cliente inicia contacto explicando necesidad, fecha y presupuesto para convertir el perfil en una contratacion.'
      }
    ],
    description:
      'Navega por categorias, revisa portafolios, reputacion y disponibilidad. Contacta directo a un proveedor o pequeno negocio con una solicitud precisa de trabajo.',
    cta: 'Explorar talento local',
    secondary: 'Ver categorias disponibles',
    previewTitle: 'Mateo Gonzalez',
    previewLabel: 'Perfil verificado',
    previewMeta: 'Fontaneria - responde en 10 min',
    previewPrice: '$220 / hora',
    previewStatus: '4.9 estrellas',
    locationPublic: 'Disponible en tu zona',
    locationPrivate: 'Agenda y detalles por confirmar',
    boardTitle: 'Perfil destacado',
    boardItems: [
      '84 trabajos completados',
      'Portafolio con reparaciones reales',
      'Insignias: Puntual, Identidad verificada'
    ],
    metrics: [
      { value: '12+', label: 'categorias' },
      { value: '10 min', label: 'respuesta media' },
      { value: '4.9', label: 'reputacion visible' }
    ],
    flow: [
      {
        icon: Store,
        title: 'Explora por categoria',
        text: 'Construccion, plomeria, maquillaje, clases, reparaciones y mas.'
      },
      {
        icon: Star,
        title: 'Evalua perfiles',
        text: 'Fotos, reseñas, experiencia, precio y disponibilidad antes de contactar.'
      },
      {
        icon: Send,
        title: 'Lanza oferta directa',
        text: 'Explica que necesitas, fecha, presupuesto y condiciones de visita.'
      }
    ],
    rail: [
      'Busqueda por categoria',
      'Perfil, portafolio y reseñas',
      'Solicitud directa al proveedor',
      'Escrow antes de revelar detalles finales'
    ]
  }
} as const;

const currentMode = computed(() => modeCopy[state.activeMode]);
const isDemandMode = computed(() => state.activeMode === 'DEMANDA');

const switchMode = (mode: LandingMode) => {
  setMode(mode);
  selectedRole.value = mode;
};

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

const selectRole = (role: LandingMode) => {
  selectedRole.value = role;
};
</script>

<template>
  <div class="welcome-container" :class="{ 'is-demand': isDemandMode, 'is-offer': !isDemandMode }">
    <div class="landing-grain" aria-hidden="true"></div>

    <header class="portada-header">
      <button class="brand-logo" type="button" aria-label="Ofix">
        <img src="/src/assets/ofix.svg" alt="Ofix" class="brand-logo-img" />
      </button>
      <nav class="landing-nav" aria-label="Secciones principales">
        <div class="nav-mode-switch" role="tablist" aria-label="Cambiar modo de Ofix">
          <button
            type="button"
            :class="{ active: isDemandMode }"
            role="tab"
            :aria-selected="isDemandMode"
            @click="switchMode('DEMANDA')"
          >
            Contratar a profesionales
          </button>
          <button
            type="button"
            :class="{ active: !isDemandMode }"
            role="tab"
            :aria-selected="!isDemandMode"
            @click="switchMode('OFERTA')"
          >
            Ofrecer Servicio
          </button>
        </div>
        <a href="#flujo">Flujo</a>
        <a href="#confianza">Confianza</a>
      </nav>
      <button @click="openAuthModal(false)" class="secondary-btn login-btn">
        Iniciar sesion
      </button>
    </header>

    <section class="hero-stage">
      <div class="hero-copy">
        <div class="intro-badge">
          <Sparkles :size="14" />
          <span>Conexión local mexicana con garantía Escrow</span>
        </div>

        <h1 class="hero-title">
          Una sola plataforma para pedir ayuda o descubrir talento local.
        </h1>

        <p class="hero-lede">
          Ofix conecta consumidores con proveedores y pequeños negocios cercanos mediante un switch dual:
          <strong>Necesito</strong> para publicar tareas y <strong>Ofrezco</strong> para explorar perfiles.
        </p>

        <div class="hero-actions">
          <button @click="openAuthModal(true)" class="premium-btn">
            <span>Comenzar ahora</span>
            <span class="icon-circle">
              <ArrowRight :size="18" />
            </span>
          </button>
        </div>
      </div>

      <div class="hero-orbit" aria-hidden="true">
        <div class="orbit-card orbit-card-demand">
          <ClipboardList :size="18" />
          <span>Necesito</span>
          <strong>Publicar tarea</strong>
        </div>
        <div class="hero-device glass-panel">
          <div class="device-topline">
            <span class="status-dot"></span>
            <span>Ofix switch activo</span>
          </div>
          <div class="device-switch">
            <span :class="{ active: isDemandMode }">Necesito</span>
            <span :class="{ active: !isDemandMode }">Ofrezco</span>
            <div :class="['device-slider', state.activeMode.toLowerCase()]"></div>
          </div>
          <div class="device-map">
            <div class="map-line line-a"></div>
            <div class="map-line line-b"></div>
            <div class="map-zone"></div>
            <span class="map-pin-home"><MapPin :size="16" /></span>
            <span class="map-pin-pro"><Wrench :size="15" /></span>
          </div>
          <div class="device-bottom">
            <span>{{ currentMode.previewLabel }}</span>
            <strong>{{ currentMode.previewStatus }}</strong>
          </div>
        </div>
        <div class="orbit-card orbit-card-offer">
          <Store :size="18" />
          <span>Ofrezco</span>
          <strong>Explorar perfiles</strong>
        </div>
      </div>
    </section>

    <section id="switch" class="switch-lab glass-panel">
      <div class="switch-lab-copy">
        <span class="badge badge-mode">{{ currentMode.badge }}</span>
        <h2 class="section-title">{{ currentMode.highlight }}</h2>
        <p class="body-text">{{ currentMode.description }}</p>
      </div>

      <div class="mode-toggle" role="tablist" aria-label="Modo de exploración">
        <button
          type="button"
          :class="['mode-option', { active: isDemandMode }]"
          role="tab"
          :aria-selected="isDemandMode"
          @click="switchMode('DEMANDA')"
        >
          <ClipboardList :size="18" />
          <span>Necesito</span>
          <small>Publicar trabajo</small>
        </button>
        <button
          type="button"
          :class="['mode-option', { active: !isDemandMode }]"
          role="tab"
          :aria-selected="!isDemandMode"
          @click="switchMode('OFERTA')"
        >
          <Store :size="18" />
          <span>Ofrezco</span>
          <small>Ver perfiles</small>
        </button>
      </div>
    </section>

    <section class="communication-section">
      <div class="section-heading">
        <span class="badge badge-mode">Lectura del producto</span>
        <h2 class="section-title">Cada modo habla con una intención diferente.</h2>
      </div>

      <Transition name="mode-shift" mode="out-in">
        <div :key="`comm-${state.activeMode}`" class="communication-grid">
          <article class="glass-panel communication-card intent-card">
            <span class="communication-label">Pregunta inicial</span>
            <h3>{{ currentMode.question }}</h3>
            <p class="body-text">{{ currentMode.promise }}</p>
            <div class="example-cloud" aria-label="Ejemplos del modo activo">
              <span v-for="example in currentMode.examples" :key="example">{{ example }}</span>
            </div>
          </article>

          <article class="glass-panel communication-card surface-card">
            <span class="communication-label">Objeto principal</span>
            <h3>{{ currentMode.primaryObject }}</h3>
            <p class="body-text">{{ currentMode.surfaceText }}</p>
            <div class="surface-token">
              <ClipboardList v-if="isDemandMode" :size="22" />
              <Store v-else :size="22" />
              <strong>{{ currentMode.surfaceTitle }}</strong>
            </div>
          </article>

          <div class="module-stack">
            <article v-for="module in currentMode.modules" :key="module.title" class="module-note">
              <span>{{ module.label }}</span>
              <h4>{{ module.title }}</h4>
              <p>{{ module.text }}</p>
            </article>
          </div>
        </div>
      </Transition>
    </section>

    <Transition name="mode-shift" mode="out-in">
      <section :key="state.activeMode" class="mode-showcase">
        <div class="mode-story">
          <span class="mode-eyebrow">{{ currentMode.eyebrow }}</span>
          <h2 class="mode-title">{{ currentMode.title }}</h2>
          <p class="body-text">
            La diferencia no es cosmetica: cambia el objeto principal de la pantalla.
            En un modo ves trabajos publicados; en el otro ves perfiles y catalogos.
          </p>

          <div class="mode-actions">
            <button @click="openAuthModal(true)" class="premium-btn">
              <span>{{ currentMode.cta }}</span>
              <span class="icon-circle">
                <ArrowRight :size="18" />
              </span>
            </button>
            <button @click="openAuthModal(false)" class="secondary-btn">
              {{ currentMode.secondary }}
            </button>
          </div>

          <div class="metric-strip">
            <div v-for="metric in currentMode.metrics" :key="metric.label" class="metric-item">
              <strong>{{ metric.value }}</strong>
              <span>{{ metric.label }}</span>
            </div>
          </div>
        </div>

        <div class="product-preview">
          <div class="preview-shell">
            <div class="preview-header">
              <span class="preview-kicker">{{ currentMode.previewLabel }}</span>
              <span class="preview-chip">
                <Clock :size="13" />
                {{ isDemandMode ? 'Urgencia visible' : 'Disponibilidad visible' }}
              </span>
            </div>

            <div class="preview-main-card">
              <div class="preview-icon">
                <ClipboardList v-if="isDemandMode" :size="26" />
                <Store v-else :size="26" />
              </div>
              <div>
                <h3>{{ currentMode.previewTitle }}</h3>
                <p>{{ currentMode.previewMeta }}</p>
              </div>
              <strong>{{ currentMode.previewPrice }}</strong>
            </div>

            <div class="privacy-band">
              <div>
                <span>Fase publica</span>
                <strong>{{ currentMode.locationPublic }}</strong>
              </div>
              <div>
                <span>Fase de contacto</span>
                <strong>{{ currentMode.locationPrivate }}</strong>
              </div>
            </div>

            <div class="preview-grid">
              <div class="local-map">
                <div class="map-road road-one"></div>
                <div class="map-road road-two"></div>
                <div class="map-radius"></div>
                <span class="pin pin-main"><MapPinned :size="16" /></span>
                <span class="pin pin-alt"><Navigation :size="15" /></span>
              </div>
              <div class="feed-card">
                <span>{{ currentMode.boardTitle }}</span>
                <ul>
                  <li v-for="item in currentMode.boardItems" :key="item">{{ item }}</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>
    </Transition>

    <section id="flujo" class="flow-section">
      <div class="section-heading">
        <span class="badge badge-success">Arquitectura dual</span>
        <h2 class="section-title">El switch cambia la intención, no solo el color.</h2>
      </div>

      <div class="flow-grid">
        <article v-for="step in currentMode.flow" :key="step.title" class="glass-panel flow-card">
          <div class="feature-icon">
            <component :is="step.icon" :size="23" />
          </div>
          <h3 class="card-title">{{ step.title }}</h3>
          <p class="body-text">{{ step.text }}</p>
        </article>
      </div>

      <div class="timeline-panel glass-panel">
        <div class="timeline-copy">
          <span class="mode-eyebrow">Lo que ve el usuario</span>
          <h3>{{ isDemandMode ? 'Tablon de tareas por resolver' : 'Catalogo vivo de talento local' }}</h3>
          <p class="body-text">
            Cada paso mantiene confianza, rapidez y cercania geografica sin exponer datos sensibles antes de tiempo.
          </p>
        </div>
        <ol class="timeline-list">
          <li v-for="(item, index) in currentMode.rail" :key="item">
            <span>{{ index + 1 }}</span>
            <p>{{ item }}</p>
          </li>
        </ol>
      </div>
    </section>

    <section id="confianza" class="trust-section">
      <div class="trust-card glass-panel">
        <div class="trust-icon">
          <ShieldCheck :size="34" />
        </div>
        <div>
          <span class="badge badge-warning">Garantia fiduciaria</span>
          <h2 class="section-title">Escrow crea confianza antes de que alguien toque la puerta.</h2>
          <p class="body-text">
            El pago se resguarda, la ubicacion exacta se protege por fases y la conversacion queda conectada
            al trabajo acordado. Asi Ofix se siente cercano sin sacrificar seguridad.
          </p>
        </div>
      </div>

      <div class="trust-grid">
        <div class="trust-mini">
          <BadgeCheck :size="20" />
          <strong>Identidad verificada</strong>
          <span>Perfiles y postulaciones con reputacion visible.</span>
        </div>
        <div class="trust-mini">
          <CircleDollarSign :size="20" />
          <strong>Pago protegido</strong>
          <span>Los fondos se liberan al cerrar el trabajo.</span>
        </div>
        <div class="trust-mini">
          <MessageCircle :size="20" />
          <strong>Contacto contextual</strong>
          <span>Solicitud, oferta y chat viven en un mismo flujo.</span>
        </div>
        <div class="trust-mini">
          <HeartHandshake :size="20" />
          <strong>Cercania real</strong>
          <span>Vecinos, oficios y negocios de la zona.</span>
        </div>
      </div>
    </section>

    <div v-if="isAuthModalOpen" class="modal-overlay" @click.self="closeAuthModal">
      <div class="modal-content glass-panel auth-modal-card text-left">
        <button @click="closeAuthModal" class="close-btn-round" type="button" aria-label="Cerrar">
          <X :size="18" />
        </button>

        <div class="auth-tabs mb-6">
          <button
            type="button"
            :class="['tab-btn', { active: !isRegister }]"
            @click="isRegister = false"
          >
            Iniciar Sesión
          </button>
          <button
            type="button"
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
          <div v-if="isRegister" class="form-group mb-4">
            <label class="form-label" for="auth-name">Nombre Completo</label>
            <div class="pill-input">
              <User :size="18" class="input-icon" />
              <input
                id="auth-name"
                v-model="name"
                type="text"
                placeholder="Juan Pérez"
                required
              />
            </div>
            <span v-if="errors.name" class="error-msg">{{ errors.name }}</span>
          </div>

          <div class="form-group mb-4">
            <label class="form-label" for="auth-email">Correo Electrónico</label>
            <div class="pill-input">
              <Mail :size="18" class="input-icon" />
              <input
                id="auth-email"
                v-model="email"
                type="email"
                placeholder="correo@ejemplo.com"
                required
              />
            </div>
            <span v-if="errors.email" class="error-msg">{{ errors.email }}</span>
          </div>

          <div v-if="isRegister" class="form-group mb-4">
            <label class="form-label" for="auth-phone">Teléfono de Contacto</label>
            <div class="pill-input">
              <Phone :size="18" class="input-icon" />
              <input
                id="auth-phone"
                v-model="phone"
                type="tel"
                placeholder="5512345678"
                required
              />
            </div>
            <span v-if="errors.phone" class="error-msg">{{ errors.phone }}</span>
          </div>

          <div class="form-group mb-6">
            <label class="form-label" for="auth-password">Contraseña</label>
            <div class="pill-input">
              <Lock :size="18" class="input-icon" />
              <input
                id="auth-password"
                v-model="password"
                type="password"
                placeholder="••••••••"
                required
              />
            </div>
            <span v-if="errors.password" class="error-msg">{{ errors.password }}</span>
          </div>

          <div class="role-selector-container mb-6">
            <label class="form-label block text-left mb-2 text-xs font-semibold text-muted">
              ¿Cuál es tu intención de ingreso?
            </label>
            <div class="role-cards">
              <div
                :class="['role-card', 'demand-card', { selected: selectedRole === 'DEMANDA' }]"
                role="button"
                tabindex="0"
                @click="selectRole('DEMANDA')"
                @keydown.enter.prevent="selectRole('DEMANDA')"
              >
                <div class="role-check"></div>
                <h4 class="role-title">Contratar ayuda</h4>
                <p class="role-desc">Tengo un problema en casa y busco un técnico de confianza.</p>
              </div>

              <div
                :class="['role-card', 'offer-card', { selected: selectedRole === 'OFERTA' }]"
                role="button"
                tabindex="0"
                @click="selectRole('OFERTA')"
                @keydown.enter.prevent="selectRole('OFERTA')"
              >
                <div class="role-check"></div>
                <h4 class="role-title">Ofrecer servicios</h4>
                <p class="role-desc">Tengo un oficio técnico y busco trabajos cercanos.</p>
              </div>
            </div>
          </div>

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
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 34px;
  padding: 0 0 72px;
  isolation: isolate;
}

.landing-grain {
  position: fixed;
  inset: 0;
  z-index: -1;
  pointer-events: none;
  opacity: 0.18;
  background-image:
    linear-gradient(90deg, rgba(24, 27, 25, 0.04) 1px, transparent 1px),
    linear-gradient(rgba(24, 27, 25, 0.035) 1px, transparent 1px);
  background-size: 54px 54px;
  mask-image: linear-gradient(to bottom, black, transparent 82%);
}

.portada-header {
  position: sticky;
  top: 10px;
  z-index: 100;
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 14px;
  padding: 9px 12px 9px 16px;
  border: 1px solid var(--frost-border);
  border-radius: var(--radius-pill);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.72), rgba(255, 255, 255, 0.34)),
    var(--frost-bg);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  box-shadow: 0 18px 44px -28px rgba(24, 27, 25, 0.28);
  animation: slideDown 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.brand-logo {
  display: inline-flex;
  align-items: center;
  width: fit-content;
  border: 0;
  background: transparent;
  cursor: pointer;
}

.brand-logo-img {
  height: 28px;
  display: block;
  object-fit: contain;
}

.landing-nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.nav-mode-switch {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
  padding: 4px;
  border: 1px solid rgba(255, 255, 255, 0.58);
  border-radius: var(--radius-pill);
  background: rgba(24, 27, 25, 0.055);
}

.nav-mode-switch button {
  border: 0;
  border-radius: var(--radius-pill);
  padding: 8px 13px;
  color: var(--text-muted);
  background: transparent;
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 800;
  white-space: nowrap;
  cursor: pointer;
  transition: color 0.25s ease, background-color 0.25s ease, box-shadow 0.25s ease;
}

.nav-mode-switch button.active {
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 10px 22px -16px var(--accent);
}

.landing-nav a,
.ghost-link {
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 600;
  text-decoration: none;
  border-radius: var(--radius-pill);
  padding: 9px 13px;
}

.landing-nav a:hover,
.ghost-link:hover {
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.54);
}

.login-btn {
  padding: 9px 17px;
  font-size: 13px;
}

.hero-stage {
  min-height: calc(100vh - 112px);
  display: grid;
  grid-template-columns: minmax(0, 1.02fr) minmax(360px, 0.78fr);
  align-items: center;
  gap: clamp(28px, 6vw, 80px);
  padding: 16px 10px 34px;
}

.hero-copy {
  max-width: 780px;
  animation: fadeInUp 0.75s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.intro-badge,
.mode-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  width: fit-content;
  color: var(--accent-text);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.58), rgba(255, 255, 255, 0.18)),
    var(--accent-light);
  border: 1px solid color-mix(in srgb, var(--accent) 24%, transparent);
  border-radius: var(--radius-pill);
  padding: 8px 13px;
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 700;
}

.hero-title {
  max-width: 860px;
  margin: 22px 0 22px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: clamp(44px, 8vw, 92px);
  font-weight: 800;
  line-height: 0.93;
  letter-spacing: 0;
}

.hero-lede {
  max-width: 680px;
  color: var(--text-muted);
  font-size: clamp(18px, 2vw, 22px);
  line-height: 1.58;
}

.hero-lede strong {
  color: var(--text-dark);
}

.hero-actions,
.mode-actions {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 14px;
  margin-top: 30px;
}

.hero-orbit {
  position: relative;
  min-height: 620px;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: floatIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.08s both;
}

.hero-orbit::before {
  content: '';
  position: absolute;
  width: min(520px, 82vw);
  aspect-ratio: 1;
  border-radius: 50%;
  background:
    radial-gradient(circle at 50% 42%, var(--accent-glow), transparent 58%),
    conic-gradient(from 180deg, rgba(255, 130, 53, 0.24), rgba(59, 96, 67, 0.22), rgba(255, 255, 255, 0.1), rgba(255, 130, 53, 0.24));
  filter: blur(6px);
  opacity: 0.82;
}

.hero-device {
  position: relative;
  width: min(390px, 92vw);
  min-height: 510px;
  padding: 20px;
  border-radius: 38px;
  transform: rotate(-2deg);
  box-shadow:
    0 34px 90px -44px rgba(24, 27, 25, 0.48),
    inset 0 1px 0 rgba(255, 255, 255, 0.82);
}

.device-topline,
.device-bottom,
.preview-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 700;
}

.status-dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: 0 0 0 7px var(--accent-glow);
}

.device-switch {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
  margin: 22px 0;
  padding: 5px;
  border-radius: var(--radius-pill);
  background: rgba(24, 27, 25, 0.06);
}

.device-switch span {
  position: relative;
  z-index: 2;
  text-align: center;
  padding: 12px 10px;
  border-radius: var(--radius-pill);
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 13px;
  font-weight: 800;
}

.device-switch span.active {
  color: #ffffff;
}

.device-slider {
  position: absolute;
  top: 5px;
  bottom: 5px;
  width: calc(50% - 5px);
  border-radius: var(--radius-pill);
  background: var(--accent);
  box-shadow: 0 10px 22px -12px var(--accent);
  transition: transform 0.42s cubic-bezier(0.16, 1, 0.3, 1), background-color 0.3s ease;
}

.device-slider.demanda {
  transform: translateX(0);
}

.device-slider.oferta {
  transform: translateX(calc(100% + 0px));
}

.device-map {
  position: relative;
  height: 310px;
  overflow: hidden;
  border-radius: 30px;
  background:
    radial-gradient(circle at 32% 35%, var(--accent-glow), transparent 26%),
    linear-gradient(135deg, #ebe3da, #f8f3ed);
  border: 1px solid rgba(255, 255, 255, 0.72);
  box-shadow: inset 0 16px 38px rgba(105, 95, 87, 0.09);
}

.map-line,
.map-road {
  position: absolute;
  border-radius: var(--radius-pill);
  background: rgba(105, 95, 87, 0.11);
}

.line-a {
  width: 360px;
  height: 34px;
  top: 76px;
  left: -42px;
  transform: rotate(-18deg);
}

.line-b {
  width: 280px;
  height: 26px;
  bottom: 76px;
  right: -62px;
  transform: rotate(32deg);
}

.map-zone {
  position: absolute;
  width: 148px;
  height: 148px;
  left: 88px;
  top: 84px;
  border-radius: 50%;
  border: 1px dashed var(--accent);
  background: var(--accent-glow);
  animation: pulseSoft 3.8s ease-in-out infinite alternate;
}

.map-pin-home,
.map-pin-pro,
.pin {
  position: absolute;
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 14px 24px -12px rgba(24, 27, 25, 0.42);
}

.map-pin-home {
  top: 128px;
  left: 142px;
}

.map-pin-pro {
  right: 76px;
  bottom: 78px;
  background: var(--obsidian-ceramic);
}

.device-bottom {
  margin-top: 18px;
}

.device-bottom strong {
  color: var(--text-dark);
}

.orbit-card {
  position: absolute;
  z-index: 2;
  display: grid;
  gap: 5px;
  min-width: 160px;
  padding: 16px;
  border-radius: 24px;
  border: 1px solid var(--frost-border);
  background: rgba(255, 255, 255, 0.58);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
  box-shadow: 0 22px 48px -34px rgba(24, 27, 25, 0.38);
  font-family: var(--font-display);
}

.orbit-card span {
  color: var(--text-muted);
  font-size: 12px;
  font-weight: 700;
}

.orbit-card strong {
  color: var(--text-dark);
  font-size: 15px;
}

.orbit-card-demand {
  top: 72px;
  left: 0;
  color: var(--sunset-orange-dark);
}

.orbit-card-offer {
  right: 0;
  bottom: 96px;
  color: var(--verde-terraria);
}

.switch-lab {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 28px;
  align-items: center;
  padding: clamp(20px, 4vw, 34px);
}

.switch-lab-copy {
  max-width: 580px;
}

.switch-lab-copy .section-title {
  margin: 10px 0;
  font-size: clamp(30px, 4vw, 48px);
  font-weight: 800;
}

.badge-mode {
  background: var(--accent-light);
  color: var(--accent-text);
}

.mode-toggle {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  min-width: min(430px, 100%);
  padding: 8px;
  border-radius: 32px;
  background: rgba(24, 27, 25, 0.055);
  border: 1px solid rgba(255, 255, 255, 0.56);
}

.mode-option {
  display: grid;
  justify-items: start;
  gap: 3px;
  min-height: 92px;
  padding: 16px;
  border: 0;
  border-radius: 24px;
  color: var(--text-muted);
  background: transparent;
  font-family: var(--font-display);
  cursor: pointer;
}

.mode-option span {
  color: var(--text-dark);
  font-size: 17px;
  font-weight: 800;
}

.mode-option small {
  font-size: 12px;
  font-weight: 700;
}

.mode-option.active {
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 18px 34px -24px var(--accent);
}

.mode-option.active span,
.mode-option.active small {
  color: #ffffff;
}

.communication-section {
  display: grid;
  gap: 20px;
  padding-top: 12px;
}

.communication-grid {
  display: grid;
  grid-template-columns: minmax(0, 0.95fr) minmax(0, 0.9fr) minmax(280px, 0.78fr);
  gap: 18px;
  align-items: stretch;
}

.communication-card {
  display: flex;
  flex-direction: column;
  min-height: 330px;
  padding: 28px;
}

.communication-label {
  width: fit-content;
  color: var(--accent-text);
  background: var(--accent-light);
  border: 1px solid color-mix(in srgb, var(--accent) 22%, transparent);
  border-radius: var(--radius-pill);
  padding: 7px 11px;
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.communication-card h3 {
  margin: 20px 0 12px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: clamp(28px, 3.3vw, 42px);
  font-weight: 800;
  line-height: 1;
}

.example-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 9px;
  margin-top: auto;
  padding-top: 24px;
}

.example-cloud span {
  border: 1px solid rgba(255, 255, 255, 0.72);
  border-radius: var(--radius-pill);
  padding: 9px 12px;
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.52);
  font-size: 12px;
  font-weight: 800;
}

.surface-card {
  background:
    linear-gradient(145deg, rgba(24, 27, 25, 0.88), rgba(24, 27, 25, 0.72)),
    var(--obsidian-ceramic);
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
  gap: 12px;
  align-items: center;
  margin-top: auto;
  padding: 15px;
  border-radius: 22px;
  color: #ffffff;
  background: var(--accent);
}

.surface-token strong {
  font-family: var(--font-display);
  font-size: 15px;
  line-height: 1.2;
}

.module-stack {
  display: grid;
  gap: 12px;
}

.module-note {
  min-height: 102px;
  padding: 18px;
  border: 1px solid var(--frost-border);
  border-radius: 26px;
  background: rgba(255, 255, 255, 0.5);
}

.module-note span {
  display: block;
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.module-note h4 {
  margin: 6px 0 5px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 18px;
  line-height: 1.15;
}

.module-note p {
  color: var(--text-muted);
  font-size: 13px;
  line-height: 1.38;
}

.mode-showcase {
  display: grid;
  grid-template-columns: minmax(0, 0.88fr) minmax(380px, 1fr);
  align-items: center;
  gap: clamp(26px, 5vw, 70px);
  padding: 34px 0 20px;
}

.mode-story {
  padding: 10px;
}

.mode-title {
  margin: 18px 0 16px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: clamp(36px, 5.6vw, 68px);
  font-weight: 800;
  line-height: 0.98;
  letter-spacing: 0;
}

.metric-strip {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-top: 30px;
}

.metric-item {
  padding: 18px 16px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.48);
  border: 1px solid var(--frost-border);
}

.metric-item strong {
  display: block;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 24px;
  line-height: 1;
}

.metric-item span {
  display: block;
  margin-top: 6px;
  color: var(--text-muted);
  font-size: 12px;
  font-weight: 700;
}

.product-preview {
  position: relative;
}

.product-preview::before {
  content: '';
  position: absolute;
  inset: 26px -18px -18px 46px;
  border-radius: 42px;
  background: var(--accent);
  opacity: 0.12;
  filter: blur(18px);
}

.preview-shell {
  position: relative;
  padding: clamp(18px, 3vw, 28px);
  border-radius: 42px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.74), rgba(255, 255, 255, 0.34)),
    var(--frost-bg);
  border: 1px solid rgba(255, 255, 255, 0.72);
  box-shadow:
    0 34px 90px -54px rgba(24, 27, 25, 0.46),
    inset 0 1px 0 rgba(255, 255, 255, 0.88);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
}

.preview-kicker {
  color: var(--accent-text);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.preview-chip {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 7px 10px;
  border-radius: var(--radius-pill);
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.58);
}

.preview-main-card {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 16px;
  margin-top: 18px;
  padding: 18px;
  border-radius: 30px;
  color: #ffffff;
  background:
    radial-gradient(circle at 90% 20%, rgba(255, 255, 255, 0.18), transparent 34%),
    var(--obsidian-ceramic);
  box-shadow: 0 22px 52px -34px rgba(24, 27, 25, 0.62);
}

.preview-icon {
  display: grid;
  place-items: center;
  width: 54px;
  height: 54px;
  border-radius: 18px;
  color: #ffffff;
  background: var(--accent);
}

.preview-main-card h3 {
  color: #ffffff;
  font-family: var(--font-display);
  font-size: 22px;
  line-height: 1.1;
}

.preview-main-card p {
  margin-top: 4px;
  color: rgba(255, 255, 255, 0.72);
  font-size: 13px;
}

.preview-main-card strong {
  color: #ffffff;
  font-family: var(--font-display);
  white-space: nowrap;
}

.privacy-band {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin: 14px 0;
}

.privacy-band div {
  min-height: 84px;
  padding: 15px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.56);
  border: 1px solid rgba(255, 255, 255, 0.62);
}

.privacy-band span,
.feed-card span {
  display: block;
  color: var(--text-muted);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

.privacy-band strong {
  display: block;
  margin-top: 8px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 14px;
  line-height: 1.25;
}

.preview-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
}

.local-map,
.feed-card {
  min-height: 238px;
  overflow: hidden;
  border-radius: 30px;
  border: 1px solid rgba(255, 255, 255, 0.68);
  background: rgba(255, 255, 255, 0.44);
}

.local-map {
  position: relative;
  background:
    radial-gradient(circle at 46% 50%, var(--accent-glow), transparent 35%),
    #e9e1d6;
}

.road-one {
  width: 230px;
  height: 28px;
  left: -28px;
  top: 70px;
  transform: rotate(28deg);
}

.road-two {
  width: 250px;
  height: 22px;
  right: -52px;
  bottom: 54px;
  transform: rotate(-22deg);
}

.map-radius {
  position: absolute;
  width: 112px;
  height: 112px;
  top: 62px;
  left: 52px;
  border-radius: 50%;
  border: 1px dashed var(--accent);
  background: var(--accent-glow);
}

.pin-main {
  top: 96px;
  left: 88px;
}

.pin-alt {
  right: 42px;
  bottom: 48px;
  background: var(--obsidian-ceramic);
}

.feed-card {
  padding: 18px;
}

.feed-card ul {
  display: grid;
  gap: 11px;
  margin-top: 14px;
  list-style: none;
}

.feed-card li {
  padding: 12px;
  border-radius: 18px;
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.58);
  font-size: 13px;
  line-height: 1.35;
}

.flow-section,
.trust-section {
  display: grid;
  gap: 22px;
  padding-top: 24px;
}

.section-heading {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 18px;
}

.section-heading .section-title {
  max-width: 640px;
  font-size: clamp(30px, 4.2vw, 50px);
  font-weight: 800;
}

.flow-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}

.flow-card {
  min-height: 240px;
  padding: 26px;
}

.feature-icon {
  display: grid;
  place-items: center;
  width: 54px;
  height: 54px;
  margin-bottom: 22px;
  border-radius: 18px;
  color: #ffffff;
  background: var(--accent);
  box-shadow: 0 16px 34px -24px var(--accent);
}

.flow-card .card-title {
  margin-bottom: 10px;
}

.timeline-panel {
  display: grid;
  grid-template-columns: 0.7fr 1fr;
  gap: 28px;
  align-items: center;
  padding: clamp(22px, 4vw, 36px);
}

.timeline-copy h3 {
  margin: 12px 0 10px;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: clamp(26px, 3.6vw, 42px);
  line-height: 1;
}

.timeline-list {
  display: grid;
  gap: 10px;
  list-style: none;
}

.timeline-list li {
  display: grid;
  grid-template-columns: auto 1fr;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.56);
}

.timeline-list span {
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--accent);
  font-family: var(--font-display);
  font-weight: 800;
}

.timeline-list p {
  color: var(--text-dark);
  font-size: 14px;
  font-weight: 700;
}

.trust-section {
  grid-template-columns: 1fr 1fr;
  align-items: stretch;
}

.trust-card {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 22px;
  align-items: start;
  padding: clamp(24px, 4vw, 38px);
}

.trust-icon {
  display: grid;
  place-items: center;
  width: 72px;
  height: 72px;
  border-radius: 26px;
  color: #ffffff;
  background: var(--obsidian-ceramic);
}

.trust-card .section-title {
  margin: 12px 0 12px;
  font-size: clamp(28px, 3.5vw, 44px);
  font-weight: 800;
}

.trust-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
}

.trust-mini {
  display: grid;
  align-content: start;
  gap: 9px;
  min-height: 154px;
  padding: 20px;
  border-radius: 28px;
  color: var(--text-muted);
  background: rgba(255, 255, 255, 0.48);
  border: 1px solid var(--frost-border);
}

.trust-mini svg {
  color: var(--accent-text);
}

.trust-mini strong {
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 17px;
}

.trust-mini span {
  font-size: 13px;
  line-height: 1.4;
}

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
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.close-btn-round:hover {
  background: #ffffff;
  color: var(--accent);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
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

.auth-form,
.form-group {
  display: flex;
  flex-direction: column;
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

.mb-2 { margin-bottom: 8px; }
.mb-4 { margin-bottom: 16px; }
.mb-6 { margin-bottom: 24px; }
.text-center { text-align: center; }
.text-left { text-align: left; }
.text-sm { font-size: 14px; }
.w-full { width: 100%; }
.block { display: block; }

.mode-shift-enter-active,
.mode-shift-leave-active {
  transition: opacity 0.28s ease, transform 0.28s ease;
}

.mode-shift-enter-from,
.mode-shift-leave-to {
  opacity: 0;
  transform: translateY(18px) scale(0.98);
}

@keyframes slideDown {
  from { transform: translateY(-18px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes fadeInUp {
  from { transform: translateY(34px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@keyframes floatIn {
  from { transform: translateY(22px) scale(0.96); opacity: 0; }
  to { transform: translateY(0) scale(1); opacity: 1; }
}

@keyframes pulseSoft {
  from { transform: scale(0.94); opacity: 0.48; }
  to { transform: scale(1.08); opacity: 0.78; }
}

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

@media (max-width: 980px) {
  .hero-stage,
  .mode-showcase,
  .communication-grid,
  .timeline-panel,
  .trust-section {
    grid-template-columns: 1fr;
  }

  .hero-stage {
    min-height: auto;
    padding-top: 18px;
  }

  .hero-orbit {
    min-height: 540px;
  }

  .switch-lab {
    grid-template-columns: 1fr;
  }

  .mode-toggle {
    width: 100%;
  }

  .flow-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .welcome-container {
    gap: 26px;
    padding-bottom: 48px;
  }

  .portada-header {
    position: relative;
    top: 0;
    grid-template-columns: 1fr auto;
    border-radius: 28px;
  }

  .landing-nav {
    grid-column: 1 / -1;
    justify-content: stretch;
    order: 3;
  }

  .landing-nav > a {
    display: none;
  }

  .nav-mode-switch {
    width: 100%;
  }

  .nav-mode-switch button {
    padding: 8px 9px;
    font-size: 11px;
    white-space: normal;
    line-height: 1.1;
  }

  .hero-stage {
    padding: 12px 0 18px;
  }

  .hero-title {
    font-size: clamp(42px, 14vw, 64px);
  }

  .hero-lede {
    font-size: 17px;
  }

  .hero-orbit {
    min-height: 470px;
  }

  .hero-device {
    min-height: 438px;
    padding: 16px;
    transform: none;
  }

  .device-map {
    height: 250px;
  }

  .orbit-card {
    min-width: 134px;
    padding: 13px;
  }

  .orbit-card-demand {
    top: 28px;
  }

  .orbit-card-offer {
    bottom: 26px;
  }

  .mode-toggle,
  .metric-strip,
  .privacy-band,
  .preview-grid,
  .trust-grid {
    grid-template-columns: 1fr;
  }

  .mode-option {
    min-height: 76px;
  }

  .communication-card {
    min-height: auto;
  }

  .preview-main-card {
    grid-template-columns: auto 1fr;
  }

  .preview-main-card strong {
    grid-column: 1 / -1;
  }

  .trust-card {
    grid-template-columns: 1fr;
  }

  .section-heading {
    display: grid;
    align-items: start;
  }

  .role-cards {
    flex-direction: column;
    gap: 12px;
  }
}
</style>
