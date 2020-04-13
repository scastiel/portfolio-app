import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _loaded = false;
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
    _initPreferences();
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userPreferences = UserPreferences(
        pricesFiatId: prefs.getString('prefs.pricesFiatId') ?? 'usd',
        holdingsFiatId: prefs.getString('prefs.holdingsFiatId') ?? 'cad',
        historyDuration: historyDurationFromString(
                prefs.getString('prefs.historyDuration')) ??
            HistoryDuration.threeMonths,
      );
      _loaded = true;
    });
  }

  void _updatePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prefs.pricesFiatId', _userPreferences.pricesFiatId);
    prefs.setString('prefs.holdingsFiatId', _userPreferences.holdingsFiatId);
    prefs.setString('prefs.historyDuration',
        historyDurationToString(_userPreferences.historyDuration));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: _loaded ? _buildHome() : LoadingScreen(),
    );
  }

  Widget _buildHome() {
    return Scaffold(
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
            _updatePreferences();
          });
        },
        pricesFetcher: CoinGeckoPricesFetcher.forPortfolio(
          portfolio: portfolio,
          userPreferences: _userPreferences,
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Center(
        child: RefreshProgressIndicator(),
      ),
    );
  }
}
