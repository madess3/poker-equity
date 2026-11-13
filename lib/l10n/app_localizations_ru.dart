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
}
