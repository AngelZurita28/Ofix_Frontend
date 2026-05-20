# Checklist de Desarrollo - Ofix (Terra) Prototipe Frontend

Este checklist registra el avance del prototipo interactivo para **Ofix (Terra)**, implementado en Vue 3 + TypeScript. Los estados son:
- `[ ]` Pendiente
- `[/]` En Desarrollo
- `[x]` Completado

---

## 🛠️ Progreso General por Módulos

### MÓDULO 1: Flujo de Acceso e Inicio (Gateway)
- [x] **1.1 Pantalla de Bienvenida / Portal de Entrada (Landing Page)**
  - [x] Switch global dinámico de Modo (`DEMANDA` / `OFERTA`) con transiciones estéticas.
  - [x] Sección informativa cambiante según el modo activo.
  - [x] Acceso/Enlaces para registro y login.
- [x] **1.2 Pantalla de Autenticación y Registro Dual**
  - [x] Formulario de acceso/registro con validaciones básicas de campos (nombre, correo, contraseña, teléfono).
  - [x] Selector de rol inicial (`Contratar` / `Ofrecer`).
  - [x] Mock de flujo de login y registro.

### MÓDULO 2: Modo Demanda (Consumidor de Servicios)
- [x] **2.1 Tablón de Necesidades / Directorio de Proveedores**
  - [x] Buscador de proveedores por nombre/categoría.
  - [x] Filtros interactivos (distancia, calificación, categoría técnica).
  - [x] Selector de Vista (Lista / Mapa).
  - [x] Mapa simulado con pines interactivos de proveedores.
  - [x] Lista con tarjetas premium de proveedores (badges de confianza, calificación).
- [x] **2.2 Formulario de Publicación de Tarea**
  - [x] Formulario funcional de publicación de tarea (título, descripción, presupuesto, urgencia, dirección exacta, dirección pública).
  - [x] Simulación de geolocalización aproximada (`geom_approx`).
- [x] **2.3 Perfil Público del Proveedor (Visto por el Cliente)**
  - [x] Información detallada (nombre, foto, verificación, tiempo de respuesta).
  - [x] Galería multimedia (carrusel de trabajos completados).
  - [x] Lista de reseñas históricas reales/dummy.
  - [x] Modal o formulario de contratación directa.
- [x] **2.4 Vista Detallada de Tarea Propia y Postulaciones**
  - [x] Vista del estado del trabajo publicado.
  - [x] Módulo con postulantes recibidos, contrapropuestas económicas y detalles.
  - [x] Botón de "Aceptar Propuesta" con redirección al flujo de pago.

### MÓDULO 3: Modo Oferta (Proveedor de Servicios)
- [x] **3.1 Panel del Proveedor y Tablón de Tareas Locales**
  - [x] Mapa de tareas cercanas con círculos aproximados de privacidad (1.5 km).
  - [x] Filtros de búsqueda (categoría, urgencia, presupuesto mínimo, distancia).
  - [x] Listado de tareas locales publicadas por clientes.
- [x] **3.2 Edición de Perfil de Proveedor (Configuración)**
  - [x] Formulario de configuración (categorías, biografía, tarifa promedio, fotos de portafolio).
  - [x] Espacio seguro de carga de identificación oficial.
- [x] **3.3 Detalle de Tarea Ajena y Formulario de Postulación**
  - [x] Vista completa de requerimientos y mapa de zona de referencia.
  - [x] Formulario para texto de propuesta y contrapropuesta económica.
  - [x] Registro en tiempo real de postulación a la tarea.

### MÓDULO 4: Flujos Transaccionales Compartidos (Sincronización)
- [x] **4.1 Chat Seguro y Hub de Interacción Activa**
  - [x] Chat funcional de mensajería (mensajes de texto y simulación de envío de imágenes de evidencia).
  - [x] Widget de Estado del Contrato (Escrow Widget):
    - [x] `pending_deposit`: Instrucciones de fondeo/espera.
    - [x] `funded`: Liberación automática de dirección exacta, teléfono y mapa de ruta del proveedor.
    - [x] `completed`: Deshabilitar inputs de chat y habilitar cierre.
- [x] **4.2 Módulo de Pago y Garantía (Escrow)**
  - [x] Desglose de cotización y comisión de garantía.
  - [x] Formulario interactivo simulado de pasarela de pago (Stripe Mock).
  - [x] Cambio de estado del contrato a `funded` con feedback estético.
- [x] **4.3 Pantalla de Reseña y Calificación (Post-Servicio)**
  - [x] Selector interactivo de estrellas (1 a 5).
  - [x] Textarea para reseñas de comportamiento y calidad.
  - [x] Cierre definitivo del flujo y retorno al panel de modo activo.

---

## 🎨 Integración del Sistema de Diseño ("Glassmorphism & Terraria")
- [x] Tipografías estilizadas (`Outfit` & `Inter`) cargadas desde Google Fonts.
- [x] Estilos globales con paleta orgánica dual (Arena base, Sunset Orange, Verde Terraria, Obsidian Ceramic, Sage Wash).
- [x] Estructura de elevación y blur de cristal (`backdrop-blur-md` y bordes de cristal brillante).
- [x] Transiciones fluidas, hovers animados y micro-animaciones premium.
