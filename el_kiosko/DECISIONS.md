# DECISIONS.md

Registro de decisiones técnicas y de diseño. Cada entrada dice **qué** se
decidió, **por qué**, y **qué habría que ver** para cambiarla.

Las decisiones que se apartan de `PLAN_FINAL.md` están marcadas con
**↔ Cambio respecto del brief**.

Fecha de implementación: **2026-08-22**.

---

## D-001 — Flutter puro, sin Flame

**Decisión.** El tablero se dibuja con widgets normales (`Draggable` /
`DragTarget`), no con Flame.

**Por qué.** El juego no tiene loop de física, ni sprites animados por frame,
ni cámara. Es una grilla de 48 celdas con arrastrar y soltar. Flame agregaría
un game loop, un sistema de componentes y una dependencia más que mantener,
sin resolver ningún problema que hoy exista. Los widgets además traen gratis
accesibilidad (`Semantics`), escalado de texto y tests de widget.

**Cuándo reconsiderar.** Si aparecen partículas masivas, animaciones por
frame en muchos objetos a la vez, o jank medido en gama baja que se rastree al
árbol de widgets.

---

## D-002 — La app vive en `el_kiosko/`, no en la raíz del repo

**Decisión.** El proyecto Flutter está en `el_kiosko/`. En la raíz quedan sólo
el README y el workflow de CI.

**Por qué.** El repositorio se llama `Juego_apps` (plural) y esta es la
estructura que describe `PLAN_FINAL.md` §18. Deja espacio para un segundo
proyecto sin reorganizar nada. El costo es una línea `working-directory` en CI.

---

## D-003 — Package name provisorio ⚠️ REQUIERE CONFIRMACIÓN DEL OWNER

**Decisión.** `cl.elkiosko.almacen`, como **placeholder**.

**Por qué es importante.** El `applicationId` es **permanente** una vez que la
app se publica en Google Play: no se puede cambiar sin crear una ficha nueva y
perder instalaciones y reseñas.

**Qué falta.** Que el owner confirme el identificador definitivo antes de la
primera subida. También conviene revisar disponibilidad del nombre "El Kiosko"
en Play y en marcas chilenas (INAPI) antes de comprometerlo.

**Dónde se cambia.** `android/app/build.gradle.kts` (`namespace` y
`applicationId`) y el nombre del paquete Kotlin en `android/app/src/main/kotlin/`.

---

## D-004 — Riverpod para estado

**Decisión.** `flutter_riverpod` 3.4.2. Un `NotifierProvider` con el estado de
la partida, más `Provider`s para motor, repositorio, economía y analytics.

**Por qué.** Es lo que pide el brief y encaja bien acá: los providers se
sobreescriben en los tests de widget para inyectar un `MemorySaveStore`, que es
lo que permite testear la UI sin tocar disco ni plugins.

**Nota.** El uso se mantiene deliberadamente chico (5 providers) para que una
futura migración, si hiciera falta, sea barata.

---

## D-005 — Persistencia en archivo JSON, no Hive ni Drift ↔ Cambio respecto del brief

**Decisión.** El save es **un archivo JSON** escrito de forma atómica
(`.tmp` + `rename`) en el directorio de documentos de la app, vía
`path_provider`. Sin base de datos.

**Por qué.** El brief sugería Hive CE o Drift. El estado completo de la partida
es un único documento de unos pocos KB que siempre se lee y escribe entero: no
hay consultas, ni índices, ni relaciones. Una base de datos agregaría una
dependencia con su propio ciclo de migraciones y su propio riesgo de abandono,
para resolver un problema que no tenemos. `dart:convert` + `dart:io` no se
deprecan.

**Lo que sí se conservó del requisito.** Las migraciones se diseñaron desde el
día 1: `SaveCodec` tiene `schemaVersion`, una cadena de migraciones registrada
y tests que cubren save viejo, save corrupto, save de versión futura y tablero
truncado.

**Cuándo reconsiderar.** Si aparece contenido que exija consultas (ranking
local grande, historial de partidas, inventario de miles de ítems), Drift.

---

## D-006 — Sin barra de energía; generar cuesta monedas

**Decisión.** No hay energía ni cooldown. Tocar la caja del proveedor cuesta
**3 monedas**. El ingreso real viene de los pedidos.

**Por qué.** El brief pide explícitamente no poner una barrera diseñada sólo
para vender anuncios. Pero la generación gratis e ilimitada rompe la economía:
si generar es gratis y vender paga, generar+vender es una máquina infinita de
monedas. El costo en monedas mantiene la decisión económica sin bloquear al
jugador por tiempo.

**Invariante que lo sostiene.** `sellValue(1) < generateCost` (1 < 3). Está
verificado por test (`test/economy_test.dart`), así que un cambio de balance
que rompa la economía falla en CI.

---

## D-007 — Garantía de no bloqueo: "el proveedor te fía"

**Decisión.** Después de **cada** acción se evalúa `canMakeProgress()`. Si el
jugador no tiene ninguna jugada posible, el juego le regala el equivalente a 5
generaciones, con el mensaje "El proveedor te fía".

**Por qué.** El brief exige que el juego nunca quede irrecuperablemente
atascado. Se resolvió como red de seguridad explícita y **gratuita**: no se
condiciona a ver un anuncio ni a pagar. Convertir este momento en un gancho de
monetización sería exactamente el dark pattern que el brief prohíbe.

**Cómo se verifica.** Test de propiedad: 40 partidas × 400 acciones al azar,
comprobando en cada paso que existe jugada posible y que las monedas nunca son
negativas.

---

## D-008 — La caja del proveedor es un botón inferior, no una casilla del tablero ↔ Cambio respecto del brief

**Decisión.** El generador es un botón grande (60dp de alto) en la barra
inferior, no un objeto dentro de la grilla.

**Por qué.** El brief pedía "un elemento visual tipo caja del proveedor" sin
exigir que estuviera en el tablero. Ponerlo abajo (a) libera una casilla de 48,
(b) lo deja en la zona de alcance del pulgar, que es el requisito de uso con
una mano, y (c) evita que el jugador lo tape o lo arrastre por accidente.

---

## D-009 — Navegación con `Navigator` estándar, sin `go_router`

**Decisión.** Rutas nombradas y `onGenerateRoute`.

**Por qué.** Son 5 pantallas sin deep links, sin URLs y sin web. `go_router`
resolvería problemas que este proyecto no tiene. Si más adelante se agregan
deep links (por ejemplo para compartir por WhatsApp), se reevalúa.

---

## D-010 — Analytics: interfaz sí, Firebase no ↔ Matiz respecto del brief

**Decisión.** Existe `AnalyticsSink` con la taxonomía completa de eventos de
`PLAN_FINAL` §13, y dos implementaciones: `NoopAnalytics` y `DebugAnalytics`
(imprime en consola sólo en debug). **No hay Firebase, ni red, ni SDK.**

**Por qué.** El brief dice implementar analytics después del prototipo, y así
se hizo: no sale ningún dato del dispositivo. Pero dejar la interfaz y los
nombres de evento definidos ahora cuesta ~60 líneas, obliga a pensar la
taxonomía mientras el juego se diseña, y hace que Fase 2 sea cambiar una línea
en `providers.dart` en vez de instrumentar el juego entero a posteriori.

Todos los eventos llevan `economy_version` para poder comparar cohortes cuando
cambie el balance. Ninguno lleva PII.

---

## D-011 — Ingreso offline adelantado desde Fase 2 ↔ Cambio respecto del brief

**Decisión.** La ganancia pasiva (tope 4 horas) está implementada en Fase 1.

**Por qué.** El brief la lista en Fase 2, pero también exige tests de "income
offline" entre los core tests, y la fantasía central que Gate A debe evaluar
incluye "volver y encontrar progreso acumulado". Son ~30 líneas de lógica pura
más una hoja inferior. Sin esto, el playtest no puede medir la parte de
retención del loop.

**Anti-exploit.** Si el reloj del dispositivo retrocede, la ganancia es 0:
adelantar la hora del teléfono no sirve como atajo.

---

## D-012 — `minSdk 24`, `targetSdk`/`compileSdk 36`, fijados explícitamente

**Decisión.** Los tres valores están escritos a mano en
`android/app/build.gradle.kts` en vez de heredar `flutter.compileSdkVersion` y
compañía.

**Por qué.** Google Play exige **API 36** para apps nuevas y actualizaciones
desde el **31 de agosto de 2026**, que es después de la fecha de lanzamiento
planificada. Flutter 3.47.1 hoy usa 36 por defecto, pero heredar el default
significa que una futura actualización del SDK podría mover el target sin que
nadie lo note. Fijarlo lo vuelve una decisión visible en el diff.

`minSdk 24` (Android 7.0) equilibra alcance y mantenimiento, dentro del rango
que pide el brief (23/24+).

---

## D-013 — R8 (`minifyEnabled` + `shrinkResources`) activo en release

**Decisión.** El build de release ofusca y reduce recursos, con reglas de
ProGuard propias en `android/app/proguard-rules.pro`.

**Por qué.** El público objetivo usa teléfonos económicos con almacenamiento y
datos limitados; el AAB más chico es un beneficio directo. El riesgo (R8
rompiendo algo por reflexión) es bajo acá: el único plugin es `path_provider`,
y tanto el motor de Flutter como los plugins traen sus propias reglas
`consumer`.

**Cómo se verifica.** El job `build` de CI compila el AAB de release en cada
push. Si R8 rompe algo, CI lo detecta antes que un usuario.

---

## D-014 — Íconos generados en el repo, adaptativo + legacy

**Decisión.** Ícono adaptativo (`mipmap-anydpi-v26` + vector) más PNGs legacy
regenerados para API 24–25, más un ícono 512×512 para la ficha de Play.

**Por qué.** El template de Flutter deja el logo de Flutter en los PNG legacy.
Con `minSdk 24` hay dispositivos reales (API 24–25) que **no** usan el ícono
adaptativo y habrían mostrado el logo de Flutter en producción.

---

## D-015 — Sin archivos de audio en Fase 1

**Decisión.** El feedback es háptico (`HapticFeedback`) más el click del
sistema (`SystemSound`). No se empaqueta ningún archivo de audio.

**Por qué.** El brief prohíbe bloquear el desarrollo por arte final y exige
registrar la procedencia de cada asset. Sin SFX con licencia verificada, la
opción honesta es no incluir audio todavía. Ambos canales se pueden apagar en
Ajustes.

---

## D-016 — Un arrastre inválido intercambia, no se cancela

**Decisión.** Soltar un producto sobre otro que no se puede fusionar
**intercambia** las dos piezas.

**Por qué.** Es la convención del género y le da al jugador una forma de
ordenar el tablero. Cancelar el arrastre haría que el gesto "no haga nada", que
en playtest se lee como que el juego no respondió — especialmente con dedos
imprecisos, que es el escenario de uso previsto.

---

## D-017 — Snacks se desbloquea en nivel de jugador 2

**Decisión.** Panadería y Bebidas están disponibles desde el inicio; Snacks se
desbloquea al subir a nivel 2 (30 XP, unos 2–3 pedidos).

**Por qué.** El brief pide 3 cadenas en el vertical slice. Tenerlas las tres
desde el segundo cero desperdicia el primer momento de desbloqueo, que es
justamente una de las señales que Gate A debería medir. 30 XP llega rápido.

---

## D-018 — CI compila el AAB pero no publica

**Decisión.** El workflow corre formato, análisis, tests y build de AAB, y sube
el `.aab` como artifact. **No** hay subida automática a Play Console.

**Por qué.** Es literalmente lo que pide el brief: build automático y
distribución de testing primero; automatizar Play Console sólo cuando el flujo
esté estable.

Si los secretos de firma no están configurados, el AAB se firma con la clave de
debug: sirve para verificar que compila, pero **no** se puede subir a Play.

---

## D-019 — ~~Sólo español (es-CL)~~ · SUPERSEDIDA POR D-021

**Decisión original.** Textos en español chileno, escritos en el código, sin
framework de localización, porque el lanzamiento era sólo Chile.

**Por qué cambió.** El owner cambió el objetivo comercial: distribución lo más
masiva posible y ingresos de muchos países. Eso convierte la localización en un
requisito, no en una optimización futura. Ver **D-021**.

---

## D-021 — Internacionalización: el catálogo no contiene texto

**Decisión.** El juego se localizó con `flutter_localizations` + archivos ARB.
Español e inglés en esta versión. Y, más importante que los idiomas:

> **la lógica de juego no contiene ni un solo texto visible.**

`ProductChain`, `ShopTier` y `CustomerOrder` guardan **identificadores**
(`panaderia`, nivel 3, `customerId: 4`), nunca nombres. La capa de UI resuelve
esos ids contra `lib/l10n` en
`lib/features/common/game_strings.dart`.

**Por qué así.** Si el save guardara "Marraqueta" o "Don Chofer", la partida
quedaría escrita en el idioma en que se creó: un jugador que cambia de idioma
seguiría viendo pedidos en español para siempre. Guardando ids, el mismo save
se lee correctamente en cualquier locale, y agregar un idioma es agregar un ARB
sin tocar el motor ni migrar partidas.

**Costo.** Obligó a subir el esquema del save a **v2**, con una migración que
convierte el `customer` (texto) de los saves v1 en un `customerId`. Está
cubierta por tests, incluyendo que sea determinista.

**Decisiones de contenido.**
- La moneda se muestra como "monedas"/"coins", no "pesos": el juego se
  distribuye en muchos países y el peso chileno no significa nada fuera.
- Los clientes pasaron de nombres muy locales a **roles universales** (chofer,
  vecina, repartidor, jubilado…), que traducen bien sin perder la calidez.
- La ambientación de almacén de barrio **se mantiene**: es el diferenciador del
  juego, y el concepto existe en casi todos los países. Lo que se
  internacionaliza es el idioma, no la identidad.
- El jugador puede forzar el idioma desde Ajustes; por defecto sigue al sistema.

**Cómo agregar un idioma.** Copiar `lib/l10n/app_en.arb`, traducir los valores,
guardarlo como `app_<código>.arb`, y agregar el idioma a
`SettingsScreen.languageNames`. Nada más.

**Siguiente candidato.** Portugués (Brasil) es el de mayor retorno para un
casual de este tipo. No se incluyó todavía para no meter una traducción sin
revisar por alguien que hable el idioma.

---

## D-022 — La semilla del RNG usa un literal, no `1 << 32`

**Bug encontrado y corregido.** `GameEngine._withRng` calculaba la cota de la
semilla siguiente como `rng.nextInt(1 << 32)`. En la VM de Dart eso vale
4.294.967.296 y funciona. **En la web no**: los enteros de Dart son doubles de
JavaScript y los operadores de bits son de 32 bits, así que `1 << 32` se
desborda a **0** y `nextInt(0)` lanza `RangeError`. La app arrancaba y se
quedaba para siempre en la pantalla de carga.

**Cómo apareció.** No lo detectaron los 88 tests, porque corren en la VM. Lo
detectó levantar la build web en un navegador de verdad.

**Corrección.** La cota es ahora el literal `0x7FFFFFFF`, que se comporta igual
en las dos plataformas. Hay un test de regresión que verifica que la semilla
siempre queda en rango.

**Lección aplicada.** No usar operadores de bits sobre constantes cercanas a
2^31/2^32 en código que pueda compilarse a web.

---

## D-023 — La app nunca se queda en la pantalla de carga

**Decisión.** `GameController._load()` atrapa cualquier excepción del
almacenamiento y arranca una partida nueva en memoria. El autoguardado usa
`flushQuietly()`, que no propaga errores.

**Por qué.** El fallo de D-022 dejó la app colgada en el spinner, sin nada en
pantalla y sin forma de avanzar. Da igual la causa —disco lleno, permisos,
plataforma sin soporte, save ilegible—: es preferible jugar sin guardar que no
arrancar. Perder el progreso es malo; una app que no abre es peor.

---

## D-024 — Regla de ProGuard para Play Core

**Bug encontrado y corregido.** El primer build de release en CI falló:

> `ERROR: R8: Missing class com.google.android.play.core.splitcompat.SplitCompatApplication`

El embedding de Flutter referencia Play Core para *deferred components*, pero
la app no usa esa función y por lo tanto no incluye la librería. R8 aborta al
encontrar las referencias colgando.

**Corrección.** `-dontwarn com.google.android.play.core.**` en
`android/app/proguard-rules.pro`. Se prefiere `-dontwarn` a agregar la
dependencia: no la necesitamos y engordaría el AAB.

**Nota.** Este es exactamente el riesgo que D-013 anticipaba al activar R8 sin
poder compilar localmente, y es el motivo por el que CI compila el release en
cada push.

---

## D-025 — Existe una build web, sólo para demos

**Decisión.** Se agregó la plataforma web. **No es un objetivo de release**: la
plataforma de producción sigue siendo Android.

**Por qué.** Sin Android SDK en el entorno de desarrollo, la build web es la
única forma de ejecutar el juego de verdad y verificar que el loop funciona en
un navegador real. Encontró dos bugs (D-022 y el tercer pedido fuera de
pantalla) que ninguna cantidad de tests unitarios habría encontrado. Además
permite mandarle a alguien un link para probar sin instalar nada.

**Detalles.**
- Hay que compilar con `--no-web-resources-cdn`: si no, Flutter descarga
  CanvasKit de `gstatic.com` y la app no arranca en redes que lo bloqueen.
- En web el save usa `localStorage` (`save_store_web.dart`), elegido por
  import condicional. En móvil sigue siendo un archivo.

---

## D-026 — Los efectos de sonido se generan, no se descargan

**Decisión.** Los 10 efectos son originales, sintetizados por
`tools/generate_sounds.py`, que vive en el repositorio.

**Por qué.** D-015 dejó el juego sin audio porque no había SFX con licencia
verificada, y el brief exige documentar la procedencia de cada asset. Generar
los sonidos resuelve las dos cosas de una vez: son inequívocamente nuestros y
cualquiera puede regenerarlos para comprobarlo. Además pesan 116 KB en total,
frente a los megas que suele traer un pack comercial.

**Diseño sonoro.** Notas cortas de una escala pentatónica mayor (seno más el
segundo armónico, ataque de 4 ms y caída exponencial). La pentatónica no tiene
intervalos disonantes: encadenar fusiones rápido suena como una melodía que
sube, nunca a ruido. El tono sube con el nivel resultante y el nivel máximo de
una cadena tiene un acorde propio, para que el logro se oiga distinto.

**Implementación.** `audioplayers` con un pool de 4 reproductores en
round-robin, porque fusionar rápido dispara sonidos solapados y un único
reproductor cortaría el anterior en cada toque. Cualquier fallo de audio se
traga: si el dispositivo no puede reproducir, se juega en silencio.

**Verificado:** `audioplayers_android` no agrega ningún `uses-permission`, así
que el manifest sigue sin permisos y la declaración de Data Safety no cambia.

> Actualización: esto siguió siendo cierto hasta **D-038**, que agrega el
> plugin de avisos y con él los dos primeros permisos de la app. El audio
> sigue sin aportar ninguno.

---

## D-027 — Correcciones del primer playtest

Primera sesión de juego real del owner. Lo que salió y qué se hizo:

| Reporte | Diagnóstico | Estado |
|---|---|---|
| El aviso tapa la caja del proveedor y el botón de vender | El `SnackBar` flotante se dibuja sobre la barra inferior | **Corregido**: los avisos se levantan por encima de la barra |
| Cambiar un pedido cambia los tres | **Bug real**: se quitaba el pedido de la lista y el nuevo se agregaba al final, así que los otros dos se corrían de posición | **Corregido**: el pedido nuevo ocupa la misma posición. Vale también al entregar. Con tests de regresión |
| No se escuchan sonidos | Correcto: no había ninguno (D-015) | **Corregido** en D-026 |
| Que salga un "+N" al ganar monedas | — | **Agregado**: sube y se desvanece bajo el contador, sin interceptar toques y respetando "reducir animaciones" |
| Avisar cuando alcanza para mejorar el local | — | **Agregado**: punto verde en el ícono del local. Se eligió un indicador pasivo y no un aviso modal, para no interrumpir la partida |

El bug de los pedidos es el más importante de los cinco: rompía la confianza en
el botón de cambiar pedido, que es una decisión que cuesta monedas.

---

## D-028 — Comprar mercadería: precio por sobre lo que paga el pedido

**Decisión.** Se puede comprar un producto ya hecho, pero sólo de un nivel que
el jugador **ya produjo alguna vez**, y a **2,2× su valor**.

**Por qué ese precio.** Es la única cifra que importa acá. La recompensa de un
pedido es 1,6× el valor del producto; si comprar costara menos que eso, la
jugada óptima sería comprar y entregar en bucle, y fusionar —que *es* el
juego— dejaría de tener sentido. A 2,2× comprar siempre deja pérdida frente al
pedido: es un atajo de conveniencia cuando te falta un producto, y un sumidero
de monedas. Nunca una fuente de ganancia.

Hay un test que verifica `buyPrice(n) > orderReward(n)` para todos los niveles.
Un cambio de balance que lo rompa falla en CI.

**Por qué sólo niveles ya descubiertos.** El mercado acompaña al progreso, no
lo saltea: no se puede comprar el nivel 5 en el minuto uno.

---

## D-029 — Separar productos: la operación inversa de fusionar

**Decisión.** Pagando una comisión, un producto de nivel n se separa en dos de
nivel n−1. Requiere una casilla libre.

**Por qué es seguro para la economía.** Separar deshace exactamente lo que hizo
fusionar, así que no crea valor: quien separa y vuelve a fusionar termina con
el mismo objeto y **menos** monedas. Hay un test que lo comprueba. Sirve para
lo que el jugador pidió: deshacer una fusión de más cuando un pedido pide el
nivel de abajo.

---

## D-030 — El tablero empieza chico y se amplía pagando

**Decisión.** Las partidas nuevas empiezan con 5 de las 8 filas. Cada fila
extra cuesta monedas, con precio creciente.

**Por qué.** Da un sumidero de monedas temprano y una sensación de progreso
que antes sólo daba el local. Las filas bloqueadas se muestran con candado en
vez de ocultarse: el jugador ve hasta dónde puede crecer.

**Lo importante de la migración.** A quien ya venía jugando **no se le quita
tablero**: su partida conserva las 8 filas. Reducirle el espacio en una
actualización sería quitarle progreso ya conseguido. Cubierto por un test
específico.

---

## D-031 — Ganancia pasiva en vivo, con decimales

**Decisión.** La ganancia por hora corre también mientras se juega, y el
contador de monedas muestra dos decimales que suben de forma continua.

**Cómo.** Un único camino, `_accrueIncome`, sirve para los dos casos: el latido
de un segundo mientras se juega y el cobro al volver después de un rato. La
fracción que todavía no llega a una moneda se guarda en `idleAccrued`, para que
el contador suba continuo y no a saltos.

**Por qué el latido no guarda.** Escribir el save una vez por segundo castiga a
los teléfonos de gama baja. No hace falta: el save guarda `lastIncomeAt`, así
que al volver a cargar se acredita igual todo el tiempo transcurrido. No se
pierde nada, sólo se acredita más tarde.

**Presentación.** El entero va grande y los decimales chicos y apagados: de un
vistazo se lee "820", pero se nota que la caja sigue trabajando. El separador
decimal sale del idioma (coma en español, punto en inglés), no hardcodeado.

---

## D-032 — Bonificación por rapidez, nunca castigo

**Decisión.** Cada pedido nace con una ventana de 5 minutos. Entregarlo dentro
paga 1,5×. **Los pedidos no caducan nunca**: pasada la ventana simplemente se
cobra lo normal y desaparece el contador.

**Por qué así y no un timer clásico.** El owner pidió timers; el brief advierte
que la presión choca con "jugable en cualquier rato". Un premio por rapidez da
la misma urgencia que un reloj, pero guardar el teléfono a mitad de partida no
cuesta nada. Perder un pedido por cerrar la app sería exactamente el castigo
que el brief pide evitar.

Hay un test que entrega un pedido **una semana después** y verifica que sigue
pagando.

---

## D-033 — La hoja de acciones se abre con un toque, no manteniendo presionado

**Decisión.** Tocar una ficha abre sus acciones (separar / vender).

**Por qué no long press.** Se probó y se descartó: mantener presionado compite
con el arrastre —quien duda un momento antes de arrastrar termina abriendo un
menú en vez de fusionar— y además es mucho menos descubrible. El toque sólo se
confunde con el arrastre si el gesto es más corto que el umbral del sistema, y
con celdas de ~50 px eso no pasa en un teléfono real.

**Lo que lo destapó.** Los tests de widget corrían en la ventana por defecto de
`flutter_test`, 800×600, casi apaisada: ahí el tablero quedaba con celdas de
**18 px** —por debajo del mínimo táctil de 48 dp que la app promete— y los
arrastres eran tan cortos que competían con el toque. Los tests ahora corren a
393×851, la forma en que el juego se usa de verdad.

---

## D-034 — Las cadenas no tienen todas la misma cantidad de niveles

**Decisión.** Se agregaron **Huevos (3 niveles)** y **Aseo (4 niveles)**, que se
desbloquean en niveles de jugador 4 y 6. El catálogo ya soportaba largo
variable; ahora se usa.

**Por qué.** Una cadena corta se completa rápido y da una sensación de logro
temprana; una larga sostiene el juego a la larga. Mezclarlas evita que todo el
catálogo se sienta igual y le da ritmos distintos al álbum. Además agregan
profundidad justo donde el juego se empezaba a aplanar: los niveles altos.

**Por qué no cigarrillos ni licores**, que era la propuesta original: suben la
clasificación de contenido en el cuestionario IARC, restringen inventario de
publicidad en varias redes, complican la distribución en mercados con reglas
estrictas sobre tabaco, y exigen caracterizar la edad de cada cliente para el
castigo por vender a un menor. A cambio dan exactamente lo mismo que huevos o
aseo: una cadena más. El razonamiento completo está en
`MONETIZATION_DESIGN.md` §7.

---

## D-035 — Entrega parcial con castigo, desde nivel 4

**Decisión.** Un pedido incompleto se puede entregar a medias. Paga la parte
proporcional **por 0,7**, así que completar el pedido siempre conviene. Se
desbloquea en nivel de jugador 4.

**Por qué existe.** En niveles altos un pedido puede pedir un producto caro que
el jugador no alcanza a juntar, y ese pedido queda ocupando un espacio para
siempre. Entregar la parte que sí tiene es mejor que quedarse mirándolo.

**Por qué no desde el principio.** El jugador nuevo tiene que aprender a
completar pedidos antes de que se le ofrezca una salida; si no, no aprende el
loop.

**Por qué el botón cambia en vez de agregarse.** La tarjeta mide ~118 px: no
cabe un segundo botón. "Falta" pasa a decir "Entregar parte" y se habilita.

---

## D-036 — El onboarding tiene "Siguiente", no sólo "Saltar"

**Decisión.** El banner del tutorial ahora tiene "Siguiente" además de
"Saltar".

**Por qué.** El tutorial avanza solo cuando el jugador hace la acción que se le
pide, que es lo correcto para aprender jugando. Pero quien ya entendió —o
quien prefiere leerlo todo de corrido antes de jugar— quedaba con una sola
salida: saltarse el tutorial completo. Ahora puede pasar de paso en paso.

---

## D-037 — La ganancia se acumula en una caja con tope

**Decisión.** La ganancia pasiva ya no se acredita sola: se junta en una
**caja** que el jugador cobra con un toque, y que **deja de acumular al
llenarse**. La capacidad son horas de ganancia, ampliables pagando.

**Por qué el tope.** Sin él, el dinero se junta para siempre y volver da lo
mismo hoy que en una semana. Con tope, dejar el almacén lleno es perder
ganancia, y eso es una razón concreta —y honesta— para volver. Es también lo
único que hace que la notificación tenga algo real que decir.

**Por qué cobrar es un gesto y no automático.** El gesto de cobrar es medio
punto del bucle: el número sube solo, se toca, y las monedas saltan con el
"+N". Acreditarlo en silencio desperdicia ese momento.

**Dónde va.** Sobre la fachada del local, no en la barra superior: ahí está la
caja en la ficción, y la barra ya tenía cinco elementos.

**Interacción que hubo que cuidar.** La plata guardada en la caja **no** cuenta
como jugada posible: si el jugador se queda sin monedas y sin mercadería, el
rescate del proveedor tiene que saltar igual aunque la caja esté llena, o
quedaría mirando la pantalla. Cubierto por test.

**Corregido en la verificación en navegador.** El aviso de vuelta ("mientras no
estabas se juntaron N monedas") se disparaba mirando el **saldo** de la caja y
no lo que se había juntado durante la ausencia. Con la caja como concepto nuevo
eso pasó a ser mentira: quien cerraba el juego sin cobrar veía el aviso en cada
apertura, aunque volviera a los diez segundos. Ahora el evento lleva dos
números, `earned` —lo único que se puede afirmar— y `total`, y el aviso solo
sale si `earned` supera el mínimo. Cuando el botón cobra más que lo de esa
ausencia, una segunda línea lo explica en vez de dejar dos cifras que parecen
contradecirse. Los tests no lo veían porque todos partían con la caja vacía;
ahora hay dos que parten con saldo.

---

## D-038 — Aviso local de "caja llena", opt-in

**Decisión.** Un aviso local cuando la caja se llena. Viene **apagado**, se
enciende en Ajustes, y encenderlo pide el permiso del sistema.

**Local, no push.** Se programa en el propio teléfono. No hay servidor, ni
token, ni nada que salga del dispositivo: el Data Safety sigue diciendo que no
se recolectan datos.

**Lo que cambió y hay que declarar:** la app pasa de **cero permisos** a
declarar `POST_NOTIFICATIONS` (runtime, Android 13+) y `VIBRATE` (normal), que
aporta el plugin. Documentado en `SDK_INVENTORY.md`.

**Programación inexacta a propósito.** Los avisos exactos exigen
`SCHEDULE_EXACT_ALARM`, que Play restringe a apps de alarmas y recordatorios.
Para esto no hace falta que llegue al segundo.

**Tres cosas que costó el plugin, y que sólo se ven al compilar de verdad.**

1. *Desugaring de la biblioteca base.* El plugin usa `java.time`, que en
   `minSdk 24` no existe, así que exige `isCoreLibraryDesugaringEnabled`. Sin
   eso el build de release muere en `checkReleaseAarMetadata`. No se podía
   detectar acá —este entorno no tiene el SDK de Android— y lo encontró CI. La
   versión de `desugar_jdk_libs` la fija el plugin: 2.1.4.
2. *Ícono propio, monocromo.* Android dibuja el ícono de la barra de estado
   como **silueta**: usa sólo el canal alfa y pinta de blanco lo que no es
   transparente. El ícono del lanzador, que es a color, se habría visto como un
   cuadrado blanco. Se dibujó `ic_notification.xml`: la fachada del almacén en
   blanco sobre transparente, que a 18 dp todavía se lee.
3. *Protegerlo del shrinker.* El ícono se nombra desde Dart, como texto, así
   que `shrinkResources` no ve la referencia y lo borraría. Y el modo de falla
   es silencioso: sin recurso, el aviso simplemente **no aparece nunca**. Lo
   fija `res/raw/keep.xml`.

**Y una cosa que el plugin destapó de antes.** `resourceConfigurations = ["es"]`
venía de cuando la app era sólo para Chile: podaba los recursos de cualquier
otro idioma. Con distribución global es sencillamente incorrecto, así que se
quitó. La poda por idioma la hace Play con los splits del `bundle`, que le
entregan a cada teléfono sólo el suyo.

**Limitación aceptada:** sin `RECEIVE_BOOT_COMPLETED`, un reinicio del teléfono
antes de que la caja se llene pierde ese aviso. Recuperarlo costaría otro
permiso y un receptor de arranque, para una comodidad.

**Si el usuario niega el permiso, el interruptor no queda encendido.** Dejarlo
prendido cuando Android no va a mostrar nada sería mentirle.

**El mensaje es funcional**, nunca con culpa: "Tu almacén dejó de vender. Pasa
a cobrar." Nada de "tu kiosko te extraña".

---

## D-039 — Pulido de plataforma que faltaba

Tres cosas que no se habían hecho y que se notan en un teléfono real:

**Arranque sin destello blanco.** El fondo que Android muestra mientras arranca
el proceso estaba en blanco (el default del template). Ahora va en el crema del
juego, con variante para modo oscuro. Un destello blanco en cada arranque es de
las cosas que más hacen sentir barata una app.

**Barras del sistema.** Con `targetSdk 36`, Android 15+ dibuja la app detrás de
las barras se pida o no. Se declara `edgeToEdge` explícitamente y se fuerzan
íconos oscuros: sobre el crema del juego, los blancos por defecto quedaban
invisibles.

**Respaldo declarado.** Se agregaron reglas explícitas de respaldo. Además de
quitar ambigüedad, tiene una consecuencia concreta: **el progreso vuelve solo
al restaurar un teléfono nuevo**, que es la mitad del problema que resolvería
un login, sin backend.

---

## D-040 — Íconos de mercadería más grandes

**Decisión.** El ícono de cada ficha pasó de 0,46 a 0,58 del alto de la celda,
y la insignia de nivel se achicó un poco.

**Por qué.** En un teléfono real la ficha mide ~50 px: con el ícono al 46% del
alto, distinguir una botella de un pan a simple vista costaba más de lo que
debería en un juego que se basa justamente en reconocer pares rápido.

---

## D-020 — El build de AAB no pudo verificarse en el entorno de desarrollo

**Situación, no decisión (resuelta).** `flutter analyze`, `dart format` y los
88 tests se ejecutaron y pasan localmente. **`flutter build appbundle` no se
pudo ejecutar en el entorno de desarrollo**: bloquea `dl.google.com` a nivel de
red, que es de donde se descarga el Android SDK.

**Estado actual: verificado.** CI compila el AAB y el APK de release en verde
(corrida 3). El pipeline de release funciona de punta a punta.

**Qué se hizo en su lugar.** El job `build` de CI compila el AAB en GitHub
Actions, donde el SDK de Android ya está instalado. La primera corrida de CI es
la que confirma que el release compila.

**Qué pasó.** La primera corrida de CI **falló** por lo que predecía D-013: R8
y las clases de Play Core. Corregido en D-024, y desde entonces el AAB y el APK
compilan en verde. Es la justificación práctica de compilar el release en CI en
vez de asumir que compila.

---

## D-041 — Deshacer la última jugada

**Decisión.** Un botón "deshacer" que aparece sobre la barra inferior después
de vender, fusionar, separar, comprar o cambiar un pedido. Dura seis segundos o
hasta la jugada siguiente, lo que pase primero.

**Por qué esto y no confirmaciones.** Es la queja mejor documentada del género.
Varios juegos de fusionar tienen artículo de soporte propio titulado "vendí un
objeto sin querer", y "es demasiado fácil fusionar sin querer" aparece una y
otra vez en sus foros. La industria ya convergió en la solución: un botón que
se ofrece unos segundos y desaparece con la jugada siguiente. Un diálogo de
confirmación estorbaría mil veces para salvar una, y en un juego cuyo bucle es
tocar y arrastrar sería insoportable.

**Por qué no es un `SnackBar`.** Fusionar es el bucle principal. Un aviso de
ancho completo en cada fusión taparía el tablero todo el tiempo. El chip es
chico, va a un costado y no estorba.

**Por qué sale gratis de implementar.** El motor es un reducer puro: deshacer
es quedarse con el estado anterior y volver a ponerlo. No hay que escribir la
inversa de cada acción, que es donde esto se suele complicar.

**Tres cosas que hubo que cuidar, todas con test propio:**

1. *El reloj no vuelve atrás.* Al restaurar se conservan `idleAccrued`,
   `lastIncomeAt` y `lastSeenAt` del estado actual. Sin eso, deshacer sería una
   máquina de rehacer tiempo. Ninguna acción que toque la caja es deshacible,
   así que copiar esos campos es seguro.
2. *El latido de la ganancia no cierra la ventana.* Corre una vez por segundo;
   si contara como jugada, deshacer duraría menos de un segundo.
3. *Si tuvo que saltar el rescate del proveedor, no se ofrece.* Deshacer
   devolvería al jugador al estado sin salida y el rescate saltaría otra vez.

**El álbum no retrocede.** Descubrir un producto no es un recurso explotable, y
borrar una casilla recién marcada se siente a castigo por arrepentirse.

**Se mide.** El evento `action_undone` registra qué se deshace. Si una acción
se deshace mucho, es que se dispara sin querer y hay que revisar su gesto —no
culpar al jugador.

---

## D-042 — Personalización del local

**Decisión.** El jugador le pone **nombre** a su almacén y elige el **color del
toldo**. El nombre va en el letrero de la fachada y en la pantalla del local.

**Por qué.** Es lo tradicional del género de administración, y es lo más barato
que existe en términos de apego: un local que se llama como uno quiso deja de
ser "el juego" y pasa a ser "mi almacén". No toca ninguna regla ni la economía.

**Dónde vive.** En `GameSettings`, no en `GameState`: no cambia ninguna regla, y
`fromJson` rellena lo que falte, así que **no hizo falta migrar el esquema** —
una partida vieja se lee tal cual y ve los valores por defecto.

**Se guarda el índice del color, no el color.** Así retocar la paleta no deja
saves apuntando a un color que ya no existe. El índice 0 es el toldo de
siempre: quien no elija nada ve el juego igual que antes.

**El selector no depende sólo del color.** La opción activa lleva un visto
bueno, y cada color tiene nombre leído por el lector de pantalla. Es la guía de
accesibilidad de juegos —ninguna información esencial en un color y nada más—
aplicada al propio selector de colores, que es donde más fácil se olvida.

---

## D-043 — Tema oscuro y tamaño de texto

**Decisión.** Tema claro/oscuro/según el teléfono, y un multiplicador de texto
propio de la app.

**Lo que costó, y por qué se hizo igual.** La app tenía unos setenta colores
fijos repartidos por los widgets. Se movieron a un `ThemeExtension`
(`KioskoPalette`) que el widget lee con `context.palette`. Se **quitaron** los
campos estáticos viejos a propósito, para que el compilador señalara cada sitio
sin migrar: un tema oscuro al que se le escapan cinco pantallas es peor que no
tener tema oscuro.

**Dos familias de color.** Las constantes `brand*` son lo que está *dibujado*
—la fachada, las insignias con texto blanco encima— y no cambian con el tema:
un dibujo no se invierte porque el teléfono esté en oscuro, y una insignia
verde que se aclarara dejaría su texto blanco ilegible. Todo lo demás —fondos,
textos, tarjetas, bordes— sale de la paleta.

**Oscuro cálido, no gris.** El juego pasa dentro de un almacén de madera; un
gris azulado lo convertiría en otra cosa. Los acentos se aclaran respecto del
tema claro porque el mismo marrón sobre fondo oscuro queda por debajo del
contraste mínimo.

**El contraste está en los tests.** Hay un test que calcula la razón de
contraste de texto principal, secundario y acento contra su fondo en los dos
temas, y exige WCAG AA. Un cambio de paleta que rompa la legibilidad falla en
CI en vez de llegar al teléfono.

**El tamaño de texto se suma al del sistema, con techo.** Existe además del
ajuste de Android porque mucha gente no sabe que ese ajuste existe. El techo se
calcula sobre el **producto** de los dos y no sobre cada uno: quien ya tiene el
teléfono en letra grande y además sube el de la app llegaría a un tamaño donde
el tablero expulsa las etiquetas de los pedidos.

**La barra de estado sigue al tema.** Antes se fijaba una sola vez al arrancar,
con íconos oscuros. En modo oscuro quedaba negro sobre negro.

---

## D-044 — El juego se ponía lento: dos causas, ninguna del teléfono

Reporte del owner: "después de jugarlo un rato se vuelve lento; tengo un S24+ y
aún así los sonidos se desfasan". Un teléfono así no debería sufrir con este
juego, así que el problema era del código. Eran dos cosas.

**1. Cada efecto de sonido volvía a preparar su archivo.** Se llamaba
`player.play(AssetSource(...))`, que hace tres saltos al canal nativo —volumen,
fuente y reproducir— **más un `prepare` del archivo, cada vez**. La propia
documentación de `audioplayers` lo dice: para bajar la latencia hay que llamar
`setSource` antes y `resume` por separado.

Encadenando fusiones, esas llamadas se acumulaban en la cola del canal más
rápido de lo que se resolvían. Los sonidos llegaban tarde —el síntoma que se
oye— y, como el canal de plataforma es el mismo que usa todo lo demás, la app
entera se iba poniendo lenta a medida que la sesión avanzaba. Eso explica por
qué empeoraba con el tiempo y no desde el principio.

Ahora hay **un reproductor por sonido**, con su archivo y su volumen puestos
una sola vez al arrancar, y reproducir es una llamada. Además hay un freno de
60 ms por efecto: dos disparos del mismo sonido más juntos que eso no se
distinguen de uno, y descartarlo evita que una ráfaga inunde el canal.

**2. La pantalla entera se rehacía una vez por segundo.** Un `Timer.periodic`
aplicaba una acción al motor para mover el contador de la caja y hacía
`setState`. Eso reconstruía barra superior, fachada, tres tarjetas de pedido y
cuarenta y ocho casillas —sesenta veces por minuto— para mover dos decimales.

El contador ahora es una **función pura**: `tillAmountAt(state, now)` calcula lo
que hay en la caja sin tocar el estado, y un `GameClock` late una vez por
segundo repintando sólo a quien lo escucha —la caja y los cronómetros de los
pedidos—. El motor dejó de enterarse de que pasa el tiempo, y el save tampoco
cambia: `lastIncomeAt` es el ancla, así que al cobrar o al volver se acredita
igual todo lo transcurrido.

**Lección.** Ninguna de las dos se ve en los tests: la primera es de canal
nativo y la segunda es de rendimiento, no de resultado. Se encontraron leyendo
el código con el síntoma en la mano.

---

## D-045 — Deshacer: flotante y con comisión

**Dos correcciones a D-041**, ambas por reporte del owner.

**Movía la pantalla.** El chip vivía dentro de la columna, así que aparecer y
desaparecer le quitaba y le devolvía alto a todo lo de arriba: el tablero daba
un salto en cada jugada. Ahora flota en el `Stack`, encima del tablero, y el
layout no se entera. Hay un test que compara el rectángulo del tablero antes y
después de que aparezca el botón.

**Se ofrecía gratis.** Ahora cuesta una cantidad chica y fija, escrita en el
propio botón. No es un castigo por equivocarse —sería mezquino cobrar por
arrepentirse— sino lo que impide usarlo como una jugada más: probar una fusión,
mirar el resultado y volver atrás las veces que uno quiera. Con la comisión, el
ciclo vender-deshacer es estrictamente perdedor, y hay un test que lo fija.

**Y colisionaba con los avisos.** El aviso de "vendido por N" salía en el mismo
lugar y tapaba el botón justo en el segundo y medio en que el jugador se da
cuenta de que no quería vender. El botón se subió por encima de esa franja
(`AppTheme.toastLane`).

---

## D-046 — Que parezca un almacén y no una planilla

Reporte del owner: "en este minuto parece un juego de matemáticas". Tenía
razón, y la causa era concreta: **todo lo que identificaba a un producto o a un
cliente era texto y números.**

**El pedido ahora muestra la ficha, no su nombre.** Cada línea lleva la misma
pieza que hay que juntar —mismo color, mismo ícono, mismo número de nivel— en
miniatura. Antes había que leer "Botella grande" y traducirlo mentalmente a
cuál de las casillas de la grilla era; ahora el ojo hace la comparación sin
pensar. Esto también resuelve que los niveles no se entendieran en los pedidos:
el número está donde uno lo busca, sobre la pieza.

**Los clientes tienen cara.** Dibujada en código y derivada de su id, así que
el mismo cliente se ve siempre igual: si cambiara en cada pedido no sería
nadie. Seis tonos de piel, doce camisas y seis peinados — los clientes de un
almacén de barrio son el barrio.

**Entregar es un momento.** Al entregar, el cliente se acerca al mesón, se ve
lo que se llevó y agradece. Antes entregar era un número que subía y una
tarjeta que se reemplazaba: correcto y completamente frío. El remate del bucle
es lo que separa atender un almacén de hacer una suma.

---

## D-047 — Ordenar, y la mejora que lo deja gratis

**Ordenar** acomoda la mercadería por cadena y, dentro de cada una, de mayor a
menor nivel: los que están a un paso de fusionarse quedan juntos y a la vista,
que es lo que uno busca al tocar el botón.

**Cuesta muy poco a propósito.** Es una ayuda de comodidad, no una decisión
económica. Si costara de verdad, el jugador se pondría a ordenar a mano para
ahorrar —exactamente el trabajo aburrido que el botón viene a sacar—. Y si ya
está ordenado no cobra nada: se rechaza la acción.

**La mejora "ordenar gratis"** cuesta la mitad de lo que cuesta subir el local
al siguiente nivel. Se cotiza contra el nivel siguiente y no contra un número
fijo para que acompañe al progreso: temprano es una compra chica y accesible, y
a quien ya tiene un local grande le sigue pareciendo un gasto menor frente a lo
que maneja. En el último nivel, donde ya no hay salto siguiente, se cotiza
contra el último que hubo — si no, saldría gratis justo cuando el jugador tiene
más monedas.

---

## D-048 — Al arrastrar se ve qué va a pasar

Antes, arrastrar una ficha sobre otra era una apuesta: si eran iguales se
fusionaban y si no, se intercambiaban, pero el jugador se enteraba **después**
de soltar.

Ahora la casilla de destino se marca en **verde con un visto** si se va a
fusionar, y en **rojo con dos flechas** si sólo se van a intercambiar. El
símbolo acompaña al color a propósito: "verde o rojo" no le dice nada a quien
no los distingue, que es la misma regla que rige el resto del juego.

La ficha levantada además crece y se corre hacia arriba: el dedo la tapa, y si
no sobresale el jugador no ve qué está moviendo.

La regla que decide el color es la misma que aplica el motor, para que lo que
se ve prometido sea exactamente lo que ocurre.

---

## D-049 — La fachada, por capas y con progresión real

Pedido del owner: gráfica mucho más realista, y que cada nivel del local
muestre una mejora clara.

**Lo segundo se hizo entero.** La fachada se pinta por capas —cielo, vecinos,
muro, letrero, toldo, vitrina, estantes, mesón, vereda, clientes, luz— y cada
capa consulta el nivel para decidir si aparece. Subir de nivel deja de ser "lo
mismo pero más grande": entran elementos nuevos, hasta el gato del almacén en
el nivel 6. En modo oscuro la escena pasa a ser de noche, con la vitrina
iluminada desde adentro. El detalle nivel por nivel está en `ART_DIRECTION.md`.

**Sobre lo primero hay que ser franco.** Esto no va a verse como Clash of
Clans, y no es cuestión de dedicarle más horas: esa gráfica es ilustración
profesional, con horas de pintura por elemento. Lo que el código puede dar es
una escena vectorial limpia y legible, que es lo que hay. `ART_DIRECTION.md`
deja escritas las tres opciones reales para arte encargado, lo que implica cada
una, y por qué **no** se generó arte con IA por cuenta propia: es una decisión
con consecuencias legales y de marca que le toca al dueño del proyecto.

**La arquitectura queda lista para el cambio.** El painter es el respaldo:
meter ilustraciones es hacer que `Storefront` busque primero un asset por nivel
y sólo caiga al painter si no existe. No toca el motor, ni el save, ni la
lógica.

**Tres errores de dibujo que sólo se vieron mirando.** Se armó una hoja de
contacto con las siete fachadas en claro y oscuro, y ahí aparecieron: las ondas
del toldo abombaban hacia arriba en vez de colgar, los clientes eran una
campana con un punto por cabeza, y la bicicleta caía justo encima de un
cliente. Los tres se corrigieron; ninguno lo habría detectado un test.

---

## D-050 — El pedido mayorista

Cada cuatro horas aparece un pedido grande que dura diez minutos y paga por
encima de lo proporcional.

**Es el único pedido que caduca**, y eso contradice en apariencia la regla de
que los pedidos no vencen (D-030). No la contradice: esa regla existe para no
castigar a quien guarda el teléfono a mitad de partida, y perder el mayorista
**no le quita nada** al jugador — sigue con sus monedas, su mercadería y sus
tres pedidos. Es una oportunidad extra, no una obligación. Un pedido normal que
venciera sí sería un castigo, porque ocupa un cupo que el jugador estaba
trabajando.

**No ocupa un cupo.** Va en una banda propia sobre los tres pedidos normales.
Como cuarta tarjeta habría dejado las cuatro tan angostas que no se leería
ninguna, y además se leería como "un pedido más", que es lo contrario de lo que
es.

**No se puede cambiar.** Pagar unas monedas por otro mayorista sería comprar el
evento, y dejaría de ser un evento.

**Diez minutos y no dos.** Corto de verdad —es lo que lo hace un evento— pero
suficiente para alguien que abrió el juego mientras hace otra cosa. Dos minutos
sólo premiarían a quien está mirando la pantalla, que es exactamente el jugador
que el brief pide no privilegiar.

**Cómo entra en escena sin un latido.** `refreshBigOrder` se llama en cada
acción del jugador y al volver a la app, no una vez por segundo: eso habría
reintroducido el problema de rendimiento de D-044. El reloj de la pantalla
también lo llama, pero **sólo cuando la hora ya pasó**, no en cada tic.

---

## D-051 — Logros

Diecisiete logros en escaleras —fusionar, rachas, entregar, mayoristas, nivel
del local, álbum, caja— cada uno con premio en monedas.

**El premio se cobra a mano y no se acredita solo.** El momento de tocar
"cobrar" y ver subir las monedas *es* el logro; acreditarlo en silencio
mientras el jugador mira otra cosa lo desperdicia.

**La racha mira la mejor, no la actual.** Si mirara la actual, conseguir "cinco
seguidas" dependería de acordarse de abrir la pantalla antes de tocar cualquier
otra cosa. Se guarda `bestMergeStreak` y el logro se compara contra ésa.

**Escaleras, no logros sueltos.** Un logro suelto se consigue una vez y se
olvida; 10 → 100 → 500 fusiones acompaña toda la partida. Los premios crecen
más rápido que las metas para que el último escalón siga valiendo algo cuando
el jugador ya maneja miles de monedas — hay un test que lo verifica.

**Se guardan ids, no índices.** Agregar o reordenar logros no puede devolverle
a nadie un premio ya cobrado.

**Lo que pidió el owner y todavía no existe.** Invitar amigos, cambiarse de
barrio y contratar un locatario dependen de funciones que no están construidas.
`Achievements.reservedFamilies` deja los prefijos reservados y documentado qué
falta para cada uno, para que agregarlos sea sumar una fila.

**Y a quien ya venía jugando se le respeta lo hecho.** `totalMerges` y
`totalOrdersCompleted` ya se guardaban, así que al actualizar sus logros de
fusiones y pedidos aparecen listos para cobrar. La racha arranca en cero porque
nunca se midió, y no se puede inventar.

---

## D-052 — Por qué NO se hizo el deslizar estilo 2048

El owner lo propuso y él mismo marcó la duda: "esto quizás complejiza demasiado
el juego".

**Es un juego distinto, no un control distinto.** En 2048 todas las fichas se
deslizan y se fusionan a la vez: el jugador piensa en el estado del tablero
completo. En un juego de fusionar, elige un par concreto. Poner los dos gestos
juntos no suma una alternativa: convierte cada deslizada en una jugada masiva
que puede fusionar justo las dos piezas que el jugador estaba guardando para un
pedido.

**Lo que el pedido buscaba sí se atendió, por otro camino.** La molestia real
detrás de "quiero deslizar" es tener que apuntar con precisión. Eso se resolvió
en D-048 —la ficha levantada crece y asoma sobre el dedo, y la casilla de
destino dice en verde o rojo qué va a pasar antes de soltar— y en D-047, con el
botón de ordenar, que junta lo fusionable sin arrastrar nada.

**Queda anotado, no descartado.** Si en un playtest la gente sigue pidiendo
deslizar, la forma segura de probarlo es como ajuste opcional apagado por
defecto, nunca reemplazando el arrastre. Deshacer (D-045) ya cubre el
arrepentimiento de una deslizada masiva.

