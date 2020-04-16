import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/portfolio.dart';
import '../model/currencies.dart';
import '../model/price.dart';
import '../model/user-preferences.dart';
import 'price-card.dart';

class CurrencyCard extends StatelessWidget {
  final Asset asset;
  final Price price;
  final Map<DateTime, double> history;
  final UserPreferences userPreferences;

  const CurrencyCard({
    @required this.asset,
    @required this.price,
    @required this.history,
    @required this.userPreferences,
  });

  Widget buildEditView(BuildContext context, void Function() cancel) {
    return Center(
      child: ButtonBar(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FlatButton.icon(
          //   icon: Icon(Icons.edit),
          //   onPressed: () {},
          //   label: Text('Edit'),
          // ),
          FlatButton.icon(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RemoveAssetDialog(
                    asset: asset,
                    onConfirm: () {
                      final portfolio =
                          Provider.of<Portfolio>(context, listen: false);
                      portfolio.removeAsset(asset);
                      cancel();
                    },
                  );
                },
              );
            },
            label: Text('Remove'),
          ),
          FlatButton.icon(
            icon: Icon(Icons.cancel),
            onPressed: () {
              cancel();
            },
            label: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencies = Provider.of<Currencies>(context);
    final priceFiat = price?.getInFiat(userPreferences.pricesFiatId);
    final holdingValueFiat = price != null
        ? asset.amount * price.getInFiat(userPreferences.holdingsFiatId)
        : null;
    final pricesFiat = currencies.getCurrency(userPreferences.pricesFiatId);
    final holdingsFiat = currencies.getCurrency(userPreferences.holdingsFiatId);
    return PriceCard(
      title: Text(asset.currency.name),
      currency: asset.currency,
      fiat: currencies.getCurrency(userPreferences.pricesFiatId),
      variation: price?.variation,
      priceText:
          '${priceFiat != null ? priceFiat.toStringAsFixed(2) : '-'} ${pricesFiat.symbol}',
      history: history,
      holdingText:
          'Holding: ${holdingValueFiat != null ? holdingValueFiat.toStringAsFixed(2) : '-'} ${holdingsFiat.symbol} (${asset.amount.toString()} ${asset.currency.symbol})',
      buildEditView: buildEditView,
    );
  }
}

class RemoveAssetDialog extends StatelessWidget {
  const RemoveAssetDialog({
    Key key,
    @required this.asset,
    @required this.onConfirm,
  }) : super(key: key);

  final Asset asset;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text("Remove asset"),
      content: RichText(
        text: TextSpan(
          text: 'Do you want to remove ',
          style: Theme.of(context).textTheme.bodyText1,
          children: <TextSpan>[
            TextSpan(
              text: asset.currency.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' from your portfolio?'),
          ],
        ),
      ),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          textColor: Colors.red,
          child: new Text('Delete'),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
