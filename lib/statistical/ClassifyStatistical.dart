import 'dart:collection';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';
import 'package:wallet/widget/MyMonthPicker.dart';

import '../Constants.dart';

class ClassifyStatistical extends StatelessWidget {
  ClassifyChart _classifyChart = ClassifyChart(dateTime: DateTime.now());

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Column(
      children: [
        Container(
          child: MyMonthPicker(
            selectedDate: now,
            onChanged: (month) {
              _classifyChart.setMonth(month);
            },
            firstDate: now.add(Duration(days: -365)),
            lastDate: now
          )
        ),
        Expanded(
          child: _classifyChart,
        ),
      ],
    );
  }

}


class ClassifyChart extends StatefulWidget {
  DateTime dateTime;

  ClassifyChart({Key key, this.dateTime}): super(key: key);

  _ClassifyChart state;

  @override
  State<StatefulWidget> createState() {
    state = _ClassifyChart();
    return state;
  }


  void setMonth(DateTime month) {
    dateTime = month;
    state.refreshData();
  }

}

class _ClassifyChart extends State<ClassifyChart> {
  final List<charts.Series> seriesList = List();
  charts.PieChart chart;

  List<StatisticalItem> data;
  int totalAmount;

  _ClassifyChart():super() {
    refreshData();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Container(
            decoration: BoxDecoration(
                border: Border( bottom: BorderSide(color: Colors.grey[300]))
            ),
            child: chart,
          )
        ),
        Expanded(child: buildListView(context))
      ],
    );
  }


  Widget buildListView(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        StatisticalItem item = data[index];
        Classify classify = DBManager().classifies[item.id];
        double percent = 1;
        if(totalAmount > 0)
          percent = item.amount / totalAmount;
        return new Container(
            height: 40,
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            decoration: BoxDecoration(
                border: Border( bottom: BorderSide(color: Colors.grey[300]))
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Image.asset(Utils.getClassifyImage(classify.image), width: 26, height: 26,),
                ),
                Expanded(
                  flex: 2,
                  child: Text(classify.name, style: TextStyle(fontSize: 16),),
                ),
                Expanded(
                  flex: 3,
                  child:  new Text(Utils.toPercent(percent), style: TextStyle(fontSize: 18), textAlign: TextAlign.right,)
                ),
                Expanded(
                  flex: 4,
                  child: new Text(Utils.toCurrency(item.amount), style: TextStyle(fontSize: 18), textAlign: TextAlign.right,)
                )
              ],
            )
        );
      },
      itemCount: data == null ? 0 : data.length,
    );
  }


  void refreshData() {
    seriesList.clear();
    totalAmount = 0;
    int year = 0;
    int month = 0;
    if(widget == null) {
      DateTime now = DateTime.now();
      year = now.year;
      month = now.month;
    } else {
      year = widget.dateTime.year;
      month = widget.dateTime.month;
    }
    DBHelper.records(year, month).then((records) {
      Map<int, int> result = HashMap();
      records.forEach((record) {
        int amount = 0;
        if(result.containsKey(record.classify)) {
          amount = result[record.classify];
        }
        amount += record.amount;
        result[record.classify] = amount;
        totalAmount += amount;
      });
      final data = result.entries.map((e) => StatisticalItem(e.key, e.value)).toList();
      this.data = data;
    }).whenComplete((){
      List<charts.Series<StatisticalItem, int>> items = _createSampleData(data);
      seriesList.addAll(items);
      chart = new charts.PieChart(seriesList,
          animate: true,
          defaultRenderer: new charts.ArcRendererConfig(arcWidth: 50));
      setState(() {
      });
    });
  }


  /// Create one series with sample hard coded data.
  static List<charts.Series<StatisticalItem, int>> _createSampleData(List<StatisticalItem> data) {
    List<Classify> classifies = DBManager().classifies;

    return [
      new charts.Series<StatisticalItem, int>(
        id: '',
        domainFn: (StatisticalItem item, _) => item.id,
        measureFn: (StatisticalItem item, _) => item.amount,
        colorFn: (StatisticalItem item, _){
          int color = classifies[item.id].color;
          return Utils.toChartColor(color);
        },
        data: data,
      )
    ];
  }

}

/// Sample linear data type.
class StatisticalItem {
  final int id;
  final int amount;

  StatisticalItem(this.id, this.amount);
}
