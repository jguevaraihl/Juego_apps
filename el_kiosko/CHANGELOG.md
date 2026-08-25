# CHANGELOG

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado: `versionName+versionCode` de `pubspec.yaml`.

## [Sin publicar]

### Agregado (cuarta tanda de playtest)
- **La caja tiene tope.** La ganancia por hora ya no cae directo en el bolsillo:
  se junta en la caja del local y se cobra tocándola en la fachada. La caja
  aguanta 4 horas al principio y se amplía hasta 14 con mejoras. Es el motivo
  honesto para volver: si no vuelves, la caja se llena y deja de juntar.
- **Aviso local cuando la caja se llena**, apagado por defecto. Se enciende en
  Ajustes, pide el permiso del sistema y **no queda encendido si lo rechazas**.
  El aviso se programa al salir del juego y se cancela al volver. No sale del
  teléfono: no hay servidor, ni push, ni cuenta.
- **Mejora de la caja** en la pantalla del local, con su propio costo y curva.
- **Ajustes ampliados**: sonido, vibración, reducir animaciones, avisos e
  idioma, todos en un mismo lugar y guardados en el save.
- **Íconos de mercadería más grandes** (de 0,46 a 0,58 del alto de la celda),
  con la insignia de nivel un poco más chica para que no compita.
- **Arranque sin destello blanco**: la pantalla de inicio de Android usa el
  crema del juego (y su variante oscura), con el ícono al centro.
- **Pantalla completa de borde a borde** y barra de estado transparente con
  íconos oscuros, en vez de la franja gris del sistema.
- **Reglas explícitas de respaldo de Android**: el save entra en la copia de
  seguridad y en la transferencia a un teléfono nuevo; nada más lo hace.
- `MONETIZATION_DESIGN.md` §7b: lo que queda guardado para cuando haya
  monetización — inicio de sesión y save en la nube, bonificación por invitar
  amigos, y la versión de iPhone — cada uno con lo que cuesta y qué hace falta
  antes.

### Corregido (cuarta tanda)
- **El build de release fallaba** al agregar el plugin de avisos: exige
  *desugaring* de la biblioteca base porque usa `java.time`, que no existe en
  Android 7. Lo detectó CI; no se puede compilar Android en el entorno de
  desarrollo.
- **El ícono del aviso se habría visto como un cuadrado blanco.** Android
  dibuja el ícono de la barra de estado como silueta, así que no puede ser el
  ícono del lanzador. Se dibujó uno monocromo con la fachada del almacén, y se
  lo protegió del *shrinker* —que lo habría borrado, dejando el aviso sin
  aparecer nunca y sin error visible.
- **El release podaba los recursos de todo idioma que no fuera español.**
  Quedaba de cuando la app era sólo para Chile.
- **El aviso de vuelta decía algo falso.** "Mientras no estabas se juntaron N
  monedas" se disparaba mirando el saldo de la caja, no lo que se había
  juntado durante la ausencia: quien cerraba el juego sin cobrar veía el aviso
  en cada apertura, aunque volviera a los diez segundos y no se hubiera
  juntado nada. Ahora el aviso cuenta solo lo de esa ausencia; si además había
  saldo sin cobrar, lo dice en una segunda línea y el botón cobra el total.
  Lo encontró la verificación en navegador, no los tests.

### Cambiado (cuarta tanda)
- El contador de monedas ya no sube solo con decimales: ahora sube la caja. Las
  monedas cambian cuando cobras, vendes o entregas — cada movimiento tiene una
  causa visible.

### Agregado (tercera tanda de playtest)
- **Dos cadenas nuevas con distinta cantidad de niveles**: Huevos (3) y Aseo
  (4), que se desbloquean en niveles de jugador altos. El álbum pasa de 15 a 22
  productos.
- **Entrega parcial** de un pedido incompleto, pagando menos de lo
  proporcional. Se desbloquea en nivel 4.
- **"Siguiente" en el onboarding**, además de "Saltar".
- `MONETIZATION_DESIGN.md`: diseño guardado de todo lo que depende de la
  monetización — menú de monedas, caja XL, segunda moneda, eventos de
  temporada, barrios — con la recomendación de no incluir alcohol ni tabaco y
  el motivo.

### Agregado (segunda tanda de playtest)
- **Comprar mercadería** ya hecha, de niveles que ya produjiste. El precio está
  siempre por encima de lo que paga un pedido de ese nivel: es un atajo, no una
  forma de ganar monedas.
- **Separar** un producto en dos del nivel anterior, pagando una comisión.
- **El tablero empieza con 5 de 8 filas** y se amplía pagando. Las filas
  bloqueadas se ven con candado. A quien ya venía jugando no se le quita
  tablero.
- **La ganancia por hora corre en vivo**: el contador de monedas sube con
  decimales mientras juegas.
- **Bonificación por rapidez**: entregar dentro de los primeros 5 minutos paga
  1,5×. Los pedidos **no caducan**; pasada la ventana se cobra lo normal.

### Corregido (segunda tanda)
- La barra inferior desbordaba al agregar el botón de comprar, y el contador de
  bonificación desbordaba la tarjeta de pedido. Ambos textos están ahora
  acotados a una línea.

### Agregado (primer playtest)
- **Efectos de sonido**, originales y generados por síntesis
  (`tools/generate_sounds.py`): aparición de mercadería, levantar una ficha,
  fusión con el tono subiendo por nivel, nivel máximo, cobro, venta y mejora
  del local. Se apagan desde Ajustes.
- **"+N" al ganar monedas**: sube y se desvanece bajo el contador. Respeta
  "reducir animaciones" y no intercepta toques.
- **Aviso de mejora disponible**: punto verde en el ícono del local cuando ya
  alcanzan las monedas para el siguiente nivel.

### Corregido (primer playtest)
- **Cambiar un pedido cambiaba los tres.** Se quitaba el pedido de la lista y
  el nuevo se agregaba al final, así que los otros dos se corrían de posición.
  Ahora el pedido nuevo ocupa el mismo lugar, tanto al cambiarlo como al
  entregarlo.
- **Los avisos tapaban la caja del proveedor y el botón de vender.** Ahora se
  levantan por encima de la barra inferior.

### Agregado
- **Internacionalización.** Español e inglés. La lógica de juego ya no contiene
  texto: guarda identificadores y la UI los traduce, así el mismo save se lee
  en cualquier idioma. Selector de idioma en Ajustes (por defecto sigue al
  sistema). Agregar un idioma es agregar un `.arb`.
- Build web, **sólo para demos**: permite probar el juego en el navegador sin
  instalar nada. La plataforma de release sigue siendo Android.
- CI ahora genera también un **APK instalable** y la build web como artifacts.

### Corregido
- **La app se colgaba en la pantalla de carga en web.** `1 << 32` se desborda a
  0 en JavaScript y `Random.nextInt(0)` lanzaba `RangeError`. La cota ahora es
  un literal que se comporta igual en la VM y en la web.
- **El build de release fallaba en R8** por clases de Play Core que el
  embedding de Flutter referencia y la app no usa. Se agregó `-dontwarn`.
- **La tercera tarjeta de pedido quedaba fuera de pantalla** en teléfonos
  angostos, incumpliendo el requisito de "3 pedidos visibles". Las tarjetas
  ahora reparten el ancho disponible.
- La app ya no puede quedarse en la pantalla de carga: si el almacenamiento
  falla, arranca una partida nueva en memoria en vez de esperar para siempre.

### Cambiado
- Distribución **global** en vez de sólo Chile. Se actualizaron el modelo de
  costos (comisión de Play por región), el checklist de publicación
  (información tributaria, ficha por idioma) y los documentos de privacidad
  (GDPR, UK GDPR, CCPA, LGPD).
- La moneda se muestra como "monedas"/"coins" en vez de "pesos".
- Los clientes pasaron de nombres muy locales a roles universales.
- Esquema del save a **v2**, con migración desde v1 (el nombre del cliente pasa
  a ser un índice).

### Pendiente antes de la primera subida a Play
- Confirmar el package name definitivo (hoy `cl.elkiosko.almacen`, placeholder)
- Generar y respaldar el keystore de upload
- Alojar la política de privacidad en una URL pública (es + en)
- Completar la información tributaria en Play Console
- Ejecutar Gate A (playtest con 15–20 personas)

---

## [0.1.0+1] — 2026-08-22

Primera versión: vertical slice jugable (Fase 0 + Fase 1 del plan).

### Agregado

**Juego**
- Tablero de 6×8 con arrastrar y soltar, sin restricción de adyacencia
- Fusión de productos iguales; intercambio cuando la fusión no es válida
- 3 cadenas de productos × 5 niveles (Panadería, Bebidas, Snacks)
- Caja del proveedor: genera mercadería a cambio de monedas
- 3 pedidos simultáneos con progreso en vivo, recompensa congelada y cambio de
  pedido con costo
- Pedidos especiales con bonus
- Vender excedente para liberar casillas
- 7 niveles de local, cada uno con fachada distinta dibujada en código
- Nivel de jugador con XP; desbloqueo de Snacks en nivel 2 y de niveles de
  pedido más altos según progreso
- Ganancia pasiva mientras la app está cerrada, con tope de 4 horas
- Álbum de productos descubiertos
- Onboarding de 3 pasos, saltable, que no bloquea la pantalla
- Sugerencia de jugada tras 12 segundos de inactividad
- **Garantía de no bloqueo**: si el jugador queda sin salida, el proveedor le
  fía monedas, gratis y sin anuncios

**Plataforma**
- Guardado local en JSON con escritura atómica y autoguardado con debounce
- Migraciones de esquema del save desde el día 1
- Ajustes: sonido, vibración, animaciones reducidas y sugerencias
- Accesibilidad: objetivos táctiles ≥48dp, `Semantics`, escalado de texto,
  identificación por color + forma + número + texto
- Ícono adaptativo y PNGs legacy para API 24–25
- `minSdk` 24, `targetSdk`/`compileSdk` 36 fijados explícitamente
- Firma de release desde `key.properties`, con fallback a debug
- R8 (`minifyEnabled` + `shrinkResources`) en release
- CI: formato, análisis, 82 tests y build de AAB

**Documentación**
- `DECISIONS.md`, `GAME_DESIGN.md`, `GAME_ECONOMY.md`, `TEST_PLAN.md`,
  `PLAY_STORE_CHECKLIST.md`, `DATA_INVENTORY.md`, `DATA_SAFETY.md`,
  `SDK_INVENTORY.md`, `PRIVACY_POLICY_DRAFT.md`, `COST_MODEL.md`,
  `ASSET_LICENSES.md`

### Deliberadamente ausente
Anuncios, compras dentro de la app, Firebase, login, notificaciones push,
backend y cualquier acceso a red. La app no declara el permiso `INTERNET` en
producción.

### Notas
- El build de AAB no se pudo verificar en el entorno de desarrollo porque
  bloquea `dl.google.com`; CI lo compila. Ver `DECISIONS.md` D-020.
