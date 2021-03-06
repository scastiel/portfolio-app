import 'package:flutter/material.dart';

import '../fixtures.dart' as fixtures;

class Currency {
  final String id;
  final String name;
  final String symbol;
  final bool fiat;

  const Currency({
    @required this.id,
    @required this.name,
    @required this.symbol,
    this.fiat = false,
  });

  Currency.fromJson(Map<String, dynamic> json, {this.fiat = false})
      : id = json['id'],
        name = json['name'],
        symbol = json['symbol'];

  // Currency copyWith({
  //   String id,
  //   String name,
  //   String symbol,
  //   bool fiat = false,
  // }) => Currency(
  //   id:
  // )
}

class Currencies {
  final Set<Currency> currencies;

  const Currencies({@required this.currencies});

  const Currencies.withFixtureData() : this(currencies: fixtures.currencies);

  Set<Currency> get cryptos =>
      currencies.where((currency) => currency.fiat == false).toSet();
  Set<Currency> get fiats =>
      currencies.where((currency) => currency.fiat == true).toSet();

  Currency getCurrency(String currencyId) {
    return currencies.firstWhere((currency) => currency.id == currencyId);
  }
}
