import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'DBManager.dart';
import 'classify.dart';

class DBHelper {

  static Future<List<Classify>> classifies() async {
    final Database db = await DBManager().database;

    final List<Map<String, dynamic>> maps = await db.query('classifies');

    return List.generate(maps.length, (i) {
      return Classify(
          id: maps[i]['id'],
          image: maps[i]['image'],
          name: maps[i]['name']
      );
    });
  }

  static Future<List<Asset>> assets() async {
    final Database db = await DBManager().database;

    final List<Map<String, dynamic>> maps = await db.query('assets');

    return List.generate(maps.length, (i) {
      return Asset(
          id: maps[i]['id'],
          color: maps[i]['color'],
          image: maps[i]['image'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          balance: maps[i]['balance']
      );
    });
  }


  static Future<void> insertRecord(Record record) async {
    final Database db = await DBManager().database;

    await db.insert(
      'record',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}