# SDK_INVENTORY.md

Inventario de todo lo que se empaqueta dentro del APK/AAB, con foco en qué
puede recolectar datos. Se actualiza **en el mismo commit** que agregue o quite
una dependencia.

Estado a **2026-08-22** · versión de app **0.1.0+1** · Fase 1.

---

## 1. Resumen

**Ningún SDK de esta versión recolecta datos, muestra publicidad, ni abre
conexiones de red.** La app no declara el permiso `INTERNET` en el manifest de
producción.

---

## 2. Dependencias de runtime

| Paquete | Versión | Qué hace | ¿Red? | ¿Recolecta datos? | ¿Código nativo Android? |
|---|---|---|:---:|:---:|:---:|
| `flutter` (SDK) | 3.47.1 | Framework y motor | No | No | Sí (motor) |
| `flutter_riverpod` | 3.4.2 | Estado en memoria | No | No | No (Dart puro) |
| `path_provider` | 2.1.6 | Ruta del directorio de documentos | No | No | Sí (`path_provider_android`) |
| `flutter_localizations` | SDK | Traducciones de Material y formatos por locale | No | No | No |
| `intl` | (resuelta por el SDK) | Formato de números y fechas por locale | No | No | No |
| `web` | 1.1.1 | `localStorage` **sólo en la build web de demo**; no entra al APK/AAB | No | No | No |

`path_provider` sólo devuelve una **ruta**; no lee, escribe ni transmite nada
por su cuenta. La escritura del save la hace la app con `dart:io`.

`web` se usa únicamente en `save_store_web.dart`, seleccionado por import
condicional: en una build de Android ese archivo **no se compila**.

Ninguna de las librerías de localización hace red: los `.arb` se compilan a
código Dart dentro del binario.

### Transitivas con código nativo
`path_provider_android` es el único plugin con implementación Android.
El resto del árbol (`collection`, `meta`, `characters`, …) es Dart puro sin E/S.

---

## 3. Dependencias de desarrollo (NO se empaquetan)

| Paquete | Versión | Uso |
|---|---|---|
| `flutter_test` | SDK | Tests |
| `flutter_lints` | 6.0.0 | Reglas de análisis estático |

---

## 4. Permisos Android

| Permiso | Manifest | Motivo |
|---|---|---|
| `INTERNET` | **sólo debug** | Lo agrega Flutter para hot reload y depuración. **No** está en el manifest de release |

El manifest de producción (`android/app/src/main/AndroidManifest.xml`) **no
declara ningún permiso**. Hay un bloque `<queries>` para `ACTION_PROCESS_TEXT`
que trae el template de Flutter; no otorga acceso a datos.

---

## 5. Identificadores

La app **no** lee ni almacena: Advertising ID (GAID), Android ID, IMEI, número
de teléfono, MAC, ni ningún identificador de dispositivo o publicidad.

---

## 6. SDKs previstos para fases futuras

⚠️ Cada uno de estos **cambia** la declaración de Data Safety y la política de
privacidad. No agregar ninguno sin actualizar `DATA_SAFETY.md`,
`DATA_INVENTORY.md` y `PRIVACY_POLICY_DRAFT.md` en el mismo commit.

| SDK | Fase | Impacto en privacidad |
|---|---|---|
| Firebase Crashlytics | 2 | Diagnóstico: stack traces, modelo, versión de OS |
| Firebase Analytics | 2 | Analítica de uso; genera un App Instance ID |
| Firebase Remote Config | 2 | Configuración remota |
| Firebase Cloud Messaging | 3 (sólo si hay razón clara) | Token de push |
| Google Mobile Ads (AdMob) | 3 | **Publicidad**; identificadores; requiere UMP/consentimiento |
| Google Play Billing | 3 | Compras; requiere manejar el estado de compra |

Al agregar AdMob habrá que declarar `INTERNET` (y `AD_ID` según la
configuración) y rehacer por completo la sección de publicidad del Data Safety.
