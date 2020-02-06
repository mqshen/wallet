import 'package:flutter/material.dart';

class TimeLineIcon extends CustomPainter {
  //虚线
  double DottedLineLenght;

  double circleSize;
  Gradient myGradient;
  Color lineColor;
  double paintWidth;
  bool isTimeLine;

  TimeLineIcon({this.circleSize,
    this.myGradient,
    this.isTimeLine = false,
    this.lineColor = Colors.redAccent,
    this.paintWidth = 4
  });

  Paint _paint = Paint()
    ..strokeCap = StrokeCap.square //画笔笔触类型
    ..isAntiAlias = true;//是否启动抗锯齿; //画笔的宽度

  Path _path = new Path();

  @override
  Future paint(Canvas canvas, Size size) {
    _paint.color = this.lineColor;

    if(this.isTimeLine) {
      _paint.style = PaintingStyle.stroke; // 画线模式
      _paint.strokeWidth = this.paintWidth;
      _path.moveTo(size.width / 2, 0); // 移动起点到（20,40）
      _path.lineTo(size.width / 2, size.height); // 画条斜线

      if (myGradient != null) {
        final Rect arcRect = Rect.fromLTWH(10, 5, 4, size.height);
        _paint.shader = myGradient.createShader(arcRect);
      }

      canvas.drawPath(_path, _paint);
    }
    if(circleSize > 0) {
      _paint.style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), circleSize, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}