import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../features/equity/logic/cards.dart';
import 'card_slot.dart';
import 'suit_icon.dart';

const _suitColors = [
  SuitColors.spade,
  SuitColors.heart,
  SuitColors.diamond,
  SuitColors.club,
];

Color suitColor(int card) => _suitColors[cardSuit(card)];

/// Ранг над мастью; цвет строго по четырёхцветной колоде.
class CardGlyph extends StatelessWidget {
  const CardGlyph({super.key, required this.card, required this.height});
  final int card;
  final double height; // высота карты

  @override
  Widget build(BuildContext context) {
    final col = suitColor(card);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rankLabel(card),
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: height * 0.44,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: col,
            ),
          ),
          SizedBox(height: height * 0.03),
          SuitIcon(suit: cardSuit(card), size: height * 0.3, color: col),
        ],
      ),
    );
  }
}

/// Карта (или пустой слот, если card == null).
class PlayingCardView extends StatelessWidget {
  const PlayingCardView({
    super.key,
    required this.card,
    this.width = 46,
    this.height = 62,
    this.selected = false,
    this.onTap,
    this.onDoubleTap,
  });

  final int? card;
  final double width;
  final double height;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap; // только у заполненной карты

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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.cardFace,
              borderRadius: BorderRadius.circular(6),
              border: selected ? Border.all(color: accent, width: 2) : null,
            ),
            child: CardGlyph(card: c, height: height),
          );
    if (onTap == null) return face;
    return Semantics(
      container: true,
      button: true,
      label: c == null ? null : cardCode(c),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: c == null ? null : onDoubleTap,
        behavior: HitTestBehavior.opaque,
        child: face,
      ),
    );
  }
}
