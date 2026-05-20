# Sistema de Diseño: Ofix (Conexión Local)

Este sistema de diseño nace de una estética orgánica, táctil e inspirada en la naturaleza mexicana. Combina la textura etérea del vidrio esmerilado (_glassmorphism_) con materiales terrenales: arena, rocas de río pulidas, la calidez de la arcilla al atardecer y la vitalidad de la vegetación viva ("Terraria Elements"). Es una interfaz profesional, limpia y sumamente cercana.

## 1. Concepto Visual y Dirección Creativa

- **Efecto Cristal ("Glassmorphism"):** Paneles translúcidos con desenfoque de fondo generoso (`backdrop-blur`), bordes finos de brillo blanco que emulan el canto de un cristal y sombras suaves. Esto permite que los colores orgánicos de fondo se asomen como luces difusas y suaves.
    
- **Geometría de Piedra de Río:** Curvas extremadamente pronunciadas, amigables y fluidas (radios de `24px` a `36px`). Se eliminan las esquinas duras para dar paso a contenedores interactivos que recuerdan a cantos rodados o cerámica pulida.
    
- **Dualidad de Color Natural:** - El modo **Demanda** se viste de un **Naranja Atardecer / Arcilla**, que invita a la acción inmediata, la calidez del hogar y la resolución de necesidades.
    
    - El modo **Oferta** adopta la paleta **Verde Terraria**, inspirada en hojas vivas, plantas de interior y macetas de cerámica oscura. Transmite crecimiento, serenidad, frescura y un profesionalismo sumamente honesto y cercano.
        

## 2. Paleta de Colores

### Base Común (Arena y Cristal)

- **Arena Base / Stone** (`#F3ECE5`): El lienzo cálido y natural sobre el que flota toda la aplicación. Evoca calma y cercanía.
    
- **Blanco Cristal / Frost** (`rgba(255, 255, 255, 0.45)`): Fondo ultra suave para paneles de vidrio esmerilado.
    
- **Borde de Cristal / Frost Border** (`rgba(255, 255, 255, 0.60)`): Línea de contorno blanca y brillante para separar los paneles del fondo.
    
- **Sombra Orgánica / Clay Shadow** (`rgba(105, 95, 87, 0.12)`): Sombras de caída sumamente suaves y difuminadas.
    

### Modo Demanda (Atardecer & Arcilla)

_Para cuando los usuarios publican un trabajo o tarea que necesitan resolver._

- **Naranja Atardecer / Sunset** (`#FF8235`): Color de acento para botones de acción y elementos activos en este modo.
    
- **Luz de Arcilla / Clay Glow** (`#FDEEE3`): Tono de apoyo cálido y sutil para contenedores internos.
    

### Modo Oferta: "Terraria Elements" (Verde Vegetal & Humus)

_Para los perfiles de proveedores, catálogos de servicios y directorios locales._

- **Verde Terraria / Deep Foliage** (`#3B6043`): El verde protagonista de la imagen de inspiración. Un tono vegetal profundo, vivo y maduro que representa profesionalismo, salud, confianza y cercanía local.
    
- **Verde Brote / Leaf Sprout** (`#97C59F`): Un verde claro, luminoso y sutilmente desaturado (como el panel frontal de la maceta). Ideal para destacar estados de disponibilidad activa, badges y acentos secundarios.
    
- **Negro Humus / Obsidian Ceramic** (`#181B19`): Un negro satinado ultra-profundo con matiz verde oliva oscuro, extraído de la maceta de cerámica de la imagen. Aporta el contraste perfecto y elegante para botones principales, textos destacados y elementos de alto impacto.
    
- **Rocío de Salvia / Sage Wash** (`#EAF0EB`): Fondo súper limpio y fresco con un toque verde agua, excelente para tarjetas de perfiles de proveedores y bloques de contenido.
    

## 3. Tipografía

### Tipos de Letra (Fonts)

- **Display & Títulos:** `Outfit` (o en su defecto `Space Grotesk`, `Inter`). Sus formas geométricas pero amigables y redondeadas encajan perfectamente con este estilo natural y cercano.
    
- **Cuerpo de Texto y UI:** `Inter` (o `ui-sans-serif`). Ofrece una legibilidad óptima y limpia para el uso cotidiano en celulares.
    

### Jerarquía Tipográfica

|   |   |   |   |   |
|---|---|---|---|---|
|**Rol**|**Tamaño**|**Peso**|**Interlineado**|**Notas**|
|**Gran Título / Hero**|`46px`|400|1.05|Bienvenida a la app y claims de confianza.|
|**Título de Sección**|`30px`|500|1.15|Títulos de pantallas principales (ej. "Encuentra ayuda").|
|**Título de Tarjeta**|`19px`|500|1.25|Nombres de proveedores, oficios y tareas.|
|**Cuerpo de Texto**|`15px`|400|1.45|Descripciones, mensajes del chat, textos informativos.|
|**Botón / Píldora**|`14px`|500|1.20|Textos en botones y acciones primarias.|
|**Etiqueta / Micro**|`11px`|600|1.30|Precios promedio, insignias de confianza (ej. "Puntual").|

## 4. Estructura de Elevación y Efecto Cristal

Para dar vida a las transparencias e iluminaciones orgánicas de fondo (como ese "sol" de color que se percibe detrás del cristal), los contenedores principales deben implementar este esquema técnico:

```
/* Especificación de panel de cristal esmerilado */
.glass-panel {
  background-color: rgba(255, 255, 255, 0.45);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 32px; /* Esquinas muy redondeadas de río */
  box-shadow: 0 12px 36px -12px rgba(105, 95, 87, 0.12);
}
```

_Tip Técnico:_ Detrás de los paneles de cristal esmerilado, la app puede posicionar "orbes" o círculos de color difuminados (en **Naranja Atardecer** o **Verde Terraria** según el modo activo) para emular la hermosa iluminación de fondo que se ve en la imagen inspiracional.

## 5. Escala de Redondez (Radii)

Las esquinas pronunciadas o cuadradas están prohibidas para mantener el tacto "orgánico":

- **`xs`** (`6px`): Badges de categorías, insignias pequeñas de confianza.
    
- **`sm`** (`14px`): Avatares, galerías de trabajos anteriores de proveedores (fotos/videos).
    
- **`md`** (`24px`): Tarjetas de trabajos, globos de conversación del chat.
    
- **`lg`** (`32px`): Paneles de pantalla completos, tarjetas principales de perfiles.
    
- **`pill`** (`9999px`): Botones, campos de texto (inputs), selector de modo dinámico.
    

## 6. Componentes del Ecosistema de Diseño

### A. Selector de Modo (El Switch Central)

Una píldora interactiva suspendida en la parte superior:

- **Base:** Vidrio esmerilado translúcido con un fino borde blanco brillante.
    
- **Píldora Deslizante:** Al cambiar al modo **Demanda**, la píldora se torna **Naranja Atardecer**. Al cambiar al modo **Oferta**, se desliza y se torna del majestuoso **Verde Terraria** con tipografía blanca.
    

### B. Campos de Entrada (Inputs)

Inspirados en la limpia barra de búsqueda de la primera imagen:

- Forma de píldora perfecta (`rounded-full`).
    
- Fondo blanco altamente translúcido, borde suave brillante y textos legibles en **Negro Humus**.
    
- Iconografía minimalista en tonos tierra.
    

### C. Botones de Acción "Unirse / Contratar"

Siguen la estética de alta gama del botón `Join in ->` de la imagen de login:

- Botón principal tipo píldora en **Negro Humus** con tipografía blanca.
    
- Contiene un círculo secundario en el extremo derecho que alberga un sutil icono de flecha minimalista.
    
- Al interactuar, este círculo se ilumina en **Naranja Atardecer** (modo demanda) o **Verde Terraria** (modo oferta).
    

### D. Indicadores de Disponibilidad e Insignias de Confianza

- **Online/Disponible:** Una píldora sutil con fondo **Rocío de Salvia** y texto en **Verde Terraria** o un pequeño punto brillante en **Verde Brote**.
    
- **Insignias (Platinum, Puntual):** Contenedores translúcidos con microtipografías elegantes.
    

## 7. Do's and Don'ts (Qué hacer y qué no hacer)

### Sí (Hacer):

- **Saturación contenida:** Usa el fondo Arena cálida y las transparencias para suavizar la interfaz. Los colores vivos (Naranja o Verde) actúan como guías visuales e "iluminación" de fondo, no como plastas de color sólido que saturen al usuario.
    
- **Contraste de Cerámica:** Usa el **Negro Humus** para dar un aspecto increíblemente sofisticado y premium a la tipografía principal y a las acciones importantes.
    
- **Esquinas fluidas:** Asegúrate de que las imágenes de los portafolios y perfiles se recorten con curvas suaves de río.
    

### No (Hacer):

- **Evitar grises industriales:** No uses grises fríos para bordes o fondos; utiliza el tono Arena y sus transparencias.
    
- **Evitar verdes brillantes de tecnología:** El verde de esta aplicación debe ser siempre el **Verde Terraria**, un tono vegetal maduro, natural y boscoso, nunca un verde fosforescente, azulado o tipo "crypto".