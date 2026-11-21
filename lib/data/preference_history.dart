import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHistory<T> {
  PreferenceHistory({
    required this.key,
    required this.fromJson,
    required this.toJson,
  });

  final String key;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, Object?> Function(T) toJson;
  final _preferences = SharedPreferencesAsync();
  static final _pendingWrites = <String, Future<void>>{};

  Future<List<T>> load() async {
    await _pendingWrites[key];
    return _decode(await _preferences.getStringList(key) ?? []);
  }

  Future<List<T>> add(T record) async {
    final previousWrite = _pendingWrites[key];
    final finished = Completer<void>();
    _pendingWrites[key] = finished.future;
    try {
      await previousWrite;
      final values = await _preferences.getStringList(key) ?? [];
      final previous = _decode(values);
      await _preferences.setStringList(key, [
        jsonEncode(toJson(record)),
        ...values,
      ]);
      return [record, ...previous];
    } finally {
      finished.complete();
      if (_pendingWrites[key] == finished.future) _pendingWrites.remove(key);
    }
  }

  List<T> _decode(List<String> values) => [
    for (final value in values)
      fromJson(jsonDecode(value) as Map<String, dynamic>),
  ];
}
