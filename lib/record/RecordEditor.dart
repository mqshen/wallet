
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';

import '../Constants.dart';
import '../NumericalKeyboard.dart';
import 'AddRecord.dart';

class RecordEditor extends StatefulWidget {
  final int opType;

  RecordEditor({Key key,this.opType}): super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordEditorState();

}

class _RecordEditorState extends State<RecordEditor> {
  String amount = "";
  bool saving = false;
  int classify = 0;

  AddRecord _addRecord;
  RecordStatus _recordStatus;

  @override
  void initState() {
    if(widget.opType == 0) {
      classify = 19;
    }
    Classify temp = DBManager().classifies[classify];
    _addRecord = AddRecord(image: temp.image, name: temp.name, amount: "0.0");
    _recordStatus = RecordStatus(date: DateTime.now(), account: 0,);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _addRecord,
        Expanded( child: ClassifyWidget(
          classifyType: widget.opType,
          onTab: (index){
            classify = index;
            Classify selectedClassify = DBManager().classifies[index];
            _addRecord.state.setState(() {
              _addRecord.image = selectedClassify.image;
              _addRecord.name = selectedClassify.name;
            });
          })
        ),
        _recordStatus,
        NumericalKeyboard(
          onKeyPressed: (key) {
            Utils.amountKeyPressed(key, amount, (result){
              amount = result;
              _addRecord.state.setState((){
                _addRecord.amount = Utils.stringToCurrency(result);
              });
            }, saveRecord);
          }
        ),
      ]
    );
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
      type: widget.opType,
      classify: classify,
      time: _recordStatus.date.millisecondsSinceEpoch,
      account: _recordStatus.account,
    );
    DBHelper.insertRecord(record).then((id) {
      Asset asset = DBManager().assets[record.account];
      if(Constants.Income == record.type) {
        asset.balance += record.amount;
      } else {
        asset.balance -= record.amount;
      }
      DBHelper.updateAsset(asset).whenComplete((){
        saving = false;
        Navigator.of(context).pop(null);
      });
    });
  }
}