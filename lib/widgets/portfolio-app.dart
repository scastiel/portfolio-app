import 'dart:convert';
import 'dart:io';

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
  bool _networkError = false;

  @override
  void initState() {
    super.initState();
    _initCurrencies();
  }

  onNetworkError(BuildContext context, {void Function() retry}) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(hours: 1),
        content: Text('There is a problem with your network.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            retry();
          },
        ),
      ),
    );
  }

  void _initCurrencies() async {
    try {
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
        onNetworkError: onNetworkError,
      );

      setState(() {
        _userPreferences = userPreferences;
        _currencies = currencies;
        _portfolio = portfolio;
        _pricesFetcher = pricesFetcher;
        _initialized = true;
      });
    } on SocketException catch (_) {
      setState(() {
        _networkError = true;
      });
    }
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
            child: _App(),
          )
        : _LoadingScreen(
            networkError: _networkError,
            retry: () {
              setState(() {
                _networkError = false;
                _initCurrencies();
              });
            },
          );
  }
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    return MaterialApp(
      title: 'Portfolio',
      theme: _getTheme(ThemeData.light()),
      darkTheme: _getTheme(ThemeData.dark()),
      themeMode: userPreferences.appTheme,
      home: Scaffold(
        body: DashboardWrapper(),
        floatingActionButton: AddAssetFloatingActionButton(),
      ),
    );
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
  final bool networkError;
  final void Function() retry;

  const _LoadingScreen({Key key, this.networkError = false, this.retry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Center(
          child: networkError
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          'There seems to be a problem with your network.'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48.0),
                      child: RaisedButton.icon(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          if (retry != null) {
                            retry();
                          }
                        },
                        label: Text('Retry'),
                      ),
                    ),
                  ],
                )
              : RefreshProgressIndicator(),
        ),
      ),
    );
  }
}
