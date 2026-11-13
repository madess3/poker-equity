/// Оценка покерной руки из 5–7 карт: чем больше число, тем сильнее рука.
///
/// Число = категория << 20 | старшинство карт по 4 бита.
/// Категории: 0 старшая, 1 пара, 2 две пары, 3 сет, 4 стрит,
/// 5 флеш, 6 фулл-хаус, 7 каре, 8 стрит-флеш (роял — старший стрит-флеш).
library;

const catHigh = 0, catPair = 1, catTwoPair = 2, catTrips = 3, catStraight = 4;
const catFlush = 5, catFullHouse = 6, catQuads = 7, catStraightFlush = 8;

int handCategory(int score) => score >> 20;

int _popcount(int x) {
  var n = 0;
  while (x != 0) {
    x &= x - 1;
    n++;
  }
  return n;
}

/// Старшая карта стрита в маске рангов (туз может быть младшим), или -1.
int straightTop(int rankMask) {
  // бит 0 — туз как единица, бит r+1 — ранг r
  final m = (rankMask << 1) | ((rankMask >> 12) & 1);
  for (var top = 13; top >= 4; top--) {
    final w = 0x1F << (top - 4);
    if (m & w == w) return top - 1;
  }
  return -1;
}

/// Упаковывает до n старших рангов из маски, пропуская excludeMask.
int _kickers(int mask, int n, [int excludeMask = 0]) {
  var out = 0, k = 0;
  for (var r = 12; r >= 0 && k < n; r--) {
    if (mask & (1 << r) != 0 && excludeMask & (1 << r) == 0) {
      out = (out << 4) | r;
      k++;
    }
  }
  return out << (4 * (n - k));
}

int evaluate(List<int> cards) {
  final cnt = List<int>.filled(13, 0);
  final suitMask = List<int>.filled(4, 0);
  var rankMask = 0;
  for (final c in cards) {
    final r = c >> 2;
    cnt[r]++;
    suitMask[c & 3] |= 1 << r;
    rankMask |= 1 << r;
  }

  var flushScore = -1;
  for (final sm in suitMask) {
    if (_popcount(sm) >= 5) {
      final sf = straightTop(sm);
      if (sf >= 0) return (catStraightFlush << 20) | (sf << 16);
      flushScore = (catFlush << 20) | _kickers(sm, 5);
      break;
    }
  }

  var quad = -1, trip1 = -1, trip2 = -1, pair1 = -1, pair2 = -1;
  for (var r = 12; r >= 0; r--) {
    switch (cnt[r]) {
      case 4:
        if (quad < 0) quad = r;
      case 3:
        if (trip1 < 0) {
          trip1 = r;
        } else if (trip2 < 0) {
          trip2 = r;
        }
      case 2:
        if (pair1 < 0) {
          pair1 = r;
        } else if (pair2 < 0) {
          pair2 = r;
        }
    }
  }

  if (quad >= 0) {
    return (catQuads << 20) |
        (quad << 16) |
        (_kickers(rankMask, 1, 1 << quad) << 12);
  }
  if (trip1 >= 0 && (trip2 >= 0 || pair1 >= 0)) {
    final p = trip2 > pair1 ? trip2 : pair1;
    return (catFullHouse << 20) | (trip1 << 16) | (p << 12);
  }
  if (flushScore >= 0) return flushScore;
  final st = straightTop(rankMask);
  if (st >= 0) return (catStraight << 20) | (st << 16);
  if (trip1 >= 0) {
    return (catTrips << 20) |
        (trip1 << 16) |
        (_kickers(rankMask, 2, 1 << trip1) << 8);
  }
  if (pair2 >= 0) {
    final ex = (1 << pair1) | (1 << pair2);
    return (catTwoPair << 20) |
        (pair1 << 16) |
        (pair2 << 12) |
        (_kickers(rankMask, 1, ex) << 8);
  }
  if (pair1 >= 0) {
    return (catPair << 20) |
        (pair1 << 16) |
        (_kickers(rankMask, 3, 1 << pair1) << 4);
  }
  return (catHigh << 20) | _kickers(rankMask, 5);
}
