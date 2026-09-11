# Plan de publicación

Escrito el **2026-09-10**, respondiendo a las preguntas del owner. Los precios
y las reglas de plataforma cambian: cada cifra lleva su fecha, y hay que
verificarlas antes de gastar. Ver también `COST_MODEL.md` y
`PLAY_STORE_CHECKLIST.md`, que este documento **no** repite.

---

## 1. ¿Publicar ahora o seguir mejorando?

**Publicar ahora, y no es una concesión: es lo correcto.**

El juego tiene 266 pruebas, `flutter analyze` limpio, y lo revisó alguien de
fuera que encontró tres defectos —ya corregidos—. Lo que falta no se puede
arreglar con más trabajo a ciegas: **falta información que sólo dan jugadores
reales.** Preguntas abiertas hoy, y ninguna se contesta sin datos:

- ¿Las 98 horas hasta el tope son demasiado? (Se ajusta cambiando un número.)
- ¿El ayudante a 400 monedas es caro o barato?
- ¿La gente vuelve al día siguiente?
- ¿En qué nivel deja de jugar?

Cada semana que el juego pasa sin publicar es una semana sin esos datos, y las
mejoras que se hagan mientras tanto son apuestas.

**Pero "publicar" no significa lo que parece.** Google impone un camino que
tarda ~3 semanas antes de que exista una ficha pública (§3). Lo que se puede
hacer **hoy** es subirlo a *internal testing*, que es inmediato: hasta 100
personas por correo, sin revisión, sin espera. Ahí es donde hay que probar.

### Lo único que yo recomendaría arreglar antes de la ficha pública

No bloquea el testing interno, pero sí una ficha con reseñas:

1. **El arte.** Es el techo del juego y lo dice `ART_DIRECTION.md`. Una ficha
   con capturas dibujadas en código compite mal contra Merge Inn o Travel Town.
   El encargo está listo en `ART_PROMPTS.md`.
2. ~~El nombre del paquete.~~ ✅ Confirmado el 2026-09-11:
   `cl.elkiosko.almacen`. Queda pendiente —y **no es bloqueante**— verificar la
   disponibilidad del **nombre visible** "El Kiosko" en Play e INAPI: ese sí se
   puede cambiar después.

---

## 2. ¿Cuánto invertir y en qué?

### Obligatorio: USD 25

La cuenta de desarrollador de Google Play, pago único. **Eso es todo lo que
hace falta para publicar.** Los costos recurrentes hoy son cero: no hay
servidor, no hay backend, CI es gratis.

### Lo que sí vale la pena, por orden de retorno

| Prioridad | Gasto | Rango | Por qué |
|:--:|---|---:|---|
| 1 | **Las 7 fachadas ilustradas** | USD 300–1.500 | Es lo que más se mira y el techo actual del juego. Encargo listo en `ART_PROMPTS.md` |
| 2 | **Ícono y feature graphic** | USD 50–200 | El ícono decide si alguien toca la ficha. Puede ir en el mismo encargo |
| 3 | **Capturas y video de la ficha** | USD 0–150 | Las capturas se sacan del build real; el video se puede editar sobre `store_assets/video/` |
| 4 | Traducción a 3–5 idiomas más | USD 100–300 | Sólo **después** de saber que el juego retiene. Agregar un idioma es agregar un `.arb` |

### Lo que NO hay que comprar todavía

**Publicidad para conseguir instalaciones.** Ni un peso hasta conocer, con
datos propios: retención D1/D7, cuánto rinde un jugador al día, y cuánto cuesta
traer uno. Comprar tráfico antes de eso es pagar por instalar una app que no se
sabe si retiene: se gasta el presupuesto y no se aprende nada.

**Presupuesto sensato para empezar: USD 25 ahora, y hasta ~USD 800 en arte
cuando el testing interno confirme que el juego engancha.** Si no engancha, esos
800 no se gastaron, que es justamente la gracia de este orden.

---

## 3. Cómo se sube a Google Play, de verdad

El orden lo impone Google y **no se puede saltar**:

| # | Paso | Quién | Tiempo |
|:--:|---|---|---|
| 1 | Crear cuenta de desarrollador (USD 25) | 🔑 Owner | 1 día |
| 2 | **Verificación de identidad** (documento oficial) | 🔑 Owner | días |
| 3 | Generar keystore y respaldarlo | 🔑 Owner (yo doy el comando) | minutos |
| 4 | Crear la app y subir el primer AAB a **internal testing** | Yo puedo automatizarlo | inmediato |
| 5 | **Closed testing: 12 testers, 14 días continuos** | 🔑 Owner consigue los 12 | **14 días** |
| 6 | Solicitar acceso a producción | 🔑 Owner | revisión ~7 días |
| 7 | Publicar | 🔑 Owner | — |

> ⚠️ **Los pasos 5 y 6 son ~3 semanas de calendario y sorprenden a todo el
> mundo.** Aplican a cuentas personales creadas después del 13-11-2023. Los 12
> testers tienen que **aceptar la invitación e instalar**; invitados que no
> instalan no cuentan. Conviene juntar a los 12 *antes* del día 1.

### Lo que sólo puede hacer el owner, sin excepción

Ninguna de estas cosas la puedo hacer yo, y no es una limitación del entorno
sino de cómo funcionan estas plataformas: **todas exigen la identidad legal o
la tarjeta de una persona.**

1. Crear y verificar la cuenta de Google Play.
2. Crear la cuenta de AdMob (exige identidad y datos tributarios).
3. Aceptar los términos, completar el formulario tributario de EE.UU. y los
   datos de pago.
4. Guardar el keystore. **Si se pierde, se pierde la capacidad de actualizar la
   app**; recuperarlo exige un trámite con Google.
5. Conseguir los 12 testers.

### Lo que sí puedo automatizar para que sea "una vez por semana"

Esto responde directamente a lo que pediste. Con **un service-account JSON**
que tú generas una vez en Google Cloud y pegas como secreto de GitHub, el
proyecto queda así:

- Tú haces un cambio o me lo pides.
- CI compila, corre las 266 pruebas y, si todo está verde, **sube el AAB solo**
  al track que corresponda.
- Tú entras a Play Console sólo a apretar "publicar" (o ni eso, si se
  configura despliegue automático a internal testing).

El JSON **nunca** entra al repositorio: va como secreto, igual que el keystore.
Cuando quieras, lo dejo montado; hace falta que primero exista la cuenta.

---

## 4. El comercial

### Lo que ya existe

`store_assets/video/gameplay_raw_390x844.webm` — captura real de juego, 55
segundos, grabada del build de verdad. **No es el comercial**: es la materia
prima. Sirve para ver el ritmo y para cortar encima.

### Cómo debería ser el comercial

Lo que funciona en este género —mirando Merge Inn, Travel Town, Eatventure— es
bastante estrecho:

- **15 a 30 segundos.** Los primeros **3 segundos** deciden todo: quien no
  entendió el juego en tres segundos ya se fue.
- **Empieza por la acción, no por el logo.** El logo va al final, un segundo.
- **Sin voz en off.** Se ve en silencio, en el metro. Todo el mensaje va en
  imagen y en dos o tres carteles de tres palabras.
- **Mostrar el juego de verdad.** Los anuncios con minijuegos falsos que no
  están en la app generan desinstalaciones y reportes, y Google los sanciona.

**Guion propuesto, 20 segundos:**

| Tiempo | Imagen | Cartel |
|---|---|---|
| 0–3 s | Dos productos se arrastran y se fusionan, con el "+N" saltando | *Junta. Vende. Crece.* |
| 3–8 s | Cadena rápida de tres fusiones seguidas, la ficha subiendo de nivel | — |
| 8–12 s | Un cliente pide, se entrega, cae la moneda | *Atiende a tu barrio* |
| 12–17 s | **La fachada mejorando**: corte seco entre el mesón improvisado y el minimarket | *De un mesón a una cadena* |
| 17–20 s | Ícono + nombre | *El Kiosko* |

El corte del segundo 12 es el más importante: es lo único que comunica que hay
un juego largo detrás, y es lo que distingue esto de un juego de fusionar más.

**Con qué editarlo, sin gastar:** CapCut o DaVinci Resolve, los dos gratis. La
captura ya está en formato vertical de teléfono.

⚠️ Para el video de la **ficha de Play** hay reglas propias (se sube a YouTube,
no puede ser privado, sin llamados a la acción tipo "descarga ya" en el propio
video). Verificar las especificaciones vigentes al subirlo.

---

## 5. Publicidad y suscripción: qué falta para que sean reales

El owner pidió: anuncios menores y no invasivos durante el juego, cada anuncio
monetizable, y una versión premium sin anuncios por un pago mensual bajo.

**El diseño está escrito** en `MONETIZATION_DESIGN.md` y la regla de fondo
—vender aceleración, nunca acceso— no cambia. Lo que **no** está es la
integración, y no por falta de tiempo:

> **No se puede integrar AdMob sin una cuenta de AdMob.** Los identificadores
> de aplicación y de bloque de anuncios los emite Google al crear la cuenta, y
> el brief prohíbe explícitamente inventarlos. Sin ellos, la app **no arranca**:
> el SDK de anuncios exige un App ID válido en el manifiesto de Android.

Lo mismo con la suscripción: el producto se crea en Play Console y su
identificador sale de ahí.

### Lo que necesito de ti para hacerlo, exactamente

1. **AdMob**: el App ID (`ca-app-pub-XXXXXXXX~XXXXXXXX`) y los IDs de los
   bloques que decidamos (uno *rewarded*, uno *interstitial*).
2. **Play Console**: el ID del producto de suscripción (por ejemplo
   `premium_mensual`) y el precio en cada país.

Con eso, en una tanda dejo: los anuncios donde corresponde, el consentimiento
de privacidad —**obligatorio** en Europa y Reino Unido antes de mostrar el
primer anuncio—, la suscripción con restauración de compras, y la Data Safety
actualizada, que hoy dice "no se recolecta nada" y **deja de ser cierta el día
que entre el primer anuncio**.

### Dónde irían los anuncios, para que los apruebes antes

Siguiendo tu criterio de "menores, no invasivos", y las reglas de Google:

| Dónde | Tipo | Por qué ahí |
|---|---|---|
| Ayudante gratis por 30 min | **Rewarded** (el jugador elige verlo) | Es aceleración pura. El mejor hueco que tiene el juego |
| Duplicar el premio de una misión | **Rewarded** | El jugador ya está mirando una recompensa |
| Duplicar lo cobrado de la caja | **Rewarded** | Momento de premio, no de fricción |
| Al volver tras varias horas | **Interstitial**, con tope de 1 cada varias horas | El único no elegido, y por eso el más limitado |

**Nunca**: durante una fusión, al entregar un pedido, ni al abrir la app.
Google sanciona los anuncios que se disparan sin acción del usuario o que
interrumpen el juego, y además es lo que hace que la gente desinstale.

### Sobre "cada comercial debe ser monetizable"

Entendido, y conviene decirlo con precisión: **un anuncio genera ingreso cuando
se muestra (impresión) y más cuando se completa o se toca.** Los *rewarded*
—los que el jugador elige ver a cambio de algo— pagan bastante más por
impresión que un banner, y son los que menos molestan. Por eso los cuatro
huecos de arriba son tres rewarded y un interstitial: no es sólo cuidar al
jugador, es también lo que más rinde por anuncio mostrado.

Lo que **no** puedo prometer es cuánto. El ingreso por mil impresiones depende
del país del jugador, de la temporada y del inventario disponible, y varía en
un orden de magnitud entre mercados. Cualquier número que ponga acá sería
inventado.

### La suscripción premium

- **Qué incluye**: sin anuncios. Nada más. Si además diera ventajas de juego,
  el juego gratis pasaría a estar diseñado para molestar, que es exactamente lo
  que el brief prohíbe.
- **Precio**: bajo, del orden de USD 1–3 al mes. El punto de comparación es lo
  que rendiría ese jugador en anuncios durante un mes.
- **Comisión**: ~15% (ver `COST_MODEL.md` §4). Google Play Billing v8 o
  superior es obligatorio desde el 31-08-2026.

---

## 5a. Activar la política de privacidad (2 clics, los únicos que faltan)

Las páginas ya están escritas y en el repositorio, en `/docs`. Para que la URL
funcione:

1. GitHub → el repositorio → **Settings** → **Pages**.
2. En **Source**, elegir **Deploy from a branch**.
3. Branch: **`claude/android-game-google-play-2mb5xw`** (es la rama por defecto
   del repo) · Folder: **`/docs`** → **Save**.

En uno o dos minutos quedan vivas:

- https://jguevaraihl.github.io/Juego_apps/privacidad.html
- https://jguevaraihl.github.io/Juego_apps/privacy.html

Esa primera URL es la que va en Play Console → *Política de privacidad*.

> **Funciona gratis porque el repositorio es público.** En un repositorio
> privado, Pages público exige un plan de pago. Si algún día se vuelve privado,
> la política deja de abrir y Play la rechaza: conviene recordarlo.

### El único dato que falta llenar

En `docs/privacidad.html` y `docs/privacy.html`, la línea marcada
`<!-- CAMBIAR -->`: el **nombre o razón social del publisher**. Tiene que ser
**el mismo** que se declara en Play Console. No lo rellené porque es un dato
legal y no me corresponde inventarlo.

### Un tercer correo, y por qué

Las páginas usan **`el.kiosko90+privacidad@gmail.com`**, distinto del de
comentarios. No es burocracia: las solicitudes sobre datos personales (GDPR,
CCPA) tienen **plazos legales** del orden de 30 días, y no pueden terminar en la
misma carpeta que se revisa una vez por semana.

**Para ése no crees un filtro que omita Recibidos.** Es el único correo del
proyecto que conviene que suene.

---

## 5b. El correo del proyecto

Los correos del juego llegan a **`el.kiosko90@gmail.com`**, una cuenta
**separada de la personal del owner**. Eso resuelve de raíz lo que antes se
intentaba parchar con filtros:

- Todo lo que llega ahí **es** del proyecto: no hay nada que separar.
- Esa dirección va a quedar **pública** en la ficha de Google Play y en la
  política de privacidad. Publicar una cuenta personal ahí es irreversible en
  la práctica: queda en capturas, en cachés y en la ficha.
- Si mañana el proyecto cambia de manos o se le suma alguien, se entrega la
  cuenta entera y no medio buzón privado.

**Consecuencia importante y con fecha:** la cuenta de **Google Play Console** y
la de **AdMob** deben crearse con **esta misma cuenta**, no con la personal.
Mover una app entre cuentas de desarrollador después es un trámite lento y hay
que volver a pagar el registro. Es de las pocas decisiones de este proyecto que
cuesta caro deshacer.

### Lo único que sí conviene filtrar

`el.kiosko90+privacidad@gmail.com` mantiene su etiqueta, pero ahora por otra
razón: **no para separarlo de lo personal, sino de lo que no corre prisa.** Las
solicitudes de datos personales (GDPR, CCPA) tienen plazos legales del orden de
30 días; un comentario sobre el balance puede esperar al domingo.

Filtro sugerido, dentro de la cuenta del proyecto:

- `to:el.kiosko90+privacidad@gmail.com` → **etiqueta "Privacidad", que SÍ llegue
  a Recibidos y SÍ notifique.**
- Todo lo demás puede quedarse como está: la cuenta es del proyecto, así que
  abrirla una vez por semana ya es el filtro.

---

## 6. El modelo de "una hora a la semana"

Esto es lo que hay que montar para que el proyecto no te coma tiempo:

| Automatizado (ya, o en cuanto exista la cuenta) | Tuyo, cada semana |
|---|---|
| Compilar y correr 266 pruebas en cada cambio | Leer los comentarios que llegan por correo |
| Publicar APK y AAB como artefactos | Mirar crashes en Play Console (5 min) |
| Subir el AAB al track de testing (falta el service account) | Decidir qué ajustar y pedírmelo |
| Bloquear un cambio que rompa el balance o desborde la pantalla | Apretar "publicar" |

Lo que **no** conviene automatizar es publicar a producción sin mirar. Un
cambio de balance que se sube solo un viernes puede arruinar la partida de
gente real, y las reseñas de una semana mala tardan meses en diluirse.

---

## 6b. ¿Qué posibilidades hay de que esto genere ganancias?

El owner preguntó directo y merece una respuesta directa. Esta sección son
**estimaciones de orden de magnitud, no datos**: nadie tiene datos de este juego
todavía, y ése es precisamente el punto.

### La respuesta corta

**Muy bajas si "ganancias" significa un ingreso que se note. Razonables si
significa cubrir los USD 25 y algo más.**

| Resultado | Probabilidad (juicio, no dato) |
|---|---|
| Recuperar los USD 25 del registro | **Alta** |
| Unos pocos dólares al mes durante un tiempo | **Moderada** |
| USD 50–200 al mes de forma sostenida | **Baja** |
| Un ingreso que compita con un sueldo | **Muy baja** |

### Por qué, y no es por la calidad del juego

**El cuello de botella no es el producto: es que nadie lo encuentre.**

Hay cientos de juegos de fusionar en Google Play. Los que el owner miró —Merge
Inn, Travel Town, Eatventure— no ganan porque sean mejores juegos: ganan porque
detrás hay estudios con equipos de arte, equipos de live-ops y **presupuestos de
adquisición de usuarios de millones de dólares**. Ese gasto es lo que compra la
posición en la tienda, y a su vez la posición es la que trae instalaciones
orgánicas. Es un volante que hay que empujar con dinero para que gire.

Un juego nuevo sin presupuesto de marketing, en una categoría saturada, recibe
un tráfico orgánico cercano a cero. No "poco": cercano a cero.

### La aritmética, con los supuestos a la vista

Los anuncios pagan por cada mil impresiones. Ese precio varía muchísimo por
país: en mercados de habla hispana suele ser **bastante menor** que en EE.UU. o
Europa, y un vídeo premiado paga bastante más que un banner.

Tomemos un caso optimista para un juego sin marketing: **200 personas jugando
cada día**, cada una mirando **2 vídeos premiados**. Son 400 impresiones
diarias. Con un precio por mil de entre 3 y 12 dólares:

- **Entre USD 1,2 y 4,8 al día.** Es decir, del orden de **USD 35 a 145 al
  mes**, brutos, antes de la parte que se queda la red de anuncios.

Y conseguir esas 200 personas diarias **de forma orgánica** ya sería un
resultado notable. Lo habitual para un lanzamiento sin marketing es un orden de
magnitud menos: decenas de instalaciones, unas pocas personas jugando a diario,
y unos pocos dólares al mes.

La suscripción no cambia el cuadro: sobre una base chica, un porcentaje chico de
suscriptores sigue siendo un número chico.

### Qué sí movería la aguja

Por orden de lo que más cambia las probabilidades:

1. **La ambientación.** "Almacén de barrio" es lo único que este juego tiene y
   los grandes no: ninguno de ellos va a hacer un juego sobre el negocio de la
   esquina latinoamericano, con sus marraquetas y su gato. Eso es un ángulo real
   para **un mercado concreto**, no para competir de frente con Merge Mansion.
   Y es exactamente lo que hoy no se ve, porque el arte está dibujado en código.
2. **Un canal de distribución que no cueste dinero.** Vídeos cortos mostrando el
   local que crece, comunidades de nostalgia de barrio, prensa local de
   tecnología. Es trabajo, no plata, y es el único camino realista sin
   presupuesto.
3. **Retención.** Si la gente no vuelve al día siguiente, cualquier instalación
   que se consiga se evapora. Es lo primero que hay que medir, y por eso el
   testing interno importa más que cualquier otra cosa ahora.
4. **Arte.** Necesario para que lo anterior funcione, pero inútil por sí solo:
   un juego precioso que nadie encuentra tampoco gana.

### La recomendación honesta

**Publicarlo igual, pero con la expectativa correcta.**

- **Gastar los USD 25 y punto.** Es un costo trivial por aprender cómo funciona
  todo el circuito: publicar, testear, medir, actualizar.
- **No gastar los USD 800 de arte hasta ver retención real.** Ese es el número
  que conviene mirar: si de 100 personas que instalan, 20 vuelven al día
  siguiente, hay algo. Si vuelven 3, el arte no lo va a arreglar.
- **Tratar el ingreso como un resultado secundario.** Lo que este proyecto sí
  produce con seguridad es un juego terminado, probado y publicado, y un proceso
  que sirve para el siguiente. Eso tiene valor aunque el juego no gane un peso.

### Sobre el sesgo de quien escribe esto

Conviene decirlo: durante todo este proyecto se optimizó por **calidad del
juego** —balance, rendimiento, accesibilidad, pruebas—, y **no** por
descubribilidad, que es lo que determina el ingreso. Son dos problemas
distintos y el segundo casi no se tocó. Un juego con 273 pruebas y un juego que
la gente encuentra no son lo mismo, y este proyecto es hoy claramente lo
primero.

---

## 7. Respuesta corta a "¿tienes todo para avanzar?"

**No, y falta poco.** Todo lo que depende del código está hecho. Lo que falta
es lo que exige tu identidad:

- [x] ~~Correo de soporte~~ — `el.kiosko90@gmail.com`, 2026-09-11 (D-066)
- [x] ~~Nombre del paquete definitivo~~ — `cl.elkiosko.almacen`, 2026-09-11 (D-003)
- [ ] Cuenta de Google Play verificada (USD 25)
- [ ] Keystore generado y respaldado
- [~] URL pública de la política de privacidad — **escrita y alojada en `/docs`**; falta activar Pages (2 clics) y el nombre del publisher
- [ ] 12 testers para el closed testing
- [ ] Cuenta de AdMob → para los anuncios
- [ ] Producto de suscripción en Play Console → para el premium
