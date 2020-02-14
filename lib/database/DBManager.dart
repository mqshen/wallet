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
      join(dataPath, 'wallet.db'),
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute("CREATE TABLE classifies(id INTEGER PRIMARY KEY, type INTEGER, color INTEGER, image TEXT, name TEXT);");
        await db.execute("insert into classifies values(0, 1, 0xEFC77E, 'eat', '餐饮'),"
            "(1,  1, 0x937866, 'movie', '电影'),"
            "(2,  1, 0xA6B5FD, 'traffic', '出行'),"
            "(3,  1, 0xDCBF4C, 'shop', '购物'),"
            "(4,  1, 0xBDB8E8, 'dailyuse', '日用'),"
            "(5,  1, 0xBDBDE9, 'game', '娱乐'),"
            "(6,  1, 0xC1E085, 'snack', '零食'),"
            "(7,  1, 0xEDD973, 'fruit', '水果'),"
            "(8,  1, 0xA8B2D9, 'smoke', '烟酒'),"
            "(9, 1, 0xB4D3DA, 'waterpower', '水电'),"
            "(10, 1, 0xA5B1A4, 'pet', '宠物'),"
            "(11, 1, 0xDACBB3, 'doctor', '就医'),"
            "(12, 1, 0xC8D7DC, 'sport', '运动'),"
            "(13, 1, 0xBFACF2, 'cloth', '衣物'),"
            "(14, 1, 0x937866, 'edu', '教育'),"
            "(15, 1, 0xDEA7D1, 'face', '美妆'),"
            "(16, 1, 0xD07F9F, 'baby', '育婴'),"
            "(17, 1, 0xCDA6BA, 'gift', '人情'),"
            "(18, 1, 0x9BB7DB, 'fangdai', '房贷'),"
            "(19, 0, 0x9BB7DB, 'income_wage', '薪资'),"
            "(20, 0, 0x9BB7DB, 'income_bonus', '奖金'),"
            "(21, 0, 0x9BB7DB, 'income_buzhu', '补助'),"
            "(22, 0, 0x9BB7DB, 'income_baoxiao', '报销'),"
            "(23, 0, 0x9BB7DB, 'income_redpacket', '红包'),"
            "(24, 0, 0x9BB7DB, 'income_finance', '理财'),"
            "(25, 0, 0x9BB7DB, 'income_stock', '股票'),"
            "(26, 0, 0x9BB7DB, 'income_jijin', '基金'),"
            "(27, 0, 0x9BB7DB, 'income_parttime', '兼职'),"
            "(28, 0, 0x9BB7DB, 'income_gift', '礼物'),"
            "(29, 0, 0x9BB7DB, 'income_refund', '退款');");

        await db.execute("CREATE TABLE assets(id INTEGER PRIMARY KEY, color INTEGER, "
            "image TEXT, name TEXT, description TEXT, balance INTEGER);");
        await db.execute("insert into assets values(0, 5, 'cash', '现金', '现金余额', 0),"
            "(1, 3, 'rbank_zs', '储蓄卡', '储蓄卡余额', 0),"
            "(2, 7, 'weixin', '微信', '微信零钱', 0),"
            "(3, 14, 'zhifubao', '支付宝', '支付宝余额', 0);");

        return db.execute("CREATE TABLE record(id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "amount INTEGER, "
            "type INTEGER,"
            "classify INTEGER,"
            "time INTEGER,"
            "account INTEGER,"
            "remark TEXT);");
      },
//      onUpgrade: (db, oldVersion, version) async {
//        if(oldVersion == 1 && version == 2)
//        db.execute("ALTER TABLE record ADD remark TEXT;");
//      },
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