import 'package:flutter/material.dart';
import 'package:portfolio/widgets/edit-asset-screen.dart';
import 'package:provider/provider.dart';

import '../prices-fetcher.dart';
import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/user-preferences.dart';
import 'dashbboard.dart';

class PortfolioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currencies = Currencies.withFixtureData();
    final portfolio = Portfolio(assets: [
      Asset(currency: currencies.getCurrency('btc'), amount: 0.39112364),
      Asset(currency: currencies.getCurrency('eth'), amount: 12.9542),
    ]);
    final userPreferences = UserPreferences();
    userPreferences.initWithSharedPrefs();

    final pricesFetcher = CoinGeckoPricesFetcher(
      portfolio: portfolio,
      userPreferences: userPreferences,
    );

    return MultiProvider(
      providers: [
        Provider<Currencies>(create: (_) => currencies),
        ChangeNotifierProvider<UserPreferences>(create: (_) => userPreferences),
        ChangeNotifierProvider<Portfolio>(create: (_) => portfolio),
        Provider<PricesFetcher>(create: (_) => pricesFetcher),
      ],
      child: const _App(),
    );
  }
}

class _App extends StatelessWidget {
  const _App({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    if (!userPreferences.initialized) {
      return _LoadingScreen();
    }
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
