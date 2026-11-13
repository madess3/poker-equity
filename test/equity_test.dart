import 'package:flutter_test/flutter_test.dart';
import 'package:poker_equity/features/equity/logic/cards.dart';
import 'package:poker_equity/features/equity/logic/equity.dart';
import 'package:poker_equity/features/equity/logic/hand_eval.dart';
import 'package:poker_equity/features/equity/logic/outs.dart';
import 'package:poker_equity/features/equity/logic/ranges.dart';
import 'package:poker_equity/features/equity/logic/rules.dart';

int ev(String s) => evaluate(parseCards(s));
int cat(String s) => handCategory(ev(s));
List<int> c(String s) => parseCards(s);

const holdem = Rules(Variant.holdem);

EquityAcc run(
  Rules rules,
  List<String> hands,
  List<String> boards, {
  List<String> dead = const [],
}) => computeEquity(
  EquityRequest(
    rules: rules,
    hands: [for (final h in hands) c(h)],
    boards: [for (final b in boards) c(b)],
    dead: [for (final d in dead) ...c(d)],
  ),
)!;

void main() {
  group('категории рук', () {
    test('все категории', () {
      expect(cat('AsKsQsJsTs2d3c'), catStraightFlush);
      expect(cat('9h9d9s9c2d3c4h'), catQuads);
      expect(cat('9h9d9s2c2d3c4h'), catFullHouse);
      expect(cat('Ah2h7h9hKh2d3c'), catFlush);
      expect(cat('5h6d7s8c9d2c2h'), catStraight);
      expect(cat('9h9d9s2c4d6cKh'), catTrips);
      expect(cat('9h9d2s2c4d6cKh'), catTwoPair);
      expect(cat('9h9d2s3c4d6cKh'), catPair);
      expect(cat('9h8d2s3c4dJcKh'), catHigh);
    });

    test('колесо слабее стрита до 6', () {
      expect(ev('As2d3h4c5s9dKh') < ev('2d3h4c5s6s9dKh'), isTrue);
      expect(cat('Ah2h3h4h5hKdQd'), catStraightFlush);
    });

    test('кикеры и три пары', () {
      expect(ev('AhAd9s7c4d3c2h') > ev('AsAc8s7c4d3c2h'), isTrue);
      expect(ev('AhKd9s7c4d3c2h') == ev('AsKc9h7d4s3h2c'), isTrue);
      expect(ev('KhKd9s9c4d4cAh') > ev('KhKd9s9c4d4c3h'), isTrue);
    });
  });

  group('шорт-дек', () {
    int sd(String h, String b, bool tos) => evaluateShort2(c(h), c(b), tos);
    test('флеш старше фулл-хауса', () {
      final flush = sd('AhKh', '9h8h6hTcJd', false);
      final fh = sd('9s9c', '9d8s8cTcJd', false);
      expect(flush > fh, isTrue);
    });
    test('A-6-7-8-9 — стрит', () {
      expect(
        straightTopShort(
          c('As6d7h8c9s').fold(0, (m, x) => m | 1 << cardRank(x)),
        ),
        cardRank(c('9s').first),
      );
    });
    test('правило сет/стрит', () {
      final straight = sd('Th6d', '9s8h7cKdAc', false);
      final trips = sd('9h9d', '9s8h7cKdAc', false);
      expect(straight > trips, isTrue); // стрит > сет
      expect(
        sd('Th6d', '9s8h7cKdAc', true) < sd('9h9d', '9s8h7cKdAc', true),
        isTrue,
      );
    });
    test('колода 36 карт', () {
      expect(const Rules(Variant.shortDeck).fullDeck().length, 36);
    });
  });

  group('Омаха', () {
    test('ровно 2 карты с руки', () {
      // 4 пики на руке + 1 пика на борде — флеша нет.
      final s = bestOmaha(c('AsKsQsJs'), c('2s7d8c9hTd'));
      expect(handCategory(s) == catFlush, isFalse);
      // 2 пики с руки + 3 с борда — флеш.
      expect(handCategory(bestOmaha(c('AsKs2d3c'), c('4s7s9s9hTd'))), catFlush);
    });
    test('лоу: A2 на борде 3-5-7 — колесо-лоу 75432? нет, 7-5-3-2-A', () {
      expect(bestLowOmaha(c('As2dKcKd'), c('3h5c7dKsQh')), isNot(-1));
      expect(bestLowOmaha(c('KsKdQcQd'), c('3h5c7d8s2h')), -1);
      // лоу на борде с двумя низкими картами невозможен
      expect(bestLowOmaha(c('As2d3c4d'), c('KhQcJd8s7h')), -1);
    });
    test('лоу сравнение: 5432A лучше 6432A', () {
      final a = bestLowOmaha(c('As2dKcKd'), c('3h4c5d9sTh'));
      final b = bestLowOmaha(c('As2dKcKd'), c('3h4c6d9sTh'));
      expect(a < b, isTrue);
    });
    test('хай-лоу: делёж банка и скуп', () {
      final r = run(
        const Rules(Variant.omahaHiLo, hole: 4),
        ['As2dKcKd', 'QsQdJcJh'],
        ['3h5c7dKsQh'],
      );
      // У 1-го лоу A-2-3-5-7, хай — сет королей; у 2-го сет дам. Скуп у 1-го.
      expect(r.equity(0), closeTo(1.0, 1e-9));
      expect(r.scoopOf(0), closeTo(1.0, 1e-9));
    });
    test('Омаха 5 и 6 считаются', () {
      for (final h in [5, 6]) {
        final r = computeEquity(
          EquityRequest(
            rules: Rules(Variant.omaha, hole: h),
            hands: [<int>[], <int>[]],
            boards: [<int>[]],
            maxDeals: 3000,
          ),
        )!;
        expect(r.equity(0) + r.equity(1), closeTo(1, 1e-9));
      }
    });
  });

  group('эквити Холдем', () {
    test('ривер детерминирован', () {
      final r = run(holdem, ['AhKh', 'QsQd'], ['JhTs2c9dQh']);
      expect(r.exact, isTrue);
      expect(r.equity(0), 1.0);
    });
    test('делёж на ривере', () {
      final r = run(holdem, ['2c3d', '2h3s'], ['AsKdQhJcTh']);
      expect(r.equity(0), closeTo(0.5, 1e-9));
      expect(r.tieOf(0), closeTo(1.0, 1e-9));
    });
    test('сумма = 100%, флоп — точный перебор', () {
      final r = run(holdem, ['AhKh', 'QsQd', '7c7d'], ['Jh8s2c']);
      expect(r.exact, isTrue);
      expect(r.deals, 903);
      final sum = r.equity(0) + r.equity(1) + r.equity(2);
      expect(sum, closeTo(1.0, 1e-9));
    });
    test('AA против KK ≈ 82%', () {
      final r = run(holdem, ['AsAh', 'KsKh'], ['']);
      expect(r.equity(0), closeTo(0.82, 0.015));
    });
    test('мёртвые карты меняют расчёт', () {
      final a = run(holdem, ['AhKh', 'QsQd'], ['Jh8s2c']);
      final b = run(holdem, ['AhKh', 'QsQd'], ['Jh8s2c'], dead: ['ThTcTd']);
      expect(a.deals, isNot(b.deals));
    });
    test('дабл борд: по бордам и скуп', () {
      final r = run(holdem, ['AhKh', 'QsQd'], ['Ac8s2c9d3h', 'Qh7c4d5s6h']);
      expect(r.board(0, 0), 1.0);
      expect(r.board(1, 1), 1.0);
      expect(r.equity(0), closeTo(0.5, 1e-9));
      expect(r.scoopOf(0), 0.0);
    });
    test('диапазон соперника', () {
      final aa = classToCombos('AA');
      final r = computeEquity(
        EquityRequest(
          rules: holdem,
          hands: [c('KsKh'), <int>[]],
          ranges: [null, aa],
          boards: [<int>[]],
          maxDeals: 40000,
        ),
      )!;
      expect(r.equity(0), closeTo(0.18, 0.02));
    });
  });

  group('Ананас', () {
    test('сброс худшей карты под флоп', () {
      // Флоп K-8-3: держим AK (пара королей), сбрасываем 5.
      expect(pineappleDiscard(c('AhKd5s'), c('Kh8c3d')), 2);
    });
    test('расчёт с 3 картами на префлопе', () {
      final r = computeEquity(
        EquityRequest(
          rules: const Rules(Variant.pineapple, hole: 3),
          hands: [c('AhAdKs'), <int>[]],
          boards: [<int>[]],
          maxDeals: 20000,
        ),
      )!;
      expect(r.equity(0), greaterThan(0.75));
    });
  });

  group('нехватка карт и мак', () {
    test('Омаха 6, 8 игроков, дабл борд — нужен мак', () {
      final req = EquityRequest(
        rules: const Rules(Variant.omaha, hole: 6),
        hands: List.generate(8, (_) => <int>[]),
        boards: [<int>[], <int>[]],
      );
      expect(needsMuck(req), isTrue);
      expect(computeEquity(req), isNull);
    });
    test('Холдем на 9 игроков — мак не нужен', () {
      final req = EquityRequest(
        rules: holdem,
        hands: List.generate(9, (_) => <int>[]),
        boards: [<int>[], <int>[]],
      );
      expect(needsMuck(req), isFalse);
    });
  });

  group('ауты', () {
    test('флеш-дро на флопе', () {
      final outs = computeOuts(
        holdem,
        [c('AhKh'), c('QsQd')],
        c('7h2h9c'),
        [],
        0,
      )!;
      // 9 червей + 3 туза + 3 короля = 15
      expect(outs.length, 15);
    });
    test('лидер не имеет аутов', () {
      expect(
        computeOuts(holdem, [c('AhAd'), c('QsQd')], c('7h2h9c'), [], 0),
        isEmpty,
      );
    });
  });

  group('диапазоны', () {
    test('классы и комбинации', () {
      expect(classToCombos('AKs').length, 4);
      expect(classToCombos('AKo').length, 12);
      expect(classToCombos('QQ').length, 6);
      expect(classOf(c('Ah').first, c('Kh').first), 'AKs');
      expect(handClass(0, 1), 'AKs');
      expect(handClass(1, 0), 'AKo');
    });
  });
}
