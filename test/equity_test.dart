import 'package:flutter_test/flutter_test.dart';
import 'package:poker_equity/features/equity/logic/cards.dart';
import 'package:poker_equity/features/equity/logic/equity.dart';
import 'package:poker_equity/features/equity/logic/hand_eval.dart';

int ev(String s) => evaluate(parseCards(s));
int cat(String s) => handCategory(ev(s));

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

    test('стрит с младшим тузом (колесо) слабее 6-high', () {
      expect(cat('As2d3h4c5s9dKh'), catStraight);
      expect(ev('As2d3h4c5s9dKh') < ev('2d3h4c5s6s9dKh'), isTrue);
    });

    test('стрит-флеш с младшим тузом', () {
      expect(cat('Ah2h3h4h5hKdQd'), catStraightFlush);
    });

    test('две сета → фулл-хаус со старшим сетом', () {
      expect(ev('9h9d9sKcKdKh2c') > ev('KcKdKh9h9d2c3s'), isFalse);
      expect(cat('9h9d9sKcKdKh2c'), catFullHouse);
    });

    test('кикеры решают', () {
      expect(ev('AhAd9s7c4d3c2h') > ev('AsAc8s7c4d3c2h'), isTrue);
      expect(ev('AhKd9s7c4d3c2h') == ev('AsKc9h7d4s3h2c'), isTrue);
    });

    test('три пары → лучшие две + кикер', () {
      expect(ev('KhKd9s9c4d4cAh') > ev('KhKd9s9c4d4c3h'), isTrue);
    });
  });

  group('эквити', () {
    EquityResult run(
      List<String> hands,
      String board, {
      List<String>? board2,
    }) => computeEquity(
      EquityRequest(
        hands: [for (final h in hands) parseCards(h)],
        boards: [
          parseCards(board),
          if (board2 != null) parseCards(board2.first),
        ],
      ),
    )!;

    test('на ривере результат детерминирован', () {
      final r = run([
        'AhKh',
        'QsQd',
      ], 'JhTs2c9dQh'); // стрит до туза против сета
      expect(r.exact, isTrue);
      expect(r.players[0].equity, 1.0);
      expect(r.players[1].equity, 0.0);
    });

    test('делёж банка на ривере', () {
      final r = run(['2c3d', '2h3s'], 'AsKdQhJcTh');
      expect(r.players[0].equity, closeTo(0.5, 1e-9));
      expect(r.players[0].tie, closeTo(1.0, 1e-9));
    });

    test('сумма эквити = 100%', () {
      final r = run(['AhKh', 'QsQd', '7c7d'], 'Jh8s2c');
      final sum = r.players.fold(0.0, (s, p) => s + p.equity);
      expect(sum, closeTo(1.0, 1e-9));
    });

    test('AA против KK префлоп ≈ 82%', () {
      final r = run(['AsAh', 'KsKh'], '');
      expect(r.exact, isFalse);
      expect(r.players[0].equity, closeTo(0.82, 0.015));
    });

    test('флоп: точный перебор тёрна и ривера', () {
      final r = run(['AhKh', 'QsQd'], 'Jh8s2c');
      expect(r.exact, isTrue);
      expect(r.deals, 990);
    });

    test('случайная рука соперника', () {
      final r = computeEquity(
        EquityRequest(hands: [parseCards('AsAh'), <int>[]], boards: [<int>[]]),
      )!;
      expect(r.players[0].equity, closeTo(0.85, 0.015));
    });

    test('дабл борд: скуп и среднее по бордам', () {
      final r = computeEquity(
        EquityRequest(
          hands: [parseCards('AhKh'), parseCards('QsQd')],
          boards: [parseCards('Ac8s2c9d3h'), parseCards('Qh7c4d5s6h')],
        ),
      )!;
      expect(r.players[0].perBoard[0], 1.0);
      expect(r.players[1].perBoard[1], 1.0);
      expect(r.players[0].equity, closeTo(0.5, 1e-9));
      expect(r.players[0].scoop, 0.0);
    });

    test('не хватает карт → null', () {
      final r = computeEquity(
        EquityRequest(
          hands: List.generate(9, (_) => <int>[]),
          boards: [<int>[], <int>[]],
          holeCards: 6,
        ),
      );
      expect(r, isNull);
    });
  });
}
