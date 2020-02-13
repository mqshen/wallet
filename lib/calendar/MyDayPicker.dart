import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:wallet/database/DBManager.dart';


import 'dart:math' as math;

import '../Constants.dart';
import 'MyCalendar.dart';

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double viewTileHeight = constraints.viewportMainAxisExtent / (Constants.kMaxDayPickerRowCount + 1);
    final double tileHeight = math.max(Constants.kDayPickerRowHeight, viewTileHeight);
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _kDayPickerGridDelegate = _DayPickerGridDelegate();

class MyDayPicker extends StatefulWidget {
  /// Creates a day picker.
  ///
  /// Rarely used directly. Instead, typically used as part of a [MonthPicker].
  MyDayPicker({
    Key key,
    @required this.selectedDate,
    @required this.currentDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.displayedMonth,
    this.selectableDayPredicate,
    this.dragStartBehavior = DragStartBehavior.start,
    this.summary,
  }) : assert(selectedDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(dragStartBehavior != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate) || selectedDate.isAtSameMomentAs(firstDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  DateTime selectedDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  final DragStartBehavior dragStartBehavior;

  final Map<int, DayItem> summary;

  @override
  State<StatefulWidget> createState() => _MyDayPickerState();

}

class _MyDayPickerState extends State<MyDayPicker> {


  List<Widget> _getDayHeaders(TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7)
        break;
    }
    return result;
  }

  // Do not use this directly - call getDaysInMonth instead.
  static const List<int> _daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear)
        return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [DateTime.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  int _computeFirstDayOffset(int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;
    final int daysInMonth = getDaysInMonth(year, month);

    double daybudget = DBManager().budget / daysInMonth;

    final int firstDayOffset = _computeFirstDayOffset(year, month, localizations);
    final List<Widget> labels = <Widget>[
      ..._getDayHeaders(themeData.textTheme.caption, localizations),
    ];
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth)
        break;
      if (day < 1) {
        labels.add(Container(
          decoration: BoxDecoration(
              border: Border( bottom: BorderSide(color: Colors.grey[300]))
          ),
        ));
//        TextStyle itemStyle = themeData.textTheme.body1.copyWith(color: themeData.disabledColor);
//        final DateTime dayToBuild = DateTime(year, month, 1).add(Duration(days: day - 1));
//        labels.add(Container(
//            decoration: BoxDecoration(
//                border: Border( bottom: BorderSide(color: Colors.grey[300]))
//            ),
//            child: Center(
//              child: Semantics(
//                label: '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
//                selected: false,
//                sortKey: OrdinalSortKey(day.toDouble()),
//                child: ExcludeSemantics(
//                  child: Text(localizations.formatDecimal(dayToBuild.day), style: itemStyle),
//                ),
//              ),
//            )
//          )
//        );
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(widget.lastDate)
            || dayToBuild.isBefore(widget.firstDate)
            || (widget.selectableDayPredicate != null && !widget.selectableDayPredicate(dayToBuild));

        BoxDecoration decoration = BoxDecoration(
            border: Border( bottom: BorderSide(color: Colors.grey[300]))
        );
        TextStyle itemStyle = themeData.textTheme.body1;

        DayItem dayItem = widget.summary[day];
        String income = "";
        String spend = "";
        if(dayItem != null) {
          income = Utils.toCurrency(dayItem.income);
          if(dayItem.spend > 0)
            spend = "-${Utils.toCurrency(dayItem.spend)}";
          else
            spend = "0.00";

          if(dayItem.spend > daybudget) {
            decoration = BoxDecoration(
              border: Border( bottom: BorderSide(color: Colors.grey[300])),
              color: Colors.red[200],
              //shape: BoxShape.circle,
            );
          } else {
            decoration = BoxDecoration(
              border: Border( bottom: BorderSide(color: Colors.grey[300])),
              color: Colors.lightBlue[300],
              //shape: BoxShape.circle,
            );
          }
        }

        final bool isSelectedDay = widget.selectedDate.year == year &&
            widget.selectedDate.month == month && widget.selectedDate.day == day;
        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          decoration = BoxDecoration(
            border: Border( bottom: BorderSide(color: Colors.grey[300])),
            color: themeData.accentColor,
            //shape: BoxShape.circle,
          );
        } else if (disabled) {
          itemStyle = themeData.textTheme.body1.copyWith(color: themeData.disabledColor);
        } else if (widget.currentDate.year == year && widget.currentDate.month == month &&
            widget.currentDate.day == day) {
          // The current day gets a different text color.
          itemStyle = themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        }


        Widget dayWidget = Container(
          padding: EdgeInsets.only(top: 5.0, right: 5.0),
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(localizations.formatDecimal(day), style: itemStyle, textAlign: TextAlign.right,),
              Text(income, style: TextStyle(fontSize: 8, color: Colors.grey[300]), textAlign: TextAlign.right,),
              Text(spend, style: TextStyle(fontSize: 8, color: Colors.red[400]), textAlign: TextAlign.right,),
            ],
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                widget.selectedDate = dayToBuild;
              });
              widget.onChanged(dayToBuild);
            },
            child: dayWidget,
            dragStartBehavior: widget.dragStartBehavior,
          );
        }

        labels.add(dayWidget);
      }
    }

    return Column(
      children: <Widget>[
        Container(
          height: Constants.kDayPickerRowHeight,
          child: Center(
            child: ExcludeSemantics(
              child: Text(
                localizations.formatMonthYear(widget.displayedMonth),
                style: themeData.textTheme.subhead,
              ),
            ),
          ),
        ),
        Flexible(
          child: GridView.custom(
            gridDelegate: _kDayPickerGridDelegate,
            childrenDelegate: SliverChildListDelegate(labels, addRepaintBoundaries: false),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
