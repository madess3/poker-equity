import 'hand_eval.dart';

enum Variant { holdem, omaha, omahaHiLo, shortDeck, pineapple }

/// Правила конкретного расчёта.
class Rules {
  const Rules(this.variant, {this.hole = 2, this.tripsOverStraight = false});

  final Variant variant;
  final int hole; // карт на руке при раздаче
  final bool tripsOverStraight; // шорт-дек: сет > стрит

  bool get isOmaha => variant == Variant.omaha || variant == Variant.omahaHiLo;
  bool get hiLo => variant == Variant.omahaHiLo;
  bool get short => variant == Variant.shortDeck;

  /// Колода: 52 карты, в шорт-деке 36 (6..A).
  List<int> fullDeck() => [
    for (var c = 0; c < 52; c++)
      if (!short || (c >> 2) >= 4) c,
  ];

  int get deckSize => short ? 36 : 52;

  /// Оценка хай-руки (рука уже без сброшенной карты, борд из 5 карт).
  int hiScore(List<int> hand, List<int> board) {
    if (isOmaha) return bestOmaha(hand, board);
    if (short) return evaluateShort2(hand, board, tripsOverStraight);
    return evaluate2(hand, board);
  }

  /// Сколько «единиц работы» стоит оценка одной руки (для выбора перебор/симуляция).
  int evalCost(int handSize) {
    if (!isOmaha) return 1;
    final pairs = handSize * (handSize - 1) ~/ 2;
    return pairs * 10 * (hiLo ? 2 : 1);
  }

  int category(int score) =>
      stdCategory(score, short: short, tripsOverStraight: tripsOverStraight);
}
