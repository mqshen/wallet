import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';

import '../BillItem.dart';
import '../Constants.dart';
import 'MyCalendar.dart';

class Calendar extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DayRecords dayRecords = DayRecords(day: now);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("日历"),
        ),
        body: Column(
            children: [
              MyCalendar(selectedDate: now,
                  onChanged: (day) {
                    dayRecords.setDay(day);
                  },
                  firstDate: now.add(Duration(days: -365)),
                  lastDate: now
              ),
              Expanded(
                child: dayRecords
              )
            ]
        )
    );
  }
}

class DayRecords extends StatefulWidget {
  _DayRecordsState state;
  DateTime day;


  DayRecords({Key key, this.day}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = _DayRecordsState();
    return state;
  }

  void setDay(DateTime day) {
    this.day = day;
    state.refreshData();
  }
}

class _DayRecordsState extends State<DayRecords> {
  bool isPageLoading = false;
  static const double lineHeight = 48.0;

  List<BillItem> arrayOfProducts = new List();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context, int index) {
        BillItem recordItem = arrayOfProducts[index];

          String content = "";
          if (recordItem.leftAmount > 0) {
            content = '${Utils.toCurrency(recordItem.leftAmount)} ';
          } else if (recordItem.rightAmount > 0) {
            content = '-${Utils.toCurrency(recordItem.rightAmount)}';
          }
          return Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 2, bottom: 2),
            decoration: BoxDecoration(
              border: Border( bottom: BorderSide(color: Colors.grey[350])),
              color: Colors.grey[300],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(Utils.getClassifyImage(recordItem.classifyImage),
                  width: Classify.iconSize, height: Classify.iconSize,),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child:Text(recordItem.classifyName),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                      height: lineHeight,
                      padding: const EdgeInsets.only(right: 5.0),
                      alignment: Alignment.centerRight,
                      child: new Text(content, textAlign: TextAlign.right,)
                  ),
                ),
              ],
            ),
          );
      },
      itemCount: arrayOfProducts == null ? 0 : arrayOfProducts.length,
    );

  }


  void refreshData() {
    if(isPageLoading)
      return;
    isPageLoading = true;
    DBHelper.findRecordsByDay(widget.day).then((records) {
      arrayOfProducts.clear();
      List<Classify> classifies = DBManager().classifies;
      int day = -1;
      records.forEach((record) {
        DateTime dateTime = record.getOpTime();

        String classifyName = "";
        String classifyImage = "eat";
        if(record.type == Constants.TransferIn || record.type == Constants.TransferOut) {
          classifyName = "转账";
          classifyImage = "transfer";
        } else if(record.classify < classifies.length) {
          classifyName = classifies[record.classify].name;
          classifyImage = classifies[record.classify].image;
        }
        BillItem billItem = BillItem(
          id: dateTime.day,
          type: RecordType.item,
          classifyName: classifyName,
          classifyImage: classifyImage,
        );
        if(billItem.id != day) {
          day = billItem.id;
          billItem.type = RecordType.headItem;
        }
        if(record.type == Constants.Income || record.type == Constants.TransferIn) {
          billItem.leftAmount = record.amount;
        } else {
          billItem.rightAmount = record.amount;
        }
        arrayOfProducts.add(billItem);
      });
    }).whenComplete((){
      isPageLoading = false;
      setState(() {
      });
    });
  }


}