import 'package:flutter/material.dart';

import '../Constants.dart';


class MyMonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  MyMonthPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
  }) : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate) || selectedDate.isAtSameMomentAs(firstDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  DateTime selectedDate;

  /// Called when the user picks a month.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  @override
  _MyMonthPickerState createState() => _MyMonthPickerState();
}

class _MyMonthPickerState extends State<MyMonthPicker> {

  /// Add months to a month truncated date.
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    if(monthsToAdd < 0) {
      int toAdd = - monthsToAdd;
      return DateTime(monthDate.year - toAdd ~/ 12, monthDate.month - toAdd % 12);
    }
    return DateTime(monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      setState(() {
        widget.selectedDate = _addMonthsToMonthDate(widget.selectedDate, 1);
        widget.onChanged(widget.selectedDate);
      });
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      setState(() {
        widget.selectedDate = _addMonthsToMonthDate(widget.selectedDate, -1);
      });
      widget.onChanged(widget.selectedDate);
      //SemanticsService.announce(localizations.formatMonthYear(_previousMonthDate), textDirection);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !widget.selectedDate.isAfter(
        DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !widget.selectedDate.isBefore(
        DateTime(widget.lastDate.year, widget.lastDate.month));
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
              child: Text(Utils.formatMonth(widget.selectedDate), style: TextStyle(fontSize: 18),)
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _isDisplayingFirstMonth ? null : _handlePreviousMonth,
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
            ),
          ),
        ],
      ),
    );
  }

}