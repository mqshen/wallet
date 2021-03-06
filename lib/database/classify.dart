
class Classify {
  static const double iconSize = 30;

  final int id;
  final int type;
  final int color;
  final String image;
  final String name;

  Classify({this.id, this.type, this.color, this.image, this.name});

}

class Asset {
  final int id;
  final int color;
  final String image;
  String name;
  String description;
  int balance;

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'image': image,
      'name': name,
      'description': description,
      'balance': balance,
    };
  }

  Asset({this.id, this.color, this.image, this.name, this.description,
      this.balance});
}

class Record {
  int id;
  int amount;
  final int type;
  int classify;
  int time;
  int account;
  String remark;


  Record({
    this.id,
    this.amount,
    this.type,
    this.classify,
    this.time,
    this.account,
    this.remark = ""});

  DateTime getOpTime() {
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

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

  @override
  String toString() {
    return 'id: $id, amount: $amount, type: $type, classify: $classify, time: $time, account: $account, remark: $remark';
  }

}