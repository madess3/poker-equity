import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../features/equity/logic/cards.dart';
import 'card_slot.dart';

const _suitColors = [
  SuitColors.spade,
  SuitColors.heart,
  SuitColors.diamond,
  SuitColors.club,
];

Color suitColor(int card) => _suitColors[cardSuit(card)];

/// Карта (или пустой слот, если card == null). Ранг и масть ≈ 75% высоты.
class PlayingCardView extends StatelessWidget {
  const PlayingCardView({
    super.key,
    required this.card,
    this.width = 46,
    this.height = 62,
    this.selected = false,
    this.onTap,
  });

  final int? card;
  final double width;
  final double height;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final c = card;
    final Widget face = c == null
        ? CardSlot(
            width: width,
            height: height,
            color: selected ? accent : null,
          )
        : Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: context.colors.cardFace,
              borderRadius: BorderRadius.circular(6),
              border: selected ? Border.all(color: accent, width: 2) : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rankLabel(c),
                    style: TextStyle(
                      fontSize: height * 0.45,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: suitColor(c),
                    ),
                  ),
                  Text(
                    suitSymbols[cardSuit(c)],
                    style: TextStyle(
                      fontSize: height * 0.37,
                      height: 1,
                      color: suitColor(c),
                    ),
                  ),
                ],
              ),
            ),
          );
    if (onTap == null) return face;
    return Semantics(
      button: true,
      label: c == null ? null : cardCode(c),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: face,
      ),
    );
  }
}
