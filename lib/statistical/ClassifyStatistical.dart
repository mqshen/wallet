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
  PieChartView pieChartView;

  List<StatisticalItem> data;
  int totalAmount = 0;
  int type = 1;
  String title  = "";

  @override
  void initState() {
    pieChartView = PieChartView(title: title, data: new List(), totalAmount: totalAmount, callback: (){
      type ^= 1;
      refreshData();
    },);
    refreshData();
  }
//  _ClassifyChart():super() {
//  }

  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        SizedBox(
          height: 250,
          child: pieChartView
        ),
        Expanded(child: buildListView(context))
      ],
    );
  }


  Widget buildListView(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        StatisticalItem item = data[index];
        return StatisticalRow(item: item, totalAmount: totalAmount, callback: () {
          updatePieChart();
          setState((){});
        });
      },
      itemCount: data == null ? 0 : data.length,
    );
  }

  void updatePieChart() {
    List<StatisticalItem> result = data.where((x) => x.show).toList();
    totalAmount = 0;
    result.forEach((record) {
      totalAmount += record.amount;
    });
    pieChartView.data = result;
    pieChartView.title = title;
    pieChartView.totalAmount = totalAmount;
    pieChartView.refresh();
  }


  void refreshData() {
    if(type == 0) {
      title = "总收入";
    } else {
      title = "总支出";
    }
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
    DBHelper.recordsByType(year, month, type).then((records) {
      Map<int, int> result = HashMap();
      records.forEach((record) {
        int amount = 0;
        if(result.containsKey(record.classify)) {
          amount = result[record.classify];
        }
        amount += record.amount;
        result[record.classify] = amount;
        totalAmount += record.amount;
      });
      final data = result.entries.map((e) => StatisticalItem(id: e.key, amount: e.value))
          .toList();
      data.sort((x, y) => y.amount - x.amount);
      this.data = data;
    }).whenComplete((){
//      List<charts.Series<StatisticalItem, int>> items = _createSampleData(data);
//      seriesList.addAll(items);
//      chart = new charts.PieChart(seriesList,
//          animate: true,
//          defaultRenderer: new charts.ArcRendererConfig(arcWidth: 50));
      updatePieChart();
      setState(() {
      });
    });
  }




}

/// Sample linear data type.
class StatisticalItem {
  final int id;
  final int amount;
  bool show;

  StatisticalItem({this.id, this.amount, this.show = true});
}

class StatisticalRow extends StatefulWidget {
  StatisticalItem item;
  int totalAmount;
  VoidCallback callback;


  StatisticalRow({Key key, this.item, this.totalAmount, this.callback}): super(key: key);

  @override
  State<StatefulWidget> createState() => _StatisticalRowState();

}

class _StatisticalRowState extends State<StatisticalRow> {

  @override
  Widget build(BuildContext context) {
    Classify classify = DBManager().classifies[widget.item.id];
    String percent;

    Color backgroundColor ;
    Color textColor ;

    if(widget.item.show) {
      backgroundColor = Colors.white;
      textColor = Colors.black;
      percent = Utils.toPercent(widget.item.amount / widget.totalAmount);
    } else {
      backgroundColor = Colors.grey[300];
      textColor = Colors.grey;
      percent = '';
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.item.show = !widget.item.show;
          widget.callback();
        });
      },
      child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          decoration: BoxDecoration(
              color: backgroundColor,
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
                child: Text(classify.name, style: TextStyle(fontSize: 16, color: textColor),),
              ),
              Expanded(
                  flex: 3,
                  child: Text(percent,
                    style: TextStyle(fontSize: 18, color: textColor),
                    textAlign: TextAlign.right,)
              ),
              Expanded(
                  flex: 4,
                  child: Text(Utils.toCurrency(widget.item.amount),
                    style: TextStyle(fontSize: 18, color: textColor),
                    textAlign: TextAlign.right,)
              )
            ],
          )
      )
    );
  }

}

class PieChartView extends StatefulWidget {
  String title;
  int totalAmount;
  List<StatisticalItem> data;
  VoidCallback callback;
  _PieChartState state;

  PieChartView({Key key, this.title, this.totalAmount, this.data, this.callback}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = _PieChartState();
    return state;
  }

  void refresh() {
    state.refresh();
  }

}

class _PieChartState extends State<PieChartView> {
  charts.PieChart chart;

  final List<charts.Series> seriesList = List();

  @override
  void initState() {
    if(widget.data != null && widget.data.length > 0) {
      refresh();
    }
    super.initState();
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

  void refresh() {
    setState((){
      seriesList.clear();
      List<charts.Series<StatisticalItem, int>> items = _createSampleData(widget.data);
      seriesList.addAll(items);
      chart = new charts.PieChart(seriesList,
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(arcWidth: 50));

    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border( bottom: BorderSide(color: Colors.grey[300]))
            ),
            child: chart,
          ),
          Positioned(
              child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(widget.title, style: TextStyle(fontSize: 12),),
                        Text(Utils.toCurrency(widget.totalAmount), style: TextStyle(fontSize: 18),),
                        Icon(Icons.loop, color: Colors.grey[300], size: 16,)
                      ],
                    ),
                    onTap: () {
                      widget.callback();
                    },
                  )
              )
          ),
        ]
    );
  }

}
