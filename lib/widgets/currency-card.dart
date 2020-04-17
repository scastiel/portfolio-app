import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:portfolio/widgets/edit-asset-screen.dart';
import 'package:provider/provider.dart';

import '../helpers.dart';
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
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).hintColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ReorderableListener(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.drag_handle),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonBar(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTextButton(
                    icon: Icons.edit,
                    title: 'Edit',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditAssetScreen(asset: asset),
                        ),
                      );
                      Future.delayed(Duration(milliseconds: 100)).then((_) {
                        cancel();
                      });
                    },
                  ),
                  IconTextButton(
                    icon: Icons.delete,
                    title: 'Remove',
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return RemoveAssetDialog(
                            asset: asset,
                            onConfirm: () {
                              final portfolio = Provider.of<Portfolio>(context,
                                  listen: false);
                              portfolio.removeAsset(asset);
                              cancel();
                            },
                          );
                        },
                      );
                    },
                  ),
                  IconTextButton(
                    icon: Icons.cancel,
                    title: 'Cancel',
                    onPressed: () {
                      cancel();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencies = Provider.of<Currencies>(context);
    final priceFiat = price?.getInFiat(userPreferences.pricesFiatId);
    final holdingValueFiat = asset.amount > 0 && price != null
        ? asset.amount * price.getInFiat(userPreferences.holdingsFiatId)
        : null;
    final pricesFiat = currencies.getCurrency(userPreferences.pricesFiatId);
    final holdingsFiat = currencies.getCurrency(userPreferences.holdingsFiatId);
    return PriceCard(
      title: Text(asset.currency.name),
      currency: asset.currency,
      fiat: currencies.getCurrency(userPreferences.pricesFiatId),
      variation: price?.variation,
      priceText: formatPrice(priceFiat, currency: pricesFiat),
      history: history,
      holdingText: asset.amount > 0
          ? 'Holding: ${formatPrice(holdingValueFiat, currency: holdingsFiat)} (${asset.amount.toString()} ${asset.currency.symbol})'
          : null,
      buildEditView: buildEditView,
    );
  }
}

class IconTextButton extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  final IconData icon;

  const IconTextButton({
    Key key,
    @required this.title,
    @required this.onPressed,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Icon(icon),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
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
          child: new Text('Remove'),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
