# Analisis de base de datos para Ofiix

## Resumen ejecutivo

El prototipo simula un marketplace local de servicios con dos roles principales:

- **Demanda**: usuarios que publican tareas o contratan profesionales directamente.
- **Oferta**: profesionales que configuran perfil, buscan tareas cercanas y se postulan.

La app necesita modelar identidad, perfiles, oficios, ubicaciones con privacidad progresiva, tareas, postulaciones, contratos, escrow, chat, evidencia multimedia, reseñas, notificaciones y auditoria de estados.

La recomendacion principal es usar **PostgreSQL + PostGIS** como base transaccional y geoespacial unica. No conviene separar la fuente de verdad entre SQL y NoSQL al inicio porque los datos tienen muchas relaciones, estados financieros y reglas de integridad. Como complemento operativo, si el producto crece, se recomienda:

- **Redis** para presencia, sockets, locks cortos, rate limits, sesiones y eventos efimeros de chat.
- **Object Storage** tipo S3/R2/GCS para fotos de perfil, portafolio, evidencias e identificaciones.
- **Motor de busqueda** opcional como Meilisearch/OpenSearch cuando el directorio requiera ranking avanzado, sinonimos, autocompletado y busqueda por texto con alta escala.

## Lo que existe hoy en el prototipo

El store actual define estos objetos:

- `User`: nombre, email, telefono y rol activo.
- `Provider`: profesional con categoria, rating, trabajos completados, badges, bio, tarifa, imagen, portafolio, estado, tiempo de respuesta, reseñas y coordenadas.
- `Job`: tarea con titulo, categoria, descripcion, presupuesto, urgencia, direccion exacta, zona aproximada, estado, cliente, coordenadas y postulaciones.
- `Bid`: postulacion de proveedor con propuesta, monto y llegada estimada.
- `Contract`: contrato entre cliente y proveedor asociado a una tarea, estado de escrow, monto, mensajes y reseña.
- `Message`: mensaje de chat con sender, contenido, timestamp e imagen opcional.
- `Review`: calificacion, comentario, fecha y autor.

Eso cubre bien el prototipo visual, pero para producto real faltan varias capas: cuentas multirol, verificacion, direcciones normalizadas, geolocalizacion real, estados auditables, pagos reales, archivos, permisos por participante, denuncias, cancelaciones y trazabilidad.

## Arquitectura de datos recomendada

### PostgreSQL + PostGIS como fuente de verdad

Debe guardar:

- Usuarios, sesiones logicas y roles.
- Perfiles de cliente y profesional.
- Categorias/oficios y habilidades.
- Direcciones, zonas aproximadas y puntos geograficos.
- Tareas, postulaciones, contrataciones directas y contratos.
- Estados de escrow, pagos, comisiones y liberaciones.
- Mensajes persistentes, adjuntos y evidencias.
- Reseñas, badges, verificacion, reportes y auditoria.

PostGIS es importante porque el producto depende de:

- Buscar profesionales cerca de un cliente.
- Buscar tareas cerca de un profesional.
- Mostrar ubicacion aproximada antes de fondear escrow.
- Liberar direccion exacta solo al contrato fondeado.
- Calcular distancia real y ordenar por cercania.

### Redis como complemento, no como base principal

Redis conviene para datos que no deben ser la fuente final:

- Presencia online/offline de profesionales.
- Ultima actividad de chat y typing indicators.
- Canales WebSocket por contrato.
- Rate limits de mensajes, postulaciones y login.
- Locks de aceptacion de postulacion para evitar doble contratacion.
- Cola ligera de notificaciones si no se usa un broker dedicado.

### Object Storage

Los binarios no deben vivir en la base SQL. La base solo guarda metadatos:

- URL privada o key del archivo.
- Tipo, tamano, checksum, propietario.
- Relacion con perfil, portafolio, mensaje, evidencia, verificacion o disputa.
- Estado de revision/moderacion.

## Entidades principales

### Identidad y usuarios

**users**

Representa una cuenta de acceso. Un usuario puede actuar como cliente, profesional o ambos. El `activeMode` del frontend no debe ser el rol permanente; debe ser una preferencia de UI o una sesion actual.

Campos clave:

- `id`
- `email`
- `phone`
- `full_name`
- `password_hash`
- `status`: active, suspended, deleted
- `default_mode`: DEMANDA u OFERTA
- `created_at`, `updated_at`

**user_roles**

Permite que una cuenta tenga capacidades separadas: client, provider, admin, support. Evita duplicar cuentas cuando alguien contrata y tambien ofrece servicios.

**client_profiles**

Datos de cliente que no pertenecen a autenticacion: nombre publico, foto, preferencias, conteo de trabajos, rating como contratante si se decide calificar tambien al cliente.

**provider_profiles**

Perfil profesional visible: bio, tarifa base, estado de disponibilidad, tiempo promedio de respuesta, rating agregado, trabajos completados, verificacion, zona base y ubicacion operativa.

### Categorias y habilidades

**categories**

Catalogo jerarquico: Fontaneria, Electricidad, Carpinteria, etc. Puede tener `parent_id` para subcategorias.

**provider_categories**

Relacion N:N entre profesionales y categorias. El prototipo solo soporta una categoria por proveedor, pero producto real necesita varias especialidades.

**skills**
**provider_skills**

Opcional para granularidad: "deteccion de fugas", "tableros electricos", "muebles a medida".

### Ubicaciones y privacidad

**addresses**

Guarda direcciones exactas privadas, normalizadas y relacionadas con el usuario o una tarea.

**locations**

Tabla reutilizable para puntos geograficos. Para tareas debe guardar:

- `exact_point`: coordenada real, privada.
- `approx_point`: centro aproximado visible antes del acuerdo.
- `approx_radius_m`: radio de privacidad.
- `public_label`: colonia/zona visible.

Regla de negocio: antes de que el contrato este `funded`, proveedores solo ven `public_label`, `approx_point` y `approx_radius_m`. La direccion exacta solo se revela a participantes del contrato fondeado.

### Tareas y postulaciones

**jobs**

Necesidad publicada por cliente o creada por contratacion directa. Estados recomendados:

- `draft`
- `open`
- `bidded`
- `assigned`
- `in_progress`
- `completed`
- `cancelled`
- `expired`
- `disputed`

Campos clave:

- cliente
- categoria
- titulo
- descripcion
- presupuesto estimado
- urgencia
- ubicacion
- estado
- fuente: public_post o direct_hire

**job_bids**

Postulaciones de profesionales. Estados recomendados:

- `submitted`
- `withdrawn`
- `rejected`
- `accepted`
- `expired`

Debe tener una restriccion unica por `job_id + provider_id` para evitar postulaciones duplicadas activas.

### Contratos, escrow y pagos

**contracts**

Acuerdo formal entre cliente y profesional. Puede originarse desde una postulacion aceptada o desde contratacion directa.

Estados recomendados:

- `pending_deposit`
- `funded`
- `provider_en_route`
- `arrived`
- `work_started`
- `work_submitted`
- `completed`
- `cancelled`
- `disputed`

El prototipo salta de `funded` a `completed`, pero producto real necesita estados intermedios para llegada, ejecucion, evidencia, cancelacion y disputa.

**escrow_accounts**

Registro logico del saldo retenido por contrato. No sustituye al PSP; guarda la verdad de negocio interna.

**payments**

Intentos de pago y cobros del cliente, enlazados a Stripe/Mercado Pago/Conekta/etc.

**payouts**

Liberaciones al profesional cuando el contrato se completa.

**ledger_entries**

Libro contable interno inmutable. Recomendado para auditar:

- cobro al cliente
- comision de plataforma
- impuestos si aplican
- saldo escrow
- liberacion al proveedor
- reembolsos

### Chat, evidencias y archivos

**conversation_threads**

Un contrato debe tener un hilo principal de chat. Tambien puede haber hilos de soporte/disputa.

**messages**

Mensajes persistentes con emisor, tipo, texto, estado y timestamps.

Tipos:

- `text`
- `image`
- `system`
- `payment_event`
- `location_event`
- `review_event`

**message_attachments**

Relaciona mensajes con archivos.

**media_assets**

Metadatos de fotos, videos, documentos de identidad, evidencias y portafolio.

### Reputacion, confianza y seguridad

**reviews**

Debe enlazarse al contrato para impedir reseñas falsas. Puede soportar rating de cliente a proveedor y de proveedor a cliente.

**badges**
**provider_badges**

Insignias como Identidad Verificada, Puntual, Super Pro, Certificada.

**verification_requests**

Carga y revision de INE, comprobante, certificaciones o documentos profesionales.

**reports**
**disputes**

Reportes y disputas para casos de incumplimiento, fraude, mala conducta o evidencia insuficiente.

**audit_log**

Eventos criticos: cambios de estado, revelacion de direccion exacta, pago fondeado, liberacion, cancelacion, bloqueo de cuenta.

## Relaciones clave

- `users` 1:N `user_roles`
- `users` 1:1 `client_profiles`
- `users` 1:1 `provider_profiles`
- `provider_profiles` N:N `categories`
- `jobs` N:1 `client_profiles`
- `jobs` N:1 `categories`
- `jobs` 1:1 `locations`
- `jobs` 1:N `job_bids`
- `job_bids` N:1 `provider_profiles`
- `contracts` N:1 `jobs`
- `contracts` N:1 `client_profiles`
- `contracts` N:1 `provider_profiles`
- `contracts` 1:1 `escrow_accounts`
- `contracts` 1:N `payments`
- `contracts` 1:N `payouts`
- `contracts` 1:1 o 1:N `conversation_threads`
- `conversation_threads` 1:N `messages`
- `messages` 1:N `message_attachments`
- `contracts` 1:N `reviews`

## Reglas de integridad importantes

1. Una tarea `open` puede recibir muchas postulaciones.
2. Una tarea solo puede tener una postulacion `accepted`.
3. Aceptar postulacion debe crear contrato y mover tarea a `assigned` o `in_progress`.
4. Un contrato no puede pasar a `funded` sin pago confirmado por PSP.
5. Direccion exacta se revela solo si:
   - el usuario es cliente propietario, o
   - el usuario es proveedor asignado, y
   - el contrato esta `funded` o posterior.
6. Solo participantes del contrato pueden leer/escribir en su chat.
7. Reseña solo puede crearse cuando contrato esta `completed`.
8. Archivos de identidad son privados y visibles solo para admin/verificacion.
9. Eventos financieros deben registrarse en ledger inmutable.
10. Estados criticos deben escribirse tambien en `audit_log`.

## Indices recomendados

- `users.email` unico.
- `users.phone` unico opcional, normalizado E.164.
- `jobs.status`, `jobs.category_id`, `jobs.created_at`.
- `jobs.location_id` y `locations.approx_point` con GIST.
- `provider_profiles.current_point` con GIST.
- `job_bids(job_id, provider_id)` unico.
- `contracts(client_id, status)`.
- `contracts(provider_id, status)`.
- `messages(thread_id, created_at)`.
- `reviews(reviewee_user_id, created_at)`.
- Busqueda textual con `tsvector` en perfiles y tareas al inicio; motor externo despues.

## Vistas o queries que la app necesitara

### Directorio de profesionales

Consulta profesionales activos por categoria, rating minimo y distancia desde el cliente. Orden probable:

1. Disponibilidad online.
2. Distancia.
3. Rating.
4. Tiempo de respuesta.
5. Trabajos completados.

### Tablero de tareas para profesionales

Consulta tareas `open` o `bidded` cerca del profesional, mostrando solo ubicacion aproximada.

### Mis tareas publicadas

Consulta tareas del cliente con conteo de postulaciones y estado contractual.

### Tratos en curso

Consulta contratos activos por usuario, separando `pending_deposit`, `funded`, `in_progress` y `disputed`.

### Chat del contrato

Mensajes paginados por `thread_id`, con adjuntos y eventos de sistema.

## Seguridad y privacidad

- Guardar coordenadas exactas separadas de coordenadas aproximadas.
- Aplicar autorizacion por filas desde backend. Si se usa Supabase/Postgres RLS, definir policies por participante.
- No enviar direccion exacta al frontend antes del estado `funded`.
- No exponer telefono real antes del acuerdo; usar relay o numero enmascarado si es posible.
- Cifrar o proteger documentos de identidad con storage privado, URLs firmadas y expiracion corta.
- Registrar `location_revealed` en auditoria.
- Rate limit para chat, postulaciones, login y creacion de tareas.

## Archivos de estructura incluidos

Se incluye [schema_postgres.sql](/home/zurita/dev/Ofix_Frontend/analisis_implementacion/schema_postgres.sql) como propuesta inicial para PostgreSQL + PostGIS. El esquema prioriza integridad, estados explicitos y consultas geoespaciales.

