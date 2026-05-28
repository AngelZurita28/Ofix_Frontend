<script setup lang="ts">
import { ref, computed } from 'vue';
import { useStore } from '../store';
import type { Bid } from '../store';
import { 
  Search, MapPin, Star, Sparkles, SlidersHorizontal, 
  List, Map, Plus, X, Clock, FileText, ChevronRight,
  BadgeCheck
} from 'lucide-vue-next';

const { 
  state, 
  selectedProvider, 
  selectedJob, 
  createJob, 
  acceptBid, 
  hireDirect
} = useStore();

// UI States
const searchQuery = ref('');
const activeCategory = ref('');
const maxDistance = ref(10); // in km
const minStars = ref(0);
const currentViewMode = ref<'list' | 'map'>('list');

// Modals
const isDirectHireOpen = ref(false);
const directTaskTitle = ref('');
const directTaskDesc = ref('');
const directTaskBudget = ref(250);
const directTaskUrgent = ref(false);

// New Job Form
const jobTitle = ref('');
const jobCategory = ref('Fontanería');
const jobDesc = ref('');
const jobBudget = ref<number | null>(null);
const jobUrgent = ref(false);
const jobExactAddr = ref('');
const jobApproxAddr = ref('');

// Computed filtered providers
const filteredProviders = computed(() => {
  return state.providers.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
                          p.category.toLowerCase().includes(searchQuery.value.toLowerCase());
    const matchesCategory = activeCategory.value ? p.category === activeCategory.value : true;
    const matchesStars = p.rating >= minStars.value;
    // Mock distance logic: Mateo is 3km, Valeria is 7km, Alejandro is 12km
    const mockDistance = p.id === 1 ? 3 : p.id === 2 ? 7 : 12;
    const matchesDistance = mockDistance <= maxDistance.value;
    
    return matchesSearch && matchesCategory && matchesStars && matchesDistance;
  });
});

// Categories list
const categories = ['Fontanería', 'Electricidad', 'Carpintería'];

// Client's own published jobs
const clientJobs = computed(() => {
  return state.jobs.filter(j => j.clientName === state.user?.name);
});

// Selected job's active bids
const activeJobBids = computed(() => {
  if (!state.selectedJobId) return [];
  const job = state.jobs.find(j => j.id === state.selectedJobId);
  return job ? job.bids : [];
});

const handlePublishJob = () => {
  if (!jobTitle.value.trim() || !jobDesc.value.trim() || !jobExactAddr.value.trim() || !jobApproxAddr.value.trim()) {
    alert('Por favor completa todos los campos requeridos.');
    return;
  }
  
  createJob({
    title: jobTitle.value,
    category: jobCategory.value,
    description: jobDesc.value,
    budget: jobBudget.value || 0,
    isUrgent: jobUrgent.value,
    exactAddress: jobExactAddr.value,
    approxAddress: jobApproxAddr.value
  });

  // Reset form
  jobTitle.value = '';
  jobDesc.value = '';
  jobBudget.value = null;
  jobUrgent.value = false;
  jobExactAddr.value = '';
  jobApproxAddr.value = '';
  
  // Add a fake bid automatically after 4 seconds to make the prototype feel incredibly alive!
  const targetJobId = state.selectedJobId;
  setTimeout(() => {
    const targetJob = state.jobs.find(j => j.id === targetJobId);
    if (targetJob && targetJob.status === 'open') {
      targetJob.bids.push({
        providerId: 1, // Mateo González
        providerName: 'Mateo González',
        proposal: 'Hola Diana Laura, tengo disponibilidad inmediata para atender tu fuga. Llevo equipo de sellado y tuberías PVC de repuesto. El costo incluye materiales y garantía de 3 meses.',
        bidAmount: targetJob.budget || 550,
        estimatedArrival: '20 min'
      });
      targetJob.status = 'bidded';
    }
  }, 4000);
};

const handleAcceptBid = (bid: Bid) => {
  if (state.selectedJobId) {
    acceptBid(state.selectedJobId, bid);
  }
};

const handleHireDirect = () => {
  if (!directTaskTitle.value.trim() || !directTaskDesc.value.trim()) {
    alert('Completa los campos de la tarea.');
    return;
  }
  if (state.selectedProviderId) {
    hireDirect(
      state.selectedProviderId, 
      directTaskTitle.value, 
      directTaskDesc.value, 
      directTaskBudget.value, 
      directTaskUrgent.value
    );
    // Reset states
    isDirectHireOpen.value = false;
    directTaskTitle.value = '';
    directTaskDesc.value = '';
    state.selectedProviderId = null;
  }
};

const selectProvider = (id: number) => {
  state.selectedProviderId = id;
};

const selectJob = (id: number) => {
  state.selectedJobId = id;
};
</script>

<template>
  <div class="dashboard-container">
    <section class="dashboard-command glass-panel mb-4">
      <div class="command-copy text-left">
        <h2 class="section-title">Contrata con contexto, privacidad y pago retenido.</h2>
        <p class="body-text">
          Publica una necesidad para recibir postulaciones o explora perfiles cuando ya sabes qué oficio necesitas.
          Ofiixmantiene la zona aproximada visible y reserva la dirección exacta para el trato aceptado.
        </p>
      </div>
      <button @click="state.isPublishingModalOpen = true" class="premium-btn">
        <span>Solicitar Tarea</span>
        <span class="icon-circle">
          <Plus :size="18" />
        </span>
      </button>
    </section>

    <!-- Main Layout (Sidebar + Content) -->
    <div class="dashboard-grid">
      <!-- Left Column: Providers directory / Filters / My Tasks -->
      <div class="sidebar-column">
        <!-- Dashboard Navigation Tabs -->
        <div class="sidebar-section glass-panel mb-4 mission-panel">
          <div class="panel-heading">
            <span class="panel-label">Tu tablero</span>
            <h3 class="card-title">Mis tareas publicadas</h3>
          </div>
          <div v-if="clientJobs.length === 0" class="empty-state text-center py-4">
            <FileText :size="32" class="text-muted mx-auto mb-2 opacity-50" />
            <p class="body-text text-sm">No has publicado tareas aún.</p>
            <button @click="state.isPublishingModalOpen = true" class="secondary-btn mini-action">
              Crear primera tarea
            </button>
          </div>
          <div v-else class="jobs-list">
            <div 
              v-for="job in clientJobs" 
              :key="job.id"
              :class="['job-sidebar-card', { active: state.selectedJobId === job.id }]"
              @click="selectJob(job.id)"
            >
              <div class="job-card-header mb-1">
                <span class="job-title-text font-semibold">{{ job.title }}</span>
                <span :class="['badge', job.status === 'open' ? 'badge-warning' : 'badge-success']">
                  {{ job.status === 'open' ? 'Abierta' : job.status === 'bidded' ? 'Ofertas' : 'Activa' }}
                </span>
              </div>
              <p class="body-text text-xs line-clamp-1 mb-2">{{ job.description }}</p>
              <div class="job-card-footer">
                <span class="text-xs font-medium text-orange">${{ job.budget }} MXN</span>
                <span class="text-xs text-muted flex items-center">
                  <Clock :size="10" class="mr-1" /> {{ job.isUrgent ? 'Urgente' : 'Normal' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Directories Filters -->
        <div class="sidebar-section glass-panel filter-panel">
          <div class="panel-heading">
            <span class="panel-label">Directorio</span>
            <h3 class="card-title">Filtros de búsqueda</h3>
          </div>
          
          <!-- Category Selector -->
          <div class="filter-group mb-4 text-left">
            <label class="form-label">Categoría</label>
            <div class="pill-input">
              <SlidersHorizontal :size="16" class="input-icon" />
              <select v-model="activeCategory">
                <option value="">Todas las categorías</option>
                <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
              </select>
            </div>
          </div>

          <!-- Distance Slider -->
          <div class="filter-group mb-4 text-left">
            <div class="flex justify-between mb-1">
              <label class="form-label">Distancia Máxima</label>
              <span class="text-xs font-semibold">{{ maxDistance }} km</span>
            </div>
            <input 
              v-model.number="maxDistance" 
              type="range" 
              min="1" 
              max="20" 
              class="w-full range-slider"
            />
          </div>

          <!-- Stars Filter -->
          <div class="filter-group text-left">
            <label class="form-label">Calificación mínima</label>
            <div class="stars-filter-options">
              <button 
                v-for="stars in [0, 3, 4, 4.5]" 
                :key="stars"
                :class="['stars-btn', { active: minStars === stars }]"
                @click="minStars = stars"
              >
                {{ stars === 0 ? 'Todas' : stars + '★+' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column: Results list, map, detail view of selected items -->
      <div class="content-column">
        <!-- Selected Task Details Mode (If client wants to check their posted task and bids) -->
        <div v-if="state.selectedJobId && selectedJob" class="glass-panel mb-6 relative">
          <button @click="state.selectedJobId = null" class="close-btn-round">
            <X :size="16" />
          </button>
          
          <div class="text-left">
            <span class="badge badge-warning mb-2">{{ selectedJob.category }}</span>
            <h3 class="card-title text-2xl mb-2">{{ selectedJob.title }}</h3>
            <p class="body-text mb-4">{{ selectedJob.description }}</p>
            
            <div class="job-meta-grid mb-6">
              <div class="meta-item">
                <span class="text-xs text-muted block">Presupuesto</span>
                <span class="font-semibold text-lg text-orange">${{ selectedJob.budget }} MXN</span>
              </div>
              <div class="meta-item">
                <span class="text-xs text-muted block">Ubicación aproximada</span>
                <span class="font-semibold text-sm flex items-center mt-1">
                  <MapPin :size="14" class="mr-1 text-orange" /> {{ selectedJob.approxAddress }}
                </span>
              </div>
              <div class="meta-item">
                <span class="text-xs text-muted block">Prioridad</span>
                <span :class="['badge', selectedJob.isUrgent ? 'badge-warning' : 'badge-success', 'mt-1']">
                  {{ selectedJob.isUrgent ? '🚨 URGENTE' : 'Estándar' }}
                </span>
              </div>
            </div>

            <!-- Bids Section -->
            <h4 class="card-title border-t pt-4 mb-4">Postulaciones Recibidas ({{ activeJobBids.length }})</h4>
            <div v-if="activeJobBids.length === 0" class="empty-state-bids text-center py-6 glass-panel-sm">
              <Sparkles :size="28" class="text-orange mx-auto mb-2 animate-bounce" />
              <p class="body-text font-medium text-sm">Esperando postulaciones de expertos cercanos...</p>
              <p class="body-text text-xs opacity-75">Suelen llegar propuestas en menos de 1 minuto en este prototipo.</p>
            </div>
            <div v-else class="bids-grid">
              <div 
                v-for="bid in activeJobBids" 
                :key="bid.providerId"
                class="glass-panel-sm bid-card"
              >
                <div class="bid-card-header mb-3">
                  <div class="flex items-center gap-2">
                    <img 
                      src="https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=100&auto=format&fit=crop&q=80" 
                      class="bid-avatar" 
                      alt="Provider Avatar"
                    />
                    <div class="text-left">
                      <span class="bid-provider-name font-semibold block">{{ bid.providerName }}</span>
                      <span class="text-xs text-muted">Llegada: {{ bid.estimatedArrival }}</span>
                    </div>
                  </div>
                  <div class="text-right">
                    <span class="text-sm text-muted block">Tarifa propuesta</span>
                    <span class="font-bold text-orange">${{ bid.bidAmount }} MXN</span>
                  </div>
                </div>
                <p class="body-text text-sm italic mb-4">"{{ bid.proposal }}"</p>
                <div class="flex justify-between items-center">
                  <button @click="selectProvider(bid.providerId)" class="secondary-btn text-xs py-2">
                    Ver perfil completo
                  </button>
                  <button @click="handleAcceptBid(bid)" class="premium-btn text-xs py-1">
                    <span>Aceptar y Pagar Escrow</span>
                    <span class="icon-circle">
                      <ChevronRight :size="14" />
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Directory Tab Panel -->
        <div class="glass-panel content-surface">
          <!-- Filter/View controller bar -->
          <div class="controls-bar mb-6">
            <div class="surface-title text-left">
              <span class="panel-label">Oferta local disponible</span>
              <h3 class="card-title text-lg">Directorio de talento cercano</h3>
            </div>
            <div class="toolbar-actions">
              <div class="search-wrapper">
                <div class="pill-input">
                  <Search :size="18" class="input-icon" />
                  <input 
                    v-model="searchQuery" 
                    type="text" 
                    placeholder="Buscar fontanero, electricista..." 
                  />
                </div>
              </div>
              
              <div class="view-toggle">
                <button 
                  :class="['toggle-btn', { active: currentViewMode === 'list' }]"
                  @click="currentViewMode = 'list'"
                >
                  <List :size="16" class="mr-1" /> Lista
                </button>
                <button 
                  :class="['toggle-btn', { active: currentViewMode === 'map' }]"
                  @click="currentViewMode = 'map'"
                >
                  <Map :size="16" class="mr-1" /> Mapa
                </button>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="filteredProviders.length === 0" class="empty-state text-center py-12">
            <SlidersHorizontal :size="48" class="text-muted mx-auto mb-4 opacity-50" />
            <h3 class="card-title text-xl mb-2">Sin resultados</h3>
            <p class="body-text">Prueba ajustando los filtros de búsqueda o distancia.</p>
          </div>

          <!-- LIST VIEW -->
          <div v-else-if="currentViewMode === 'list'" class="providers-list">
            <div 
              v-for="provider in filteredProviders" 
              :key="provider.id"
              class="glass-panel-sm provider-card text-left"
            >
              <div class="provider-card-main">
                <img :src="provider.profileImg" class="provider-avatar" :alt="provider.name" />
                <div class="provider-info">
                  <div class="flex justify-between items-start">
                    <div>
                      <h3 class="card-title text-lg flex items-center gap-2">
                        {{ provider.name }}
                        <span class="online-dot" v-if="provider.status === 'online'"></span>
                      </h3>
                      <span class="text-xs text-muted block font-semibold uppercase">{{ provider.category }}</span>
                    </div>
                    <div class="rating-badge font-bold">
                      <Star :size="14" class="icon-star mr-1" /> {{ provider.rating }}
                    </div>
                  </div>
                  <p class="body-text text-sm line-clamp-2 my-2">{{ provider.bio }}</p>
                  
                  <!-- Badges list -->
                  <div class="badges-row mb-3">
                    <span class="trust-chip">
                      <BadgeCheck :size="12" />
                      Verificado
                    </span>
                    <span v-for="badge in provider.badges" :key="badge" class="badge badge-success text-xs">
                      {{ badge }}
                    </span>
                    <span class="badge badge-warning text-xs">Tarifa: ${{ provider.pricePerHour }}/hr</span>
                  </div>
                  
                  <div class="flex justify-between items-center mt-4">
                    <span class="text-xs text-muted">Responde en: <strong>{{ provider.responseTime }}</strong></span>
                    <button @click="selectProvider(provider.id)" class="premium-btn text-xs py-1">
                      <span>Ver Perfil Comercial</span>
                      <span class="icon-circle">
                        <ChevronRight :size="14" />
                      </span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- MAP VIEW (Simulated map) -->
          <div v-else-if="currentViewMode === 'map'" class="map-view-container">
            <div class="map-canvas">
              <div class="map-grid"></div>
              <div class="map-river"></div>
              
              <!-- Pins for Providers -->
              <div 
                v-for="p in filteredProviders" 
                :key="p.id"
                class="map-pin"
                :style="{ top: p.lat + '%', left: p.lng + '%' }"
                @click="selectProvider(p.id)"
              >
                <div class="map-pin-pulse"></div>
                <div class="pin-bubble">
                  <img :src="p.profileImg" class="pin-avatar" />
                  <span class="pin-badge font-bold"><Star :size="10" /> {{ p.rating }}</span>
                </div>
                <div class="pin-pointer"></div>
              </div>

              <!-- Pin for Client (Self) -->
              <div class="map-pin client-pin" style="top: 50%; left: 50%;">
                <div class="client-pin-glow"></div>
                <div class="pin-bubble-client">
                  <span class="text-xs font-bold text-white">TÚ</span>
                </div>
              </div>
            </div>
            <p class="body-text text-xs text-center mt-2 italic">Representación de geolocalización difuminada de 1.5 km</p>
          </div>
        </div>
      </div>
    </div>

    <!-- PUBLISHING JOB MODAL (2.2) -->
    <div v-if="state.isPublishingModalOpen" class="modal-overlay">
      <div class="modal-content glass-panel text-left task-request-modal">
        <button @click="state.isPublishingModalOpen = false" class="close-btn-round task-close-btn">
          <X :size="18" />
        </button>

        <div class="task-request-hero">
          <span class="task-kicker">Solicitar tarea</span>
          <h3 class="card-title" style="padding-bottom: 40px;">Publica lo que necesitas y deja que profesionales cercanos se postulen.</h3>
          <div class="task-hero-steps">
            <span>1. Describe</span>
            <span>2. Define presupuesto</span>
            <span>3. Protege ubicación</span>
          </div>
        </div>

        <form @submit.prevent="handlePublishJob" class="publish-form task-request-form">
          <section class="task-form-section">
            <div class="task-section-heading">
              <span>01</span>
              <div>
                <h4 class="card-title">Trabajo solicitado</h4>
                <p class="body-text text-xs">Especifica qué problema necesitas resolver.</p>
              </div>
            </div>

            <div class="form-group mb-4">
              <label class="form-label">¿Qué necesitas resolver?</label>
              <div class="pill-input">
                <input 
                  v-model="jobTitle" 
                  type="text" 
                  placeholder="Fuga de agua en lavabo, instalación de lámparas..." 
                  required 
                  maxlength="150"
                />
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Descripción detallada</label>
              <div class="pill-input text-area-input">
                <textarea 
                  v-model="jobDesc" 
                  placeholder="Describe a detalle el problema. Ej: El lavabo de la cocina gotea de la manguera derecha. Requiere cambio de conector metálico." 
                  rows="4"
                  required
                ></textarea>
              </div>
            </div>
          </section>

          <section class="task-form-section">
            <div class="task-section-heading">
              <span>02</span>
              <div>
                <h4 class="card-title">Categoría y presupuesto</h4>
                <p class="body-text text-xs">Ayuda a que se postulen los profesionales correctos.</p>
              </div>
            </div>

            <div class="grid-2">
              <div class="form-group">
                <label class="form-label">Categoría del oficio</label>
                <div class="pill-input">
                  <select v-model="jobCategory">
                    <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">Presupuesto ofrecido (MXN)</label>
                <div class="pill-input">
                  <input 
                    v-model.number="jobBudget" 
                    type="number" 
                    placeholder="Ej: 500"
                  />
                </div>
              </div>
            </div>

            <label class="task-urgent-toggle">
              <input type="checkbox" v-model="jobUrgent" class="checkbox-custom" />
              <span>
                <strong>Marcar como urgencia inmediata</strong>
                <small>Se resaltará para profesionales disponibles cerca de ti.</small>
              </span>
            </label>
          </section>

          <section class="task-form-section privacy-task-section">
            <div class="task-section-heading">
              <span>03</span>
              <div>
                <h4 class="card-title">Ubicación y privacidad</h4>
                <p class="body-text text-xs">La zona ayuda a postularse; la dirección exacta se reserva para el acuerdo.</p>
              </div>
            </div>

            <div class="form-group mb-4">
              <label class="form-label">Dirección exacta</label>
              <div class="pill-input">
                <MapPin :size="16" class="input-icon" />
                <input 
                  v-model="jobExactAddr" 
                  type="text" 
                  placeholder="Calle Lerma 142, Dpto 402, Cuauhtémoc" 
                  required
                />
              </div>
              <p class="field-helper">Privada. Se libera cuando aceptas una propuesta y se concreta el pago Escrow.</p>
            </div>

            <div class="form-group">
              <label class="form-label">Zona o referencia pública</label>
              <div class="pill-input">
                <MapPin :size="16" class="input-icon" />
                <input 
                  v-model="jobApproxAddr" 
                  type="text" 
                  placeholder="Cerca del Ángel de la Independencia, Cuauhtémoc" 
                  required
                />
              </div>
              <p class="field-helper">Visible para que profesionales calculen distancia y disponibilidad.</p>
            </div>
          </section>

          <div class="task-request-footer">
            <p class="body-text text-xs">Los profesionales podrán responder con explicación técnica, tiempo estimado y precio.</p>
            <button type="submit" class="premium-btn">
              <span>Publicar tarea</span>
              <span class="icon-circle">
                <ArrowRight :size="18" />
              </span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- PROVIDER PUBLIC PROFILE MODAL (2.3) -->
    <div v-if="state.selectedProviderId && selectedProvider" class="modal-overlay">
      <div class="modal-content glass-panel profile-modal text-left provider-profile-modal">
        <button @click="state.selectedProviderId = null" class="close-btn-round provider-profile-close">
          <X :size="18" />
        </button>

        <div class="provider-profile-hero">
          <img :src="selectedProvider.profileImg" class="profile-modal-avatar" :alt="selectedProvider.name" />
          <div class="provider-profile-copy">
            <span class="provider-profile-kicker">{{ selectedProvider.category }}</span>
            <h3 class="card-title">
              {{ selectedProvider.name }}
              <span class="online-dot" v-if="selectedProvider.status === 'online'"></span>
            </h3>
            <p class="body-text">
              Profesional local disponible para solicitudes directas y tareas publicadas. Revisa su experiencia,
              trabajos anteriores y reseñas antes de iniciar un trato con pago retenido.
            </p>
            <div class="provider-profile-stats">
              <span><Star :size="13" class="icon-star" /> {{ selectedProvider.rating }} de calificación</span>
              <span>{{ selectedProvider.completedJobs }} trabajos completados</span>
              <span>Responde en {{ selectedProvider.responseTime }}</span>
            </div>
          </div>
        </div>

        <div class="provider-profile-body">
          <section class="provider-profile-section bio-section">
            <div class="provider-section-heading">
              <span>01</span>
              <div>
                <h4 class="card-title">Sobre su servicio</h4>
                <p class="body-text text-xs">Especialidad, experiencia y forma de trabajo.</p>
              </div>
            </div>
            <p class="body-text provider-bio">{{ selectedProvider.bio }}</p>
            <div class="badges-row provider-badge-row">
              <span v-for="badge in selectedProvider.badges" :key="badge" class="badge badge-success text-xs">
                {{ badge }}
              </span>
              <span class="badge badge-warning text-xs">${{ selectedProvider.pricePerHour }} MXN / hr</span>
            </div>
          </section>

          <section class="provider-profile-section">
            <div class="provider-section-heading">
              <span>02</span>
              <div>
                <h4 class="card-title">Portafolio</h4>
                <p class="body-text text-xs">Evidencia visual de trabajos anteriores.</p>
              </div>
            </div>
            <div class="portfolio-carousel">
              <img 
                v-for="(img, idx) in selectedProvider.portfolio" 
                :key="idx"
                :src="img" 
                class="portfolio-img"
                alt="Trabajo de portafolio"
              />
            </div>
          </section>

          <section class="provider-profile-section">
            <div class="provider-section-heading">
              <span>03</span>
              <div>
                <h4 class="card-title">Reseñas de la comunidad</h4>
                <p class="body-text text-xs">Comentarios que ayudan a decidir con confianza.</p>
              </div>
            </div>
            <div class="reviews-list">
              <div 
                v-for="rev in selectedProvider.reviews" 
                :key="rev.id"
                class="glass-panel-sm review-item text-left"
              >
                <div class="review-head">
                  <span class="font-semibold text-sm">{{ rev.reviewer }}</span>
                  <span class="text-xs text-muted">{{ rev.date }}</span>
                </div>
                <div class="flex items-center gap-1 mb-1">
                  <Star 
                    v-for="star in 5" 
                    :key="star" 
                    :size="10" 
                    :class="star <= rev.rating ? 'icon-star' : 'icon-star-empty'" 
                  />
                </div>
                <p class="body-text text-xs italic">"{{ rev.comment }}"</p>
              </div>
            </div>
          </section>
        </div>

        <!-- Hiring CTA Bar -->
        <div class="hiring-bar provider-hiring-bar">
          <div>
            <span class="text-xs text-muted block">Tarifa promedio</span>
            <span class="font-bold text-lg text-orange">${{ selectedProvider.pricePerHour }} MXN / hr</span>
          </div>
          <button @click="isDirectHireOpen = true" class="premium-btn">
            <span>Contratar Directamente</span>
            <span class="icon-circle">
              <ChevronRight :size="18" />
            </span>
          </button>
        </div>
      </div>
    </div>

    <!-- DIRECT HIRE DETAILED MODAL -->
    <div v-if="isDirectHireOpen && selectedProvider" class="modal-overlay z-1000">
      <div class="modal-content glass-panel text-left">
        <div class="flex justify-between items-center mb-6">
          <h3 class="card-title text-lg flex items-center gap-2">
            🤝 Ofrecer Contrato Directo a {{ selectedProvider.name }}
          </h3>
          <button @click="isDirectHireOpen = false" class="close-btn-round">
            <X :size="18" />
          </button>
        </div>

        <form @submit.prevent="handleHireDirect">
          <div class="form-group mb-4">
            <label class="form-label">Título de la tarea</label>
            <div class="pill-input">
              <input 
                v-model="directTaskTitle" 
                type="text" 
                placeholder="Ej: Cambio de mezcladora en baño principal"
                required
              />
            </div>
          </div>

          <div class="form-group mb-4">
            <label class="form-label">Instrucciones / Detalles específicos</label>
            <div class="pill-input text-area-input">
              <textarea 
                v-model="directTaskDesc" 
                placeholder="Explica qué se requiere resolver de forma detallada."
                rows="3"
                required
              ></textarea>
            </div>
          </div>

          <div class="grid-2 mb-6">
            <div class="form-group">
              <label class="form-label">Monto del trato acordado (MXN)</label>
              <div class="pill-input">
                <input 
                  v-model.number="directTaskBudget" 
                  type="number" 
                  required
                />
              </div>
            </div>
            <div class="form-group flex items-center justify-start pt-6 pl-4">
              <label class="flex items-center gap-2 cursor-pointer font-medium text-sm">
                <input type="checkbox" v-model="directTaskUrgent" />
                🚨 Contrato urgente
              </label>
            </div>
          </div>

          <button type="submit" class="premium-btn w-full">
            <span>Iniciar contrato y pagar por OpenPay</span>
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
.dashboard-container {
  padding: 24px 20px;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.text-orange { color: var(--accent-text); }
.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }

.dashboard-grid {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: 24px;
  align-items: start;
}

@media (max-width: 900px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}

.sidebar-column {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.sidebar-section {
  padding: 20px;
}

.jobs-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 300px;
  overflow-y: auto;
}

.job-sidebar-card {
  border: 1px solid var(--frost-border);
  background-color: rgba(255, 255, 255, 0.3);
  border-radius: var(--radius-md);
  padding: 12px;
  cursor: pointer;
  text-align: left;
  transition: all 0.3s ease;
}

.job-sidebar-card:hover {
  background-color: rgba(255, 255, 255, 0.6);
  border-color: var(--sunset-orange);
}

.job-sidebar-card.active {
  background-color: var(--clay-glow);
  border-color: var(--sunset-orange);
  box-shadow: 0 4px 12px -4px rgba(255, 130, 53, 0.15);
}

.job-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.job-title-text {
  font-size: 13px;
  color: var(--text-dark);
}

.job-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;  
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;  
  overflow: hidden;
}

.filter-group {
  display: flex;
  flex-direction: column;
}

.stars-filter-options {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.stars-btn {
  background-color: rgba(255, 255, 255, 0.5);
  border: 1px solid var(--frost-border);
  border-radius: var(--radius-pill);
  padding: 8px 16px;
  font-size: 13px;
  cursor: pointer;
  font-family: var(--font-body);
  font-weight: 500;
  color: var(--text-muted);
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 2px 6px rgba(105, 95, 87, 0.04);
}

.stars-btn:hover {
  background-color: #ffffff;
  color: var(--text-dark);
  border-color: var(--accent);
  transform: translateY(-1px);
}

.stars-btn.active {
  background-color: var(--accent);
  color: #ffffff;
  border-color: var(--accent);
  box-shadow: 0 6px 16px var(--accent-glow);
  font-weight: 600;
}

.controls-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.search-wrapper {
  flex: 1;
  min-width: 250px;
}

.view-toggle {
  display: flex;
  background-color: rgba(24, 27, 25, 0.06);
  padding: 4px;
  border-radius: var(--radius-pill);
  border: 1px solid var(--frost-border);
}

.toggle-btn {
  border: none;
  background: transparent;
  padding: 6px 16px;
  border-radius: var(--radius-pill);
  font-size: 13px;
  font-family: var(--font-display);
  font-weight: 600;
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.toggle-btn:hover:not(.active) {
  background-color: rgba(255, 255, 255, 0.45);
  color: var(--text-dark);
}

.toggle-btn.active {
  background-color: #ffffff;
  color: var(--accent-text);
  box-shadow: 0 4px 12px rgba(105, 95, 87, 0.08);
}

.providers-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.provider-card {
  padding: 16px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.provider-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 28px -12px var(--clay-shadow);
}

.provider-card-main {
  display: flex;
  gap: 20px;
}

.provider-avatar {
  width: 72px;
  height: 72px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  border: 2px solid #ffffff;
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
}

.provider-info {
  flex: 1;
}

.online-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: var(--verde-brote);
  display: inline-block;
  box-shadow: 0 0 0 2px rgba(151, 197, 159, 0.4);
}

.rating-badge {
  display: inline-flex;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.7);
  border: 1px solid var(--frost-border);
  padding: 4px 10px;
  border-radius: var(--radius-xs);
  font-size: 13px;
  font-weight: 700;
  color: var(--text-dark);
  box-shadow: 0 2px 6px rgba(105, 95, 87, 0.05);
}

.icon-star {
  color: #FFB020;
  fill: #FFB020;
}

.icon-star-empty {
  color: #D8D0C4;
}

.badges-row {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  align-items: center;
}

.close-btn-round {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 1px solid var(--frost-border);
  background-color: #ffffff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
  transition: all 0.2s ease;
}

.close-btn-round:hover {
  background-color: var(--clay-glow);
  color: var(--sunset-orange);
}

.job-meta-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
  background-color: rgba(255, 255, 255, 0.4);
  padding: 16px;
  border-radius: var(--radius-md);
  border: 1px solid var(--frost-border);
}

.bids-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.bid-card {
  padding: 16px;
  border: 1px solid rgba(255, 130, 53, 0.15);
  background-color: rgba(255, 255, 255, 0.5);
  position: relative;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.bid-card:hover {
  transform: translateY(-1px);
  border-color: rgba(255, 130, 53, 0.4);
  box-shadow: 0 8px 24px -6px rgba(255, 130, 53, 0.1);
}

.bid-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #ffffff;
}

.text-area-input {
  border-radius: var(--radius-md) !important;
  padding: 16px 20px !important;
}

.text-area-input textarea {
  min-height: 100px;
  resize: none;
  line-height: 1.5;
}

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

@media (max-width: 500px) {
  .grid-2 {
    grid-template-columns: 1fr;
  }
}

.profile-modal.provider-profile-modal {
  max-width: 820px;
  padding: 0;
  overflow: hidden;
  border-radius: 38px;
  display: flex;
  flex-direction: column;
}

.provider-profile-close {
  top: 18px;
  right: 18px;
  z-index: 5;
}

.provider-profile-hero {
  position: relative;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: 24px;
  align-items: center;
  padding: 32px 36px;
  overflow: hidden;
  background:
    radial-gradient(circle at 12% 16%, rgba(255, 130, 53, 0.32), transparent 31%),
    linear-gradient(135deg, rgba(24, 27, 25, 0.94), rgba(24, 27, 25, 0.76));
}

.provider-profile-hero::after {
  content: '';
  position: absolute;
  right: -86px;
  top: -116px;
  width: 270px;
  height: 270px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.16);
  background: rgba(255, 255, 255, 0.06);
}

.profile-modal-avatar {
  position: relative;
  z-index: 1;
  width: 128px;
  height: 128px;
  border-radius: 34px;
  object-fit: cover;
  border: 3px solid rgba(255, 255, 255, 0.82);
  box-shadow: 0 24px 44px -28px rgba(0, 0, 0, 0.82);
}

.provider-profile-copy {
  position: relative;
  z-index: 1;
  padding-right: 28px;
}

.provider-profile-kicker {
  display: inline-flex;
  width: fit-content;
  color: var(--sunset-orange);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.provider-profile-copy .card-title {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 8px 0 8px;
  color: #ffffff;
  font-size: clamp(28px, 3.4vw, 42px);
  font-weight: 800;
  line-height: 1;
}

.provider-profile-copy .body-text {
  max-width: 560px;
  color: rgba(255, 255, 255, 0.72);
}

.provider-profile-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

.provider-profile-stats span {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: var(--radius-pill);
  padding: 7px 10px;
  color: #ffffff;
  background: rgba(255, 255, 255, 0.1);
  font-size: 12px;
  font-weight: 800;
}

.provider-profile-body {
  display: grid;
  gap: 16px;
  min-height: 0;
  overflow-y: auto;
  overscroll-behavior: contain;
  padding: 24px 34px;
}

.provider-profile-section {
  display: grid;
  gap: 16px;
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.66);
  border-radius: 30px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.58), rgba(255, 255, 255, 0.24)),
    rgba(255, 255, 255, 0.34);
}

.provider-section-heading {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 12px;
  align-items: start;
}

.provider-section-heading > span {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--sunset-orange);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 900;
}

.provider-section-heading .card-title {
  margin-bottom: 3px;
  font-size: 18px;
}

.provider-bio {
  font-size: 15px;
  line-height: 1.55;
}

.provider-badge-row {
  margin-top: 2px;
}

.portfolio-carousel {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.portfolio-img {
  width: 100%;
  height: 168px;
  border-radius: 24px;
  object-fit: cover;
  border: 2px solid #ffffff;
  box-shadow: 0 12px 24px -18px rgba(24, 27, 25, 0.35);
}

.reviews-list {
  display: grid;
  gap: 12px;
  max-height: 250px;
  overflow-y: auto;
  padding-right: 4px;
}

.review-item {
  padding: 14px;
  border-radius: 22px;
}

.review-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 8px;
}

.provider-hiring-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 20px 34px 28px;
  border-top: 1px solid var(--frost-border);
  background: rgba(255, 255, 255, 0.28);
}

/* Map specific pins style */
.pin-bubble {
  background-color: #ffffff;
  border: 2px solid var(--accent);
  border-radius: var(--radius-sm);
  padding: 2px;
  display: flex;
  align-items: center;
  gap: 4px;
  box-shadow: 0 6px 12px rgba(0,0,0,0.1);
}

.pin-avatar {
  width: 28px;
  height: 28px;
  border-radius: 4px;
  object-fit: cover;
}

.pin-badge {
  font-size: 10px;
  display: flex;
  align-items: center;
  gap: 2px;
  padding-right: 4px;
}

.pin-pointer {
  width: 0;
  height: 0;
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-top: 8px solid var(--accent);
  margin-top: -1px;
}

.client-pin .pin-bubble-client {
  background-color: var(--accent);
  border-radius: var(--radius-pill);
  padding: 6px 12px;
  box-shadow: 0 0 12px var(--accent);
}

.client-pin .pin-pointer {
  border-top-color: var(--accent);
}

.client-pin-glow {
  position: absolute;
  width: 48px;
  height: 48px;
  background-color: var(--accent);
  border-radius: 50%;
  opacity: 0.2;
  animation: pulse 1.8s infinite ease-out;
  top: -8px;
  left: -2px;
}

.range-slider {
  accent-color: var(--accent);
  height: 6px;
  border-radius: 4px;
  background: rgba(0,0,0,0.1);
  outline: none;
}

.task-request-modal {
  max-width: 760px;
  padding: 0;
  overflow: hidden;
  border-radius: 38px;
  display: flex;
  flex-direction: column;
}

.task-close-btn {
  top: 18px;
  right: 18px;
  z-index: 5;
}

.task-request-hero {
  position: relative;
  padding: 30px 34px;
  overflow: hidden;
  background:
    radial-gradient(circle at 90% 8%, rgba(255, 130, 53, 0.36), transparent 34%),
    linear-gradient(135deg, rgba(24, 27, 25, 0.94), rgba(24, 27, 25, 0.76));
}

.task-request-hero::after {
  content: '';
  position: absolute;
  right: -80px;
  bottom: -120px;
  width: 280px;
  height: 280px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.16);
  background: rgba(255, 255, 255, 0.06);
}

.task-kicker {
  position: relative;
  z-index: 1;
  display: inline-flex;
  color: var(--sunset-orange);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.task-request-hero .card-title {
  position: relative;
  z-index: 1;
  max-width: 620px;
  margin: 9px 0;
  color: #ffffff;
  font-size: clamp(28px, 3.5vw, 42px);
  font-weight: 800;
  line-height: 1;
}

.task-request-hero .body-text {
  position: relative;
  z-index: 1;
  max-width: 650px;
  color: rgba(255, 255, 255, 0.74);
}

.task-hero-steps {
  position: relative;
  z-index: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

.task-hero-steps span {
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: var(--radius-pill);
  padding: 7px 10px;
  color: #ffffff;
  background: rgba(255, 255, 255, 0.1);
  font-size: 12px;
  font-weight: 800;
}

.task-request-form {
  display: grid;
  gap: 16px;
  min-height: 0;
  overflow-y: auto;
  overscroll-behavior: contain;
  padding: 24px 34px 30px;
}

.task-form-section {
  display: grid;
  gap: 16px;
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.66);
  border-radius: 30px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.58), rgba(255, 255, 255, 0.24)),
    rgba(255, 255, 255, 0.34);
}

.privacy-task-section {
  background:
    linear-gradient(145deg, rgba(253, 238, 227, 0.86), rgba(255, 255, 255, 0.3)),
    rgba(255, 255, 255, 0.34);
}

.task-section-heading {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 12px;
  align-items: start;
}

.task-section-heading > span {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--sunset-orange);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 900;
}

.task-section-heading .card-title {
  margin-bottom: 3px;
  font-size: 18px;
}

.task-urgent-toggle {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 12px;
  align-items: center;
  padding: 14px;
  border: 1px solid var(--frost-border);
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.48);
  cursor: pointer;
}

.task-urgent-toggle strong,
.task-urgent-toggle small,
.field-helper {
  display: block;
}

.task-urgent-toggle strong {
  color: var(--text-dark);
  font-size: 13px;
}

.task-urgent-toggle small,
.field-helper {
  margin-top: 4px;
  color: var(--text-muted);
  font-size: 11px;
  line-height: 1.35;
}

.task-request-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.dashboard-container {
  padding: 8px 0 48px;
}

.dashboard-command {
  position: relative;
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  gap: 18px;
  overflow: hidden;
  padding: clamp(16px, 2.6vw, 24px);
}

.dashboard-command::before {
  content: '';
  position: absolute;
  inset: -35% auto auto -10%;
  width: 360px;
  height: 360px;
  border-radius: 50%;
  background: var(--accent);
  opacity: 0.13;
  filter: blur(24px);
}

.command-copy,
.dashboard-command > .premium-btn {
  position: relative;
  z-index: 1;
}

.command-kicker,
.panel-label {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  width: fit-content;
  color: var(--accent-text);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.command-copy .section-title {
  max-width: 650px;
  margin: 0 0 8px;
  font-size: clamp(28px, 3.2vw, 40px);
  font-weight: 800;
  line-height: 1.04;
}

.command-copy .body-text {
  max-width: 720px;
  font-size: 15px;
  line-height: 1.45;
}

.trust-chip {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  border: 1px solid rgba(255, 255, 255, 0.7);
  border-radius: var(--radius-pill);
  padding: 8px 11px;
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.5);
  font-size: 12px;
  font-weight: 800;
}

.dashboard-grid {
  grid-template-columns: minmax(280px, 340px) minmax(0, 1fr);
  gap: 22px;
}

.sidebar-column {
  position: sticky;
  top: 118px;
}

.panel-heading {
  display: grid;
  gap: 6px;
  margin-bottom: 18px;
}

.mission-panel,
.filter-panel,
.content-surface {
  border-color: rgba(255, 255, 255, 0.72);
}

.mini-action {
  margin-top: 14px;
  padding: 9px 14px;
  font-size: 12px;
}

.job-sidebar-card {
  position: relative;
  overflow: hidden;
  padding: 14px;
}

.job-sidebar-card::before {
  content: '';
  position: absolute;
  inset: 0 auto 0 0;
  width: 4px;
  background: var(--accent);
  opacity: 0;
  transition: opacity 0.25s ease;
}

.job-sidebar-card.active::before,
.job-sidebar-card:hover::before {
  opacity: 1;
}

.content-surface {
  padding: clamp(18px, 3vw, 28px);
}

.surface-title .card-title {
  margin-top: 5px;
}

.toolbar-actions {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  justify-content: flex-end;
}

.provider-card {
  border-radius: 28px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.62), rgba(255, 255, 255, 0.28)),
    var(--frost-bg);
}

.provider-card-main {
  align-items: flex-start;
}

.provider-avatar {
  width: 84px;
  height: 84px;
  border-radius: 24px;
}

.rating-badge {
  border-radius: var(--radius-pill);
  padding: 7px 11px;
}

.map-canvas {
  border-radius: 32px;
}

@media (max-width: 1060px) {
  .dashboard-command {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 900px) {
  .sidebar-column {
    position: static;
  }

  .toolbar-actions {
    width: 100%;
    justify-content: stretch;
    flex-wrap: wrap;
  }

  .search-wrapper {
    min-width: min(100%, 280px);
  }
}

@media (max-width: 640px) {
  .dashboard-command {
    padding: 18px;
  }

  .provider-profile-hero,
  .portfolio-carousel,
  .task-request-footer {
    grid-template-columns: 1fr;
  }

  .provider-profile-hero {
    padding: 28px 22px;
  }

  .provider-profile-body {
    padding: 18px;
  }

  .task-request-hero {
    padding: 28px 22px;
  }

  .task-request-form {
    padding: 18px;
  }

  .task-request-footer {
    display: grid;
  }

  .provider-hiring-bar {
    display: grid;
    padding: 18px;
  }

  .profile-modal-avatar {
    width: 112px;
    height: 112px;
  }

  .provider-card-main {
    grid-template-columns: 1fr;
    display: grid;
  }

  .toolbar-actions {
    display: grid;
    grid-template-columns: 1fr;
  }

  .view-toggle {
    width: 100%;
  }

  .toggle-btn {
    flex: 1;
    justify-content: center;
  }
}
</style>
