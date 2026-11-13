import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Poker Equity'**
  String get appTitle;

  /// No description provided for @holdem.
  ///
  /// In ru, this message translates to:
  /// **'Холдем'**
  String get holdem;

  /// No description provided for @omaha.
  ///
  /// In ru, this message translates to:
  /// **'Омаха'**
  String get omaha;

  /// No description provided for @omahaHiLo.
  ///
  /// In ru, this message translates to:
  /// **'Омаха хай-лоу'**
  String get omahaHiLo;

  /// No description provided for @shortDeck.
  ///
  /// In ru, this message translates to:
  /// **'Шорт-дек'**
  String get shortDeck;

  /// No description provided for @pineapple.
  ///
  /// In ru, this message translates to:
  /// **'Ананас'**
  String get pineapple;

  /// No description provided for @ofc.
  ///
  /// In ru, this message translates to:
  /// **'OFC'**
  String get ofc;

  /// No description provided for @handStrength.
  ///
  /// In ru, this message translates to:
  /// **'Сила руки'**
  String get handStrength;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about;

  /// No description provided for @menu.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get menu;

  /// No description provided for @toggleTheme.
  ///
  /// In ru, this message translates to:
  /// **'Переключить тему'**
  String get toggleTheme;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системный'**
  String get languageSystem;

  /// No description provided for @languageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @shortDeckDefault.
  ///
  /// In ru, this message translates to:
  /// **'Шорт-дек по умолчанию'**
  String get shortDeckDefault;

  /// No description provided for @ruleStraightOverTrips.
  ///
  /// In ru, this message translates to:
  /// **'Стрит > сет'**
  String get ruleStraightOverTrips;

  /// No description provided for @ruleTripsOverStraight.
  ///
  /// In ru, this message translates to:
  /// **'Сет > стрит'**
  String get ruleTripsOverStraight;

  /// No description provided for @doubleBoard.
  ///
  /// In ru, this message translates to:
  /// **'Дабл борд'**
  String get doubleBoard;

  /// No description provided for @cameraV2.
  ///
  /// In ru, this message translates to:
  /// **'Камера (в версии 2)'**
  String get cameraV2;

  /// No description provided for @board.
  ///
  /// In ru, this message translates to:
  /// **'Борд'**
  String get board;

  /// No description provided for @boardN.
  ///
  /// In ru, this message translates to:
  /// **'Борд {n}'**
  String boardN(int n);

  /// No description provided for @playerN.
  ///
  /// In ru, this message translates to:
  /// **'Игрок {n}'**
  String playerN(int n);

  /// No description provided for @cardsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Карт:'**
  String get cardsLabel;

  /// No description provided for @playersLabel.
  ///
  /// In ru, this message translates to:
  /// **'Игроков:'**
  String get playersLabel;

  /// No description provided for @rulesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Правила:'**
  String get rulesLabel;

  /// No description provided for @gameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Игра:'**
  String get gameLabel;

  /// No description provided for @cardsOnHand.
  ///
  /// In ru, this message translates to:
  /// **'Карт на руке'**
  String get cardsOnHand;

  /// No description provided for @playersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Игроков'**
  String get playersTitle;

  /// No description provided for @rulesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Правила'**
  String get rulesTitle;

  /// No description provided for @gameTitle.
  ///
  /// In ru, this message translates to:
  /// **'Игра'**
  String get gameTitle;

  /// No description provided for @comingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт появится в следующих версиях'**
  String get comingSoon;

  /// No description provided for @boxTop.
  ///
  /// In ru, this message translates to:
  /// **'Верх'**
  String get boxTop;

  /// No description provided for @boxMiddle.
  ///
  /// In ru, this message translates to:
  /// **'Середина'**
  String get boxMiddle;

  /// No description provided for @boxBottom.
  ///
  /// In ru, this message translates to:
  /// **'Низ'**
  String get boxBottom;

  /// No description provided for @topPercent.
  ///
  /// In ru, this message translates to:
  /// **'Топ —'**
  String get topPercent;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия {v}'**
  String version(String v);

  /// No description provided for @offlineNote.
  ///
  /// In ru, this message translates to:
  /// **'Работает без интернета. Данные не собираются.'**
  String get offlineNote;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @clearCard.
  ///
  /// In ru, this message translates to:
  /// **'Убрать карту'**
  String get clearCard;

  /// No description provided for @clearAll.
  ///
  /// In ru, this message translates to:
  /// **'Очистить всё'**
  String get clearAll;

  /// No description provided for @winTie.
  ///
  /// In ru, this message translates to:
  /// **'побед {w} · ничьих {t}'**
  String winTie(String w, String t);

  /// No description provided for @boardsLine.
  ///
  /// In ru, this message translates to:
  /// **'Б1 {b1} · Б2 {b2} · скуп {s}'**
  String boardsLine(String b1, String b2, String s);

  /// No description provided for @deadCards.
  ///
  /// In ru, this message translates to:
  /// **'Мёртвые карты'**
  String get deadCards;

  /// No description provided for @deadShort.
  ///
  /// In ru, this message translates to:
  /// **'Мёртвые'**
  String get deadShort;

  /// No description provided for @analysis.
  ///
  /// In ru, this message translates to:
  /// **'Анализ'**
  String get analysis;

  /// No description provided for @range.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон'**
  String get range;

  /// No description provided for @rangeShort.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон {p}'**
  String rangeShort(String p);

  /// No description provided for @mixMuck.
  ///
  /// In ru, this message translates to:
  /// **'Замешать срезку и мак'**
  String get mixMuck;

  /// No description provided for @muckMixed.
  ///
  /// In ru, this message translates to:
  /// **'Срезка и мак замешаны'**
  String get muckMixed;

  /// No description provided for @lowPossible.
  ///
  /// In ru, this message translates to:
  /// **'Лоу возможен в {p} раздач'**
  String lowPossible(String p);

  /// No description provided for @hiLoLine.
  ///
  /// In ru, this message translates to:
  /// **'хай {h} · лоу {lo} · скуп {s}'**
  String hiLoLine(String h, String lo, String s);

  /// No description provided for @discard.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get discard;

  /// No description provided for @bestOption.
  ///
  /// In ru, this message translates to:
  /// **'лучший'**
  String get bestOption;

  /// No description provided for @topN.
  ///
  /// In ru, this message translates to:
  /// **'Топ {p}'**
  String topN(String p);

  /// No description provided for @combosCount.
  ///
  /// In ru, this message translates to:
  /// **'{n} комбинаций'**
  String combosCount(int n);

  /// No description provided for @clearRange.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clearRange;

  /// No description provided for @rankOf.
  ///
  /// In ru, this message translates to:
  /// **'#{k} из {n}'**
  String rankOf(int k, int n);

  /// No description provided for @typeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип:'**
  String get typeLabel;

  /// No description provided for @typeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тип игры'**
  String get typeTitle;

  /// No description provided for @typeHi.
  ///
  /// In ru, this message translates to:
  /// **'Хай'**
  String get typeHi;

  /// No description provided for @typeHiLo.
  ///
  /// In ru, this message translates to:
  /// **'Хай-лоу'**
  String get typeHiLo;

  /// No description provided for @playerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Игрок:'**
  String get playerLabel;

  /// No description provided for @outsTab.
  ///
  /// In ru, this message translates to:
  /// **'Ауты'**
  String get outsTab;

  /// No description provided for @combosTab.
  ///
  /// In ru, this message translates to:
  /// **'Комбинации'**
  String get combosTab;

  /// No description provided for @outsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ауты на следующую улицу'**
  String get outsTitle;

  /// No description provided for @outsUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Ауты считаются, когда известны карты всех игроков и открыт флоп или тёрн.'**
  String get outsUnavailable;

  /// No description provided for @outsAhead.
  ///
  /// In ru, this message translates to:
  /// **'Игрок уже впереди — аутов нет.'**
  String get outsAhead;

  /// No description provided for @outsChanceFlop.
  ///
  /// In ru, this message translates to:
  /// **'На тёрне {n} · к риверу {r}'**
  String outsChanceFlop(String n, String r);

  /// No description provided for @outsChanceTurn.
  ///
  /// In ru, this message translates to:
  /// **'На ривере {n}'**
  String outsChanceTurn(String n);

  /// No description provided for @pot.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get pot;

  /// No description provided for @betToCall.
  ///
  /// In ru, this message translates to:
  /// **'Ставка соперника'**
  String get betToCall;

  /// No description provided for @needEquity.
  ///
  /// In ru, this message translates to:
  /// **'Нужно эквити'**
  String get needEquity;

  /// No description provided for @yourEquity.
  ///
  /// In ru, this message translates to:
  /// **'Ваше эквити'**
  String get yourEquity;

  /// No description provided for @potOdds.
  ///
  /// In ru, this message translates to:
  /// **'Пот-оддсы'**
  String get potOdds;

  /// No description provided for @evCall.
  ///
  /// In ru, this message translates to:
  /// **'EV колла'**
  String get evCall;

  /// No description provided for @callGood.
  ///
  /// In ru, this message translates to:
  /// **'Колл выгоден'**
  String get callGood;

  /// No description provided for @callBad.
  ///
  /// In ru, this message translates to:
  /// **'Колл невыгоден'**
  String get callBad;

  /// No description provided for @toRiver.
  ///
  /// In ru, this message translates to:
  /// **'Шансы к риверу'**
  String get toRiver;

  /// No description provided for @catHigh.
  ///
  /// In ru, this message translates to:
  /// **'Старшая карта'**
  String get catHigh;

  /// No description provided for @catPair.
  ///
  /// In ru, this message translates to:
  /// **'Пара'**
  String get catPair;

  /// No description provided for @catTwoPair.
  ///
  /// In ru, this message translates to:
  /// **'Две пары'**
  String get catTwoPair;

  /// No description provided for @catTrips.
  ///
  /// In ru, this message translates to:
  /// **'Сет'**
  String get catTrips;

  /// No description provided for @catStraight.
  ///
  /// In ru, this message translates to:
  /// **'Стрит'**
  String get catStraight;

  /// No description provided for @catFlush.
  ///
  /// In ru, this message translates to:
  /// **'Флеш'**
  String get catFlush;

  /// No description provided for @catFullHouse.
  ///
  /// In ru, this message translates to:
  /// **'Фулл-хаус'**
  String get catFullHouse;

  /// No description provided for @catQuads.
  ///
  /// In ru, this message translates to:
  /// **'Каре'**
  String get catQuads;

  /// No description provided for @catStraightFlush.
  ///
  /// In ru, this message translates to:
  /// **'Стрит-флеш'**
  String get catStraightFlush;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
