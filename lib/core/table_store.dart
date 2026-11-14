import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/settings.dart';

/// Состояние одной игровой вкладки: всё, что ввёл пользователь.
/// Хранится в настройках телефона, поэтому переживает переход между
/// вкладками, сворачивание и перезапуск приложения.
class TableSnapshot {
  TableSnapshot({
    required this.handSize,
    required this.players,
    required this.doubleBoard,
    required this.rule,
    required this.cards,
    required this.dead,
    required this.ranges,
    required this.discarded,
    required this.mixed,
  });

  final int handSize;
  final int players;
  final bool doubleBoard;
  final int? rule; // шорт-дек: индекс ShortDeckRule, null — по умолчанию
  final Map<String, int> cards;
  final List<int> dead;
  final Map<int, List<String>> ranges;
  final List<int> discarded;
  final bool mixed;

  Map<String, Object?> toJson() => {
    'handSize': handSize,
    'players': players,
    'doubleBoard': doubleBoard,
    'rule': rule,
    'cards': cards,
    'dead': dead,
    'ranges': {for (final e in ranges.entries) '${e.key}': e.value},
    'discarded': discarded,
    'mixed': mixed,
  };

  static TableSnapshot? fromJson(Map<String, Object?> j) {
    try {
      return TableSnapshot(
        handSize: j['handSize'] as int,
        players: j['players'] as int,
        doubleBoard: j['doubleBoard'] as bool,
        rule: j['rule'] as int?,
        cards: (j['cards'] as Map).map(
          (k, v) => MapEntry(k as String, v as int),
        ),
        dead: (j['dead'] as List).cast<int>(),
        ranges: (j['ranges'] as Map).map(
          (k, v) =>
              MapEntry(int.parse(k as String), (v as List).cast<String>()),
        ),
        discarded: (j['discarded'] as List).cast<int>(),
        mixed: j['mixed'] as bool,
      );
    } catch (_) {
      return null; // повреждённые или старые данные — начинаем с чистого стола
    }
  }
}

/// Простое хранилище JSON-значений по ключу.
class TableStore {
  TableStore(this._p);
  final SharedPreferences _p;

  static const lastGameKey = 'lastGame';
  static const lastRouteKey = 'lastRoute';

  TableSnapshot? loadTable(String id) {
    final m = loadJson('table_$id');
    return m == null ? null : TableSnapshot.fromJson(m);
  }

  void saveTable(String id, TableSnapshot s) =>
      saveJson('table_$id', s.toJson());

  Map<String, Object?>? loadJson(String key) {
    final s = _p.getString(key);
    if (s == null) return null;
    try {
      return (jsonDecode(s) as Map).cast<String, Object?>();
    } catch (_) {
      return null;
    }
  }

  void saveJson(String key, Map<String, Object?> v) =>
      _p.setString(key, jsonEncode(v));

  String? getString(String key) => _p.getString(key);
  void setString(String key, String v) => _p.setString(key, v);
}

final tableStoreProvider = Provider<TableStore>(
  (ref) => TableStore(ref.read(prefsProvider)),
);
