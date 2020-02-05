import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DbHelper.dart';
import 'classify.dart';

class DBManager {

  static final DBManager _singleton = new DBManager._internal();
  // Open the database and store the reference.
  Future<Database> database;
  final classifies = <Classify>[];
  final assets = <Asset>[];


  factory DBManager() {
    return _singleton;
  }

  void init() async {
    String dataPath = await getDatabasesPath();
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(dataPath, 'wallet.db'),
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute("CREATE TABLE classifies(id INTEGER PRIMARY KEY, image TEXT, name TEXT);");
        await db.execute("insert into classifies values(1, 'eat', '餐饮'),"
        "(2, 'movie', '电影'),"
        "(3, 'traffic', '出行'),"
        "(4, 'shop', '购物'),"
        "(5, 'dailyuse', '日用'),"
        "(6, 'game', '娱乐'),"
        "(7, 'snack', '零食'),"
        "(8, 'fruit', '水果'),"
        "(9, 'smoke', '烟酒'),"
        "(10, 'waterpower', '水电'),"
        "(11, 'pet', '宠物'),"
        "(12, 'doctor', '就医'),"
        "(13, 'sport', '运动'),"
        "(14, 'cloth', '衣物'),"
        "(15, 'edu', '教育'),"
        "(16, 'face', '美妆'),"
        "(17, 'baby', '育婴'),"
        "(18, 'gift', '人情'),"
        "(19, 'fangdai', '房贷');");

        await db.execute("CREATE TABLE assets(id INTEGER PRIMARY KEY, color INTEGER, "
            "image TEXT, name TEXT, description TEXT, balance INTEGER);");
        await db.execute("insert into assets values(1, 5, 'cash', '现金', '现金余额', 0),"
            "(2, 3, 'rbank_zs', '储蓄卡', '储蓄卡余额', 0),"
            "(3, 7, 'weixin', '微信', '微信零钱', 0),"
            "(4, 14, 'zhifubao', '支付宝', '支付宝余额', 0);");

        return db.execute("CREATE TABLE record(id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "amount INTEGER, "
            "type INTEGER,"
            "classify INTEGER,"
            "time INTEGER,"
            "account INTEGER,"
            "remark TEXT);");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    database.then((db) {
      DBHelper.classifies().then((array) {
        classifies.addAll(array);
      });
      DBHelper.assets().then((array) {
        assets.addAll(array);
      });

    });
  }


  DBManager._internal() {
    init();
  }

}