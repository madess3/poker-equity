import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/drawer.dart';
import '../../../app/settings.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/playing_card.dart';
import '../../../core/widgets/select_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../games/game.dart';
import '../logic/equity.dart';
import '../logic/ranges.dart';
import '../logic/rules.dart';
import 'analysis_screen.dart';
import 'card_keyboard.dart';
import 'range_screen.dart';

String pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

/// Экран расчёта эквити для Холдема, Омах, Шорт-дека и Ананаса.
class EquityScreen extends ConsumerStatefulWidget {
  const EquityScreen({super.key, required this.game});
  final Game game;

  @override
  ConsumerState<EquityScreen> createState() => _EquityScreenState();
}

class _EquityScreenState extends ConsumerState<EquityScreen> {
  late int handSize = widget.game.handCards.first;
  int players = 2;
  bool doubleBoard = false;
  ShortDeckRule? rule;
  final Map<String, int> cards = {}; // слот → карта
  final List<int> dead = [];
  final Map<int, Set<String>> ranges = {};
  final Set<int> discarded = {}; // ананас: игроки, уже сбросившие карту
  String? selected = 'p0_0';
  bool keyboard = true;
  bool showDead = false;
  bool mixed = false;

  EquityAcc? acc;
  bool busy = false;
  bool muckNeeded = false;
  Map<int, List<(int, double)>> pineOptions = {};
  int _gen = 0;

  Game get game => widget.game;
  bool get isShort => game == Game.shortDeck;
  bool get isPine => game == Game.pineapple;
  bool get hasRanges => game == Game.holdem || game == Game.shortDeck;
  int get boardCount => doubleBoard ? 2 : 1;
  int holeOf(int i) => isPine && discarded.contains(i) ? 2 : handSize;

  Rules get rules {
    final r = rule ?? ref.read(settingsProvider).shortDeckRule;
    return switch (game) {
      Game.omaha => Rules(Variant.omaha, hole: handSize),
      Game.omahaHiLo => Rules(Variant.omahaHiLo, hole: handSize),
      Game.shortDeck => Rules(
        Variant.shortDeck,
        tripsOverStraight: r == ShortDeckRule.tripsOverStraight,
      ),
      Game.pineapple => const Rules(Variant.pineapple, hole: 3),
      _ => const Rules(Variant.holdem),
    };
  }

  List<int> handOf(int i) => [
    for (var j = 0; j < holeOf(i); j++) ?cards['p${i}_$j'],
  ];
  List<int> boardOf(int b) => [for (var j = 0; j < 5; j++) ?cards['b${b}_$j']];

  List<String> get slotOrder => [
    for (var i = 0; i < players; i++)
      if (!ranges.containsKey(i))
        for (var j = 0; j < holeOf(i); j++) 'p${i}_$j',
    for (var b = 0; b < boardCount; b++)
      for (var j = 0; j < 5; j++) 'b${b}_$j',
  ];

  Set<int> get used => {...cards.values, ...dead};

  // ---------- ввод карт ----------

  void _select(String key) => setState(() {
    selected = key;
    keyboard = true;
  });

  void _place(int card) {
    final key = selected;
    if (key == null) return;
    setState(() {
      if (key == 'dead') {
        dead.add(card);
        return;
      }
      if (key.startsWith('dead:')) {
        final i = dead.indexOf(int.parse(key.substring(5)));
        if (i >= 0) dead[i] = card;
        selected = 'dead';
        return;
      }
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
    if (key == null) return;
    setState(() {
      if (key.startsWith('dead:')) {
        dead.remove(int.parse(key.substring(5)));
        selected = 'dead';
      } else {
        cards.remove(key);
      }
    });
    _recalc();
  }

  void _clearAll() {
    setState(() {
      cards.clear();
      dead.clear();
      ranges.clear();
      discarded.clear();
      mixed = false;
      showDead = false;
      selected = 'p0_0';
      keyboard = true;
      acc = null;
      muckNeeded = false;
      pineOptions = {};
    });
  }

  void _setPlayers(int v) {
    setState(() {
      players = v;
      cards.removeWhere((k, _) => k.startsWith('p') && _playerOf(k) >= v);
      ranges.removeWhere((i, _) => i >= v);
      discarded.removeWhere((i) => i >= v);
      _fixSelection();
    });
    _recalc();
  }

  void _setHandSize(int v) {
    setState(() {
      handSize = v;
      final maxP = game.maxPlayersFor(v);
      if (players > maxP) players = maxP;
      cards.removeWhere(
        (k, _) =>
            k.startsWith('p') && (_playerOf(k) >= players || _slotOf(k) >= v),
      );
      _fixSelection();
    });
    _recalc();
  }

  void _setDoubleBoard(bool v) {
    setState(() {
      doubleBoard = v;
      if (!v) cards.removeWhere((k, _) => k.startsWith('b1_'));
      _fixSelection();
    });
    _recalc();
  }

  int _playerOf(String k) => int.parse(k.substring(1, k.indexOf('_')));
  int _slotOf(String k) => int.parse(k.substring(k.indexOf('_') + 1));

  void _fixSelection() {
    final s = selected;
    if (s != null && !s.startsWith('dead') && !slotOrder.contains(s)) {
      selected = null;
      keyboard = false;
    }
  }

  void _discard(int player, int card) {
    setState(() {
      final rest = handOf(player)..remove(card);
      for (var j = 0; j < 3; j++) {
        cards.remove('p${player}_$j');
      }
      cards['p${player}_0'] = rest[0];
      cards['p${player}_1'] = rest[1];
      discarded.add(player);
      dead.add(card);
      pineOptions.remove(player);
    });
    _recalc();
  }

  Future<void> _editRange(int player) async {
    final res = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => RangeScreen(
          title: AppLocalizations.of(context).playerN(player + 1),
          short: isShort,
          tripsOverStraight: rules.tripsOverStraight,
          initial: ranges[player] ?? const {},
        ),
      ),
    );
    if (res == null || !mounted) return;
    setState(() {
      if (res.isEmpty) {
        ranges.remove(player);
      } else {
        ranges[player] = res;
        for (var j = 0; j < 2; j++) {
          cards.remove('p${player}_$j');
        }
      }
      _fixSelection();
    });
    _recalc();
  }

  // ---------- расчёт ----------

  EquityRequest _request() => EquityRequest(
    rules: rules,
    hands: [for (var i = 0; i < players; i++) handOf(i)],
    holeCounts: [for (var i = 0; i < players; i++) holeOf(i)],
    ranges: [
      for (var i = 0; i < players; i++)
        ranges[i] == null ? null : rangeToCombos(ranges[i]!),
    ],
    boards: [for (var b = 0; b < boardCount; b++) boardOf(b)],
    dead: [...dead],
  );

  Future<void> _recalc() async {
    final gen = ++_gen;
    var req = _request();
    final anything = req.hands.any((h) => h.isNotEmpty) || ranges.isNotEmpty;
    final need = needsMuck(req);
    if (!need && mixed) mixed = false;
    if (!anything || (need && !mixed)) {
      setState(() {
        acc = null;
        busy = false;
        muckNeeded = need;
        pineOptions = {};
      });
      return;
    }
    if (mixed) req = req.copyWith(dead: const []);
    setState(() {
      busy = true;
      muckNeeded = need;
    });
    final sw = Stopwatch()..start();
    EquityAcc? total;
    while (true) {
      final left = 150000 - (total?.deals ?? 0);
      final part = await computeEquityAsync(
        req.copyWith(timeMs: 350, maxDeals: left),
      );
      if (!mounted || gen != _gen) return;
      if (part == null) {
        total = null;
        break;
      }
      if (total == null) {
        total = part;
      } else {
        total.merge(part);
      }
      setState(() => acc = total);
      if (part.exact ||
          total.deals >= 150000 ||
          sw.elapsedMilliseconds > 3000) {
        break;
      }
    }
    setState(() {
      acc = total;
      busy = false;
    });
    if (isPine) await _pineappleOptions(req, gen);
  }

  /// Ананас: эквити каждого варианта сброса для игроков с 3 картами на флопе.
  Future<void> _pineappleOptions(EquityRequest req, int gen) async {
    final out = <int, List<(int, double)>>{};
    if (boardOf(0).length >= 3) {
      for (var i = 0; i < players; i++) {
        final h = handOf(i);
        if (discarded.contains(i) || h.length != 3) continue;
        final opts = <(int, double)>[];
        for (var d = 0; d < 3; d++) {
          final keep = List<List<int>?>.filled(players, null);
          keep[i] = [
            for (var j = 0; j < 3; j++)
              if (j != d) h[j],
          ];
          final r = await computeEquityAsync(
            req.copyWith(keep: keep, timeMs: 300, maxDeals: 40000),
          );
          if (!mounted || gen != _gen) return;
          opts.add((h[d], r?.equity(i) ?? 0));
        }
        out[i] = opts;
      }
    }
    setState(() => pineOptions = out);
  }

  // ---------- интерфейс ----------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final c = context.colors;
    final settings = ref.watch(settingsProvider);
    final effRule = rule ?? settings.shortDeckRule;
    final big = handSize <= 3;
    final cw = handSize <= 3 ? 50.0 : (handSize == 4 ? 46.0 : 42.0);
    final ch = handSize <= 3 ? 68.0 : (handSize == 4 ? 62.0 : 58.0);

    Widget slot(String key, double w, double h) => PlayingCardView(
      card: cards[key],
      width: w,
      height: h,
      selected: keyboard && selected == key,
      onTap: () => _select(key),
    );

    final selectors = <Widget>[
      if (game.handCards.length > 1)
        SelectButton<int>(
          label: l.cardsLabel,
          sheetTitle: l.cardsOnHand,
          value: handSize,
          options: game.handCards,
          optionLabel: (v) => '$v',
          onChanged: _setHandSize,
        ),
      if (isShort)
        SelectButton<ShortDeckRule>(
          label: l.rulesLabel,
          sheetTitle: l.rulesTitle,
          value: effRule,
          options: ShortDeckRule.values,
          optionLabel: (r) => r == ShortDeckRule.straightOverTrips
              ? l.ruleStraightOverTrips
              : l.ruleTripsOverStraight,
          onChanged: (v) {
            setState(() => rule = v);
            _recalc();
          },
        ),
      SelectButton<int>(
        label: l.playersLabel,
        sheetTitle: l.playersTitle,
        value: players,
        options: [for (var i = 2; i <= game.maxPlayersFor(handSize); i++) i],
        optionLabel: (v) => '$v',
        onChanged: _setPlayers,
      ),
    ];

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

    final a = acc;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(game.title(l)),
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
            onPressed: cards.isEmpty && dead.isEmpty && ranges.isEmpty
                ? null
                : _clearAll,
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
                Row(
                  children: [
                    for (final (i, s) in selectors.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(child: s),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                for (var b = 0; b < boardCount; b++) boardRow(b),
                if (muckNeeded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: mixed ? c.accentText : c.warn,
                        backgroundColor: mixed ? c.accentSoft : c.warnBg,
                        side: BorderSide(
                          color: mixed ? theme.colorScheme.primary : c.warn,
                        ),
                      ),
                      onPressed: () {
                        setState(() => mixed = !mixed);
                        _recalc();
                      },
                      child: Text(mixed ? l.muckMixed : l.mixMuck),
                    ),
                  ),
                if (game == Game.omahaHiLo && a != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l.lowPossible(pct(a.lowChance())),
                      style: t.bodySmall,
                    ),
                  ),
                if (showDead || dead.isNotEmpty) _deadRow(l, t),
                for (var i = 0; i < players; i++)
                  _PlayerTile(
                    name: l.playerN(i + 1),
                    wide: !big,
                    cards: ranges.containsKey(i)
                        ? null
                        : [
                            for (var j = 0; j < holeOf(i); j++)
                              slot('p${i}_$j', cw, ch),
                          ],
                    rangeLabel: ranges.containsKey(i)
                        ? l.rangeShort(
                            pct(
                              rangeToCombos(ranges[i]!).length /
                                  (isShort ? 630 : 1326),
                            ),
                          )
                        : null,
                    onRange: hasRanges && handOf(i).isEmpty
                        ? () => _editRange(i)
                        : null,
                    equity: a?.equity(i),
                    detail: a == null ? null : _detail(l, a, i),
                    stale: busy,
                    options: pineOptions[i],
                    onDiscard: (card) => _discard(i, card),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => setState(() {
                          showDead = true;
                          selected = 'dead';
                          keyboard = true;
                        }),
                        child: Text(l.deadCards),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: a == null ? null : _openAnalysis,
                        child: Text(l.analysis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (keyboard && selected != null)
            CardKeyboard(
              used: used,
              ranks: isShort ? 9 : 13,
              onPick: _place,
              onClear: _clearSelected,
              onDone: () => setState(() => keyboard = false),
            ),
        ],
      ),
    );
  }

  String _detail(AppLocalizations l, EquityAcc a, int i) {
    final parts = <String>[];
    if (game == Game.omahaHiLo) {
      parts.add(l.hiLoLine(pct(a.hiOf(i)), pct(a.loOf(i)), pct(a.scoopOf(i))));
    } else if (!doubleBoard) {
      parts.add(l.winTie(pct(a.winOf(i)), pct(a.tieOf(i))));
    }
    if (doubleBoard) {
      parts.add(
        l.boardsLine(pct(a.board(0, i)), pct(a.board(1, i)), pct(a.scoopOf(i))),
      );
    }
    return parts.join('\n');
  }

  Widget _deadRow(AppLocalizations l, TextTheme t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l.deadShort, style: t.bodySmall),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final d in dead)
                PlayingCardView(
                  card: d,
                  width: 36,
                  height: 50,
                  selected: keyboard && selected == 'dead:$d',
                  onTap: () => _select('dead:$d'),
                ),
              PlayingCardView(
                card: null,
                width: 36,
                height: 50,
                selected: keyboard && selected == 'dead',
                onTap: () => _select('dead'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _openAnalysis() {
    final a = acc;
    if (a == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          rules: rules,
          hands: [for (var i = 0; i < players; i++) handOf(i)],
          board: boardOf(0),
          dead: [...dead],
          acc: a,
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.name,
    required this.wide,
    required this.cards,
    required this.rangeLabel,
    required this.onRange,
    required this.equity,
    required this.detail,
    required this.stale,
    required this.options,
    required this.onDiscard,
  });

  final String name;
  final bool wide; // 4–6 карт: карты отдельной строкой
  final List<Widget>? cards;
  final String? rangeLabel;
  final VoidCallback? onRange;
  final double? equity;
  final String? detail;
  final bool stale;
  final List<(int, double)>? options;
  final ValueChanged<int> onDiscard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;

    final cardRow = rangeLabel != null
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: ActionChip(
              label: Text(rangeLabel!, overflow: TextOverflow.ellipsis),
              onPressed: onRange,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, w) in cards!.indexed) ...[
                if (i > 0) SizedBox(width: wide ? 5 : 6),
                w,
              ],
            ],
          );

    final result = AnimatedOpacity(
      opacity: stale ? 0.6 : 1,
      duration: const Duration(milliseconds: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            equity == null ? '—' : pct(equity!),
            textAlign: TextAlign.right,
            style: t.headlineSmall,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: equity ?? 0,
              minHeight: 6,
              backgroundColor: c.surface2,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(detail!, textAlign: TextAlign.right, style: t.bodySmall),
          ],
        ],
      ),
    );

    final header = SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(child: Text(name, style: t.bodySmall)),
          if (onRange != null && rangeLabel == null)
            TextButton(onPressed: onRange, child: Text(l.range)),
        ],
      ),
    );

    final opts = options;
    final bestEq = opts == null || opts.isEmpty
        ? null
        : opts.map((o) => o.$2).reduce((x, y) => x > y ? x : y);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 4),
              if (wide) ...[
                cardRow,
                const SizedBox(height: 10),
                result,
              ] else
                Row(
                  children: [
                    cardRow,
                    const SizedBox(width: 12),
                    Expanded(child: result),
                  ],
                ),
              if (opts != null && opts.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final (card, eq) in opts)
                  _DiscardOption(
                    card: card,
                    equity: eq,
                    best: eq == bestEq,
                    onTap: () => onDiscard(card),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscardOption extends StatelessWidget {
  const _DiscardOption({
    required this.card,
    required this.equity,
    required this.best,
    required this.onTap,
  });
  final int card;
  final double equity;
  final bool best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: best ? c.accentSoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: best ? accent : c.line, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('${l.discard} '),
                  PlayingCardView(card: card, width: 26, height: 36),
                  const Spacer(),
                  if (best)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        l.bestOption,
                        style: TextStyle(fontSize: 13, color: c.accentText),
                      ),
                    ),
                  Text(
                    pct(equity),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
