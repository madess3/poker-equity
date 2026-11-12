import '../../l10n/app_localizations.dart';

/// Описание вкладки игры: какие элементы управления на ней есть.
enum Game {
  holdem(path: '/holdem', handCards: [2], maxPlayers: 9),
  omaha(path: '/omaha', handCards: [4, 5, 6], maxPlayers: 9),
  omahaHiLo(path: '/omaha-hi-lo', handCards: [4, 5, 6], maxPlayers: 9),
  shortDeck(path: '/short-deck', handCards: [2], maxPlayers: 9, hasRules: true),
  pineapple(path: '/pineapple', handCards: [3], maxPlayers: 9),
  ofc(path: '/ofc', handCards: [], maxPlayers: 4, minPlayers: 2, doubleBoard: false),
  handStrength(path: '/hand-strength', handCards: [], maxPlayers: 1, doubleBoard: false);

  const Game({
    required this.path,
    required this.handCards,
    required this.maxPlayers,
    this.minPlayers = 2,
    this.hasRules = false,
    this.doubleBoard = true,
  });

  final String path;
  final List<int> handCards; // варианты числа карт на руке
  final int maxPlayers;
  final int minPlayers;
  final bool hasRules;
  final bool doubleBoard;

  /// В 6-карточных играх максимум 8 игроков.
  int maxPlayersFor(int cards) => cards == 6 ? 8 : maxPlayers;

  String title(AppLocalizations l) => switch (this) {
        Game.holdem => l.holdem,
        Game.omaha => l.omaha,
        Game.omahaHiLo => l.omahaHiLo,
        Game.shortDeck => l.shortDeck,
        Game.pineapple => l.pineapple,
        Game.ofc => l.ofc,
        Game.handStrength => l.handStrength,
      };

  /// Игры, доступные во вкладке «Сила руки».
  static const strengthGames = [holdem, omaha, omahaHiLo, shortDeck, pineapple];

  static Game byPath(String p) =>
      values.firstWhere((g) => g.path == p, orElse: () => holdem);
}
