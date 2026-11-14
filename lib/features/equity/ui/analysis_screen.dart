import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../core/table_store.dart';
import '../../../core/widgets/playing_card.dart';
import '../../../core/widgets/select_button.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/deals.dart';
import '../logic/equity.dart';
import '../logic/outs.dart';
import '../logic/rules.dart';
import '../logic/runouts.dart';
import 'equity_screen.dart' show pct;

enum _Tab { outs, ev, combos, insurance, runouts }

/// Анализ раздачи: ауты, EV, комбинации, страховка (EV chop / ауты), прокрутки.
class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.request,
    required this.acc,
    required this.doubleBoard,
    this.initialTab = 0,
  });

  /// Индекс вкладки «Страховка» (для ярлыка из меню).
  static const insuranceTab = 3;

  final EquityRequest request;
  final EquityAcc? acc;
  final bool doubleBoard;
  final int initialTab;

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  static const _inputsKey = 'analysisInputs';
  static const _modelKey = 'insuranceModel';

  EquityAcc? acc;
  int player = 0;
  int? insured;
  bool toRiver = false; // страховка на флопе: до ривера или только тёрн
  int model = 0; // 0 — EV chop, 1 — страховка от аутов

  final pot = TextEditingController(text: '100');
  final bet = TextEditingController(text: '50');
  final fee = TextEditingController(text: '1');
  final stake = TextEditingController(text: '20');
  final odds = TextEditingController(text: '1.6');
  final runPot = TextEditingController();

  final Map<int, RunoutStats?> runs = {};
  bool runsBusy = false;
  int _gen = 0;

  EquityRequest get req => widget.request;
  Rules get rules => req.rules;
  List<List<int>> get hands => req.hands;
  List<int> get board => req.boards.first;

  List<_Tab> get tabs => [
    _Tab.outs,
    _Tab.ev,
    _Tab.combos,
    if (!widget.doubleBoard) ...[_Tab.insurance, _Tab.runouts],
  ];

  /// Игроки с полностью известными руками (без диапазонов).
  List<int> get known => [
    for (var i = 0; i < hands.length; i++)
      if (hands[i].length == req.holeOf(i) &&
          !(rules.variant == Variant.pineapple && hands[i].length != 2))
        i,
  ];

  @override
  void initState() {
    super.initState();
    acc = widget.acc;
    final store = ref.read(tableStoreProvider);
    model = int.tryParse(store.getString(_modelKey) ?? '') ?? 0;
    final j = store.loadJson(_inputsKey);
    if (j != null) {
      for (final (k, ctl) in [
        ('pot', pot),
        ('bet', bet),
        ('fee', fee),
        ('stake', stake),
        ('odds', odds),
        ('runPot', runPot),
      ]) {
        final v = j[k];
        if (v is String) ctl.text = v;
      }
    }
    if (acc == null && known.length >= 2) _computeEquity();
    if (!widget.doubleBoard) _computeRuns();
  }

  @override
  void dispose() {
    for (final c in [pot, bet, fee, stake, odds, runPot]) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveInputs() {
    ref.read(tableStoreProvider).saveJson(_inputsKey, {
      'pot': pot.text,
      'bet': bet.text,
      'fee': fee.text,
      'stake': stake.text,
      'odds': odds.text,
      'runPot': runPot.text,
    });
    setState(() {});
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _computeEquity() async {
    final r = await computeEquityAsync(
      req.copyWith(timeMs: 1500, maxDeals: 150000),
    );
    if (mounted) setState(() => acc = r);
  }

  /// Прокрутки 1/2/3: каждая колонка уточняется пакетами до ~1.5 с.
  Future<void> _computeRuns() async {
    final gen = ++_gen;
    if (board.length == 5 || known.length != hands.length || hands.length < 2) {
      return;
    }
    setState(() => runsBusy = true);
    for (var k = 1; k <= 3; k++) {
      final rq = RunoutRequest(
        rules: rules,
        hands: hands,
        board: board,
        dead: req.dead,
        runs: k,
        timeMs: 500,
      );
      if (!runoutsFit(rq)) {
        setState(() => runs[k] = null);
        continue;
      }
      RunoutStats? total;
      final sw = Stopwatch()..start();
      while (true) {
        final part = await computeRunoutsAsync(rq);
        if (!mounted || gen != _gen) return;
        if (part == null) break;
        if (total == null) {
          total = part;
        } else {
          total.merge(part);
        }
        setState(() => runs[k] = total);
        if (part.exact || sw.elapsedMilliseconds > 1500) break;
      }
    }
    if (mounted) setState(() => runsBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tl = tabs;
    final initial = widget.initialTab.clamp(0, tl.length - 1);
    String title(_Tab t) => switch (t) {
      _Tab.outs => l.outsTab,
      _Tab.ev => 'EV',
      _Tab.combos => l.combosTab,
      _Tab.insurance => l.insuranceTab,
      _Tab.runouts => l.runoutsTab,
    };
    return DefaultTabController(
      length: tl.length,
      initialIndex: initial,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.analysis),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: [for (final t in tl) Tab(text: title(t))],
          ),
        ),
        body: TabBarView(
          children: [
            for (final t in tl)
              switch (t) {
                _Tab.outs => _withPlayer(l, _outs(l)),
                _Tab.ev => _withPlayer(l, _ev(l)),
                _Tab.combos => _withPlayer(l, _combos(l)),
                _Tab.insurance => _insurance(l),
                _Tab.runouts => _runouts(l),
              },
          ],
        ),
      ),
    );
  }

  // ---------- общие элементы ----------

  Widget _playerSelect(
    AppLocalizations l,
    int value,
    List<int> options,
    ValueChanged<int> on, {
    String? label,
  }) => SelectButton<int>(
    label: label ?? l.playerLabel,
    sheetTitle: l.playersTitle,
    value: options.contains(value) ? value : options.first,
    options: options,
    optionLabel: (i) => l.playerN(i + 1),
    onChanged: on,
  );

  Widget _allPlayers(AppLocalizations l) => _playerSelect(l, player, [
    for (var i = 0; i < hands.length; i++) i,
  ], (v) => setState(() => player = v));

  Widget _withPlayer(AppLocalizations l, List<Widget> body) => ListView(
    padding: const EdgeInsets.all(16),
    children: [_allPlayers(l), const SizedBox(height: 12), ...body],
  );

  Widget _box(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  Widget _field(String label, TextEditingController ctl) => Expanded(
    child: TextField(
      controller: ctl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => _saveInputs(),
    ),
  );

  Widget _stat(String k, String v, {Color? color}) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surface2,
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
  }

  Widget _tiles(List<Widget> a, List<Widget> b) => Column(
    children: [
      Row(children: [a[0], const SizedBox(width: 8), a[1]]),
      const SizedBox(height: 8),
      Row(children: [b[0], const SizedBox(width: 8), b[1]]),
    ],
  );

  Widget _plate(
    String title,
    String? sub, {
    required Color bg,
    required Color fg,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600, color: fg),
        ),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: fg),
          ),
        ],
      ],
    ),
  );

  Widget _message(String text, {bool backButton = false}) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _box([
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
          if (backButton) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.toHand),
            ),
          ],
        ]),
      ],
    );
  }

  List<Widget> _loading() => [
    _box([const LinearProgressIndicator()]),
  ];

  String _money(double v) => v.toStringAsFixed(1);

  int _unseen() {
    final seen = {...board, ...req.dead, for (final h in hands) ...h};
    return rules.deckSize - seen.length;
  }

  // ---------- Ауты ----------

  List<Widget> _outs(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final outs = known.length == hands.length
        ? computeOuts(rules, hands, board, req.dead, player)
        : null;
    final children = <Widget>[];
    if (outs == null) {
      children.add(Text(l.outsUnavailable, style: t.bodyMedium));
    } else if (outs.isEmpty) {
      children.add(Text(l.outsAhead, style: t.bodyMedium));
    } else {
      final (next, river) = outsChance(
        outs.length,
        _unseen(),
        5 - board.length,
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
          board.length == 3
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
    return [_box(children)];
  }

  // ---------- EV ----------

  List<Widget> _ev(AppLocalizations l) {
    final c = context.colors;
    final a = acc;
    if (a == null) {
      return _loading();
    }
    final p = _num(pot), b = _num(bet);
    final eq = a.equity(player);
    final total = p + 2 * b;
    final need = total > 0 ? b / total : 0.0;
    final ev = eq * total - b;
    final good = ev >= 0;
    return [
      _box([
        Row(
          children: [
            _field(l.pot, pot),
            const SizedBox(width: 12),
            _field(l.betToCall, bet),
          ],
        ),
        const SizedBox(height: 16),
        _tiles(
          [_stat(l.needEquity, pct(need)), _stat(l.yourEquity, pct(eq))],
          [
            _stat(
              l.potOdds,
              b > 0 ? '${((p + b) / b).toStringAsFixed(1)} : 1' : '—',
            ),
            _stat(
              l.evCall,
              '${ev >= 0 ? '+' : ''}${_money(ev)}',
              color: good ? Theme.of(context).colorScheme.primary : c.warn,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _plate(
          good ? l.callGood : l.callBad,
          null,
          bg: good ? c.accentSoft : c.warnBg,
          fg: good ? c.accentText : c.warn,
        ),
      ]),
    ];
  }

  // ---------- Комбинации ----------

  List<Widget> _combos(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final a = acc;
    if (a == null) {
      return _loading();
    }
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
    return [
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
                      value: a.catChance(player, k),
                      minHeight: 8,
                      backgroundColor: c.surface2,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    pct(a.catChance(player, k)),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
      ]),
    ];
  }

  // ---------- Страховка ----------

  Widget _insurance(AppLocalizations l) {
    if (known.length < 2) {
      return _message(l.needTwoHands, backButton: true);
    }
    final modelSelect = SelectButton<int>(
      label: l.modelLabel,
      sheetTitle: l.modelTitle,
      value: model,
      options: const [0, 1],
      optionLabel: (v) => v == 0 ? l.modelChop : l.modelOuts,
      onChanged: (v) {
        ref.read(tableStoreProvider).setString(_modelKey, '$v');
        setState(() => model = v);
      },
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        modelSelect,
        const SizedBox(height: 12),
        ...(model == 0 ? _chop(l) : _outsInsurance(l)),
      ],
    );
  }

  List<Widget> _chop(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    if (board.length == 5) {
      return [
        _box([Text(l.allCardsOpen, style: t.bodyMedium)]),
      ];
    }
    final a = acc;
    if (a == null) {
      return _loading();
    }
    final r = ChopResult(a.equity(player), _num(pot), _num(fee));
    return [
      _allPlayers(l),
      const SizedBox(height: 12),
      _box([
        Row(
          children: [
            _field(l.pot, pot),
            const SizedBox(width: 12),
            _field(l.feePct, fee),
          ],
        ),
        const SizedBox(height: 16),
        _tiles(
          [
            _stat(l.yourEquity, pct(r.equity)),
            _stat(l.chopSum, _money(r.chop)),
          ],
          [_stat(l.fee, _money(r.fee)), _stat(l.shareNoDeal, _money(r.share))],
        ),
        const SizedBox(height: 12),
        _plate(
          l.chopCosts(_money(r.fee)),
          l.chopOfShare(pct(r.feeOfShare)),
          bg: c.surface2,
          fg: Theme.of(context).colorScheme.onSurface,
        ),
      ]),
      const SizedBox(height: 8),
      Text(l.feeFromPot, style: t.bodySmall),
    ];
  }

  List<Widget> _outsInsurance(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    if (hands.length != 2 || known.length != 2) {
      return [
        _box([Text(l.insTwoPlayers, style: t.bodyMedium)]),
      ];
    }
    if (board.length < 3 || board.length > 4) {
      return [
        _box([Text(l.insStreet, style: t.bodyMedium)]),
      ];
    }
    // По умолчанию страхуется лидер по текущему борду.
    final s0 = partialScore(rules, hands[0], board);
    final s1 = partialScore(rules, hands[1], board);
    final me = insured ?? (s1 > s0 ? 1 : 0);
    final opp = 1 - me;
    final outs =
        computeOuts(rules, hands, board, req.dead, opp) ?? const <int>[];
    final unseen = _unseen();
    final flop = board.length == 3;
    final p = !flop || !toRiver
        ? outs.length / unseen
        : outsChance(outs.length, unseen, 2).$2;
    final r = InsuranceResult(
      outs: outs.length,
      unseen: unseen,
      p: p,
      stake: _num(stake),
      odds: _num(odds),
    );
    final good = r.ev >= 0;
    final fair = r.fair.isFinite ? r.fair.toStringAsFixed(2) : '—';

    final inputs = <Widget>[
      _playerSelect(
        l,
        me,
        const [0, 1],
        (v) => setState(() => insured = v),
        label: l.insuredLabel,
      ),
      const SizedBox(height: 8),
      if (flop) ...[
        SelectButton<bool>(
          label: l.streetLabel,
          sheetTitle: l.streetTitle,
          value: toRiver,
          options: const [false, true],
          optionLabel: (v) => v ? l.streetToRiver : l.streetTurn,
          onChanged: (v) => setState(() => toRiver = v),
        ),
        const SizedBox(height: 12),
      ],
    ];

    if (outs.isEmpty) {
      return [
        ...inputs,
        _box([Text(l.insNoOuts, style: t.bodyMedium)]),
      ];
    }
    return [
      ...inputs,
      _box([
        Row(
          children: [
            _field(l.pot, pot),
            const SizedBox(width: 12),
            _field(l.insStake, stake),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [_field(l.insOdds, odds), const Spacer()]),
        const SizedBox(height: 16),
        _tiles(
          [_stat(l.insOppOuts, '${outs.length}'), _stat(l.insChance, pct(p))],
          [
            _stat(l.insFair, fair),
            _stat(
              l.insEv,
              '${r.ev >= 0 ? '+' : ''}${_money(r.ev)}',
              color: good ? Theme.of(context).colorScheme.primary : c.warn,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _plate(
          good ? l.insGood : l.insBad,
          l.insSub(
            _num(odds).toStringAsFixed(2),
            fair,
            r.overpayPct.toStringAsFixed(1),
          ),
          bg: good ? c.accentSoft : c.warnBg,
          fg: good ? c.accentText : c.warn,
        ),
      ]),
      const SizedBox(height: 8),
      Text(l.insFooter(_money(r.payout), _money(r.stake)), style: t.bodySmall),
    ];
  }

  // ---------- Прокрутки ----------

  Widget _runouts(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    if (board.length == 5) {
      return _message(l.allCardsOpen);
    }
    if (hands.length < 2 || known.length != hands.length) {
      return _message(l.runNeedHands);
    }
    final bank = _num(runPot);
    String v(double share) => bank > 0 ? _money(share * bank) : pct(share);

    Widget cellText(String s) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        s,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );

    TableRow row(String name, String Function(RunoutStats s) f) => TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(name, style: const TextStyle(fontSize: 13)),
        ),
        for (var k = 1; k <= 3; k++)
          cellText(runs[k] == null ? '—' : f(runs[k]!)),
      ],
    );

    final noCards = [
      1,
      2,
      3,
    ].any((k) => runs.containsKey(k) && runs[k] == null);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _allPlayers(l)),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: TextField(
                controller: runPot,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l.pot,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => _saveInputs(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _box([
          if (runsBusy) const LinearProgressIndicator(minHeight: 2),
          Table(
            columnWidths: const {0: FlexColumnWidth(1.6)},
            children: [
              TableRow(
                children: [
                  const SizedBox(),
                  for (final h in [l.runOnce, l.runTwice, l.runThrice])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        h,
                        textAlign: TextAlign.right,
                        style: t.bodySmall,
                      ),
                    ),
                ],
              ),
              row(l.runAll, (s) => pct(s.allOf(player))),
              row(l.runPart, (s) => pct(s.partOf(player))),
              row(l.runNone, (s) => pct(s.noneOf(player))),
              row(l.runMean, (s) => v(s.mean(player))),
              row(l.runSd, (s) => v(s.sd(player))),
            ],
          ),
          if (noCards)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l.runNoCards,
                style: TextStyle(fontSize: 13, color: c.warn),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        Text(l.runNote, style: t.bodySmall),
      ],
    );
  }
}
