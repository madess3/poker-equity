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
}
