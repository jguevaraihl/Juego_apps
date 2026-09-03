import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/progression/shop_tiers.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/game_strings.dart';
import 'storefront_art.dart';
import 'storefront_painter.dart';

/// Fachada del local: la meta visible de largo plazo. Cada nivel agrega toldo,
/// letrero, estantes, clientes e iluminación. Sube de nivel ⇒ se ve distinto.
///
/// Tiene dos caminos. Si el nivel tiene ilustración encargada
/// ([StorefrontArt]) se pinta esa; si no, se dibuja en código
/// ([StorefrontPainter]), que es el respaldo y sostiene el juego mientras no
/// haya arte —o si nunca lo hay—. El encargo está en `ART_PROMPTS.md`.
class Storefront extends StatelessWidget {
  const Storefront({
    required this.tier,
    this.height = 120,
    this.animate = true,
    this.storeName,
    this.awningColor = 0,
    this.petId = 0,
    this.art,
    super.key,
  });

  final ShopTier tier;
  final double height;
  final bool animate;

  /// Nombre puesto por el jugador. null = el nombre del nivel, como antes.
  final String? storeName;

  /// Índice en [AppTheme.awningPalette].
  final int awningColor;

  /// Mascota elegida por el jugador.
  final int petId;

  /// La ilustración de este nivel, si hay una. Se resuelve del registro
  /// ([StorefrontArt]) salvo en tests, que la inyectan para probar el camino
  /// del arte sin depender de que haya assets encargados.
  final StorefrontArtSpec? art;

  /// Dónde se ancla el recorte de la ilustración. La imagen es 2:1 y el banner
  /// de la pantalla de juego es mucho más ancho, así que sobra alto y hay que
  /// elegir qué se pierde: anclado algo por encima del centro, se conserva el
  /// letrero y el toldo y se sacrifica la vereda, que es decorativa (la "zona
  /// crítica" del encargo, en ART_PROMPTS.md §1.4).
  ///
  /// Lo usan la capa de imagen y la cuenta que ubica el letrero, y **tienen
  /// que ser el mismo valor**: si se separan, el nombre del local queda flotando
  /// fuera de su panel.
  static const Alignment _artAlignment = Alignment(0, -0.1);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String sign = storeName ?? l.shopTierName(tier.level);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final StorefrontArtSpec? spec = art ?? StorefrontArt.forLevel(tier.level);

    return Semantics(
      label: '$sign. ${l.shopTierTagline(tier.level)}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: animate ? 420 : 0),
            child: KeyedSubtree(
              // La key incluye letrero y toldo: sin eso, cambiar el nombre o
              // el color no volvería a pintar, porque el nivel no cambió.
              key: ValueKey<String>(
                '${tier.level}|$sign|$awningColor|$petId|${dark ? 'n' : 'd'}',
              ),
              child: spec == null
                  ? _painted(sign, dark)
                  : _illustrated(context, spec, sign, dark),
            ),
          ),
        ),
      ),
    );
  }

  /// El respaldo: la fachada dibujada con `CustomPainter`.
  Widget _painted(String sign, bool dark) => CustomPaint(
    painter: StorefrontPainter(
      tier: tier,
      signText: sign,
      awning: AppTheme.awningAt(awningColor),
      dark: dark,
      petId: petId,
    ),
    size: Size.infinite,
  );

  /// La fachada ilustrada, por capas: la pintura, el toldo teñido con el color
  /// que eligió el jugador, y encima el nombre del local.
  ///
  /// El nombre se escribe acá y no viene pintado en la imagen porque lo elige
  /// el jugador y cambia con el idioma: una fachada con el texto incrustado
  /// serviría para un solo nombre y un solo país.
  Widget _illustrated(
    BuildContext context,
    StorefrontArtSpec spec,
    String sign,
    bool dark,
  ) {
    final String path = dark ? (spec.night ?? spec.day) : spec.day;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        Widget layer(String asset, {Color? tint}) => Positioned.fill(
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: _artAlignment,
            color: tint,
            colorBlendMode: tint == null ? null : BlendMode.modulate,
            filterQuality: FilterQuality.medium,
            // Si el archivo falta o está corrupto no se cae el juego: se ve la
            // fachada dibujada, que es exactamente para lo que está.
            errorBuilder: (_, _, _) => _painted(sign, dark),
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            layer(path),
            if (spec.awning != null)
              layer(spec.awning!, tint: AppTheme.awningAt(awningColor)),
            _signText(context, spec, sign, box.biggest),
          ],
        );
      },
    );
  }

  /// El nombre del local sobre el panel vacío del letrero.
  ///
  /// El rectángulo viene en fracciones de la imagen, pero la imagen está
  /// recortada dentro de la caja, así que hay que rehacer la misma cuenta que
  /// hace `BoxFit.cover` para saber dónde cayó el panel en pantalla.
  Widget _signText(
    BuildContext context,
    StorefrontArtSpec spec,
    String sign,
    Size box,
  ) {
    const double imageAspect = 2; // 2048×1024, fijado en ART_PROMPTS.md §1.4.
    // Lo mismo que hace BoxFit.cover: la imagen se agranda hasta tapar la caja
    // y lo que sobra se reparte según el anclaje.
    final double drawnHeight = math.max(box.width / imageAspect, box.height);
    final double drawnWidth = drawnHeight * imageAspect;
    final double dx = (box.width - drawnWidth) / 2 * (1 + _artAlignment.x);
    final double dy = (box.height - drawnHeight) / 2 * (1 + _artAlignment.y);

    final Rect r = spec.signRect;
    return Positioned(
      left: dx + r.left * drawnWidth,
      top: dy + r.top * drawnHeight,
      width: r.width * drawnWidth,
      height: r.height * drawnHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          sign,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.brandWoodDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
