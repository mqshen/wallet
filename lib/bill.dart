import 'package:flutter/material.dart';
import 'package:wallet/widget/CircleProcessor.dart';

import 'Constants.dart';
import 'TimeLineIcon.dart';
import 'database/DBManager.dart';
import 'database/DbHelper.dart';
import 'database/classify.dart';

class Bill extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _Bill();

}

class _Bill extends State<Bill> {
  static const double lineHeight = 48.0;
  int _currentSelected = -1;
  int year = 0;
  int month = 0;
  bool isPageLoading = false;
  List<BillItem> arrayOfProducts = new List();
  BillHeadView _billHeadView = BillHeadView();

  ScrollController controller;

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    DateTime dateTime = DateTime.now();
    year = dateTime.year;
    month = dateTime.month;
    super.initState();
    _callAPIToGetListOfData();
  }

  _scrollListener() {
//    if (controller.position.maxScrollExtent == controller.offset) {
//      if (arrayOfProducts.length >= (Constants.pageSize * pageNum) && !isPageLoading) {
//        pageNum++;
//        print("PAGE NUMBER $pageNum");
//        print("getting data");
//        _callAPIToGetListOfData(); // Hit API to get new data
//      }
//    }
    print(controller.position.extentAfter);
    if (controller.position.extentAfter <= 0 && isPageLoading == false) {
      month -= 1;
      _callAPIToGetListOfData();
    }
  }

  void _callAPIToGetListOfData() {
    isPageLoading = true;
    DBHelper.records(year, month).then((records) {
      List<Classify> classifies = DBManager().classifies;
      BillItem monthItem = BillItem(
          type: RecordType.month,
      );
      BillItem dayItem = BillItem(
        type: RecordType.day,
      );
      records.forEach((record) {
        DateTime dateTime = record.getOpTime();
        if(dateTime.month != monthItem.id) {
          monthItem.id = dateTime.month;
          arrayOfProducts.add(monthItem);
        }
        if(dateTime.day != dayItem.id) {
          dayItem = BillItem(
            id: dateTime.day,
            type: RecordType.day,
          );
          arrayOfProducts.add(dayItem);
        }
        String classifyName = "";
        String classifyImage = "eat";
        if(record.classify < classifies.length) {
          classifyName = classifies[record.classify].name;
          classifyImage = classifies[record.classify].image;
        }
        BillItem billItem = BillItem(
          type: RecordType.item,
          classifyName: classifyName,
          classifyImage: classifyImage,
        );
        if(record.type == 0) {
          dayItem.leftAmount += record.amount;
          monthItem.leftAmount += record.amount;
          billItem.leftAmount = record.amount;
        } else {
          dayItem.rightAmount += record.amount;
          monthItem.rightAmount += record.amount;
          billItem.rightAmount = record.amount;
        }
        arrayOfProducts.add(billItem);
      });
      if(arrayOfProducts.length > 0 && _billHeadView.billItem == null) {
        _billHeadView.state.setState((){
          _billHeadView.billItem = arrayOfProducts[0];
        });
      }
    }).whenComplete((){
      isPageLoading = false;
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(""),
        ),
        body: Column(
          children: [
            _billHeadView,
            Expanded(
                child: buildListView(context)
            )
          ],
        )
    );
  }

  Widget buildListView(BuildContext context) {

    return new ListView.builder(
      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        BillItem recordItem = arrayOfProducts[index];
        String leftText = "";
        String rightText = "";
        if(RecordType.item == recordItem.type) {
          if (recordItem.leftAmount > 0) {
            leftText = '${Utils.toCurrency(recordItem.leftAmount)} ${recordItem.classifyName}';
          } else if (recordItem.rightAmount > 0) {
            rightText = '${recordItem.classifyName} ${Utils.toCurrency(recordItem.rightAmount)}';
          }
          return FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 30,
                  height: lineHeight,
                  child: Visibility(
                    child: FlatButton(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Icon(Icons.delete, size: 14, color: Colors.red,),
                      onPressed: () {},
                    ),
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: recordItem.show,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                      height: lineHeight,
                      padding: const EdgeInsets.only(right: 5.0),
                      alignment: Alignment.centerRight,
                      child: new Text(leftText, textAlign: TextAlign.right,)
                  ),
                ),
                CustomPaint(
                  painter: new TimeLineIcon(
                      paintWidth: 1, //widget.timeAxisLineWidth,
                      circleSize: 0, //widget.lineToLeft,
                      lineColor: Colors.grey[300],
                      isTimeLine: true
                  ),
                  child: Container(
                    width: 40,
                    child: IconButton(
                      //child: Center(
                      icon: Image.asset(Utils.getClassifyImage(recordItem.classifyImage),),
                      //),
                      onPressed: () {
                        doHidden();
                        _currentSelected = index;
                        setState(() {
                          recordItem.show = !recordItem.show;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                      height: lineHeight,
                      padding: const EdgeInsets.only(left: 5.0),
                      alignment: Alignment.centerLeft,
                      child: new Text(rightText, textAlign: TextAlign.left,)
                  ),
                ),
                SizedBox(
                  width: 30,
                  height: lineHeight,
                  child: Visibility(
                    child: Icon(Icons.edit, size: 14, color: Colors.blue),
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: recordItem.show,
                  ),
                ),
              ],
            ),
            onPressed: () {
              doHidden();
            },
          );
        } else {
          String centerText = '${recordItem.id}';
          double circleSize = 12;
          Widget widget;
          if(RecordType.day == recordItem.type) {
            centerText = centerText + "日";
            widget = Center(
                child: Text(centerText, style: TextStyle(fontSize: 8),)
            );
            if(recordItem.leftAmount > 0) {
              leftText = '${Utils.toCurrency(recordItem.leftAmount)} 收入';
            }
            if(recordItem.rightAmount > 0) {
              rightText = '支出 ${Utils.toCurrency(recordItem.rightAmount)}';
            }
          }
          if(RecordType.month == recordItem.type) {
            centerText = centerText + "月";
            widget = Align(
                alignment: Alignment.centerLeft ,
                child: Text(centerText, style: TextStyle(fontSize: 10),)
            );
            circleSize = 3;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                    height: lineHeight,
                    padding: const EdgeInsets.only(right: 5.0),
                    alignment: Alignment.centerRight,
                    child: new Text(leftText, textAlign: TextAlign.right,)
                ),
              ),
              CustomPaint(
                painter: new TimeLineIcon(
                    paintWidth: 1, //widget.timeAxisLineWidth,
                    circleSize: circleSize, //widget.lineToLeft,
                    lineColor: Colors.grey[300],
                    isTimeLine: true
                ),
                child: Container (
                  width: 40,
                  height: lineHeight,
                  child: widget
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                    height: lineHeight,
                    padding: const EdgeInsets.only(left: 5.0),
                    alignment: Alignment.centerLeft,
                    child: new Text(rightText, textAlign: TextAlign.left,)
                ),
              ),
            ],
          );
          //return new Text("");
        }
      },
      itemCount: arrayOfProducts == null ? 0 : arrayOfProducts.length,
    );
  }

  void doHidden() {
    if(_currentSelected >= 0) {
      BillItem recordItem = arrayOfProducts[_currentSelected];
      setState(() {
        recordItem.show = false;
      });
    }
  }
}

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

class BillHeadView extends StatefulWidget {
  BillItem billItem = null;

  final State<StatefulWidget> state = _BillHeadView();

  BillHeadView({this.billItem});

  @override
  State<StatefulWidget> createState() => state;

}

class _BillHeadView extends State<BillHeadView> {

  @override
  Widget build(BuildContext context) {
    String leftContent = "";
    int leftAmount = 0;
    int amount = 0;
    String rightContent = "";
    double percent = 0.0;
    int rightAmount = 0;
    if(widget.billItem != null) {
      leftContent = '${widget.billItem.id}月收入';
      rightContent = '${widget.billItem.id}月支出';
      leftAmount = widget.billItem.leftAmount;
      rightAmount = widget.billItem.rightAmount;
      amount = DBManager().budget - rightAmount;
      percent = rightAmount / DBManager().budget;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.only(right: 5.0),
            alignment: Alignment.centerRight,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(leftContent, style: TextStyle(fontSize: 12),),
                  Text(Utils.toCurrency(leftAmount), style: TextStyle(fontSize: 12),)
                ]
            ),
          ),
        ),
        CustomPaint(
          painter: new TimeLineIcon(
              paintWidth: 1,
              circleSize: 0,
              lineColor: Colors.grey[300],
              isTimeLine: true
          ),
          child: Container (
            padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: SizedBox(
              width: 70,
              height: 70,
              child: CircleProcessor(value: percent, size: 70, amount: amount),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
              padding: const EdgeInsets.only(left: 5.0),
              alignment: Alignment.centerLeft,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(rightContent, style: TextStyle(fontSize: 12),),
                    Text(Utils.toCurrency(rightAmount), style: TextStyle(fontSize: 12),)
                  ]
              )
          ),
        ),
      ],
    );
  }

}