import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';

class DatabaseHelper {
  static final _databaseName = 'xcuseme.db';
  static final _databaseVersion = 1;

  static final table = 'events';

  static final columnId = '_id';
  static final columnMillis = 'millis';
  static final columnType = 'type';
  static final columnDescription = 'description';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    Database db = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    return db;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnMillis INTEGER NOT NULL,
        $columnType TEXT NOT NULL,
        $columnDescription TEXT NOT NULL
      )
      ''');
  }

  // HELPERS

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<void> update(int millis, Map<String, dynamic> newRow) async {
    Database db = await instance.database;
    await db.update(
      table,
      newRow,
      where: "${columnMillis} = ?",
      whereArgs: [millis],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
