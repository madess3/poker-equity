import 'package:material_ui/material_ui.dart';

import '../../../app/drawer.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/playing_card.dart';
import '../../../core/widgets/select_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../games/game.dart';
import '../logic/equity.dart';
import 'card_keyboard.dart';

/// Экран расчёта эквити (сейчас — Холдем): ввод карт, автопересчёт, дабл борд.
class EquityScreen extends StatefulWidget {
  const EquityScreen({super.key, required this.game});
  final Game game;

  @override
  State<EquityScreen> createState() => _EquityScreenState();
}

class _EquityScreenState extends State<EquityScreen> {
  int players = 2;
  bool doubleBoard = false;
  final Map<String, int> cards = {}; // слот → карта
  String? selected = 'p0_0';
  bool keyboard = true;

  EquityResult? result;
  bool busy = false;
  int _gen = 0;

  int get hole => widget.game.handCards.first;
  int get boardCount => doubleBoard ? 2 : 1;

  /// Порядок заполнения: игроки, затем борды.
  List<String> get slotOrder => [
    for (var i = 0; i < players; i++)
      for (var j = 0; j < hole; j++) 'p${i}_$j',
    for (var b = 0; b < boardCount; b++)
      for (var j = 0; j < 5; j++) 'b${b}_$j',
  ];

  void _select(String key) => setState(() {
    selected = key;
    keyboard = true;
  });

  void _place(int card) {
    final key = selected;
    if (key == null) return;
    setState(() {
      cards[key] = card;
      final order = slotOrder;
      final start = order.indexOf(key);
      String? next;
      for (var k = 1; k <= order.length; k++) {
        final cand = order[(start + k) % order.length];
        if (!cards.containsKey(cand)) {
          next = cand;
          break;
        }
      }
      selected = next;
      if (next == null) keyboard = false;
    });
    _recalc();
  }

  void _clearSelected() {
    final key = selected;
    if (key == null || !cards.containsKey(key)) return;
    setState(() => cards.remove(key));
    _recalc();
  }

  void _clearAll() {
    setState(() {
      cards.clear();
      selected = 'p0_0';
      keyboard = true;
      result = null;
    });
  }

  void _setPlayers(int v) {
    setState(() {
      players = v;
      cards.removeWhere(
        (k, _) =>
            k.startsWith('p') && int.parse(k.substring(1, k.indexOf('_'))) >= v,
      );
      if (selected != null && !slotOrder.contains(selected)) selected = null;
    });
    _recalc();
  }

  void _setDoubleBoard(bool v) {
    setState(() {
      doubleBoard = v;
      if (!v) cards.removeWhere((k, _) => k.startsWith('b1_'));
      if (selected != null && !slotOrder.contains(selected)) selected = null;
    });
    _recalc();
  }

  Future<void> _recalc() async {
    final hands = [
      for (var i = 0; i < players; i++)
        [for (var j = 0; j < hole; j++) ?cards['p${i}_$j']],
    ];
    if (hands.every((h) => h.isEmpty)) {
      setState(() => result = null);
      return;
    }
    final req = EquityRequest(
      hands: hands,
      boards: [
        for (var b = 0; b < boardCount; b++)
          [for (var j = 0; j < 5; j++) ?cards['b${b}_$j']],
      ],
      holeCards: hole,
    );
    final gen = ++_gen;
    setState(() => busy = true);
    final r = await computeEquityAsync(req);
    if (!mounted || gen != _gen) return;
    setState(() {
      result = r;
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final g = widget.game;
    final theme = Theme.of(context);
    final t = theme.textTheme;

    Widget slot(String key, double w, double h) => PlayingCardView(
      card: cards[key],
      width: w,
      height: h,
      selected: keyboard && selected == key,
      onTap: () => _select(key),
    );

    Widget boardRow(int b) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              doubleBoard ? l.boardN(b + 1) : l.board,
              style: t.bodySmall,
            ),
          ),
          for (var j = 0; j < 5; j++) ...[
            if (j > 0) const SizedBox(width: 6),
            slot('b${b}_$j', 50, 68),
          ],
        ],
      ),
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(g.title(l)),
        actions: [
          FilterChip(
            label: Text(l.doubleBoard),
            selected: doubleBoard,
            showCheckmark: false,
            selectedColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
              fontSize: 13,
              color: doubleBoard ? theme.colorScheme.onPrimary : null,
            ),
            onSelected: _setDoubleBoard,
          ),
          IconButton(
            tooltip: l.clearAll,
            onPressed: cards.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          IconButton(
            tooltip: l.cameraV2,
            onPressed: null,
            icon: const Icon(Icons.photo_camera_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                SelectButton<int>(
                  label: l.playersLabel,
                  sheetTitle: l.playersTitle,
                  value: players,
                  options: [for (var i = 2; i <= g.maxPlayersFor(hole); i++) i],
                  optionLabel: (v) => '$v',
                  onChanged: _setPlayers,
                ),
                const SizedBox(height: 12),
                for (var b = 0; b < boardCount; b++) boardRow(b),
                const SizedBox(height: 4),
                for (var i = 0; i < players; i++)
                  _PlayerTile(
                    name: l.playerN(i + 1),
                    cards: [
                      for (var j = 0; j < hole; j++) slot('p${i}_$j', 50, 68),
                    ],
                    result: result?.players[i],
                    doubleBoard: doubleBoard,
                    stale: busy,
                  ),
              ],
            ),
          ),
          if (keyboard && selected != null)
            CardKeyboard(
              used: cards.values.toSet(),
              onPick: _place,
              onClear: _clearSelected,
              onDone: () => setState(() => keyboard = false),
            ),
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.name,
    required this.cards,
    required this.result,
    required this.doubleBoard,
    required this.stale,
  });

  final String name;
  final List<Widget> cards;
  final PlayerEquity? result;
  final bool doubleBoard;
  final bool stale;

  static String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final r = result;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: t.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (final (i, w) in cards.indexed) ...[
                        if (i > 0) const SizedBox(width: 6),
                        w,
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: stale ? 0.5 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        r == null ? '—' : pct(r.equity),
                        textAlign: TextAlign.right,
                        style: t.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: r?.equity ?? 0,
                          minHeight: 6,
                          backgroundColor: c.surface2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (r != null)
                        Text(
                          doubleBoard
                              ? l.boardsLine(
                                  pct(r.perBoard[0]),
                                  pct(r.perBoard[1]),
                                  pct(r.scoop),
                                )
                              : l.winTie(pct(r.win), pct(r.tie)),
                          textAlign: TextAlign.right,
                          style: t.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
