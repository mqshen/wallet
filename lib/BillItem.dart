


enum RecordType {
  headItem,
  item,
  day,
  month,
}

class BillItem {
  int id;
  RecordType type;
  bool show;
  int leftAmount;
  int rightAmount;
  String classifyName;
  String classifyImage;

  BillItem({
    this.id = 0,
    this.type,
    this.show = false,
    this.leftAmount = 0,
    this.rightAmount = 0,
    this.classifyName = "",
    this.classifyImage = ""});

}
