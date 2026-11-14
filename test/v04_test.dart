import 'package:flutter_test/flutter_test.dart';
import 'package:poker_equity/core/table_store.dart';
import 'package:poker_equity/features/equity/logic/cards.dart';
import 'package:poker_equity/features/equity/logic/deals.dart';
import 'package:poker_equity/features/equity/logic/equity.dart';
import 'package:poker_equity/features/equity/logic/outs.dart';
import 'package:poker_equity/features/equity/logic/rules.dart';
import 'package:poker_equity/features/equity/logic/runouts.dart';
import 'package:poker_equity/features/games/game.dart';
import 'package:poker_equity/features/icm/icm.dart';

List<int> c(String s) => parseCards(s);
List<String> r1(List<double> v) => [for (final x in v) x.toStringAsFixed(1)];

void main() {
  group('лимит игроков в Омахах', () {
    test('по правилу min(9, ⌊47/карт⌋ + 1)', () {
      expect(
        [
          for (final k in [4, 5, 6, 7]) Game.omaha.maxPlayersFor(k),
        ],
        [9, 9, 8, 7],
      );
      expect(Game.omahaHiLo.maxPlayersFor(7), 7);
      expect(Game.holdem.maxPlayersFor(2), 9);
    });
  });

  group('Омаха 7', () {
    test('2 игрока на флопе: сумма 100%', () {
      final r = computeEquity(
        EquityRequest(
          rules: const Rules(Variant.omaha, hole: 7),
          hands: [c('AsAdKsKdQcJh2c'), c('9h9d8h8d7c6s5s')],
          boards: [c('Ah7d3c')],
        ),
      )!;
      expect(r.equity(0) + r.equity(1), closeTo(1, 1e-9));
    });
    test('хай-лоу: доли хай/лоу', () {
      final r = computeEquity(
        EquityRequest(
          rules: const Rules(Variant.omahaHiLo, hole: 7),
          hands: [c('As2d3cKsKdQcJh'), c('9h9d8h8dTcTs5s')],
          boards: [c('4h7d6c')],
          maxDeals: 20000,
        ),
      )!;
      expect(r.loOf(0), greaterThan(0.3));
      expect(r.equity(0) + r.equity(1), closeTo(1, 1e-9));
    });
    test('7 игроков на флопе: колода пуста, мак не поможет', () {
      final deck = const Rules(Variant.omaha).fullDeck();
      final hands = [
        for (var i = 0; i < 7; i++) deck.sublist(i * 7, i * 7 + 7),
      ];
      final req = EquityRequest(
        rules: const Rules(Variant.omaha, hole: 7),
        hands: hands,
        boards: [deck.sublist(49, 52)],
      );
      expect(needsMuck(req), isTrue);
      expect(computeEquity(req), isNull);
      final now = showdownNow(req)!;
      final sum = [for (var i = 0; i < 7; i++) now.equity(i)]
          .reduce((a, b) => a + b);
      expect(sum, closeTo(1, 1e-9));
    });
  });

  group('ICM', () {
    test('пример 1', () {
      final r = computeIcm([50, 30, 20], [900, 400, 200], 0);
      expect(r1(r.icm), ['617.9', '485.0', '397.1']);
      expect(r1(r.chips), ['650.0', '470.0', '380.0']);
      expect(r1(r.equal), ['500.0', '500.0', '500.0']);
    });
    test('пример 2', () {
      final r = computeIcm(
        [120000, 80000, 60000, 40000, 100000],
        [1000, 600, 400, 200, 0],
        0,
      );
      expect(r1(r.icm), ['572.4', '456.5', '377.4', '273.8', '519.9']);
      expect(r1(r.chips), ['660.0', '440.0', '330.0', '220.0', '550.0']);
      expect(r1(r.equal), List.filled(5, '440.0'));
    });
    test('сумма столбцов = фонд, «оставить победителю»', () {
      final r = computeIcm([50, 30, 20], [900, 400, 200], 100);
      expect(r.fund, 1400);
      expect(r.reserved, 100);
      for (final col in [r.icm, r.chips, r.equal]) {
        expect(col.reduce((a, b) => a + b), closeTo(1400, 1e-6));
      }
    });
    test('10 игроков — точно и быстро', () {
      final sw = Stopwatch()..start();
      final r = computeIcm(List.generate(10, (i) => (i + 1) * 1000.0), [
        3000,
        2000,
        1500,
        1000,
        800,
        600,
        400,
        300,
        200,
        200,
      ], 0);
      expect(r.icm.reduce((a, b) => a + b), closeTo(10000, 1e-6));
      expect(sw.elapsedMilliseconds, lessThan(200));
    });
    test('призы не по убыванию', () {
      expect(badPrizeOrder([900, 1000, 200]), {1});
    });
  });

  group('EV chop и страховка', () {
    test('EV chop: контрольный пример', () {
      final r = ChopResult(0.541, 100, 1);
      expect(r.chop.toStringAsFixed(1), '53.1');
      expect(r.fee.toStringAsFixed(1), '1.0');
      expect((r.feeOfShare * 100).toStringAsFixed(1), '1.8');
    });
    test('страховка: контрольный пример', () {
      final outs = computeOuts(
        const Rules(Variant.holdem),
        [c('AhKh'), c('QsQd')],
        c('7h2h9c'),
        [],
        0,
      )!;
      expect(outs.length, 15);
      final r = InsuranceResult(
        outs: 15,
        unseen: 45,
        p: 15 / 45,
        stake: 20,
        odds: 1.6,
      );
      expect(r.fair.toStringAsFixed(1), '2.0');
      expect(r.ev.toStringAsFixed(1), '-2.7');
      expect(r.overpayPct.toStringAsFixed(1), '13.3');
    });
  });

  group('прокрутки', () {
    RunoutStats run(int k) => computeRunouts(
      RunoutRequest(
        rules: const Rules(Variant.holdem),
        hands: [c('AsKd'), c('QhJh')],
        board: c('Ah7h2c9d'),
        dead: const [],
        runs: k,
      ),
    )!;
    test('тёрн, 9 аутов из 44', () {
      final one = run(1), two = run(2);
      expect((one.allOf(1) * 100).toStringAsFixed(1), '20.5');
      expect((one.noneOf(1) * 100).toStringAsFixed(1), '79.5');
      expect((two.allOf(1) * 100).toStringAsFixed(1), '3.8');
      expect((two.noneOf(1) * 100).toStringAsFixed(1), '62.9');
      expect((two.partOf(1) * 100).toStringAsFixed(1), '33.3');
      expect(two.mean(1), closeTo(one.mean(1), 1e-9));
      expect(two.sd(1), lessThan(one.sd(1)));
      expect(run(3).exact, isTrue);
    });
  });

  group('сохранение стола', () {
    test('JSON туда и обратно', () {
      final s = TableSnapshot(
        handSize: 4,
        players: 3,
        doubleBoard: true,
        rule: null,
        cards: {'p0_0': 5, 'b0_1': 7},
        dead: [9],
        ranges: {
          1: ['AA', 'KK'],
        },
        discarded: [2],
        mixed: false,
      );
      final back = TableSnapshot.fromJson(s.toJson())!;
      expect(back.cards, s.cards);
      expect(back.ranges[1], ['AA', 'KK']);
      expect(back.players, 3);
    });
  });
}
