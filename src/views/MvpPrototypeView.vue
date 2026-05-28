<script setup lang="ts">
import { computed, ref } from 'vue';
import { useStore } from '../store';
import type { Contract, Job, Provider } from '../store';
import {
  ArrowRight,
  BadgeCheck,
  Bell,
  CheckCircle2,
  ChevronRight,
  Clock,
  CreditCard,
  FileText,
  Lock,
  MessageSquare,
  Plus,
  ShieldCheck,
  Star,
  User
} from 'lucide-vue-next';

type PrototypeTab =
  | 'job'
  | 'provider'
  | 'onboarding'
  | 'contracts'
  | 'payment'
  | 'notifications'
  | 'disputes'
  | 'admin';

type PaymentStage = 'requires_payment' | 'processing' | 'funded' | 'release_pending' | 'released' | 'refunded';

const { state, selectedJob, selectedProvider, activeContract, navigateTo } = useStore();

const activeTab = ref<PrototypeTab>('job');
const paymentStage = ref<PaymentStage>('requires_payment');
const selectedAdminQueue = ref<'verifications' | 'disputes' | 'payments'>('verifications');
const showNotificationPanel = ref(false);

const tabs = [
  { id: 'job', label: 'Detalle tarea', icon: FileText },
  { id: 'provider', label: 'Perfil pro', icon: User },
  { id: 'onboarding', label: 'Onboarding', icon: BadgeCheck },
  { id: 'contracts', label: 'Contratos', icon: ShieldCheck },
  { id: 'payment', label: 'Pago escrow', icon: CreditCard },
  { id: 'notifications', label: 'Notificaciones', icon: Bell },
  { id: 'disputes', label: 'Disputas', icon: MessageSquare },
  { id: 'admin', label: 'Admin', icon: Lock }
] as const;

const fallbackJob = computed<Job>(() => selectedJob.value || state.jobs[0]);
const fallbackProvider = computed<Provider>(() => selectedProvider.value || state.providers[0]);
const fallbackContract = computed<Contract | null>(() => activeContract.value || state.contracts[0] || null);

const displayContract = computed(() => {
  const contract = fallbackContract.value;
  if (contract) return contract;

  return {
    id: 9001,
    jobId: fallbackJob.value?.id || 101,
    providerId: fallbackProvider.value?.id || 1,
    clientName: state.user?.name || 'Diana Laura',
    providerName: fallbackProvider.value?.name || 'Mateo Gonzalez',
    status: 'pending_deposit' as const,
    agreementAmount: fallbackJob.value?.budget || 650,
    messages: [],
    reviewSubmitted: false
  };
});

const contractCards = computed(() => {
  const realCards = state.contracts.map((contract) => ({
    id: contract.id,
    title: state.jobs.find((job) => job.id === contract.jobId)?.title || 'Trabajo contratado',
    clientName: contract.clientName,
    providerName: contract.providerName,
    amount: contract.agreementAmount,
    status: contract.status,
    source: 'real'
  }));

  return [
    ...realCards,
    {
      id: 7001,
      title: 'Cambio de mezcladora y sellado',
      clientName: 'Mariana V.',
      providerName: 'Mateo Gonzalez',
      amount: 920,
      status: 'funded' as const,
      source: 'mock'
    },
    {
      id: 7002,
      title: 'Revision de centro de carga',
      clientName: 'Fernando T.',
      providerName: 'Valeria Solares',
      amount: 1250,
      status: 'completed' as const,
      source: 'mock'
    },
    {
      id: 7003,
      title: 'Puerta principal desajustada',
      clientName: 'Hector G.',
      providerName: 'Alejandro Ruiz',
      amount: 780,
      status: 'pending_deposit' as const,
      source: 'mock'
    }
  ];
});

const jobTimeline = computed(() => [
  { label: 'Publicada', detail: 'Visible con ubicacion aproximada', done: true },
  { label: 'Postulaciones', detail: `${fallbackJob.value?.bids.length || 3} propuestas recibidas`, done: true },
  { label: 'Acuerdo', detail: 'Cliente compara perfil, precio y propuesta', done: displayContract.value.status !== 'pending_deposit' },
  { label: 'Escrow', detail: 'Direccion exacta se libera al pagar por OpenPay', done: ['funded', 'completed'].includes(displayContract.value.status) },
  { label: 'Cierre', detail: 'Trabajo, liberacion y resena', done: displayContract.value.status === 'completed' }
]);

const paymentStages: { id: PaymentStage; label: string; detail: string }[] = [
  { id: 'requires_payment', label: 'Intento de pago', detail: 'Captura y revision del metodo.' },
  { id: 'processing', label: 'Procesando', detail: 'Pasarela confirma autorizacion.' },
  { id: 'funded', label: 'Pago retenido', detail: 'Pago completo retenido y direccion liberada.' },
  { id: 'release_pending', label: 'Liberacion pendiente', detail: 'Cliente valida evidencia final.' },
  { id: 'released', label: 'Liberado', detail: 'Pago enviado al profesional.' },
  { id: 'refunded', label: 'Reembolso', detail: 'Ruta alternativa por cancelacion/disputa.' }
];

const notifications = computed(() => [
  { type: 'bid.created', title: 'Nueva postulacion recibida', detail: `${fallbackProvider.value.name} envio una propuesta tecnica.`, channel: 'In-app' },
  { type: 'contract.funded', title: 'Pago retenido con Escrow', detail: 'El pago completo quedo retenido y la direccion exacta fue revelada.', channel: 'SMS' },
  { type: 'message.created', title: 'Mensaje nuevo', detail: 'El profesional adjunto una evidencia del avance.', channel: 'Push' },
  { type: 'review.created', title: 'Resena pendiente', detail: 'Califica el trabajo para cerrar reputacion.', channel: 'Email' }
]);

const formatCurrency = (value: number) => `$${value.toLocaleString('es-MX')} MXN`;

const statusCopy = (status: string) => {
  const labels: Record<string, string> = {
    pending_deposit: 'Pago pendiente',
    funded: 'Pago retenido',
    provider_en_route: 'En camino',
    arrived: 'En sitio',
    work_started: 'En ejecucion',
    work_submitted: 'Revision final',
    completed: 'Completado',
    cancelled: 'Cancelado',
    disputed: 'En disputa'
  };
  return labels[status] || status;
};

const movePayment = (stage: PaymentStage) => {
  paymentStage.value = stage;
};

const openRealContractChat = (contractId: number | string, source: string) => {
  if (source !== 'real') return;
  state.activeContractId = Number(contractId);
  navigateTo('chat-escrow');
};
</script>

<template>
  <div class="mvp-prototype">
    <section class="prototype-hero glass-panel">
      <div class="hero-copy">
        <span class="panel-label">Prototipo frontend MVP</span>
        <h2 class="section-title">Pantallas operativas faltantes para llevar Ofiix a producto.</h2>
        <p class="body-text">
          Esta vista simula las rutas, estados y modulos descritos en DEVELOPMENT.md: detalle de tarea,
          perfil profesional independiente, onboarding, contratos, pagos, notificaciones, disputas y admin.
        </p>
      </div>

      <button class="premium-btn" @click="showNotificationPanel = !showNotificationPanel">
        <span>{{ showNotificationPanel ? 'Ocultar inbox' : 'Ver inbox' }}</span>
        <span class="icon-circle">
          <Bell :size="16" />
        </span>
      </button>
    </section>

    <aside v-if="showNotificationPanel" class="notification-strip glass-panel-sm">
      <div v-for="item in notifications" :key="item.type" class="notification-item">
        <span class="badge badge-success">{{ item.channel }}</span>
        <strong>{{ item.title }}</strong>
        <small>{{ item.detail }}</small>
      </div>
    </aside>

    <nav class="prototype-tabs glass-panel-sm" aria-label="Modulos del prototipo">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        :class="['prototype-tab', { active: activeTab === tab.id }]"
        @click="activeTab = tab.id"
      >
        <component :is="tab.icon" :size="16" />
        <span>{{ tab.label }}</span>
      </button>
    </nav>

    <section v-if="activeTab === 'job'" class="prototype-grid">
      <div class="glass-panel prototype-main">
        <div class="detail-head">
          <div>
            <span class="panel-label">/jobs/:id</span>
            <h3 class="section-title">{{ fallbackJob.title }}</h3>
            <p class="body-text">{{ fallbackJob.description }}</p>
          </div>
          <div class="amount-chip">
            <small>Presupuesto</small>
            <strong>{{ formatCurrency(fallbackJob.budget) }}</strong>
          </div>
        </div>

        <div class="timeline-row">
          <article v-for="step in jobTimeline" :key="step.label" :class="['timeline-step', { done: step.done }]">
            <span class="timeline-dot">
              <CheckCircle2 v-if="step.done" :size="14" />
            </span>
            <strong>{{ step.label }}</strong>
            <small>{{ step.detail }}</small>
          </article>
        </div>

        <div class="role-panels">
          <article class="role-panel">
            <span class="panel-label">Cliente</span>
            <h4>Revision y decision</h4>
            <p>Compara postulaciones, historial, precio, llegada estimada y condiciones antes de aceptar.</p>
            <button class="secondary-btn">Editar tarea</button>
          </article>

          <article class="role-panel">
            <span class="panel-label">Profesional</span>
            <h4>Postulacion tecnica</h4>
            <p>Ve solo la zona aproximada, envia propuesta y espera aceptacion antes de recibir direccion.</p>
            <button class="secondary-btn">Retirar postulacion</button>
          </article>

          <article class="role-panel">
            <span class="panel-label">Soporte</span>
            <h4>Trazabilidad</h4>
            <p>Consulta cambios de estado, revelacion de ubicacion, reportes y eventos de pago.</p>
            <button class="secondary-btn">Ver auditoria</button>
          </article>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Postulaciones</span>
        <div class="bid-preview-card" v-for="provider in state.providers" :key="provider.id">
          <div>
            <strong>{{ provider.name }}</strong>
            <small>{{ provider.category }} · {{ provider.rating }} estrellas</small>
          </div>
          <span>{{ formatCurrency(provider.pricePerHour * 3) }}</span>
        </div>
        <button class="premium-btn side-action">
          <span>Aceptar mejor propuesta</span>
          <span class="icon-circle"><ArrowRight :size="14" /></span>
        </button>
      </aside>
    </section>

    <section v-else-if="activeTab === 'provider'" class="prototype-grid">
      <div class="glass-panel provider-public">
        <div class="provider-profile-head">
          <img :src="fallbackProvider.profileImg" :alt="fallbackProvider.name" />
          <div>
            <span class="badge badge-success">Identidad verificada</span>
            <h3 class="section-title">{{ fallbackProvider.name }}</h3>
            <p class="body-text">{{ fallbackProvider.bio }}</p>
          </div>
        </div>

        <div class="metric-grid">
          <div><strong>{{ fallbackProvider.rating }}</strong><span>Rating</span></div>
          <div><strong>{{ fallbackProvider.completedJobs }}</strong><span>Trabajos</span></div>
          <div><strong>{{ formatCurrency(fallbackProvider.pricePerHour) }}</strong><span>Tarifa hora</span></div>
          <div><strong>{{ fallbackProvider.responseTime }}</strong><span>Respuesta</span></div>
        </div>

        <div class="portfolio-grid">
          <img v-for="photo in fallbackProvider.portfolio" :key="photo" :src="photo" alt="Trabajo del portafolio" />
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Politicas del profesional</span>
        <ul class="clean-list">
          <li>Incluye diagnostico inicial y presupuesto final antes de comprar materiales.</li>
          <li>Garantia visual con fotografias antes, durante y despues.</li>
          <li>No inicia traslado hasta que el cliente pague por OpenPay y el monto quede retenido con Escrow.</li>
          <li>Zonas de cobertura: Centro, Roma, Condesa y Del Valle.</li>
        </ul>
        <button class="premium-btn side-action">
          <span>Contratar directo</span>
          <span class="icon-circle"><Plus :size="14" /></span>
        </button>
      </aside>
    </section>

    <section v-else-if="activeTab === 'onboarding'" class="prototype-grid">
      <div class="glass-panel prototype-main">
        <span class="panel-label">/settings/provider</span>
        <h3 class="section-title">Onboarding profesional con verificacion progresiva.</h3>

        <div class="onboarding-steps">
          <article class="onboarding-step complete">
            <BadgeCheck :size="18" />
            <strong>Datos profesionales</strong>
            <small>Nombre publico, bio, telefono y foto.</small>
          </article>
          <article class="onboarding-step complete">
            <BadgeCheck :size="18" />
            <strong>Categorias y habilidades</strong>
            <small>Oficios, especialidades y tarifa base.</small>
          </article>
          <article class="onboarding-step active">
            <Clock :size="18" />
            <strong>Zonas y disponibilidad</strong>
            <small>Radio, horarios, urgencias y agenda.</small>
          </article>
          <article class="onboarding-step">
            <Lock :size="18" />
            <strong>Documentos privados</strong>
            <small>Identificacion y certificaciones para admin.</small>
          </article>
          <article class="onboarding-step">
            <Star :size="18" />
            <strong>Revision final</strong>
            <small>Estado: pending_verification.</small>
          </article>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Preview publico</span>
        <div class="profile-mini-preview">
          <img :src="fallbackProvider.profileImg" :alt="fallbackProvider.name" />
          <strong>{{ fallbackProvider.name }}</strong>
          <small>{{ fallbackProvider.category }} · Perfil al 72%</small>
        </div>
        <div class="upload-zone">Arrastra INE, comprobante o certificado</div>
        <button class="premium-btn side-action">
          <span>Enviar a revision</span>
          <span class="icon-circle"><ChevronRight :size="14" /></span>
        </button>
      </aside>
    </section>

    <section v-else-if="activeTab === 'contracts'" class="prototype-grid">
      <div class="glass-panel prototype-main">
        <span class="panel-label">/contracts</span>
        <h3 class="section-title">Centro de contratos separado del chat.</h3>

        <div class="contract-board">
          <article
            v-for="contract in contractCards"
            :key="contract.id"
            :class="['contract-card-demo', contract.status]"
            @click="openRealContractChat(contract.id, contract.source)"
          >
            <div>
              <span class="badge badge-warning">{{ statusCopy(contract.status) }}</span>
              <h4>{{ contract.title }}</h4>
              <small>{{ contract.clientName }} / {{ contract.providerName }}</small>
            </div>
            <strong>{{ formatCurrency(contract.amount) }}</strong>
          </article>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Detalle contrato</span>
        <h4>{{ displayContract.clientName }} y {{ displayContract.providerName }}</h4>
        <p class="body-text">Pago retenido: {{ formatCurrency(displayContract.agreementAmount) }}</p>
        <div class="contract-actions">
          <button class="secondary-btn">Confirmar llegada</button>
          <button class="secondary-btn">Marcar terminado</button>
          <button class="secondary-btn">Abrir disputa</button>
        </div>
      </aside>
    </section>

    <section v-else-if="activeTab === 'payment'" class="prototype-grid">
      <div class="glass-panel prototype-main">
        <span class="panel-label">/contracts/:id/fund</span>
        <h3 class="section-title">Simulacion completa de pago, escrow y liberacion.</h3>

        <div class="payment-stage-grid">
          <button
            v-for="stage in paymentStages"
            :key="stage.id"
            :class="['payment-stage-card', { active: paymentStage === stage.id }]"
            @click="movePayment(stage.id)"
          >
            <strong>{{ stage.label }}</strong>
            <small>{{ stage.detail }}</small>
          </button>
        </div>

        <div class="payment-terminal">
          <div class="mock-card">
            <span>Ofiix Escrow</span>
            <strong>**** 2842</strong>
            <small>{{ paymentStage }}</small>
          </div>

          <div class="payment-copy">
            <span class="badge badge-success">{{ statusCopy(paymentStage) }}</span>
            <h4>{{ formatCurrency(displayContract.agreementAmount) }} retenidos</h4>
            <p>
              Servicio: {{ formatCurrency(displayContract.agreementAmount) }} · Comision:
              {{ formatCurrency(Math.round(displayContract.agreementAmount * 0.08)) }} · Total:
              {{ formatCurrency(Math.round(displayContract.agreementAmount * 1.08)) }}
            </p>
            <div class="payment-buttons">
              <button class="premium-btn" @click="movePayment('processing')">
                <span>Simular pago</span>
                <span class="icon-circle"><CreditCard :size="14" /></span>
              </button>
              <button class="secondary-btn" @click="movePayment('refunded')">Simular reembolso</button>
            </div>
          </div>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Ledger visual</span>
        <div class="ledger-row"><span>Cargo cliente</span><strong>{{ formatCurrency(Math.round(displayContract.agreementAmount * 1.08)) }}</strong></div>
        <div class="ledger-row"><span>Saldo escrow</span><strong>{{ formatCurrency(displayContract.agreementAmount) }}</strong></div>
        <div class="ledger-row"><span>Comision</span><strong>{{ formatCurrency(Math.round(displayContract.agreementAmount * 0.08)) }}</strong></div>
        <div class="ledger-row"><span>Liberacion pro</span><strong>{{ paymentStage === 'released' ? formatCurrency(displayContract.agreementAmount) : '$0 MXN' }}</strong></div>
      </aside>
    </section>

    <section v-else-if="activeTab === 'notifications'" class="prototype-grid">
      <div class="glass-panel prototype-main">
        <span class="panel-label">Centro de notificaciones</span>
        <h3 class="section-title">Eventos criticos por canal.</h3>
        <div class="notification-board">
          <article v-for="item in notifications" :key="item.type" class="notification-large">
            <Bell :size="18" />
            <div>
              <strong>{{ item.title }}</strong>
              <small>{{ item.type }} · {{ item.channel }}</small>
              <p>{{ item.detail }}</p>
            </div>
          </article>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Preferencias</span>
        <label class="toggle-line"><input type="checkbox" checked /> In-app</label>
        <label class="toggle-line"><input type="checkbox" checked /> Email</label>
        <label class="toggle-line"><input type="checkbox" checked /> SMS eventos criticos</label>
        <label class="toggle-line"><input type="checkbox" /> Push mobile</label>
      </aside>
    </section>

    <section v-else-if="activeTab === 'disputes'" class="prototype-grid">
      <div class="glass-panel prototype-main">
        <span class="panel-label">/contracts/:id/dispute</span>
        <h3 class="section-title">Disputa por evidencia insuficiente.</h3>
        <div class="dispute-layout">
          <article class="evidence-card">
            <span class="badge badge-warning">Antes</span>
            <p>Fotografia de fuga antes de iniciar.</p>
          </article>
          <article class="evidence-card">
            <span class="badge badge-success">Durante</span>
            <p>Avance con tuberia reemplazada.</p>
          </article>
          <article class="evidence-card muted">
            <span class="badge">Despues</span>
            <p>Pendiente de evidencia final.</p>
          </article>
        </div>
        <div class="support-chat">
          <p><strong>Cliente:</strong> El trabajo parece incompleto y no hay foto final.</p>
          <p><strong>Profesional:</strong> Puedo regresar hoy y adjuntar evidencia.</p>
          <p><strong>Soporte:</strong> Escrow queda retenido mientras se revisa.</p>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Resolucion</span>
        <button class="secondary-btn">Liberar pago</button>
        <button class="secondary-btn">Reembolso total</button>
        <button class="secondary-btn">Reembolso parcial</button>
        <button class="premium-btn side-action">
          <span>Resolver caso</span>
          <span class="icon-circle"><CheckCircle2 :size="14" /></span>
        </button>
      </aside>
    </section>

    <section v-else class="prototype-grid">
      <div class="glass-panel prototype-main">
        <span class="panel-label">Panel administrativo</span>
        <h3 class="section-title">Operaciones, verificacion y soporte.</h3>

        <div class="admin-metrics">
          <article><strong>18</strong><span>Verificaciones</span></article>
          <article><strong>7</strong><span>Disputas abiertas</span></article>
          <article><strong>$42k</strong><span>Escrow retenido</span></article>
          <article><strong>3</strong><span>Alertas de fraude</span></article>
        </div>

        <div class="admin-queues">
          <button :class="{ active: selectedAdminQueue === 'verifications' }" @click="selectedAdminQueue = 'verifications'">Verificaciones</button>
          <button :class="{ active: selectedAdminQueue === 'disputes' }" @click="selectedAdminQueue = 'disputes'">Disputas</button>
          <button :class="{ active: selectedAdminQueue === 'payments' }" @click="selectedAdminQueue = 'payments'">Pagos</button>
        </div>

        <div class="admin-table">
          <div class="admin-row">
            <span>{{ selectedAdminQueue === 'verifications' ? 'Mateo Gonzalez' : selectedAdminQueue === 'disputes' ? 'Contrato #7001' : 'Pago #PX-2842' }}</span>
            <span>{{ selectedAdminQueue === 'verifications' ? 'INE pendiente' : selectedAdminQueue === 'disputes' ? 'Revision evidencia' : 'Webhook confirmado' }}</span>
            <button class="secondary-btn">Revisar</button>
          </div>
          <div class="admin-row">
            <span>{{ selectedAdminQueue === 'verifications' ? 'Valeria Solares' : selectedAdminQueue === 'disputes' ? 'Contrato #7003' : 'Payout #PO-1039' }}</span>
            <span>{{ selectedAdminQueue === 'verifications' ? 'Certificado electrico' : selectedAdminQueue === 'disputes' ? 'No show reportado' : 'Liberacion pendiente' }}</span>
            <button class="secondary-btn">Revisar</button>
          </div>
        </div>
      </div>

      <aside class="glass-panel prototype-side">
        <span class="panel-label">Auditoria</span>
        <ul class="clean-list">
          <li>location_revealed registrado despues del pago retenido con Escrow.</li>
          <li>payment.succeeded recibido desde pasarela simulada.</li>
          <li>review.created pendiente para contrato completado.</li>
          <li>dispute.open bloqueo liberacion de fondos.</li>
        </ul>
      </aside>
    </section>
  </div>
</template>

<style scoped>
.mvp-prototype {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.prototype-hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.hero-copy {
  max-width: 720px;
  text-align: left;
}

.panel-label {
  display: inline-flex;
  margin-bottom: 8px;
  font-family: var(--font-body);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--accent-text);
}

.notification-strip,
.prototype-tabs {
  display: flex;
  gap: 10px;
  align-items: center;
  overflow-x: auto;
}

.notification-item {
  min-width: 260px;
  text-align: left;
  display: grid;
  gap: 5px;
}

.notification-item small,
.prototype-side small,
.timeline-step small,
.bid-preview-card small,
.profile-mini-preview small {
  color: var(--text-muted);
}

.prototype-tabs {
  position: sticky;
  top: 16px;
  z-index: 3;
}

.prototype-tab {
  border: 1px solid transparent;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.42);
  color: var(--text-muted);
  padding: 10px 14px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  cursor: pointer;
  font-family: var(--font-display);
  font-weight: 600;
}

.prototype-tab.active {
  background: var(--obsidian-ceramic);
  color: #ffffff;
  border-color: color-mix(in srgb, var(--accent) 35%, transparent);
}

.prototype-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 340px;
  gap: 18px;
  align-items: start;
}

.prototype-main,
.prototype-side {
  text-align: left;
}

.detail-head,
.provider-profile-head {
  display: flex;
  justify-content: space-between;
  gap: 22px;
  align-items: flex-start;
}

.amount-chip {
  min-width: 190px;
  border-radius: var(--radius-md);
  background: var(--obsidian-ceramic);
  color: #ffffff;
  padding: 18px;
  display: grid;
  gap: 4px;
}

.amount-chip small,
.mock-card small {
  color: rgba(255, 255, 255, 0.72);
}

.amount-chip strong {
  font-size: 24px;
  font-family: var(--font-display);
}

.timeline-row,
.role-panels,
.metric-grid,
.payment-stage-grid,
.admin-metrics {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-top: 22px;
}

.timeline-row {
  grid-template-columns: repeat(5, minmax(0, 1fr));
}

.timeline-step,
.role-panel,
.onboarding-step,
.payment-stage-card,
.notification-large,
.evidence-card,
.admin-metrics article {
  border: 1px solid rgba(255, 255, 255, 0.58);
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.46);
  padding: 16px;
}

.timeline-step {
  display: grid;
  gap: 8px;
}

.timeline-dot {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 1px solid var(--frost-border);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
  background: rgba(255, 255, 255, 0.5);
}

.timeline-step.done .timeline-dot {
  background: var(--accent);
  color: #ffffff;
}

.role-panels {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.role-panel h4,
.prototype-side h4 {
  font-family: var(--font-display);
  margin-bottom: 8px;
}

.role-panel p,
.support-chat p,
.evidence-card p,
.notification-large p {
  color: var(--text-muted);
  line-height: 1.45;
  font-size: 14px;
}

.bid-preview-card,
.ledger-row,
.admin-row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid rgba(105, 95, 87, 0.12);
}

.bid-preview-card div {
  display: grid;
  gap: 2px;
}

.side-action {
  width: 100%;
  margin-top: 18px;
}

.provider-profile-head {
  align-items: center;
}

.provider-profile-head img {
  width: 132px;
  height: 132px;
  border-radius: var(--radius-md);
  object-fit: cover;
  box-shadow: 0 18px 42px -26px rgba(24, 27, 25, 0.4);
}

.metric-grid div,
.admin-metrics article {
  display: grid;
  gap: 4px;
}

.metric-grid strong,
.admin-metrics strong {
  font-family: var(--font-display);
  font-size: 24px;
  color: var(--text-dark);
}

.metric-grid span,
.admin-metrics span {
  color: var(--text-muted);
  font-size: 12px;
}

.portfolio-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  margin-top: 20px;
}

.portfolio-grid img {
  width: 100%;
  aspect-ratio: 16 / 10;
  object-fit: cover;
  border-radius: var(--radius-md);
}

.clean-list {
  list-style: none;
  display: grid;
  gap: 12px;
  color: var(--text-muted);
  line-height: 1.45;
  font-size: 14px;
}

.clean-list li {
  padding-left: 18px;
  position: relative;
}

.clean-list li::before {
  content: '';
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--accent);
  position: absolute;
  top: 8px;
  left: 0;
}

.onboarding-steps {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 12px;
  margin-top: 22px;
}

.onboarding-step {
  display: grid;
  gap: 10px;
}

.onboarding-step.complete {
  border-color: color-mix(in srgb, var(--verde-terraria) 28%, transparent);
}

.onboarding-step.active {
  border-color: color-mix(in srgb, var(--accent) 40%, transparent);
  box-shadow: 0 0 0 4px var(--accent-glow);
}

.profile-mini-preview {
  display: grid;
  place-items: center;
  gap: 8px;
  text-align: center;
}

.profile-mini-preview img {
  width: 84px;
  height: 84px;
  border-radius: 50%;
  object-fit: cover;
}

.upload-zone {
  margin-top: 18px;
  min-height: 110px;
  border-radius: var(--radius-md);
  border: 1.5px dashed rgba(105, 95, 87, 0.26);
  display: grid;
  place-items: center;
  color: var(--text-muted);
  text-align: center;
  padding: 16px;
}

.contract-board {
  display: grid;
  gap: 12px;
  margin-top: 20px;
}

.contract-card-demo {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: center;
  padding: 16px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.52);
  border: 1px solid rgba(255, 255, 255, 0.62);
  cursor: pointer;
}

.contract-card-demo h4 {
  margin: 10px 0 4px;
  font-family: var(--font-display);
}

.contract-card-demo.funded {
  border-color: color-mix(in srgb, var(--verde-terraria) 24%, transparent);
}

.contract-card-demo.completed {
  opacity: 0.74;
}

.contract-actions {
  display: grid;
  gap: 10px;
  margin-top: 18px;
}

.payment-stage-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.payment-stage-card {
  text-align: left;
  cursor: pointer;
  display: grid;
  gap: 8px;
  font-family: var(--font-body);
}

.payment-stage-card.active {
  background: var(--obsidian-ceramic);
  color: #ffffff;
}

.payment-stage-card.active small {
  color: rgba(255, 255, 255, 0.72);
}

.payment-terminal {
  display: grid;
  grid-template-columns: 260px 1fr;
  gap: 18px;
  margin-top: 22px;
  align-items: stretch;
}

.mock-card {
  min-height: 170px;
  border-radius: 28px;
  background:
    radial-gradient(circle at 88% 18%, rgba(255, 255, 255, 0.18), transparent 34%),
    linear-gradient(145deg, rgba(24, 27, 25, 0.92), rgba(24, 27, 25, 0.74));
  color: #ffffff;
  padding: 22px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  box-shadow: 0 22px 52px -34px rgba(24, 27, 25, 0.62);
}

.mock-card strong {
  font-family: var(--font-display);
  font-size: 24px;
}

.payment-copy {
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.46);
  padding: 20px;
}

.payment-copy h4 {
  font-family: var(--font-display);
  font-size: 28px;
  margin: 10px 0;
}

.payment-copy p {
  color: var(--text-muted);
  line-height: 1.45;
}

.payment-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 18px;
}

.notification-board {
  display: grid;
  gap: 12px;
  margin-top: 18px;
}

.notification-large {
  display: flex;
  align-items: flex-start;
  gap: 14px;
}

.notification-large div {
  display: grid;
  gap: 5px;
}

.toggle-line {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 12px 0;
  font-weight: 600;
  color: var(--text-dark);
}

.dispute-layout {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  margin-top: 18px;
}

.evidence-card {
  min-height: 150px;
}

.evidence-card.muted {
  opacity: 0.68;
}

.support-chat {
  margin-top: 18px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.48);
  padding: 16px;
  display: grid;
  gap: 10px;
}

.admin-queues {
  display: flex;
  gap: 10px;
  margin: 20px 0;
}

.admin-queues button {
  border: 1px solid var(--frost-border);
  background: rgba(255, 255, 255, 0.5);
  border-radius: var(--radius-pill);
  padding: 10px 14px;
  font-family: var(--font-display);
  font-weight: 600;
  cursor: pointer;
}

.admin-queues button.active {
  background: var(--accent);
  color: #ffffff;
}

.admin-table {
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.44);
  padding: 4px 16px;
}

.admin-row:last-child,
.ledger-row:last-child,
.bid-preview-card:last-child {
  border-bottom: none;
}

@media (max-width: 980px) {
  .prototype-hero,
  .detail-head,
  .provider-profile-head {
    flex-direction: column;
    align-items: stretch;
  }

  .prototype-grid,
  .payment-terminal {
    grid-template-columns: 1fr;
  }

  .timeline-row,
  .role-panels,
  .metric-grid,
  .onboarding-steps,
  .payment-stage-grid,
  .dispute-layout,
  .admin-metrics {
    grid-template-columns: 1fr;
  }

  .amount-chip {
    min-width: 0;
  }
}
</style>
