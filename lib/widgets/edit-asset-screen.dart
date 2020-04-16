import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/model/currencies.dart';
import 'package:portfolio/model/portfolio.dart';
import 'package:portfolio/model/user-preferences.dart';
import 'package:provider/provider.dart';

class EditAssetScreen extends StatelessWidget {
  final Asset asset;
  final TextEditingController _holdingsTextController;

  EditAssetScreen({Key key, @required this.asset})
      : _holdingsTextController =
            TextEditingController(text: asset.amount.toString()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _EditAssetAppBar(
            asset: asset,
            holdingsTextController: _holdingsTextController,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _EditAssetCurrencies(
                asset: asset,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                    'You can enter the amount you own, or keep it empty if you just want to watch the price.',
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 13)),
              ),
              _EditAssetHoldings(
                asset: asset,
                holdingsTextController: _holdingsTextController,
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class _EditAssetAppBar extends StatelessWidget {
  const _EditAssetAppBar({
    Key key,
    @required this.asset,
    @required this.holdingsTextController,
  }) : super(key: key);

  final Asset asset;
  final TextEditingController holdingsTextController;

  @override
  Widget build(BuildContext context) {
    final portfolio = Provider.of<Portfolio>(context);
    return SliverAppBar(
      title: Text(asset.currency.name),
      centerTitle: false,
      pinned: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.green,
          ),
          tooltip: 'Save',
          onPressed: () {
            final amount = double.tryParse(holdingsTextController.text) ?? 0.0;
            portfolio.updateAsset(asset.copyWith(amount: amount));
            Navigator.of(context).pop();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.red,
          ),
          tooltip: 'Cancel',
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
      automaticallyImplyLeading: false,
    );
  }
}

class _EditAssetCurrencies extends StatelessWidget {
  const _EditAssetCurrencies({
    Key key,
    @required this.asset,
  }) : super(key: key);

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final currencies = Provider.of<Currencies>(context);
    final userPreferences = Provider.of<UserPreferences>(context);
    final fiat = currencies.getCurrency(userPreferences.pricesFiatId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              title: Text('Cryptocurrency'),
              trailing: Text(asset.currency.name),
            ),
            Divider(height: 1),
            ListTile(
              title: Text('Fiat to display price'),
              trailing: Text(fiat.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditAssetHoldings extends StatelessWidget {
  const _EditAssetHoldings({
    Key key,
    @required this.asset,
    @required this.holdingsTextController,
  }) : super(key: key);

  final Asset asset;
  final TextEditingController holdingsTextController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              title: Text('Holdings'),
              trailing: Container(
                width: 150,
                child: TextField(
                  controller: holdingsTextController,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'None',
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
