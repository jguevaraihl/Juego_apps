# DATA_SAFETY.md

Borrador de respuestas para el formulario **Data safety** de Google Play,
derivado de `DATA_INVENTORY.md` y `SDK_INVENTORY.md` — no de una plantilla.

Estado a **2026-08-22** · versión **0.1.0+1** · Fase 1.

⚠️ Sólo el owner de la cuenta puede enviar este formulario, y la declaración es
una **afirmación legal**. Verificar contra el código antes de enviar.

---

## Respuestas para la versión actual (Fase 1)

| Pregunta del formulario | Respuesta | Fundamento |
|---|---|---|
| ¿La app recolecta o comparte alguno de los tipos de datos requeridos? | **No** | Sin red, sin SDKs de terceros, sin permisos |
| ¿Los datos están cifrados en tránsito? | N/A | No hay tránsito |
| ¿Se puede pedir la eliminación de datos? | N/A | No hay datos en servidores. El usuario borra todo desinstalando |
| ¿La app tiene publicidad? | **No** | Sin SDK de anuncios |
| ¿Compras dentro de la app? | **No** | Sin Billing integrado |
| ¿Contenido generado por usuarios? | **No** | |
| ¿Recolecta datos de menores? | **No** | Dirigida a adultos |
| Sección "Prácticas de seguridad" → Datos cifrados en tránsito | N/A | |
| Sección "Prácticas de seguridad" → Compromiso con Play Families Policy | N/A | No es app infantil |

### Declaraciones asociadas

| Ítem de Play Console | Valor |
|---|---|
| Ads declaration | **La app no contiene anuncios** |
| Target audience | Adultos (18+ como público objetivo declarado) |
| Content rating | Completar el cuestionario IARC. Sin violencia, sin lenguaje, sin apuestas, sin alcohol ni tabaco. Se espera clasificación para todo público |
| Government apps | No |
| Financial features | No |
| Data safety → "Colecta de datos" | Ninguna |

---

## ⚠️ Cómo cambia esto en Fase 2 y 3

Este es el punto que más fácilmente termina en una declaración falsa. Cada SDK
que entre **obliga** a rehacer el formulario **antes** de publicar esa versión.

### Al agregar Firebase Crashlytics + Analytics (Fase 2)

| Pregunta | Nueva respuesta |
|---|---|
| ¿Recolecta datos? | **Sí** |
| Tipo: Diagnóstico → Registros de fallos | Recolectado, no compartido, para "Analytics" y "Funcionalidad de la app" |
| Tipo: Diagnóstico → Diagnóstico de rendimiento | Recolectado |
| Tipo: Identificadores → App Instance ID | Recolectado (lo genera Firebase Analytics) |
| ¿Cifrado en tránsito? | **Sí** |
| ¿Se puede pedir eliminación? | **Sí** — hay que ofrecer un mecanismo real |
| ¿Es obligatorio o el usuario puede optar por no participar? | Decidir explícitamente; lo honesto es ofrecer opt-out |

### Al agregar Google Mobile Ads (Fase 3)

| Pregunta | Nueva respuesta |
|---|---|
| ¿La app tiene publicidad? | **Sí** |
| Tipo: Identificadores → Advertising ID | Recolectado **y compartido** con terceros |
| Tipo: Actividad de la app → Interacciones | Probablemente recolectado |
| Permiso `com.google.android.gms.permission.AD_ID` | Habrá que declararlo |
| Consentimiento | Implementar UMP (User Messaging Platform) |

### Al agregar Google Play Billing (Fase 3)

| Pregunta | Nueva respuesta |
|---|---|
| ¿Compras dentro de la app? | **Sí** |
| Compras | Las procesa Google Play; declarar según cómo se maneje el estado de entitlement |

---

## ⚠️ Distribución global: qué cambia

La app se distribuye en todos los países, no sólo Chile. Eso agrega regímenes
de privacidad que hoy **no** obligan a nada porque no se recolecta ningún dato,
pero que se vuelven críticos en cuanto entren analytics y publicidad:

| Régimen | Dónde | Qué exigirá en Fase 2–3 |
|---|---|---|
| GDPR | Espacio Económico Europeo | Base legal, consentimiento previo para publicidad personalizada, derecho de acceso y borrado, registro de tratamiento |
| UK GDPR | Reino Unido | Equivalente al anterior |
| CCPA / CPRA | California | Derecho a optar por no "vender/compartir" datos; los identificadores publicitarios cuentan como compartir |
| LGPD | Brasil | Similar a GDPR |
| Ley 21.719 | Chile | Vigente desde el 01-12-2026 |
| DSA / Play Families | UE | Declaraciones adicionales si la audiencia incluyera menores (no es el caso) |

**Consecuencia práctica.** Cuando entre AdMob hay que implementar la
**User Messaging Platform (UMP)** de Google para pedir consentimiento en el EEE
y Reino Unido, y una señal de opt-out para California. No es opcional: publicar
anuncios personalizados en la UE sin consentimiento válido es una infracción,
no un detalle de configuración.

**Hoy, en Fase 1, nada de esto aplica**: sin red, sin SDKs y sin datos, la
declaración es "no se recolectan datos" en todos los mercados por igual.

---

## Regla operativa

> No enviar una versión a Play sin revisar que la declaración de Data Safety
> coincida con `SDK_INVENTORY.md` **de esa misma versión**.

Está incluido como ítem bloqueante en `PLAY_STORE_CHECKLIST.md`.
