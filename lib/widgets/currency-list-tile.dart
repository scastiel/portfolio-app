import 'package:flutter/material.dart';
import 'package:portfolio/model/currencies.dart';

import 'currencies-screen.dart';

class CurrencyListTile extends StatelessWidget {
  final Currency selectedCurrency;
  final void Function(Currency) onSelected;
  final String title;
  final bool fiats;

  const CurrencyListTile({
    Key key,
    this.onSelected,
    this.selectedCurrency,
    this.title = '',
    this.fiats = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showCurrenciesScreen(
          context,
          fiats: fiats,
          title: title,
          onSelected: onSelected,
        );
      },
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          selectedCurrency != null
              ? Text(selectedCurrency.name)
              : Text('Select'),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}