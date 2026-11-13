import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../app/settings.dart';
import '../../core/widgets/select_button.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    String theme(ThemeMode m) => switch (m) {
      ThemeMode.system => l.themeSystem,
      ThemeMode.light => l.themeLight,
      ThemeMode.dark => l.themeDark,
    };
    String lang(String? code) => switch (code) {
      'ru' => l.languageRu,
      'en' => l.languageEn,
      _ => l.languageSystem,
    };
    String rule(ShortDeckRule r) => r == ShortDeckRule.straightOverTrips
        ? l.ruleStraightOverTrips
        : l.ruleTripsOverStraight;

    Widget row<T>(
      String title,
      T value,
      List<T> opts,
      String Function(T) label,
      ValueChanged<T> onChanged,
    ) => ListTile(
      minTileHeight: 64,
      title: Text(title),
      subtitle: Text(
        label(value),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final v = await showSelectSheet<T>(
          context,
          title: title,
          value: value,
          options: opts,
          optionLabel: label,
        );
        if (v != null) onChanged(v);
      },
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                row<ThemeMode>(
                  l.theme,
                  s.themeMode,
                  ThemeMode.values,
                  theme,
                  n.setThemeMode,
                ),
                row<String?>(
                  l.language,
                  s.locale?.languageCode,
                  const [null, 'ru', 'en'],
                  lang,
                  (v) => n.setLocale(v == null ? null : Locale(v)),
                ),
                row<ShortDeckRule>(
                  l.shortDeckDefault,
                  s.shortDeckRule,
                  ShortDeckRule.values,
                  rule,
                  n.setShortDeckRule,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
