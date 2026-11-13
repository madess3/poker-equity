import 'dart:ui' show Size;

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
  appRouter.go(path);
  await tester.pumpAndSettle();
}

Future<void> tapCards(WidgetTester tester, List<String> codes) async {
  for (final code in codes) {
    await tester.tap(find.bySemanticsLabel(code).last);
    await tester.pump();
  }
}

Future<void> settle(WidgetTester tester, [int seconds = 4]) async {
  await tester.runAsync(() => Future.delayed(Duration(seconds: seconds)));
  await tester.pump();
}

void main() {
  testWidgets('Омаха: 4 карты, расчёт', (tester) async {
    await openApp(tester, '/omaha');
    await tapCards(tester, ['As', 'Ad', 'Ks', 'Kd', 'Qh', 'Jh', 'Th', '9h']);
    await settle(tester);
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('Омаха хай-лоу: строка хай/лоу', (tester) async {
    await openApp(tester, '/omaha-hi-lo');
    await tapCards(tester, ['As', '2d', '3c', 'Kd', 'Qh', 'Jh', 'Th', '9h']);
    await settle(tester);
    expect(find.textContaining('хай'), findsWidgets);
    expect(find.textContaining('Лоу возможен'), findsOneWidget);
  });

  testWidgets('Шорт-дек: клавиатура без младших карт', (tester) async {
    await openApp(tester, '/short-deck');
    expect(find.bySemanticsLabel('5s'), findsNothing);
    await tapCards(tester, ['As', 'Ah', 'Ks', 'Kh']);
    await settle(tester);
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
    for (var k = 0; k < 8; k++) {
      await settle(tester, 1); // расчёт идёт пакетами
    }
    if (find.text('Готово').evaluate().isNotEmpty) {
      await tester.tap(find.text('Готово'));
      await tester.pump();
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pump();
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
    await settle(tester);
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
    await settle(tester);
    expect(find.textContaining('Диапазон 1'), findsOneWidget);
  });
}
