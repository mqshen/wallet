
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/classify.dart';

import '../Constants.dart';

class TransferPage extends StatelessWidget {
  int amount;
  int sourceAsset = -1;
  int targetAsset = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }

  Widget getAccount(int type) {
    List<Widget> content = List();
    if(type == 0 && sourceAsset == -1) {
      content.add(Text("转出账户"));
    } else if(type == 1 && targetAsset == -1) {
      content.add(Text("转入账户"));
    } else {
      Asset asset;
      if(type == 0) {
        asset = DBManager().assets[sourceAsset];
      } else {
        asset = DBManager().assets[targetAsset];
      }
      content.add(Container(
        padding: EdgeInsets.only(
            left: 20.0, right: 10.0, top: 16, bottom: 16),
        child: Image.asset(
          'images/icon_${asset.image}.png', width: 38, height: 38,),
      ));
      content.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(asset.name, style: TextStyle(fontSize: 16, color: Colors.white),),
          Text(asset.description, style: TextStyle(fontSize: 12, color: Colors.white70),)
        ],
      ));
    }

    content.add(Expanded(
        flex: 6,
        child: Container(
            padding: const EdgeInsets.only(right: 10.0),
            alignment: Alignment.centerRight,
            child: Text(Utils.toCurrency(amount), style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.right,)
        )
    ));
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 10, right: 10),
          child: Container(
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
                border: Border.all(color: Colors.grey[300])
              ),
              child: Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: content,
              )
          )
      ),
      onTap: () {

      },
    );
  }
}

