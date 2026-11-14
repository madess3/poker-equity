import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../app/theme.dart';
import '../../core/table_store.dart';
import '../../core/widgets/select_button.dart';
import '../../l10n/app_localizations.dart';
import 'icm.dart';

/// ICM · делёжка призового фонда (до 10 игроков). Пересчёт мгновенный.
class IcmScreen extends ConsumerStatefulWidget {
  const IcmScreen({super.key});

  @override
  ConsumerState<IcmScreen> createState() => _IcmScreenState();
}

class _IcmScreenState extends ConsumerState<IcmScreen> {
  static const _key = 'icm';
  int players = 3;
  final stacks = List.generate(10, (_) => TextEditingController());
  final prizes = List.generate(10, (_) => TextEditingController());
  final leave = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    final j = ref.read(tableStoreProvider).loadJson(_key);
    if (j != null) {
      players = (j['players'] as int? ?? 3).clamp(2, 10);
      final s = (j['stacks'] as List?)?.cast<String>() ?? const [];
      final p = (j['prizes'] as List?)?.cast<String>() ?? const [];
      for (var i = 0; i < 10; i++) {
        if (i < s.length) stacks[i].text = s[i];
        if (i < p.length) prizes[i].text = p[i];
      }
      leave.text = j['leave'] as String? ?? '0';
    }
  }

  @override
  void dispose() {
    for (final c in [...stacks, ...prizes, leave]) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed() {
    ref.read(tableStoreProvider).saveJson(_key, {
      'players': players,
      'stacks': [for (final c in stacks) c.text],
      'prizes': [for (final c in prizes) c.text],
      'leave': leave.text,
    });
    setState(() {});
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;

  String _f(double v) => v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;

    final st = [for (var i = 0; i < players; i++) _num(stacks[i])];
    final pr = [for (var i = 0; i < players; i++) _num(prizes[i])];
    final totalChips = st.fold(0.0, (s, v) => s + v);
    final fundAll = pr.fold(0.0, (s, v) => s + v);
    final bad = badPrizeOrder(pr);
    final ready = st.every((v) => v > 0) && fundAll > 0;
    final res = ready ? computeIcm(st, pr, _num(leave)) : null;

    Widget field(
      TextEditingController ctl,
      String label, {
      bool error = false,
      String? helper,
    }) => TextField(
      controller: ctl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _changed(),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        helperText: helper,
        border: const OutlineInputBorder(),
        enabledBorder: error
            ? OutlineInputBorder(
                borderSide: BorderSide(color: c.warn, width: 1.5),
              )
            : null,
      ),
    );

    Widget box(List<Widget> children) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );

    Widget cell(
      String s, {
      bool bold = false,
      Color? color,
      TextAlign align = TextAlign.right,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        s,
        textAlign: align,
        style: TextStyle(
          fontSize: 15,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(l.icmTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          SelectButton<int>(
            label: l.playersLabel,
            sheetTitle: l.playersTitle,
            value: players,
            options: [for (var i = 2; i <= 10; i++) i],
            optionLabel: (v) => '$v',
            onChanged: (v) {
              players = v;
              _changed();
            },
          ),
          const SizedBox(height: 12),
          box([
            Text(l.icmStacks, style: t.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < players; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: field(stacks[i], l.playerN(i + 1))),
                    SizedBox(
                      width: 64,
                      child: Text(
                        totalChips > 0
                            ? '${(st[i] / totalChips * 100).toStringAsFixed(1)}%'
                            : '',
                        textAlign: TextAlign.right,
                        style: t.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              l.icmChipsTotal(totalChips.toStringAsFixed(0)),
              style: t.bodySmall,
            ),
          ]),
          const SizedBox(height: 8),
          box([
            Text(l.icmPrizes, style: t.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < players; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: field(
                  prizes[i],
                  l.icmPlace(i + 1),
                  error: bad.contains(i),
                ),
              ),
            Text(l.icmFund(fundAll.toStringAsFixed(0)), style: t.bodySmall),
            if (bad.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l.icmPrizeOrder,
                style: TextStyle(fontSize: 13, color: c.warn),
              ),
            ],
            const SizedBox(height: 12),
            field(leave, l.icmLeave),
          ]),
          const SizedBox(height: 8),
          if (res == null)
            box([Text(l.icmFillAll, style: t.bodyMedium)])
          else
            box([
              Table(
                columnWidths: const {0: FlexColumnWidth(1.3)},
                children: [
                  TableRow(
                    children: [
                      cell(l.icmPlayer, align: TextAlign.left, color: c.muted),
                      cell('ICM', color: accent, bold: true),
                      cell(l.icmByChips, color: c.muted),
                      cell(l.icmEqual, color: c.muted),
                    ],
                  ),
                  for (var i = 0; i < players; i++)
                    TableRow(
                      children: [
                        cell(l.playerN(i + 1), align: TextAlign.left),
                        cell(_f(res.icm[i]), bold: true, color: accent),
                        cell(
                          res.chipsOverFirst(i)
                              ? '${_f(res.chips[i])}*'
                              : _f(res.chips[i]),
                          color: res.chipsOverFirst(i) ? c.warn : null,
                        ),
                        cell(_f(res.equal[i])),
                      ],
                    ),
                ],
              ),
              if ([for (var i = 0; i < players; i++) i].any(res.chipsOverFirst))
                Text(
                  '* ${l.icmOverFirst}',
                  style: TextStyle(fontSize: 13, color: c.warn),
                ),
              if (res.reserved > 0) ...[
                const SizedBox(height: 8),
                Text(l.icmReserved(_f(res.reserved)), style: t.bodySmall),
              ],
              const SizedBox(height: 8),
              Text(l.icmNote, style: t.bodySmall),
            ]),
        ],
      ),
    );
  }
}
