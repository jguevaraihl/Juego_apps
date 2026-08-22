# MONETIZATION_DESIGN.md

Diseño de las mecánicas que dependen de la monetización, guardadas para
implementarlas cuando el juego entre en Fase 3.

**Nada de esto está implementado.** Este documento existe para que las ideas no
se pierdan y para que, cuando se construyan, se construyan con criterio y no de
apuro.

> **Regla que ordena todo el documento:** se vende **aceleración**, nunca
> **acceso**. Todo lo que el juego ofrece tiene que ser alcanzable jugando
> gratis; pagar sólo lo hace más rápido. En el momento en que algo sólo se
> consigue pagando, el juego deja de ser un juego con tienda y pasa a ser una
> tienda con juego, y ahí es donde llegan las desinstalaciones y las reseñas
> de una estrella.

---

## 1. Menú de monedas (idea #3)

**Qué.** Tocar el contador de monedas abre una hoja con:

- ganancia actual por hora y por día;
- **duplicar la ganancia por X horas** viendo un anuncio con recompensa;
- **packs de monedas** de compra directa, más baratos por moneda mientras más
  grande el pack;
- ofertas temáticas o rotativas.

**Por qué funciona.** El jugador ya mira ese número (el contador con decimales
está justamente para eso). Convertir un número que ya observa en una puerta a
la tienda es el camino natural, y no interrumpe la partida.

**Cómo hacerlo bien**
- El rewarded es **opcional siempre**. La ganancia base nunca se baja para que
  el x2 "se sienta necesario": eso es empeorar el juego para vender el arreglo.
- Un cooldown razonable entre rewarded (no un botón infinito).
- Los precios se leen de Google Play, nunca hardcodeados: Play los localiza.
- La oferta rotativa no puede usar cuenta regresiva falsa ni "última
  oportunidad" mentirosa.

**Depende de:** cuenta de AdMob, productos creados en Play Console, Billing
integrado.

---

## 2. Caja del proveedor XL (idea #5)

**Qué.** Rellenar de una vez todas las casillas libres, viendo un anuncio o
pagando.

**Por qué es una buena candidata.** Es exactamente el tipo de recompensa que
conviene dar por rewarded: **ahorra tiempo, no da poder**. El jugador podría
haber tocado la caja 20 veces; el anuncio le ahorra los 20 toques.

**Cuidado.** Con el tablero lleno de nivel 1 el jugador queda sin espacio para
fusionar. Conviene rellenar hasta dejar **2 o 3 casillas libres**, no hasta el
tope, o la "recompensa" termina siendo un castigo. Este detalle es la
diferencia entre que se sienta un regalo o una trampa.

---

## 3. Segunda moneda (idea #6)

**Qué.** Una moneda premium ("fichas" o similar) que no se farmea fácil y sirve
para: cosméticos del local, acelerar la ganancia por X horas, y canjearse por
monedas normales. Se consigue por rewarded, por compra directa y en cantidades
chicas jugando.

**Por qué conviene tenerla.** Separa la economía del juego de la economía de la
tienda. Sin ella, cualquier ajuste de precios de la tienda descompensa el
balance del juego entero.

**Cómo hacerlo bien**
- Que se pueda ganar jugando, aunque sea lento. Una moneda 100% de pago rompe
  la regla de "aceleración, no acceso".
- Que sirva sobre todo para **cosméticos**, que no afectan el balance.
- Que el canje fichas → monedas exista, pero **no al revés**: si se pudieran
  comprar fichas con monedas, la moneda premium pierde sentido.

---

## 4. Curva de dificultad y monetización (idea #8)

Preguntaste directamente si es correcto que subir de nivel se vuelva
proporcionalmente más difícil pensando en monetizar. **Sí, pero con una
distinción que es la que decide si el juego vive o muere.**

**Lo que es correcto y estándar.** Que el costo de cada mejora crezca más
rápido que el ingreso, de modo que el tiempo hasta la siguiente meta se alargue
gradualmente. Todos los juegos del género lo hacen y no es un truco sucio: es
lo que hace que una mejora en el nivel 20 se sienta como un logro y no como un
trámite.

**Lo que hace que la gente desinstale**, y que no es lo mismo:

| Sano | Tóxico |
|---|---|
| El progreso se hace más lento **de a poco** | Aparece un **muro** de golpe en un nivel |
| Siempre hay una meta visible a la vista | La siguiente meta está a semanas |
| Pagar **acelera** | Pagar **desbloquea** |
| Lo ganado no se pierde nunca | Se te quita lo que ya conseguiste |
| Cada sesión deja algo | Hay sesiones donde no avanzas nada |

**La regla práctica:** el jugador tiene que poder terminar **cada sesión** con
al menos una cosa conseguida — un producto nuevo en el álbum, una fila del
tablero, un nivel de jugador. Si una sesión de 5 minutos no deja nada, esa es
la sesión después de la cual desinstalan. No es la lentitud lo que expulsa: es
la sensación de estar corriendo sin moverse.

**Cómo medirlo cuando haya datos.** Mirar el tiempo entre mejoras por nivel de
jugador. Si entre dos niveles consecutivos se duplica de golpe, ahí hay un muro
y hay que suavizarlo, aunque a corto plazo venda más.

---

## 5. Eventos y temporadas (idea #9)

Es acá donde está la retención de verdad, más que en cualquier ajuste de
precios.

**Lo que vale la pena copiar del género**

| Mecánica | Por qué funciona |
|---|---|
| Evento de temporada con pista de premios | Da una meta nueva sin tocar el juego base |
| Misión diaria simple | Razón concreta para abrir la app hoy |
| Colección temática limitada | La colección incompleta tira más que un premio |
| Racha con protección | Premia la constancia sin castigar el día que faltaste |
| Recompensa por volver | Recupera al que se fue, en vez de darlo por perdido |
| Contenido "de la casa" en el local | Lo que compraste sigue visible, no se consume |

Calendario natural para un almacén: Fiestas Patrias (Chile), Navidad, Año
Nuevo, vuelta a clases, verano/invierno, Pascua, Mundial, Juegos Olímpicos.
Cada evento es sobre todo **una cadena de productos temática y un cosmético**,
que es contenido barato de producir sobre el motor que ya existe.

**Lo que NO conviene copiar**
- Vidas que se agotan y hay que esperar o pagar. Es lo primero que la gente
  nombra cuando dice que un juego "se puso pesado", y choca de frente con
  "jugable en cualquier rato".
- Niveles diseñados para ser imposibles sin comprar.
- Cuentas regresivas falsas y ofertas que "vencen" y reaparecen.
- Notificaciones con culpa ("tu kiosko te extraña"). Ya está prohibido en el
  brief y se mantiene.

**Lo que esto exige técnicamente:** Remote Config, para poder lanzar y apagar
un evento sin publicar una versión nueva. Sin eso, cada evento es un release y
el calendario se vuelve inmanejable para una persona sola.

---

## 6. Mafia y barrios (idea #11)

La idea tiene una mitad muy buena y una mitad riesgosa, y conviene separarlas.

### La mitad buena: los barrios

**Un menú de barrios con arriendo y riesgo distintos es una meta de largo plazo
excelente**, y encaja perfecto con lo que ya existe: hoy el techo del juego es
el nivel 7 del local. Barrios agregan un eje entero de progresión — barrio
barato con poco tráfico, barrio caro con clientes que pagan más — y dan un
sumidero de monedas grande y con sentido narrativo.

### La mitad riesgosa: que te quiten lo ganado

Que la mafia **saquee mercadería o monedas ya conseguidas** es el punto que yo
no haría, por tres razones concretas:

1. **Choca con el principio del juego.** Perder progreso por no haber abierto
   la app castiga a quien tiene vida fuera del teléfono. El público 30–60 en el
   micro es exactamente el que peor lo tolera.
2. **La aversión a la pérdida vende, pero quema.** Funciona a corto plazo y es
   de las principales causas de reseñas de una estrella y desinstalación.
3. **Que el juego te degrade de barrio por no pagar el arriendo estando
   offline** es la versión más dura de lo mismo: te castiga por no jugar.

### Cómo conservar la tensión sin el castigo

| En vez de… | Hacer… |
|---|---|
| Saquear el inventario | Bajar el **ingreso futuro** unas horas ("el barrio quedó nervioso") |
| Confiscar monedas | Que los clientes paguen menos un rato |
| Degradar de barrio por no pagar | Que el barrio caro simplemente **no se pueda mantener** y haya que volver, sin perder nada de lo comprado |
| Protección sólo con moneda premium | Protección pagable con monedas normales; la premium sólo **acelera** |

Así se mantiene la decisión interesante —¿pago protección o me arriesgo?— y el
incentivo a entrar seguido, pero lo peor que puede pasar es **ganar menos por
un rato**, nunca perder lo que ya conseguiste. La diferencia entre "gané menos
de lo que podría" y "me quitaron lo mío" es enorme para la retención.

**Nota de tono.** "Mafia" en un juego cálido de barrio puede leerse pesado.
Vale considerar un antagonista más suave y más universal para distribución
global: la competencia del supermercado, la inspección municipal, una racha de
mala suerte. La mecánica es idéntica y no arrastra connotaciones.

---

## 7. Cigarrillos y licores: recomiendo no incluirlos (idea #7)

Preguntaste si vale la pena. **Mi recomendación es que no**, y el motivo es
concreto, no de gusto.

**Lo que cuesta**
- **Clasificación de contenido.** El cuestionario IARC pregunta explícitamente
  por alcohol y tabaco. Incluirlos sube la clasificación de la ficha, lo que
  reduce el público alcanzable y cambia cómo Play muestra la app.
- **Publicidad.** Buena parte de las redes de anuncios restringen inventario en
  apps con contenido de alcohol o tabaco. Con la monetización apoyada en
  rewarded, eso pega directo en el ingreso.
- **Distribución global.** Varios países tienen reglas más estrictas todavía
  sobre representación de tabaco. Lo que en Chile pasa desapercibido, en otros
  mercados es un problema de ficha.
- **Desarrollo.** El castigo por vender a un menor exige caracterizar la edad
  de cada cliente: es una capa nueva de datos y de UI.

**Lo que se gana:** una cadena de productos más. Exactamente lo mismo que dan
chocolates, huevos, lácteos o aseo, que no traen ninguno de esos costos.

**Ya implementé la parte buena de tu idea**: agregué **Huevos (3 niveles)** y
**Aseo (4 niveles)**, que se desbloquean en niveles de jugador altos. Y demuestran
lo otro que planteaste — **que no todas las cadenas necesitan 5 niveles**: una
corta se completa rápido y da un logro temprano; una larga sostiene el juego a
la larga.

Si más adelante quisieras el ángulo de "vender responsablemente", se puede
hacer con productos sin carga regulatoria: pedidos que exigen verificar algo,
clientes que piden fiado, un producto vencido que no hay que vender. La
mecánica interesante se conserva y la ficha no cambia.

---

## 8. Orden sugerido de implementación

1. **Firebase + Remote Config + Crashlytics** (Fase 2). Sin Remote Config no se
   pueden hacer eventos ni ajustar balance sin publicar.
2. **Menú de monedas sin tienda todavía**: mostrar ganancia por hora y por día.
   Es útil por sí solo y deja la puerta lista.
3. **Rewarded** en los tres casos donde ahorra tiempo sin dar poder: duplicar
   ganancia acumulada, caja XL, cambiar pedido gratis.
4. **Compra única "sin anuncios"**. Es lo más simple de operar y lo que menos
   rechazo genera.
5. **Packs de monedas.**
6. **Segunda moneda** — sólo cuando haya cosméticos que comprar con ella.
7. **Eventos de temporada**, empezando por uno solo bien hecho.
8. **Barrios**, en la versión sin confiscación.

Los primeros cinco puntos son los que producen ingreso. Los últimos tres son
los que producen retención, que es lo que hace que el ingreso valga la pena.

---

## 9. Lo que no se hace, pase lo que pase

Esto no es una lista de buenas intenciones: son las cosas que, si se hacen,
hacen que todo lo demás deje de importar.

- Empeorar el juego para vender el arreglo.
- Quitarle al jugador algo que ya ganó.
- Cuentas regresivas falsas u ofertas que mienten.
- Anuncios durante un arrastre o al abrir la app.
- Anuncios antes de que el jugador entienda el juego.
- Condicionar el rescate por bloqueo a ver un anuncio. Es gratis y se queda
  gratis.
- Notificaciones que usan culpa.
- Diseñar o promocionar hacia menores.
