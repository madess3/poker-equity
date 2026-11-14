import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:poker_equity/app/router.dart';
import 'package:poker_equity/app/settings.dart';
import 'package:poker_equity/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> openApp(WidgetTester tester, String path) async {
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
  // Сбросить стек экранов от предыдущего теста (маршрутизатор общий).
  appRouter.go('/settings');
  await tester.pumpAndSettle();
  appRouter.go(path);
  await tester.pumpAndSettle();
}

Future<void> tapCards(WidgetTester tester, List<String> codes) async {
  for (final code in codes) {
    await tester.tap(find.bySemanticsLabel(code).last);
    await tester.pump();
  }
}

/// Ждёт, пока появится [finder] (расчёт идёт в отдельном потоке), до 30 с.
Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
  }
}

void main() {
  testWidgets('Омаха: 4 карты, расчёт', (tester) async {
    await openApp(tester, '/omaha');
    await tapCards(tester, ['As', 'Ad', 'Ks', 'Kd', 'Qh', 'Jh', 'Th', '9h']);
    await waitFor(tester, find.textContaining('%'));
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('Омаха хай-лоу: строка хай/лоу', (tester) async {
    await openApp(tester, '/omaha-hi-lo');
    await tapCards(tester, ['As', '2d', '3c', 'Kd', 'Qh', 'Jh', 'Th', '9h']);
    await waitFor(tester, find.textContaining('Лоу возможен'));
    expect(find.textContaining('хай'), findsWidgets);
    expect(find.textContaining('Лоу возможен'), findsOneWidget);
  });

  testWidgets('Шорт-дек: клавиатура без младших карт', (tester) async {
    await openApp(tester, '/short-deck');
    expect(find.bySemanticsLabel('5s'), findsNothing);
    await tapCards(tester, ['As', 'Ah', 'Ks', 'Kh']);
    await waitFor(tester, find.textContaining('%'));
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('Ананас: варианты сброса на флопе', (tester) async {
    await openApp(tester, '/pineapple');
    await tapCards(tester, [
      'As',
      'Kd',
      '5c',
      'Qh',
      'Qd',
      '2s',
      'Kh',
      '8c',
      '3d',
    ]);
    await waitFor(tester, find.textContaining('%'));
    if (find.text('Готово').evaluate().isNotEmpty) {
      await tester.tap(find.text('Готово'));
      await tester.pump();
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pump();
    await waitFor(tester, find.text('Сбросить ', skipOffstage: false));
    expect(find.text('Сбросить ', skipOffstage: false), findsWidgets);
  });

  testWidgets('Сила руки: Холдем и Омаха', (tester) async {
    await openApp(tester, '/hand-strength');
    await tapCards(tester, ['As', 'Jd']);
    await tester.pump();
    expect(find.textContaining('Топ'), findsWidgets);
    expect(find.textContaining('из 169'), findsOneWidget);
  });

  testWidgets('Холдем: анализ открывается', (tester) async {
    await openApp(tester, '/holdem');
    await tapCards(tester, ['Ah', 'Kh', 'Qs', 'Qd', '7h', '2h', '9c']);
    await waitFor(tester, find.textContaining('побед'));
    await tester.tap(find.text('Готово'));
    await tester.pump();
    await tester.ensureVisible(find.text('Анализ'));
    await tester.tap(find.text('Анализ'));
    await tester.pumpAndSettle();
    expect(find.text('15'), findsOneWidget); // 9 червей + 3 туза + 3 короля
  });

  testWidgets('Холдем: экран диапазона', (tester) async {
    await openApp(tester, '/holdem');
    await tester.tap(find.text('Диапазон').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('10%'));
    await tester.pump();
    expect(find.textContaining('комбинаций'), findsOneWidget);
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();
    await waitFor(tester, find.textContaining('Диапазон 1'));
    expect(find.textContaining('Диапазон 1'), findsOneWidget);
  });

  testWidgets('Состояние вкладки сохраняется при переходе', (tester) async {
    await openApp(tester, '/holdem');
    await tapCards(tester, ['Ah', 'Kh']);
    appRouter.go('/omaha');
    await tester.pumpAndSettle();
    appRouter.go('/holdem');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Ah'), findsWidgets);
    expect(find.bySemanticsLabel('Kh'), findsWidgets);
  });

  testWidgets('Убрать конкретного игрока', (tester) async {
    await openApp(tester, '/holdem');
    await tester.tap(find.textContaining('Игроков'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3').last);
    await tester.pumpAndSettle();
    await tapCards(tester, ['Ah', 'Kh', 'Qs', 'Qd', '7c', '7d']);
    await tester.tap(find.byTooltip('Убрать игрока').at(1));
    await tester.pump();
    expect(find.text('Игрок 3'), findsNothing);
    expect(
      find.bySemanticsLabel('Qs'),
      findsNWidgets(1),
    ); // только на клавиатуре
    expect(find.bySemanticsLabel('7c'), findsWidgets);
  });

  testWidgets('Омаха: 7 карт и лимит 7 игроков', (tester) async {
    await openApp(tester, '/omaha');
    await tester.tap(find.textContaining('Карт:'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Игроков'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    expect(find.descendant(of: sheet, matching: find.text('8')), findsNothing);
    expect(
      find.descendant(of: sheet, matching: find.text('7')),
      findsOneWidget,
    );
  });

  testWidgets('ICM: контрольный пример', (tester) async {
    await openApp(tester, '/icm');
    final fields = find.byType(TextField);
    for (final (i, v) in ['50', '30', '20', '900', '400', '200'].indexed) {
      await tester.enterText(fields.at(i), v);
    }
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('617.9'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('617.9'), findsOneWidget);
    expect(find.text('485.0'), findsOneWidget);
    expect(find.text('397.1'), findsOneWidget);
    expect(find.text('650.0'), findsOneWidget);
  });

  testWidgets('Ярлык «EV chop · Страховка» открывает анализ', (tester) async {
    await openApp(tester, '/holdem');
    await tapCards(tester, ['Ah', 'Kh', 'Qs', 'Qd', '7h', '2h', '9c']);
    await waitFor(tester, find.textContaining('побед'));
    appRouter.go('/holdem?open=insurance');
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('EV chop стоит 1.0'));
    expect(find.textContaining('EV chop'), findsWidgets);
    await tester.tap(find.textContaining('Модель'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Страховка от аутов'));
    await tester.pumpAndSettle();
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('Прокрутки на тёрне', (tester) async {
    await openApp(tester, '/holdem');
    await tapCards(tester, ['As', 'Kd', 'Qh', 'Jh', 'Ah', '7h', '2c', '9d']);
    await waitFor(tester, find.textContaining('побед'));
    await tester.ensureVisible(find.text('Анализ'));
    await tester.tap(find.text('Анализ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Прокрутки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Прокрутки'));
    // На вкладке крутится индикатор расчёта — pumpAndSettle не дождётся конца.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.textContaining('Игрок:').hitTestable().first);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Игрок 2').last);
    await tester.pump(const Duration(milliseconds: 600));
    await waitFor(tester, find.text('3.8%'));
    expect(find.text('3.8%'), findsOneWidget);
    expect(find.text('62.9%'), findsOneWidget);
  });
}
