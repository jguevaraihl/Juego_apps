import 'dart:io';

import 'package:almacen/app/support.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que se le manda al jugador y lo que el jugador nos manda de vuelta.
void main() {
  test('la versión del correo coincide con la del pubspec', () {
    // Un comentario que diga "acordarse de actualizar esto" no evita el error;
    // un test sí. Sin esto, el primer reporte de un bug llegaría con la
    // versión equivocada y se buscaría en el código que no es.
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final RegExpMatch? m = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(m, isNotNull, reason: 'pubspec.yaml sin version');
    expect(Support.appVersion, m!.group(1));
  });

  test('el paquete coincide con el applicationId de Android', () {
    // Si se separan, el botón de "calificar en Google Play" lleva a una ficha
    // que no existe.
    final String gradle = File('android/app/build.gradle.kts')
        .readAsStringSync();
    expect(gradle, contains('applicationId = "${Support.packageName}"'));
  });

  test('hay un correo de soporte configurado', () {
    // Google Play lo exige, y sin él la app esconde la opción de escribir.
    expect(Support.hasEmail, isTrue);
    expect(Support.email, contains('@'));
  });

  test('el correo de soporte no es una cuenta personal', () {
    // La dirección queda pública en la ficha de Play y en la política de
    // privacidad, y eso es irreversible en la práctica. Este test no puede
    // saber de quién es una cuenta, pero sí puede fijar la que se decidió, de
    // modo que sustituirla por otra sea un cambio deliberado y no un descuido.
    expect(Support.email, 'el.kiosko90@gmail.com');
  });

  test('el correo lleva asunto, datos técnicos y nada que identifique', () {
    final Uri uri = Support.feedbackMail(
      subject: 'Asunto',
      intro: 'Escribe acá',
      diagnosticsTitle: 'Datos técnicos',
      appVersion: '1.2.3',
      shopLevel: 7,
      playerLevel: 4,
      locale: 'es-CL',
    );

    expect(uri.scheme, 'mailto');
    final String query = Uri.decodeComponent(uri.query);
    // El prefijo es la segunda llave del filtro y no cambia con el idioma.
    expect(query, contains('${Support.subjectPrefix} Asunto'));
    expect(query, contains('v1.2.3'));
    expect(query, contains('Local nivel 7'));
    expect(query, contains('Jugador nivel 4'));
    expect(query, contains('es-CL'));
  });

  group('política de privacidad', () {
    test('las dos versiones existen en docs/, que es lo que sirve Pages', () {
      // Si el enlace de la app apunta a un archivo que no está en docs/, el
      // jugador —y Google Play, que la revisa— ven un 404. Este test compara
      // la URL contra los archivos del repositorio, no contra una constante.
      for (final String lang in <String>['es', 'en']) {
        final String path = Support.privacyPolicy(lang).pathSegments.last;
        expect(
          File('../docs/$path').existsSync(),
          isTrue,
          reason: 'falta docs/$path, que es a donde apunta la app en "$lang"',
        );
      }
    });

    test('un idioma sin traducir cae en español y no en un 404', () {
      expect(Support.privacyPolicy('pt').path, endsWith('privacidad.html'));
    });

    test('la página declara el mismo paquete que compila Android', () {
      // La política nombra la app por su identificador. Si se separan, dice
      // cosas de una app que no es ésta.
      final String page = File('../docs/privacidad.html').readAsStringSync();
      expect(page, contains(Support.packageName));
      expect(page, contains(Support.appVersion));
    });

    test('el contacto de privacidad es distinto al de comentarios', () {
      // Las solicitudes de datos personales tienen plazos legales y no pueden
      // terminar en la misma carpeta que se revisa una vez por semana.
      expect(Support.privacyEmail, isNot(Support.email));
      for (final String f in <String>['privacidad.html', 'privacy.html']) {
        expect(
          File('../docs/$f').readAsStringSync(),
          contains(Support.privacyEmail),
        );
      }
    });

    test('las páginas no cargan nada de fuera', () {
      // Tienen que abrir siempre, rápido y sin login: Google Play las revisa y
      // los jugadores las consultan desde el teléfono con mala señal. Una
      // fuente remota o un script de terceros son un punto de falla, y además
      // un problema de privacidad en la página que justamente habla de
      // privacidad: cargar algo de otro dominio le entrega la IP del visitante.
      //
      // Se distingue **cargar** de **enlazar**: un `<a href>` a GitHub lo pulsa
      // el visitante si quiere; una hoja de estilos remota se descarga sola.
      final RegExp remoteResource = RegExp(
        r'(<link[^>]+href=|<script[^>]+src=|<img[^>]+src=)"https?:|'
        r'@import\s+(url\()?"?https?:|url\(\s*"?https?:',
        caseSensitive: false,
      );
      for (final String f in <String>[
        'privacidad.html',
        'privacy.html',
        'index.html',
        'estilo.css',
      ]) {
        final String page = File('../docs/$f').readAsStringSync();
        expect(page, isNot(contains('<script')), reason: '$f trae script');
        expect(
          remoteResource.hasMatch(page),
          isFalse,
          reason: '$f carga un recurso de otro dominio',
        );
      }
    });
  });

  test('la ficha de Play apunta al paquete de esta app', () {
    expect(Support.playListing.host, 'play.google.com');
    expect(Support.playListing.queryParameters['id'], Support.packageName);
  });
}
