import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../strength/strength_tables.dart';
import '../logic/ranges.dart';

/// Выбор диапазона соперника: сетка классов рук + «топ X%».
/// Возвращает набор классов (пустой — диапазон снят) или null — без изменений.
class RangeScreen extends StatefulWidget {
  const RangeScreen({
    super.key,
    required this.title,
    required this.initial,
    this.short = false,
    this.tripsOverStraight = false,
  });

  final String title;
  final Set<String> initial;
  final bool short;
  final bool tripsOverStraight;

  @override
  State<RangeScreen> createState() => _RangeScreenState();
}

class _RangeScreenState extends State<RangeScreen> {
  late final Set<String> sel = {...widget.initial};
  late final List<String> ranking = [
    for (final e
        in widget.short
            ? (widget.tripsOverStraight
                  ? shortClassesTrips
                  : shortClassesStraight)
            : holdemClasses)
      e.$1,
  ];
  int get size => widget.short ? 9 : 13;
  int get total => widget.short ? 630 : 1326;
  double pctValue = 0;

  int get combos => sel.fold(0, (s, c) => s + classCombos(c));

  void _setPct(double v) => setState(() {
    pctValue = v;
    sel
      ..clear()
      ..addAll(topPercent(ranking, v, total: total));
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = context.colors;
    final t = theme.textTheme;
    final shown = combos / total * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.range} · ${widget.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, sel),
            child: Text(
              l.done,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l.topN('${shown.toStringAsFixed(1)}%'),
                  style: t.headlineSmall,
                ),
              ),
              Text(l.combosCount(combos), style: t.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: size,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            children: [
              for (var row = 0; row < size; row++)
                for (var col = 0; col < size; col++)
                  _cell(handClass(row, col), theme, c),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: pctValue,
            max: 100,
            divisions: 100,
            label: '${pctValue.round()}%',
            onChanged: _setPct,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in [5.0, 10.0, 20.0, 35.0, 50.0])
                ActionChip(
                  label: Text('${p.round()}%'),
                  onPressed: () => _setPct(p),
                ),
              ActionChip(
                label: Text(l.clearRange),
                onPressed: () => setState(() {
                  pctValue = 0;
                  sel.clear();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(String cls, ThemeData theme, AppColors c) {
    final on = sel.contains(cls);
    return Semantics(
      button: true,
      selected: on,
      label: cls,
      child: GestureDetector(
        onTap: () => setState(() => on ? sel.remove(cls) : sel.add(cls)),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? theme.colorScheme.primary : c.surface2,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Text(
                cls,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontSize: widget.short ? 12 : 9,
                  fontWeight: FontWeight.w600,
                  color: on ? theme.colorScheme.onPrimary : c.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
