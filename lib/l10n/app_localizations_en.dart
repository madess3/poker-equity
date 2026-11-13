// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Poker Equity';

  @override
  String get holdem => 'Hold\'em';

  @override
  String get omaha => 'Omaha';

  @override
  String get omahaHiLo => 'Omaha Hi-Lo';

  @override
  String get shortDeck => 'Short Deck';

  @override
  String get pineapple => 'Pineapple';

  @override
  String get ofc => 'OFC';

  @override
  String get handStrength => 'Hand Strength';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get menu => 'Menu';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get shortDeckDefault => 'Short Deck default';

  @override
  String get ruleStraightOverTrips => 'Straight > trips';

  @override
  String get ruleTripsOverStraight => 'Trips > straight';

  @override
  String get doubleBoard => 'Double board';

  @override
  String get cameraV2 => 'Camera (version 2)';

  @override
  String get board => 'Board';

  @override
  String boardN(int n) {
    return 'Board $n';
  }

  @override
  String playerN(int n) {
    return 'Player $n';
  }

  @override
  String get cardsLabel => 'Cards:';

  @override
  String get playersLabel => 'Players:';

  @override
  String get rulesLabel => 'Rules:';

  @override
  String get gameLabel => 'Game:';

  @override
  String get cardsOnHand => 'Cards in hand';

  @override
  String get playersTitle => 'Players';

  @override
  String get rulesTitle => 'Rules';

  @override
  String get gameTitle => 'Game';

  @override
  String get comingSoon => 'Calculation is coming in the next versions';

  @override
  String get boxTop => 'Top';

  @override
  String get boxMiddle => 'Middle';

  @override
  String get boxBottom => 'Bottom';

  @override
  String get topPercent => 'Top —';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get offlineNote => 'Works offline. No data is collected.';

  @override
  String get done => 'Done';

  @override
  String get clearCard => 'Remove card';

  @override
  String get clearAll => 'Clear all';

  @override
  String winTie(String w, String t) {
    return 'win $w · tie $t';
  }

  @override
  String boardsLine(String b1, String b2, String s) {
    return 'B1 $b1 · B2 $b2 · scoop $s';
  }

  @override
  String get deadCards => 'Dead cards';

  @override
  String get deadShort => 'Dead';

  @override
  String get analysis => 'Analysis';

  @override
  String get range => 'Range';

  @override
  String rangeShort(String p) {
    return 'Range $p';
  }

  @override
  String get mixMuck => 'Mix burns and muck';

  @override
  String get muckMixed => 'Burns and muck mixed';

  @override
  String lowPossible(String p) {
    return 'Low possible in $p of deals';
  }

  @override
  String hiLoLine(String h, String lo, String s) {
    return 'hi $h · lo $lo · scoop $s';
  }

  @override
  String get discard => 'Discard';

  @override
  String get bestOption => 'best';

  @override
  String topN(String p) {
    return 'Top $p';
  }

  @override
  String combosCount(int n) {
    return '$n combos';
  }

  @override
  String get clearRange => 'Clear';

  @override
  String rankOf(int k, int n) {
    return '#$k of $n';
  }

  @override
  String get typeLabel => 'Type:';

  @override
  String get typeTitle => 'Game type';

  @override
  String get typeHi => 'Hi';

  @override
  String get typeHiLo => 'Hi-Lo';

  @override
  String get playerLabel => 'Player:';

  @override
  String get outsTab => 'Outs';

  @override
  String get combosTab => 'Hands';

  @override
  String get outsTitle => 'Outs to the next street';

  @override
  String get outsUnavailable =>
      'Outs are shown when all hands are known and the flop or turn is dealt.';

  @override
  String get outsAhead => 'The player is already ahead — no outs.';

  @override
  String outsChanceFlop(String n, String r) {
    return 'Turn $n · by river $r';
  }

  @override
  String outsChanceTurn(String n) {
    return 'River $n';
  }

  @override
  String get pot => 'Pot';

  @override
  String get betToCall => 'Bet to call';

  @override
  String get needEquity => 'Equity needed';

  @override
  String get yourEquity => 'Your equity';

  @override
  String get potOdds => 'Pot odds';

  @override
  String get evCall => 'Call EV';

  @override
  String get callGood => 'Call is profitable';

  @override
  String get callBad => 'Call is unprofitable';

  @override
  String get toRiver => 'Chances by the river';

  @override
  String get catHigh => 'High card';

  @override
  String get catPair => 'Pair';

  @override
  String get catTwoPair => 'Two pair';

  @override
  String get catTrips => 'Trips';

  @override
  String get catStraight => 'Straight';

  @override
  String get catFlush => 'Flush';

  @override
  String get catFullHouse => 'Full house';

  @override
  String get catQuads => 'Quads';

  @override
  String get catStraightFlush => 'Straight flush';
}
