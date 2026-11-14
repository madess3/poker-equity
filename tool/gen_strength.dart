// Предрасчёт таблиц силы рук: `dart run tool/gen_strength.dart`.
// Пишет lib/features/strength/strength_tables.dart.
import 'dart:io';
import 'dart:math';

import 'package:poker_equity/features/equity/logic/cards.dart';
import 'package:poker_equity/features/equity/logic/equity.dart';
import 'package:poker_equity/features/equity/logic/ranges.dart';
import 'package:poker_equity/features/equity/logic/rules.dart';

double vsRandom(Rules rules, List<int> hand, int deals) {
  final r = computeEquity(
    EquityRequest(
      rules: rules,
      hands: [hand, <int>[]],
      boards: [<int>[]],
      maxDeals: deals,
      allowExact: false,
    ),
  )!;
  return r.equity(0);
}

/// Классы рук с рейтингом (сильнейшие первыми) и эквити.
List<(String, double)> classTable(Rules rules, int minRank, int deals) {
  final out = <(String, double)>[];
  for (var a = 12; a >= minRank; a--) {
    for (var b = a; b >= minRank; b--) {
      final classes = a == b
          ? [rankChars[a] * 2]
          : [
              '${rankChars[a]}${rankChars[b]}s',
              '${rankChars[a]}${rankChars[b]}o',
            ];
      for (final cls in classes) {
        final combo = classToCombos(cls).first;
        out.add((cls, vsRandom(rules, combo, deals)));
      }
    }
  }
  out.sort((x, y) => y.$2.compareTo(x.$2));
  return out;
}

/// Отсортированное (по убыванию) распределение эквити случайных рук.
List<double> distribution(Rules rules, int hands, int deals) {
  final rnd = Random(42);
  final deck = rules.fullDeck();
  final out = <double>[];
  for (var k = 0; k < hands; k++) {
    final d = [...deck]..shuffle(rnd);
    out.add(vsRandom(rules, d.sublist(0, rules.hole), deals));
  }
  out.sort((a, b) => b.compareTo(a));
  return out;
}

String classesDart(String name, List<(String, double)> t) =>
    'const $name = <(String, double)>[\n${t.map((e) => "  ('${e.$1}', ${e.$2.toStringAsFixed(4)}),").join('\n')}\n];\n';

String distDart(String name, List<double> d) =>
    'const $name = <double>[\n  ${d.map((e) => e.toStringAsFixed(4)).join(', ')}\n];\n';

const _dists = [
  ('distOmaha4', Rules(Variant.omaha, hole: 4), 1000, 2500),
  ('distOmaha5', Rules(Variant.omaha, hole: 5), 1000, 2000),
  ('distOmaha6', Rules(Variant.omaha, hole: 6), 1000, 1500),
  ('distOmaha7', Rules(Variant.omaha, hole: 7), 1000, 1200),
  ('distHiLo4', Rules(Variant.omahaHiLo, hole: 4), 1000, 2000),
  ('distHiLo5', Rules(Variant.omahaHiLo, hole: 5), 1000, 1500),
  ('distHiLo6', Rules(Variant.omahaHiLo, hole: 6), 1000, 1200),
  ('distHiLo7', Rules(Variant.omahaHiLo, hole: 7), 1000, 1000),
  ('distPineapple', Rules(Variant.pineapple, hole: 3), 1000, 8000),
];

/// Без аргументов — пересчитать всё. С именами (`distOmaha7 …`) —
/// досчитать только их и дописать в конец файла.
void main(List<String> args) {
  final sw = Stopwatch()..start();
  void log(String s) => stdout.writeln('${sw.elapsed.inSeconds}s $s');
  if (args.isNotEmpty) {
    final f = File('lib/features/strength/strength_tables.dart');
    for (final (name, rules, hands, deals) in _dists) {
      if (!args.contains(name)) continue;
      f.writeAsStringSync(distDart(name, distribution(rules, hands, deals)),
          mode: FileMode.append);
      log(name);
    }
    return;
  }
  final b = StringBuffer()
    ..writeln('// Сгенерировано tool/gen_strength.dart — не править вручную.')
    ..writeln('// Эквити стартовых рук против одной случайной руки.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln();
  b.write(
    classesDart(
      'holdemClasses',
      classTable(const Rules(Variant.holdem), 0, 200000),
    ),
  );
  log('holdem');
  b.write(
    classesDart(
      'shortClassesStraight',
      classTable(const Rules(Variant.shortDeck), 4, 150000),
    ),
  );
  b.write(
    classesDart(
      'shortClassesTrips',
      classTable(
        const Rules(Variant.shortDeck, tripsOverStraight: true),
        4,
        150000,
      ),
    ),
  );
  log('short');
  for (final (name, rules, hands, deals) in _dists) {
    b.write(distDart(name, distribution(rules, hands, deals)));
    log(name);
  }
  File('lib/features/strength/strength_tables.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(b.toString());
  log('done');
}
