/// ICM: делёжка призового фонда. Три модели: ICM (Малмут — Харвилл),
/// «по фишкам» с гарантией минимального приза и «поровну».
library;

class IcmResult {
  IcmResult({
    required this.icm,
    required this.chips,
    required this.equal,
    required this.fund,
    required this.reserved,
    required this.firstPrize,
  });

  final List<double> icm;
  final List<double> chips;
  final List<double> equal;
  final double fund; // разыгрываемый фонд (без «оставить победителю»)
  final double reserved; // «оставить победителю»
  final double firstPrize; // 1-й приз после вычета reserved

  bool chipsOverFirst(int i) => chips[i] > firstPrize + 1e-9;
}

/// Точный ICM: шанс каждого места через перебор наборов уже «занявших места»
/// игроков (2^N состояний вместо N! порядков).
List<double> icmEquity(List<double> stacks, List<double> prizes) {
  final n = stacks.length;
  final all = (1 << n) - 1;
  final g = List<double>.filled(1 << n, 0);
  g[0] = 1;
  final eq = List<double>.filled(n, 0);
  final pop = List<int>.filled(1 << n, 0);
  for (var m = 1; m <= all; m++) {
    pop[m] = pop[m >> 1] + (m & 1);
  }
  for (var mask = 0; mask < all; mask++) {
    final p0 = g[mask];
    if (p0 == 0) continue;
    final place = pop[mask];
    var rest = 0.0;
    for (var i = 0; i < n; i++) {
      if (mask & (1 << i) == 0) rest += stacks[i];
    }
    if (rest <= 0) continue;
    final prize = place < prizes.length ? prizes[place] : 0.0;
    for (var i = 0; i < n; i++) {
      if (mask & (1 << i) != 0) continue;
      final p = p0 * stacks[i] / rest;
      eq[i] += p * prize;
      g[mask | (1 << i)] += p;
    }
  }
  return eq;
}

/// Все три модели. [prizes] — по местам (недостающие места = 0),
/// [leave] — «оставить победителю», вычитается из 1-го приза.
IcmResult computeIcm(List<double> stacks, List<double> prizes, double leave) {
  final n = stacks.length;
  final p = [for (var i = 0; i < n; i++) i < prizes.length ? prizes[i] : 0.0];
  final reserved = leave.clamp(0.0, p.isEmpty ? 0.0 : p[0]);
  if (p.isNotEmpty) p[0] -= reserved;
  final fund = p.fold(0.0, (s, v) => s + v);
  final total = stacks.fold(0.0, (s, v) => s + v);
  final minPrize = p.isEmpty ? 0.0 : p.last;
  final chips = [
    for (final s in stacks) minPrize + (fund - n * minPrize) * s / total,
  ];
  return IcmResult(
    icm: icmEquity(stacks, p),
    chips: chips,
    equal: List.filled(n, fund / n),
    fund: fund,
    reserved: reserved,
    firstPrize: p.isEmpty ? 0 : p[0],
  );
}

/// Призы должны не возрастать: индексы мест, где это нарушено.
Set<int> badPrizeOrder(List<double> prizes) => {
  for (var i = 1; i < prizes.length; i++)
    if (prizes[i] > prizes[i - 1]) i,
};
