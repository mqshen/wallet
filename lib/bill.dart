import 'package:flutter/material.dart';

import 'MyIcons.dart';
import 'TimeLineIcon.dart';

class Bill extends StatelessWidget {
  static const double lineHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    //tt.child = Icon(MyIcons.add);
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: Container (
                height: lineHeight,
                padding: const EdgeInsets.only(right: 10.0),
                alignment: Alignment.centerRight,
                child: new Text("22222", textAlign: TextAlign.right,)
              ),
            ),
            CustomPaint(
              painter: new TimeLineIcon(
                  paintWidth: 1,//widget.timeAxisLineWidth,
                  circleSize: 18,//widget.lineToLeft,
                  lineColor: Colors.grey,
                  isTimeLine: true
              ),
              child: Container(
                child: Icon(MyIcons.card, size: lineHeight / 2,),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(child: new Text("22222")),
            ),
          ],
        );
      },
      itemCount: 5,
    );
  }



}