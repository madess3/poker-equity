import 'dart:isolate';
import 'dart:math';

import 'hand_eval.dart';
import 'rules.dart';

/// Доли банка одного борда (5 карт) по правилам игры, сумма = 1.
List<double> boardShares(Rules rules, List<List<int>> hands, List<int> board) {
  final n = hands.length;
  final hi = [for (final h in hands) rules.hiScore(h, board)];
  final best = hi.reduce(max);
  final hw = hi.where((s) => s == best).length;
  var bestLo = -1, lw = 0;
  final lo = List<int>.filled(n, -1);
  if (rules.hiLo) {
    for (var i = 0; i < n; i++) {
      final l = bestLowOmaha(hands[i], board);
      lo[i] = l;
      if (l < 0) continue;
      if (bestLo < 0 || l < bestLo) {
        bestLo = l;
        lw = 1;
      } else if (l == bestLo) {
        lw++;
      }
    }
  }
  final hiPart = bestLo >= 0 ? 0.5 : 1.0;
  return [
    for (var i = 0; i < n; i++)
      (hi[i] == best ? hiPart / hw : 0.0) +
          (bestLo >= 0 && lo[i] == bestLo ? 0.5 / lw : 0.0),
  ];
}

class RunoutRequest {
  const RunoutRequest({
    required this.rules,
    required this.hands,
    required this.board,
    required this.dead,
    required this.runs,
    this.timeMs = 800,
    this.maxDeals = 200000,
  });
  final Rules rules;
  final List<List<int>> hands; // все руки известны
  final List<int> board; // 0, 3 или 4 карты
  final List<int> dead;
  final int runs; // 1..3
  final int timeMs, maxDeals;
}

/// Статистика доли банка игроков при N прогонах.
class RunoutStats {
  RunoutStats(int n)
    : all = List.filled(n, 0),
      none = List.filled(n, 0),
      part = List.filled(n, 0),
      sum = List.filled(n, 0),
      sumSq = List.filled(n, 0);

  final List<double> all, none, part, sum, sumSq;
  int deals = 0;
  bool exact = false;

  void merge(RunoutStats o) {
    for (var i = 0; i < all.length; i++) {
      all[i] += o.all[i];
      none[i] += o.none[i];
      part[i] += o.part[i];
      sum[i] += o.sum[i];
      sumSq[i] += o.sumSq[i];
    }
    deals += o.deals;
  }

  double allOf(int i) => all[i] / deals;
  double noneOf(int i) => none[i] / deals;
  double partOf(int i) => part[i] / deals;
  double mean(int i) => sum[i] / deals;
  double sd(int i) {
    final m = mean(i);
    return sqrt(max(0, sumSq[i] / deals - m * m));
  }
}

/// Хватает ли карт на [runs] прогонов.
bool runoutsFit(RunoutRequest r) {
  final used = {...r.dead, ...r.board, for (final h in r.hands) ...h};
  final left = r.rules.fullDeck().where((c) => !used.contains(c)).length;
  return (5 - r.board.length) * r.runs <= left;
}

Future<RunoutStats?> computeRunoutsAsync(RunoutRequest r) =>
    Isolate.run(() => computeRunouts(r));

/// Прогоны идут подряд из одной колоды без возврата карт; банк делится на
/// равные части по прогонам. null — карт не хватает.
RunoutStats? computeRunouts(RunoutRequest r) {
  if (!runoutsFit(r)) return null;
  final n = r.hands.length;
  final used = {...r.dead, ...r.board, for (final h in r.hands) ...h};
  final deck = [
    for (final c in r.rules.fullDeck())
      if (!used.contains(c)) c,
  ];
  final m = 5 - r.board.length;
  final need = m * r.runs;
  final stats = RunoutStats(n);
  final share = List<double>.filled(n, 0);
  final board = List<int>.filled(5, 0);
  for (var j = 0; j < r.board.length; j++) {
    board[j] = r.board[j];
  }

  void evalDeal(List<int> drawn) {
    for (var i = 0; i < n; i++) {
      share[i] = 0;
    }
    for (var run = 0; run < r.runs; run++) {
      for (var j = 0; j < m; j++) {
        board[r.board.length + j] = drawn[run * m + j];
      }
      final s = boardShares(r.rules, r.hands, board);
      for (var i = 0; i < n; i++) {
        share[i] += s[i] / r.runs;
      }
    }
    for (var i = 0; i < n; i++) {
      final v = share[i];
      if (v > 1 - 1e-9) {
        stats.all[i]++;
      } else if (v < 1e-9) {
        stats.none[i]++;
      } else {
        stats.part[i]++;
      }
      stats.sum[i] += v;
      stats.sumSq[i] += v * v;
    }
    stats.deals++;
  }

  // Тёрн: по одной карте на прогон, прогоны равноправны — перебираем наборы.
  if (m == 1) {
    final drawn = List<int>.filled(need, 0);
    void rec(int start, int depth) {
      if (depth == need) {
        evalDeal(drawn);
        return;
      }
      for (var k = start; k <= deck.length - (need - depth); k++) {
        drawn[depth] = deck[k];
        rec(k + 1, depth + 1);
      }
    }

    rec(0, 0);
    stats.exact = true;
    return stats;
  }

  final rnd = Random();
  final d = [...deck];
  final drawn = List<int>.filled(need, 0);
  final sw = Stopwatch()..start();
  while (stats.deals < r.maxDeals) {
    if ((stats.deals & 127) == 0 && sw.elapsedMilliseconds >= r.timeMs) break;
    for (var j = 0; j < need; j++) {
      final x = j + rnd.nextInt(d.length - j);
      final t = d[j];
      d[j] = d[x];
      d[x] = t;
      drawn[j] = d[j];
    }
    evalDeal(drawn);
  }
  return stats;
}
