import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/playing_card.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/cards.dart';

/// Клавиатура карт: 4 ряда мастей × 13 рангов. Занятые карты затемнены.
class CardKeyboard extends StatelessWidget {
  const CardKeyboard({
    super.key,
    required this.used,
    required this.onPick,
    required this.onClear,
    required this.onDone,
    this.ranks = 13,
  });

  final Set<int> used;
  final ValueChanged<int> onPick;
  final VoidCallback onClear; // убрать карту из выбранного слота
  final VoidCallback onDone;
  final int ranks; // 13; для шорт-дека — 9 (6..A)

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  TextButton(onPressed: onClear, child: Text(l.clearCard)),
                  const Spacer(),
                  TextButton(
                    onPressed: onDone,
                    child: Text(
                      l.done,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              for (var s = 0; s < 4; s++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      for (var r = 12; r >= 13 - ranks; r--)
                        Expanded(child: _key(makeCard(r, s), c)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _key(int card, AppColors c) {
    final dim = used.contains(card);
    return Semantics(
      label: cardCode(card),
      button: true,
      enabled: !dim,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Opacity(
          opacity: dim ? 0.25 : 1,
          child: Material(
            color: c.cardFace,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: dim ? null : () => onPick(card),
              child: SizedBox(
                height: 46,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rankLabel(card),
                        style: TextStyle(
                          fontSize: 19,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: suitColor(card),
                        ),
                      ),
                      Text(
                        suitSymbols[cardSuit(card)],
                        style: TextStyle(
                          fontSize: 17,
                          height: 1,
                          color: suitColor(card),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
