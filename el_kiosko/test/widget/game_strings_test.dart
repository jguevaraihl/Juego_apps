import 'package:almacen/features/common/game_strings.dart';
import 'package:almacen/game/models/product.dart';
import 'package:almacen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pone [body] dentro de un árbol con localizaciones cargadas.
Future<void> withLocale(
  WidgetTester tester,
  Locale locale,
  void Function(AppLocalizations l) body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (BuildContext context) {
          body(AppLocalizations.of(context));
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  // Regresión: al agregar dos cadenas nuevas se actualizó el catálogo y las
  // traducciones, pero se olvidó el mapeo de nombres de producto. El juego
  // mostraba "huevos 2" y "aseo 3" en los pedidos, porque el switch caía en su
  // caso por defecto. Este test recorre el catálogo entero, así que agregar una
  // cadena sin traducirla falla acá y no en producción.
  for (final Locale locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'todos los productos tienen nombre traducido en ${locale.languageCode}',
      (WidgetTester tester) async {
        await withLocale(tester, locale, (AppLocalizations l) {
          for (final ProductChain chain in ProductCatalog.chains) {
            expect(
              l.chainName(chain.id),
              isNot(chain.id),
              reason: 'la cadena ${chain.id} no tiene nombre traducido',
            );
            for (final int level in chain.levels) {
              final String name = l.productName(chain.id, level);
              expect(
                name,
                isNot('${chain.id} $level'),
                reason: '${chain.id} nivel $level cayó en el caso por defecto',
              );
              expect(name.trim(), isNotEmpty);
            }
          }
        });
      },
    );

    testWidgets(
      'todos los niveles del local tienen nombre en ${locale.languageCode}',
      (WidgetTester tester) async {
        await withLocale(tester, locale, (AppLocalizations l) {
          for (int level = 1; level <= 7; level++) {
            expect(l.shopTierName(level).trim(), isNotEmpty);
            expect(l.shopTierTagline(level).trim(), isNotEmpty);
          }
        });
      },
    );
  }
}
