
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';

import '../Bill.dart';
import '../Constants.dart';

class AssetDetail extends StatefulWidget {
  int assetId;
  int year;

  AssetDetail({Key key, this.assetId}): super(key: key) {
    year = DateTime.now().year;
  }

  @override
  State<StatefulWidget> createState() => _AssetDetailState();

}

class _AssetDetailState extends State<AssetDetail> {
  static const double lineHeight = 48.0;
  int spend = 0;
  int income = 0;
  bool isPageLoading = false;
  List<BillItem> arrayOfProducts = new List();

  @override
  Widget build(BuildContext context) {
    _callAPIToGetListOfData();
    Asset asset = DBManager().assets[widget.assetId];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Utils.toColor(asset.color),//Colors.white,
          title: Text(asset.name),
          elevation: 0,
        ),
        body: Column (
          children: [
          Container(
            color: Utils.toColor(asset.color),
              padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Container (
                  padding: EdgeInsets.all(20),
                    child: Column(
                        children:[
                          Text(Utils.toCurrency(asset.balance), style: TextStyle(fontSize: 30, color: Colors.white), ),
                          Text("账户余额", style: TextStyle(fontSize: 8, color: Colors.white),),
                        ]
                    )
                ),
                Row(
                  children: [
                    Expanded (
                      flex: 3,
                      child: Text('${widget.year}', style: TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,),
                    ),
                    Expanded (
                      flex: 3,
                      child: Column (
                        children: [
                          Text(Utils.toCurrency(spend), style: TextStyle(fontSize: 20, color: Colors.white),),
                          Text("流出", style: TextStyle(fontSize: 8, color: Colors.white),),
                        ],
                      ),
                    ),
                    Expanded (
                      flex: 3,
                      child: Column (
                        children: [
                          Text(Utils.toCurrency(income), style: TextStyle(fontSize: 20, color: Colors.white),),
                          Text("流入", style: TextStyle(fontSize: 8, color: Colors.white),),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )
            ),
            Expanded(
              child: buildListView(context),
            )
          ],
        )
    );
  }



  Widget buildListView(BuildContext context) {

    return new ListView.builder(
//      controller: controller,
      itemBuilder: (BuildContext context, int index) {
        BillItem recordItem = arrayOfProducts[index];
        if(RecordType.month == recordItem.type) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      alignment: Alignment.center,
                      child: Text("${recordItem.id}月", textAlign: TextAlign.center,)
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      alignment: Alignment.centerLeft,
                      child: Column(
                          children: [
                            Text('流入：${Utils.toCurrency(recordItem.leftAmount)}', ),
                            Text('流出：${Utils.toCurrency(recordItem.rightAmount)}'),
                          ]
                      )
                  ),
                ),
              ],
            )
          );
        } else {
          String content = "";
          if (recordItem.leftAmount > 0) {
            content = '${Utils.toCurrency(recordItem.leftAmount)} ';
          } else if (recordItem.rightAmount > 0) {
            content = '-${Utils.toCurrency(recordItem.rightAmount)}';
          }
          return Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all( 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 50,
                  height: lineHeight,
                  child: Visibility(
                    child: Center(child: Text("${recordItem.id}日")),
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: recordItem.type == RecordType.headItem,
                  ),
                ),
                Image.asset(Utils.getClassifyImage(recordItem.classifyImage),
                  width: Classify.iconSize, height: Classify.iconSize,),
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child:Text(recordItem.classifyName),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                      height: lineHeight,
                      padding: const EdgeInsets.only(right: 5.0),
                      alignment: Alignment.centerRight,
                      child: new Text(content, textAlign: TextAlign.right,)
                  ),
                ),
              ],
            ),
          );
        }
      },
      itemCount: arrayOfProducts == null ? 0 : arrayOfProducts.length,
    );
  }


  void _callAPIToGetListOfData() {
    if(isPageLoading)
      return;
    isPageLoading = true;
    print(widget.assetId);
    DBHelper.findRecordsByYearAndAccount(widget.year, widget.assetId).then((records) {
      List<Classify> classifies = DBManager().classifies;
      BillItem monthItem = BillItem(
        type: RecordType.month,
      );
      int day = -1;
      records.forEach((record) {
        DateTime dateTime = record.getOpTime();
        if(dateTime.month != monthItem.id) {
          monthItem.id = dateTime.month;
          arrayOfProducts.add(monthItem);
        }

        String classifyName = "";
        String classifyImage = "eat";
        if(record.classify < classifies.length) {
          classifyName = classifies[record.classify].name;
          classifyImage = classifies[record.classify].image;
        }
        BillItem billItem = BillItem(
          id: dateTime.day,
          type: RecordType.item,
          classifyName: classifyName,
          classifyImage: classifyImage,
        );
        if(billItem.id != day) {
          billItem.type = RecordType.headItem;
        }
        if(record.type == 0) {
          income += record.amount;
          monthItem.leftAmount += record.amount;
          billItem.leftAmount = record.amount;
        } else {
          spend += record.amount;
          monthItem.rightAmount += record.amount;
          billItem.rightAmount = record.amount;
        }
        arrayOfProducts.add(billItem);
      });
//      if(arrayOfProducts.length > 0 && _billHeadView.billItem == null) {
//        _billHeadView.state.setState((){
//          _billHeadView.billItem = arrayOfProducts[0];
//        });
//      }
    }).whenComplete((){
//      isPageLoading = false;
      setState(() {
      });
    });
  }

}