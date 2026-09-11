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

  test('el correo lleva etiqueta para poder filtrarlo', () {
    // El "+kiosko" es lo que permite un filtro exacto en el buzón: filtrar por
    // asunto fallaría, porque el asunto cambia con el idioma del jugador.
    // Si algún día se quita, este test recuerda por qué estaba.
    expect(
      Support.email,
      contains('+'),
      reason: 'sin etiqueta, el filtro del correo no puede ser exacto',
    );
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

  test('la ficha de Play apunta al paquete de esta app', () {
    expect(Support.playListing.host, 'play.google.com');
    expect(Support.playListing.queryParameters['id'], Support.packageName);
  });
}
