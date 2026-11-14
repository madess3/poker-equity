/// OFC (открытый китайский покер): подсчёт очков по введённым комбинациям.
///
/// Комбинация бокса вводится категорией, для верха пары и сета — ещё рангом.
/// Старшинство одинаковых комбинаций в одном боксе у разных игроков задаётся
/// местом 1…N (1 — старшая, одинаковые места — ничья).
library;

enum OfcBox { top, middle, bottom }

/// Категории: 0 старшая карта … 8 стрит-флеш, 9 роял.
const ofcHigh = 0, ofcPair = 1, ofcTwoPair = 2, ofcTrips = 3, ofcStraight = 4;
const ofcFlush = 5,
    ofcFullHouse = 6,
    ofcQuads = 7,
    ofcStraightFlush = 8,
    ofcRoyal = 9;

/// Какие категории возможны в боксе (в верхнем — только 3 карты).
List<int> ofcCombosFor(OfcBox box) => box == OfcBox.top
    ? const [ofcHigh, ofcPair, ofcTrips]
    : List.generate(10, (i) => i);

/// Нужен ли ранг (2…A) для комбинации: пара и сет в верхнем боксе.
bool ofcNeedsRank(OfcBox box, int combo) =>
    box == OfcBox.top && (combo == ofcPair || combo == ofcTrips);

class OfcHand {
  const OfcHand(this.combo, {this.rank, this.place = 1});
  final int combo;
  final int? rank; // ранг 0..12 (2..A) для пары/сета наверху
  final int place; // место среди одинаковых комбинаций в этом боксе

  OfcHand copyWith({int? combo, int? rank, int? place}) => OfcHand(
    combo ?? this.combo,
    rank: rank ?? this.rank,
    place: place ?? this.place,
  );

  Map<String, Object?> toJson() => {'c': combo, 'r': rank, 'p': place};
  static OfcHand fromJson(Map<String, Object?> j) =>
      OfcHand(j['c'] as int, rank: j['r'] as int?, place: j['p'] as int? ?? 1);

  /// Одинаковые ли комбинации для сравнения местом.
  bool sameAs(OfcHand o) => combo == o.combo && rank == o.rank;
}

class OfcPlayer {
  OfcPlayer({List<OfcHand?>? boxes, this.manualFoul = false})
    : boxes = boxes ?? List<OfcHand?>.filled(3, null);
  final List<OfcHand?> boxes; // верх, середина, низ
  bool manualFoul; // фол, отмеченный вручную

  bool get complete => boxes.every((b) => b != null);

  Map<String, Object?> toJson() => {
    'b': [for (final b in boxes) b?.toJson()],
    'f': manualFoul,
  };
  static OfcPlayer fromJson(Map<String, Object?> j) => OfcPlayer(
    boxes: [
      for (final b in (j['b'] as List))
        b == null ? null : OfcHand.fromJson((b as Map).cast<String, Object?>()),
    ],
    manualFoul: j['f'] as bool? ?? false,
  );
}

/// Роялти бокса (стандартная таблица Pineapple).
int ofcRoyalty(OfcBox box, OfcHand h) {
  switch (box) {
    case OfcBox.top:
      final r = h.rank;
      if (r == null) return 0;
      if (h.combo == ofcPair) return r >= 4 ? r - 3 : 0; // 66 = 1 … AA = 9
      if (h.combo == ofcTrips) return 10 + r; // 222 = 10 … AAA = 22
      return 0;
    case OfcBox.middle:
      return const {
            ofcTrips: 2,
            ofcStraight: 4,
            ofcFlush: 8,
            ofcFullHouse: 12,
            ofcQuads: 20,
            ofcStraightFlush: 30,
            ofcRoyal: 50,
          }[h.combo] ??
          0;
    case OfcBox.bottom:
      return const {
            ofcStraight: 2,
            ofcFlush: 4,
            ofcFullHouse: 6,
            ofcQuads: 10,
            ofcStraightFlush: 15,
            ofcRoyal: 25,
          }[h.combo] ??
          0;
  }
}

/// Явный фол: нижний бокс слабее среднего или средний слабее верхнего
/// по категории. При одинаковых категориях фол отмечается вручную.
bool ofcAutoFoul(OfcPlayer p) {
  if (!p.complete) return false;
  final t = p.boxes[0]!.combo, m = p.boxes[1]!.combo, b = p.boxes[2]!.combo;
  return b < m || m < t;
}

bool ofcFoul(OfcPlayer p) => p.manualFoul || ofcAutoFoul(p);

int ofcRoyalties(OfcPlayer p) => ofcFoul(p) || !p.complete
    ? 0
    : [for (final box in OfcBox.values) ofcRoyalty(box, p.boxes[box.index]!)]
          .fold(0, (s, v) => s + v);

/// Сравнение бокса двух игроков: >0 — сильнее первый, 0 — ничья.
int ofcCompare(OfcHand a, OfcHand b) {
  if (a.combo != b.combo) return a.combo - b.combo;
  if ((a.rank ?? -1) != (b.rank ?? -1)) return (a.rank ?? -1) - (b.rank ?? -1);
  return b.place - a.place; // место 1 старше
}

/// Очки игрока a против игрока b (линии, скуп +3, роялти, фол).
int ofcVersus(OfcPlayer a, OfcPlayer b) {
  final fa = ofcFoul(a), fb = ofcFoul(b);
  if (fa && fb) return 0;
  if (fa) return -(6 + ofcRoyalties(b));
  if (fb) return 6 + ofcRoyalties(a);
  var lines = 0, wins = 0, losses = 0;
  for (var i = 0; i < 3; i++) {
    final c = ofcCompare(a.boxes[i]!, b.boxes[i]!);
    if (c > 0) {
      lines++;
      wins++;
    } else if (c < 0) {
      lines--;
      losses++;
    }
  }
  final scoop = wins == 3 ? 3 : (losses == 3 ? -3 : 0);
  return lines + scoop + ofcRoyalties(a) - ofcRoyalties(b);
}

/// Итог каждого игрока (сумма по парам). null — не все боксы заполнены.
List<int>? ofcTotals(List<OfcPlayer> ps) {
  if (ps.any((p) => !p.complete)) return null;
  return [
    for (var i = 0; i < ps.length; i++)
      [
        for (var j = 0; j < ps.length; j++)
          if (j != i) ofcVersus(ps[i], ps[j]),
      ].fold(0, (s, v) => s + v),
  ];
}
