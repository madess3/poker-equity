import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../l10n/app_localizations.dart';

const appVersion = '0.4.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.appTitle, style: t.titleLarge),
                  const SizedBox(height: 4),
                  Text(l.version(appVersion), style: t.bodySmall),
                  const SizedBox(height: 12),
                  Text(l.offlineNote),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
