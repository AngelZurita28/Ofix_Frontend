# Especificación Funcional de Flujos y Pantallas: "Terra"

Este documento contiene la definición estructural de las pantallas, la arquitectura de información y la lógica de navegación de la plataforma Terra. Está diseñado para ser neutral en cuanto a diseño visual (sin directrices de color, tipografía o maquetación física) para que los equipos de UI/UX y Desarrollo de Software construyan la interfaz libre de sesgos estéticos.

## MÓDULO 1: Flujo de Acceso e Inicio (Gateway)

### 1.1 Pantalla de Bienvenida / Portal de Entrada (Landing Page)

- **Objetivo:** Informar al usuario sobre los dos modos de operación del sistema, educar sobre el sistema de seguridad/pagos y permitir el acceso.
    
- **Componentes Funcionales Obligatorios:**
    
    - **Selector de Estado Global (Switch):** Control bidireccional que conmuta el estado `USER_MODE` entre `'DEMANDA'` y `'OFERTA'`. Al alternarse, actualiza de forma reactiva el contenido dinámico del resto de la pantalla.
        
    - **Sección Informativa Dinámica (Demanda activa):** Explica los pasos para publicar tareas, geolocalización difusa y recibir ofertas.
        
    - **Sección Informativa Dinámica (Oferta activa):** Explica los pasos para ofrecer servicios, construir reputación y cotizar.
        
    - **Acceso a Registro/Login:** Enlace o control de acción hacia la autenticación.
        
- **Redirecciones:**
    
    - Al interactuar con el registro/login -> Dirige a **Pantalla de Autenticación (1.2)**.
        
    - Al conmutar el selector -> Cambia la configuración del contenido informativo de manera instantánea.
        

### 1.2 Pantalla de Autenticación y Registro Dual

- **Objetivo:** Validar identidad o crear una cuenta nueva recolectando las preferencias del usuario.
    
- **Componentes Funcionales Obligatorios:**
    
    - **Formulario de Registro/Acceso:**
        
        - Nombre Completo (Validación de texto sin caracteres especiales).
            
        - Correo Electrónico (Validación de formato RFC/estándar).
            
        - Contraseña (Validación de fortaleza mínima).
            
        - Teléfono de contacto (Código de país + 10 dígitos).
            
    - **Selector de Rol Inicial:** El usuario debe indicar si su intención inmediata de ingreso es contratar (Demanda) u ofrecer (Oferta).
        
- **Redirecciones:**
    
    - Registro exitoso en Modo Demanda -> Redirige a **Tablón de Necesidades (2.1)**.
        
    - Registro exitoso en Modo Oferta -> Redirige a **Configuración de Perfil de Proveedor (3.1)**.
        

## MÓDULO 2: Modo Demanda (Consumidor de Servicios)

Este flujo se activa cuando `USER_MODE = 'DEMANDA'`. El objetivo del usuario es encontrar un proveedor local para resolver un problema específico.

```
+-------------------------------------------------------------------------+
|                              MODO DEMANDA                               |
+-------------------------------------------------------------------------+
       |                                                   |
       v                                                   v
 [2.1 Tablón de Necesidades]                      [2.2 Formulario de Tarea]
 (Búsqueda de Proveedores/Mapa)                   (Campos de publicación)
       |                                                   |
       v                                                   |
 [2.3 Perfil Público del Proveedor] <----------------------+
 (Historial, reseñas, contratar)
```

### 2.1 Tablón de Necesidades / Directorio de Proveedores

- **Objetivo:** Mostrar los profesionales disponibles en la zona e iniciar búsquedas filtradas.
    
- **Componentes Funcionales Obligatorios:**
    
    - **Buscador:** Barra de texto libre indexada a las categorías y nombres de los proveedores.
        
    - **Filtros Activos:** Selector de distancia máxima (radio en km), calificación mínima (estrellas) y categoría técnica.
        
    - **Selector de Vista:** Alternador entre vista de listado o vista de mapa.
        
    - **Componente de Mapa (Vista Mapa):** Muestra pines de ubicación en tiempo real de proveedores disponibles en base a su última coordenada registrada.
        
    - **Componente de Lista (Vista Lista):** Despliega tarjetas de perfil con:
        
        - Nombre del proveedor.
            
        - Categoría principal.
            
        - Calificación promedio e historial de trabajos completados.
            
        - Badges o insignias de confianza asignadas por el sistema (ej. Identidad Verificada, Puntual, etc.).
            
    - **Control de Acción para Publicar:** Acceso rápido para crear una necesidad propia.
        
- **Redirecciones:**
    
    - Selección de una tarjeta de proveedor o pin de mapa -> Abre **Perfil Público del Proveedor (2.3)**.
        
    - Acción de publicar -> Abre **Formulario de Publicación de Tarea (2.2)**.
        

### 2.2 Formulario de Publicación de Tarea

- **Objetivo:** Recolectar la información detallada del trabajo requerido para exponerlo al tablón de oferta.
    
- **Campos del Formulario:**
    
    - **Título del Trabajo:** Breve, descriptivo (Máximo 150 caracteres).
        
    - **Categoría:** Menú de selección única asociado a la tabla de `categories`.
        
    - **Descripción Detallada:** Campo de texto libre para detallar el problema.
        
    - **Presupuesto Estimado:** Entrada numérica (opcional, para transparentar expectativas).
        
    - **Indicador de Urgencia:** Control booleano (Urgente / No urgente).
        
    - **Selector de Ubicación:**
        
        - Entrada de texto para Dirección Exacta (Para uso exclusivo interno del sistema).
            
        - Entrada de texto para Nombre de Zona/Aproximada (Visible al público).
            
        - Captura de coordenada GPS por geolocalización de navegador.
            
- **Lógica del Sistema:** Al enviar el formulario, el backend calcula automáticamente el círculo aproximado (`geom_approx`) y deja oculta la dirección real (`location_exact_address`).
    
- **Redirecciones:**
    
    - Al enviar con éxito -> Redirige a **Vista Detallada de Tarea Propia (2.4)**.
        

### 2.3 Perfil Público del Proveedor (Visto por el Cliente)

- **Objetivo:** Evaluar la idoneidad de un profesional y solicitar su contratación directa.
    
- **Información Requerida en Pantalla:**
    
    - **Datos Generales:** Nombre, fotografía de perfil, estado de verificación de identidad, tiempo promedio de respuesta.
        
    - **Biografía/Presentación:** Texto descriptivo redactado por el proveedor.
        
    - **Galería Multimedia:** Carrusel de imágenes/videos que documentan trabajos completados previamente.
        
    - **Módulo de Reseñas:** Lista histórica de calificaciones con nombre del evaluador, estrellas asignadas, comentario y fecha.
        
- **Controles de Acción:**
    
    - **Contratación Directa:** Abre un cuadro de diálogo para definir la tarea específica a ofrecerle, incluyendo fecha límite y propuesta económica.
        
- **Redirecciones:**
    
    - Al iniciar la contratación directa y aceptar la oferta inicial -> Envía al usuario al **Módulo de Pago en Escrow (4.2)** y crea el canal en el **Chat Seguro (4.1)**.
        

### 2.4 Vista Detallada de Tarea Propia y Postulaciones Recibidas

- **Objetivo:** Permitir al cliente revisar el progreso de su publicación y las propuestas de proveedores interesados.
    
- **Información Requerida en Pantalla:**
    
    - Detalles del trabajo publicado (Título, estado actual, descripción, presupuesto).
        
    - **Módulo de Postulantes:** Listado de propuestas enviadas por proveedores que incluye:
        
        - Nombre del proveedor y enlace a su perfil.
            
        - Texto explicativo de su propuesta o candidatura.
            
        - Monto económico solicitado (Bid amount).
            
- **Controles de Acción:**
    
    - **Aceptar Propuesta:** Inicia el flujo de contratación con el proveedor seleccionado.
        
- **Redirecciones:**
    
    - Al dar clic en "Aceptar Propuesta" -> Envía al **Módulo de Pago en Escrow (4.2)** para fondeo de garantía.
        

## MÓDULO 3: Modo Oferta (Proveedor de Servicios)

Este flujo se activa cuando `USER_MODE = 'OFERTA'`. El objetivo del usuario es encontrar tareas publicadas por clientes en su zona o gestionar su perfil profesional.

```
+-------------------------------------------------------------------------+
|                               MODO OFERTA                               |
+-------------------------------------------------------------------------+
       |                                                   |
       v                                                   v
 [3.1 Panel del Proveedor / Tablón]              [3.2 Edición de Perfil]
 (Lista de tareas locales en mapa)               (Portafolio, categorías)
       |                                                   |
       v                                                   |
 [3.3 Detalle de Tarea Ajena] <----------------------------+
 (Ubicación aproximada, postularse)
```

### 3.1 Panel del Proveedor y Tablón de Tareas Locales

- **Objetivo:** Mostrar los trabajos activos publicados por clientes en la región geográfica del proveedor.
    
- **Componentes Funcionales Obligatorios:**
    
    - **Mapa de Tareas Cercanas:** Despliega círculos de exclusión (radios aproximados de 1.5 km) que protegen la privacidad de los clientes que tienen tareas abiertas.
        
    - **Filtros de Tareas:** Filtrar por categoría, presupuesto mínimo, distancia y tareas marcadas como "Urgentes".
        
    - **Listado de Tareas Activas:** Tarjetas informativas que muestran:
        
        - Título y descripción recortada del problema.
            
        - Distancia estimada al centro del círculo aproximado.
            
        - Presupuesto ofrecido e indicador de urgencia.
            
- **Redirecciones:**
    
    - Seleccionar una tarea -> Redirige a **Detalle de Tarea Ajena (3.3)**.
        

### 3.2 Edición del Perfil de Proveedor (Configuración)

- **Objetivo:** Configurar las herramientas comerciales para destacar en el directorio.
    
- **Campos del Formulario:**
    
    - **Selección de Categoría de Trabajo:** Catálogo de oficios soportados.
        
    - **Texto de Biografía:** Presentación comercial de servicios.
        
    - **Tarifa Promedio:** Indicador numérico de costo de referencia por hora o servicio estándar.
        
    - **Gestor de Portafolio:** Cargador de archivos multimedia (Fotos y videos cortos con peso controlado).
        
    - **Documentos de Identidad (Privado para el Admin):** Espacio para subir identificaciones oficiales para la verificación de identidad.
        
- **Redirecciones:**
    
    - Guardado exitoso -> Redirige al **Panel del Proveedor (3.1)**.
        

### 3.3 Detalle de Tarea Ajena y Formulario de Postulación

- **Objetivo:** Evaluar a fondo los requisitos de una tarea y presentar una postulación económica/técnica.
    
- **Información Requerida en Pantalla:**
    
    - Título, descripción extendida del problema, presupuesto inicial del cliente, fecha de creación.
        
    - Mapa centrado en la coordenada difuminada (Sector o colonia de referencia).
        
    - Contador de otros proveedores ya postulados a esta tarea.
        
- **Componentes Funcionales Obligatorios (Formulario de Postulación):**
    
    - **Texto de Propuesta:** Espacio para describir cómo planea solucionar el problema y tiempo estimado de llegada.
        
    - **Contrapropuesta Económica:** Campo numérico donde el proveedor puede aceptar el presupuesto del cliente o proponer un monto diferente.
        
- **Redirecciones:**
    
    - Al enviar la postulación con éxito -> Regresa al **Tablón de Tareas Locales (3.1)** con estado actualizado.
        

## MÓDULO 4: Flujos Transaccionales Compartidos (Sincronización)

Estos flujos unen a ambos usuarios y son independientes del estado actual del Switch de interfaz, requiriendo validación de estados y protección de datos.

```
[Cliente acepta oferta/proveedor] -> [4.2 Fondeo de Escrow (Pago)]
                                                |
                                                v
                                  [4.1 Chat Seguro Activo] 
                                  (Dirección liberada en UI,
                                   intercambio de mensajes)
                                                |
                                                v
                                  [Cliente confirma fin]
                                                |
                                                v
                                  [4.3 Reseña y Calificación]
```

### 4.1 Chat Seguro y Hub de Interacción Activa

- **Objetivo:** Coordinar la ejecución del servicio, compartir actualizaciones en tiempo real y guiar el flujo financiero del contrato.
    
- **Componentes Funcionales Obligatorios:**
    
    - **Línea de Mensajes en Tiempo Real:** Flujo de textos y archivos multimedia (fotografías de evidencias).
        
    - **Módulo de Estado del Contrato (Escrow Widget):** Barra interactiva fija que indica el estado del trato para ambos participantes de forma transparente:
        
        - _Estado 'pending_deposit':_ Avisa al proveedor que no acuda al lugar hasta que el cliente realice el depósito. Avisa al cliente que debe fondear.
            
        - _Estado 'funded':_ **Se revela automáticamente en la interfaz la calle, número y geolocalización exacta del cliente.** Se activa un botón para que el proveedor indique "Ya llegué" y "Trabajo completado".
            
        - _Estado 'completed':_ Se deshabilitan los campos de texto del chat y se muestra el botón de calificación.
            
- **Redirecciones:**
    
    - Al detectarse la liberación de fondos -> Se habilita la **Pantalla de Reseña y Calificación (4.3)** de forma automática.
        

### 4.2 Módulo de Pago y Garantía (Escrow)

- **Objetivo:** Recolectar de forma segura el dinero del cliente y notificar al sistema la reserva de los fondos.
    
- **Componentes Funcionales Obligatorios:**
    
    - Desglose del costo del servicio acordado.
        
    - Formulario seguro para captura de métodos de pago (Pasarela externa tipo Stripe).
        
    - Mensaje claro sobre la política de protección: "El dinero se mantendrá seguro por Terra y solo se entregará al proveedor una vez que confirmes la entrega satisfactoria del trabajo".
        
- **Redirecciones:**
    
    - Al procesar con éxito -> Cambia el estado del contrato a `funded`, actualiza la base de datos y redirige al **Chat Seguro (4.1)** con el evento de "Dirección Liberada".
        

### 4.3 Pantalla de Reseña y Calificación (Post-Servicio)

- **Objetivo:** Alimentar el sistema de reputación para mitigar riesgos en la comunidad.
    
- **Campos del Formulario:**
    
    - **Selector de Calificación:** De 1 a 5 estrellas (Obligatorio).
        
    - **Comentarios Escritos:** Texto libre para describir el comportamiento, puntualidad y limpieza del trabajo o trato.
        
- **Redirecciones:**
    
    - Al enviar la reseña -> El contrato se cierra definitivamente. Redirige al panel correspondiente al modo activo (`USER_MODE`).