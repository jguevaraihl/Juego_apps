# ASSET_LICENSES.md

Procedencia y licencia de **todo** lo que se empaqueta en la app. Se actualiza
en el mismo commit que agregue un asset.

Regla: **si no se puede documentar su procedencia acá, no entra al repo.**

Estado a **2026-08-22** · versión **0.1.0+1**.

---

## 1. Imágenes

| Asset | Origen | Licencia | Nota |
|---|---|---|---|
| `android/.../ic_launcher_foreground.xml` | Original, hecho para este proyecto | Propiedad del proyecto | Vector dibujado a mano: fachada con toldo, mesón y estante |
| `android/.../mipmap-*/ic_launcher.png` | Generado en este repo desde el mismo vector | Propiedad del proyecto | PNGs legacy para API 24–25 |
| `store_assets/play_icon_512.png` | Generado en este repo desde el mismo vector | Propiedad del proyecto | Ícono 512×512 para la ficha de Play |

**No hay archivos de imagen de terceros.** `assets/images/` está vacío a
propósito.

## 2. Arte dentro del juego

Todo el arte del juego se **dibuja en código**, no son archivos:

| Elemento | Dónde | Técnica |
|---|---|---|
| Fichas de producto | `lib/features/home/widgets/item_tile.dart` | Contenedores + íconos de Material |
| Fachada del local | `lib/features/home/widgets/storefront.dart` | `CustomPainter` con formas geométricas |
| Casillas del tablero | `lib/features/home/widgets/board_view.dart` | Contenedores con bordes |

Los íconos son **Material Icons**, que vienen con el SDK de Flutter bajo licencia
Apache 2.0.

## 3. Audio

**No hay archivos de audio.** El feedback usa `HapticFeedback` y
`SystemSound.play` de la plataforma. `assets/sounds/` está vacío a propósito
(ver DECISIONS D-015).

## 4. Tipografías

Ninguna tipografía empaquetada. Se usa la fuente del sistema (Roboto en
Android), lo que además reduce el tamaño del AAB.

## 5. Dependencias de software

| Paquete | Licencia |
|---|---|
| Flutter SDK | BSD-3-Clause |
| `flutter_riverpod` / `riverpod` | MIT |
| `path_provider` | BSD-3-Clause |
| `flutter_lints` | BSD-3-Clause |

---

## 6. Reglas para el arte de producción

Cuando entre arte definitivo:

- **no** imitar de forma identificable el estilo de un artista o estudio;
- **no** usar logos, marcas ni envases comerciales reales;
- **no** usar personajes protegidos;
- si se usa IA generativa, dejar registro de la herramienta y revisar sus
  términos respecto de uso comercial;
- si se compra o descarga un asset, guardar acá: fuente, autor, licencia, fecha
  y enlace;
- preferir licencias que no exijan atribución dentro de la app, o incluir una
  pantalla de créditos si la exigen.

---

## 7. Nombres y contenido cultural

Los nombres de producto (marraqueta, sopaipilla, completo) son **términos
genéricos** del habla chilena, no marcas. Los clientes son roles y oficios
cotidianos, no personas ni personajes reconocibles.

⚠️ **Pendiente para el owner:** verificar disponibilidad del nombre "El Kiosko"
en Google Play y en el registro de marcas de INAPI antes de comprometerlo en la
ficha de la tienda.
