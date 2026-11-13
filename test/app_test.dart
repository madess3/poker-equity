import 'dart:ui' show Size;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_equity/app/settings.dart';
import 'package:poker_equity/features/games/game.dart';
import 'package:poker_equity/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('в 6-карточных играх максимум 8 игроков', () {
    expect(Game.omaha.maxPlayersFor(6), 8);
    expect(Game.omaha.maxPlayersFor(5), 9);
    expect(Game.ofc.maxPlayersFor(0), 4);
  });

  testWidgets('приложение запускается на вкладке Холдем', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'ru'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: const PokerEquityApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Холдем'), findsWidgets);
  });

  testWidgets('ввод карт с клавиатуры и расчёт эквити', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'locale': 'ru'});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: const PokerEquityApp(),
      ),
    );
    await tester.pumpAndSettle();
    // Клавиатура открыта сразу: вводим AA против KK.
    for (final code in ['As', 'Ah', 'Ks', 'Kh']) {
      await tester.tap(find.bySemanticsLabel(code).first);
      await tester.pump();
    }
    for (
      var i = 0;
      i < 100 && find.textContaining('%').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump();
    }
    expect(find.textContaining('%'), findsWidgets);
  });
}
