import 'package:flutter/material.dart';

import '../fixtures.dart' as fixtures;

class Prices {
  final Map<String, Price> prices;

  const Prices({@required this.prices});

  Prices.withFixtureData() : this(prices: fixtures.prices);

  Price getCurrencyPrice(String currencyId) {
    return prices[currencyId];
  }
}

class Price {
  final Map<String, double> fiatPrices;
  final double variation;

  const Price({
    @required this.fiatPrices,
    @required this.variation,
  });

  double getInFiat(String fiatId) {
    if (fiatPrices.containsKey(fiatId)) {
      return fiatPrices[fiatId];
    }
    throw ArgumentError('Invalid fiat currency ID: $fiatId');
  }
}
