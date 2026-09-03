# Dirección de arte

## Dónde estamos, dicho sin adornos

Todo el arte del juego está **dibujado en código** con `CustomPainter`: la
fachada, los productos, los clientes, los íconos. No hay un solo archivo de
imagen, y por eso no hay ninguna licencia pendiente (ver `ASSET_LICENSES.md`).

Eso tiene un techo, y conviene decirlo claro: **esto no va a verse como Clash
of Clans, y no es cuestión de dedicarle más horas.** Ese tipo de gráfica es
ilustración y modelado hechos por artistas profesionales, con horas de pintura
por elemento. Lo que sí puede hacer el código es una escena vectorial limpia,
legible y con progresión clara — que es lo que hay hoy.

La comparación honesta no es con Clash of Clans sino con juegos como *Merge
Mansion* en sus primeras versiones, o con la gráfica plana de un *Two Dots*.

## Lo que sí se hizo

`storefront_painter.dart` pinta la fachada por capas, de atrás hacia adelante,
como un decorado de teatro: cielo, edificios vecinos, muro con textura de
ladrillo, letrero, toldo con ondas, vitrina con reflejo, estantes con
mercadería, mesón, vereda y clientes.

Cada capa consulta el nivel del local para decidir si aparece, así que subir de
nivel **no es lo mismo pero más grande**: entran elementos nuevos.

| Nivel | Qué entra |
|---|---|
| 1 | Muro de ladrillo desnudo, cartón escrito a mano, un tablón, un cliente |
| 2 | Letrero de verdad, toldo a rayas, segundo estante, segundo cliente |
| 3 | Vitrina con vidrio y reflejo, zócalo pintado, edificios vecinos, clientes con bolsa |
| 4 | Cuarto estante, balanza en el mesón, planta, varillas del toldo |
| 5 | Ampolletas en el letrero, pizarra de precios en la vereda, cruceta en la vitrina |
| 6 | Segunda vitrina, el gato del almacén sobre el cajón |
| 7 | Muro completamente revocado y claro, la escena llena |

Además, del nivel 6 en adelante aparece el gato del almacén — y desde que el
jugador puede elegir mascota (D-055), ese lugar lo ocupa la que haya elegido:
gato, perro, loro o tortuga.

En modo oscuro la escena pasa a ser **de noche**: cielo azul profundo, luna,
ventanas encendidas en los vecinos, vitrina iluminada desde adentro y un haz de
luz cálida cayendo sobre la vereda. La fachada no se "invierte" —sigue siendo
el mismo almacén— pero deja de ser un recorte a plena luz sobre fondo negro.

## Si se quiere arte de verdad

**El enchufe ya está puesto y probado.** `Storefront` mira el registro
`StorefrontArt`: si el nivel tiene ilustración la pinta, y si no cae al painter.
Hoy el registro está vacío, así que el juego se ve exactamente como se veía.

Activar un nivel ilustrado es dejar los archivos en `assets/art/storefront/` y
sumar una línea al registro. Se puede hacer **de a un nivel**. No hay que tocar
el motor, ni el save, ni la lógica del juego.

El camino del arte —imagen de día, versión de noche para el modo oscuro, toldo
en capa aparte teñido con el color que eligió el jugador, y el nombre del local
escrito encima del panel en blanco— está cubierto por tests con un asset falso
(`test/widget/storefront_art_test.dart`), incluido el caso de un archivo mal
declarado en el `pubspec`: ahí se cae al dibujo en código en vez de dejar un
hueco gris donde va el local del jugador.

**El painter no se borra nunca.** Es el respaldo permanente.

Las opciones reales, con lo que implica cada una:

**1. Encargar las siete fachadas a un ilustrador.** Es lo que da el mejor
resultado y el más coherente. Hay que presupuestarlo con un artista; el rango
depende del nivel de detalle y de los derechos que se compren. Pedir siempre
cesión de derechos comercial por escrito, no sólo "permiso de uso".

**2. Comprar un pack de assets con licencia comercial.** Más barato y más
rápido, pero el juego se parece a otros que usan el mismo pack, y hay que leer
la licencia con cuidado: muchos packs "gratis" prohíben el uso comercial o
exigen atribución en un lugar visible.

**3. Generar el arte con una herramienta de IA.** Es la más barata, pero es la
que más cuidado necesita: hay que verificar los términos de la herramienta
respecto de uso comercial, y la coherencia entre las siete fachadas es difícil
de conseguir. **No se hizo por cuenta propia**: es una decisión con
implicancias legales y de marca que corresponde al dueño del proyecto, no a
quien escribe el código.

> **El encargo ya está escrito: `ART_PROMPTS.md`.** Sirve igual para las tres
> opciones —a un ilustrador humano se le pasa como brief y a una herramienta de
> IA como prompt—. Trae las reglas de encuadre que hacen que las siete se vean
> como el mismo local mejorando, los siete prompts, las versiones de noche, las
> cuatro mascotas, las especificaciones de entrega y la lista con la que
> rechazar una entrega mala.

Mi recomendación es la **1** para las siete fachadas —son sólo siete imágenes y
es lo que más se mira— y dejar el resto (productos, clientes, íconos) dibujado
en código, donde el estilo plano funciona bien y además escala a cualquier
tamaño sin pesar nada.

## Lo que NO conviene cambiar a imágenes

- **Las fichas de producto.** Son 22 y tienen que verse nítidas a 40 px y a
  80 px, en claro y en oscuro. Dibujadas escalan sin peso.
- **Los clientes.** Se generan a partir de su id, así que hay doce caras
  distintas sin doce archivos.
- **El ícono del aviso.** Android lo dibuja como silueta; tiene que ser un
  glifo monocromo (ver D-039).
