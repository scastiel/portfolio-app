import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/model/user-preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            delegate: SliverChildListDelegate(
                [ThemeSettings(), FiatSettings(), Legal(), AboutSection()]),
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
              trailing: _buildThemeSelector(userPreferences),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(UserPreferences userPreferences) {
    final themeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    return ToggleButtons(
      children: themeModes.map((t) => Text(_getThemeLabel(t))).toList(),
      constraints: BoxConstraints(minWidth: 64.0, minHeight: 32),
      borderRadius: BorderRadius.all(Radius.circular(8)),
      isSelected: themeModes.map((t) => userPreferences.appTheme == t).toList(),
      onPressed: (index) {
        userPreferences.appTheme = themeModes[index];
      },
    );
  }

  String _getThemeLabel(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return 'Auto';
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
              showSymbolsInList: true,
            ),
            Divider(height: 1),
            CurrencyListTile(
              selectedCurrency: holdingsCurrency,
              onSelected: (currency) {
                userPreferences.holdingsFiatId = currency.id;
              },
              title: 'Currency for holdings',
              fiats: true,
              showSymbolsInList: true,
            ),
          ],
        ),
      ),
    );
  }
}

class Legal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              title: Text('Terms and conditions'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch(
                  'https://scastiel.github.io/portfolio-app/terms-and-conditions',
                );
              },
            ),
            Divider(height: 1),
            ListTile(
              title: Text('Privacy policy'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch(
                  'https://scastiel.github.io/portfolio-app/privacy-policy',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _modalTransitionBuilder(
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

void openSettings(context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(),
      transitionsBuilder: _modalTransitionBuilder,
    ),
  );
}

class AboutSection extends StatelessWidget {
  _linkRecognizer(uri) => new TapGestureRecognizer()..onTap = () => launch(uri);

  TextSpan _text(BuildContext context, String text) {
    return TextSpan(text: text);
  }

  TextSpan _newLine(BuildContext context) {
    return _text(context, '\n\n');
  }

  TextSpan _link(BuildContext context, String text, String uri) {
    return TextSpan(
      text: text,
      style: TextStyle(decoration: TextDecoration.underline),
      recognizer: _linkRecognizer(uri),
    );
  }

  TextSpan _strongLink(BuildContext context, String text, String uri) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
      ),
      recognizer: _linkRecognizer(uri),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 11,
              ),
              children: [
                TextSpan(
                  children: [
                    _text(context, 'Made with ❤️ by '),
                    _strongLink(context, 'Sébastien Castiel',
                        'https://blog.castiel.me'),
                  ],
                  style: TextStyle(fontSize: 15),
                ),
                _newLine(context),
                _text(context, 'Price data is provided by '),
                _link(context, 'CoinGecko.com', 'https://www.coingecko.com/'),
                _newLine(context),
                _text(context, 'Application icon from '),
                _link(context, 'Vecteezy.com', 'https://www.vecteezy.com/'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
