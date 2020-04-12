import 'package:flutter/material.dart';
import 'package:portfolio/prices-fetcher.dart';

import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/user-preferences.dart';
import 'dashbboard.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp();

  @override
  Widget build(BuildContext context) {
    final currencies = Currencies.withFixtureData();
    final fiats = Currencies.withFiatFixtureData();
    final portfolio = Portfolio(assets: [
      Asset(currency: currencies.getCurrency('btc'), amount: 0.39112364),
      Asset(currency: currencies.getCurrency('eth'), amount: 12.9542),
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
          userPreferences: userPreferences,
          fiats: fiats,
          currencies: currencies,
          pricesFetcher: CoinGeckoPricesFetcher.forPortfolio(
            portfolio: portfolio,
            userPreferences: userPreferences,
          ),
        ),
      ),
    );
  }
}
