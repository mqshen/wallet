import 'package:intl/intl.dart';

class Constants {
  static final int pageSize = 20;

  static const colors = [0x85619F, 0xA392E5, 0x677ECF, 0x739CE8, 0x6E9BDB,
    0x6CB1E7, 0x77BAB3, 0x77B982, 0xE5BC63, 0xE5BC63, 0xDE9364, 0xD17067,
    0xD387BD, 0x76AFC7, 0x7FC3D0, 0xD1B37A, 0xB4A5C2, 0xA8B99D
  ];

  static const borderColorAlpha = 0xff000000;
  static const backgroundColorAlpha = 0xc0000000;

}

class Utils {

  static final currencyFormat = new NumberFormat("#,##0", "en_US");
  static final placeholderFormat = new NumberFormat("00", "en_US");

  static String toCurrency(int amount) {
    return '${currencyFormat.format((amount / 100).floor())}.${placeholderFormat.format(amount % 100)}';
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

  static String getClassifyImage(String image) {
    return 'images/classify_${image}.png';
  }
}