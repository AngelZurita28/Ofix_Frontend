import { reactive, computed } from 'vue';

// Types
export interface Review {
  id: number;
  reviewer: string;
  rating: number;
  comment: string;
  date: string;
}

export interface Provider {
  id: number;
  name: string;
  category: string;
  rating: number;
  completedJobs: number;
  badges: string[];
  bio: string;
  pricePerHour: number;
  profileImg: string;
  portfolio: string[];
  status: 'online' | 'offline';
  responseTime: string;
  reviews: Review[];
  lat: number; // 0 to 100 on simulated canvas
  lng: number; // 0 to 100 on simulated canvas
}

export interface Bid {
  providerId: number;
  providerName: string;
  proposal: string;
  bidAmount: number;
  estimatedArrival: string;
}

export interface Job {
  id: number;
  title: string;
  category: string;
  description: string;
  budget: number;
  isUrgent: boolean;
  exactAddress: string;
  approxAddress: string;
  status: 'open' | 'bidded' | 'in_progress' | 'completed';
  clientName: string;
  lat: number;
  lng: number;
  bids: Bid[];
}

export interface Message {
  sender: 'client' | 'provider';
  content: string;
  timestamp: string;
  image?: string;
}

export interface Contract {
  id: number;
  jobId: number;
  providerId: number;
  clientName: string;
  providerName: string;
  status: 'pending_deposit' | 'funded' | 'completed';
  agreementAmount: number;
  messages: Message[];
  reviewSubmitted: boolean;
}

export interface User {
  name: string;
  email: string;
  phone: string;
  role: 'DEMANDA' | 'OFERTA';
}

// Initial Mock Providers
const initialProviders: Provider[] = [
  {
    id: 1,
    name: 'Mateo González',
    category: 'Fontanería',
    rating: 4.9,
    completedJobs: 84,
    badges: ['Identidad Verificada', 'Puntual', 'Súper Pro'],
    bio: 'Especialista en detección de fugas de agua y reparación de tuberías de alta presión. Más de 12 años resolviendo emergencias del hogar en la zona metropolitana. Rápido, honesto y ordenado.',
    pricePerHour: 220,
    profileImg: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150&auto=format&fit=crop&q=80',
    portfolio: [
      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&auto=format&fit=crop&q=80'
    ],
    status: 'online',
    responseTime: '10 min',
    reviews: [
      { id: 1, reviewer: 'Sofía L.', rating: 5, comment: 'Excelente servicio. Detectó una fuga que otros dos plomeros no pudieron encontrar. Muy recomendado.', date: 'Hace 3 días' },
      { id: 2, reviewer: 'Carlos M.', rating: 4.8, comment: 'Muy profesional y puntual. Explicó todo a detalle antes de hacer el trabajo.', date: 'Hace 1 semana' }
    ],
    lat: 35,
    lng: 42
  },
  {
    id: 2,
    name: 'Valeria Solares',
    category: 'Electricidad',
    rating: 4.8,
    completedJobs: 56,
    badges: ['Certificada', 'Detallista'],
    bio: 'Ingeniera eléctrica y técnica independiente. Realizo instalaciones completas de iluminación inteligente, cortos circuitos, reparación de tableros eléctricos y balanceo de cargas. Trabajo garantizado.',
    pricePerHour: 280,
    profileImg: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
    portfolio: [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1558224494-ef8b242e551f?w=400&auto=format&fit=crop&q=80'
    ],
    status: 'online',
    responseTime: '15 min',
    reviews: [
      { id: 1, reviewer: 'Andrea R.', rating: 5, comment: 'Hizo la instalación de mi casa inteligente de manera impecable. Súper atenta y sabe lo que hace.', date: 'Hace 5 días' }
    ],
    lat: 65,
    lng: 50
  },
  {
    id: 3,
    name: 'Alejandro Ruiz',
    category: 'Carpintería',
    rating: 4.7,
    completedJobs: 92,
    badges: ['Puntual', 'Creativo'],
    bio: 'Carpintero de oficio y diseñador de muebles de madera maciza. Restauración de clósets, reparación de puertas caídas, cocinas integrales y trabajos a la medida con acabados finos y aceites naturales.',
    pricePerHour: 250,
    profileImg: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    portfolio: [
      'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=400&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400&auto=format&fit=crop&q=80'
    ],
    status: 'online',
    responseTime: '20 min',
    reviews: [
      { id: 1, reviewer: 'Héctor G.', rating: 4, comment: 'Reparó mis puertas principales. Quedaron perfectas y ya no arrastran. Buen precio.', date: 'Hace 2 semanas' }
    ],
    lat: 48,
    lng: 72
  }
];

// Initial Mock Jobs
const initialJobs: Job[] = [
  {
    id: 101,
    title: 'Fuga severa debajo de tarja de cocina',
    category: 'Fontanería',
    description: 'El tubo del desagüe principal de la cocina se agrietó y hay filtración abundante de agua cada vez que se abre la llave. Requiero cambio de tubería PVC y sellado.',
    budget: 650,
    isUrgent: true,
    exactAddress: 'Calle Río Lerma 142, Dpto 402, Cuauhtémoc, CDMX',
    approxAddress: 'Cerca del Monumento a la Independencia, Cuauhtémoc',
    status: 'open',
    clientName: 'Diana Laura',
    lat: 40,
    lng: 38,
    bids: []
  },
  {
    id: 102,
    title: 'Cortocircuito en sala comedor',
    category: 'Electricidad',
    description: 'Al encender la luz de la sala se escuchó un chispazo en el interruptor principal y nos quedamos sin luz únicamente en esa zona. Los interruptores de seguridad (breaker) se botaron.',
    budget: 800,
    isUrgent: false,
    exactAddress: 'Av. Coyoacán 874, Col. Del Valle, Benito Juárez, CDMX',
    approxAddress: 'Colonia Del Valle Norte, Benito Juárez',
    status: 'open',
    clientName: 'Fernando T.',
    lat: 58,
    lng: 60,
    bids: []
  }
];

// Global State Store
const state = reactive({
  // Auth & Nav
  currentView: 'welcome' as 'welcome' | 'auth' | 'demand-dashboard' | 'offer-dashboard' | 'chat-escrow' | 'mvp-prototype' | 'presentation',
  activeMode: 'OFERTA' as 'DEMANDA' | 'OFERTA',
  user: null as User | null,
  
  // Data lists
  providers: initialProviders,
  jobs: initialJobs,
  contracts: [] as Contract[],
  
  // Selection states
  selectedProviderId: null as number | null,
  selectedJobId: null as number | null,
  activeContractId: null as number | null,
  
  // New Job Temp State
  isPublishingModalOpen: false,
});

// Set body classes reactively based on active mode
const updateBodyClass = () => {
  if (state.activeMode === 'OFERTA') {
    document.body.classList.add('mode-oferta');
  } else {
    document.body.classList.remove('mode-oferta');
  }
};
updateBodyClass();

// Actions
export const useStore = () => {
  
  // Switch Global Mode
  const toggleMode = () => {
    state.activeMode = state.activeMode === 'DEMANDA' ? 'OFERTA' : 'DEMANDA';
    updateBodyClass();
    
    // Auto redirect dashboard if already authenticated
    if (state.user) {
      state.currentView = state.activeMode === 'DEMANDA' ? 'demand-dashboard' : 'offer-dashboard';
    }
  };
  
  const setMode = (mode: 'DEMANDA' | 'OFERTA') => {
    state.activeMode = mode;
    updateBodyClass();
  };

  // Navigations
  const navigateTo = (view: 'welcome' | 'auth' | 'demand-dashboard' | 'offer-dashboard' | 'chat-escrow' | 'mvp-prototype' | 'presentation') => {
    state.currentView = view;
  };

  // Auth Simulation
  const login = (email: string, role: 'DEMANDA' | 'OFERTA') => {
    state.user = {
      name: email.split('@')[0].toUpperCase(),
      email: email,
      phone: '+52 55 ' + Math.floor(10000000 + Math.random() * 90000000),
      role: role
    };
    state.activeMode = role;
    updateBodyClass();
    state.currentView = role === 'DEMANDA' ? 'demand-dashboard' : 'offer-dashboard';
  };

  const register = (name: string, email: string, phone: string, role: 'DEMANDA' | 'OFERTA') => {
    state.user = {
      name,
      email,
      phone,
      role
    };
    state.activeMode = role;
    updateBodyClass();
    state.currentView = role === 'DEMANDA' ? 'demand-dashboard' : 'offer-dashboard';
  };

  const logout = () => {
    state.user = null;
    state.currentView = 'welcome';
  };

  // Clients posting a job (2.2)
  const createJob = (jobData: Omit<Job, 'id' | 'status' | 'clientName' | 'bids' | 'lat' | 'lng'>) => {
    const newId = Date.now();
    const newJob: Job = {
      ...jobData,
      id: newId,
      status: 'open',
      clientName: state.user?.name || 'Cliente Prototipo',
      lat: Math.floor(10 + Math.random() * 80),
      lng: Math.floor(10 + Math.random() * 80),
      bids: []
    };
    state.jobs.unshift(newJob);
    state.isPublishingModalOpen = false;
    state.selectedJobId = newId;
  };

  // Providers bidding on a job (3.3)
  const submitBid = (jobId: number, proposal: string, bidAmount: number, estimatedArrival: string) => {
    const job = state.jobs.find(j => j.id === jobId);
    if (!job) return;

    // Get current provider profile or use a default mock
    const providerId = 1; // Mateo González
    const providerName = 'Mateo González';

    // Remove old bids from same provider if any
    job.bids = job.bids.filter(b => b.providerId !== providerId);

    job.bids.push({
      providerId,
      providerName,
      proposal,
      bidAmount,
      estimatedArrival
    });
    job.status = 'bidded';
  };

  // Clients accepting a bid (2.4) -> Initiates pending full payment with Escrow
  const acceptBid = (jobId: number, bid: Bid) => {
    const job = state.jobs.find(j => j.id === jobId);
    if (!job) return;

    job.status = 'in_progress';
    
    // Create Transaction Contract
    const contractId = Date.now();
    const newContract: Contract = {
      id: contractId,
      jobId: jobId,
      providerId: bid.providerId,
      clientName: job.clientName,
      providerName: bid.providerName,
      status: 'pending_deposit',
      agreementAmount: bid.bidAmount,
      messages: [
        {
          sender: 'provider',
          content: `¡Hola ${job.clientName}! Acepté tu propuesta para resolver "${job.title}". El costo acordado es de $${bid.bidAmount}. Realiza el pago completo por OpenPay para que el sistema me libere la información de tu domicilio y enseguida estaré ahí. Tu pago es seguro: Ofiix implementa Escrow, así que el dinero queda retenido y no se libera hasta que se completa el trabajo.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }
      ],
      reviewSubmitted: false
    };

    state.contracts.push(newContract);
    state.activeContractId = contractId;
    state.currentView = 'chat-escrow';
  };

  // Hire Direct (2.3) -> Creates Contract directly
  const hireDirect = (providerId: number, taskTitle: string, description: string, budget: number, isUrgent: boolean) => {
    const provider = state.providers.find(p => p.id === providerId);
    if (!provider) return;

    const newJobId = Date.now();
    const newJob: Job = {
      id: newJobId,
      title: taskTitle,
      category: provider.category,
      description: description,
      budget: budget,
      isUrgent: isUrgent,
      exactAddress: 'Calle Río Lerma 142, Dpto 402, Cuauhtémoc, CDMX',
      approxAddress: 'Cerca del Monumento a la Independencia, Cuauhtémoc',
      status: 'in_progress',
      clientName: state.user?.name || 'Cliente Prototipo',
      lat: provider.lat + 2,
      lng: provider.lng - 2,
      bids: []
    };

    state.jobs.unshift(newJob);

    // Create Contract
    const contractId = Date.now() + 1;
    const newContract: Contract = {
      id: contractId,
      jobId: newJobId,
      providerId: providerId,
      clientName: newJob.clientName,
      providerName: provider.name,
      status: 'pending_deposit',
      agreementAmount: budget,
      messages: [
        {
          sender: 'client',
          content: `¡Hola ${provider.name}! Te he contratado directamente para la tarea: "${taskTitle}". Detalles: ${description}. Presupuesto propuesto: $${budget}.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        },
        {
          sender: 'provider',
          content: `¡Muchísimas gracias por confiar en mí! Acepto de inmediato. Realiza el pago completo por OpenPay para que el sistema me libere los detalles de tu dirección y pueda salir en camino. No te preocupes: Ofiix implementa Escrow, por lo que tu dinero queda retenido y solo se libera cuando el trabajo se completa.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }
      ],
      reviewSubmitted: false
    };

    state.contracts.push(newContract);
    state.activeContractId = contractId;
    state.currentView = 'chat-escrow';
  };

  // Payment Processing (4.2) -> Retains full payment in Escrow
  const fundContract = (contractId: number) => {
    const contract = state.contracts.find(c => c.id === contractId);
    if (!contract) return;

    contract.status = 'funded';
    
    // Add automated messages
    contract.messages.push({
      sender: 'client',
      content: `🔒 [Pago seguro realizado] Se pagaron $${contract.agreementAmount} MXN por OpenPay. Ofiix mantiene el dinero retenido con Escrow y solo lo liberará al profesional cuando confirmes que el trabajo fue completado.`,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    });

    contract.messages.push({
      sender: 'provider',
      content: `¡Perfecto! Veo que el pago completo ya quedó retenido de forma segura con Escrow. El sistema me liberó la calle, número y mapa de tu ubicación exacta. ¡Voy en camino de inmediato! Tiempo estimado de llegada: 25 minutos.`,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    });
  };

  // Send message in Chat (4.1)
  const sendMessage = (contractId: number, sender: 'client' | 'provider', content: string, image?: string) => {
    const contract = state.contracts.find(c => c.id === contractId);
    if (!contract) return;

    contract.messages.push({
      sender,
      content,
      image,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    });

    // Auto simulated response if provider sends and client is offline, or vice-versa
    if (sender === 'client' && contract.status === 'funded') {
      setTimeout(() => {
        // Quick mock auto-reply based on message context
        let reply = 'Recibido. Estoy concentrado en el trabajo, te aviso de cualquier eventualidad.';
        if (content.toLowerCase().includes('llegar') || content.toLowerCase().includes('camino')) {
          reply = '¡Ya casi llego! Estoy a unos 5 minutos, buscando estacionamiento.';
        } else if (content.toLowerCase().includes('foto') || content.toLowerCase().includes('evidencia')) {
          reply = 'Claro, enseguida te paso fotos de cómo quedó la tubería principal reparada.';
        }
        
        contract.messages.push({
          sender: 'provider',
          content: reply,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        });
      }, 3000);
    }
  };

  // Release retained payment & complete job (4.3)
  const completeContract = (contractId: number) => {
    const contract = state.contracts.find(c => c.id === contractId);
    if (!contract) return;

    contract.status = 'completed';

    // Update job status
    const job = state.jobs.find(j => j.id === contract.jobId);
    if (job) {
      job.status = 'completed';
    }

    contract.messages.push({
      sender: 'client',
      content: `🎉 [Pago liberado] Se liberó el pago retenido de $${contract.agreementAmount} MXN al proveedor. ¡Trabajo terminado!`,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    });
  };

  // Submits review (4.3)
  const submitReview = (contractId: number, rating: number, comment: string) => {
    const contract = state.contracts.find(c => c.id === contractId);
    if (!contract) return;

    contract.reviewSubmitted = true;
    
    // Add review to the actual provider in lists
    const provider = state.providers.find(p => p.id === contract.providerId);
    if (provider) {
      provider.completedJobs += 1;
      provider.reviews.unshift({
        id: Date.now(),
        reviewer: contract.clientName,
        rating,
        comment,
        date: 'Reciente'
      });
      // Recalculate average rating
      const totalStars = provider.reviews.reduce((acc, curr) => acc + curr.rating, 0);
      provider.rating = parseFloat((totalStars / provider.reviews.length).toFixed(1));
    }

    // Return to dashboard
    state.currentView = state.activeMode === 'DEMANDA' ? 'demand-dashboard' : 'offer-dashboard';
  };

  // Provider Updates Profile (3.2)
  const updateProviderProfile = (profileData: { bio: string, category: string, pricePerHour: number }) => {
    const provider = state.providers.find(p => p.id === 1); // Mock provider is Mateo
    if (provider) {
      provider.bio = profileData.bio;
      provider.category = profileData.category;
      provider.pricePerHour = profileData.pricePerHour;
    }
  };

  // Computeds
  const activeContract = computed(() => state.contracts.find(c => c.id === state.activeContractId) || null);
  const selectedProvider = computed(() => state.providers.find(p => p.id === state.selectedProviderId) || null);
  const selectedJob = computed(() => state.jobs.find(j => j.id === state.selectedJobId) || null);
  const providerProfile = computed(() => state.providers.find(p => p.id === 1) || null); // Hardcode provider Mateo as "me" in offer mode
  
  return {
    state,
    activeContract,
    selectedProvider,
    selectedJob,
    providerProfile,
    
    // Functions
    toggleMode,
    setMode,
    navigateTo,
    login,
    register,
    logout,
    createJob,
    submitBid,
    acceptBid,
    hireDirect,
    fundContract,
    sendMessage,
    completeContract,
    submitReview,
    updateProviderProfile
  };
};
