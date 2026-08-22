# El Kiosko — Almacén de Barrio

Juego móvil Android de *merge* y administración ligera: abasteces un almacén de
barrio chileno, juntas mercadería, completas pedidos y haces crecer el local.

**Estado: Fase 1 (vertical slice) completa. Pendiente Gate A (playtest).**

| | |
|---|---|
| Flutter | 3.47.1 (stable) · Dart 3.13.1 |
| Android | `minSdk` 24 · `targetSdk`/`compileSdk` 36 |
| Estado | 82 tests · `flutter analyze` sin issues |
| Red | **Ninguna.** Funciona 100% sin conexión |
| Monetización | **Ninguna todavía.** Sin ads, sin compras, sin SDKs |

---

## Empezar

```bash
cd el_kiosko
flutter pub get
flutter run
```

Verificación completa (lo mismo que corre CI):

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build appbundle --release   # requiere Android SDK
```

---

## Cómo se juega

Toca **la caja del proveedor** para que llegue mercadería, arrastra dos
productos iguales para juntarlos y súbelos de nivel, entrega los pedidos de
arriba y usa las monedas para mejorar el local. El almacén sigue vendiendo
mientras no juegas (hasta 4 horas).

---

## Arquitectura

La regla que ordena todo: **la lógica de juego es Dart puro y no sabe que
Flutter existe.** Por eso el 88% de los tests corre sin binding y sin disco.

```text
lib/
├── game/                    ← lógica pura, sin Flutter
│   ├── models/              ← producto, tablero, ficha, pedido, estado, ajustes
│   ├── board/board_ops.dart ← mover / fusionar / intercambiar / consumir pedido
│   ├── economy/             ← configuración de balance + fórmulas
│   ├── orders/              ← generación de pedidos
│   ├── progression/         ← niveles del local
│   ├── game_engine.dart     ← (estado, acción) → (estado nuevo, eventos)
│   ├── game_events.dart     ← lo que pasó, para feedback y analytics
│   └── game_controller.dart ← orquesta motor + persistencia + analytics
├── data/
│   ├── local/               ← codec del save (con migraciones) + almacenamiento
│   └── repositories/        ← carga y autoguardado con debounce
├── features/                ← UI por pantalla
├── services/                ← analytics (no-op), háptica
└── app/                     ← tema, rutas, providers
```

`GameEngine` es una **función pura**: recibe un estado y devuelve uno nuevo más
la lista de lo que ocurrió. No toca disco, ni reloj global, ni Flutter. Todo el
azar entra por una semilla persistida, así que una partida es reproducible y los
tests no son flaky.

---

## Documentación

| Archivo | Para qué |
|---|---|
| `DECISIONS.md` | Qué se decidió y por qué, incluidos los cambios respecto del brief |
| `GAME_DESIGN.md` | Diseño del juego |
| `GAME_ECONOMY.md` | Fórmulas, tablas de balance e invariantes |
| `TEST_PLAN.md` | Qué está cubierto y qué falta probar a mano |
| `PLAY_STORE_CHECKLIST.md` | Todo lo que falta para publicar |
| `DATA_INVENTORY.md` | Qué datos toca la app (fuente de los otros dos) |
| `DATA_SAFETY.md` | Borrador del formulario de Play |
| `PRIVACY_POLICY_DRAFT.md` | Borrador de la política de privacidad |
| `SDK_INVENTORY.md` | Qué se empaqueta y qué puede recolectar datos |
| `COST_MODEL.md` | Costos reales y comisión de Play |
| `ASSET_LICENSES.md` | Procedencia de cada asset |
| `CHANGELOG.md` | Historial de versiones |

---

## Seguridad

- El keystore, `key.properties`, `*.jks` y `*.keystore` **nunca** se versionan.
- No hay secretos, IDs de AdMob ni claves en el repositorio.
- La firma de release se inyecta en CI desde GitHub Secrets y se borra al
  terminar el job.
- Sin `key.properties`, el build de release usa la firma de debug: sirve para
  verificar que compila, pero **no** se puede subir a Play.

### Generar el keystore de upload

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Guárdalo **fuera del repositorio** y haz una copia de seguridad: si se pierde,
hay que pedirle a Google un reseteo de la clave de upload. Luego crea
`el_kiosko/android/key.properties` (ya ignorado por git):

```properties
storeFile=/ruta/absoluta/a/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

---

## Lo que sigue

**Gate A — playtest con 15–20 personas** antes de agregar cualquier
infraestructura. El brief es explícito: si el loop no resulta entretenido, no se
pasa a Firebase, ads ni billing. El plan de qué medir está en `TEST_PLAN.md` §4.
