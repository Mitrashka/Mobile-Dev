import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'calculation_record.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider instance = DBProvider._();
  static const _tableName = 'calculations';
  static const _webStorageKey = 'saved_calculations';

  Database? _database;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null) return currentDatabase;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'calculations.db');
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mass REAL NOT NULL,
            radius REAL NOT NULL,
            velocity REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  Future<int> insertCalculation(CalculationRecord record) async {
    if (kIsWeb) {
      final records = await _getWebCalculations();
      records.add(record);
      await SharedPreferencesAsync().setString(
        _webStorageKey,
        jsonEncode(records.map((item) => item.toMap()).toList()),
      );
      return records.length;
    }

    final db = await database;
    return db.insert(_tableName, record.toMap());
  }

  Future<List<CalculationRecord>> getAllCalculations() async {
    if (kIsWeb) {
      return (await _getWebCalculations()).reversed.toList();
    }

    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'id DESC');
    return rows.map(CalculationRecord.fromMap).toList();
  }

  Future<List<CalculationRecord>> _getWebCalculations() async {
    final value = await SharedPreferencesAsync().getString(_webStorageKey);
    if (value == null) return [];

    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => CalculationRecord.fromMap(Map<String, Object?>.from(item)))
        .toList();
  }
}
