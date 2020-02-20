import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/classify.dart';
import 'package:wallet/widget/AssetPicker.dart';

import '../Constants.dart';

class AddRecord extends StatefulWidget {
  String image;
  String name;
  String amount;
  final State<StatefulWidget> state = _AddRecord();

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
    String amount = widget.amount;
    if(amount.length == 0) {
      amount = "0.00";
    }
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
              child: Image.asset(Utils.getClassifyImage(widget.image), width: 40, height: 40,),
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
                  child: new Text(amount, style: TextStyle(fontSize: 30), textAlign: TextAlign.right,)
              ),
            )
          ],
        )
    );
  }

}


class ClassifyWidget extends StatelessWidget {

  final int classifyType;
  final ValueChanged<int> onTab;

  ClassifyWidget({ Key key, this.classifyType, this.onTab}):super(key: key);

  @override
  Widget build(BuildContext context) {
    final _buttons = <Widget>[];
    DBManager().classifies.where((c) => classifyType == c.type).forEach((classify) {
      _buttons.add(
          new Container(
              width: 65,
              height: 65,
              child: FlatButton(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(
                  children: <Widget>[
                    Image.asset(Utils.getClassifyImage(classify.image), width: Classify.iconSize, height: Classify.iconSize,),
                    Text(classify.name),
                  ],
                ),
                onPressed: () {
                  if(onTab != null)
                    onTab(classify.id);
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
  int account;
  VoidCallback remarkShow;


  RecordStatus({ Key key,
    this.date,
    this.account,
    this.remarkShow
  }):super(key: key);

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
    List<Widget> content = new List();
    content.add(Container(
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
    ));
    if(widget.account > -1) {
      content.add(Container(
          height: 30,
          child: FlatButton(
            color: Colors.white,
            textColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(15.0),
                side: BorderSide(color: Colors.blue)
            ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return AssetPicker(selected: widget.account, onTap: (index) {
                    Navigator.of(context, rootNavigator: true).pop();
                    setState(() {
                      widget.account = index;
                    });
                  },);
                },
              );
            },
            child: Text(DBManager().assets[widget.account].name,
              style: TextStyle(fontSize: 12.0),),
          )
      ));
    }

    content.add(Expanded(
      flex: 2,
      child: IconButton(
        padding: const EdgeInsets.only(right: 10.0),
        alignment: Alignment.centerRight,
        icon: Icon(Icons.edit),
        onPressed: () {
          widget.remarkShow();
        },
      ),
    ));


    return new Container(
        height: 50,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border(
                top: BorderSide(color: Colors.grey[300]),
                bottom: BorderSide(color: Colors.grey[300])
            )
        ),
        child: Row(
          children: content
        )
    );
  }

}
