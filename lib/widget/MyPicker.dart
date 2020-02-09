
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPicker extends StatefulWidget {
  int selectedValue;
  final ValueChanged<int> onChanged;
  final int firstValue;
  final int lastValue;

  MyPicker({
    Key key,
    @required this.selectedValue,
    @required this.onChanged,
    @required this.firstValue,
    @required this.lastValue,
  }): assert(onChanged != null),
        assert(firstValue < lastValue),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _MyPickerSate();

}

class _MyPickerSate extends State<MyPicker> {
  /// Add months to a month truncated date.
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    if(monthsToAdd < 0) {
      int toAdd = - monthsToAdd;
      return DateTime(monthDate.year - toAdd ~/ 12, monthDate.month - toAdd % 12);
    }
    return DateTime(monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  void _handleNextValue() {
    if (!_isDisplayingLastValue) {
      setState(() {
        widget.selectedValue += 1;
        widget.onChanged(widget.selectedValue);
      });
    }
  }

  void _handlePreviousValue() {
    if (!_isDisplayingFirstValue) {
      setState(() {
        widget.selectedValue -= 1;
      });
      widget.onChanged(widget.selectedValue);
      //SemanticsService.announce(localizations.formatMonthYear(_previousMonthDate), textDirection);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstValue {
    return widget.selectedValue <= widget.firstValue;
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastValue {
    return widget.selectedValue >= widget.lastValue;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // The month picker just adds month navigation to the day picker, so make
      // it the same height as the DayPicker
      height: 45,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Center(
              child: Text('${widget.selectedValue}', style: TextStyle(fontSize: 18),)
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _isDisplayingFirstValue ? null : _handlePreviousValue,
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _isDisplayingLastValue ? null : _handleNextValue,
            ),
          ),
        ],
      ),
    );
  }

}