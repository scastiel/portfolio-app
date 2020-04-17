import 'package:intl/intl.dart';

import 'model/currencies.dart';

final _pricesFormat =
    NumberFormat.currency(locale: 'en-US', decimalDigits: 2, symbol: '');

String formatPrice(double price, {Currency currency}) {
  if (currency == null) {
    if (price == null) return '-';
    return _pricesFormat.format(price);
  }
  return '${formatPrice(price)} ${currency.symbol}';
}
