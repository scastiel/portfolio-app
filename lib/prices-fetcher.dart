import 'dart:math';

import 'package:portfolio/model/currencies.dart';

import 'fixtures.dart';
import 'model/price.dart';

class PricesFetcher {
  final Map<String, Price> _prices = {};
  static final random = Random();

  subscribeForCurrency(Currency currency, void Function(Price) onUpdate) {
    void _updatePrice() {
      if (_prices[currency.id] == null) {
        _prices[currency.id] = prices[currency.id];
      } else {
        final factor = (1 + 0.0001 * (random.nextDouble() - 0.5));
        _prices[currency.id] = Price(fiatPrices: {
          'usd': _prices[currency.id].fiatPrices['usd'] * factor,
          'cad': _prices[currency.id].fiatPrices['cad'] * factor
        }, variation: _prices[currency.id].variation * factor);
      }
      Future.delayed(Duration(milliseconds: 300))
          .then((_) => onUpdate(_prices[currency.id]));
      Future.delayed(Duration(seconds: 5)).then((_) => _updatePrice());
    }

    _updatePrice();
  }
}
