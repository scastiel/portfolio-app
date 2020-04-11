import 'package:flutter/material.dart';

import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/prices.dart';
import '../model/user-preferences.dart';
import 'price-card.dart';
import 'price-chart.dart';

class Summary extends StatelessWidget {
  final Portfolio portfolio;
  final Prices prices;
  final UserPreferences userPreferences;
  final Currencies fiats;

  const Summary({
    @required this.portfolio,
    @required this.prices,
    @required this.userPreferences,
    @required this.fiats,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = portfolio.assets.fold<double>(
        0.0,
        (value, asset) =>
            value +
            asset.amount *
                prices
                    .getCurrencyPrice(asset.currency.id)
                    .getInFiat(userPreferences.holdingsFiatId));
    final variation = portfolio.assets.fold<double>(0.0, (value, asset) {
      var price = prices.getCurrencyPrice(asset.currency.id);
      return value +
          price.variation *
              asset.amount *
              price.getInFiat(userPreferences.holdingsFiatId) /
              totalValue;
    });
    final holdingsFiat = fiats.getCurrency(userPreferences.holdingsFiatId);
    return PriceCard(
      title: Text('Total value'),
      variation: variation,
      priceText: '${totalValue.toStringAsFixed(2)} ${holdingsFiat.symbol}',
      chart: PriceChart.withSampleData(end: totalValue),
    );
  }
}
