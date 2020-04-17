import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:portfolio/coin-gecko-api.dart';
import 'package:portfolio/widgets/edit-asset-screen.dart';
import 'package:provider/provider.dart';

import '../prices-fetcher.dart';
import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/user-preferences.dart';
import 'dashbboard.dart';

class PortfolioApp extends StatefulWidget {
  @override
  _PortfolioAppState createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  UserPreferences _userPreferences;
  Currencies _currencies;
  Portfolio _portfolio;
  PricesFetcher _pricesFetcher;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initCurrencies();
  }

  void _initCurrencies() async {
    final userPreferences = UserPreferences();
    await userPreferences.initWithSharedPrefs();
    final api = CoinGeckoApi();
    final currencies = Currencies(currencies: {
      ...await api.fetchCurrencies(),
      ...await api.fetchFiats(),
    });
    final portfolio = Portfolio();
    await portfolio.initWithSharedPrefs(currencies: currencies);
    final pricesFetcher = CoinGeckoPricesFetcher(
      portfolio: portfolio,
      userPreferences: userPreferences,
    );

    setState(() {
      _userPreferences = userPreferences;
      _currencies = currencies;
      _portfolio = portfolio;
      _pricesFetcher = pricesFetcher;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? MultiProvider(
            providers: [
              Provider<Currencies>(create: (_) => _currencies),
              ChangeNotifierProvider<UserPreferences>(
                  create: (_) => _userPreferences),
              ChangeNotifierProvider<Portfolio>(create: (_) => _portfolio),
              Provider<PricesFetcher>(create: (_) => _pricesFetcher),
            ],
            child: MaterialApp(
              title: 'Portfolio',
              theme: _getTheme(ThemeData.light()),
              darkTheme: _getTheme(ThemeData.dark()),
              themeMode: _userPreferences.appTheme,
              home: Scaffold(
                body: DashboardWrapper(),
                floatingActionButton: AddAssetFloatingActionButton(),
              ),
            ),
          )
        : _LoadingScreen();
  }
}

class AddAssetFloatingActionButton extends StatelessWidget {
  const AddAssetFloatingActionButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EditAssetScreen(asset: null)));
      },
      tooltip: 'Add asset',
      child: const Icon(Icons.add),
    );
  }
}

_getTheme(ThemeData baseTheme) => baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        color: baseTheme.scaffoldBackgroundColor,
        brightness: baseTheme.brightness,
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 22,
            color: baseTheme.hintColor,
          ),
        ),
        actionsIconTheme:
            baseTheme.iconTheme.copyWith(color: baseTheme.hintColor),
        iconTheme: baseTheme.iconTheme.copyWith(color: baseTheme.hintColor),
      ),
    );

class _LoadingScreen extends StatelessWidget {
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
