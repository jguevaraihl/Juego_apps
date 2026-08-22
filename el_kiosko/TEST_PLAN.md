# TEST_PLAN.md

Qué está cubierto automáticamente, qué hay que probar a mano, y qué no se pudo
verificar todavía.

Estado a **2026-08-22** · **92 tests** · `flutter analyze` sin issues.

---

## 1. Filosofía

No se persigue un porcentaje de cobertura. Se cubre:

1. **lógica de negocio** — economía, merge, pedidos, progresión;
2. **invariantes que, si se rompen, rompen el juego** — sin bloqueos, sin
   máquinas de monedas infinitas;
3. **regresiones caras** — pérdida del save del jugador.

---

## 2. Cobertura automática

| Archivo | Tests | Qué protege |
|---|---:|---|
| `test/economy_test.dart` | 14 | Valores, ventas, recompensas, curva de nivel, ganancia offline y los invariantes anti-exploit |
| `test/board_ops_test.dart` | 13 | Merge válido/inválido, mover, intercambiar, consumo atómico de pedidos, detección de jugadas |
| `test/game_engine_test.dart` | 32 | Generar, fusionar, entregar, reroll, vender, mejorar, subir de nivel, desbloqueos, ganancia offline, garantía de no bloqueo, rango de la semilla |
| `test/save_codec_test.dart` | 11 | Serialización completa, migraciones v0→v1→v2, saves corruptos, saves de versión futura, tablero truncado |
| `test/game_repository_test.dart` | 7 | Carga sin save, ida y vuelta, cobro offline al cargar, save corrupto, autoguardado con debounce, borrado |
| `test/widget/home_screen_test.dart` | 15 | Render del tablero, generar desde la UI, arrastre real que fusiona, entrega de pedido, onboarding, modo vender, navegación a la tienda, ajustes, álbum, aviso de ganancia offline, cambio de idioma |

### Los tests que más importan

**Garantía de no bloqueo** (`game_engine_test.dart`) — prueba de propiedad:
40 partidas × 400 acciones al azar, verificando en cada paso que existe jugada
posible y que las monedas nunca son negativas. Es la defensa del requisito
"el juego nunca debe quedar irrecuperablemente atascado".

**Invariante anti-exploit** (`economy_test.dart`) — `venta(1) < costo_generar`.
Si un futuro cambio de balance rompe esto, generar+vender se vuelve una máquina
infinita de monedas y CI falla antes del release.

**Migración de save** (`save_codec_test.dart`) — un save sin `schemaVersion`
(build vieja) se migra sin perder progreso; uno corrupto o de versión futura
devuelve `null` y arranca partida nueva en vez de crashear.

---

## 3. Mapa contra los "core tests" del brief (§19)

| Requisito del brief | Estado |
|---|---|
| Merge válido | ✅ |
| Merge inválido | ✅ (distinta cadena, distinto nivel, nivel máximo, índices inválidos) |
| Cálculo de recompensa | ✅ |
| Creación/completado de pedidos | ✅ |
| Serialización del save | ✅ |
| Migración del save | ✅ |
| Income offline | ✅ (incluye tope y reloj hacia atrás) |
| Comportamiento offline | ✅ por construcción: la app no tiene red en Fase 1 |
| Premium entitlement | ⛔ **N/A** — no hay billing en Fase 1 |
| Frecuencia de ads | ⛔ **N/A** — no hay ads en Fase 1 |

Los dos últimos son requisitos de **Fase 3**. Deben implementarse junto con sus
SDKs, no antes.

---

## 4. Pruebas manuales pendientes (Gate A y Fase 4)

### Dispositivo
- [ ] Instalar en un teléfono Android **de gama baja real** y medir arranque en frío
- [ ] Verificar que no haya jank perceptible al arrastrar con el tablero lleno
- [ ] Probar en pantalla chica (~5") y en pantalla grande
- [ ] Probar con el tamaño de fuente del sistema al máximo
- [ ] Probar en **modo avión** durante una sesión completa
- [ ] Matar la app desde el selector y confirmar que el progreso se conserva
- [ ] Cambiar la hora del teléfono hacia adelante y hacia atrás; confirmar que la ganancia offline se topa y no se puede explotar
- [ ] Verificar el ícono en el launcher, incluido un dispositivo API 24–25
- [ ] Probar el gesto de volver (predictive back)

### Playtest de Gate A (15–20 personas, varias de 30–60 años)
Registrar para cada participante:
- [ ] ¿entiende qué hacer sin explicación extensa?
- [ ] tiempo hasta el primer merge
- [ ] tiempo hasta el primer pedido completado
- [ ] **tiempo hasta la primera mejora del local** (objetivo: <5 min)
- [ ] duración de la sesión sin que se le pida seguir
- [ ] puntos de confusión (anotar textual)
- [ ] ¿quiere jugar una segunda vez?
- [ ] calificación subjetiva de diversión (1–5)
- [ ] problemas de legibilidad o de tamaño de botones

---

## 5. Verificación en navegador real

Además de los tests, el juego se ejecutó en Chromium (build web, 393×851) y se
jugó el loop completo con Playwright:

| Paso | Resultado |
|---|---|
| Arranque | Tablero, 3 pedidos y fachada renderizados, sin errores de consola |
| 14 toques a la caja del proveedor | 14 productos en el tablero, monedas 60 → 18 (14 × 3) |
| Arrastrar dos Marraquetas | Se fusionan en una Bolsa de pan (nivel 2); el tutorial avanza al paso 2 |
| Entregar el pedido | Monedas 60 → 73 (+13), aviso "¡Pedido entregado! +13", barra de XP avanza, aparece un pedido nuevo, tutorial al paso 3 |

Esto encontró **dos defectos que los tests no detectaron**:

1. `1 << 32` se desborda a 0 en la web y dejaba la app colgada en la pantalla de
   carga (DECISIONS D-022).
2. La tercera tarjeta de pedido quedaba fuera de pantalla en un teléfono
   angosto, incumpliendo el requisito de "3 pedidos visibles".

## 6. Build de release: verificado en CI

`flutter build appbundle` y `flutter build apk` **no** se pueden ejecutar en el
entorno de desarrollo (bloquea `dl.google.com`, de donde baja el Android SDK).
Los compila el job `build` de CI, y **están en verde**: el AAB y el APK de
release se generan y se publican como artifacts.

La primera corrida falló por R8 (clases de Play Core que el embedding de Flutter
referencia y esta app no usa); corregido con `-dontwarn` (DECISIONS D-024).

**Sigue sin verificarse en hardware real:** rendimiento, hápticos, íconos en el
launcher y arranque en frío en un teléfono de gama baja. Para eso está el APK
que genera CI (§4).

---

## 7. Cómo correr todo

```bash
cd el_kiosko
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build appbundle --release   # requiere Android SDK
```
