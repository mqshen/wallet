import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'NumericalKeyboard.dart';

class Constants {
  static final int pageSize = 20;
  static const double kDayPickerRowHeight = 45.0;
  static const int kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.

  static const colors = [0x85619F, 0xA392E5, 0x677ECF, 0x739CE8, 0x6E9BDB,
    0x6CB1E7, 0x77BAB3, 0x77B982, 0xE5BC63, 0xE5BC63, 0xDE9364, 0xD17067,
    0xD387BD, 0x76AFC7, 0x7FC3D0, 0xD1B37A, 0xB4A5C2, 0xA8B99D
  ];

  static const borderColorAlpha = 0xff000000;
  static const backgroundColorAlpha = 0xc0000000;


  static const Income = 0;
  static const Spend = 1;
  static const TransferOut = 3;
  static const TransferIn = 4;

}

typedef MyKeyboardCallback(String key);
typedef MyKeyboardConfirm();

class Utils {

  static final currencyFormat = new NumberFormat("#,##0", "en_US");
  static final placeholderFormat = new NumberFormat("00", "en_US");
  static final percentFormat = new NumberFormat("0.00", "en_US");

  static String toCurrency(int amount) {
    return '${currencyFormat.format((amount / 100).floor())}.${placeholderFormat.format(amount % 100)}';
  }

  static String toPercent(double percent) {
    return '${percentFormat.format(percent * 100)}%';
  }

  static int stringToInt(String amount) {
    String temp = amount;
    int index = amount.indexOf("\.");
    if(index < 0) {
      temp = '${amount}.00';
    } else {
      int interval = amount.length - index;
      if(interval < 3) {
        int i = 3 - (amount.length - index);
        for (int j = 0; j < i; ++j) {
          temp = '${temp}0';
        }
      }
    }
    String currency = temp.replaceAll("\.", "");
    return int.parse(currency);
  }

  static String stringToCurrency(String amount) {
    int currency = stringToInt(amount);
    return toCurrency(currency);
  }

  static String formatDate(DateTime time) {
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(time);
  }

  static String formatMonth(DateTime time) {
    var formatter = new DateFormat('yyyy-MM');
    return formatter.format(time);
  }

  static String getClassifyImage(String image) {
    return 'images/classify_$image.png';
  }

  static String getIconImage(String image) {
    return 'images/icon_$image.png';
  }

  static Color toColor(int colorIndex) {
    return Color(Constants.borderColorAlpha | Constants.colors[colorIndex]);
  }

  static charts.Color toChartColor(int color) {
    int r = (color & 0xFF0000) >> 16;
    int g = (color & 0xFF00) >> 8;
    int b = (color & 0xFF);
    return charts.Color(r: r, g: g, b: b);
  }

  static void amountKeyPressed(int key, String amount, MyKeyboardCallback callback, MyKeyboardConfirm confirm) {
    String result = amount;
    if(key == NumericalKeyboard.confirmKey) {
      confirm();
    } else {
      if (key == NumericalKeyboard.clearKey) {
        result = "";
      } else if (key == NumericalKeyboard.backspaceKey) {
        result = amount.substring(0, amount.length - 1);
      } else {
        int index = amount.indexOf("\.");
        if (key == NumericalKeyboard.pointKey) {
          if(index < 0)
            result = '$amount.';
        } else {
          if(index < 0 || amount.length - index < 3) {
            result = '$amount$key';
          }
        }
      }
      callback(result);
    }
  }
}


class MyCenterButtonLocation extends FloatingActionButtonLocation {
  const MyCenterButtonLocation();

  // Positions the Y coordinate of the [FloatingActionButton] at a height
  // where it docks to the [BottomAppBar].
  double getDockedY(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;

    double fabY = contentBottom;
    // The FAB should sit with a margin between it and the snack bar.
    if (snackBarHeight > 0.0)
      fabY = math.min(fabY, contentBottom - snackBarHeight - fabHeight - kFloatingActionButtonMargin);
    // The FAB should sit with its center in front of the top of the bottom sheet.
    if (bottomSheetHeight > 0.0)
      fabY = math.min(fabY, contentBottom - bottomSheetHeight - fabHeight);

    final double maxFabY = scaffoldGeometry.scaffoldSize.height - fabHeight;
    return math.min(maxFabY, fabY) - 10;
  }

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2.0;
    return Offset(fabX, getDockedY(scaffoldGeometry));
  }


}