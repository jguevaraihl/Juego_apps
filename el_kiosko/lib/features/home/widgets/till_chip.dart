import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';

/// La caja del local: lo que el almacén lleva vendido y el jugador no cobra.
///
/// Va sobre la fachada y no en la barra superior por dos razones: ahí es donde
/// está la caja en la ficción, y la barra superior ya tiene cinco elementos.
///
/// Muestra el saldo con decimales para que se vea acumular, y cambia de color
/// al llenarse: llena, el almacén dejó de producir y hay una razón concreta
/// para tocarla.
class TillChip extends StatelessWidget {
  const TillChip({
    required this.amount,
    required this.capacity,
    required this.onCollect,
    super.key,
  });

  /// Saldo actual, con fracción.
  final double amount;
  final int capacity;
  final VoidCallback onCollect;

  bool get isFull => amount >= capacity;

  double get fillFraction =>
      capacity <= 0 ? 0 : (amount / capacity).clamp(0.0, 1.0);

  /// Dos decimales con el separador del idioma.
  static String _formatted(BuildContext context, double value) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final Color accent = isFull
        ? context.palette.success
        : context.palette.woodDark;

    return Semantics(
      button: true,
      label: isFull ? l.tillFull : l.tillSemantics(amount.floor(), capacity),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCollect,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
            decoration: BoxDecoration(
              color: context.palette.paper.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent, width: isFull ? 2 : 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      isFull ? Icons.savings : Icons.savings_outlined,
                      size: 15,
                      color: accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatted(context, amount),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: 78,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: fillFraction,
                      minHeight: 4,
                      backgroundColor: context.palette.wood.withValues(
                        alpha: 0.18,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ),
                if (isFull)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      l.tillFull,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: context.palette.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
