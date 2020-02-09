import 'package:flutter/material.dart';

import '../Constants.dart';

class CircleProcessor extends StatelessWidget {
  final double value;
  final double size;
  final int amount;

  CircleProcessor({this.value, this.size, this.amount});

  @override
  Widget build(BuildContext context) {
    double radius = this.size / 2;
    return Container(
      decoration: new BoxDecoration(
      gradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [value, value],
          colors: [Colors.grey, Colors.blue]
          ),
          borderRadius: new BorderRadius.all(Radius.circular(radius))
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("月预算", style: TextStyle(fontSize: 8, color: Colors.white),),
            Text(Utils.toCurrency(amount), style: TextStyle(fontSize: 14, color: Colors.white),)
          ]
      ),
    );
  }
}
