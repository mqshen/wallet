import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../Constants.dart';
import 'DBManager.dart';
import 'classify.dart';

class DBHelper {
  static Future<List<Classify>> classifies() async {
    final Database db = await DBManager().database;

    final List<Map<String, dynamic>> maps = await db.query('classifies');

    return List.generate(maps.length, (i) {
      return Classify(
          id: maps[i]['id'],
          color: maps[i]['color'],
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


  static Future<int> insertRecord(Record record) async {
    final Database db = await DBManager().database;

    return db.insert(
      'record',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Record>> records(int year, int month) async {
    final Database db = await DBManager().database;

    DateTime start = new DateTime(year, month, 1);
    DateTime end = new DateTime(year, month + 1, 1);

    String where = "time between ${start.millisecondsSinceEpoch} and ${end.millisecondsSinceEpoch}";

    final List<Map<String, dynamic>> maps = await db.query('record',
        orderBy: "time desc", where: where);

    return List.generate(maps.length, (i) {
      return Record(
          id: maps[i]['id'],
          amount: maps[i]['amount'],
          type: maps[i]['type'],
          classify: maps[i]['classify'],
          time: maps[i]['time'],
          account: maps[i]['account'],
          remark: maps[i]['remark']
      );
    });
  }

  static Future<List<Record>> findRecordsByYear(int year) async {
    final Database db = await DBManager().database;

    DateTime start = new DateTime(year, 1, 1);
    DateTime end = new DateTime(year + 1, 1, 1);

    String where = "time between ${start.millisecondsSinceEpoch} and ${end.millisecondsSinceEpoch}";

    final List<Map<String, dynamic>> maps = await db.query('record',
        orderBy: "time desc", where: where);

    return List.generate(maps.length, (i) {
      return Record(
          id: maps[i]['id'],
          amount: maps[i]['amount'],
          type: maps[i]['type'],
          classify: maps[i]['classify'],
          time: maps[i]['time'],
          account: maps[i]['account'],
          remark: maps[i]['remark']
      );
    });
  }
}