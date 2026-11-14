import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// «Премиум»: всё и так бесплатно и без рекламы; добровольный донат.
/// Оплаты пока нет — только суммы (появится после выхода в Google Play).
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const amounts = ['4.99', '19.99', '99.99', '999.99'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l.premium)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.premiumAd,
                    style: t.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.premiumFree,
                    style: t.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(l.premiumDonate, style: t.bodySmall),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.4,
            children: [
              for (final a in amounts)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(l.premiumSoon))),
                  child: Text(
                    '\$$a',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
