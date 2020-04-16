import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/model/currencies.dart';
import 'package:portfolio/model/portfolio.dart';
import 'package:portfolio/model/user-preferences.dart';
import 'package:portfolio/widgets/currencies-screen.dart';
import 'package:provider/provider.dart';

import 'currency-list-tile.dart';

class EditAssetScreen extends StatefulWidget {
  final Asset asset;

  EditAssetScreen({Key key, @required this.asset}) : super(key: key);

  @override
  _EditAssetScreenState createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> {
  TextEditingController _holdingsTextController;
  bool _error = false;
  Currency _crypto;

  @override
  void initState() {
    super.initState();
    _holdingsTextController =
        TextEditingController(text: widget.asset.amount.toString());
    _crypto = widget.asset.currency;
  }

  @override
  void dispose() {
    _holdingsTextController.dispose();
    super.dispose();
  }

  double validateAndGetHoldings() {
    final text = _holdingsTextController.text;
    if (text.trim() == '') return 0;
    final holdings = double.tryParse(text);
    if (holdings == null) {
      setState(() {
        _error = true;
      });
    }
    return holdings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _EditAssetAppBar(
            asset: widget.asset,
            validateAndGetHoldings: validateAndGetHoldings,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _EditAssetCurrencies(
                asset: widget.asset,
                crypto: _crypto,
                updateCrypto: (currency) {
                  setState(() {
                    _crypto = currency;
                  });
                },
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
                asset: widget.asset,
                holdingsTextController: _holdingsTextController,
                error: _error,
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
    @required this.validateAndGetHoldings,
  }) : super(key: key);

  final Asset asset;
  final double Function() validateAndGetHoldings;

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
            final amount = validateAndGetHoldings();
            if (amount != null) {
              portfolio.updateAsset(asset.copyWith(amount: amount));
              Navigator.of(context).pop();
            }
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
    @required this.updateCrypto,
    this.crypto,
  }) : super(key: key);

  final Asset asset;
  final Currency crypto;
  final void Function(Currency) updateCrypto;

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
            CurrencyListTile(
              selectedCurrency: crypto,
              onSelected: updateCrypto,
              title: 'Cryptocurrency',
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
  _EditAssetHoldings({
    Key key,
    @required this.asset,
    @required this.holdingsTextController,
    this.error = false,
  }) : super(key: key);

  final Asset asset;
  final TextEditingController holdingsTextController;
  final bool error;
  final FocusNode holdingsFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            ListTile(
              onTap: () {
                holdingsFocusNode.requestFocus();
              },
              title: Text('Holdings'),
              trailing: Container(
                width: 150,
                child: TextField(
                  focusNode: holdingsFocusNode,
                  controller: holdingsTextController,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  style: error ? TextStyle(color: Colors.red) : null,
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
