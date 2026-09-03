import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../game/game_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Ofrece deshacer la última jugada, sobre la barra inferior.
///
/// Es la respuesta a la queja mejor documentada del género: vender o fusionar
/// sin querer. Varios juegos de fusionar tienen artículo de soporte titulado
/// "vendí un objeto sin querer", y la solución que se impuso es exactamente
/// esta —un botón que aparece unos segundos y se va con la jugada siguiente—,
/// no un diálogo de confirmación en cada toque, que estorba mil veces para
/// salvar una.
///
/// No usa un `SnackBar` porque fusionar es el bucle principal: un aviso de
/// ancho completo en cada fusión sería insoportable. Este es chico, va a un
/// costado y no tapa el tablero.
class UndoChip extends StatefulWidget {
  const UndoChip({
    required this.action,
    required this.ticket,
    required this.cost,
    required this.affordable,
    required this.onUndo,
    required this.onExpire,
    this.animate = true,
    super.key,
  });

  final UndoableAction? action;

  /// Sube con cada jugada. Reinicia la cuenta regresiva aunque la acción
  /// deshacible sea del mismo tipo que la anterior.
  final int ticket;

  /// Lo que cuesta deshacer, en monedas. Va escrito en el botón: cobrar sin
  /// avisar sería lo mismo que cobrar a escondidas.
  final int cost;

  /// Si no alcanza, el botón se ve apagado en vez de desaparecer: que se
  /// esfume al quedarse sin monedas parecería un error del juego.
  final bool affordable;

  final VoidCallback onUndo;
  final VoidCallback onExpire;
  final bool animate;

  /// Cuánto se ofrece. Suficiente para reaccionar a un error, corto para que
  /// no se vuelva parte del paisaje.
  static const Duration window = Duration(seconds: 6);

  @override
  State<UndoChip> createState() => _UndoChipState();
}

class _UndoChipState extends State<UndoChip> {
  Timer? _timer;

  @override
  void didUpdateWidget(UndoChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ticket != oldWidget.ticket ||
        widget.action != oldWidget.action) {
      _restart();
    }
  }

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    if (widget.action == null) return;
    _timer = Timer(UndoChip.window, () {
      if (mounted) widget.onExpire();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label(AppLocalizations l, UndoableAction action) => switch (action) {
    UndoableAction.sell => l.undoSell,
    UndoableAction.split => l.undoSplit,
    UndoableAction.buy => l.undoBuy,
    UndoableAction.reroll => l.undoReroll,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final UndoableAction? action = widget.action;

    return AnimatedSwitcher(
      duration: widget.animate
          ? const Duration(milliseconds: 160)
          : Duration.zero,
      child: action == null
          ? const SizedBox.shrink()
          : Material(
              key: ValueKey<UndoableAction>(action),
              color: context.palette.paper,
              elevation: 3,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: widget.affordable ? widget.onUndo : null,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: AppTheme.minTouchTarget,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: context.palette.wood.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.undo,
                        size: 18,
                        color: widget.affordable
                            ? context.palette.wood
                            : context.palette.inkSoft,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _label(l, action),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: widget.affordable
                              ? context.palette.woodDark
                              : context.palette.inkSoft,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.payments,
                        size: 14,
                        color: context.palette.coin,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.cost}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.palette.coin,
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
