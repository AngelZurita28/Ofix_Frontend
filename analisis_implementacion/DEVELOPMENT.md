# Analisis de implementacion y producto

## Estado actual del prototipo

La aplicacion ya comunica el flujo central:

1. Landing con selector de modo `DEMANDA` / `OFERTA`.
2. Registro/login simulado.
3. Cliente busca profesionales o publica tarea.
4. Profesional ve tareas cercanas y se postula.
5. Cliente acepta propuesta.
6. Se crea contrato con escrow pendiente.
7. Cliente fondea, se libera ubicacion exacta y se coordina por chat.
8. Se completa el trabajo y se deja resena.

Esto es suficiente como prototipo visual, pero para convertirlo en producto funcional faltan pantallas, backend, estados y modulos operativos.

## Modulos que conviene agregar

### 1. Vista detalle real de tarea

Hoy el detalle vive dentro del dashboard. Conviene una ruta propia:

- `/jobs/:id`
- Cliente: ve descripcion completa, estado, postulaciones, historial y acciones.
- Profesional: ve ubicacion aproximada, presupuesto, numero de postulantes, formulario de postulacion y restricciones.
- Admin/soporte: ve trazabilidad, reportes y flags.

Debe incluir:

- Timeline de estado.
- Conteo y lista de postulaciones.
- Datos visibles segun rol.
- Historial de cambios.
- Acciones contextuales: editar, cancelar, pausar, postular, retirar postulacion.

### 2. Perfil publico de profesional como pantalla independiente

Hoy esta embebido en el dashboard de demanda. Conviene:

- `/providers/:id`

Debe incluir:

- Bio, categorias y habilidades.
- Tarifa base y disponibilidad.
- Galeria/portafolio.
- Resenas verificadas.
- Badges y verificaciones.
- Zonas de cobertura.
- Boton de contratacion directa.
- Politicas del profesional: materiales, garantia, horarios.

### 3. Onboarding de profesional

El profesional no deberia entrar directo al tablero sin completar datos minimos.

Pantallas sugeridas:

- Datos profesionales.
- Categorias y habilidades.
- Zonas de servicio.
- Tarifa y disponibilidad.
- Documentos de verificacion.
- Portafolio inicial.
- Revision/estado de aprobacion.

Estados:

- `draft`
- `pending_verification`
- `verified`
- `rejected`
- `suspended`

### 4. Centro de contratos

Crear una vista separada:

- `/contracts`
- `/contracts/:id`

Utilidad:

- Ver tratos pendientes de deposito.
- Ver trabajos en camino/en ejecucion.
- Ver completados.
- Ver cancelados o en disputa.

Esto evita que el chat sea el unico lugar donde se entiende el estado del negocio.

### 5. Chat transaccional completo

El chat actual es correcto como demo. Para producto necesita:

- Mensajes paginados.
- Estados enviado/entregado/leido.
- Adjuntos reales.
- Evidencia marcada como "antes", "durante", "despues".
- Mensajes de sistema no editables.
- Botones de accion dentro del hilo: fondear, confirmar llegada, marcar terminado, abrir disputa.
- Moderacion y bloqueo.
- Plantillas de respuestas rapidas.

### 6. Escrow y pagos

Hace falta separar visualmente:

- Intento de pago.
- Pago confirmado por proveedor externo.
- Saldo retenido.
- Comision de plataforma.
- Liberacion al proveedor.
- Reembolso total/parcial.

Estados recomendados:

- `requires_payment`
- `processing`
- `funded`
- `release_pending`
- `released`
- `refunded`
- `disputed`

### 7. Notificaciones

Necesarias desde el primer backend:

- Nueva postulacion recibida.
- Postulacion aceptada/rechazada.
- Deposito pendiente.
- Escrow fondeado.
- Direccion liberada.
- Mensaje nuevo.
- Profesional en camino.
- Trabajo marcado como terminado.
- Resena pendiente.
- Disputa abierta.

Canales:

- In-app.
- Email.
- SMS/WhatsApp para eventos criticos, si el presupuesto lo permite.
- Push mobile en una etapa posterior.

### 8. Agenda y disponibilidad

El prototipo usa llegada estimada manual. Producto real necesita:

- Horarios de servicio.
- Dias disponibles.
- Bloqueos de agenda.
- Citas programadas.
- Urgencias inmediatas.
- Reagendamiento.

Esto puede vivir como modulo despues de validar demanda, pero el esquema ya debe dejar espacio para `scheduled_start_at`, `scheduled_end_at` y `arrival_eta_minutes`.

### 9. Disputas, cancelaciones y soporte

Imprescindible por escrow:

- Cliente cancela antes de fondear.
- Cliente cancela despues de fondear.
- Profesional cancela.
- No show.
- Trabajo incompleto.
- Danos o cobros extra.
- Evidencia insuficiente.

Debe existir:

- Vista de disputa.
- Carga de evidencia.
- Chat de soporte.
- Resolucion: liberar, reembolsar, parcial, sancionar.

### 10. Panel administrativo

No necesita estar en el primer prototipo publico, pero si en la implementacion real:

- Usuarios y profesionales.
- Verificaciones pendientes.
- Tareas activas.
- Contratos y pagos.
- Disputas.
- Reportes.
- Moderacion de resenas y archivos.
- Auditoria de ubicaciones reveladas.

## Cambios recomendados en frontend

### Rutas

Migrar de `currentView` en store a Vue Router cuando haya backend:

- `/`
- `/login`
- `/register`
- `/demand`
- `/offer`
- `/jobs/:id`
- `/providers/:id`
- `/contracts`
- `/contracts/:id`
- `/contracts/:id/chat`
- `/settings/profile`
- `/settings/provider`

### Estado cliente

Separar:

- Auth/session store.
- User/profile store.
- Jobs store.
- Providers store.
- Contracts store.
- Chat store.
- Notifications store.

Para MVP puede usarse Pinia. Para datos remotos, Vue Query/TanStack Query ayudaria a cache, loading, retry e invalidacion.

### Componentes reutilizables

Extraer:

- `ProviderCard`
- `JobCard`
- `BidCard`
- `ContractStatusStepper`
- `EscrowSummary`
- `ChatThread`
- `MessageBubble`
- `LocationPrivacyMap`
- `RatingStars`
- `MediaUploader`
- `VerificationBadge`

## Backend sugerido

Stack pragmatico:

- API REST o tRPC/NestJS/Fastify.
- PostgreSQL + PostGIS.
- Redis.
- Storage S3 compatible.
- WebSockets para chat y estados.
- Stripe/Mercado Pago/Conekta segun mercado objetivo.

### Servicios principales

- AuthService
- UserService
- ProviderService
- JobService
- BidService
- ContractService
- EscrowPaymentService
- ChatService
- NotificationService
- MediaService
- VerificationService
- ReviewService
- DisputeService
- AuditService

## Endpoints iniciales

### Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`
- `GET /me`

### Providers

- `GET /providers`
- `GET /providers/:id`
- `PATCH /providers/me`
- `POST /providers/me/categories`
- `POST /providers/me/portfolio`
- `POST /providers/me/verification`

### Jobs

- `POST /jobs`
- `GET /jobs`
- `GET /jobs/:id`
- `PATCH /jobs/:id`
- `POST /jobs/:id/cancel`

### Bids

- `POST /jobs/:id/bids`
- `PATCH /jobs/:id/bids/:bidId`
- `POST /jobs/:id/bids/:bidId/accept`

### Contracts

- `GET /contracts`
- `GET /contracts/:id`
- `POST /contracts/direct-hire`
- `POST /contracts/:id/fund`
- `POST /contracts/:id/arrival`
- `POST /contracts/:id/complete`
- `POST /contracts/:id/dispute`

### Chat

- `GET /contracts/:id/messages`
- `POST /contracts/:id/messages`
- `POST /contracts/:id/messages/:messageId/attachments`

### Reviews

- `POST /contracts/:id/reviews`
- `GET /providers/:id/reviews`

## Eventos WebSocket

- `message.created`
- `message.read`
- `typing.started`
- `typing.stopped`
- `bid.created`
- `bid.accepted`
- `contract.created`
- `contract.funded`
- `contract.location_revealed`
- `contract.completed`
- `payment.succeeded`
- `payment.failed`
- `review.created`
- `notification.created`

## Fases de implementacion

### Fase 1: Backend MVP con persistencia

Objetivo: reemplazar mocks sin cambiar demasiado la UI.

- Crear auth real.
- Crear tablas principales.
- Conectar registro/login.
- CRUD de perfil profesional.
- CRUD de tareas.
- Postulaciones.
- Contrato desde postulacion aceptada.
- Chat persistente basico.
- Resenas.

### Fase 2: Geolocalizacion y privacidad

- PostGIS.
- Busquedas por radio.
- Ubicacion aproximada.
- Reglas de revelacion de direccion.
- Auditoria de revelacion.
- Mapa real con tiles.

### Fase 3: Pagos reales y escrow operativo

- Integracion PSP.
- Webhooks.
- Ledger interno.
- Estados de pago.
- Liberacion y reembolso.
- Comisiones.

### Fase 4: Confianza y operaciones

- Verificacion de identidad.
- Panel admin.
- Disputas.
- Reportes.
- Moderacion.
- Notificaciones multicanal.

### Fase 5: Calidad de marketplace

- Ranking de profesionales.
- Busqueda avanzada.
- Agenda.
- Recomendaciones.
- Metricas de conversion.
- Experimentos de precios/comisiones.

## Riesgos y decisiones pendientes

- **Escrow legal**: retener dinero puede tener implicaciones regulatorias. Conviene validar con proveedor de pagos y asesoria legal antes de construir demasiado.
- **Seguridad fisica**: revelar ubicacion exacta requiere verificacion, auditoria y soporte.
- **Responsabilidad de trabajos**: definir terminos, garantias, seguros, cancelaciones y evidencia obligatoria.
- **Fraude y colusion**: postulaciones, resenas y pagos requieren deteccion de abuso.
- **Privacidad**: documentos de identidad y direcciones deben tratarse como datos sensibles.

## MVP funcional recomendado

Para una primera version real, limitar el alcance a:

- Una ciudad o zona.
- Tres categorias: Fontaneria, Electricidad, Carpinteria.
- Registro, perfil profesional y verificacion manual.
- Publicacion de tareas.
- Postulaciones.
- Contrato con pago retenido.
- Chat con fotos.
- Reseña final.
- Panel admin minimo para verificaciones y disputas.

Esto conserva la promesa central del prototipo sin abrir demasiadas superficies operativas al mismo tiempo.

