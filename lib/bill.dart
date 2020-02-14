import 'package:flutter/material.dart';
import 'package:wallet/record/AddRecordPage.dart';
import 'package:wallet/widget/CircleProcessor.dart';

import 'BillItem.dart';
import 'Constants.dart';
import 'TimeLineIcon.dart';
import 'calendar/Calendar.dart';
import 'database/DBManager.dart';
import 'database/DbHelper.dart';
import 'database/classify.dart';

class Bill extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _Bill();

}

class _Bill extends State<Bill> {
  TimeLineBillItem _currentSelected = null;
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
          id: record.id,
          type: RecordType.item,
          classifyName: classifyName,
          classifyImage: classifyImage,
          remark: record.remark,
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
          title: Text("账单"),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.today,
                color: Colors.black,),
              onPressed: () => Navigator.push( context,
                MaterialPageRoute(builder: (context) => Calendar()))
            ),
          ],
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
        TimeLineBillItem timeLineBillItem = TimeLineBillItem(recordItem: recordItem, index: index,);
        timeLineBillItem.onTap = (i) {
          doHidden();
          if(i > -1)
            _currentSelected = timeLineBillItem;
        };
        return timeLineBillItem;
      },
      itemCount: arrayOfProducts == null ? 0 : arrayOfProducts.length,
    );
  }

  void doHidden() {
    if(_currentSelected != null) {
      _currentSelected.endEdit();
    }
  }
}

class BillHeadView extends StatefulWidget {
  BillItem billItem;

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


class TimeLineBillItem extends StatefulWidget {
  BillItem recordItem;
  ValueChanged<int> onTap;
  int index;
  _TimeLineBillItemState state;

  TimeLineBillItem({Key key, this.index, this.recordItem, this.onTap}):
        assert(index != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = _TimeLineBillItemState();
    return state;
  }

  void endEdit() {
    recordItem.show = false;
    if(state != null) {
      state.setState(() {});
    }
  }

}

class _TimeLineBillItemState extends State<TimeLineBillItem> {

  @override
  Widget build(BuildContext context) {
    final recordItem = widget.recordItem;
    Widget leftWidget;
    Widget rightWidget;
    double lineHeight = 70.0;

    TextStyle remarkStyle = TextStyle(color: Colors.grey[500], fontSize: 12);
    if(RecordType.item == recordItem.type) {
      EdgeInsets padding = EdgeInsets.only(top: 25.0, bottom: 0.0);
      if (recordItem.leftAmount > 0) {
        String content = '${Utils.toCurrency(recordItem.leftAmount)} ${recordItem.classifyName}';

          leftWidget = Container(
              padding: padding,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(content, textAlign: TextAlign.right,),
                Text(recordItem.remark, textAlign: TextAlign.right, style: remarkStyle,),
              ]
          ));
        rightWidget = new Container();

      } else if (recordItem.rightAmount > 0) {
        String content = '${recordItem.classifyName} ${Utils.toCurrency(recordItem.rightAmount)}';

          rightWidget = Container(
              padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content, textAlign: TextAlign.left,),
                Text(recordItem.remark, textAlign: TextAlign.left, style: remarkStyle,),
              ]
            )
          );
        leftWidget = new Container();
      }

      return GestureDetector(
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
                  onPressed: () {
                    Utils.showConfirmDialog(context, "确定删除么？", (){
                      DBHelper.findRecordById(recordItem.id).then((record) {
                        DBHelper.deleteRecord(recordItem.id).whenComplete((){
                          Asset asset = DBManager().assets[record.account];
                          if (Constants.Income == record.type) {
                            asset.balance -= record.amount;
                          } else {
                            asset.balance += record.amount;
                          }
                          DBHelper.updateAsset(asset);
                        });
                      });
                    });
                  },
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
                  child: leftWidget
              ),
            ),
            CustomPaint(
                painter: new TimeLineIcon(
                    paintWidth: 1, //widget.timeAxisLineWidth,
                    circleSize: 0, //widget.lineToLeft,
                    lineColor: Colors.grey[300],
                    isTimeLine: true
                ),
                size: Size(40, lineHeight),
                child: GestureDetector(
                  child:
                  Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(Utils.getClassifyImage(recordItem.classifyImage),),
                    ),
                  ),
                  onTap: () {
                    if(!recordItem.show)
                      widget.onTap(widget.index);
                    setState(() {
                      recordItem.show = !recordItem.show;
                    });
                  },
                )
            ),
            Expanded(
              flex: 3,
              child: Container(
                  height: lineHeight,
                  padding: const EdgeInsets.only(left: 5.0),
                  alignment: Alignment.centerLeft,
                  child: rightWidget
              ),
            ),
            SizedBox(
              width: 30,
              height: lineHeight,
              child: Visibility(
                child: FlatButton(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Icon(Icons.edit, size: 14, color: Colors.blueAccent,),
                  onPressed: () {
                    DBHelper.findRecordById(recordItem.id).then((record){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddRecordPage(record: record,)));
                    });
                  },
                ),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: recordItem.show,
              ),
            ),
          ],
        ),
        onTap: () {
          widget.onTap(-1);
        },
      );
    } else {
      String centerText = '${recordItem.id}';
      double circleSize = 12;
      Widget widget;
      String leftText = "";
      String rightText = "";
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
                height: 40,
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
                height: 40,
                padding: const EdgeInsets.only(left: 5.0),
                alignment: Alignment.centerLeft,
                child: new Text(rightText, textAlign: TextAlign.left,)
            ),
          ),
        ],
      );
      //return new Text("");
    }
  }

}