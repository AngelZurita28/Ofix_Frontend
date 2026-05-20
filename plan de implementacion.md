
# Plan de Implementación: Prototipo Frontend Ofix (Terra)

Este plan detalla el desarrollo del prototipo frontend para **Ofix (Terra)** en Vue 3 con TypeScript. La aplicación será sumamente interactiva, permitiendo simular el flujo completo: desde registrarse, publicar un trabajo, ofertar como proveedor, pagar en garantía (Escrow) y chatear con geolocalización liberada.

## Estética y Diseño Premium (Glassmorphism & Terraria)

Implementaremos los requisitos visuales de [DESIGN.md](file:///home/zurita/dev/Ofix_frontend/DESIGN.md):
- **Tipografía**: Importación de `Outfit` y `Inter` de Google Fonts.
- **Fondo Arena**: `#F3ECE5` con orbes de luz difusa interactivos en el fondo (Naranja Atardecer `#FF8235` y Verde Terraria `#3B6043`) que se mueven de acuerdo con el cursor o de forma animada suave.
- **Vidrio Esmerilado**: Paneles con `backdrop-blur(16px)`, bordes blancos brillantes `rgba(255, 255, 255, 0.6)` y sombras difusas.
- **Píldoras y Botones Premium**: Botones tipo cápsula en **Negro Humus** con círculo indicador interactivo que se ilumina con transiciones de color orgánicas.
- **Selector de Modo Suspendido**: Toggle central interactivo que desliza estéticamente y cambia la paleta de la aplicación instantáneamente de Modo Demanda a Modo Oferta.

## Lógica y Arquitectura (KISS & Clean Code)

1. **Estado Central Reactivo (`src/store/index.ts`)**:
   - Administra el estado global de la aplicación (Usuario activo, Modo activo `'DEMANDA'` | `'OFERTA'`).
   - Datos simulados autogenerados (Proveedores locales, Tareas activas).
   - Acciones reactivas directas para interactuar entre ambos roles (Client <-> Provider). ¡Esto permite probar la app en vivo simulando ambas partes en una misma ventana!
2. **Enrutamiento Simplificado Reactivo (`src/store/router.ts` o directiva en `store`)**:
   - Navegación instantánea mediante transiciones fluidas.
   - Rutas principales: `welcome`, `auth`, `demand-dashboard`, `offer-dashboard`, `chat-escrow`.
3. **Componentes y Vistas**:
   - `App.vue`: Estructura base, orbes ambientales, selector de modo global y footer flotante interactivo.
   - `WelcomeView.vue`: Landing Page interactiva según el modo seleccionado.
   - `AuthView.vue`: Registro y Login dual.
   - `DemandDashboard.vue`: Directorio de proveedores, mapas interactivos (con Canvas o SVG interactivo para simulación táctil y limpia sin dependencias externas pesadas), formulario de tarea y detalle de postulaciones.
   - `OfferDashboard.vue`: Tablón de tareas de proveedores, edición de perfil y formulario de postulación.
   - `ChatEscrowView.vue`: Chat interactivo con widget de contrato (Escrow), simulación de pasarela de pago Stripe, y modal de calificación post-servicio.

---

## Proposed Changes

### 1. Configuración de Estilo y Tipografía
#### [MODIFY] [index.html](file:///home/zurita/dev/Ofix_frontend/index.html)
- Importar tipografías `Outfit` y `Inter` desde Google Fonts.
- Actualizar el título de la página.

#### [MODIFY] [style.css](file:///home/zurita/dev/Ofix_frontend/src/style.css)
- Implementar el sistema de diseño completo: colores base (`#F3ECE5`), modo Demanda (`#FF8235`) y modo Oferta (`#3B6043`, `#181B19`, etc.).
- Definir clases globales de utilidad para glassmorphism, botones premium de río, y orbes de iluminación.

### 2. Estado Global Reactivo (Mocking Interactivo)
#### [NEW] [src/store/index.ts](file:///home/zurita/dev/Ofix_frontend/src/store/index.ts)
- Definir tipos de TypeScript para la seguridad del código (`Provider`, `Job`, `Bid`, `Message`, `Contract`).
- Implementar la base de datos simulada en memoria y funciones para guardar tareas, postularse, aceptar, realizar pagos simulados y chatear de forma reactiva.

### 3. Vistas y Componentes
#### [NEW] [src/views/WelcomeView.vue](file:///home/zurita/dev/Ofix_frontend/src/views/WelcomeView.vue)
- Portal de inicio interactivo con la dualidad de colores natural.
#### [NEW] [src/views/AuthView.vue](file:///home/zurita/dev/Ofix_frontend/src/views/AuthView.vue)
- Formulario de inicio de sesión y registro de alta gama con selector de rol inicial.
#### [NEW] [src/views/DemandDashboard.vue](file:///home/zurita/dev/Ofix_frontend/src/views/DemandDashboard.vue)
- Tablón para clientes. Incluye el buscador de proveedores, mapa de calor interactivo y formulario de creación de tareas.
#### [NEW] [src/views/OfferDashboard.vue](file:///home/zurita/dev/Ofix_frontend/src/views/OfferDashboard.vue)
- Tablón para proveedores de servicios. Muestra tareas cercanas en mapa difuminado y formulario de oferta técnica.
#### [NEW] [src/views/ChatEscrowView.vue](file:///home/zurita/dev/Ofix_frontend/src/views/ChatEscrowView.vue)
- Centro de chat transaccional. Integra el widget de Escrow (garantía), pantalla de pago simulada y modal de retroalimentación de 5 estrellas.

#### [MODIFY] [src/App.vue](file:///home/zurita/dev/Ofix_frontend/src/App.vue)
- Control de layout maestro, animación de orbes en el background, selector flotante de modo.

#### [MODIFY] [src/main.ts](file:///home/zurita/dev/Ofix_frontend/src/main.ts)
- Configurar la inicialización del store global.

---

## Verification Plan

### Automated / Manual Verification
1. **Compilation Check**: Run `npm run build` to confirm all TypeScript components and stores compile without errors.
2. **Interactive Testing**:
   - Toggle the switch at the top to confirm instantly switching between Sunset (Orange) and Terraria (Green) modes.
   - Perform registration/login to confirm role redirection.
   - **Full End-to-End simulation**:
     - Log in as Client -> Create a Task ("Reparación de Fuga en Cocina") -> View details.
     - Switch mode to Provider -> Browse Task board -> Select the Task -> Apply with a bid.
     - Switch mode back to Client -> View Task -> Accept Provider's bid.
     - Go to Escrow Screen -> Complete mock payment -> Verify transition to `funded` (which must unlock the precise address, phone number, and routes).
     - Send chat messages from both sides.
     - Complete the job from the provider side -> Release payment -> Fill the 5-star review.
3. **Responsive Web Check**: Inspect visually on desktop and mobile layout to verify the fluidity of the glass panels and rounded river stone controls.
