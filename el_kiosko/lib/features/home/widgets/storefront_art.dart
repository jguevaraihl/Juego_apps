import 'package:flutter/widgets.dart';

/// Registro de las fachadas **ilustradas** que vienen empaquetadas en la app.
///
/// Hoy está vacío a propósito: no hay ninguna ilustración encargada todavía y
/// el juego se ve con la fachada dibujada en código (`StorefrontPainter`). El
/// registro existe para que agregar el arte cuando llegue sea dejar los
/// archivos en su carpeta y sumar una línea acá, sin tocar el motor, el
/// guardado ni la lógica del juego.
///
/// El encargo —lienzo, encuadre, qué va en cada nivel, qué se entrega— está en
/// `ART_PROMPTS.md`. Lo que este archivo fija es el **contrato técnico** entre
/// esas imágenes y la app.
///
/// **El painter no se borra.** Es el respaldo: sostiene los niveles que
/// todavía no tienen ilustración, y deja el juego jugable si el arte nunca
/// llega. Se puede activar de a un nivel.
class StorefrontArt {
  const StorefrontArt._();

  static const String _dir = 'assets/art/storefront';

  /// Los niveles con ilustración. Vacío ⇒ todo se dibuja en código.
  ///
  /// Al agregar un nivel hay que declarar también los archivos en `pubspec.yaml`
  /// y verificar el resultado en el teléfono: la fachada se ve a 340×96 px en
  /// la pantalla de juego, que es donde una ilustración bonita puede volverse
  /// una mancha ilegible.
  static const Map<int, StorefrontArtSpec> byLevel = <int, StorefrontArtSpec>{};

  static StorefrontArtSpec? forLevel(int level) => byLevel[level];

  /// Las rutas que le corresponden a un nivel, con la convención de nombres
  /// del encargo. Es una función y no texto suelto para que un archivo mal
  /// nombrado se note al escribir la entrada del registro y no en producción.
  static StorefrontArtSpec spec(
    int level, {
    bool hasNight = true,
    bool hasAwningLayer = true,
  }) => StorefrontArtSpec(
    day: '$_dir/level_$level.webp',
    night: hasNight ? '$_dir/level_${level}_night.webp' : null,
    awning: hasAwningLayer ? '$_dir/level_${level}_awning.webp' : null,
  );
}

/// Los archivos de un nivel ilustrado y dónde cae su letrero.
class StorefrontArtSpec {
  const StorefrontArtSpec({
    required this.day,
    this.night,
    this.awning,
    this.signRect = const Rect.fromLTRB(0.22, 0.26, 0.78, 0.40),
  });

  /// La fachada de día. Es el único archivo obligatorio.
  final String day;

  /// La misma fachada reencendida de noche, para el modo oscuro. Si falta se
  /// usa la de día: el juego no se rompe, sólo se ve un almacén a pleno sol
  /// dentro de una pantalla oscura.
  final String? night;

  /// El toldo suelto, transparente y en escala de grises, para poder teñirlo
  /// con el color que eligió el jugador. Si falta, el toldo va pintado en la
  /// fachada y la elección de color deja de verse en esta.
  final String? awning;

  /// Dónde está el panel vacío del letrero, en fracciones del ancho y del alto
  /// de la imagen. Encima de ese rectángulo la app escribe el nombre que puso
  /// el jugador, que por eso no puede venir pintado.
  final Rect signRect;

  bool get tintsAwning => awning != null;
}
