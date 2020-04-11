import 'package:flutter/material.dart';

import '../fixtures.dart' as fixtures;

class Currency {
  final String id;
  final String name;
  final String symbol;
  const Currency(
      {@required this.id, @required this.name, @required this.symbol});
}

class Currencies {
  final Map<String, Currency> currencies;

  const Currencies({@required this.currencies});

  const Currencies.withFixtureData() : this(currencies: fixtures.currencies);

  const Currencies.withFiatFixtureData() : this(currencies: fixtures.fiats);

  Currency getCurrency(String currencyId) {
    if (currencies.containsKey(currencyId)) {
      return currencies[currencyId];
    }
    throw ArgumentError('Invalid currency ID: $currencyId');
  }
}
