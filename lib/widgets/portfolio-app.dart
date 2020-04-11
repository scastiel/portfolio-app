import 'package:flutter/material.dart';

import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/prices.dart';
import '../model/user-preferences.dart';
import 'dashbboard.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp();

  @override
  Widget build(BuildContext context) {
    final prices = Prices.withFixtureData();
    final currencies = Currencies.withFixtureData();
    final fiats = Currencies.withFiatFixtureData();
    final portfolio = Portfolio(assets: [
      Asset(currency: currencies.getCurrency('btc'), amount: 5.4),
      Asset(currency: currencies.getCurrency('eth'), amount: 32.9),
    ]);
    final userPreferences = UserPreferences(
      pricesFiatId: 'usd',
      holdingsFiatId: 'cad',
    );
    return MaterialApp(
      title: 'Portfolio',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: Dashboard(
          portfolio: portfolio,
          prices: prices,
          userPreferences: userPreferences,
          fiats: fiats,
        ),
      ),
    );
  }
}
