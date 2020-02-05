
class Classify {
  static const double iconSize = 30;

  final int id;
  final String image;
  final String name;

  Classify({this.id, this.image, this.name});

}

class Asset {
  final int id;
  final int color;
  final String image;
  final String name;
  final String description;
  final int balance;

  Asset({this.id, this.color, this.image, this.name, this.description,
      this.balance});
}

class Record {
  int id;
  final int amount;
  final int type;
  final int classify;
  final int time;
  final int account;
  final String remark;


  Record({
    this.id,
    this.amount,
    this.type,
    this.classify,
    this.time,
    this.account,
    this.remark = ""});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'classify': classify,
      'time': time,
      'account': account,
      'remark': remark,
    };
  }

}