import 'package:flutter/material.dart';
import 'package:portfolio/model/user-preferences.dart';
import 'package:portfolio/widgets/currencies-screen.dart';
import 'package:provider/provider.dart';

import '../model/currencies.dart';
import 'currency-list-tile.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Settings'),
            centerTitle: false,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.close),
                tooltip: 'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate:
                SliverChildListDelegate([ThemeSettings(), FiatSettings()]),
          ),
        ],
      ),
    );
  }
}

class ThemeSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 0.0, left: 8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              title: Text('Theme'),
              trailing: DropdownButton(
                value: userPreferences.appTheme,
                items: ThemeMode.values
                    .map(
                      (theme) => DropdownMenuItem(
                        value: theme,
                        child: Text(_getThemeLabel(theme)),
                      ),
                    )
                    .toList(),
                onChanged: (newTheme) {
                  userPreferences.appTheme = newTheme;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

class FiatSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    final currencies = Provider.of<Currencies>(context);
    final pricesCurrency = currencies.getCurrency(userPreferences.pricesFiatId);
    final holdingsCurrency =
        currencies.getCurrency(userPreferences.holdingsFiatId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            CurrencyListTile(
              selectedCurrency: pricesCurrency,
              onSelected: (currency) {
                userPreferences.pricesFiatId = currency.id;
              },
              title: 'Currency for prices',
              fiats: true,
            ),
            Divider(height: 1),
            CurrencyListTile(
              selectedCurrency: holdingsCurrency,
              onSelected: (currency) {
                userPreferences.holdingsFiatId = currency.id;
              },
              title: 'Currency for holdings',
              fiats: true,
            ),
          ],
        ),
      ),
    );
  }
}

Widget modalTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(
    begin: Offset(0.0, 1.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.ease));
  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
