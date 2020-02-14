import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/database/classify.dart';


import '../Constants.dart';
import 'RecordEditor.dart';
import 'Transfer.dart';

class AddRecordPage extends StatefulWidget {
  Record record;

  AddRecordPage({Key key, this.record}): super(key: key);

  @override
  State<StatefulWidget> createState() => _AddRecordPageSate();

}

class _AddRecordPageSate extends State<AddRecordPage> with SingleTickerProviderStateMixin {
//  ButtonGroup _buttonGroup ;

  TabController _tabController;

  @override
  void initState() {
    int index = 1;
    if(widget.record != null) {
      index = widget.record.type;
    }
    _tabController = new TabController(initialIndex: index, length: 3, vsync: this);
    super.initState();
  }

  Widget build(BuildContext context) {
    Record incomeRecord;
    Record spendRecord;
    if(widget.record != null ) {
      if(Constants.Income == widget.record.type ) {
        incomeRecord = widget.record;
      } else {
        spendRecord = widget.record;
      }
    }
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
            RecordEditor(opType: 0, record: incomeRecord),
            RecordEditor(opType: 1, record: spendRecord),
            TransferPage()
          ],
          controller: _tabController,
        )

    );
  }



}

