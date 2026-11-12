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
    await tester.pumpWidget(ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const PokerEquityApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Холдем'), findsWidgets);
  });
}
