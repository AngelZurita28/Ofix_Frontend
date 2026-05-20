<script setup lang="ts">
import { ref, watch, nextTick } from 'vue';
import { useStore } from '../store';
import { 
  ArrowLeft, Send, Image, ShieldCheck, 
  Phone, Star, Clock, CheckCircle2, CreditCard, Lock
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
    '📸 He adjuntado una fotografía del estado del avance de la tarea para la garantía visual.', 
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
    <div class="chat-header glass-panel mb-6">
      <button @click="goBackToDashboard" class="secondary-btn text-xs py-2 px-3 flex items-center gap-1">
        <ArrowLeft :size="14" /> Volver al Tablón
      </button>
      
      <div v-if="activeContract" class="header-job-title text-left flex-1 pl-4">
        <span class="badge badge-success text-xs mb-1 uppercase font-semibold">Trato de Confianza</span>
        <h3 class="card-title text-xl">Contrato: {{ activeContract.providerName }} & {{ activeContract.clientName }}</h3>
      </div>
      
      <div v-if="activeContract" class="contract-amount font-bold text-orange text-lg">
        ${{ activeContract.agreementAmount }} MXN
      </div>
    </div>

    <!-- Active view container -->
    <div v-if="!activeContract" class="glass-panel text-center py-16">
      <h3 class="card-title text-xl mb-2">No hay un contrato seleccionado</h3>
      <p class="body-text">Regresa al panel para iniciar un trato comercial.</p>
    </div>

    <div v-else class="chat-grid">
      <!-- LEFT COLUMN: Messaging chat -->
      <div class="chat-column glass-panel">
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
          <h3 class="card-title mb-4 flex items-center gap-2">
            <ShieldCheck :size="18" class="text-orange animate-pulse" /> Escrow de Garantía Ofix
          </h3>

          <!-- STATUS: PENDING DEPOSIT -->
          <div v-if="activeContract.status === 'pending_deposit'">
            <!-- Client view of pending payment -->
            <div v-if="state.activeMode === 'DEMANDA'" class="client-payment-flow">
              <p class="body-text text-sm mb-4">Deposita de manera ultra-segura el fondo acordado. Ofix resguardará el dinero y solo lo entregará al técnico una vez que confirmes que el servicio fue entregado.</p>
              
              <div class="glass-panel-sm payment-card-mock mb-4">
                <div class="flex justify-between items-center mb-3">
                  <span class="font-bold text-sm">Pago Simulado (Stripe)</span>
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
                  <span>Fondear Garantía (${{ activeContract.agreementAmount }} MXN)</span>
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
                <p class="body-text text-sm font-semibold text-center mb-1">Esperando Depósito en Garantía</p>
                <p class="body-text text-xs text-center opacity-75">No asistas al lugar hasta que el cliente realice el fondeo. Te notificaremos de inmediato.</p>
              </div>
            </div>
          </div>

          <!-- STATUS: FUNDED (Address Unlocked!) -->
          <div v-else-if="activeContract.status === 'funded'">
            <div class="alert-box-success mb-6 glass-panel-sm text-center">
              <CheckCircle2 :size="24" class="text-green mb-1 block mx-auto" />
              <p class="body-text text-sm font-semibold text-green">✓ Garantía Escrow Fondeada</p>
              <p class="body-text text-xs opacity-75">Los fondos de ${{ activeContract.agreementAmount }} MXN se encuentran seguros.</p>
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
                <span>Liberar Garantía al Proveedor</span>
                <span class="icon-circle">
                  <ShieldCheck :size="18" />
                </span>
              </button>
            </div>
            <div v-else class="provider-actions-funded">
              <button @click="sendMessage(activeContract.id, 'provider', '🛠️ He terminado el trabajo de reparación. Por favor revisa el resultado y libera los fondos en garantía Escrow.')" class="premium-btn w-full">
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
              <p class="body-text text-sm opacity-75">La garantía de ${{ activeContract.agreementAmount }} MXN se ha transferido al proveedor.</p>
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
  padding: 24px 20px;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  padding: 16px 24px;
}

.text-orange { color: var(--sunset-orange); }
.text-green { color: var(--verde-terraria); }
.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }

.chat-grid {
  display: grid;
  grid-template-columns: 1fr 340px;
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
  height: 520px;
  padding: 24px;
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
  padding: 12px 16px;
  border-radius: var(--radius-md);
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

.payment-card-mock {
  padding: 16px;
  border: 1px solid var(--frost-border);
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
}

.font-mono {
  font-family: monospace;
}

.mini-route-map {
  height: 160px;
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
