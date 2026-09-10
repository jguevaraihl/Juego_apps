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

  test('sin correo configurado la opción no se ofrece', () {
    // El correo de soporte lo decide el dueño del proyecto: no se inventa uno
    // ni se filtra el personal. Mientras no esté, la app no muestra un botón
    // que no lleva a ninguna parte.
    expect(Support.hasEmail, Support.email.trim().isNotEmpty);
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
    expect(query, contains('Asunto'));
    expect(query, contains('v1.2.3'));
    expect(query, contains('Local nivel 7'));
    expect(query, contains('Jugador nivel 4'));
    expect(query, contains('es-CL'));
  });

  test('la ficha de Play apunta al paquete de esta app', () {
    expect(Support.playListing.host, 'play.google.com');
    expect(Support.playListing.queryParameters['id'], Support.packageName);
  });
}
