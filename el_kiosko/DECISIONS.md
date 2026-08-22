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
