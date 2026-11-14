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

  @override
  String get removePlayer => 'Remove player';

  @override
  String get deckEmpty => 'Deck is empty: no more cards can be dealt';

  @override
  String get icmTitle => 'ICM · deal';

  @override
  String get icmStacks => 'Stacks';

  @override
  String icmChipsTotal(String n) {
    return 'Total chips: $n';
  }

  @override
  String get icmPrizes => 'Prizes';

  @override
  String icmPlace(int n) {
    return 'Place $n';
  }

  @override
  String icmFund(String n) {
    return 'Prize pool: $n';
  }

  @override
  String get icmPrizeOrder => 'Prizes must go in descending order';

  @override
  String get icmLeave => 'Leave for the winner';

  @override
  String get icmFillAll => 'Fill in every player\'s stack and the prizes.';

  @override
  String get icmPlayer => 'Player';

  @override
  String get icmByChips => 'Chip chop';

  @override
  String get icmEqual => 'Equal';

  @override
  String get icmOverFirst => 'more than first prize';

  @override
  String icmReserved(String r) {
    return 'Played for: $r';
  }

  @override
  String get icmNote =>
      'ICM treats all players as equally skilled and ignores blinds and position.';

  @override
  String get menuChop => 'EV chop · Insurance';

  @override
  String get insuranceTab => 'Insurance';

  @override
  String get runoutsTab => 'Run it';

  @override
  String get toHand => 'Back to hand';

  @override
  String get needTwoHands => 'Enter hands of at least two players';

  @override
  String get modelLabel => 'Model:';

  @override
  String get modelTitle => 'Model';

  @override
  String get modelChop => 'EV chop';

  @override
  String get modelOuts => 'Outs insurance';

  @override
  String get allCardsOpen => 'All cards are dealt';

  @override
  String get feePct => 'Fee, %';

  @override
  String get chopSum => 'EV chop amount';

  @override
  String get fee => 'Fee';

  @override
  String get shareNoDeal => 'Share without deal';

  @override
  String chopCosts(String x) {
    return 'EV chop costs $x';
  }

  @override
  String chopOfShare(String p) {
    return '$p of your pot share';
  }

  @override
  String get feeFromPot => 'The fee is taken from the pot';

  @override
  String get insTwoPlayers => 'Exactly 2 players with known hands are needed.';

  @override
  String get insStreet => 'Insurance works on the flop or turn.';

  @override
  String get insuredLabel => 'Insured:';

  @override
  String get streetLabel => 'Street:';

  @override
  String get streetTitle => 'Street';

  @override
  String get streetToRiver => 'to the river';

  @override
  String get streetTurn => 'turn';

  @override
  String get insNoOuts => 'The opponent has no outs — nothing to insure.';

  @override
  String get insStake => 'Insurance stake';

  @override
  String get insOdds => 'Payout odds';

  @override
  String get insOppOuts => 'Opponent outs';

  @override
  String get insChance => 'Out chance';

  @override
  String get insFair => 'Fair odds';

  @override
  String get insEv => 'Insurance EV';

  @override
  String get insGood => 'Insurance is profitable';

  @override
  String get insBad => 'Insurance is unprofitable';

  @override
  String insSub(String k, String f, String o) {
    return 'pays $k vs fair $f · overpay $o% of stake';
  }

  @override
  String insFooter(String pay, String stake) {
    return 'Out hits — payout $pay. Misses — stake $stake is lost.';
  }

  @override
  String get runNeedHands => 'Run-it stats need every player\'s hand.';

  @override
  String get runOnce => 'Once';

  @override
  String get runTwice => 'Twice';

  @override
  String get runThrice => '3 times';

  @override
  String get runAll => 'Scoop the pot';

  @override
  String get runPart => 'Win a part';

  @override
  String get runNone => 'Nothing';

  @override
  String get runMean => 'Average share';

  @override
  String get runSd => 'Spread';

  @override
  String get runNoCards => '«—» — not enough cards for that many runs.';

  @override
  String get runNote =>
      'The number of runs doesn\'t change the average share, only the spread.';
}
