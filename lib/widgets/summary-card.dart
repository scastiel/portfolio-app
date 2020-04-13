import 'dart:math';

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
  final Currencies currencies;
  final Currencies fiats;
  final PricesFetcher pricesFetcher;

  const Summary({
    @required this.portfolio,
    @required this.userPreferences,
    @required this.currencies,
    @required this.fiats,
    @required this.pricesFetcher,
  });

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  Map<String, Price> _prices = {};
  Map<String, Map<DateTime, double>> _histories = {};
  Set<void Function()> _unsubscribeFromHistoryForCurrencies = {};
  Set<void Function()> _unsubscribeFromCurrencies = {};

  @override
  void initState() {
    super.initState();
    _initPricesFetcher();
  }

  void _initPricesFetcher() {
    widget.portfolio.assets.forEach((asset) {
      _unsubscribeFromCurrencies.add(
        widget.pricesFetcher.subscribeForCurrency(asset.currency, (price) {
          setState(() {
            _prices[asset.currency.id] = price;
          });
        }),
      );
      _unsubscribeFromHistoryForCurrencies.add(
        widget.pricesFetcher.subscribeToHistoryForCurrency(
          asset.currency.id,
          widget.userPreferences.holdingsFiatId,
          (history) {
            setState(() {
              _histories[asset.currency.id] = history;
            });
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _disposePricesFetcher();
    super.dispose();
  }

  void _disposePricesFetcher() {
    _unsubscribeFromHistoryForCurrencies
        .forEach((unsubscribe) => unsubscribe());
    _unsubscribeFromCurrencies.forEach((unsubscribe) => unsubscribe());
  }

  @override
  void didUpdateWidget(Summary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pricesFetcher != widget.pricesFetcher) {
      _disposePricesFetcher();
      _initPricesFetcher();
    }
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

  bool get _historiesInitialized => widget.portfolio.assets
      .every((asset) => _histories.containsKey(asset.currency.id));

  Map<DateTime, double> get _history {
    if (!_historiesInitialized) {
      return null;
    }
    final dates =
        _histories[widget.portfolio.assets.first.currency.id].keys.toList();
    final prices = _histories.entries.map((entry) {
      final currencyId = entry.key;
      final prices = entry.value.values;
      final asset = widget.portfolio.assets
          .firstWhere((asset) => asset.currency.id == currencyId);
      return prices.map((value) => value * asset.amount).toList();
    }).toList();
    final nbElements = prices.fold<int>(prices.first.length,
        (currentMin, prices) => min(prices.length, currentMin));
    final history = <DateTime, double>{};
    for (var i = 0; i < nbElements; i++) {
      history[dates[i]] =
          prices.fold(0.0, (value, element) => value + element[i]);
    }
    return history;
  }

  double get _variation => _pricesInitialized
      ? widget.portfolio.assets.fold<double>(0.0, (value, asset) {
          var price = _prices[asset.currency.id];
          if (price.variation == null) return null;
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
      history: _history,
      fiat: widget.fiats.getCurrency(widget.userPreferences.holdingsFiatId),
    );
  }
}
