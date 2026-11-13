import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/playing_card.dart';
import '../../../core/widgets/select_button.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/equity.dart';
import '../logic/outs.dart';
import '../logic/rules.dart';
import 'equity_screen.dart' show pct;

/// Анализ раздачи для выбранного игрока: ауты, EV и пот-оддсы, шансы комбинаций.
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.rules,
    required this.hands,
    required this.board,
    required this.dead,
    required this.acc,
  });

  final Rules rules;
  final List<List<int>> hands;
  final List<int> board;
  final List<int> dead;
  final EquityAcc acc;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int player = 0;
  final pot = TextEditingController(text: '100');
  final bet = TextEditingController(text: '50');

  @override
  void dispose() {
    pot.dispose();
    bet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.analysis),
          bottom: TabBar(
            tabs: [
              Tab(text: l.outsTab),
              const Tab(text: 'EV'),
              Tab(text: l.combosTab),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SelectButton<int>(
                label: l.playerLabel,
                sheetTitle: l.playersTitle,
                value: player,
                options: [for (var i = 0; i < widget.hands.length; i++) i],
                optionLabel: (i) => l.playerN(i + 1),
                onChanged: (v) => setState(() => player = v),
              ),
            ),
            Expanded(
              child: TabBarView(children: [_outs(l), _ev(l), _combos(l)]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  Widget _outs(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final outs = computeOuts(
      widget.rules,
      widget.hands,
      widget.board,
      widget.dead,
      player,
    );
    final children = <Widget>[];
    if (outs == null) {
      children.add(Text(l.outsUnavailable, style: t.bodyMedium));
    } else if (outs.isEmpty) {
      children.add(Text(l.outsAhead, style: t.bodyMedium));
    } else {
      final known = {
        ...widget.board,
        ...widget.dead,
        for (final h in widget.hands) ...h,
      };
      final unseen = widget.rules.deckSize - known.length;
      final (next, river) = outsChance(
        outs.length,
        unseen,
        5 - widget.board.length,
      );
      children.addAll([
        Row(
          children: [
            Expanded(child: Text(l.outsTitle, style: t.titleMedium)),
            Text('${outs.length}', style: t.headlineSmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.board.length == 3
              ? l.outsChanceFlop(pct(next), pct(river))
              : l.outsChanceTurn(pct(next)),
          style: t.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in outs)
              PlayingCardView(card: c, width: 40, height: 54),
          ],
        ),
      ]);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_box(children)],
    );
  }

  Widget _ev(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final p = double.tryParse(pot.text.replaceAll(',', '.')) ?? 0;
    final b = double.tryParse(bet.text.replaceAll(',', '.')) ?? 0;
    final eq = widget.acc.equity(player);
    final total = p + 2 * b;
    final need = total > 0 ? b / total : 0.0;
    final ev = eq * total - b;
    final good = ev >= 0;

    Widget field(String label, TextEditingController ctl) => Expanded(
      child: TextField(
        controller: ctl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );

    Widget stat(String k, String v, {Color? color}) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: t.bodySmall),
            const SizedBox(height: 2),
            Text(v, style: t.titleLarge?.copyWith(color: color)),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _box([
          Row(
            children: [
              field(l.pot, pot),
              const SizedBox(width: 12),
              field(l.betToCall, bet),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              stat(l.needEquity, pct(need)),
              const SizedBox(width: 8),
              stat(l.yourEquity, pct(eq)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              stat(
                l.potOdds,
                b > 0 ? '${((p + b) / b).toStringAsFixed(1)} : 1' : '—',
              ),
              const SizedBox(width: 8),
              stat(
                l.evCall,
                '${ev >= 0 ? '+' : ''}${ev.toStringAsFixed(1)}',
                color: good ? Theme.of(context).colorScheme.primary : c.warn,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: good ? c.accentSoft : c.warnBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              good ? l.callGood : l.callBad,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: good ? c.accentText : c.warn,
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _combos(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final names = [
      l.catHigh,
      l.catPair,
      l.catTwoPair,
      l.catTrips,
      l.catStraight,
      l.catFlush,
      l.catFullHouse,
      l.catQuads,
      l.catStraightFlush,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _box([
          Text(l.toRiver, style: t.titleMedium),
          const SizedBox(height: 12),
          for (var k = 8; k >= 0; k--)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(width: 116, child: Text(names[k])),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.acc.catChance(player, k),
                        minHeight: 8,
                        backgroundColor: c.surface2,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      pct(widget.acc.catChance(player, k)),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ]),
      ],
    );
  }
}
