import 'package:flutter/material.dart';
import 'package:portfolio/model/user-preferences.dart';
import 'package:provider/provider.dart';

import '../model/currencies.dart';

class SettingsScreen extends StatelessWidget {
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
            delegate: SliverChildListDelegate([Settings()]),
          ),
        ],
      ),
    );
  }
}

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    final currencies = Provider.of<Currencies>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              title: Text('Currency for prices'),
              trailing: CurrencyDropdownFormField(
                currency: currencies.getCurrency(userPreferences.pricesFiatId),
                onCurrencySelected: (fiat) {
                  userPreferences.pricesFiatId = fiat.id;
                },
              ),
            ),
            Divider(height: 1),
            ListTile(
              title: Text('Currency for holdings'),
              trailing: CurrencyDropdownFormField(
                currency:
                    currencies.getCurrency(userPreferences.holdingsFiatId),
                onCurrencySelected: (fiat) {
                  userPreferences.holdingsFiatId = fiat.id;
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
  final Currency currency;
  final void Function(Currency) onCurrencySelected;

  const CurrencyDropdownFormField({
    Key key,
    @required this.currency,
    this.onCurrencySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencies = Provider.of<Currencies>(context);
    return DropdownButton(
      value: currency,
      items: currencies.fiats
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
