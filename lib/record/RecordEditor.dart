
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';

import '../Constants.dart';
import '../NumericalKeyboard.dart';
import 'AddRecord.dart';

class RecordEditor extends StatefulWidget {
  final int opType;
  Record record;

  RecordEditor({Key key, this.opType, this.record}): super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordEditorState();

}

class _RecordEditorState extends State<RecordEditor> {
  String amount;
  String remark = "";
  DateTime time;
  bool saving = false;
  int classify = 0;
  int account = 0;

  AddRecord _addRecord;
  RecordStatus _recordStatus;
  TextEditingController myController;

  @override
  void initState() {
    if(widget.opType == 0) {
      classify = 19;
    }
    if(widget.record != null) {
      classify = widget.record.classify;
      amount = Utils.toCurrency(widget.record.amount);
      remark = widget.record.remark;
      time = widget.record.getOpTime();
      account = widget.record.account;
    } else {
      time = DateTime.now();
      amount = "";
    }
    Classify temp = DBManager().classifies[classify];
    _addRecord = AddRecord(image: temp.image, name: temp.name, amount: amount);
    _recordStatus = RecordStatus(
        date: time,
        account: account,
        remarkShow: _showDialog);
    myController = TextEditingController(text: remark);
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


  _showDialog() async {
    await showDialog<String>(
        context: context,
        builder: (context) {
          TextField input = new TextField(
            autofocus: true,
            controller: myController,
            decoration: new InputDecoration(
                labelText: '备注', hintText: '请输入备注'),
          );
          return //new _SystemPadding(child:
          new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: input,
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('确定'),
                  onPressed: () {
                    remark = myController.text;
                    Navigator.pop(context);
                  })
            ],
          //),
          );
        }
    );
  }

  void saveRecord() {
    if(saving)
      return;
    saving = true;
    int count = Utils.stringToInt(amount);
    if(0 == count)
      return;
    if(widget.record != null) {
      int oldAccount = widget.record.account;
      int oldAmount = widget.record.amount;

      widget.record.amount = count;
      widget.record.classify = classify;
      widget.record.time = _recordStatus.date.millisecondsSinceEpoch;
      widget.record.account = _recordStatus.account;
      widget.record.remark = remark;

      DBHelper.updateRecord(widget.record).whenComplete(() {
        Asset oldAsset = DBManager().assets[oldAccount];
        if (Constants.Income == widget.opType) {
          oldAsset.balance -= oldAmount;
        } else {
          oldAsset.balance += oldAmount;
        }

        Asset asset = DBManager().assets[_recordStatus.account];
        if (Constants.Income == widget.opType) {
          asset.balance += oldAmount;
        } else {
          asset.balance -= oldAmount;
        }

        if (oldAccount != _recordStatus.account) {
          DBHelper.updateAsset(oldAsset).whenComplete(() {
            DBHelper.updateAsset(asset).whenComplete(() {
              saving = false;
              Navigator.of(context).pop(null);
            });
          });
        } else {
          DBHelper.updateAsset(asset).whenComplete(() {
            saving = false;
            Navigator.of(context).pop(null);
          });
        }
      });
    } else {
      Record record = Record(
          amount: count,
          type: widget.opType,
          classify: classify,
          time: _recordStatus.date.millisecondsSinceEpoch,
          account: _recordStatus.account,
          remark: remark
      );
      DBHelper.insertRecord(record).then((id) {
        Asset asset = DBManager().assets[record.account];
        if (Constants.Income == record.type) {
          asset.balance += record.amount;
        } else {
          asset.balance -= record.amount;
        }
        DBHelper.updateAsset(asset).whenComplete(() {
          saving = false;
          Navigator.of(context).pop(null);
        });
      });
    }
  }
}


class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
