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

  /// El correo de soporte del proyecto.
  ///
  /// **Es una cuenta aparte de la personal del owner**, y esa separación es lo
  /// que resuelve de verdad el problema que antes se parchaba con una etiqueta
  /// `+kiosko` sobre una cuenta personal:
  ///
  /// - Todo lo que llega a esta cuenta **es** del proyecto, así que no hace
  ///   falta filtrar nada para que no se mezcle con el correo de la vida.
  /// - Esta dirección va a quedar **pública** en la ficha de Google Play y en
  ///   la política de privacidad. Exponer una cuenta personal ahí es
  ///   irreversible en la práctica: queda en capturas, en cachés y en la ficha.
  /// - Si algún día el proyecto cambia de manos o se le suma alguien, se
  ///   entrega la cuenta y no medio buzón privado.
  ///
  /// La misma cuenta debería usarse para **Play Console y AdMob**: mover una
  /// app entre cuentas de desarrollador después es un trámite caro y lento.
  static const String _fallbackEmail = 'el.kiosko90@gmail.com';

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

  /// La política de privacidad, alojada en GitHub Pages sobre este mismo
  /// repositorio (`docs/`).
  ///
  /// Google Play **exige** una URL accesible sin login, y además conviene que
  /// esté dentro de la app: alguien que quiere saber qué se hace con sus datos
  /// no debería tener que ir a buscarla a la ficha de la tienda.
  ///
  /// Se sirve del repo a propósito: no cuesta nada, no se cae, y el historial
  /// de cambios de la política queda público y verificable, que es justo lo
  /// que una política de privacidad debería poder demostrar.
  static const String _pagesBase = 'https://jguevaraihl.github.io/Juego_apps';

  /// La versión en el idioma del jugador, con el español como respaldo.
  static Uri privacyPolicy(String languageCode) => Uri.parse(
    languageCode == 'en'
        ? '$_pagesBase/privacy.html'
        : '$_pagesBase/privacidad.html',
  );

  /// Para consultas de privacidad.
  ///
  /// Mantiene la etiqueta `+privacidad` aunque la cuenta ya sea exclusiva del
  /// proyecto, y por una razón distinta a la de antes: **no es para separarlo
  /// de lo personal, es para separarlo de lo urgente**. Las solicitudes de
  /// datos personales bajo GDPR o CCPA tienen plazos legales del orden de 30
  /// días; los comentarios sobre el balance del juego pueden esperar al
  /// domingo. Con la etiqueta se puede dejar que los comentarios se archiven
  /// solos y que **éstos** sí lleguen a Recibidos.
  static const String privacyEmail = 'el.kiosko90+privacidad@gmail.com';

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
