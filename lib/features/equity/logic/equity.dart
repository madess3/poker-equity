import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'hand_eval.dart';
import 'outs.dart';
import 'rules.dart';

/// Входные данные расчёта. Пустые/неполные руки добираются случайно,
/// руки с диапазоном — случайной комбинацией из диапазона.
class EquityRequest {
  const EquityRequest({
    required this.rules,
    required this.hands,
    required this.boards,
    this.holeCounts,
    this.ranges,
    this.dead = const [],
    this.keep,
    this.maxDeals = 150000,
    this.timeMs = 0,
    this.allowExact = true,
  });

  final Rules rules;
  final List<List<int>> hands; // известные карты игроков
  final List<int>? holeCounts; // карт у игрока (ананас: 3 до сброса, 2 после)
  final List<List<List<int>>?>? ranges; // диапазон игрока: список комбинаций
  final List<List<int>> boards; // 1–2 борда, известные карты
  final List<int> dead; // мёртвые карты
  final List<List<int>?>? keep; // ананас: какие 2 карты игрок оставляет
  final int maxDeals;
  final int timeMs; // 0 — без ограничения
  final bool allowExact;

  int holeOf(int i) => holeCounts?[i] ?? rules.hole;
  List<List<int>>? rangeOf(int i) {
    final r = ranges?[i];
    return (r == null || r.isEmpty || hands[i].isNotEmpty) ? null : r;
  }

  EquityRequest copyWith({
    int? maxDeals,
    int? timeMs,
    bool? allowExact,
    List<List<int>?>? keep,
    List<int>? dead,
  }) => EquityRequest(
    rules: rules,
    hands: hands,
    boards: boards,
    holeCounts: holeCounts,
    ranges: ranges,
    dead: dead ?? this.dead,
    keep: keep ?? this.keep,
    maxDeals: maxDeals ?? this.maxDeals,
    timeMs: timeMs ?? this.timeMs,
    allowExact: allowExact ?? this.allowExact,
  );
}

/// Накопленные результаты (суммы). Пакеты симуляций можно складывать.
class EquityAcc {
  EquityAcc(this.n, this.nb)
    : eq = Float64List(n),
      win = Float64List(n),
      tie = Float64List(n),
      scoop = Float64List(n),
      hi = Float64List(n),
      lo = Float64List(n),
      perBoard = Float64List(n * nb),
      cat = Int32List(n * 9);

  final int n, nb;
  final Float64List eq, win, tie, scoop, hi, lo, perBoard;
  final Int32List cat; // итоговая категория руки на 1-м борде
  int deals = 0;
  double lowBoards = 0; // сколько бордов с возможным лоу
  bool exact = false;

  void merge(EquityAcc o) {
    for (var i = 0; i < n; i++) {
      eq[i] += o.eq[i];
      win[i] += o.win[i];
      tie[i] += o.tie[i];
      scoop[i] += o.scoop[i];
      hi[i] += o.hi[i];
      lo[i] += o.lo[i];
    }
    for (var i = 0; i < perBoard.length; i++) {
      perBoard[i] += o.perBoard[i];
    }
    for (var i = 0; i < cat.length; i++) {
      cat[i] += o.cat[i];
    }
    deals += o.deals;
    lowBoards += o.lowBoards;
  }

  double _f(double v) => deals == 0 ? 0 : v / deals;
  double equity(int i) => _f(eq[i]);
  double winOf(int i) => _f(win[i]);
  double tieOf(int i) => _f(tie[i]);
  double scoopOf(int i) => _f(scoop[i]);
  double hiOf(int i) => _f(hi[i]);
  double loOf(int i) => _f(lo[i]);
  double board(int b, int i) => _f(perBoard[b * n + i]);
  double lowChance() => deals == 0 ? 0 : lowBoards / (deals * nb);
  double catChance(int i, int c) => deals == 0 ? 0 : cat[i * 9 + c] / deals;
}

Uint8List _usedMask(EquityRequest r) {
  final t = Uint8List(52);
  for (final c in r.dead) {
    t[c] = 1;
  }
  for (final h in r.hands) {
    for (final c in h) {
      t[c] = 1;
    }
  }
  for (final b in r.boards) {
    for (final c in b) {
      t[c] = 1;
    }
  }
  return t;
}

/// Сколько карт нужно добрать (без срезки).
int cardsNeeded(EquityRequest r) {
  var need = 0;
  for (var i = 0; i < r.hands.length; i++) {
    need += r.rangeOf(i) != null
        ? r.holeOf(i)
        : r.holeOf(i) - r.hands[i].length;
  }
  for (final b in r.boards) {
    need += 5 - b.length;
  }
  return need;
}

/// Сколько карт осталось в колоде.
int cardsAvailable(EquityRequest r) {
  final t = _usedMask(r);
  return r.rules.fullDeck().where((c) => t[c] == 0).length;
}

/// Срезка: по карте перед каждой ещё не открытой улицей каждого борда.
int burnsNeeded(EquityRequest r) {
  var n = 0;
  for (final b in r.boards) {
    if (b.length < 3) n++;
    if (b.length < 4) n++;
    if (b.length < 5) n++;
  }
  return n;
}

/// Нужна ли кнопка «Замешать срезку и мак».
bool needsMuck(EquityRequest r) =>
    cardsNeeded(r) + burnsNeeded(r) > cardsAvailable(r);

/// Колода закончилась: делёж банка по уже открытому борду (3–5 карт),
/// без добора. Все руки должны быть известны; иначе null.
EquityAcc? showdownNow(EquityRequest r) {
  final rules = r.rules;
  final board = r.boards.first;
  final n = r.hands.length;
  if (board.length < 3 || r.hands.any((h) => h.length < 2)) return null;
  final acc = EquityAcc(n, 1)..deals = 1;
  final hi = [for (final h in r.hands) partialScore(rules, h, board)];
  final best = hi.reduce(max);
  final hw = hi.where((s) => s == best).length;
  final lo = rules.hiLo
      ? [for (final h in r.hands) bestLowOmaha(h, board)]
      : <int>[];
  final valid = lo.where((l) => l >= 0);
  final bestLo = valid.isEmpty ? -1 : valid.reduce(min);
  final lw = bestLo < 0 ? 0 : lo.where((l) => l == bestLo).length;
  final hiPart = bestLo >= 0 ? 0.5 : 1.0;
  for (var i = 0; i < n; i++) {
    var got = 0.0;
    if (hi[i] == best) {
      got += hiPart / hw;
      acc.hi[i] = 1 / hw;
      if (hw == 1) {
        acc.win[i] = 1;
      } else {
        acc.tie[i] = 1;
      }
    }
    if (bestLo >= 0 && lo[i] == bestLo) {
      got += 0.5 / lw;
      acc.lo[i] = 1 / lw;
    }
    acc.eq[i] = got;
    acc.perBoard[i] = got;
    if (got > 0.999999) acc.scoop[i] = 1;
  }
  if (bestLo >= 0) acc.lowBoards = 1;
  acc.exact = true;
  return acc;
}

/// Расчёт в отдельном потоке, чтобы не тормозил интерфейс.
/// Функция верхнего уровня: замыкание не должно захватывать виджеты.
Future<EquityAcc?> computeEquityAsync(EquityRequest r) =>
    Isolate.run(() => computeEquity(r));

/// Расчёт эквити. null — карт в колоде не хватает.
EquityAcc? computeEquity(EquityRequest r) {
  final rules = r.rules;
  final n = r.hands.length;
  final nb = r.boards.length;
  final taken0 = _usedMask(r);
  final deck = [
    for (final c in rules.fullDeck())
      if (taken0[c] == 0) c,
  ];
  final need = cardsNeeded(r);
  if (need > deck.length) return null;

  final acc = EquityAcc(n, nb);
  final hands = [for (var i = 0; i < n; i++) List<int>.filled(r.holeOf(i), 0)];
  final kept = [for (var i = 0; i < n; i++) List<int>.filled(2, 0)];
  final boards = [for (var b = 0; b < nb; b++) List<int>.filled(5, 0)];
  final hi = Int32List(n), lo = Int32List(n), sole = Int32List(n);
  final pine = rules.variant == Variant.pineapple;

  List<int> playable(int i) {
    final h = hands[i];
    if (!pine || h.length != 3) return h;
    final forced = r.keep?[i];
    if (forced != null) return forced;
    final d = pineappleDiscard(h, boards[0]);
    var k = 0;
    for (var j = 0; j < 3; j++) {
      if (j != d) kept[i][k++] = h[j];
    }
    return kept[i];
  }

  void evalDeal() {
    acc.deals++;
    final hs = [for (var i = 0; i < n; i++) playable(i)];
    for (var i = 0; i < n; i++) {
      sole[i] = 0;
    }
    for (var b = 0; b < nb; b++) {
      final board = boards[b];
      var best = -1, hw = 0, bestLo = -1, lw = 0;
      for (var i = 0; i < n; i++) {
        final s = rules.hiScore(hs[i], board);
        hi[i] = s;
        if (s > best) {
          best = s;
          hw = 1;
        } else if (s == best) {
          hw++;
        }
        if (rules.hiLo) {
          final l = bestLowOmaha(hs[i], board);
          lo[i] = l;
          if (l >= 0) {
            if (bestLo < 0 || l < bestLo) {
              bestLo = l;
              lw = 1;
            } else if (l == bestLo) {
              lw++;
            }
          }
        }
        if (b == 0) acc.cat[i * 9 + rules.category(s)]++;
      }
      final hasLow = rules.hiLo && bestLo >= 0;
      if (hasLow) acc.lowBoards++;
      final hiPart = hasLow ? 0.5 : 1.0;
      for (var i = 0; i < n; i++) {
        var got = 0.0;
        var whole = true;
        if (hi[i] == best) {
          got += hiPart / hw;
          acc.hi[i] += 1 / hw / nb;
          if (hw == 1) {
            acc.win[i] += 1 / nb;
          } else {
            acc.tie[i] += 1 / nb;
            whole = false;
          }
        } else {
          whole = false;
        }
        if (hasLow) {
          if (lo[i] == bestLo) {
            got += 0.5 / lw;
            acc.lo[i] += 1 / lw / nb;
            if (lw > 1) whole = false;
          } else {
            whole = false;
          }
        }
        acc.eq[i] += got / nb;
        acc.perBoard[b * n + i] += got;
        if (whole) sole[i]++;
      }
    }
    for (var i = 0; i < n; i++) {
      if (sole[i] == nb) acc.scoop[i]++;
    }
  }

  // Известные карты ставим в начало рук и бордов.
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < r.hands[i].length; j++) {
      hands[i][j] = r.hands[i][j];
    }
  }
  for (var b = 0; b < nb; b++) {
    for (var j = 0; j < r.boards[b].length; j++) {
      boards[b][j] = r.boards[b][j];
    }
  }

  final allKnown = [for (var i = 0; i < n; i++) i]
      .every((i) => r.rangeOf(i) == null && r.hands[i].length == r.holeOf(i));
  final maxHole = [for (var i = 0; i < n; i++) r.holeOf(i)].fold(2, max);
  final work = _choose(deck.length, need) * n * nb * rules.evalCost(maxHole);

  if (r.allowExact && allKnown && work <= 3000000) {
    // Точный перебор: добираются только карты бордов.
    final slots = <(int, int)>[
      for (var b = 0; b < nb; b++)
        for (var j = r.boards[b].length; j < 5; j++) (b, j),
    ];
    void rec(int start, int depth) {
      if (depth == need) {
        evalDeal();
        return;
      }
      final (b, j) = slots[depth];
      for (var k = start; k <= deck.length - (need - depth); k++) {
        boards[b][j] = deck[k];
        rec(k + 1, depth + 1);
      }
    }

    rec(0, 0);
    acc.exact = true;
    return acc;
  }

  // Симуляция (Монте-Карло).
  final rnd = Random();
  final taken = Uint8List(52);
  final sw = Stopwatch()..start();
  var attempts = 0;
  int draw() {
    while (true) {
      final c = deck[rnd.nextInt(deck.length)];
      if (taken[c] == 0) {
        taken[c] = 1;
        return c;
      }
    }
  }

  while (acc.deals < r.maxDeals) {
    if ((++attempts & 127) == 0 &&
        r.timeMs > 0 &&
        sw.elapsedMilliseconds >= r.timeMs) {
      break;
    }
    if (attempts > r.maxDeals * 4 + 1000) break; // диапазоны не сочетаются
    taken.setAll(0, taken0);
    var ok = true;
    for (var i = 0; i < n && ok; i++) {
      final range = r.rangeOf(i);
      if (range != null) {
        var placed = false;
        for (var t = 0; t < 40; t++) {
          final combo = range[rnd.nextInt(range.length)];
          if (taken[combo[0]] == 0 && taken[combo[1]] == 0) {
            taken[combo[0]] = 1;
            taken[combo[1]] = 1;
            hands[i][0] = combo[0];
            hands[i][1] = combo[1];
            placed = true;
            break;
          }
        }
        ok = placed;
      } else {
        for (var j = r.hands[i].length; j < hands[i].length; j++) {
          hands[i][j] = draw();
        }
      }
    }
    if (!ok) continue;
    for (var b = 0; b < nb; b++) {
      for (var j = r.boards[b].length; j < 5; j++) {
        boards[b][j] = draw();
      }
    }
    evalDeal();
  }
  return acc;
}

int _choose(int n, int k) {
  if (k < 0 || k > n) return 0;
  var r = 1;
  for (var i = 0; i < k; i++) {
    r = r * (n - i) ~/ (i + 1);
  }
  return r;
}
