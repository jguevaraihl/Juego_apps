# Instrucciones para ilustrar las siete fachadas

Este documento es el **encargo**: lo que hay que pedirle a un ilustrador —humano
o una herramienta de IA— para reemplazar la fachada dibujada en código por
ilustración de verdad, sin tocar el motor del juego.

Está dividido en tres partes:

1. **Reglas duras** — lo que hace que las siete se vean como el *mismo* local
   mejorando, y no como siete locales distintos. Es la parte que más importa.
2. **Los siete prompts** — listos para copiar y pegar.
3. **Cómo se integran los archivos** — dónde van y qué toca el programador.

Los prompts están **en inglés a propósito**. Todos los generadores de imagen
actuales (Midjourney, Imagen, Firefly, DALL·E, Flux) entienden bastante mejor
las descripciones de estilo en inglés, y "warm hand-painted 2D game
illustration" produce un resultado más consistente que su traducción. La
explicación de cada uno queda en español para quien encarga.

> **Aviso legal, antes de generar nada.** Si se usa una herramienta de IA, hay
> que verificar en **sus términos** que permite uso comercial de lo generado y
> qué derechos otorga. No todas lo permiten, y algunas cambian las condiciones
> según el plan contratado. Si se contrata a un ilustrador humano, pedir
> **cesión de derechos comercial por escrito**, no un "permiso de uso". Esta
> decisión es del dueño del proyecto (ver `ART_DIRECTION.md`).

---

## 1. Reglas duras

### 1.1 La cámara no se mueve. Nunca.

Esta es **la regla más importante del documento**. El jugador ve las siete
fachadas a lo largo de semanas, una después de otra, en el mismo rectángulo de
la pantalla. Si la cámara cambia de altura, de distancia o de ángulo entre un
nivel y el siguiente, subir de nivel deja de sentirse como *"mi local mejoró"* y
pasa a sentirse como *"me cambiaron de local"*. Todo el efecto emocional del
progreso depende de esto.

En las siete imágenes:

- **Vista frontal plana**, a la altura de los ojos, sin punto de fuga, sin
  ángulo isométrico, sin picado ni contrapicado.
- **La puerta va siempre en el mismo lugar**: centrada horizontalmente, su
  umbral apoyado en la línea del suelo.
- **La línea del suelo va siempre a la misma altura**: al **72 %** de la altura
  de la imagen, medido desde arriba.
- **El local ocupa siempre el mismo ancho**: de borde a borde, con los vecinos
  asomando apenas por los costados.
- La misma distancia a la cámara. El local no se acerca ni se aleja al mejorar:
  **se llena**.

Manera práctica de conseguirlo: generar **primero el nivel 4** (el que le da el
nombre al juego, "Almacén de barrio") como **ancla de estilo**, aprobarlo, y
después generar los otros seis **usándolo como imagen de referencia**. Anclar
todos al mismo, no encadenarlos uno tras otro: encadenados, la desviación se
acumula y el nivel 7 termina en otro planeta.

### 1.2 El letrero va **en blanco**

El jugador le pone nombre a su local, y ese nombre lo escribe la app encima de
la ilustración, en el idioma que corresponda. Por lo tanto:

- **La ilustración no lleva ni una letra, ni un número, en ningún idioma.**
  Ni en el letrero, ni en la vitrina, ni en las cajas, ni en la pizarra.
- El letrero tiene que ser un **panel liso y vacío**, con contraste suficiente
  para que encima se lea texto oscuro, y espacio cómodo para unos 18 caracteres.
- El panel del letrero debe quedar **horizontal y centrado**, en el mismo lugar
  en los siete niveles (ver el rectángulo del letrero en la tabla de 1.5).

Los generadores de imagen insisten en inventar letreros escritos. Si aparece
texto, la entrega **se rechaza**: no es un detalle menor, es texto basura en
todos los idiomas del mundo menos en ninguno.

### 1.3 El toldo se entrega aparte

El jugador elige entre ocho colores de toldo. Si el toldo viene pintado en la
imagen, esa personalización se pierde. Por eso cada nivel que tenga toldo (del 2
en adelante) se entrega en **dos archivos**:

- `level_N.png` — la fachada completa **sin el toldo** (el hueco donde va queda
  pintado como pared/sombra, como si el toldo estuviera recogido).
- `level_N_awning.png` — **sólo el toldo**, fondo transparente, pintado en
  **escala de grises** (las rayas como valores claros y oscuros, no como
  colores). La app lo tiñe con el color elegido.

Si esto se complica, la alternativa aceptable es entregar el toldo pintado en
color teja (`#C2410C`) y **avisar**, para desactivar la elección de color: es
peor, pero es una decisión consciente y no una sorpresa.

### 1.4 Lienzo, recorte y zona crítica

**Lienzo: 2048 × 1024 px (relación 2:1), horizontal.**

La misma imagen se usa en dos lugares de la app con formas distintas:

- En la **pantalla de la tienda** se ve prácticamente completa (banda ancha).
- En la **pantalla de juego** se ve sólo una **franja horizontal** de ella,
  porque ahí la fachada es un banner bajo y ancho.

Por eso hay que componer con márgenes de sacrificio arriba y abajo:

| Franja | Altura (de 1024 px) | Qué va ahí |
|---|---|---|
| Cielo / techos | 0 – 205 px (0 – 20 %) | Decorativo. **Se recorta.** |
| **Zona crítica** | **205 – 738 px (20 – 72 %)** | **Letrero, toldo, vitrina, mercadería, puerta. Todo lo que identifica el nivel.** |
| Vereda / clientes / plantas | 738 – 1024 px (72 – 100 %) | Decorativo. **Se recorta.** |

Horizontalmente, dejar **8 % de margen a cada lado** (≈ 165 px) libre de
cualquier cosa importante: en pantallas angostas esos bordes se recortan.

Nada de bordes, marcos, viñetas ni sombra alrededor de la imagen: la app la
recorta con esquinas redondeadas y un marco pintado quedaría cortado.

### 1.5 Coordenadas fijas entre niveles

Para que el letrero y el toldo caigan siempre en el mismo sitio, y para que la
app pueda escribir el nombre del local encima:

| Elemento | Posición (fracción del ancho × alto) |
|---|---|
| Panel del letrero | x de 0.22 a 0.78 · y de 0.26 a 0.40 |
| Toldo | x de 0.14 a 0.86 · y de 0.41 a 0.52 |
| Vitrina / ventana | x de 0.14 a 0.60 · y de 0.52 a 0.72 |
| Puerta | x de 0.63 a 0.84 · y de 0.48 a 0.72 |
| Línea del suelo | y = 0.72 |

No hace falta que sean exactas al píxel; sí que **no se muevan** entre niveles.

### 1.6 Paleta

El juego ya tiene una identidad de color. La ilustración tiene que caer dentro
de ella, no imponer la suya:

| Color | Hex | Dónde |
|---|---|---|
| Madera de marca | `#7A4A25` | Estantes, mesón, marcos |
| Madera oscura | `#4A2B14` | Sombras de la madera, zócalos |
| Crema | `#FBF3E4` | Muros claros, panel del letrero |
| Teja | `#C2410C` | Toldo por defecto, acentos |
| Verde | `#15803D` | Plantas, detalles |

Luz cálida de día, entrando desde arriba a la izquierda. Nada de azules fríos
dominantes, nada de neón, nada de paleta pastel lavada.

### 1.7 Un local de barrio de ningún país en particular

El juego se publica en todo el mundo. La fachada tiene que leerse como *"el
almacén de la esquina"* para alguien en Santiago, en Manila o en Varsovia: cajón
de frutas, toldo a rayas, vitrina, cajas de cartón, una balanza, un gato. **Sin
banderas, sin marcas reales, sin envases reconocibles, sin arquitectura
específica de un país** (nada de tejados coloniales, ni de puestos de mercado
asiáticos, ni de delis neoyorquinos). Genérico y cálido.

### 1.8 Prompt negativo (para todos los niveles)

```
text, letters, words, numbers, signage copy, watermark, signature, logo,
brand names, product labels with text, isometric view, three-quarter view,
perspective distortion, vanishing point, top-down view, photorealistic,
3d render, octane, cgi, neon, cyberpunk, dark gritty, muted washed-out colors,
cluttered background, street traffic, cars, crowds, close-up faces,
frame, border, vignette, drop shadow around the image, blurry, lowres
```

---

## 2. Los siete prompts

Todos empiezan con el **mismo bloque de estilo**. Copiarlo tal cual delante de
la descripción de cada nivel; es lo que mantiene la unidad.

### Bloque de estilo (va en los siete)

```
Front-on flat elevation view of a small neighbourhood corner grocery store,
perfectly centred, eye level, no perspective, no vanishing point, no isometric
angle. Warm hand-painted 2D mobile game illustration, soft cel shading with
visible brush texture, thick readable silhouettes, cosy and inviting. Earthy
saturated palette built on warm brown wood #7A4A25, cream #FBF3E4 and
terracotta #C2410C. Warm daylight from the upper left, soft ambient occlusion
under the awning and shelves. Style of Merge Mansion and Township key art:
appealing, clean, readable at small sizes. Ground line at 72% of the image
height, door centred. Absolutely no text, no letters and no numbers anywhere.
Wide 2:1 banner composition, 2048x1024.
```

---

### Nivel 1 — *Mesón improvisado*

**La idea:** todavía no hay local. Hay ganas. Es el punto de partida contra el
que se van a medir los otros seis, así que tiene que verse **modesto pero
digno**, nunca miserable ni triste: el jugador acaba de empezar y no se le da la
bienvenida con pobreza.

```
[BLOQUE DE ESTILO]
Level 1: the humblest possible beginning. A bare, slightly weathered red brick
wall with no shopfront yet. In front of it, a single wooden plank laid across
two stacked wooden crates as a makeshift counter. On the plank, three or four
loose goods: a couple of paper-wrapped bread loaves, a bottle, a small pile of
fruit. A blank rectangular piece of cardboard is tied to the wall above as a
sign — completely empty, no writing at all. No awning, no window, no door frame
yet, just the doorway opening in the wall. Bare concrete pavement. One friendly
customer standing to the side. Sunny, hopeful, modest but tidy — humble, never
poor or sad.
```

---

### Nivel 2 — *Kiosko*

**Qué cambia:** aparece la **primera inversión de verdad**: un letrero de madera
pintado y un toldo. Es el salto más importante de todo el juego en términos de
sensación, porque es el primero que el jugador ve.

```
[BLOQUE DE ESTILO]
Level 2: the stall has become a proper little kiosk. The brick wall now has a
painted wooden sign board mounted above the opening — a clean, completely blank
cream panel with a simple carved wooden frame, no writing at all. A small
serving window with a wooden ledge has been cut into the wall. Two wooden
shelves inside hold bread, bottles and boxed goods. The makeshift crate counter
is now a real wooden counter. The awning is retracted and absent; leave a clean
shadowed strip on the wall where an awning would attach. Two customers, one
waiting at the window. Same brick wall, same doorway position, same pavement as
before — visibly the same place, just built up.
```

*(Recordar: el toldo de este nivel y de todos los siguientes se entrega en el
archivo `_awning` aparte, en escala de grises y con fondo transparente.)*

---

### Nivel 3 — *Almacén chico*

**Qué cambia:** el local se cierra hacia la calle con **vidrio**. Aparece la
vitrina, el zócalo pintado y los edificios vecinos: el almacén deja de flotar y
se planta en una cuadra.

```
[BLOQUE DE ESTILO]
Level 3: now a small closed grocery shop. The serving window has become a proper
glass shop window with a wooden frame and a soft diagonal reflection across the
glass. Behind the glass, three wooden shelves fully stocked with tins, jars,
bread and boxes. A painted wooden skirting board runs along the bottom of the
facade. A real panelled wooden door with a small glass pane and a brass handle.
Neighbouring buildings now appear at both edges of the frame, cropped, giving
the shop a street. Three customers, one carrying a paper shopping bag. Same
camera, same door position, same ground line.
```

---

### Nivel 4 — *Almacén de barrio* ← **generar este primero**

**Qué cambia:** es el nivel que le da el nombre al juego y el **ancla de estilo**
de la serie. Tiene que ser el más "correcto" de todos: si este queda bien, los
otros seis se generan usándolo como referencia.

```
[BLOQUE DE ESTILO]
Level 4: a warm, established neighbourhood grocery store — the heart of the
block. Four wooden shelves visible through a large clean shop window, densely
and neatly stocked with produce crates, tins, jars, bread and bottles. A brass
weighing scale sits on the wooden counter by the window. A healthy green potted
plant beside the door. The wall is neatly painted above the brick skirting. A
crate of colourful fruit and vegetables on the pavement by the entrance. Metal
support rods for the awning are visible against the wall. Four customers,
relaxed, chatting. Golden warm afternoon light. This is the reference image for
the whole series: get the camera, palette and level of detail exactly right.
```

---

### Nivel 5 — *Minimarket*

**Qué cambia:** llega la **electricidad decorativa**. Ampolletas en el letrero,
refrigerador visible: el local empieza a verse "de noche" incluso de día.

```
[BLOQUE DE ESTILO]
Level 5: the shop has grown into a small minimarket. A row of round warm
lightbulbs is mounted along the top edge of the blank sign board, lit. Inside,
through the window, a glass-fronted drinks refrigerator glows softly beside five
well-stocked shelves. A small blank chalkboard easel stands on the pavement by
the door — a dark empty slate, no writing at all. The window now has a slim
cross mullion dividing the glass. The facade wall is fully rendered and painted
in warm cream. Five customers, one leaving with a full bag. Same camera, same
door position, same ground line.
```

---

### Nivel 6 — *Local renovado*

**Qué cambia:** la **segunda vitrina**. Es el primer nivel donde el local ocupa
más frente del que ocupaba: se nota que se comió el espacio del lado.

```
[BLOQUE DE ESTILO]
Level 6: a fully renovated shop. The facade now has two large glass shop
windows, one on each side of the central door, both framed in polished dark
wood. Six shelves are visible in total, immaculately arranged. New patterned
tile flooring is visible through the open door. Polished brass fittings, a
clean cream painted wall, a proper stone step at the entrance. A ginger cat
sleeps curled on a wooden crate beside the door. Two potted plants. Six
customers, a small queue forming. Same camera, same door position, same ground
line.
```

---

### Nivel 7 — *Cadena de barrio*

**Qué cambia:** es el final del camino visible. Tiene que verse **claramente
mejor que el 6** sin volverse un supermercado corporativo: sigue siendo el
almacén de la esquina, pero es *el mejor de todos*.

```
[BLOQUE DE ESTILO]
Level 7: the most beloved shop in the neighbourhood, at its peak. Immaculate
smooth cream rendered facade with decorative moulding along the top. Two tall
pristine shop windows with seven densely stocked shelves visible, plus a
handsome glass display cabinet by the door. A wide blank sign panel with an
elegant carved wooden frame and warm lit bulbs above it. Polished brass and
dark wood everywhere, a striped tiled entrance step, a bicycle leaning by the
wall, two large healthy plants in glazed pots, a wooden bench. A small awning
over each window. Eight happy customers around the entrance, some chatting,
some leaving with full bags. Late golden hour light. Prosperous, warm and
family-run — never corporate, never a supermarket chain. Same camera, same door
position, same ground line.
```

---

### Las versiones de noche (modo oscuro)

El juego tiene modo oscuro, y en modo oscuro la fachada **no se invierte**: es
el mismo almacén, de noche. Es mucho más barato pedir un **reencendido** de cada
pintura que siete pinturas nuevas — al ilustrador se le pasa la imagen de día y
se le pide esto:

```
Same illustration, exactly the same composition, camera, geometry and objects,
relit as a warm night scene: deep blue night sky, a moon, lit windows in the
neighbouring buildings, the shop interior glowing warm yellow through the glass,
a soft pool of warm light spilling onto the pavement in front of the door, and
the sign bulbs lit (levels 5 to 7). Do not move, add or remove any object. Do
not change the sign panel, which stays blank.
```

Si el presupuesto obliga a recortar: pedir las nocturnas **sólo de los niveles
5, 6 y 7**. Los niveles bajos duran pocos días y la versión dibujada en código
ya se ve digna de noche.

### Las cuatro mascotas

El jugador elige una mascota para el local (gato, perro, loro, tortuga) o
ninguna. Se dibuja **encima** de la fachada, así que van aparte:

```
[BLOQUE DE ESTILO, sin la parte de composición 2:1]
A single [cat | small dog | green parrot | tortoise] sitting calmly on a wooden
crate, side view facing right, friendly and rounded, matching the shop
illustration style exactly. Isolated on a fully transparent background, no
shadow on the ground, no background elements at all. Square canvas 512x512, the
animal filling most of the frame.
```

Los cuatro tienen que compartir la misma altura aparente y la misma línea de
apoyo, porque se dibujan sobre el mismo cajón.

---

## 3. Qué se entrega y cómo se integra

### 3.1 Archivos

| Archivo | Tamaño | Fondo |
|---|---|---|
| `level_1.png` … `level_7.png` | 2048 × 1024 | opaco |
| `level_2_awning.png` … `level_7_awning.png` | 2048 × 1024 | **transparente**, toldo en escala de grises |
| `level_1_night.png` … `level_7_night.png` | 2048 × 1024 | opaco |
| `pet_1.png` … `pet_4.png` | 512 × 512 | **transparente** |

Entregar en **PNG sin comprimir**. El proyecto los convierte a WebP calidad 85,
que es lo que se empaqueta; a esa calidad cada fachada queda en torno a 150 KB y
las 21 imágenes suman menos de 3 MB, que es lo que se puede gastar sin que el
tamaño de descarga en Google Play se vuelva un problema.

Si el ilustrador trabaja por capas (Photoshop, Procreate, Krita), pedir además
el archivo por capas: sirve para corregir un detalle sin repintar todo.

### 3.2 Lista de aceptación

Antes de pagar o de dar por buena una entrega, revisar una por una:

- [ ] **No hay ni una letra ni un número** en ninguna imagen.
- [ ] El panel del letrero está **vacío** y tiene contraste para texto oscuro.
- [ ] La puerta está en el mismo x en las siete; la línea del suelo en el mismo y.
- [ ] Poniendo las siete en fila se lee **una progresión**, no siete locales.
- [ ] Recortando la franja del 20 % al 72 % de alto, cada imagen **sigue
      identificándose** como su nivel.
- [ ] Achicada a 340 × 96 px (el tamaño real en un teléfono), la fachada
      **todavía se entiende**. Esta es la prueba que más entregas reprueba.
- [ ] El toldo viene en archivo aparte, transparente y en escala de grises.
- [ ] Sin marcas reales, sin banderas, sin arquitectura de un país específico.
- [ ] Sin marco, sin borde, sin viñeta, sin sombra alrededor.

### 3.3 Integración en el código

La app ya está preparada para recibirlas. `lib/features/home/widgets/
storefront_art.dart` tiene un registro **vacío** hoy; mientras esté vacío el
juego sigue usando la fachada dibujada en código, que es el respaldo y no se
elimina (sirve de red si un asset falta y mantiene el juego jugable si el arte
nunca llega).

Para activar un nivel ilustrado:

1. Convertir el PNG a WebP y dejarlo en
   `assets/art/storefront/level_N.webp` (y `_night`, y `_awning`).
2. Agregar la entrada del nivel en `StorefrontArt.byLevel`.
3. Listo. No hay que tocar el motor, ni el guardado, ni la lógica del juego.

Se puede activar **de a un nivel**: si sólo llegaron el 4 y el 7, esos dos se
ven ilustrados y los otros cinco siguen dibujados. Feo mezclado, pero permite
ir soltando el arte a medida que llega en vez de esperar a tenerlo todo.
