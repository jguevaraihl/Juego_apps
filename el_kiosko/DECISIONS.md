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

## D-019 — Sólo español (es-CL), sin framework de localización todavía

**Decisión.** Los textos están en español chileno, en el código. Existe
`lib/l10n/` vacío y `resourceConfigurations += listOf("es")` en Gradle.

**Por qué.** El lanzamiento es sólo Chile y el brief dice explícitamente no
expandir países por reflejo. Montar `flutter_localizations` + ARB ahora sería
infraestructura para una decisión que todavía no se toma. El costo de agregarlo
después es real pero acotado y localizado en los widgets.

**Cuándo reconsiderar.** En cuanto se decida un segundo país o idioma.

---

## D-020 — El build de AAB no pudo verificarse en el entorno de desarrollo

**Situación, no decisión.** `flutter analyze`, `dart format` y los 82 tests se
ejecutaron y pasan. **`flutter build appbundle` no se pudo ejecutar**: el
entorno donde se implementó esto bloquea `dl.google.com` a nivel de red, que es
de donde se descarga el Android SDK (`cmdline-tools`, `platforms;android-36`,
`build-tools`).

**Qué se hizo en su lugar.** El job `build` de CI compila el AAB en GitHub
Actions, donde el SDK de Android ya está instalado. La primera corrida de CI es
la que confirma que el release compila.

**Qué debe verificar el owner.** Que el job `build` pase en verde en la primera
corrida. Si R8 (D-013) diera problemas, la solución es poner
`isMinifyEnabled = false` en `android/app/build.gradle.kts`.
