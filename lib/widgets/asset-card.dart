import 'package:flutter/material.dart';
import 'package:portfolio/model/price.dart';

import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/user-preferences.dart';
import '../prices-fetcher.dart';
import 'currency-card.dart';

class AssetCard extends StatefulWidget {
  final Asset asset;
  final UserPreferences userPreferences;
  final Currencies fiats;

  const AssetCard({
    @required this.asset,
    @required this.userPreferences,
    @required this.fiats,
  });

  @override
  _AssetCardState createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  Price _price;
  static final priceFetcher = PricesFetcher();

  @override
  void initState() {
    super.initState();
    priceFetcher.subscribeForCurrency(widget.asset.currency, (price) {
      setState(() {
        _price = price;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CurrencyCard(
      asset: widget.asset,
      price: _price,
      userPreferences: widget.userPreferences,
      fiats: widget.fiats,
    );
  }
}
