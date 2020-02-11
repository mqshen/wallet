import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/widget/AssetPicker.dart';

import '../widget/ButtonGroup.dart';
import '../Constants.dart';
import '../NumericalKeyboard.dart';
import '../database/DBManager.dart';
import '../database/DbHelper.dart';
import '../database/classify.dart';
import 'RecordEditor.dart';

class AddRecordPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _AddRecordPageSate();

}

class _AddRecordPageSate extends State<AddRecordPage> with SingleTickerProviderStateMixin {

//  ButtonGroup _buttonGroup ;

  TabController _tabController;

  @override
  void initState() {
//    _buttonGroup = ButtonGroup(
//      titles: ["收入", "支出", "转账"],
//      color: Colors.blue,
//      secondaryColor: Colors.white,
//      current: 1,
//      onTab: (index) {
//        if(_tabController != null) {
//          _tabController.animateTo(index);
//        }
//      },
//    );
    _tabController = new TabController(initialIndex: 1, length: 3, vsync: this);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title:  TabBar(
            unselectedLabelColor: Colors.black12,
            labelColor: Colors.blue,
            controller: _tabController,
            tabs: [
              new Tab(icon: new Text("收入")),
              new Tab(icon: new Text("支出")),
              new Tab(icon: new Text("转账")),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.close,
                color: Colors.black,),
              onPressed: () => Navigator.of(context).pop(null),
            ),
          ],
          leading: new Container(),
        ),
        body: TabBarView(
          children: [
            RecordEditor(opType: 0),
            RecordEditor(opType: 1),
            new Text("This is notification Tab View"),
          ],
          controller: _tabController,
        )

    );
  }



}


