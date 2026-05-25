<script setup lang="ts">
import { ref, computed } from 'vue';
import { useStore } from '../store';
import type { Job } from '../store';
import { 
  MapPin, Star, SlidersHorizontal, 
  List, Map, CheckCircle, ShieldAlert, X,
  Clock, DollarSign, Upload, Settings, MessageSquare, ChevronRight,
  ArrowRight
} from 'lucide-vue-next';

const { 
  state, 
  providerProfile, 
  submitBid, 
  updateProviderProfile, 
  navigateTo 
} = useStore();

// UI States
const activeCategoryFilter = ref('');
const minBudget = ref(0);
const maxDistance = ref(15); // in km
const onlyUrgent = ref(false);
const currentViewMode = ref<'list' | 'map'>('list');

// Selection states
const selectedJobId = ref<number | null>(null);
const selectedJob = computed(() => state.jobs.find(j => j.id === selectedJobId.value) || null);

// Modal states
const isProfileModalOpen = ref(false);
const isSuccessAlertOpen = ref(false);

// Profile Form States
const profileBio = ref(providerProfile.value?.bio || '');
const profileCategory = ref(providerProfile.value?.category || '');
const profileFee = ref(providerProfile.value?.pricePerHour || 220);
const idFileUploaded = ref(false);
const idFileName = ref('');

// Bid Form States
const bidProposal = ref('');
const bidAmount = ref(0);
const bidArrival = ref('20 min');

// Select a job to view details / apply
const selectJob = (job: Job) => {
  selectedJobId.value = job.id;
  bidAmount.value = job.budget;
  bidProposal.value = `Hola, soy ${providerProfile.value?.name || 'experto local'}. Cuento con amplia experiencia en ${job.category}. Puedo atender tu problema de inmediato. Llevo todo el equipo y materiales necesarios.`;
};

// Filtered tasks on board
const filteredJobs = computed(() => {
  return state.jobs.filter(j => {
    // Only show open or bidded jobs (not completed or actively in progress with others)
    const isAvailable = j.status === 'open' || j.status === 'bidded';
    const matchesCategory = activeCategoryFilter.value ? j.category === activeCategoryFilter.value : true;
    const matchesBudget = j.budget >= minBudget.value;
    const matchesUrgent = onlyUrgent.value ? j.isUrgent : true;
    
    // Mock distance based on coordinates: distance from provider (Mateo at 35,42)
    const mockDistance = Math.sqrt(Math.pow(j.lat - 35, 2) + Math.pow(j.lng - 42, 2)) * 0.15;
    const matchesDistance = mockDistance <= maxDistance.value;

    return isAvailable && matchesCategory && matchesBudget && matchesUrgent && matchesDistance;
  });
});

// Provider's active contracts (chats)
const providerContracts = computed(() => {
  return state.contracts.filter(c => c.providerId === 1); // Mateo González is ID 1
});

const handleUploadId = (event: Event) => {
  const target = event.target as HTMLInputElement;
  if (target.files && target.files.length > 0) {
    idFileName.value = target.files[0].name;
    idFileUploaded.value = true;
  }
};

const handleSaveProfile = () => {
  updateProviderProfile({
    bio: profileBio.value,
    category: profileCategory.value,
    pricePerHour: profileFee.value
  });
  isProfileModalOpen.value = false;
  
  // Show premium success alert
  isSuccessAlertOpen.value = true;
  setTimeout(() => {
    isSuccessAlertOpen.value = false;
  }, 3000);
};

const handleSendBid = () => {
  if (!bidProposal.value.trim() || bidAmount.value <= 0) {
    alert('Completa los campos de la postulación.');
    return;
  }
  
  if (selectedJobId.value) {
    submitBid(
      selectedJobId.value, 
      bidProposal.value, 
      bidAmount.value, 
      bidArrival.value
    );
    selectedJobId.value = null;
    
    // Alert success
    alert('¡Tu propuesta técnica ha sido enviada con éxito! Recibirás una notificación de chat si el cliente decide aceptarte en garantía Escrow.');
  }
};

const openContractChat = (contractId: number) => {
  state.activeContractId = contractId;
  navigateTo('chat-escrow');
};

const getDistanceText = (job: Job) => {
  const mockDistance = Math.sqrt(Math.pow(job.lat - 35, 2) + Math.pow(job.lng - 42, 2)) * 0.15;
  return `${mockDistance.toFixed(1)} km de distancia`;
};
</script>

<template>
  <div class="dashboard-container">
    <section class="provider-command glass-panel mb-4">
      <div class="command-copy text-left">
        <h2 class="section-title">Tu oficio convertido en oportunidades cercanas.</h2>
        <p class="body-text">
          Revisa tareas abiertas por zona aproximada, postúlate con una propuesta clara y espera el fondeo
          Escrow antes de salir. El panel prioriza trabajos accionables, contratos activos y reputación.
        </p>
      </div>
      <button @click="isProfileModalOpen = true" class="premium-btn">
        <span>Configurar Perfil</span>
        <span class="icon-circle">
          <Settings :size="18" />
        </span>
      </button>
    </section>

    <!-- Main Layout (Sidebar + Content) -->
    <div class="dashboard-grid">
      <!-- Left Column: Quick Profile Info / Filters -->
      <div class="sidebar-column">
        <!-- Quick Profile Card -->
        <div v-if="providerProfile" class="sidebar-section glass-panel text-left mb-4 profile-command-card">
          <div class="flex items-center gap-3 mb-4">
            <img :src="providerProfile.profileImg" class="mini-profile-avatar" />
            <div>
              <span class="badge badge-success mb-1">{{ providerProfile.category }}</span>
              <h3 class="card-title text-base flex items-center gap-1">
                {{ providerProfile.name }}
                <span class="verified-icon">✓</span>
              </h3>
              <div class="flex gap-2 text-xs text-muted">
                <span class="flex items-center"><Star :size="10" class="icon-star mr-1" /> {{ providerProfile.rating }}</span>
                <span>Trabajos: <strong>{{ providerProfile.completedJobs }}</strong></span>
              </div>
            </div>
          </div>
          <div class="border-t pt-3 flex justify-between text-xs text-muted">
            <span>Tarifa: <strong>${{ providerProfile.pricePerHour }}/hr</strong></span>
            <span>Respuesta: <strong>{{ providerProfile.responseTime }}</strong></span>
          </div>
        </div>

        <!-- Active Chats & Contracts (Independent from board) -->
        <div class="sidebar-section glass-panel mb-4 text-left">
          <div class="panel-heading">
            <span class="panel-label">Seguimiento</span>
            <h3 class="card-title flex items-center gap-2">
              <MessageSquare :size="16" class="text-green" /> Tratos en curso ({{ providerContracts.length }})
            </h3>
          </div>
          <div v-if="providerContracts.length === 0" class="empty-state py-4 text-center">
            <p class="body-text text-xs opacity-75">No tienes contratos activos en curso.</p>
          </div>
          <div v-else class="contracts-list">
            <div 
              v-for="contract in providerContracts" 
              :key="contract.id"
              class="contract-mini-card"
              @click="openContractChat(contract.id)"
            >
              <div class="flex justify-between items-center mb-1">
                <span class="font-semibold text-xs text-dark">{{ contract.clientName }}</span>
                <span :class="['badge-status', contract.status]">
                  {{ contract.status === 'pending_deposit' ? 'Depósito Pendiente' : 'Activo (Funded)' }}
                </span>
              </div>
              <p class="text-xs text-muted line-clamp-1 mb-2">Trato de: ${{ contract.agreementAmount }} MXN</p>
              <span class="text-green text-xs font-semibold flex items-center justify-end">
                Entrar al Chat <ChevronRight :size="12" />
              </span>
            </div>
          </div>
        </div>

        <!-- Directories Filters -->
        <div class="sidebar-section glass-panel text-left filter-panel">
          <div class="panel-heading">
            <span class="panel-label">Tablón local</span>
            <h3 class="card-title">Filtrar tareas cercanas</h3>
          </div>
          
          <!-- Category Selector -->
          <div class="filter-group mb-4">
            <label class="form-label">Oficios Técnicos</label>
            <div class="pill-input">
              <SlidersHorizontal :size="16" class="input-icon" />
              <select v-model="activeCategoryFilter">
                <option value="">Todos los oficios</option>
                <option value="Fontanería">Fontanería</option>
                <option value="Electricidad">Electricidad</option>
                <option value="Carpintería">Carpintería</option>
              </select>
            </div>
          </div>

          <!-- Budget Filter -->
          <div class="filter-group mb-4">
            <label class="form-label">Presupuesto Mínimo (MXN)</label>
            <div class="pill-input">
              <DollarSign :size="16" class="input-icon" />
              <select v-model.number="minBudget">
                <option :value="0">Cualquier presupuesto</option>
                <option :value="400">$400 MXN +</option>
                <option :value="600">$600 MXN +</option>
                <option :value="850">$850 MXN +</option>
              </select>
            </div>
          </div>

          <!-- Distance Slider -->
          <div class="filter-group mb-4">
            <div class="flex justify-between mb-1">
              <label class="form-label">Distancia Máxima</label>
              <span class="text-xs font-semibold">{{ maxDistance }} km</span>
            </div>
            <input 
              v-model.number="maxDistance" 
              type="range" 
              min="2" 
              max="30" 
              class="w-full range-slider"
            />
          </div>

          <!-- Urgent Filter -->
          <div class="filter-group">
            <label class="flex items-center gap-2 cursor-pointer font-medium text-sm">
              <input type="checkbox" v-model="onlyUrgent" />
              🚨 Mostrar solo Urgentes
            </label>
          </div>
        </div>
      </div>

      <!-- Right Column: Local job feed -->
      <div class="content-column">
        <div class="glass-panel content-surface">
          <!-- Filter/View controller bar -->
          <div class="controls-bar mb-6">
            <div class="surface-title text-left">
              <span class="panel-label">Demanda local disponible</span>
              <h3 class="card-title text-lg">Trabajos abiertos en tu vecindario</h3>
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
                <Map :size="16" class="mr-1" /> Mapa de Privacidad
              </button>
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="filteredJobs.length === 0" class="empty-state text-center py-12">
            <ShieldAlert :size="48" class="text-muted mx-auto mb-4 opacity-50" />
            <h3 class="card-title text-xl mb-2">No hay tareas en esta categoría</h3>
            <p class="body-text">Ajusta tus filtros de búsqueda o distancia para ver más.</p>
          </div>

          <!-- LIST VIEW -->
          <div v-else-if="currentViewMode === 'list'" class="jobs-list-active">
            <div 
              v-for="job in filteredJobs" 
              :key="job.id"
              class="glass-panel-sm job-feed-card text-left"
            >
              <div class="flex justify-between items-start mb-2">
                <div>
                  <span class="badge badge-success text-xs mb-1">{{ job.category }}</span>
                  <h3 class="card-title text-lg flex items-center gap-2">
                    {{ job.title }}
                    <span v-if="job.isUrgent" class="badge badge-warning text-xs">🚨 URGENTE</span>
                  </h3>
                </div>
                <div class="budget-badge text-right">
                  <span class="text-xs text-muted block">Presupuesto</span>
                  <span class="font-bold text-lg text-green">${{ job.budget }} MXN</span>
                </div>
              </div>
              
              <p class="body-text text-sm line-clamp-2 my-2">{{ job.description }}</p>
              
              <div class="border-t pt-3 mt-4 flex justify-between items-center text-xs text-muted">
                <span class="flex items-center"><MapPin :size="12" class="mr-1 text-green" /> {{ getDistanceText(job) }} (Aprox. {{ job.approxAddress }})</span>
                <button @click="selectJob(job)" class="premium-btn text-xs py-1">
                  <span>Revisar y Postularse</span>
                  <span class="icon-circle">
                    <ChevronRight :size="14" />
                  </span>
                </button>
              </div>
            </div>
          </div>

          <!-- MAP VIEW (Simulated Privacy Map) -->
          <div v-else-if="currentViewMode === 'map'" class="map-view-container">
            <div class="map-canvas">
              <div class="map-grid"></div>
              <div class="map-river"></div>
              
              <!-- Dashed Exclusion Circles for privacy protection -->
              <div 
                v-for="job in filteredJobs" 
                :key="job.id"
                class="privacy-exclusion-circle"
                :style="{ top: (job.lat - 6) + '%', left: (job.lng - 6) + '%' }"
                @click="selectJob(job)"
              >
                <div class="exclusion-dashed-border"></div>
                <div class="exclusion-badge font-bold">
                  {{ job.category }}
                  <span v-if="job.isUrgent" class="badge-dot-red"></span>
                </div>
              </div>

              <!-- Pin for Provider (Self Mateo) -->
              <div class="map-pin provider-pin" style="top: 35%; left: 42%;">
                <div class="provider-pin-glow"></div>
                <div class="pin-bubble-provider">
                  <span class="text-xs font-bold text-white">TÚ</span>
                </div>
              </div>
            </div>
            <p class="body-text text-xs text-center mt-2 italic">Exhibiendo círculos de exclusión de privacidad de 1.5 km (dirección bloqueada en mapa)</p>
          </div>
        </div>
      </div>
    </div>

    <!-- JOB DETAILS & POSTULATION FORM MODAL (3.3) -->
    <div v-if="selectedJobId" class="modal-overlay">
      <div v-if="selectedJob" class="modal-content glass-panel text-left bid-review-modal">
        <button @click="selectedJobId = null" class="close-btn-round bid-close-btn">
          <X :size="18" />
        </button>
        
        <div class="bid-review-hero">
          <span class="bid-kicker">{{ selectedJob.category }}</span>
          <h3 class="card-title">{{ selectedJob.title }}</h3>
          <p class="body-text">
            Revisa lo que solicita el cliente, confirma si está dentro de tu zona y envía una propuesta clara
            con tu explicación técnica, precio y tiempo estimado.
          </p>
          <div class="bid-hero-chips">
            <span :class="{ urgent: selectedJob.isUrgent }">{{ selectedJob.isUrgent ? 'Urgente' : 'Normal' }}</span>
            <span>${{ selectedJob.budget }} MXN ofrecidos</span>
            <span>{{ getDistanceText(selectedJob) }}</span>
          </div>
        </div>

        <div class="bid-review-body">
          <section class="bid-review-section">
            <div class="bid-section-heading">
              <span>01</span>
              <div>
                <h4 class="card-title">Solicitud del cliente</h4>
                <p class="body-text text-xs">Entiende el problema antes de postularte.</p>
              </div>
            </div>
            <p class="body-text bid-description">{{ selectedJob.description }}</p>
            <div class="job-meta-grid compact-meta-grid">
              <div class="meta-item">
                <span class="text-xs text-muted block">Presupuesto del cliente</span>
                <span class="font-semibold text-lg text-green">${{ selectedJob.budget }} MXN</span>
              </div>
              <div class="meta-item">
                <span class="text-xs text-muted block">Otros postulantes</span>
                <span class="font-semibold text-sm block mt-1">{{ selectedJob.bids.length }} experto(s)</span>
              </div>
            </div>
          </section>

          <section class="bid-review-section privacy-bid-section">
            <div class="bid-section-heading">
              <span>02</span>
              <div>
                <h4 class="card-title">Zona aproximada</h4>
                <p class="body-text text-xs">La dirección exacta se libera solo si el cliente acepta y fondea Escrow.</p>
              </div>
            </div>

            <div class="mini-privacy-map">
              <div class="privacy-map-orbs">
                <div class="approx-center-glow"></div>
                <div class="approx-outer-dashed"></div>
              </div>
              <span class="privacy-center-text font-semibold flex items-center">
                <MapPin :size="14" class="mr-1 text-green" /> Zona aproximada: {{ selectedJob.approxAddress }}
              </span>
            </div>
            <p class="body-text text-xs italic mt-2 text-muted">
              La calle y número se revelan en el chat cuando el cliente aprueba tu propuesta y deposita los fondos.
            </p>
          </section>

          <!-- Bidding Form -->
          <section class="bid-review-section">
            <div class="bid-section-heading">
              <span>03</span>
              <div>
                <h4 class="card-title">Tu propuesta técnica</h4>
                <p class="body-text text-xs">Explica por qué eres adecuado y cuánto cobrarías.</p>
              </div>
            </div>

            <form @submit.prevent="handleSendBid" class="bid-submit-form">
              <div class="form-group mb-4">
                <label class="form-label">Explicación técnica</label>
                <div class="pill-input text-area-input">
                  <textarea 
                    v-model="bidProposal" 
                    placeholder="Describe cómo planeas solucionar el problema y tu experiencia en trabajos similares." 
                    rows="3"
                    required
                  ></textarea>
                </div>
              </div>

              <div class="grid-2 mb-6">
                <div class="form-group">
                  <label class="form-label">Tu precio propuesto (MXN)</label>
                  <div class="pill-input">
                    <input 
                      v-model.number="bidAmount" 
                      type="number" 
                      required 
                      min="1"
                    />
                  </div>
                </div>
                <div class="form-group">
                  <label class="form-label">Tiempo estimado de llegada</label>
                  <div class="pill-input">
                    <Clock :size="16" class="input-icon" />
                    <select v-model="bidArrival">
                      <option value="15 min">15 minutos</option>
                      <option value="20 min">20 minutos</option>
                      <option value="30 min">30 minutos</option>
                      <option value="45 min">45 minutos</option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="bid-review-footer">
                <p class="body-text text-xs">Si el cliente acepta, el chat y la ubicación exacta se activarán tras el pago Escrow.</p>
                <button type="submit" class="premium-btn">
                  <span>Enviar propuesta</span>
                  <span class="icon-circle">
                    <ArrowRight :size="18" />
                  </span>
                </button>
              </div>
            </form>
          </section>
        </div>
      </div>
    </div>

    <!-- PROFILE MODAL CONFIGURATION (3.2) -->
    <div v-if="isProfileModalOpen" class="modal-overlay">
      <div class="modal-content glass-panel text-left profile-editor-modal">
        <button @click="isProfileModalOpen = false" class="close-btn-round profile-close-btn">
          <X :size="18" />
        </button>

        <div class="profile-editor-hero">
          <img
            :src="providerProfile?.profileImg"
            class="profile-editor-photo"
            alt="Foto de perfil del proveedor"
          />
          <div class="profile-editor-copy">
            <span class="profile-editor-kicker">Perfil profesional</span>
            <h3 class="card-title">Configura cómo te verán los clientes</h3>
            <p class="body-text">
              Estos datos son mock para el prototipo, pero representan la información que ayuda a que un solicitante
              entienda tu oficio, tu precio y tu nivel de confianza antes de aceptar una propuesta.
            </p>
            <div class="profile-editor-stats" style="padding-bottom: 40px;">
              <span>{{ providerProfile?.name || 'Proveedor local' }}</span>
              <span>{{ providerProfile?.rating || '4.9' }} ★</span>
              <span>{{ providerProfile?.completedJobs || 0 }} trabajos</span>
            </div>
          </div>
        </div>

        <form @submit.prevent="handleSaveProfile" class="profile-form profile-editor-form">
          <section class="profile-form-section">
            <div class="profile-section-heading">
              <span>01</span>
              <div>
                <h4 class="card-title">Servicio y tarifa</h4>
                <p class="body-text text-xs">Define el oficio principal y el rango de precio que verá el cliente.</p>
              </div>
            </div>

            <div class="profile-fields-grid">
              <div class="form-group">
                <label class="form-label">Categoría Técnica Principal</label>
                <div class="pill-input">
                  <select v-model="profileCategory">
                    <option value="Fontanería">Fontanería</option>
                    <option value="Electricidad">Electricidad</option>
                    <option value="Carpintería">Carpintería</option>
                  </select>
                </div>
              </div>

              <div class="form-group">
                <label class="form-label">Tarifa Promedio por hora (MXN)</label>
                <div class="pill-input">
                  <input 
                    v-model.number="profileFee" 
                    type="number" 
                    required 
                  />
                </div>
              </div>
            </div>
          </section>

          <section class="profile-form-section">
            <div class="profile-section-heading">
              <span>02</span>
              <div>
                <h4 class="card-title">Presentación comercial</h4>
                <p class="body-text text-xs">Explica experiencia, especialidad, garantía y tipo de trabajos que aceptas.</p>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Biografía y Presentación Comercial</label>
              <div class="pill-input text-area-input profile-bio-input">
                <textarea 
                  v-model="profileBio" 
                  placeholder="Escribe sobre tus años de experiencia, especialidad y garantías que ofreces a los clientes." 
                  rows="4"
                  required
                ></textarea>
              </div>
            </div>
          </section>

          <section class="profile-form-section verification-section">
            <div class="profile-section-heading">
              <span>03</span>
              <div>
                <h4 class="card-title">Verificación de identidad</h4>
                <p class="body-text text-xs">La insignia de identidad aumenta la confianza antes de que un cliente acepte tu propuesta.</p>
              </div>
            </div>

            <div class="file-upload-wrapper profile-upload-card text-left">
              <div class="upload-icon-shell">
                <Upload :size="26" />
              </div>
              <div class="upload-copy">
                <p class="body-text text-sm font-semibold mb-1">
                  {{ idFileUploaded ? 'Documento cargado correctamente' : 'Sube INE, pasaporte o documento oficial' }}
                </p>
                <p class="body-text text-xs opacity-75">
                  {{ idFileUploaded ? idFileName : 'Formatos soportados: PDF, JPG, PNG (Max 5MB)' }}
                </p>
              </div>
              <input 
                type="file" 
                id="id-file-input" 
                class="hidden-file-input" 
                @change="handleUploadId"
              />
              <label for="id-file-input" class="secondary-btn text-xs py-2 cursor-pointer upload-action">
                {{ idFileUploaded ? 'Cambiar archivo' : 'Seleccionar Archivo' }}
              </label>
            </div>
          </section>

          <div class="profile-editor-footer">
            <p class="body-text text-xs">Tu perfil se usará para aparecer en búsquedas y para respaldar tus postulaciones.</p>
            <button type="submit" class="premium-btn">
              <span>Guardar Configuración</span>
              <span class="icon-circle">
                <CheckCircle :size="18" />
              </span>
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Success Alert -->
    <div v-if="isSuccessAlertOpen" class="success-toast glass-panel-sm">
      <CheckCircle :size="18" class="text-green mr-2" />
      <span class="font-semibold text-sm">Perfil comercial guardado con éxito</span>
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

.text-green { color: var(--verde-terraria); }
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

.mini-profile-avatar {
  width: 52px;
  height: 52px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  border: 2px solid #ffffff;
}

.verified-icon {
  background-color: var(--verde-terraria);
  color: #ffffff;
  font-size: 9px;
  width: 13px;
  height: 13px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.contracts-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.contract-mini-card {
  border: 1px solid var(--frost-border);
  background-color: rgba(255, 255, 255, 0.35);
  border-radius: var(--radius-md);
  padding: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.contract-mini-card:hover {
  background-color: rgba(255, 255, 255, 0.65);
  border-color: var(--verde-terraria);
}

.badge-status {
  font-size: 10px;
  padding: 2px 8px;
  border-radius: var(--radius-xs);
  font-weight: 600;
  text-transform: uppercase;
}

.badge-status.pending_deposit {
  background-color: var(--clay-glow);
  color: var(--sunset-orange);
}

.badge-status.funded {
  background-color: var(--sage-wash);
  color: var(--verde-terraria);
}

.filter-group {
  display: flex;
  flex-direction: column;
}

.controls-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.view-toggle {
  display: flex;
  background-color: rgba(24, 27, 25, 0.05);
  padding: 4px;
  border-radius: var(--radius-pill);
}

.toggle-btn {
  border: none;
  background: transparent;
  padding: 6px 16px;
  border-radius: var(--radius-pill);
  font-size: 13px;
  font-family: var(--font-display);
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: all 0.3s ease;
}

.toggle-btn.active {
  background-color: #ffffff;
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}

.jobs-list-active {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.job-feed-card {
  padding: 16px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.job-feed-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 28px -12px var(--clay-shadow);
}

.budget-badge {
  background-color: #ffffff;
  padding: 6px 14px;
  border-radius: var(--radius-xs);
  box-shadow: 0 2px 6px rgba(0,0,0,0.04);
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
  background-color: var(--sage-wash);
  color: var(--verde-terraria);
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

.text-area-input textarea {
  resize: vertical;
}

.mini-privacy-map {
  width: 100%;
  height: 140px;
  background-color: #E2DBD2;
  border-radius: var(--radius-md);
  border: 1px solid var(--frost-border);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.approx-center-glow {
  position: absolute;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background-color: var(--accent);
  opacity: 0.15;
  filter: blur(10px);
}

.approx-outer-dashed {
  position: absolute;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: 2px dashed var(--accent);
  opacity: 0.4;
  animation: rotateDashed 20s linear infinite;
}

@keyframes rotateDashed {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.privacy-center-text {
  position: relative;
  z-index: 2;
  background-color: rgba(255,255,255,0.85);
  padding: 6px 12px;
  border-radius: var(--radius-pill);
  font-size: 12px;
  border: 1px solid var(--frost-border);
}

.file-upload-wrapper {
  padding: 24px;
  border: 2px dashed var(--frost-border);
  background-color: rgba(255, 255, 255, 0.3);
  position: relative;
}

.profile-editor-modal {
  max-width: 780px;
  padding: 0;
  overflow: hidden;
  border-radius: 38px;
  display: flex;
  flex-direction: column;
}

.profile-close-btn {
  top: 18px;
  right: 18px;
  z-index: 4;
}

.profile-editor-hero {
  position: relative;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: 22px;
  align-items: center;
  padding: 30px 34px;
  overflow: hidden;
  background:
    radial-gradient(circle at 12% 20%, rgba(151, 197, 159, 0.36), transparent 30%),
    linear-gradient(135deg, rgba(24, 27, 25, 0.92), rgba(24, 27, 25, 0.74));
}

.profile-editor-hero::after {
  content: '';
  position: absolute;
  right: -70px;
  top: -100px;
  width: 250px;
  height: 250px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.16);
  background: rgba(255, 255, 255, 0.06);
}

.profile-editor-photo {
  position: relative;
  z-index: 1;
  width: 118px;
  height: 118px;
  border-radius: 32px;
  object-fit: cover;
  border: 3px solid rgba(255, 255, 255, 0.78);
  box-shadow: 0 24px 44px -28px rgba(0, 0, 0, 0.8);
}

.profile-editor-copy {
  position: relative;
  z-index: 1;
  padding-right: 28px;
}

.profile-editor-kicker {
  display: inline-flex;
  width: fit-content;
  color: var(--verde-brote);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.profile-editor-copy .card-title {
  margin: 8px 0 8px;
  color: #ffffff;
  font-size: clamp(26px, 3.3vw, 38px);
  font-weight: 800;
  line-height: 1;
}

.profile-editor-copy .body-text {
  max-width: 560px;
  color: rgba(255, 255, 255, 0.72);
}

.profile-editor-stats {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

.profile-editor-stats span {
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: var(--radius-pill);
  padding: 7px 10px;
  color: #ffffff;
  background: rgba(255, 255, 255, 0.1);
  font-size: 12px;
  font-weight: 800;
}

.profile-editor-form {
  display: grid;
  gap: 16px;
  min-height: 0;
  overflow-y: auto;
  overscroll-behavior: contain;
  padding: 24px 34px 30px;
}

.profile-form-section {
  display: grid;
  gap: 16px;
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.66);
  border-radius: 30px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.56), rgba(255, 255, 255, 0.24)),
    rgba(255, 255, 255, 0.34);
}

.profile-section-heading {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 12px;
  align-items: start;
}

.profile-section-heading > span {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--verde-terraria);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 900;
}

.profile-section-heading .card-title {
  margin-bottom: 3px;
  font-size: 18px;
}

.profile-fields-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.profile-bio-input {
  border-radius: 24px !important;
}

.verification-section {
  background:
    linear-gradient(145deg, rgba(234, 240, 235, 0.84), rgba(255, 255, 255, 0.32)),
    rgba(255, 255, 255, 0.38);
}

.profile-upload-card {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 16px;
  border-radius: 26px;
  border: 1px dashed rgba(59, 96, 67, 0.34);
  background: rgba(255, 255, 255, 0.52);
}

.upload-icon-shell {
  display: grid;
  place-items: center;
  width: 54px;
  height: 54px;
  border-radius: 18px;
  color: #ffffff;
  background: var(--verde-terraria);
}

.upload-copy {
  min-width: 0;
}

.upload-action {
  white-space: nowrap;
}

.profile-editor-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding-top: 4px;
}

.hidden-file-input {
  display: none;
}

.success-toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background-color: #ffffff;
  border: 1px solid var(--verde-terraria);
  padding: 12px 24px;
  border-radius: var(--radius-md);
  box-shadow: 0 10px 24px -10px rgba(0,0,0,0.15);
  display: flex;
  align-items: center;
  z-index: 10000;
  animation: slideInUp 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes slideInUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

/* Privacy map specific pins */
.privacy-exclusion-circle {
  position: absolute;
  width: 90px;
  height: 90px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.exclusion-dashed-border {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 2px dashed var(--accent);
  background-color: var(--accent-glow);
  opacity: 0.35;
  animation: rotateDashed 24s linear infinite;
  box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}

.privacy-exclusion-circle:hover .exclusion-dashed-border {
  opacity: 0.55;
  background-color: rgba(59, 96, 67, 0.15);
}

.exclusion-badge {
  position: relative;
  z-index: 5;
  background-color: #ffffff;
  padding: 4px 10px;
  border-radius: var(--radius-xs);
  font-size: 10px;
  border: 1px solid var(--frost-border);
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
  display: flex;
  align-items: center;
  gap: 4px;
}

.badge-dot-red {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background-color: var(--sunset-orange);
  display: inline-block;
}

.provider-pin .pin-bubble-provider {
  background-color: var(--verde-terraria);
  border-radius: var(--radius-pill);
  padding: 6px 12px;
  box-shadow: 0 0 12px var(--verde-terraria);
}

.provider-pin-glow {
  position: absolute;
  width: 48px;
  height: 48px;
  background-color: var(--verde-terraria);
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

.bid-review-modal {
  max-width: 780px;
  padding: 0;
  overflow: hidden;
  border-radius: 38px;
  display: flex;
  flex-direction: column;
}

.bid-close-btn {
  top: 18px;
  right: 18px;
  z-index: 5;
}

.bid-review-hero {
  position: relative;
  padding: 30px 34px;
  overflow: hidden;
  background:
    radial-gradient(circle at 88% 12%, rgba(151, 197, 159, 0.34), transparent 34%),
    linear-gradient(135deg, rgba(24, 27, 25, 0.94), rgba(24, 27, 25, 0.76));
}

.bid-review-hero::after {
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

.bid-kicker {
  position: relative;
  z-index: 1;
  display: inline-flex;
  color: var(--verde-brote);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 900;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.bid-review-hero .card-title {
  position: relative;
  z-index: 1;
  max-width: 640px;
  margin: 9px 0;
  color: #ffffff;
  font-size: clamp(28px, 3.5vw, 42px);
  font-weight: 800;
  line-height: 1;
}

.bid-review-hero .body-text {
  position: relative;
  z-index: 1;
  max-width: 650px;
  color: rgba(255, 255, 255, 0.74);
}

.bid-hero-chips {
  position: relative;
  z-index: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

.bid-hero-chips span {
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: var(--radius-pill);
  padding: 7px 10px;
  color: #ffffff;
  background: rgba(255, 255, 255, 0.1);
  font-size: 12px;
  font-weight: 800;
}

.bid-hero-chips span.urgent {
  background: rgba(255, 130, 53, 0.22);
  color: #ffffff;
}

.bid-review-body {
  display: grid;
  gap: 16px;
  min-height: 0;
  overflow-y: auto;
  overscroll-behavior: contain;
  padding: 24px 34px 30px;
}

.bid-review-section {
  display: grid;
  gap: 16px;
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.66);
  border-radius: 30px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.58), rgba(255, 255, 255, 0.24)),
    rgba(255, 255, 255, 0.34);
}

.privacy-bid-section {
  background:
    linear-gradient(145deg, rgba(234, 240, 235, 0.9), rgba(255, 255, 255, 0.3)),
    rgba(255, 255, 255, 0.34);
}

.bid-section-heading {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 12px;
  align-items: start;
}

.bid-section-heading > span {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  color: #ffffff;
  background: var(--verde-terraria);
  font-family: var(--font-display);
  font-size: 12px;
  font-weight: 900;
}

.bid-section-heading .card-title {
  margin-bottom: 3px;
  font-size: 18px;
}

.bid-description {
  font-size: 15px;
  line-height: 1.55;
}

.compact-meta-grid {
  margin-bottom: 0;
}

.bid-review-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

.dashboard-container {
  padding: 8px 0 48px;
}

.provider-command {
  position: relative;
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  gap: 18px;
  overflow: hidden;
  padding: clamp(16px, 2.6vw, 24px);
}

.provider-command::before {
  content: '';
  position: absolute;
  inset: -38% -8% auto auto;
  width: 390px;
  height: 390px;
  border-radius: 50%;
  background: var(--verde-terraria);
  opacity: 0.14;
  filter: blur(24px);
}

.command-copy,
.provider-command > .premium-btn {
  position: relative;
  z-index: 1;
}

.command-kicker,
.panel-label {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  width: fit-content;
  color: var(--verde-terraria);
  font-family: var(--font-display);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.command-copy .section-title {
  max-width: 690px;
  margin: 0 0 8px;
  font-size: clamp(28px, 3.2vw, 40px);
  font-weight: 800;
  line-height: 1.04;
}

.command-copy .body-text {
  max-width: 740px;
  font-size: 15px;
  line-height: 1.45;
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

.profile-command-card {
  overflow: hidden;
  position: relative;
}

.profile-command-card::after {
  content: '';
  position: absolute;
  right: -54px;
  top: -54px;
  width: 150px;
  height: 150px;
  border-radius: 50%;
  background: var(--sage-wash);
  opacity: 0.9;
  z-index: -1;
}

.content-surface {
  padding: clamp(18px, 3vw, 28px);
}

.surface-title .card-title {
  margin-top: 5px;
}

.job-feed-card {
  position: relative;
  overflow: hidden;
  border-radius: 28px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.62), rgba(255, 255, 255, 0.28)),
    var(--frost-bg);
}

.job-feed-card::before {
  content: '';
  position: absolute;
  inset: 0 auto 0 0;
  width: 5px;
  background: var(--verde-terraria);
  opacity: 0;
  transition: opacity 0.25s ease;
}

.job-feed-card:hover::before {
  opacity: 1;
}

.budget-badge {
  border-radius: 18px;
  border: 1px solid var(--frost-border);
}

.contract-mini-card {
  position: relative;
  overflow: hidden;
  padding: 14px;
}

.contract-mini-card::before {
  content: '';
  position: absolute;
  inset: 0 auto 0 0;
  width: 4px;
  background: var(--verde-terraria);
  opacity: 0;
  transition: opacity 0.25s ease;
}

.contract-mini-card:hover::before {
  opacity: 1;
}

.map-canvas {
  border-radius: 32px;
}

@media (max-width: 1060px) {
  .provider-command {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 900px) {
  .sidebar-column {
    position: static;
  }
}

@media (max-width: 640px) {
  .provider-command {
    padding: 18px;
  }

  .controls-bar {
    align-items: stretch;
  }

  .profile-editor-hero,
  .profile-fields-grid,
  .profile-upload-card,
  .bid-review-footer {
    grid-template-columns: 1fr;
  }

  .profile-editor-hero {
    padding: 28px 22px;
  }

  .profile-editor-form {
    padding: 18px;
  }

  .bid-review-hero {
    padding: 28px 22px;
  }

  .bid-review-body {
    padding: 18px;
  }

  .bid-review-footer {
    display: grid;
  }

  .profile-editor-footer {
    display: grid;
  }

  .upload-action {
    width: 100%;
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
