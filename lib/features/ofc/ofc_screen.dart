import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../app/theme.dart';
import '../../core/table_store.dart';
import '../../core/widgets/select_button.dart';
import '../../l10n/app_localizations.dart';
import '../equity/logic/cards.dart';
import 'ofc.dart';
import 'ofc_help_screen.dart';

/// OFC: подсчёт очков между 2–4 игроками по введённым комбинациям.
class OfcScreen extends ConsumerStatefulWidget {
  const OfcScreen({super.key});

  @override
  ConsumerState<OfcScreen> createState() => _OfcScreenState();
}

class _OfcScreenState extends ConsumerState<OfcScreen> {
  static const _key = 'ofc';
  List<OfcPlayer> players = [OfcPlayer(), OfcPlayer()];

  @override
  void initState() {
    super.initState();
    final j = ref.read(tableStoreProvider).loadJson(_key);
    try {
      final list = (j?['players'] as List?)
          ?.map((e) => OfcPlayer.fromJson((e as Map).cast<String, Object?>()))
          .toList();
      if (list != null && list.length >= 2 && list.length <= 4) players = list;
    } catch (_) {}
  }

  void _save() {
    ref.read(tableStoreProvider).saveJson(_key, {
      'players': [for (final p in players) p.toJson()],
    });
    setState(() {});
  }

  void _setCount(int n) {
    while (players.length < n) {
      players.add(OfcPlayer());
    }
    while (players.length > n) {
      players.removeLast();
    }
    _save();
  }

  String comboName(AppLocalizations l, int c) => [
    l.catHigh,
    l.catPair,
    l.catTwoPair,
    l.catTrips,
    l.catStraight,
    l.catFlush,
    l.catFullHouse,
    l.catQuads,
    l.catStraightFlush,
    l.catRoyal,
  ][c];

  String rankName(int r) => rankChars[r] == 'T' ? '10' : rankChars[r];

  String handText(AppLocalizations l, OfcHand h) => h.rank == null
      ? comboName(l, h.combo)
      : '${comboName(l, h.combo)} · ${rankName(h.rank!)}';

  /// Есть ли у других игроков такая же комбинация в этом боксе.
  bool _hasTwin(int player, int box, OfcHand h) => [
    for (var i = 0; i < players.length; i++)
      if (i != player) players[i].boxes[box],
  ].any((o) => o != null && o.sameAs(h));

  Future<void> _edit(int player, OfcBox box) async {
    final l = AppLocalizations.of(context);
    final cur = players[player].boxes[box.index];
    final res = await showModalBottomSheet<OfcHand>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ComboSheet(
        title: '${l.playerN(player + 1)} · ${_boxName(l, box)}',
        box: box,
        initial: cur,
        playersCount: players.length,
        comboName: (c) => comboName(l, c),
        rankName: rankName,
        hasTwin: (h) => _hasTwin(player, box.index, h),
      ),
    );
    if (res == null) return;
    players[player].boxes[box.index] = res;
    _save();
  }

  String _boxName(AppLocalizations l, OfcBox b) =>
      [l.boxTop, l.boxMiddle, l.boxBottom][b.index];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final totals = ofcTotals(players);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l.ofc),
        actions: [
          IconButton(
            tooltip: l.ofcHelp,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const OfcHelpScreen())),
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            tooltip: l.clearAll,
            onPressed: () {
              players = [for (var i = 0; i < players.length; i++) OfcPlayer()];
              _save();
            },
            icon: Icon(Icons.delete_outline, color: c.danger),
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
                  value: players.length,
                  options: const [2, 3, 4],
                  optionLabel: (v) => '$v',
                  onChanged: _setCount,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < players.length; i++)
                  _playerCard(l, t, c, i),
              ],
            ),
          ),
          _totalsBar(l, t, c, totals),
        ],
      ),
    );
  }

  Widget _playerCard(AppLocalizations l, TextTheme t, AppColors c, int i) {
    final p = players[i];
    final auto = ofcAutoFoul(p);
    final foul = ofcFoul(p);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: foul ? c.danger : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(l.playerN(i + 1), style: t.titleMedium),
                  const SizedBox(width: 8),
                  if (foul)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.warnBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l.ofcFoulBadge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.danger,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(l.ofcRoyalty(ofcRoyalties(p)), style: t.bodySmall),
                  if (!auto)
                    TextButton(
                      onPressed: () {
                        p.manualFoul = !p.manualFoul;
                        _save();
                      },
                      child: Text(p.manualFoul ? l.ofcUnfoul : l.ofcMarkFoul),
                    ),
                  if (auto) const SizedBox(height: 48),
                ],
              ),
              for (final box in OfcBox.values) _boxRow(l, t, c, i, box),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boxRow(
    AppLocalizations l,
    TextTheme t,
    AppColors c,
    int i,
    OfcBox box,
  ) {
    final h = players[i].boxes[box.index];
    final accent = Theme.of(context).colorScheme.primary;
    final roy = h == null ? 0 : ofcRoyalty(box, h);
    final twin = h != null && _hasTwin(i, box.index, h);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: c.surface2,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _edit(i, box),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 84,
                    child: Text(_boxName(l, box), style: t.bodySmall),
                  ),
                  Expanded(
                    child: Text(
                      h == null ? l.ofcChoose : handText(l, h),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: h == null
                            ? FontWeight.w400
                            : FontWeight.w500,
                        color: h == null ? c.muted : null,
                      ),
                    ),
                  ),
                  if (twin)
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${h.place}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      roy > 0 ? '+$roy' : '',
                      textAlign: TextAlign.right,
                      style: t.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalsBar(
    AppLocalizations l,
    TextTheme t,
    AppColors c,
    List<int>? totals,
  ) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: totals == null
              ? Text(
                  l.ofcFillAll,
                  textAlign: TextAlign.center,
                  style: t.bodySmall,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < players.length; i++)
                          Expanded(
                            child: Column(
                              children: [
                                Text(l.playerN(i + 1), style: t.bodySmall),
                                Text(
                                  totals[i] > 0
                                      ? '+${totals[i]}'
                                      : (totals[i] < 0
                                            ? '−${-totals[i]}'
                                            : '0'),
                                  style: t.headlineSmall?.copyWith(
                                    color: totals[i] > 0
                                        ? accent
                                        : (totals[i] < 0 ? c.danger : null),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (players.length > 2) ...[
                      const SizedBox(height: 6),
                      for (var i = 0; i < players.length; i++)
                        for (var j = i + 1; j < players.length; j++)
                          Text(
                            l.ofcPair(
                              i + 1,
                              j + 1,
                              _signed(ofcVersus(players[i], players[j])),
                            ),
                            style: t.bodySmall,
                          ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  String _signed(int v) => v > 0 ? '+$v' : (v < 0 ? '−${-v}' : '0');
}

/// Всплывающее окно выбора комбинации бокса.
class _ComboSheet extends StatefulWidget {
  const _ComboSheet({
    required this.title,
    required this.box,
    required this.initial,
    required this.playersCount,
    required this.comboName,
    required this.rankName,
    required this.hasTwin,
  });

  final String title;
  final OfcBox box;
  final OfcHand? initial;
  final int playersCount;
  final String Function(int) comboName;
  final String Function(int) rankName;
  final bool Function(OfcHand) hasTwin;

  @override
  State<_ComboSheet> createState() => _ComboSheetState();
}

class _ComboSheetState extends State<_ComboSheet> {
  late int combo = widget.initial?.combo ?? ofcHigh;
  late int? rank = widget.initial?.rank;
  late int place = widget.initial?.place ?? 1;

  OfcHand get hand => OfcHand(
    combo,
    rank: ofcNeedsRank(widget.box, combo) ? (rank ?? 12) : null,
    place: place,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final needRank = ofcNeedsRank(widget.box, combo);
    final twin = widget.hasTwin(hand);

    Widget choice(String label, bool on, VoidCallback onTap, {double h = 48}) =>
        Material(
          color: on ? c.accentSoft : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: on ? accent : c.line, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              height: h,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    color: on ? c.accentText : null,
                  ),
                ),
              ),
            ),
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: t.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.6,
              children: [
                for (final k in ofcCombosFor(widget.box))
                  choice(
                    widget.comboName(k),
                    combo == k,
                    () => setState(() => combo = k),
                  ),
              ],
            ),
            if (needRank) ...[
              const SizedBox(height: 14),
              Text(l.ofcRankHint, style: t.bodySmall),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.1,
                children: [
                  for (var r = 12; r >= 0; r--)
                    choice(
                      widget.rankName(r),
                      (rank ?? 12) == r,
                      () => setState(() => rank = r),
                      h: 44,
                    ),
                ],
              ),
            ],
            if (twin) ...[
              const SizedBox(height: 14),
              Text(l.ofcPlaceHint, style: t.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var n = 1; n <= widget.playersCount; n++) ...[
                    if (n > 1) const SizedBox(width: 8),
                    SizedBox(
                      width: 56,
                      child: choice(
                        '$n',
                        place == n,
                        () => setState(() => place = n),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(l.ofcPlaceNote, style: t.bodySmall),
            ],
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.pop(context, hand),
              child: Text(l.done),
            ),
          ],
        ),
      ),
    );
  }
}
