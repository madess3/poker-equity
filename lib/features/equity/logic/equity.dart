import 'dart:isolate';
import 'dart:math';

import 'hand_eval.dart';

/// Входные данные расчёта. Пустые/неполные руки добираются случайно.
class EquityRequest {
  const EquityRequest({
    required this.hands,
    required this.boards,
    this.dead = const [],
    this.holeCards = 2,
    this.samples = 120000,
    this.exactLimit = 400000,
  });

  final List<List<int>> hands; // известные карты каждого игрока
  final List<List<int>> boards; // 1 или 2 борда, известные карты
  final List<int> dead;
  final int holeCards;
  final int samples; // число симуляций, если перебор слишком велик
  final int exactLimit; // максимум вариантов для точного перебора
}

class PlayerEquity {
  PlayerEquity(this.boards);
  final int boards;
  double equity = 0; // доля банка, 0..1
  double win = 0; // единоличная победа (на одном борде)
  double tie = 0; // делёж (на одном борде)
  late final List<double> perBoard = List.filled(boards, 0);
  double scoop = 0; // единоличная победа на всех бордах
}

class EquityResult {
  EquityResult(this.players, {required this.exact, required this.deals});
  final List<PlayerEquity> players;
  final bool exact;
  final int deals;
}

/// Расчёт в отдельном потоке, чтобы не тормозил интерфейс.
/// Функция верхнего уровня: замыкание не должно захватывать виджеты.
Future<EquityResult?> computeEquityAsync(EquityRequest r) =>
    Isolate.run(() => computeEquity(r));

/// Сколько карт нужно добрать из колоды.
int cardsNeeded(EquityRequest r) =>
    r.hands.fold(0, (s, h) => s + r.holeCards - h.length) +
    r.boards.fold(0, (s, b) => s + 5 - b.length);

/// Расчёт эквити. Возвращает null, если колоды не хватает.
EquityResult? computeEquity(EquityRequest r) {
  final used = <int>{...r.dead};
  for (final h in r.hands) {
    used.addAll(h);
  }
  for (final b in r.boards) {
    used.addAll(b);
  }
  final deck = [
    for (var c = 0; c < 52; c++)
      if (!used.contains(c)) c,
  ];
  final need = cardsNeeded(r);
  if (need > deck.length) return null;

  final n = r.hands.length;
  final nb = r.boards.length;
  final res = [for (var i = 0; i < n; i++) PlayerEquity(nb)];

  final hands = [
    for (final h in r.hands) [...h],
  ];
  final boards = [
    for (final b in r.boards) [...b],
  ];
  final scores = List<int>.filled(n, 0);
  final hand7 = List<int>.filled(7, 0);
  final soleWins = List<int>.filled(n, 0);

  // Раскладывает добранные карты по рукам и бордам и считает одну раздачу.
  void deal(List<int> drawn) {
    var k = 0;
    final fullHands = <List<int>>[];
    for (final h in hands) {
      final f = [...h];
      while (f.length < r.holeCards) {
        f.add(drawn[k++]);
      }
      fullHands.add(f);
    }
    for (var i = 0; i < n; i++) {
      soleWins[i] = 0;
    }
    for (var b = 0; b < nb; b++) {
      final board = [...boards[b]];
      while (board.length < 5) {
        board.add(drawn[k++]);
      }
      var best = -1, winners = 0;
      for (var i = 0; i < n; i++) {
        final h = fullHands[i];
        for (var j = 0; j < 2; j++) {
          hand7[j] = h[j];
        }
        for (var j = 0; j < 5; j++) {
          hand7[2 + j] = board[j];
        }
        final s = evaluate(hand7);
        scores[i] = s;
        if (s > best) {
          best = s;
          winners = 1;
        } else if (s == best) {
          winners++;
        }
      }
      final share = 1 / winners / nb;
      for (var i = 0; i < n; i++) {
        if (scores[i] != best) continue;
        final p = res[i];
        p.equity += share;
        p.perBoard[b] += 1 / winners;
        if (winners == 1) {
          p.win += 1 / nb;
          soleWins[i]++;
        } else {
          p.tie += 1 / nb;
        }
      }
    }
    if (nb > 1) {
      for (var i = 0; i < n; i++) {
        if (soleWins[i] == nb) res[i].scoop += 1;
      }
    }
  }

  var deals = 0;
  final combos = _choose(deck.length, need);
  final allKnown = hands.every((h) => h.length == r.holeCards);
  final exact = allKnown && combos <= r.exactLimit;

  if (exact) {
    final drawn = List<int>.filled(need, 0);
    void rec(int start, int depth) {
      if (depth == need) {
        deal(drawn);
        deals++;
        return;
      }
      for (var i = start; i <= deck.length - (need - depth); i++) {
        drawn[depth] = deck[i];
        rec(i + 1, depth + 1);
      }
    }

    rec(0, 0);
  } else {
    final rnd = Random();
    final d = [...deck];
    final drawn = List<int>.filled(need, 0);
    for (var s = 0; s < r.samples; s++) {
      for (var j = 0; j < need; j++) {
        final x = j + rnd.nextInt(d.length - j);
        final t = d[j];
        d[j] = d[x];
        d[x] = t;
        drawn[j] = d[j];
      }
      deal(drawn);
    }
    deals = r.samples;
  }

  for (final p in res) {
    p.equity /= deals;
    p.win /= deals;
    p.tie /= deals;
    p.scoop /= deals;
    for (var b = 0; b < nb; b++) {
      p.perBoard[b] /= deals;
    }
  }
  return EquityResult(res, exact: exact, deals: deals);
}

int _choose(int n, int k) {
  if (k < 0 || k > n) return 0;
  var r = 1;
  for (var i = 0; i < k; i++) {
    r = r * (n - i) ~/ (i + 1);
  }
  return r;
}
