import 'dart:collection';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wallet/database/DBManager.dart';
import 'package:wallet/database/DbHelper.dart';
import 'package:wallet/database/classify.dart';
import 'package:wallet/widget/MyPicker.dart';

import '../Constants.dart';

class TrendStatistical extends StatelessWidget {
  TrendChart _trendChart = TrendChart(year: DateTime.now().year);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Column(
      children: [
        Container(
            child: MyPicker(
                selectedValue: now.year,
                onChanged: (month) {
                  _trendChart.setYear(month);
                },
                firstValue: now.year - 5,
                lastValue: now.year
            )
        ),
        Expanded(
          child: _trendChart,
        ),
      ],
    );
  }

}

class TrendChart extends StatefulWidget {
  int year;
  _TrendChartState state;


  TrendChart({this.year});

  @override
  State<StatefulWidget> createState() {
    state = _TrendChartState();
    return state;
  }

  void setYear(int year) {
    this.year = year;
    state.refreshData();
  }
}

class _TrendChartState extends State<TrendChart> {
  bool animate = false;
  int totalAmount = 0;
  final List<charts.Series<dynamic, num>> seriesList = List();
  List<MonthStatistical> data;
  charts.LineChart chart;
//  List<StatisticalItem> data;

  _TrendChartState():super() {
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 150,
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
        String first = "月份";
        String second = "收入";
        String third = "支出";
        String fourth = "结余";
        if(index > 0) {
          MonthStatistical item = data[index];
          first = '${index + 1}月';
          second = Utils.toCurrency(item.income);
          third = Utils.toCurrency(item.spend);
          fourth = Utils.toCurrency(item.balance);
        }
        double percent = 1;
        return new Container(
            height: 40,
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            decoration: BoxDecoration(
                border: Border( bottom: BorderSide(color: Colors.grey[300]))
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(first),
                ),
                Expanded(
                  flex: 3,
                  child: Text(second),
                ),
                Expanded(
                    flex: 3,
                    child:  Text(third),
                ),
                Expanded(
                    flex: 2,
                    child: Text(fourth),
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
    if(widget == null) {
      DateTime now = DateTime.now();
      year = now.year;
    } else {
      year = widget.year;
    }

    DBHelper.findRecordsByYear(year).then((records) {
      final List<MonthStatistical> data = List.generate(12, (index){
        return MonthStatistical(id: index + 1);
      });
      records.forEach((record) {
        DateTime dateTime = record.getOpTime();
        MonthStatistical monthStatistical = data[dateTime.month - 1];
        if(record.type == 0) {
          monthStatistical.income += record.amount;
        } else if(record.type == 1) {
          monthStatistical.spend += record.amount;
        }
      });
//      final data = result.entries.map((e) => StatisticalItem(e.key, e.value)).toList();
      this.data = data;
    }).whenComplete(() {
      List<charts.Series<MonthStatistical, int>> items = _createSampleData();
      chart = new charts.LineChart(seriesList,
        animate: animate,
          domainAxis: new charts.NumericAxisSpec(
            showAxisLine: false,
              tickFormatterSpec: new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
                  new NumberFormat("#,##0月", "en_US")
              )
          )
      );
      setState(() {
        seriesList.addAll(items);
      });
    });
  }


  /// Create one series with sample hard coded data.
  List<charts.Series<MonthStatistical, int>> _createSampleData() {

    return [
      new charts.Series<MonthStatistical, int>(
        id: '收入',
        colorFn: (_, __) => Utils.toChartColor(0x84C5AC),
        domainFn: (MonthStatistical sales, _) => sales.id,
        measureFn: (MonthStatistical sales, _) => sales.income / 100,
        data: data,
      ),
      new charts.Series<MonthStatistical, int>(
        id: '支出',
        colorFn: (_, __) => Utils.toChartColor(0x5D76E2),
        domainFn: (MonthStatistical sales, _) => sales.id,
        measureFn: (MonthStatistical sales, _) => sales.spend / 100,
        data: data,
      ),
      new charts.Series<MonthStatistical, int>(
          id: '余额',
          colorFn: (_, __) => Utils.toChartColor(0xDC696B),
          domainFn: (MonthStatistical sales, _) => sales.id,
          measureFn: (MonthStatistical sales, _) => sales.balance / 100,
          data: data)
    ];
  }
}
/// Sample linear data type.
class MonthStatistical {
  final int id;
  int income;
  int spend;
  int balance;

  MonthStatistical({this.id , this.income = 0, this.spend = 0, this.balance = 0});
}