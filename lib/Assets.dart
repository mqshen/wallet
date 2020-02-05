import 'package:flutter/material.dart';

import 'Constants.dart';
import 'database/DBManager.dart';
import 'database/classify.dart';

class Assets extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return _assets();
  }


  ListView _assets() {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        Asset asset =  DBManager().assets[index];
        return Container(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 10, right: 10),
            child: Container(
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        stops: [0.02, 0.02],
                        colors: [Color(Constants.borderColorAlpha | Constants.colors[asset.color]),
                          Color(Constants.backgroundColorAlpha | Constants.colors[asset.color])]
                    ),
                    borderRadius: new BorderRadius.all(const Radius.circular(6.0))),
                child: Row (
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20.0, right: 10.0, top: 16, bottom: 16),
                        child:Image.asset('images/icon_${asset.image}.png', width: 38, height: 38,),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(asset.name, style: TextStyle(fontSize: 16, color: Colors.white),),
                          Text(asset.description, style: TextStyle(fontSize: 12, color: Colors.white70),)
                        ],
                      ),
                      Expanded(
                          flex: 6,
                          child: Container(
                              padding: const EdgeInsets.only(right: 10.0),
                              alignment: Alignment.centerRight,
                              child: Text(Utils.toCurrency(asset.balance), style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.right,)
                          )
                      )
                    ]
                )
            )
        );
      },
      itemCount: DBManager().assets.length,
    );
  }
}