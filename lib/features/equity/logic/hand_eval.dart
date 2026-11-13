/// Оценка покерных рук: чем больше число, тем сильнее рука.
///
/// Число = значение категории << 20 | старшинство карт по 4 бита.
/// Стандартные категории: 0 старшая, 1 пара, 2 две пары, 3 сет, 4 стрит,
/// 5 флеш, 6 фулл-хаус, 7 каре, 8 стрит-флеш. В шорт-деке значения
/// категорий переставлены (флеш > фулл-хаус, сет/стрит — по правилу).
library;

import 'dart:typed_data';

const catHigh = 0, catPair = 1, catTwoPair = 2, catTrips = 3, catStraight = 4;
const catFlush = 5, catFullHouse = 6, catQuads = 7, catStraightFlush = 8;

/// Значения категорий в шорт-деке (индекс — стандартная категория).
const _shortStraightOverTrips = [0, 1, 2, 3, 4, 6, 5, 7, 8];
const _shortTripsOverStraight = [0, 1, 2, 4, 3, 6, 5, 7, 8];

int handCategory(int score) => score >> 20;

/// Стандартная категория по оценке (для шорт-дека — обратное преобразование).
int stdCategory(
  int score, {
  bool short = false,
  bool tripsOverStraight = false,
}) {
  final v = score >> 20;
  if (!short) return v;
  final t = tripsOverStraight
      ? _shortTripsOverStraight
      : _shortStraightOverTrips;
  return t.indexOf(v);
}

final Int32List _cnt = Int32List(13);
final Int32List _sm = Int32List(4);
int _rm = 0;

void _reset() {
  for (var i = 0; i < 13; i++) {
    _cnt[i] = 0;
  }
  _sm[0] = 0;
  _sm[1] = 0;
  _sm[2] = 0;
  _sm[3] = 0;
  _rm = 0;
}

void _add(int c) {
  final r = c >> 2;
  _cnt[r]++;
  _sm[c & 3] |= 1 << r;
  _rm |= 1 << r;
}

int _pop(int x) {
  var n = 0;
  while (x != 0) {
    x &= x - 1;
    n++;
  }
  return n;
}

int _flushMask() {
  for (var s = 0; s < 4; s++) {
    if (_pop(_sm[s]) >= 5) return _sm[s];
  }
  return 0;
}

/// Старшая карта стрита (туз может быть младшим: A-2-3-4-5), или -1.
int straightTop(int rankMask) {
  final m = (rankMask << 1) | ((rankMask >> 12) & 1);
  for (var top = 13; top >= 4; top--) {
    final w = 0x1F << (top - 4);
    if (m & w == w) return top - 1;
  }
  return -1;
}

/// Стрит в шорт-деке (ранги 6..A, младший стрит A-6-7-8-9), или -1.
int straightTopShort(int rankMask) {
  final m = ((rankMask >> 4) << 1) | ((rankMask >> 12) & 1);
  for (var top = 9; top >= 4; top--) {
    final w = 0x1F << (top - 4);
    if (m & w == w) return top - 1 + 4;
  }
  return -1;
}

int _kick(int mask, int n, [int exclude = 0]) {
  var out = 0, k = 0;
  for (var r = 12; r >= 0 && k < n; r--) {
    if (mask & (1 << r) != 0 && exclude & (1 << r) == 0) {
      out = (out << 4) | r;
      k++;
    }
  }
  return out << (4 * (n - k));
}

int _q = -1, _t1 = -1, _t2 = -1, _p1 = -1, _p2 = -1;

void _groups() {
  _q = _t1 = _t2 = _p1 = _p2 = -1;
  for (var r = 12; r >= 0; r--) {
    final c = _cnt[r];
    if (c == 4) {
      if (_q < 0) _q = r;
    } else if (c == 3) {
      if (_t1 < 0) {
        _t1 = r;
      } else if (_t2 < 0) {
        _t2 = r;
      }
    } else if (c == 2) {
      if (_p1 < 0) {
        _p1 = r;
      } else if (_p2 < 0) {
        _p2 = r;
      }
    }
  }
}

int _enc(int cat, int rest) => (cat << 20) | rest;

int _fullHouse() {
  final p = _t2 > _p1 ? _t2 : _p1;
  return (_t1 << 16) | (p << 12);
}

int _lowerHands(List<int> ord) {
  if (_p2 >= 0) {
    return _enc(
      ord[catTwoPair],
      (_p1 << 16) | (_p2 << 12) | (_kick(_rm, 1, (1 << _p1) | (1 << _p2)) << 8),
    );
  }
  if (_p1 >= 0) {
    return _enc(ord[catPair], (_p1 << 16) | (_kick(_rm, 3, 1 << _p1) << 4));
  }
  return _enc(ord[catHigh], _kick(_rm, 5));
}

const _std = [0, 1, 2, 3, 4, 5, 6, 7, 8];

int _scoreStd() {
  final fm = _flushMask();
  if (fm != 0) {
    final sf = straightTop(fm);
    if (sf >= 0) return _enc(catStraightFlush, sf << 16);
  }
  _groups();
  if (_q >= 0) {
    return _enc(catQuads, (_q << 16) | (_kick(_rm, 1, 1 << _q) << 12));
  }
  if (_t1 >= 0 && (_t2 >= 0 || _p1 >= 0)) {
    return _enc(catFullHouse, _fullHouse());
  }
  if (fm != 0) return _enc(catFlush, _kick(fm, 5));
  final st = straightTop(_rm);
  if (st >= 0) return _enc(catStraight, st << 16);
  if (_t1 >= 0) {
    return _enc(catTrips, (_t1 << 16) | (_kick(_rm, 2, 1 << _t1) << 8));
  }
  return _lowerHands(_std);
}

int _scoreShort(bool tripsOverStraight) {
  final ord = tripsOverStraight
      ? _shortTripsOverStraight
      : _shortStraightOverTrips;
  final fm = _flushMask();
  if (fm != 0) {
    final sf = straightTopShort(fm);
    if (sf >= 0) return _enc(ord[catStraightFlush], sf << 16);
  }
  _groups();
  if (_q >= 0) {
    return _enc(ord[catQuads], (_q << 16) | (_kick(_rm, 1, 1 << _q) << 12));
  }
  if (fm != 0) return _enc(ord[catFlush], _kick(fm, 5));
  if (_t1 >= 0 && (_t2 >= 0 || _p1 >= 0)) {
    return _enc(ord[catFullHouse], _fullHouse());
  }
  var best = -1;
  final st = straightTopShort(_rm);
  if (st >= 0) best = _enc(ord[catStraight], st << 16);
  if (_t1 >= 0) {
    final t = _enc(ord[catTrips], (_t1 << 16) | (_kick(_rm, 2, 1 << _t1) << 8));
    if (t > best) best = t;
  }
  if (best >= 0) return best;
  return _lowerHands(ord);
}

/// Лучшая рука из любых карт (5–7).
int evaluate(List<int> cards) {
  _reset();
  for (final c in cards) {
    _add(c);
  }
  return _scoreStd();
}

/// Холдем: лучшая рука из карт руки и борда (без склейки списков).
int evaluate2(List<int> hole, List<int> board) {
  _reset();
  for (final c in hole) {
    _add(c);
  }
  for (final c in board) {
    _add(c);
  }
  return _scoreStd();
}

/// Шорт-дек: лучшая рука из карт руки и борда.
int evaluateShort2(List<int> hole, List<int> board, bool tripsOverStraight) {
  _reset();
  for (final c in hole) {
    _add(c);
  }
  for (final c in board) {
    _add(c);
  }
  return _scoreShort(tripsOverStraight);
}

int evaluate5(int a, int b, int c, int d, int e) {
  _reset();
  _add(a);
  _add(b);
  _add(c);
  _add(d);
  _add(e);
  return _scoreStd();
}

/// Тройки карт борда из 5 карт.
const boardTriples = [
  [0, 1, 2],
  [0, 1, 3],
  [0, 1, 4],
  [0, 2, 3],
  [0, 2, 4],
  [0, 3, 4],
  [1, 2, 3],
  [1, 2, 4],
  [1, 3, 4],
  [2, 3, 4],
];

/// Омаха: ровно 2 карты с руки и 3 с борда (борд из 5 карт).
int bestOmaha(List<int> hole, List<int> board) {
  var best = -1;
  for (var i = 0; i < hole.length; i++) {
    for (var j = i + 1; j < hole.length; j++) {
      for (final t in boardTriples) {
        final s = evaluate5(
          hole[i],
          hole[j],
          board[t[0]],
          board[t[1]],
          board[t[2]],
        );
        if (s > best) best = s;
      }
    }
  }
  return best;
}

/// Ранг для лоу: A=1, 2..8; 0 — не годится для лоу.
int lowRank(int c) {
  final r = c >> 2;
  if (r == 12) return 1;
  if (r <= 6) return r + 2;
  return 0;
}

/// Омаха хай-лоу: лучший лоу (8 или ниже). Меньше — лучше; -1 — нет лоу.
int bestLowOmaha(List<int> hole, List<int> board) {
  var bm = 0;
  for (final c in board) {
    final l = lowRank(c);
    if (l > 0) bm |= 1 << l;
  }
  if (_pop(bm) < 3) return -1;
  var best = -1;
  for (var i = 0; i < hole.length; i++) {
    final a = lowRank(hole[i]);
    if (a == 0) continue;
    for (var j = i + 1; j < hole.length; j++) {
      final b = lowRank(hole[j]);
      if (b == 0 || b == a) continue;
      final avail = bm & ~(1 << a) & ~(1 << b);
      if (_pop(avail) < 3) continue;
      var mask = (1 << a) | (1 << b);
      var k = 0;
      for (var r = 1; r <= 8 && k < 3; r++) {
        if (avail & (1 << r) != 0) {
          mask |= 1 << r;
          k++;
        }
      }
      var v = 0;
      for (var r = 8; r >= 1; r--) {
        if (mask & (1 << r) != 0) v = (v << 4) | r;
      }
      if (best < 0 || v < best) best = v;
    }
  }
  return best;
}

/// Ананас: какую карту сбросить на флопе (индекс 0..2) — оставляем пару,
/// дающую лучшую руку с флопом; при равенстве — более старшую пару.
int pineappleDiscard(List<int> hole3, List<int> flop) {
  var bestIdx = 0, best = -1, bestHi = -1;
  for (var d = 0; d < 3; d++) {
    final a = hole3[d == 0 ? 1 : 0], b = hole3[d == 2 ? 1 : 2];
    final s = evaluate5(a, b, flop[0], flop[1], flop[2]);
    final hi = (a >> 2) + (b >> 2);
    if (s > best || (s == best && hi > bestHi)) {
      best = s;
      bestHi = hi;
      bestIdx = d;
    }
  }
  return bestIdx;
}
