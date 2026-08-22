# PLAY_STORE_CHECKLIST.md

Checklist para publicar en Google Play. Verificado el **2026-08-22**.

**Leyenda**
- ✅ **Listo en el repo** — hecho y verificable en el código
- 🔑 **Sólo el owner** — requiere credenciales, identidad legal o decisión comercial
- ⏳ **Fase posterior** — no corresponde todavía

> Regla: no marcar como "cumple" nada que dependa de información que sólo el
> owner puede declarar.

---

## 1. Cuenta y publisher

| Ítem | Estado | Nota |
|---|:--:|---|
| Cuenta de Google Play Developer | 🔑 | USD 25, pago único |
| Verificación de identidad | 🔑 | Google la exige; puede tardar días |
| Nombre público del desarrollador | 🔑 | Aparece en la ficha |
| Dirección y teléfono de contacto | 🔑 | Obligatorios para cuentas personales |
| Correo de soporte | 🔑 | Debe ser real y monitoreado |

## 2. Identidad de la app

| Ítem | Estado | Nota |
|---|:--:|---|
| Nombre de la app | 🔑 | "El Kiosko — Almacén de Barrio" es provisorio. Verificar disponibilidad en Play e INAPI |
| **Package name / applicationId** | 🔑 **BLOQUEANTE** | Hoy `cl.elkiosko.almacen` (placeholder). **Es permanente una vez publicado.** Ver DECISIONS D-003 |
| Categoría | 🔑 | Sugerido: Juegos → Puzzle o Casual |

## 3. Requisitos técnicos

| Ítem | Estado | Nota |
|---|:--:|---|
| `targetSdk` 36 | ✅ | Obligatorio para apps nuevas desde el 31-08-2026 |
| `compileSdk` 36 | ✅ | |
| `minSdk` 24 | ✅ | |
| Android App Bundle (`.aab`) | ✅ | CI lo genera |
| 64-bit | ✅ | Flutter genera arm64-v8a; los splits de ABI están activos |
| Ícono adaptativo | ✅ | Más PNGs legacy para API 24–25 |
| Back navigation moderna | ✅ | `enableOnBackInvokedCallback="true"` |
| Play App Signing | 🔑 | Se activa al crear la app en Play Console |
| Keystore de upload | 🔑 **BLOQUEANTE** | Generar con `keytool`, **nunca** subir al repo. Guardar copia de seguridad: si se pierde, hay que pedir reseteo a Google |
| Secretos de firma en CI | 🔑 | `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` |
| El AAB compila | ⚠️ | **No verificado localmente.** Confirmar con la primera corrida de CI (DECISIONS D-020) |

## 4. Testing previo a producción

| Ítem | Estado | Nota |
|---|:--:|---|
| Closed testing | 🔑 | Cuentas personales creadas después del **13-11-2023** deben correr un closed test antes de pedir acceso a producción |
| **12 testers opt-in** | 🔑 | Deben aceptar la invitación **e instalar**; invitados sin instalar no cuentan |
| **14 días continuos** | 🔑 | Los 12 deben estar opt-in de forma continua durante los 14 días previos a la solicitud |
| Solicitud de acceso a producción | 🔑 | Revisión de hasta ~7 días |
| Pre-launch report | 🔑 | Se genera solo al subir a un track de testing; revisar crashes y advertencias |

⚠️ **Estos 14 días + la revisión son ~3 semanas de calendario.** Hay que
integrarlos a la planificación, no descubrirlos al final.

## 5. Privacidad y cumplimiento

| Ítem | Estado | Nota |
|---|:--:|---|
| Inventario de datos | ✅ | `DATA_INVENTORY.md` |
| Inventario de SDKs | ✅ | `SDK_INVENTORY.md` |
| Borrador de Data Safety | ✅ | `DATA_SAFETY.md` — Fase 1: no se recolectan datos |
| Borrador de política de privacidad | ✅ | `PRIVACY_POLICY_DRAFT.md` |
| **URL pública de la política** | 🔑 **BLOQUEANTE** | Google Play la exige accesible sin login. Falta alojarla y completar los `[PENDIENTE]` |
| Ads declaration | ✅ → 🔑 | Fase 1: "no contiene anuncios". El owner lo declara |
| Target audience | 🔑 | Adultos. **No** completar como app infantil |
| Content rating (IARC) | 🔑 | Cuestionario en Play Console |
| Data Safety coincide con los SDKs de **esta** versión | ✅ | Verificado para 0.1.0. **Revisar de nuevo en cada release** |

## 6. Ficha de la tienda

| Ítem | Estado | Nota |
|---|:--:|---|
| Ícono 512×512 | ✅ | `store_assets/play_icon_512.png` |
| Feature graphic 1024×500 | 🔑 | Falta |
| Screenshots de teléfono (mín. 2, hasta 8) | 🔑 | Capturar del build real |
| Video promocional | ⏳ | Opcional |
| Short description (máx. 80 caracteres) | 🔑 | Borrador: "Haz crecer tu almacén de barrio juntando productos y sirviendo pedidos." |
| Full description | 🔑 | Sin keyword stuffing |
| Notas de la versión | 🔑 | |
| Países | 🔑 | **Sólo Chile** al inicio. No expandir por reflejo |

## 7. Monetización

| Ítem | Estado | Nota |
|---|:--:|---|
| Google Play Billing v8+ | ⏳ | **Obligatorio desde el 31-08-2026.** v9 es la versión actual. **No usar v6** |
| Productos en Play Console | ⏳ 🔑 | Fase 3 |
| Prueba de compras en track de testing | ⏳ 🔑 | Incluye restauración de compras |
| AdMob configurado | ⏳ 🔑 | Fase 3. Usar test ad units en debug; los IDs reales van por configuración externa, nunca en el repo |
| Prueba de anuncios | ⏳ 🔑 | Fase 3 |

## 8. Seguridad del repositorio

| Ítem | Estado | Nota |
|---|:--:|---|
| Keystore fuera de git | ✅ | `*.jks`, `*.keystore` y `key.properties` en `.gitignore` |
| Sin service-account JSON | ✅ | No hay publicación automatizada |
| Sin secretos en el código | ✅ | No hay IDs de AdMob ni claves |
| Secretos vía GitHub Secrets | ✅ | El workflow los consume; borra el material de firma al terminar |
| CI no publica a producción | ✅ | Sólo compila y sube el artifact |

---

## Los 5 bloqueantes reales

Nada de lo demás importa hasta que estos estén resueltos, y **ninguno lo puede
resolver Claude**:

1. **Package name definitivo** — permanente una vez publicado.
2. **Keystore de upload** — generado y respaldado fuera del repo.
3. **URL pública de la política de privacidad**.
4. **Identidad verificada** en Play Console.
5. **12 testers × 14 días** de closed testing.
