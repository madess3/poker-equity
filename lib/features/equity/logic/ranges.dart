import 'cards.dart';

/// Классы стартовых рук Холдема: 'AA', 'AKs', 'AKo'.
/// Сетка 13×13: над диагональю одномастные, под ней разномастные.
String handClass(int row, int col) {
  final a = rankChars[12 - row], b = rankChars[12 - col];
  if (row == col) return '$a$a';
  return row < col ? '$a${b}s' : '$b${a}o';
}

/// Число комбинаций класса.
int classCombos(String cls) => cls.length == 2 ? 6 : (cls[2] == 's' ? 4 : 12);

/// Все комбинации класса (пары карт).
List<List<int>> classToCombos(String cls) {
  final r1 = rankChars.indexOf(cls[0]), r2 = rankChars.indexOf(cls[1]);
  final out = <List<int>>[];
  if (cls.length == 2) {
    for (var s1 = 0; s1 < 4; s1++) {
      for (var s2 = s1 + 1; s2 < 4; s2++) {
        out.add([makeCard(r1, s1), makeCard(r1, s2)]);
      }
    }
  } else if (cls[2] == 's') {
    for (var s = 0; s < 4; s++) {
      out.add([makeCard(r1, s), makeCard(r2, s)]);
    }
  } else {
    for (var s1 = 0; s1 < 4; s1++) {
      for (var s2 = 0; s2 < 4; s2++) {
        if (s1 != s2) out.add([makeCard(r1, s1), makeCard(r2, s2)]);
      }
    }
  }
  return out;
}

/// Класс руки по двум картам.
String classOf(int a, int b) {
  var ra = cardRank(a), rb = cardRank(b);
  if (ra < rb) {
    final t = ra;
    ra = rb;
    rb = t;
  }
  final s = rankChars[ra] + rankChars[rb];
  if (ra == rb) return s;
  return s + (cardSuit(a) == cardSuit(b) ? 's' : 'o');
}

List<List<int>> rangeToCombos(Iterable<String> classes) => [
  for (final c in classes) ...classToCombos(c),
];

/// Топ X% рук по готовому рейтингу классов (сильнейшие первыми).
Set<String> topPercent(List<String> ranking, double pct, {int total = 1326}) {
  final out = <String>{};
  var acc = 0;
  final lim = pct / 100 * total;
  for (final c in ranking) {
    final n = classCombos(c);
    if (acc + n / 2 > lim) break;
    acc += n;
    out.add(c);
  }
  return out;
}
