// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Poker Equity';

  @override
  String get holdem => 'Холдем';

  @override
  String get omaha => 'Омаха';

  @override
  String get omahaHiLo => 'Омаха хай-лоу';

  @override
  String get shortDeck => 'Шорт-дек';

  @override
  String get pineapple => 'Ананас';

  @override
  String get ofc => 'OFC';

  @override
  String get handStrength => 'Сила руки';

  @override
  String get settings => 'Настройки';

  @override
  String get about => 'О приложении';

  @override
  String get menu => 'Меню';

  @override
  String get toggleTheme => 'Переключить тему';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get shortDeckDefault => 'Шорт-дек по умолчанию';

  @override
  String get ruleStraightOverTrips => 'Стрит > сет';

  @override
  String get ruleTripsOverStraight => 'Сет > стрит';

  @override
  String get doubleBoard => 'Дабл борд';

  @override
  String get cameraV2 => 'Камера (в версии 2)';

  @override
  String get board => 'Борд';

  @override
  String boardN(int n) {
    return 'Борд $n';
  }

  @override
  String playerN(int n) {
    return 'Игрок $n';
  }

  @override
  String get cardsLabel => 'Карт:';

  @override
  String get playersLabel => 'Игроков:';

  @override
  String get rulesLabel => 'Правила:';

  @override
  String get gameLabel => 'Игра:';

  @override
  String get cardsOnHand => 'Карт на руке';

  @override
  String get playersTitle => 'Игроков';

  @override
  String get rulesTitle => 'Правила';

  @override
  String get gameTitle => 'Игра';

  @override
  String get comingSoon => 'Расчёт появится в следующих версиях';

  @override
  String get boxTop => 'Верх';

  @override
  String get boxMiddle => 'Середина';

  @override
  String get boxBottom => 'Низ';

  @override
  String get topPercent => 'Топ —';

  @override
  String version(String v) {
    return 'Версия $v';
  }

  @override
  String get offlineNote => 'Работает без интернета. Данные не собираются.';

  @override
  String get done => 'Готово';

  @override
  String get clearCard => 'Убрать карту';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String winTie(String w, String t) {
    return 'побед $w · ничьих $t';
  }

  @override
  String boardsLine(String b1, String b2, String s) {
    return 'Б1 $b1 · Б2 $b2 · скуп $s';
  }

  @override
  String get deadCards => 'Мёртвые карты';

  @override
  String get deadShort => 'Мёртвые';

  @override
  String get analysis => 'Анализ';

  @override
  String get range => 'Диапазон';

  @override
  String rangeShort(String p) {
    return 'Диапазон $p';
  }

  @override
  String get mixMuck => 'Замешать срезку и мак';

  @override
  String get muckMixed => 'Срезка и мак замешаны';

  @override
  String lowPossible(String p) {
    return 'Лоу возможен в $p раздач';
  }

  @override
  String hiLoLine(String h, String lo, String s) {
    return 'хай $h · лоу $lo · скуп $s';
  }

  @override
  String get discard => 'Сбросить';

  @override
  String get bestOption => 'лучший';

  @override
  String topN(String p) {
    return 'Топ $p';
  }

  @override
  String combosCount(int n) {
    return '$n комбинаций';
  }

  @override
  String get clearRange => 'Очистить';

  @override
  String rankOf(int k, int n) {
    return '#$k из $n';
  }

  @override
  String get typeLabel => 'Тип:';

  @override
  String get typeTitle => 'Тип игры';

  @override
  String get typeHi => 'Хай';

  @override
  String get typeHiLo => 'Хай-лоу';

  @override
  String get playerLabel => 'Игрок:';

  @override
  String get outsTab => 'Ауты';

  @override
  String get combosTab => 'Комбинации';

  @override
  String get outsTitle => 'Ауты на следующую улицу';

  @override
  String get outsUnavailable =>
      'Ауты считаются, когда известны карты всех игроков и открыт флоп или тёрн.';

  @override
  String get outsAhead => 'Игрок уже впереди — аутов нет.';

  @override
  String outsChanceFlop(String n, String r) {
    return 'На тёрне $n · к риверу $r';
  }

  @override
  String outsChanceTurn(String n) {
    return 'На ривере $n';
  }

  @override
  String get pot => 'Банк';

  @override
  String get betToCall => 'Ставка соперника';

  @override
  String get needEquity => 'Нужно эквити';

  @override
  String get yourEquity => 'Ваше эквити';

  @override
  String get potOdds => 'Пот-оддсы';

  @override
  String get evCall => 'EV колла';

  @override
  String get callGood => 'Колл выгоден';

  @override
  String get callBad => 'Колл невыгоден';

  @override
  String get toRiver => 'Шансы к риверу';

  @override
  String get catHigh => 'Старшая карта';

  @override
  String get catPair => 'Пара';

  @override
  String get catTwoPair => 'Две пары';

  @override
  String get catTrips => 'Сет';

  @override
  String get catStraight => 'Стрит';

  @override
  String get catFlush => 'Флеш';

  @override
  String get catFullHouse => 'Фулл-хаус';

  @override
  String get catQuads => 'Каре';

  @override
  String get catStraightFlush => 'Стрит-флеш';

  @override
  String get removePlayer => 'Убрать игрока';

  @override
  String get deckEmpty => 'Колода закончилась: добор невозможен';

  @override
  String get icmTitle => 'ICM · делёжка';

  @override
  String get icmStacks => 'Стеки';

  @override
  String icmChipsTotal(String n) {
    return 'Всего фишек: $n';
  }

  @override
  String get icmPrizes => 'Призовые';

  @override
  String icmPlace(int n) {
    return '$n-е место';
  }

  @override
  String icmFund(String n) {
    return 'Фонд: $n';
  }

  @override
  String get icmPrizeOrder => 'Призы должны идти по убыванию';

  @override
  String get icmLeave => 'Оставить победителю';

  @override
  String get icmFillAll => 'Заполните стеки всех игроков и призовые.';

  @override
  String get icmPlayer => 'Игрок';

  @override
  String get icmByChips => 'По фишкам';

  @override
  String get icmEqual => 'Поровну';

  @override
  String get icmOverFirst => 'больше первого приза';

  @override
  String icmReserved(String r) {
    return 'Разыгрывается: $r';
  }

  @override
  String get icmNote =>
      'ICM считает всех игроков равными по силе и не учитывает блайнды и позицию.';

  @override
  String get menuChop => 'EV chop · Страховка';

  @override
  String get insuranceTab => 'Страховка';

  @override
  String get runoutsTab => 'Прокрутки';

  @override
  String get toHand => 'К раздаче';

  @override
  String get needTwoHands => 'Введите руки минимум двух игроков';

  @override
  String get modelLabel => 'Модель:';

  @override
  String get modelTitle => 'Модель';

  @override
  String get modelChop => 'EV chop';

  @override
  String get modelOuts => 'Страховка от аутов';

  @override
  String get allCardsOpen => 'Все карты открыты';

  @override
  String get feePct => 'Комиссия, %';

  @override
  String get chopSum => 'Сумма EV chop';

  @override
  String get fee => 'Комиссия';

  @override
  String get shareNoDeal => 'Доля без сделки';

  @override
  String chopCosts(String x) {
    return 'EV chop стоит $x';
  }

  @override
  String chopOfShare(String p) {
    return '$p от вашей доли в банке';
  }

  @override
  String get feeFromPot => 'Комиссия считается от банка';

  @override
  String get insTwoPlayers => 'Нужны ровно 2 игрока с известными руками.';

  @override
  String get insStreet => 'Страховка считается на флопе или тёрне.';

  @override
  String get insuredLabel => 'Страхуется:';

  @override
  String get streetLabel => 'Улица:';

  @override
  String get streetTitle => 'Улица';

  @override
  String get streetToRiver => 'до ривера';

  @override
  String get streetTurn => 'тёрн';

  @override
  String get insNoOuts => 'У соперника нет аутов — страховать нечего.';

  @override
  String get insStake => 'Сумма страховки';

  @override
  String get insOdds => 'Коэффициент выплаты';

  @override
  String get insOppOuts => 'Ауты соперника';

  @override
  String get insChance => 'Шанс аута';

  @override
  String get insFair => 'Честный коэфф.';

  @override
  String get insEv => 'EV страховки';

  @override
  String get insGood => 'Страховка выгодна';

  @override
  String get insBad => 'Страховка невыгодна';

  @override
  String insSub(String k, String f, String o) {
    return 'дают $k при честных $f · переплата $o% взноса';
  }

  @override
  String insFooter(String pay, String stake) {
    return 'Попал аут — выплата $pay. Не попал — взнос $stake сгорает.';
  }

  @override
  String get runNeedHands =>
      'Прокрутки считаются, когда известны руки всех игроков.';

  @override
  String get runOnce => '1 раз';

  @override
  String get runTwice => '2 раза';

  @override
  String get runThrice => '3 раза';

  @override
  String get runAll => 'Забрать весь банк';

  @override
  String get runPart => 'Получить часть';

  @override
  String get runNone => 'Ничего';

  @override
  String get runMean => 'Средняя доля';

  @override
  String get runSd => 'Разброс';

  @override
  String get runNoCards =>
      '«—» — карт в колоде не хватает на это число прогонов.';

  @override
  String get runNote =>
      'Число прогонов не меняет среднюю долю, меняется только разброс.';
}
