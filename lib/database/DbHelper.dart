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
          type: maps[i]['type'],
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

  static Future<int> updateAsset(Asset asset) async {
    final Database db = await DBManager().database;

    return db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertRecord(Record record) async {
    final Database db = await DBManager().database;

    return db.insert(
      'record',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<int> updateRecord(Record record) async {
    final Database db = await DBManager().database;

    return db.update(
      'record',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Record> findRecordById(int id) async {
    final Database db = await DBManager().database;

    Future<Record> result = db.query(
        'record',
        where: 'id = ?',
        whereArgs: [id]
    ).then((result){
      if(result.length > 0)
        return generateRecord(result[0]);
      else
        return null;
    });

    return result;
  }

  static Record generateRecord(Map<String, dynamic> result) {
    return Record(
        id: result['id'],
        amount: result['amount'],
        type: result['type'],
        classify: result['classify'],
        time: result['time'],
        account: result['account'],
        remark: result['remark']
    );
  }

  static Future<int> deleteRecord(int id) async {
    final Database db = await DBManager().database;

    return db.delete(
      'record',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  static Future<List<Record>> records(int year, int month) async {

    DateTime start = new DateTime(year, month, 1);
    DateTime end = new DateTime(year, month + 1, 1);

    return findRecordsByTime(start, end);

  }

  static Future<List<Record>> findRecordsByDay(DateTime dateTime) async {
    DateTime start = new DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime end = new DateTime(dateTime.year, dateTime.month, dateTime.day + 1);

    return findRecordsByTime(start, end);
  }

  static Future<List<Record>> findRecordsByTime(DateTime start, DateTime end) async {
    final Database db = await DBManager().database;

    String where = "time between ${start.millisecondsSinceEpoch} "
        "and ${end.millisecondsSinceEpoch} and type < 2";

    final List<Map<String, dynamic>> maps = await db.query('record',
        orderBy: "time desc", where: where);

    return List.generate(maps.length, (i) {
      return generateRecord(maps[i]);
    });
  }

  static Future<List<Record>> recordsByType(int year, int month, int type) async {
    final Database db = await DBManager().database;

    DateTime start = new DateTime(year, month, 1);
    DateTime end = new DateTime(year, month + 1, 1);

    String where = "time between ${start.millisecondsSinceEpoch} "
        "and ${end.millisecondsSinceEpoch} and type = $type";

    final List<Map<String, dynamic>> maps = await db.query('record',
        orderBy: "time desc", where: where);

    return List.generate(maps.length, (i) {
      return generateRecord(maps[i]);
    });
  }

  static Future<List<Record>> findRecordsByYear(int year) async {
//    final Database db = await DBManager().database;
//
//    DateTime start = new DateTime(year, 1, 1);
//    DateTime end = new DateTime(year + 1, 1, 1);
//
//    String where = "time between ${start.millisecondsSinceEpoch} and ${end.millisecondsSinceEpoch}";
//
//    final List<Map<String, dynamic>> maps = await db.query('record',
//        orderBy: "time desc", where: where);

    return findRecordsByYearAndAccount(year, -1);
  }

  static Future<List<Record>> findRecordsByYearAndAccount(int year, int account) async {
    final Database db = await DBManager().database;

    DateTime start = new DateTime(year, 1, 1);
    DateTime end = new DateTime(year + 1, 1, 1);

    String where = "time between ${start.millisecondsSinceEpoch} and ${end.millisecondsSinceEpoch}";

    if(account > -1) {
      where += " and account = ${account}";
    }

    final List<Map<String, dynamic>> maps = await db.query('record',
        orderBy: "time desc", where: where);

    return generateRecordList(maps);
  }

  static List<Record> generateRecordList(List<Map<String, dynamic>> maps ) {
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