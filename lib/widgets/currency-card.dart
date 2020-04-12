import 'package:flutter/material.dart';

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
  final Currencies fiats;

  const CurrencyCard({
    @required this.asset,
    @required this.price,
    @required this.history,
    @required this.userPreferences,
    @required this.fiats,
  });

  @override
  Widget build(BuildContext context) {
    final priceFiat = price?.getInFiat(userPreferences.pricesFiatId);
    final holdingValueFiat = price != null
        ? asset.amount * price.getInFiat(userPreferences.holdingsFiatId)
        : null;
    final pricesFiat = fiats.getCurrency(userPreferences.pricesFiatId);
    final holdingsFiat = fiats.getCurrency(userPreferences.holdingsFiatId);
    return PriceCard(
      title: Text(asset.currency.name),
      currency: asset.currency,
      fiat: fiats.getCurrency(userPreferences.pricesFiatId),
      variation: price?.variation,
      priceText:
          '${priceFiat != null ? priceFiat.toStringAsFixed(2) : '-'} ${pricesFiat.symbol}',
      history: history,
      holdingText:
          'Holding: ${holdingValueFiat != null ? holdingValueFiat.toStringAsFixed(2) : '-'} ${holdingsFiat.symbol} (${asset.amount.toString()} ${asset.currency.symbol})',
    );
  }
}
