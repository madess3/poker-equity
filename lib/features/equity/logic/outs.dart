import 'hand_eval.dart';
import 'rules.dart';

/// Лучшая хай-рука на неполном борде (3–5 карт).
int partialScore(Rules rules, List<int> hand, List<int> board) {
  if (!rules.isOmaha) {
    return rules.short
        ? evaluateShort2(hand, board, rules.tripsOverStraight)
        : evaluate2(hand, board);
  }
  var best = -1;
  final b = board;
  for (var i = 0; i < hand.length; i++) {
    for (var j = i + 1; j < hand.length; j++) {
      for (var x = 0; x < b.length; x++) {
        for (var y = x + 1; y < b.length; y++) {
          for (var z = y + 1; z < b.length; z++) {
            final s = evaluate5(hand[i], hand[j], b[x], b[y], b[z]);
            if (s > best) best = s;
          }
        }
      }
    }
  }
  return best;
}

/// Ауты игрока [player] на следующей улице: карты, после которых он
/// выходит вперёд (единолично), если сейчас не впереди. Все руки известны.
/// Возвращает null, если ауты считать нельзя.
List<int>? computeOuts(
  Rules rules,
  List<List<int>> hands,
  List<int> board,
  List<int> dead,
  int player,
) {
  if (board.length < 3 || board.length > 4) return null;
  if (rules.variant == Variant.pineapple && hands.any((h) => h.length != 2)) {
    return null;
  }
  if (hands.any(
    (h) => h.length != rules.hole && !(rules.variant == Variant.pineapple),
  )) {
    return null;
  }
  final used = {...board, ...dead, for (final h in hands) ...h};
  bool leads(List<int> b) {
    final mine = partialScore(rules, hands[player], b);
    for (var i = 0; i < hands.length; i++) {
      if (i != player && partialScore(rules, hands[i], b) >= mine) return false;
    }
    return true;
  }

  if (leads(board)) return const [];
  return [
    for (final c in rules.fullDeck())
      if (!used.contains(c) && leads([...board, c])) c,
  ];
}

/// Шанс поймать хотя бы один аут: на следующей улице и к риверу.
(double next, double river) outsChance(int outs, int unseen, int streetsLeft) {
  if (unseen <= 0) return (0, 0);
  final next = outs / unseen;
  if (streetsLeft < 2) return (next, next);
  final miss = (unseen - outs) * (unseen - outs - 1) / (unseen * (unseen - 1));
  return (next, 1 - miss);
}
