import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// Справка OFC: таблица роялти и памятка по вариантам игры.
class OfcHelpScreen extends StatelessWidget {
  const OfcHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;

    Widget table(String title, List<(String, String)> rows) => Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: t.titleMedium),
            const SizedBox(height: 6),
            for (final (k, v) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(k, style: TextStyle(color: c.muted)),
                    ),
                    Text(
                      '+$v',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    Widget variant(String title, List<String> lines) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: t.titleMedium),
            const SizedBox(height: 6),
            for (final s in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $s',
                  style: TextStyle(color: c.muted, height: 1.4),
                ),
              ),
          ],
        ),
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.ofcHelp),
          bottom: TabBar(
            tabs: [
              Tab(text: l.ofcRoyaltiesTab),
              Tab(text: l.ofcVariantsTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                table(l.boxBottom, [
                  (l.catStraight, '2'),
                  (l.catFlush, '4'),
                  (l.catFullHouse, '6'),
                  (l.catQuads, '10'),
                  (l.catStraightFlush, '15'),
                  (l.catRoyal, '25'),
                ]),
                const SizedBox(height: 8),
                table(l.boxMiddle, [
                  (l.catTrips, '2'),
                  (l.catStraight, '4'),
                  (l.catFlush, '8'),
                  (l.catFullHouse, '12'),
                  (l.catQuads, '20'),
                  (l.catStraightFlush, '30'),
                  (l.catRoyal, '50'),
                ]),
                const SizedBox(height: 8),
                table(l.boxTop, [
                  ('66', '1'),
                  ('77', '2'),
                  ('88', '3'),
                  ('99', '4'),
                  ('TT', '5'),
                  ('JJ', '6'),
                  ('QQ', '7'),
                  ('KK', '8'),
                  ('AA', '9'),
                  ('222', '10'),
                  ('333 … KKK', '11 … 21'),
                  ('AAA', '22'),
                ]),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l.ofcRules,
                      style: TextStyle(color: c.muted, height: 1.45),
                    ),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                variant(
                  l.ofcVarProgressive,
                  l.ofcVarProgressiveText.split('\n'),
                ),
                const SizedBox(height: 8),
                variant(l.ofcVarUnlimited, l.ofcVarUnlimitedText.split('\n')),
                const SizedBox(height: 8),
                variant(l.ofcVarJokers, l.ofcVarJokersText.split('\n')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
