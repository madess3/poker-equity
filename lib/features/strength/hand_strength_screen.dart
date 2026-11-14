import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../core/table_store.dart';
import '../../core/widgets/playing_card.dart';
import '../../core/widgets/select_button.dart';
import '../../l10n/app_localizations.dart';
import '../equity/logic/equity.dart';
import '../equity/logic/ranges.dart';
import '../equity/logic/rules.dart';
import '../equity/ui/card_keyboard.dart';
import '../games/game.dart';
import 'strength_tables.dart';

enum StrengthGame { holdem, omaha, shortDeck, pineapple }

/// Сила стартовой руки: топ X% по эквити против одной случайной руки.
class HandStrengthScreen extends ConsumerStatefulWidget {
  const HandStrengthScreen({super.key});

  @override
  ConsumerState<HandStrengthScreen> createState() => _HandStrengthScreenState();
}

class _HandStrengthScreenState extends ConsumerState<HandStrengthScreen> {
  StrengthGame game = StrengthGame.holdem;
  int omahaCards = 4;
  bool hiLo = false;
  final Map<int, int> cards = {};
  int? selected = 0;
  bool keyboard = true;

  String? top; // «12.0%»
  String? sub; // «#20 из 169» или «±1%»
  double? fill;
  bool busy = false;
  int _gen = 0;

  int get size => switch (game) {
    StrengthGame.omaha => omahaCards,
    StrengthGame.pineapple => 3,
    _ => 2,
  };

  static const _key = 'strength';

  @override
  void initState() {
    super.initState();
    final j = ref.read(tableStoreProvider).loadJson(_key);
    if (j == null) return;
    try {
      game = StrengthGame.values[j['game'] as int];
      omahaCards = j['omahaCards'] as int;
      hiLo = j['hiLo'] as bool;
      final m = (j['cards'] as Map).map(
        (k, v) => MapEntry(int.parse(k as String), v as int),
      );
      cards.addAll(m);
      final empty = [
        for (var i = 0; i < size; i++)
          if (!cards.containsKey(i)) i,
      ];
      selected = empty.isEmpty ? null : empty.first;
      keyboard = selected != null;
      if (cards.length == size) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _calc());
      }
    } catch (_) {
      cards.clear();
    }
  }

  void _save() => ref.read(tableStoreProvider).saveJson(_key, {
    'game': game.index,
    'omahaCards': omahaCards,
    'hiLo': hiLo,
    'cards': {for (final e in cards.entries) '${e.key}': e.value},
  });

  void _reset() {
    cards.clear();
    selected = 0;
    keyboard = true;
    top = sub = fill = null;
    _save();
  }

  void _place(int card) {
    final s = selected;
    if (s == null) return;
    setState(() {
      cards[s] = card;
      int? next;
      for (var k = 1; k <= size; k++) {
        final cand = (s + k) % size;
        if (!cards.containsKey(cand)) {
          next = cand;
          break;
        }
      }
      selected = next;
      keyboard = next != null;
    });
    _calc();
  }

  Future<void> _calc() async {
    _save();
    final gen = ++_gen;
    if (cards.length < size) {
      setState(() => top = sub = fill = null);
      return;
    }
    final hand = [for (var i = 0; i < size; i++) cards[i]!];
    final l = AppLocalizations.of(context);
    final tos =
        ref.read(settingsProvider).shortDeckRule ==
        ShortDeckRule.tripsOverStraight;

    if (game == StrengthGame.holdem || game == StrengthGame.shortDeck) {
      final table = game == StrengthGame.holdem
          ? holdemClasses
          : (tos ? shortClassesTrips : shortClassesStraight);
      final total = game == StrengthGame.holdem ? 1326 : 630;
      final cls = classOf(hand[0], hand[1]);
      var acc = 0, idx = 0;
      for (var k = 0; k < table.length; k++) {
        acc += classCombos(table[k].$1);
        if (table[k].$1 == cls) {
          idx = k;
          break;
        }
      }
      final p = acc / total;
      setState(() {
        top = '${(p * 100).toStringAsFixed(1)}%';
        sub = l.rankOf(idx + 1, table.length);
        fill = p;
      });
      return;
    }

    final rules = switch (game) {
      StrengthGame.omaha => Rules(
        hiLo ? Variant.omahaHiLo : Variant.omaha,
        hole: omahaCards,
      ),
      _ => const Rules(Variant.pineapple, hole: 3),
    };
    final dist = switch ((game, omahaCards, hiLo)) {
      (StrengthGame.omaha, 4, false) => distOmaha4,
      (StrengthGame.omaha, 5, false) => distOmaha5,
      (StrengthGame.omaha, 6, false) => distOmaha6,
      (StrengthGame.omaha, 7, false) => distOmaha7,
      (StrengthGame.omaha, 4, true) => distHiLo4,
      (StrengthGame.omaha, 5, true) => distHiLo5,
      (StrengthGame.omaha, 6, true) => distHiLo6,
      (StrengthGame.omaha, _, true) => distHiLo7,
      (StrengthGame.omaha, _, _) => distOmaha6,
      _ => distPineapple,
    };
    setState(() => busy = true);
    final r = await computeEquityAsync(
      EquityRequest(
        rules: rules,
        hands: [hand, <int>[]],
        boards: [<int>[]],
        maxDeals: 60000,
        timeMs: 1500,
        allowExact: false,
      ),
    );
    if (!mounted || gen != _gen || r == null) return;
    final eq = r.equity(0);
    final better = dist.where((d) => d > eq).length;
    final p = ((better + 0.5) / dist.length).clamp(0.001, 1.0);
    setState(() {
      busy = false;
      top = '${(p * 100).toStringAsFixed(1)}%';
      sub = '±1%';
      fill = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final n = size;
    final w = n <= 3 ? 72.0 : (n == 4 ? 64.0 : (n == 7 ? 44.0 : 52.0));
    final h = n <= 3 ? 100.0 : (n == 4 ? 88.0 : (n == 7 ? 60.0 : 72.0));

    String gameName(StrengthGame g) => switch (g) {
      StrengthGame.holdem => l.holdem,
      StrengthGame.omaha => l.omaha,
      StrengthGame.shortDeck => l.shortDeck,
      StrengthGame.pineapple => l.pineapple,
    };

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(Game.handStrength.title(l))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                SelectButton<StrengthGame>(
                  label: l.gameLabel,
                  sheetTitle: l.gameTitle,
                  value: game,
                  options: StrengthGame.values,
                  optionLabel: gameName,
                  onChanged: (g) => setState(() {
                    game = g;
                    _reset();
                  }),
                ),
                if (game == StrengthGame.omaha) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SelectButton<int>(
                          label: l.cardsLabel,
                          sheetTitle: l.cardsOnHand,
                          value: omahaCards,
                          options: const [4, 5, 6, 7],
                          optionLabel: (v) => '$v',
                          onChanged: (v) => setState(() {
                            omahaCards = v;
                            _reset();
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectButton<bool>(
                          label: l.typeLabel,
                          sheetTitle: l.typeTitle,
                          value: hiLo,
                          options: const [false, true],
                          optionLabel: (v) => v ? l.typeHiLo : l.typeHi,
                          onChanged: (v) {
                            setState(() => hiLo = v);
                            _calc();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      PlayingCardView(
                        card: cards[i],
                        width: w,
                        height: h,
                        selected: keyboard && selected == i,
                        onTap: () => setState(() {
                          selected = i;
                          keyboard = true;
                        }),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                top == null ? l.topPercent : l.topN(top!),
                                style: t.headlineMedium?.copyWith(
                                  color: busy ? c.muted : null,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (sub != null) Text(sub!, style: t.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fill ?? 0,
                            minHeight: 8,
                            backgroundColor: c.surface2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (keyboard && selected != null)
            CardKeyboard(
              used: {...cards.values},
              ranks: game == StrengthGame.shortDeck ? 9 : 13,
              onPick: _place,
              onClear: () {
                final s = selected;
                if (s == null) return;
                setState(() => cards.remove(s));
                _calc();
              },
              onDone: () => setState(() => keyboard = false),
            ),
        ],
      ),
    );
  }
}
