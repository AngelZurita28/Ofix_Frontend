<script setup lang="ts">
import { computed, ref, watch, nextTick } from 'vue';
import { useStore } from '../store';
import { 
  ArrowLeft, Send, Image, ShieldCheck, 
  Phone, Star, Clock, CheckCircle2, CreditCard, Lock, X
} from 'lucide-vue-next';

const { 
  state, 
  activeContract, 
  sendMessage, 
  fundContract, 
  completeContract, 
  submitReview, 
  navigateTo 
} = useStore();

const chatMessageText = ref('');
const isPayingLoader = ref(false);
const showReviewModal = ref(false);

// Review form states
const reviewRating = ref(5);
const reviewComment = ref('');

const statusMeta = computed(() => {
  if (!activeContract.value) {
    return {
      label: 'Sin contrato',
      title: 'No hay un trato activo',
      detail: 'Regresa al panel para iniciar una contratación.'
    };
  }

  if (activeContract.value.status === 'pending_deposit') {
    return {
      label: 'Pago pendiente',
      title: 'El trato espera el pago completo por OpenPay',
      detail: state.activeMode === 'DEMANDA'
        ? 'Realiza el pago completo para activar la visita. Ofiix retiene el dinero con Escrow hasta que el trabajo se complete.'
        : 'Espera a que el pago quede retenido con Escrow antes de salir. La dirección exacta sigue protegida.'
    };
  }

  if (activeContract.value.status === 'funded') {
    return {
      label: 'Pago retenido',
      title: 'El trabajo ya puede ejecutarse',
      detail: 'El pago completo está retenido con Escrow y la información operativa se desbloqueó.'
    };
  }

  return {
    label: 'Trato completado',
    title: 'El pago retenido fue liberado',
    detail: 'El trabajo cerró y la reputación puede alimentar futuros tratos.'
  };
});

const escrowSteps = computed(() => {
  const status = activeContract.value?.status;
  return [
    { label: 'Acuerdo', done: Boolean(activeContract.value) },
    { label: 'Escrow', done: status === 'funded' || status === 'completed' },
    { label: 'Ejecución', done: status === 'funded' || status === 'completed' },
    { label: 'Liberación', done: status === 'completed' }
  ];
});

// Scroll helper
const chatHistoryRef = ref<HTMLElement | null>(null);

const scrollToBottom = () => {
  nextTick(() => {
    if (chatHistoryRef.value) {
      chatHistoryRef.value.scrollTop = chatHistoryRef.value.scrollHeight;
    }
  });
};

// Scroll on new message
watch(() => activeContract.value?.messages.length, () => {
  scrollToBottom();
}, { immediate: true });

// Scroll when loaded
watch(() => state.currentView, (newView) => {
  if (newView === 'chat-escrow') {
    scrollToBottom();
  }
});

const handleSendMessage = () => {
  if (!chatMessageText.value.trim() || !activeContract.value) return;
  
  const sender = state.activeMode === 'DEMANDA' ? 'client' : 'provider';
  sendMessage(activeContract.value.id, sender, chatMessageText.value);
  chatMessageText.value = '';
};

// Send mock photo evidence (DESIGN feature!)
const handleSendPhotoEvidence = () => {
  if (!activeContract.value) return;
  const sender = state.activeMode === 'DEMANDA' ? 'client' : 'provider';
  
  const mockImages = [
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500&auto=format&fit=crop&q=80'
  ];
  
  const randomImage = mockImages[Math.floor(Math.random() * mockImages.length)];
  
  sendMessage(
    activeContract.value.id, 
    sender, 
    '📸 He adjuntado una fotografía del estado del avance de la tarea como evidencia visual.', 
    randomImage
  );
};

const handleMockPayment = () => {
  if (!activeContract.value) return;
  
  isPayingLoader.value = true;
  
  setTimeout(() => {
    isPayingLoader.value = false;
    if (activeContract.value) {
      fundContract(activeContract.value.id);
    }
  }, 2500);
};

const handleCompleteContract = () => {
  if (!activeContract.value) return;
  completeContract(activeContract.value.id);
};

const handleSubmitReview = () => {
  if (!activeContract.value) return;
  submitReview(activeContract.value.id, reviewRating.value, reviewComment.value);
};

const goBackToDashboard = () => {
  navigateTo(state.activeMode === 'DEMANDA' ? 'demand-dashboard' : 'offer-dashboard');
};
</script>

<template>
  <div class="chat-escrow-container">
    <!-- Header bar -->
    <div class="deal-room-header glass-panel mb-6">
      <button @click="goBackToDashboard" class="secondary-btn back-btn">
        <ArrowLeft :size="14" /> Volver al tablero
      </button>

      <div class="deal-room-copy text-left">
        <span class="deal-kicker">
          <ShieldCheck :size="14" />
          {{ statusMeta.label }}
        </span>
        <h3 class="card-title">{{ statusMeta.title }}</h3>
        <p class="body-text">{{ statusMeta.detail }}</p>
      </div>

      <div v-if="activeContract" class="deal-amount-card">
        <span>Pago retenido</span>
        <strong>${{ activeContract.agreementAmount }} MXN</strong>
        <small>{{ activeContract.providerName }} & {{ activeContract.clientName }}</small>
      </div>

      <ol class="escrow-progress" aria-label="Progreso del trato">
        <li v-for="step in escrowSteps" :key="step.label" :class="{ done: step.done }">
          <span></span>
          <p>{{ step.label }}</p>
        </li>
      </ol>
    </div>

    <!-- Active view container -->
    <div v-if="!activeContract" class="glass-panel text-center py-16">
      <h3 class="card-title text-xl mb-2">No hay un contrato seleccionado</h3>
      <p class="body-text">Regresa al panel para iniciar un trato comercial.</p>
    </div>

    <div v-else class="chat-grid">
      <!-- LEFT COLUMN: Messaging chat -->
      <div class="chat-column glass-panel">
        <div class="chat-column-head">
          <div>
            <span class="deal-kicker">Coordinación</span>
            <h3 class="card-title">Chat del trato</h3>
          </div>
          <span class="chat-pill">{{ activeContract.messages.length }} mensajes</span>
        </div>
        <!-- Message list history -->
        <div ref="chatHistoryRef" class="chat-history mb-4">
          <div 
            v-for="(msg, idx) in activeContract.messages" 
            :key="idx"
            :class="['message-wrapper', msg.sender === 'client' ? 'client-msg' : 'provider-msg']"
          >
            <div class="message-bubble glass-panel-sm">
              <span class="message-sender font-bold text-xs uppercase block mb-1">
                {{ msg.sender === 'client' ? activeContract.clientName : activeContract.providerName }}
              </span>
              <p class="body-text text-sm">{{ msg.content }}</p>
              
              <!-- Included image proof -->
              <img v-if="msg.image" :src="msg.image" class="message-image mt-3" alt="Evidencia de trabajo" />
              
              <span class="message-time text-right block mt-2 text-xxs opacity-75">{{ msg.timestamp }}</span>
            </div>
          </div>
        </div>

        <!-- Chat controls input bar -->
        <div v-if="activeContract.status !== 'completed'" class="chat-controls-bar">
          <button @click="handleSendPhotoEvidence" class="secondary-btn icon-only-btn" title="Cargar Evidencia Fotográfica">
            <Image :size="18" class="text-orange" />
          </button>
          
          <div class="pill-input flex-1">
            <input 
              v-model="chatMessageText" 
              type="text" 
              placeholder="Escribe un mensaje de coordinación..." 
              @keyup.enter="handleSendMessage"
            />
          </div>
          
          <button @click="handleSendMessage" class="premium-btn send-btn-small">
            <span class="icon-circle m-0">
              <Send :size="14" />
            </span>
          </button>
        </div>
        <div v-else class="chat-closed-notice glass-panel-sm text-center">
          <p class="body-text text-sm font-semibold text-green">🔒 Chat cerrado automáticamente tras liberación del Escrow.</p>
        </div>
      </div>

      <!-- RIGHT COLUMN: Escrow Financial / Address Widget -->
      <div class="escrow-column sidebar-column">
        <!-- Escrow Widget -->
        <div class="sidebar-section glass-panel text-left">
          <div class="escrow-widget-head">
            <ShieldCheck :size="20" class="text-orange" />
            <div>
              <span class="deal-kicker">Pago seguro Ofiix</span>
              <h3 class="card-title">Escrow y privacidad</h3>
            </div>
          </div>

          <!-- STATUS: PENDING DEPOSIT -->
          <div v-if="activeContract.status === 'pending_deposit'">
            <!-- Client view of pending payment -->
            <div v-if="state.activeMode === 'DEMANDA'" class="client-payment-flow">
              <p class="body-text text-sm mb-4">Realiza el pago completo de manera segura por OpenPay. Ofiix mantiene el dinero retenido con Escrow y solo lo libera al técnico cuando confirmes que el servicio fue completado.</p>
              
              <div class="glass-panel-sm payment-card-mock mb-4">
                <div class="flex justify-between items-center mb-3">
                  <span class="font-bold text-sm">Pago Simulado (OpenPay)</span>
                  <CreditCard :size="16" class="text-muted" />
                </div>
                
                <div class="form-group mb-3">
                  <label class="form-label text-xs">Tarjeta de Crédito / Débito</label>
                  <div class="pill-input py-2">
                    <input type="text" value="4242 4242 4242 4242" disabled />
                  </div>
                </div>
                
                <div class="grid-2">
                  <div class="form-group">
                    <label class="form-label text-xs">Vence</label>
                    <div class="pill-input py-2">
                      <input type="text" value="12 / 29" disabled />
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="form-label text-xs">CVC</label>
                    <div class="pill-input py-2">
                      <input type="text" value="***" disabled />
                    </div>
                  </div>
                </div>
              </div>

              <!-- Payment Button -->
              <button 
                @click="handleMockPayment" 
                class="premium-btn w-full justify-center"
                :disabled="isPayingLoader"
              >
                <template v-if="isPayingLoader">
                  <span>Procesando pago seguro...</span>
                </template>
                <template v-else>
                  <span>Pagar completo (${{ activeContract.agreementAmount }} MXN)</span>
                  <span class="icon-circle">
                    <Lock :size="14" />
                  </span>
                </template>
              </button>
            </div>

            <!-- Provider view of pending payment -->
            <div v-else class="provider-payment-flow">
              <div class="alert-box-warning mb-4 glass-panel-sm">
                <Clock :size="24" class="text-orange mb-2 block mx-auto animate-spin" />
                <p class="body-text text-sm font-semibold text-center mb-1">Esperando pago seguro</p>
                <p class="body-text text-xs text-center opacity-75">No asistas al lugar hasta que el cliente pague por OpenPay y el monto quede retenido con Escrow. Te notificaremos de inmediato.</p>
              </div>
            </div>
          </div>

          <!-- STATUS: FUNDED (Address Unlocked!) -->
          <div v-else-if="activeContract.status === 'funded'">
            <div class="alert-box-success mb-6 glass-panel-sm text-center">
              <CheckCircle2 :size="24" class="text-green mb-1 block mx-auto" />
              <p class="body-text text-sm font-semibold text-green">✓ Pago completo retenido con Escrow</p>
              <p class="body-text text-xs opacity-75">Los ${{ activeContract.agreementAmount }} MXN se pagaron por OpenPay y permanecen retenidos hasta completar el trabajo.</p>
            </div>

            <!-- UNLOCKED GEO INFO -->
            <div class="unlocked-address-box mb-6 text-left">
              <h4 class="card-title text-sm uppercase text-muted mb-2">📍 Datos de Domicilio Liberados 🔓</h4>
              
              <div class="address-details-panel glass-panel-sm mb-4">
                <p class="body-text text-sm font-semibold mb-2">Dirección Exacta:</p>
                <p class="body-text text-sm mb-4 font-mono">{{ state.jobs.find(j => j.id === activeContract?.jobId)?.exactAddress || 'Calle Río Lerma 142, Dpto 402, Cuauhtémoc, CDMX' }}</p>
                
                <p class="body-text text-sm font-semibold mb-1">Teléfono del Cliente:</p>
                <p class="body-text text-sm font-semibold text-orange flex items-center">
                  <Phone :size="14" class="mr-1" /> +52 55 4982 3218
                </p>
              </div>

              <!-- Route map simulator -->
              <h4 class="card-title text-sm uppercase text-muted mb-2">Ruta de Navegación del Técnico</h4>
              <div class="map-canvas mini-route-map">
                <div class="map-grid"></div>
                <div class="route-line-dashed"></div>
                
                <div class="map-pin route-pin-start" style="top: 35%; left: 42%;">
                  <span class="badge-route-mini">TEC</span>
                </div>
                <div class="map-pin route-pin-end" style="top: 50%; left: 50%;">
                  <span class="badge-route-mini route-end">CL</span>
                </div>
              </div>
            </div>

            <!-- Actions buttons depending on role -->
            <div v-if="state.activeMode === 'DEMANDA'" class="client-actions-funded">
              <button @click="handleCompleteContract" class="premium-btn w-full">
                <span>Liberar pago al proveedor</span>
                <span class="icon-circle">
                  <ShieldCheck :size="18" />
                </span>
              </button>
            </div>
            <div v-else class="provider-actions-funded">
              <button @click="sendMessage(activeContract.id, 'provider', '🛠️ He terminado el trabajo de reparación. Por favor revisa el resultado y libera el pago retenido con Escrow.')" class="premium-btn w-full">
                <span>Marcar como Terminado</span>
                <span class="icon-circle">
                  <CheckCircle2 :size="18" />
                </span>
              </button>
            </div>
          </div>

          <!-- STATUS: COMPLETED (Escrow Released) -->
          <div v-else-if="activeContract.status === 'completed'">
            <div class="alert-box-success mb-6 glass-panel-sm text-center">
              <CheckCircle2 :size="32" class="text-green mb-2 block mx-auto" />
              <h4 class="card-title text-lg text-green mb-1">Trato Completado</h4>
              <p class="body-text text-sm opacity-75">El pago retenido de ${{ activeContract.agreementAmount }} MXN se ha transferido al proveedor.</p>
            </div>

            <!-- Rating prompt trigger if not submitted -->
            <div v-if="!activeContract.reviewSubmitted && state.activeMode === 'DEMANDA'" class="review-prompt-section">
              <p class="body-text text-xs mb-4 text-center">Alimenta el círculo de reputación y confianza local calificando el comportamiento y calidad del trabajo.</p>
              <button @click="showReviewModal = true" class="premium-btn w-full justify-center">
                <span>Calificar al Experto</span>
                <span class="icon-circle">
                  <Star :size="18" />
                </span>
              </button>
            </div>
            <div v-else-if="activeContract.reviewSubmitted" class="review-done text-center">
              <p class="body-text text-sm font-semibold text-green flex items-center justify-center gap-1">
                <Star :size="16" class="icon-star" /> ¡Reseña enviada con éxito!
              </p>
            </div>
            <div v-else class="provider-done-notice text-center">
              <p class="body-text text-xs opacity-75">Esperando a que el cliente asigne su calificación de estrellas.</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- POST-SERVICE RATING MODAL (4.3) -->
    <div v-if="showReviewModal && activeContract" class="modal-overlay">
      <div class="modal-content glass-panel text-left">
        <div class="flex justify-between items-center mb-6">
          <h3 class="card-title text-xl flex items-center gap-2">
            ⭐ Calificar a {{ activeContract.providerName }}
          </h3>
          <button @click="showReviewModal = false" class="close-btn-round">
            <X :size="18" />
          </button>
        </div>

        <form @submit.prevent="handleSubmitReview" class="review-form">
          <p class="body-text text-sm mb-6">Tu calificación es sumamente importante para la comunidad. Selecciona las estrellas y describe detalladamente tu experiencia.</p>
          
          <div class="form-group text-center items-center mb-6">
            <label class="form-label text-center mb-3">Puntualidad, Calidad y Comportamiento</label>
            <div class="star-rating-selector flex gap-2">
              <button 
                v-for="star in 5" 
                :key="star" 
                type="button"
                class="star-click-btn"
                @click="reviewRating = star"
              >
                <Star :size="32" :class="star <= reviewRating ? 'star-large-fill' : 'star-large-empty'" />
              </button>
            </div>
          </div>

          <div class="form-group mb-6 text-left">
            <label class="form-label">Comentario o Reseña Comercial</label>
            <div class="pill-input text-area-input">
              <textarea 
                v-model="reviewComment" 
                placeholder="Ej: Llegó súper puntual y reparó la fuga rapidísimo. Súper profesional y dejó todo ordenado." 
                rows="4"
                required
              ></textarea>
            </div>
          </div>

          <button type="submit" class="premium-btn w-full">
            <span>Enviar Calificación Comercial</span>
            <span class="icon-circle">
              <CheckCircle2 :size="18" />
            </span>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.chat-escrow-container {
  padding: 22px 0 48px;
}

.deal-room-header {
  position: relative;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) minmax(230px, 0.34fr);
  gap: 18px;
  align-items: center;
  overflow: hidden;
  padding: clamp(18px, 3vw, 28px);
}

.deal-room-header::before {
  content: '';
  position: absolute;
  inset: -90px -80px auto auto;
  width: 280px;
  height: 280px;
  border-radius: 50%;
  background: var(--accent);
  opacity: 0.13;
  filter: blur(18px);
}

.back-btn,
.deal-room-copy,
.deal-amount-card,
.escrow-progress {
  position: relative;
  z-index: 1;
}

.back-btn {
  padding: 10px 14px;
  font-size: 12px;
}

.deal-kicker {
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

.deal-room-copy .card-title {
  margin: 7px 0 5px;
  font-size: clamp(24px, 3vw, 38px);
  font-weight: 800;
  line-height: 1;
}

.deal-room-copy .body-text {
  max-width: 620px;
}

.deal-amount-card {
  padding: 16px;
  border: 1px solid var(--frost-border);
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.5);
}

.deal-amount-card span,
.deal-amount-card small {
  display: block;
  color: var(--text-muted);
  font-size: 11px;
  font-weight: 800;
}

.deal-amount-card strong {
  display: block;
  margin: 5px 0;
  color: var(--text-dark);
  font-family: var(--font-display);
  font-size: 24px;
  line-height: 1;
}

.escrow-progress {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin: 4px 0 0;
  list-style: none;
}

.escrow-progress li {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 8px;
  align-items: center;
  min-width: 0;
  padding: 10px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.42);
  border: 1px solid rgba(255, 255, 255, 0.56);
}

.escrow-progress li span {
  width: 11px;
  height: 11px;
  border-radius: 50%;
  border: 2px solid var(--accent);
  background: transparent;
}

.escrow-progress li.done span {
  background: var(--accent);
  box-shadow: 0 0 0 6px var(--accent-glow);
}

.escrow-progress li p {
  color: var(--text-dark);
  font-size: 12px;
  font-weight: 800;
}

.text-orange { color: var(--sunset-orange); }
.text-green { color: var(--verde-terraria); }
.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }

.chat-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(330px, 0.38fr);
  gap: 24px;
  align-items: start;
}

@media (max-width: 900px) {
  .chat-grid {
    grid-template-columns: 1fr;
  }
}

.chat-column {
  display: flex;
  flex-direction: column;
  height: 620px;
  padding: 24px;
}

.chat-column-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--frost-border);
  margin-bottom: 16px;
}

.chat-column-head .card-title {
  margin-top: 5px;
}

.chat-pill {
  border-radius: var(--radius-pill);
  padding: 8px 11px;
  color: var(--text-dark);
  background: rgba(255, 255, 255, 0.54);
  font-size: 12px;
  font-weight: 800;
}

.chat-history {
  flex: 1;
  overflow-y: auto;
  padding-right: 8px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.message-wrapper {
  display: flex;
  width: 100%;
}

.client-msg {
  justify-content: flex-end;
}

.provider-msg {
  justify-content: flex-start;
}

.message-bubble {
  max-width: 75%;
  padding: 14px 16px;
  border-radius: 24px;
  text-align: left;
}

.client-msg .message-bubble {
  background-color: var(--clay-glow);
  border-color: rgba(255, 130, 53, 0.2);
  border-top-right-radius: 4px;
}

.provider-msg .message-bubble {
  background-color: var(--sage-wash);
  border-color: rgba(59, 96, 67, 0.2);
  border-top-left-radius: 4px;
}

.message-sender {
  color: var(--text-dark);
}

.message-image {
  width: 100%;
  max-height: 180px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  border: 2px solid #ffffff;
}

.text-xxs {
  font-size: 9px;
}

.chat-controls-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  border-top: 1px solid var(--frost-border);
  padding-top: 16px;
}

.icon-only-btn {
  padding: 12px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(255,255,255,0.7);
  box-shadow: 0 2px 8px -2px var(--clay-shadow);
}

.send-btn-small {
  padding: 6px;
}

.sidebar-column {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.sidebar-section {
  padding: 24px;
}

.escrow-column {
  position: sticky;
  top: 118px;
}

.escrow-widget-head {
  display: grid;
  grid-template-columns: auto 1fr;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.escrow-widget-head .card-title {
  margin-top: 5px;
}

.payment-card-mock {
  padding: 16px;
  border: 1px solid var(--frost-border);
  border-radius: 24px;
  background-color: rgba(255,255,255,0.5);
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.02);
}

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

.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.alert-box-warning {
  border: 1px solid rgba(255, 130, 53, 0.3);
  background-color: var(--clay-glow);
  padding: 20px;
  border-radius: var(--radius-md);
}

.alert-box-success {
  border: 1px solid rgba(59, 96, 67, 0.3);
  background-color: var(--sage-wash);
  padding: 16px;
  border-radius: var(--radius-md);
}

.address-details-panel {
  border: 1px solid var(--frost-border);
  background-color: rgba(255, 255, 255, 0.6);
  padding: 16px;
  border-radius: 24px;
}

.font-mono {
  font-family: monospace;
}

.mini-route-map {
  height: 160px;
  border-radius: 24px;
}

.route-line-dashed {
  position: absolute;
  top: 35%;
  left: 42%;
  width: 15%;
  height: 20%;
  border-left: 3px dashed var(--accent);
  border-bottom: 3px dashed var(--accent);
  opacity: 0.7;
}

.badge-route-mini {
  background-color: var(--verde-terraria);
  color: #ffffff;
  font-size: 9px;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: bold;
}

.badge-route-mini.route-end {
  background-color: var(--sunset-orange);
}

.chat-closed-notice {
  padding: 12px;
  background-color: rgba(59, 96, 67, 0.05);
}

@media (max-width: 980px) {
  .deal-room-header,
  .chat-grid {
    grid-template-columns: 1fr;
  }

  .escrow-column {
    position: static;
  }

  .chat-column {
    height: min(620px, 72vh);
  }
}

@media (max-width: 640px) {
  .escrow-progress {
    grid-template-columns: 1fr 1fr;
  }

  .message-bubble {
    max-width: 90%;
  }

  .chat-controls-bar {
    align-items: stretch;
  }
}

.star-rating-selector {
  justify-content: center;
}

.star-click-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.star-click-btn:hover {
  transform: scale(1.15);
}

.star-large-fill {
  color: #FFB020;
  fill: #FFB020;
}

.star-large-empty {
  color: #D8D0C4;
}

.icon-star {
  color: #FFB020;
  fill: #FFB020;
}

.text-area-input textarea {
  resize: vertical;
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
</style>
