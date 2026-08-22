# COST_MODEL.md

Costos reales de operar esto como side hustle. Verificado el **2026-08-22**.

⚠️ Los precios de terceros cambian. Cada cifra lleva su fuente y su fecha de
verificación; volver a chequear antes de comprometer presupuesto.

---

## 1. Costos de partida (una vez)

| Ítem | Costo | Nota |
|---|---:|---|
| Registro de desarrollador de Google Play | **USD 25** (pago único) | La cuenta queda activa indefinidamente. Verificado 2026-08-22 |
| Dominio (opcional) | ~USD 10–15 / año | Sólo si no se usa GitHub Pages para la política de privacidad |
| Hosting de la política de privacidad | **USD 0** | GitHub Pages sobre este repo. Google Play exige una URL pública |
| Herramientas de arte | USD 0–200 | Hoy USD 0: el arte es placeholder generado en código |
| Keystore | USD 0 | Se genera con `keytool` (viene con el JDK) |

**Mínimo real para publicar: USD 25.**

---

## 2. Costos recurrentes en Fase 1 (estado actual)

**USD 0 / mes.** La app no tiene backend, ni Firebase, ni servicios de terceros.
GitHub Actions es gratis para repos públicos, y para privados el free tier
(2.000 min/mes) sobra para este volumen de builds.

---

## 3. Costos recurrentes previstos (Fase 2–3)

| Servicio | Modelo | Estimación a escala chica |
|---|---|---|
| Firebase Crashlytics | Gratis, sin cuota por volumen | USD 0 |
| Firebase Analytics | Gratis para eventos estándar; límite de parámetros y cardinalidad | USD 0 |
| Firebase Remote Config | Cuota gratuita generosa; se cobra por fetches a gran escala | ~USD 0 con miles de DAU |
| Firebase Cloud Messaging | Gratis | USD 0 |
| RevenueCat u otro (si se usa) | Gratis bajo cierto MTR; después % del ingreso | Evaluar sólo si hay suscripción |
| Backend propio | — | **No previsto.** El brief lo excluye del MVP |

⚠️ **No asumir "Firebase gratis hasta 100k DAU".** Cada producto de Firebase
tiene su propia cuota y sus propias reglas. Crashlytics y FCM efectivamente no
cobran por volumen; Analytics tiene límites de cardinalidad, no de costo; Remote
Config sí puede cobrar a gran escala. Verificar en la calculadora de precios de
Firebase cuando se llegue a Fase 2, con números propios.

---

## 4. Comisión de Google Play — ⚠️ el brief está desactualizado acá

El brief asumía "15% para suscripciones auto-renovables". El número resulta ser
correcto para Chile en 2026, pero por una razón distinta a la que suponía, y
tiene fecha de vencimiento.

### Lo que cambió (junio 2026)

Google lanzó el programa **Billing Choice**, que separa la comisión en dos:

- **service fee**: desde **10%** sobre el primer USD 1M de ingresos anuales,
  incluyendo suscripciones auto-renovables;
- **billing fee**: **+5%** adicional si se usa el sistema de facturación de
  Google Play.

Es decir, ~15% usando Play Billing, o 10% + lo que cobre el procesador propio si
se usa facturación alternativa.

### Por qué no aplica a Chile todavía

El despliegue es por regiones:

| Región | Fecha |
|---|---|
| EEE, Reino Unido, Estados Unidos | 30-06-2026 |
| Australia | 30-09-2026 |
| Japón y Corea del Sur | 31-12-2026 |
| **Resto del mundo (incluye Chile)** | **30-09-2027** |

**Conclusión operativa:** para un lanzamiento sólo en Chile durante 2026, se
aplica el esquema vigente — **15%** sobre el primer USD 1M anual bajo el
programa de tarifa reducida, y 15% para suscripciones auto-renovables. A partir
del 30-09-2027 hay que rehacer este cálculo.

⚠️ Verificar la tarifa **efectiva de la cuenta** en Play Console antes de
modelar ingresos: depende de la inscripción al programa de tarifa reducida y de
los ingresos anuales acumulados.

---

## 5. Otros descuentos sobre el ingreso bruto

Antes de contar un peso como ganancia hay que restar:

- comisión de Google Play (arriba);
- **IVA chileno (19%)** sobre las ventas al consumidor final — verificar cómo lo
  maneja Google Play para Chile y quién es el responsable de enterarlo;
- impuesto a la renta según la situación tributaria del owner;
- retención por servicios digitales / tratado tributario, según cómo se reciba
  el pago;
- devoluciones y chargebacks;
- costos de herramientas y marketing.

⚠️ La situación tributaria es específica de cada persona. Esto **no** es asesoría
contable: conviene consultar con un contador antes del primer pago.

---

## 6. Punto de equilibrio

Con costos recurrentes de USD 0 en Fase 1, el equilibrio del **primer año** es
recuperar los **USD 25** de registro.

Deliberadamente no se proyectan ingresos acá. El brief es explícito: no
presentar ingresos futuros como certezas. Los modelos de ARPDAU sólo tienen
sentido con datos propios de retención y monetización, que hoy no existen. La
tabla del brief (§9) es ilustrativa y debe tratarse como tal.

---

## 7. Adquisición pagada

**No comprar tráfico** hasta conocer, con datos propios: CPI, retención D1/D7/D30,
ARPDAU, conversión a pagador, LTV y payback. Antes de eso, cualquier gasto en
ads es una apuesta sin información.

---

## Fuentes verificadas 2026-08-22

- Requisito de API 36 y fecha 31-08-2026: developer.android.com/google/play/requirements/target-sdk
- Play Billing Library v8+ obligatorio desde 31-08-2026; v9 es la actual
- Programa Billing Choice y fechas de despliegue por región: anuncio de Google de junio 2026
- Fee de registro USD 25 (pago único)
- Closed testing: 12 testers, 14 días continuos, para cuentas personales creadas después del 13-11-2023
