import 'package:flutter/material.dart';

import 'ButtonGroup.dart';
import 'Constants.dart';
import 'NumericalKeyboard.dart';
import 'database/DBManager.dart';
import 'database/DbHelper.dart';
import 'database/classify.dart';

class AddRecordPage extends StatelessWidget {
  String amount = "";
  int classify = 0;
  bool saving = false;
  BuildContext context;

  ButtonGroup _buttonGroup = ButtonGroup(
    titles: ["收入", "支出", "转账"],
    color: Colors.blue,
    secondaryColor: Colors.white,
    current: 1,
  );

  AddRecord _addRecord = AddRecord(image: "eat", name: "餐饮", amount: "0.0");
  RecordStatus _recordStatus = RecordStatus(date: DateTime.now(), account: '现金',);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _buttonGroup,
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.close,
              color: Colors.black,),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        leading: new Container(),
      ),
      body: Column(
        children: [
          _addRecord,
          Expanded( child: ClassifyWidget(onTab: (index){
            classify = index;
            Classify selectedClassify = DBManager().classifies[index];
            _addRecord.state.setState(() {
              _addRecord.image = selectedClassify.image;
              _addRecord.name = selectedClassify.name;
            });
          })),
          _recordStatus,
          NumericalKeyboard(
              onKeyPressed: amountKeyPressed
          ),
        ]
      )
    );
  }


  void amountKeyPressed(int key) {
    if(key == NumericalKeyboard.confirmKey) {
      saveRecord();
    } else {
      if (key == NumericalKeyboard.clearKey) {
        amount = "";
      } else if (key == NumericalKeyboard.backspaceKey) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        int index = amount.indexOf("\.");
        if (key == NumericalKeyboard.pointKey) {
          if(index < 0)
            amount = '${amount}.';
        } else if(amount.length - index < 3) {
          amount = '${amount}${key}';
        }
      }
      _addRecord.state.setState((){
        _addRecord.amount = Utils.stringToCurrency(amount);
      });
    }
  }

  void saveRecord() {
    if(saving)
      return;
    saving = true;
    int count = Utils.stringToInt(amount);
    if(0 == count)
      return;
    Record record = Record(
      amount: count,
      type: _buttonGroup.current,
      classify: classify,
      time: _recordStatus.date.millisecondsSinceEpoch,
      account: 0, //_recordStatus.account,
    );
    DBHelper.insertRecord(record).whenComplete((){
      saving = false;
      Navigator.of(context).pop(null);
    });
  }

}


class AddRecord extends StatefulWidget {
  String image;
  String name;
  String amount;
  final State<StatefulWidget> state = _AddRecord();

  static _AddRecord of(BuildContext context) => context.findAncestorStateOfType<_AddRecord>();

  AddRecord({
    Key key,
    this.image,
    this.name,
    this.amount,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }

}

class _AddRecord extends State<AddRecord> {

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 60,
      padding: EdgeInsets.only(left: 5.0, right: 10.0),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey)
        )
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Image.asset('images/classify_${widget.image}.png', width: 40, height: 40,),
          ),
          Expanded(
            flex: 2,
            child: Text(widget.name, style: TextStyle(fontSize: 20),),
          ),
          Expanded(
            flex: 6,
            child: Container (
                padding: const EdgeInsets.only(right: 10.0),
                alignment: Alignment.centerRight,
                child: new Text(widget.amount, style: TextStyle(fontSize: 30), textAlign: TextAlign.right,)
            ),
          )
        ],
      )
    );
  }

}


class ClassifyWidget extends StatelessWidget {

  final ValueChanged<int> onTab;

  ClassifyWidget({ Key key, this.onTab}):super(key: key);

  @override
  Widget build(BuildContext context) {
    final _buttons = <Widget>[];
    DBManager().classifies.asMap().forEach((index, classify) {
      _buttons.add(
          new Container(
              width: 65,
              height: 65,
              child: FlatButton(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(
                  children: <Widget>[
                    Image.asset('images/classify_${classify.image}.png', width: Classify.iconSize, height: Classify.iconSize,),
                    Text(classify.name),
                  ],
                ),
                onPressed: () {
                  if(onTab != null)
                    onTab(index);
                },
              )
          )
      );
    });
    return Wrap(
      children: _buttons,
    );
  }
}

//class _ClassifyWidget extends State<ClassifyWidget> {
//
//  @override
//  Widget build(BuildContext context) {
//
//  }
//
//}


class RecordStatus extends StatefulWidget {
  DateTime date;
  String account;


  RecordStatus({ Key key,
    this.date,
    this.account}):super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordStatus();

}

class _RecordStatus extends State<RecordStatus> {

  //DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) {
    showDatePicker(
        context: context,
        initialDate: widget.date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)).then((picked){
      if (picked != null && picked != widget.date)
        setState(() {
          widget.date = picked;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 50,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
            border: Border(
                top: BorderSide(color: Colors.grey),
                bottom: BorderSide(color: Colors.grey)
            )
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: 30,
              padding: EdgeInsets.only(right: 10.0),
              child: FlatButton(
                color: Colors.white,
                textColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.blue)
                ),
                onPressed: () {
                  _selectDate(context);
                },
                child: Text(Utils.formatDate(widget.date), style: TextStyle(fontSize: 12.0), ),
              )
            ),
            Container(
              height: 30,
              child: FlatButton(
                color: Colors.white,
                textColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    side: BorderSide(color: Colors.blue)
                ),
                onPressed: () {
                },
                child: Text(widget.account, style: TextStyle(fontSize: 12.0), ),
              )
            ),
            Expanded(
              flex: 2,
              child: IconButton(
                  padding: const EdgeInsets.only(right: 10.0),
                  alignment: Alignment.centerRight,
                icon: Icon(Icons.edit),
              ),
            )
          ],
        )
    );
  }

}
