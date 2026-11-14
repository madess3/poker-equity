import 'package:flutter_test/flutter_test.dart';
import 'package:poker_equity/features/ofc/ofc.dart';

OfcPlayer p(OfcHand top, OfcHand mid, OfcHand bot, {bool foul = false}) =>
    OfcPlayer(boxes: [top, mid, bot], manualFoul: foul);

void main() {
  const q = 10; // ранг дамы
  test('роялти по таблице', () {
    expect(ofcRoyalty(OfcBox.top, const OfcHand(ofcPair, rank: 4)), 1); // 66
    expect(ofcRoyalty(OfcBox.top, const OfcHand(ofcPair, rank: 12)), 9); // AA
    expect(ofcRoyalty(OfcBox.top, const OfcHand(ofcPair, rank: 3)), 0); // 55
    expect(ofcRoyalty(OfcBox.top, const OfcHand(ofcTrips, rank: 0)), 10); // 222
    expect(
      ofcRoyalty(OfcBox.top, const OfcHand(ofcTrips, rank: 12)),
      22,
    ); // AAA
    expect(ofcRoyalty(OfcBox.middle, const OfcHand(ofcFullHouse)), 12);
    expect(ofcRoyalty(OfcBox.middle, const OfcHand(ofcRoyal)), 50);
    expect(ofcRoyalty(OfcBox.bottom, const OfcHand(ofcStraight)), 2);
    expect(ofcRoyalty(OfcBox.bottom, const OfcHand(ofcRoyal)), 25);
  });

  test('пример из прототипа: A +33, B +3, C −36', () {
    final a = p(
      const OfcHand(ofcPair, rank: q, place: 1),
      const OfcHand(ofcStraight),
      const OfcHand(ofcFlush),
    );
    final b = p(
      const OfcHand(ofcPair, rank: q, place: 2),
      const OfcHand(ofcTwoPair),
      const OfcHand(ofcStraight),
    );
    // KK наверху сильнее пары в середине: категории равны, фол отмечен вручную.
    final c = p(
      const OfcHand(ofcPair, rank: 11),
      const OfcHand(ofcPair),
      const OfcHand(ofcTwoPair),
      foul: true,
    );
    expect(ofcAutoFoul(c), isFalse);
    expect(ofcFoul(c), isTrue);
    expect(ofcVersus(a, b), 12);
    expect(ofcTotals([a, b, c]), [33, 3, -36]);
  });

  test('сумма итогов = 0, скуп +3', () {
    final a = p(
      const OfcHand(ofcPair, rank: 5),
      const OfcHand(ofcFlush),
      const OfcHand(ofcFullHouse),
    );
    final b = p(
      const OfcHand(ofcHigh),
      const OfcHand(ofcPair),
      const OfcHand(ofcTwoPair),
    );
    expect(ofcVersus(a, b), 3 + 3 + (2 + 8 + 6));
    final t = ofcTotals([a, b])!;
    expect(t[0] + t[1], 0);
  });

  test('фол: явный по категориям и ручной', () {
    final bad = p(
      const OfcHand(ofcTrips, rank: 2),
      const OfcHand(ofcPair),
      const OfcHand(ofcFlush),
    );
    expect(ofcAutoFoul(bad), isTrue);
    final ok = p(
      const OfcHand(ofcPair, rank: 2),
      const OfcHand(ofcPair),
      const OfcHand(ofcFlush),
    );
    expect(ofcAutoFoul(ok), isFalse);
    expect(
      ofcFoul(
        p(
          const OfcHand(ofcHigh),
          const OfcHand(ofcPair),
          const OfcHand(ofcPair),
          foul: true,
        ),
      ),
      isTrue,
    );
  });

  test('одинаковые места — ничья в боксе', () {
    final a = p(
      const OfcHand(ofcHigh),
      const OfcHand(ofcPair),
      const OfcHand(ofcFlush),
    );
    final b = p(
      const OfcHand(ofcHigh),
      const OfcHand(ofcPair),
      const OfcHand(ofcFlush),
    );
    expect(ofcVersus(a, b), 0);
  });
}
