import 'package:flutter/material.dart';

import 'ClassifyStatistical.dart';
import 'TrendStatistical.dart';

class Statistical extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _Statistical();

}

class _Statistical extends State<Statistical> with SingleTickerProviderStateMixin{
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TabBar(
          unselectedLabelColor: Colors.black12,
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: [
            new Tab(icon: new Text("分类")),
            new Tab(icon: new Text("趋势")),
            new Tab(icon: new Text("成员")),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          ClassifyStatistical(),
          TrendStatistical(),
          new Text("This is notification Tab View"),
        ],
        controller: _tabController,
      )

    );
  }

}
