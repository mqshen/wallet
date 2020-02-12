
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';
import 'package:wallet/widget/AssetPicker.dart';

import '../Constants.dart';
import '../NumericalKeyboard.dart';
import 'AddRecord.dart';

class TransferPage extends StatelessWidget {
  String amount = "";
  bool saving = false;
  RecordStatus _recordStatus;
  BuildContext myContext;
  TransferItem _sourceItem;
  TransferItem _targetItem;

  @override
  Widget build(BuildContext context) {
    String amountStr = Utils.stringToCurrency(amount);
    _sourceItem = TransferItem(accountType: 0, amount: amountStr,);
    _targetItem = TransferItem(accountType: 1, amount: amountStr,);
    _recordStatus = RecordStatus(date: DateTime.now(), account: -1,);
    myContext = context;
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              _sourceItem,
              _targetItem
            ]
          )
        ),
        _recordStatus,
        NumericalKeyboard(
          onKeyPressed: (key) {
            Utils.amountKeyPressed(key, amount, (result){
              amount = result;
              String temp = Utils.stringToCurrency(result);
              _sourceItem.state.setState((){
                _sourceItem.amount = temp;
              });
              _targetItem.state.setState((){
                _targetItem.amount = temp;
              });
            }, saveRecord);
          }
        )
      ],
    );
  }

  void saveRecord() {
    if (saving)
      return;
    saving = true;
    int count = Utils.stringToInt(amount);
    if(0 == count)
      return;
    Record sourceRecord = Record(
      amount: count,
      type: Constants.TransferOut,
      classify: 1,
      time: _recordStatus.date.millisecondsSinceEpoch,
      account: _sourceItem.assetId,
    );
    DBHelper.insertRecord(sourceRecord).then((id) {
      Asset asset = DBManager().assets[sourceRecord.account];
      asset.balance -= sourceRecord.amount;
      DBHelper.updateAsset(asset).then((id) {
        Record targetRecord = Record(
          amount: count,
          type: Constants.TransferIn,
          classify: 1,
          time: _recordStatus.date.millisecondsSinceEpoch,
          account: _targetItem.assetId,
        );

        DBHelper.insertRecord(targetRecord).then((id) {
          Asset asset = DBManager().assets[targetRecord.account];
          asset.balance += sourceRecord.amount;
          DBHelper.updateAsset(asset).whenComplete(() {
            Navigator.of(myContext).pop(null);
          });
        });

      });
    });
  }
}


class TransferItem extends StatefulWidget {
  final int accountType;
  int assetId;
  String amount;
  _TransferItemState state;

  TransferItem({Key key, this.accountType, this.assetId = -1, this.amount = "0.00"}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = _TransferItemState();
    return state;
  }

}

class _TransferItemState extends State<TransferItem> {
  double lineHeight = 60;
  @override
  Widget build(BuildContext context) {
    List<Widget> content = List();
    Color fontColor = Colors.white;
    Color backgroundColor = Colors.white;
    BoxDecoration border;

    if(widget.assetId == -1) {
      fontColor = Colors.black;
      border = BoxDecoration(
        borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
        border: Border.all(color: Colors.grey[300]),
        color: backgroundColor,
      );
      String tips;
      if (widget.accountType == 0) {
        tips = "转出账户";
      } else  {
        tips = "转入账户";
      }
      content.add(
        SizedBox(
          width: 100,
          height: lineHeight,
          child: Center(child: Text(tips, style: TextStyle(fontSize: 16, color: fontColor)))
        )
      );
    } else {
      fontColor = Colors.white;
      Asset asset = DBManager().assets[widget.assetId ];
      backgroundColor = Utils.toColor(asset.color);
      border = BoxDecoration(
        borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
        color: backgroundColor,
      );
      content.add(
        SizedBox(
          width: 60,
          height: lineHeight,
          child: Center(
            child: Image.asset(Utils.getIconImage(asset.image), width: 38, height: 38,),
          )
        )
      );
      content.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(asset.name, style: TextStyle(fontSize: 16, color: fontColor),),
          Text(asset.description, style: TextStyle(fontSize: 12, color: fontColor),)
        ],
      ));
    }

    content.add(Expanded(
        flex: 6,
        child: Container(
            padding: const EdgeInsets.only(right: 10.0),
            alignment: Alignment.centerRight,
            child: Text(widget.amount,
              style: TextStyle(fontSize: 30, color: fontColor),
              textAlign: TextAlign.right,)
        )
    ));
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 10, right: 10),
        child: Container(
          decoration: border,
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: content,
          )
        )
      ),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return AssetPicker(selected: widget.assetId, onTap: (index) {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {
                widget.assetId = index;
              });
            },);
          },
        );
      },
    );

  }

}