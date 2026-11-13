/// Карта — число 0..51: ранг * 4 + масть.
/// Ранг 0..12 = 2..A, масть 0..3 = ♠ ♥ ♦ ♣.
const rankChars = '23456789TJQKA';
const suitChars = 'shdc';
const suitSymbols = ['♠', '♥', '♦', '♣'];

int cardRank(int c) => c >> 2;
int cardSuit(int c) => c & 3;
int makeCard(int rank, int suit) => rank * 4 + suit;

/// 'As' → карта; бросает FormatException при ошибке.
int parseCard(String s) {
  if (s.length != 2) throw FormatException('Bad card: $s');
  final r = rankChars.indexOf(s[0].toUpperCase());
  final u = suitChars.indexOf(s[1].toLowerCase());
  if (r < 0 || u < 0) throw FormatException('Bad card: $s');
  return makeCard(r, u);
}

/// 'AsKd' → [карты].
List<int> parseCards(String s) => [
  for (var i = 0; i + 1 < s.length; i += 2) parseCard(s.substring(i, i + 2)),
];

String cardCode(int c) => rankChars[cardRank(c)] + suitChars[cardSuit(c)];

/// Как показывать ранг на карте (T → 10).
String rankLabel(int c) {
  final r = rankChars[cardRank(c)];
  return r == 'T' ? '10' : r;
}
