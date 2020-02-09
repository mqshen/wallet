import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DbHelper.dart';
import 'classify.dart';

class DBManager {
  Completer completer = new Completer();

  static final DBManager _singleton = new DBManager._internal();
  // Open the database and store the reference.
  Future<Database> database;
  final classifies = <Classify>[];
  final assets = <Asset>[];
  int budget = 300000;


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
        await db.execute("CREATE TABLE classifies(id INTEGER PRIMARY KEY, color INTEGER, image TEXT, name TEXT);");
        await db.execute("insert into classifies values(1, 0xEFC77E, 'eat', '餐饮'),"
        "(2,  0x937866, 'movie', '电影'),"
        "(3,  0xA6B5FD, 'traffic', '出行'),"
        "(4,  0xDCBF4C, 'shop', '购物'),"
        "(5,  0xBDB8E8, 'dailyuse', '日用'),"
        "(6,  0xBDBDE9, 'game', '娱乐'),"
        "(7,  0xC1E085, 'snack', '零食'),"
        "(8,  0xEDD973, 'fruit', '水果'),"
        "(9,  0xA8B2D9, 'smoke', '烟酒'),"
        "(10, 0xB4D3DA, 'waterpower', '水电'),"
        "(11, 0xA5B1A4, 'pet', '宠物'),"
        "(12, 0xDACBB3, 'doctor', '就医'),"
        "(13, 0xC8D7DC, 'sport', '运动'),"
        "(14, 0xBFACF2, 'cloth', '衣物'),"
        "(15, 0x937866, 'edu', '教育'),"
        "(16, 0xDEA7D1, 'face', '美妆'),"
        "(17, 0xD07F9F, 'baby', '育婴'),"
        "(18, 0xCDA6BA, 'gift', '人情'),"
        "(19, 0x9BB7DB, 'fangdai', '房贷');");

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
        DBHelper.assets().then((array) {
          assets.addAll(array);
          completer.complete(() => 1);
        });
      });
    });
  }

  DBManager._internal() {
    init();
  }

}