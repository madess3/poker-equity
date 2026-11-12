import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/drawer.dart';
import '../../app/settings.dart';
import '../../app/theme.dart';
import '../../core/widgets/card_slot.dart';
import '../../core/widgets/select_button.dart';
import '../../l10n/app_localizations.dart';
import 'game.dart';

/// Каркас вкладки игры: шапка, выбор параметров, борд, игроки.
/// Ввод карт и расчёты добавляются на этапе функций.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.game});
  final Game game;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late int cards = widget.game.handCards.isEmpty ? 0 : widget.game.handCards.first;
  late int players = widget.game == Game.ofc ? 3 : 2;
  bool doubleBoard = false;
  ShortDeckRule? rule;
  Game strengthGame = Game.holdem;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final settings = ref.watch(settingsProvider);
    final effRule = rule ?? settings.shortDeckRule;

    String ruleLabel(ShortDeckRule r) => r == ShortDeckRule.straightOverTrips
        ? l.ruleStraightOverTrips
        : l.ruleTripsOverStraight;

    final selectors = <Widget>[
      if (g.handCards.length > 1)
        SelectButton<int>(
          label: l.cardsLabel,
          sheetTitle: l.cardsOnHand,
          value: cards,
          options: g.handCards,
          optionLabel: (v) => '$v',
          onChanged: (v) => setState(() {
            cards = v;
            players = players.clamp(g.minPlayers, g.maxPlayersFor(v));
          }),
        ),
      if (g.hasRules)
        SelectButton<ShortDeckRule>(
          label: l.rulesLabel,
          sheetTitle: l.rulesTitle,
          value: effRule,
          options: ShortDeckRule.values,
          optionLabel: ruleLabel,
          onChanged: (v) => setState(() => rule = v),
        ),
      if (g == Game.handStrength)
        SelectButton<Game>(
          label: l.gameLabel,
          sheetTitle: l.gameTitle,
          value: strengthGame,
          options: Game.strengthGames,
          optionLabel: (v) => v.title(l),
          onChanged: (v) => setState(() => strengthGame = v),
        )
      else
        SelectButton<int>(
          label: l.playersLabel,
          sheetTitle: l.playersTitle,
          value: players,
          options: [
            for (var i = g.minPlayers; i <= g.maxPlayersFor(cards); i++) i
          ],
          optionLabel: (v) => '$v',
          onChanged: (v) => setState(() => players = v),
        ),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(g.title(l)),
        actions: [
          if (g.doubleBoard)
            FilterChip(
              label: Text(l.doubleBoard),
              selected: doubleBoard,
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                  fontSize: 13,
                  color: doubleBoard
                      ? Theme.of(context).colorScheme.onPrimary
                      : null),
              onSelected: (v) => setState(() => doubleBoard = v),
            ),
          if (g != Game.handStrength)
            IconButton(
              tooltip: l.cameraV2,
              onPressed: null,
              icon: const Icon(Icons.photo_camera_outlined),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(children: [
            for (final (i, s) in selectors.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: s),
            ],
          ]),
          const SizedBox(height: 16),
          if (g == Game.handStrength)
            ..._strength(context, l, c)
          else if (g == Game.ofc)
            ..._ofc(context, l, c)
          else
            ..._poker(context, l, c),
          const SizedBox(height: 16),
          Text(l.comingSoon,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  List<Widget> _poker(BuildContext context, AppLocalizations l, AppColors c) {
    final t = Theme.of(context).textTheme;
    final small = cards >= 5;
    Widget board(String label) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            SizedBox(width: 56, child: Text(label, style: t.bodySmall)),
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              const CardSlot(),
            ],
          ]),
        );
    return [
      board(doubleBoard ? l.boardN(1) : l.board),
      if (doubleBoard) board(l.boardN(2)),
      const SizedBox(height: 4),
      for (var p = 1; p <= players; p++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(l.playerN(p), style: t.bodySmall)),
                  Text('—', style: t.headlineSmall),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 5, children: [
                  for (var i = 0; i < cards; i++)
                    CardSlot(width: small ? 42 : 50, height: small ? 58 : 68),
                ]),
              ]),
            ),
          ),
        ),
    ];
  }

  List<Widget> _ofc(BuildContext context, AppLocalizations l, AppColors c) {
    final t = Theme.of(context).textTheme;
    return [
      for (var p = 1; p <= players; p++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(l.playerN(p), style: t.titleMedium),
                const SizedBox(height: 8),
                for (final box in [l.boxTop, l.boxMiddle, l.boxBottom])
                  Container(
                    height: 44,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(box, style: t.bodySmall),
                  ),
              ]),
            ),
          ),
        ),
    ];
  }

  List<Widget> _strength(BuildContext context, AppLocalizations l, AppColors c) {
    final t = Theme.of(context).textTheme;
    final n = strengthGame == Game.holdem || strengthGame == Game.shortDeck
        ? 2
        : strengthGame == Game.pineapple
            ? 3
            : 4;
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          CardSlot(width: n <= 3 ? 72 : 64, height: n <= 3 ? 100 : 88),
        ],
      ]),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.topPercent, style: t.headlineMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: 0, minHeight: 8, backgroundColor: c.surface2),
            ),
          ]),
        ),
      ),
    ];
  }
}
