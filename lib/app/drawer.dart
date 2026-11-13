import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/games/game.dart';
import '../l10n/app_localizations.dart';
import 'settings.dart';
import 'theme.dart';

/// Боковое меню: шапка с переключателем темы, игры, настройки, о приложении.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final theme = Theme.of(context);
    final current = GoRouterState.of(context).uri.path;
    final dark = theme.brightness == Brightness.dark;

    Widget item(String title, String path) {
      final on = current == path;
      return ListTile(
        minTileHeight: 48,
        shape: const StadiumBorder(),
        selected: on,
        selectedTileColor: c.accentSoft,
        selectedColor: c.accentText,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!on) context.go(path);
        },
      );
    }

    return Drawer(
      width: 304,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '♠',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(l.appTitle, style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: l.toggleTheme,
                    onPressed: () => ref
                        .read(settingsProvider.notifier)
                        .toggleTheme(theme.brightness),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (w, a) =>
                          RotationTransition(turns: a, child: w),
                      child: Icon(
                        dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        key: ValueKey(dark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: c.line, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  for (final g in Game.values) item(g.title(l), g.path),
                  Divider(color: c.line, indent: 16, endIndent: 16),
                  item(l.settings, '/settings'),
                  item(l.about, '/about'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
