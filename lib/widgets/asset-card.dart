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
  final PricesFetcher pricesFetcher;

  const AssetCard({
    @required this.asset,
    @required this.userPreferences,
    @required this.fiats,
    @required this.pricesFetcher,
  });

  @override
  _AssetCardState createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  Price _price;
  Map<DateTime, double> _history;
  void Function() _unsubscribeFromCurrency;
  void Function() _unsubscribeFromHistoryForCurrency;

  @override
  void initState() {
    super.initState();
    _unsubscribeFromCurrency = widget.pricesFetcher.subscribeForCurrency(
      widget.asset.currency,
      (price) {
        setState(() {
          _price = price;
        });
      },
    );
    _unsubscribeFromHistoryForCurrency =
        widget.pricesFetcher.subscribeToHistoryForCurrency(
      widget.asset.currency.id,
      widget.userPreferences.pricesFiatId,
      (history) {
        setState(() {
          _history = history;
        });
      },
    );
  }

  @override
  void dispose() {
    if (_unsubscribeFromHistoryForCurrency != null) {
      _unsubscribeFromHistoryForCurrency();
    }
    if (_unsubscribeFromCurrency != null) {
      _unsubscribeFromCurrency();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CurrencyCard(
      asset: widget.asset,
      price: _price,
      history: _history,
      userPreferences: widget.userPreferences,
      fiats: widget.fiats,
    );
  }
}
