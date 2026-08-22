# GAME_DESIGN.md — El Kiosko: Almacén de Barrio

Estado: **Fase 1 (vertical slice) implementada**. Pendiente: Gate A (playtest).

---

## 1. Fantasía central

> "Parto con un mesón medio vacío y termino con el almacén más querido del
> barrio."

El público objetivo inicial son adultos de ~30–60 años usando el teléfono en
trayectos de transporte público. La distribución es **global** (español e
inglés en esta versión); la ambientación de almacén de barrio se mantiene
porque es el diferenciador del juego y el concepto existe en casi todos los
países. De ahí salen las restricciones duras:

| Restricción | Cómo se cumple |
|---|---|
| Se entiende en cualquier idioma | Textos en `lib/l10n`; la lógica de juego no contiene ni un texto visible (ver DECISIONS D-021) |
| Se juega con una mano | Portrait fijo; el control más usado (caja del proveedor) está en la barra inferior, al alcance del pulgar |
| Teléfonos económicos | Sin motor de juego; animaciones cortas; opción "reducir animaciones"; `minSdk 24` |
| Conectividad intermitente | Fase 1 funciona **100% sin conexión**. El save es local |
| Sesiones de 1–5 min **y** de 20 min | Nada limita la duración: no hay energía ni cooldown. La sesión termina cuando el jugador quiere |
| Dedos imprecisos | Objetivos táctiles ≥48dp; un arrastre inválido intercambia en vez de no hacer nada |

---

## 2. Core loop

```text
Tocar la caja del proveedor (cuesta 3)
  → aparece un producto de nivel 1 en el tablero
  → arrastrar dos iguales para fusionarlos (sube de nivel)
  → entregar un pedido que pida ese nivel
  → cobrar monedas + XP
  → mejorar el local (cambia visualmente) / subir de nivel de jugador
  → se desbloquean niveles de pedido más altos y más cadenas
  → volver al tablero
```

El bucle secundario, para la retención entre sesiones:

```text
cerrar la app → el local sigue vendiendo (tope 4 h)
  → al volver, las monedas ya están cobradas
```

---

## 3. Tablero

- **6 columnas × 8 filas = 48 casillas**, portrait.
- Arrastrar y soltar **sin adyacencia**: cualquier pieza sobre cualquier otra.
- Reglas de soltar:
  - casilla vacía → mover;
  - misma cadena + mismo nivel + no es el nivel máximo → **fusionar**;
  - cualquier otro caso → **intercambiar** (ver DECISIONS D-016).
- El tablero se escala para caber siempre completo en pantalla: en un teléfono
  angosto las celdas se achican en vez de aparecer scroll, para que los pedidos
  y el botón del proveedor nunca queden fuera de vista.

### Sugerencia por inactividad
Tras 12 segundos sin acción se resalta un par fusionable. Se puede apagar en
Ajustes.

### Garantía de no bloqueo
Después de cada acción se evalúa si queda alguna jugada posible: fusionar,
generar, entregar un pedido, o vender. Si no queda ninguna, el juego regala el
equivalente a 5 generaciones ("el proveedor te fía"), **gratis y sin anuncios**.
Verificado con un test de propiedad de 40 partidas × 400 acciones al azar.

---

## 4. Cadenas de productos

Tres cadenas × cinco niveles. Sin marcas registradas, sin alcohol, sin tabaco.

| Cadena | N1 | N2 | N3 | N4 | N5 | Desbloqueo |
|---|---|---|---|---|---|---|
| Panadería | Marraqueta | Bolsa de pan | Canasto de pan | Bandeja surtida | Vitrina de pan | inicio |
| Bebidas | Vaso | Botella chica | Botella grande | Pack de bebidas | Refrigerador | inicio |
| Snacks | Dulce | Bolsita | Paquete | Caja surtida | Estante de snacks | nivel 2 |

Cada merge representa **más cantidad / mejor presentación / mayor valor**.

**Cadenas futuras** (fuera del MVP): sopaipillas, completos, empanadas, mote con
huesillos, frutas, lácteos, aseo, útiles escolares.

---

## 5. Pedidos

Tres pedidos visibles arriba del tablero. Cada uno tiene:

- 1 línea (o 2 desde nivel de jugador 3, 30% de las veces);
- icono + nombre del producto + progreso `x/y` leído del tablero en vivo;
- recompensa en monedas, **congelada al generarse** (un cambio de balance en una
  actualización no cambia lo que ya se prometió al jugador);
- XP;
- a veces, marca de **pedido especial** (bonus ×2).

**Sin temporizadores.** El brief los condicionaba a que el playtest demostrara
que agregan diversión; hasta entonces no existen, porque un reloj corriendo es
justo lo contrario de "jugable en cualquier momento del viaje".

**Cambiar un pedido** cuesta monedas (35% de la recompensa, mínimo 5). Es una
decisión económica, no un botón gratis para saltar contenido.

**Los pedidos siempre son satisfacibles**: sólo piden cadenas desbloqueadas y
niveles alcanzables para el nivel de jugador actual. Cubierto por test.

---

## 6. Progreso del local

Siete niveles. Cada uno cambia la fachada dibujada en pantalla: toldo, letrero,
cantidad de estantes, mercadería visible, clientes e iluminación.

| Nivel | Nombre | Costo | Estantes | Clientes | Ingreso/hora |
|---:|---|---:|---:|---:|---:|
| 1 | Mesón improvisado | — | 1 | 1 | 12 |
| 2 | Kiosko | 150 | 2 | 2 | 30 |
| 3 | Almacén chico | 600 | 3 | 3 | 70 |
| 4 | Almacén de barrio | 2.000 | 4 | 4 | 160 |
| 5 | Minimarket | 6.000 | 5 | 5 | 360 |
| 6 | Local renovado | 18.000 | 6 | 6 | 800 |
| 7 | Cadena de barrio | 50.000 | 7 | 8 | 1.800 |

El nivel 2 está calibrado para caer dentro de los primeros 3–5 minutos, que es
el objetivo que fija el brief.

---

## 7. Onboarding

Tres pasos, en una banda inferior que **no bloquea la pantalla**, y con botón
"Saltar" siempre visible:

1. "Arrastra dos productos iguales para juntarlos."
2. "Ahora completa un pedido y cobra."
3. "Usa tus monedas para mejorar el local."

Cada paso avanza sólo cuando el jugador hace **esa** acción. No se saltan pasos:
si alguien entrega un pedido de nivel 1 sin haber fusionado nunca, el juego
sigue pidiendo el merge (cubierto por test).

---

## 8. Identidad cultural

La ambientación es un almacén de barrio: un concepto que existe en casi todo el
mundo (*corner store*, *bodega*, *tienda de la esquina*, *dépanneur*). Los
clientes son **roles cotidianos** —chofer, vecina, repartidor, jubilado,
profesora— que traducen bien sin perder calidez y sin caricaturizar a nadie.

La moneda se muestra como "monedas", no como pesos: el juego se distribuye
globalmente.


**Sí:** almacén de barrio, marraqueta, clientes como oficios cotidianos (chofer,
vecina, feriante, jubilado, repartidor, maestro, emprendedora, turno de noche),
paleta de madera/toldo/papel.

**No:** caricaturas clasistas, "el flaite" como personaje, estereotipos
degradantes, marcas o logos reales, propaganda política, alcohol y tabaco.

Los nombres de clientes describen **roles y momentos del día**, nunca clase
social ni rasgos físicos.

---

## 9. Accesibilidad

- Portrait fijo; todo alcanzable con el pulgar.
- Objetivos táctiles ≥48dp.
- **Nunca sólo color**: cada producto se identifica por color + silueta (ícono)
  + número de nivel + etiqueta de texto.
- `Semantics` en fichas, pedidos, contador de monedas y fachada.
- Escalado de texto del sistema respetado, con tope 1.4× para que el tablero
  siga cabiendo.
- Sonido, vibración y animaciones desactivables por separado.

---

## 10. Monetización — estado actual

**Fase 1 no tiene anuncios, ni compras, ni SDK de monetización.** Es
deliberado: el brief exige demostrar retención antes de monetizar.

La pantalla "Club del Barrio" existe pero es puramente informativa y **no
muestra ningún precio** — cuando entre billing, los precios se leen desde Google
Play, que además los localiza.

Lo que está previsto para Fase 3, y las reglas que ya quedaron escritas:
- rewarded **siempre voluntario** (duplicar ganancia offline, duplicar pedido
  especial, reroll gratis);
- interstitial sólo en cortes naturales, nunca durante un arrastre, nunca al
  abrir, con frequency cap por Remote Config;
- **sin banner en el tablero**;
- el rescate por bloqueo nunca se condiciona a ver un anuncio.

---

## 11. Fuera de alcance (por ahora)

PvP, chat, clanes, backend propio, marketplace, UGC, múltiples ciudades,
historia larga, 50 cadenas, IA generativa dentro del juego, login obligatorio,
leaderboard, mediation, iOS, web, PC.
