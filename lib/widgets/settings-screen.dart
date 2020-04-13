import 'package:flutter/material.dart';
import 'package:portfolio/model/user-preferences.dart';

import '../model/currencies.dart';

class SettingsScreen extends StatelessWidget {
  final Currencies fiats;
  final UserPreferences userPreferences;
  final void Function(UserPreferences) updatePreferences;

  const SettingsScreen({
    Key key,
    @required this.fiats,
    @required this.userPreferences,
    @required this.updatePreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Settings'),
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
            delegate: SliverChildListDelegate([
              Settings(
                fiats: fiats,
                userPreferences: userPreferences,
                updatePreferences: updatePreferences,
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class Settings extends StatelessWidget {
  final Currencies fiats;
  final UserPreferences userPreferences;
  final void Function(UserPreferences) updatePreferences;

  const Settings({
    Key key,
    @required this.fiats,
    @required this.userPreferences,
    @required this.updatePreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              title: Text('Currency for prices'),
              trailing: CurrencyDropdownFormField(
                fiats: fiats,
                currency: fiats.getCurrency(userPreferences.pricesFiatId),
                onCurrencySelected: (fiat) {
                  updatePreferences(
                      userPreferences.copyWith(pricesFiatId: fiat.id));
                },
              ),
            ),
            Divider(height: 1),
            ListTile(
              title: Text('Currency for holdings'),
              trailing: CurrencyDropdownFormField(
                fiats: fiats,
                currency: fiats.getCurrency(userPreferences.holdingsFiatId),
                onCurrencySelected: (fiat) {
                  updatePreferences(
                      userPreferences.copyWith(holdingsFiatId: fiat.id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyDropdownFormField extends StatelessWidget {
  final Currencies fiats;
  final Currency currency;
  final void Function(Currency) onCurrencySelected;

  const CurrencyDropdownFormField({
    Key key,
    @required this.fiats,
    @required this.currency,
    this.onCurrencySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: currency,
      items: fiats.currencies.values
          .map(
            (currency) => DropdownMenuItem(
              value: currency,
              child: Text(currency.symbol),
            ),
          )
          .toList(),
      onChanged: (newCurrency) {
        if (onCurrencySelected != null) {
          onCurrencySelected(newCurrency);
        }
      },
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
