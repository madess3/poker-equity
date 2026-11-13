import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Хранилище настроек; подставляется в main() после загрузки.
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider не инициализирован'),
);

enum ShortDeckRule { straightOverTrips, tripsOverStraight }

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.locale,
    this.shortDeckRule = ShortDeckRule.straightOverTrips,
  });

  final ThemeMode themeMode;
  final Locale? locale; // null — язык системы
  final ShortDeckRule shortDeckRule;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    ShortDeckRule? shortDeckRule,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    locale: locale != null ? locale() : this.locale,
    shortDeckRule: shortDeckRule ?? this.shortDeckRule,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _kTheme = 'theme';
  static const _kLocale = 'locale';
  static const _kShortDeck = 'shortDeckRule';

  SharedPreferences get _p => ref.read(prefsProvider);

  @override
  AppSettings build() {
    final p = ref.read(prefsProvider);
    final lang = p.getString(_kLocale);
    return AppSettings(
      themeMode: ThemeMode.values[p.getInt(_kTheme) ?? ThemeMode.dark.index],
      locale: lang == null ? null : Locale(lang),
      shortDeckRule: ShortDeckRule.values[p.getInt(_kShortDeck) ?? 0],
    );
  }

  void setThemeMode(ThemeMode m) {
    _p.setInt(_kTheme, m.index);
    state = state.copyWith(themeMode: m);
  }

  /// Кнопка в меню: переключает на противоположную текущей видимой теме.
  void toggleTheme(Brightness current) => setThemeMode(
    current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
  );

  void setLocale(Locale? l) {
    l == null ? _p.remove(_kLocale) : _p.setString(_kLocale, l.languageCode);
    state = state.copyWith(locale: () => l);
  }

  void setShortDeckRule(ShortDeckRule r) {
    _p.setInt(_kShortDeck, r.index);
    state = state.copyWith(shortDeckRule: r);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
