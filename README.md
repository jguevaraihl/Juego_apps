# Juego_apps

Monorepo de juegos móviles.

## Proyectos

| Proyecto | Descripción | Estado |
|---|---|---|
| [`el_kiosko/`](el_kiosko/) | **El Kiosko — Almacén de Barrio.** Juego Android de *merge* y administración ligera, ambientado en un almacén de barrio chileno | Fase 1 (vertical slice) · pendiente Gate A |

## Desarrollo

Toda la documentación del juego vive en [`el_kiosko/`](el_kiosko/). Empieza por
[`el_kiosko/README.md`](el_kiosko/README.md) y
[`el_kiosko/DECISIONS.md`](el_kiosko/DECISIONS.md).

```bash
cd el_kiosko
flutter pub get
flutter test
flutter run
```

## CI

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) corre formato, análisis
estático, tests y build de App Bundle en cada push. **No** publica a Google Play.

## Otros directorios

- `store_assets/` — material para la ficha de Google Play (ícono 512×512)
