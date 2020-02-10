
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/classify.dart';

import '../Constants.dart';

class AssetPicker extends StatefulWidget {
  int selected;
  ValueChanged<int> onTap;

  AssetPicker({this.selected, this.onTap});

  @override
  State<StatefulWidget> createState() => _AssetPickerState();

}

class _AssetPickerState extends State<AssetPicker> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
        child: SizedBox(
      height: 200,
    child: Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border( bottom: BorderSide(color: Colors.grey[300]))
          ),
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: Center(
              child: Text("选择账户", style: TextStyle(fontSize: 16, color: Colors.black, decoration: TextDecoration.none)),
            )
          )
        ),
        Expanded(
        child: new ListView.builder(
          padding: EdgeInsets.all(0),
          itemBuilder: (BuildContext context, int index) {
            Asset asset =  DBManager().assets[index];
            return GestureDetector(
              child: Row (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5, bottom: 5),
                    child:Image.asset('images/icon_${asset.image}.png', width: 30, height: 30,),
                  ),
                  Expanded(
                    flex: 8,
                    child: new Container(
                      decoration: BoxDecoration(
                          border: Border( bottom: BorderSide(color: Colors.grey[300]))
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(asset.name, style: TextStyle(fontSize: 16, color: Colors.black, decoration: TextDecoration.none),),
                                Text('余额：${Utils.toCurrency(asset.balance)}', style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.none),)
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Visibility(
                                child: Icon(Icons.done, size: 14, color: Colors.blue,),
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              visible: index == widget.selected,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]
              ),
              onTap: () {
                setState(() {
                  widget.selected = index;
                });
                widget.onTap(index);
              },
            );
          },
          itemCount: DBManager().assets.length,
        )
        )
      ],
    )
        )
    );
  }

}