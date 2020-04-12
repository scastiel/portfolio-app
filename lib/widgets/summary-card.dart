import 'package:flutter/material.dart';

import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/price.dart';
import '../model/user-preferences.dart';
import '../prices-fetcher.dart';
import 'price-card.dart';

class Summary extends StatefulWidget {
  final Portfolio portfolio;
  final UserPreferences userPreferences;
  final Currencies fiats;

  const Summary({
    @required this.portfolio,
    @required this.userPreferences,
    @required this.fiats,
  });

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  Map<String, Price> _prices = {};
  static final priceFetcher = PricesFetcher();

  @override
  void initState() {
    super.initState();
    widget.portfolio.assets.forEach((asset) {
      priceFetcher.subscribeForCurrency(asset.currency, (price) {
        setState(() {
          _prices[asset.currency.id] = price;
        });
      });
    });
  }

  bool get _pricesInitialized => widget.portfolio.assets
      .every((asset) => _prices.containsKey(asset.currency.id));

  double get _totalValue => _pricesInitialized
      ? widget.portfolio.assets.fold<double>(
          0.0,
          (value, asset) =>
              value +
              asset.amount *
                  _prices[asset.currency.id]
                      .getInFiat(widget.userPreferences.holdingsFiatId))
      : null;

  double get _variation => _pricesInitialized
      ? widget.portfolio.assets.fold<double>(0.0, (value, asset) {
          var price = _prices[asset.currency.id];
          return value +
              price.variation *
                  asset.amount *
                  price.getInFiat(widget.userPreferences.holdingsFiatId) /
                  _totalValue;
        })
      : null;

  @override
  Widget build(BuildContext context) {
    final holdingsFiat =
        widget.fiats.getCurrency(widget.userPreferences.holdingsFiatId);
    return PriceCard(
      title: Text('Total value'),
      variation: _variation,
      priceText:
          '${_totalValue != null ? _totalValue.toStringAsFixed(2) : '-'} ${holdingsFiat.symbol}',
      end: _totalValue,
    );
  }
}
