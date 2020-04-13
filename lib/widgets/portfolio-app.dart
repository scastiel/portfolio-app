import 'package:flutter/material.dart';

import '../model/history-duration.dart';
import '../prices-fetcher.dart';
import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/user-preferences.dart';
import 'dashbboard.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp();

  @override
  _PortfolioAppState createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  UserPreferences _userPreferences;

  static const currencies = Currencies.withFixtureData();
  static const fiats = Currencies.withFiatFixtureData();

  final portfolio = Portfolio(assets: [
    Asset(currency: currencies.getCurrency('btc'), amount: 0.39112364),
    Asset(currency: currencies.getCurrency('eth'), amount: 12.9542),
  ]);

  @override
  void initState() {
    super.initState();
    _userPreferences = UserPreferences(
      pricesFiatId: 'usd',
      holdingsFiatId: 'cad',
      historyDuration: HistoryDuration.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: Dashboard(
          portfolio: portfolio,
          userPreferences: _userPreferences,
          fiats: fiats,
          currencies: currencies,
          setHistoryDuration: (historyDuration) {
            setState(() {
              _userPreferences = _userPreferences.copyWith(
                historyDuration: historyDuration,
              );
            });
          },
          pricesFetcher: CoinGeckoPricesFetcher.forPortfolio(
            portfolio: portfolio,
            userPreferences: _userPreferences,
          ),
        ),
      ),
    );
  }
}
