/// Dónde llegan los comentarios de los jugadores, y a dónde va la ficha de la
/// app en Google Play.
///
/// **Lo único que hay que editar acá es el correo**, y es intencional que sea
/// una sola línea en un solo archivo: el correo de soporte es un dato que
/// Google Play exige de todas formas, tiene que ser real y estar atendido, y
/// **sólo el dueño del proyecto puede decidir cuál exponer públicamente**. Por
/// eso no viene puesto: no se inventa una dirección ni se filtra una personal.
///
/// Se puede fijar de dos maneras:
///
/// 1. Cambiando [_fallbackEmail] abajo, o
/// 2. Al compilar, sin tocar el código:
///    `flutter build appbundle --dart-define=SUPPORT_EMAIL=hola@midominio.cl`
///
/// La segunda es la que conviene si algún día el correo cambia: no obliga a
/// tocar el repositorio.
library;

class Support {
  const Support._();

  /// El correo de soporte, confirmado por el dueño del proyecto.
  ///
  /// **El `+kiosko` no es un error de tipeo.** Gmail entrega
  /// `usuario+loquesea@gmail.com` al mismo buzón que `usuario@gmail.com`, pero
  /// deja la etiqueta en la cabecera `Para:`. Eso da tres cosas que la
  /// dirección pelada no da:
  ///
  /// 1. Un filtro **exacto y a prueba de idiomas**: `to:` con esta dirección
  ///    captura todos los comentarios del juego y ninguna otra cosa. Filtrar
  ///    por asunto fallaría, porque el asunto cambia con el idioma del jugador.
  /// 2. Si algún día el correo se llena de spam, se sabe que salió de acá.
  /// 3. Se puede cambiar el destino sin publicar una versión nueva de la app.
  ///
  /// Para volver a la dirección pelada basta con borrar `+kiosko`.
  static const String _fallbackEmail = 'jguevaraihl+kiosko@gmail.com';

  static const String email = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: _fallbackEmail,
  );

  /// Si no hay correo configurado, la app **no muestra** la opción de escribir
  /// en vez de mostrar un botón que no lleva a ninguna parte.
  static bool get hasEmail => email.trim().isNotEmpty;

  /// La versión que se muestra en el pie del correo.
  ///
  /// Está escrita acá y no leída del paquete para no sumar una dependencia
  /// sólo por un número. Hay un test que la compara contra `pubspec.yaml` y
  /// falla si se desincronizan, que es exactamente el error que un comentario
  /// "recordar actualizar" no evita.
  static const String appVersion = '0.1.0';

  /// Prefijo del asunto, igual en todos los idiomas.
  static const String subjectPrefix = '[El Kiosko]';

  /// El identificador del paquete en Play. Tiene que coincidir con el
  /// `applicationId` de `android/app/build.gradle.kts`.
  static const String packageName = 'cl.elkiosko.almacen';

  static Uri get playListing =>
      Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

  /// El correo, con asunto y con un pie de datos técnicos ya escrito.
  ///
  /// El pie existe porque un comentario sin contexto —"se me traba"— no se
  /// puede arreglar: hace falta saber la versión y en qué punto del juego iba.
  /// Va **al final y a la vista**, no oculto: el jugador puede leerlo y
  /// borrarlo si no quiere mandarlo. No lleva nada que identifique a nadie.
  static Uri feedbackMail({
    required String subject,
    required String intro,
    required String diagnosticsTitle,
    required String appVersion,
    required int shopLevel,
    required int playerLevel,
    required String locale,
  }) => Uri(
    scheme: 'mailto',
    path: email,
    query: _query(<String, String>{
      // El prefijo va acá y no en las traducciones a propósito: es lo que
      // hace que el asunto sea reconocible sea cual sea el idioma del
      // jugador, y sirve de segunda llave para el filtro del correo.
      'subject': '$subjectPrefix $subject',
      'body':
          '$intro\n\n\n'
          '---\n'
          '$diagnosticsTitle\n'
          'v$appVersion · Android\n'
          'Local nivel $shopLevel · Jugador nivel $playerLevel\n'
          'Idioma: $locale\n',
    }),
  );

  /// `Uri` codifica el query con reglas que rompen los saltos de línea en
  /// varios clientes de correo; se arma a mano con codificación de porcentaje.
  static String _query(Map<String, String> params) => params.entries
      .map(
        (MapEntry<String, String> e) =>
            '${e.key}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}
