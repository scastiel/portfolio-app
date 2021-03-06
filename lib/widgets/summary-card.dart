import 'dart:math';

import 'package:flutter/material.dart';
import 'package:portfolio/model/history.dart';
import 'package:provider/provider.dart';

import '../helpers.dart';
import '../model/currencies.dart';
import '../model/portfolio.dart';
import '../model/price.dart';
import '../model/user-preferences.dart';
import '../prices-fetcher.dart';
import 'price-card.dart';

class SummaryWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Portfolio>(
      builder: (_, portfolio, __) => Consumer<UserPreferences>(
        builder: (_, userPreferences, __) => _Summary(
          portfolio: portfolio,
          userPreferences: userPreferences,
        ),
      ),
    );
  }
}

class _Summary extends StatefulWidget {
  final Portfolio portfolio;
  final UserPreferences userPreferences;

  const _Summary({
    @required this.portfolio,
    @required this.userPreferences,
  });

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<_Summary> {
  Map<String, Price> _prices = {};
  bool _pricesFetcherInitialized = false;
  Map<String, Map<DateTime, History>> _histories = {};
  Set<void Function()> _unsubscribeFromHistoryForCurrencies = {};
  Set<void Function()> _unsubscribeFromCurrencies = {};

  @override
  void initState() {
    super.initState();
  }

  bool get _needsRefresh => widget.portfolio.assets.any((asset) =>
      _prices[asset.currency.id] == null ||
      _histories[asset.currency.id] == null);

  void _initPricesFetcher() {
    final pricesFetcher = Provider.of<PricesFetcher>(context);
    widget.portfolio.assets.forEach((asset) {
      _unsubscribeFromCurrencies.add(
        pricesFetcher.subscribeForCurrency(asset.currency, (price) {
          setState(() {
            _prices[asset.currency.id] = price;
          });
        }),
      );
      _unsubscribeFromHistoryForCurrencies.add(
        pricesFetcher.subscribeToHistoryForCurrency(
          asset.currency.id,
          widget.userPreferences.holdingsFiatId,
          (history) {
            setState(() {
              _histories[asset.currency.id] = history;
            });
          },
        ),
      );

      if (_needsRefresh) {
        setState(() {
          _histories = {};
        });
        pricesFetcher.refresh(context);
      }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_pricesFetcherInitialized) {
      _initPricesFetcher();
      setState(() {
        _pricesFetcherInitialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(_Summary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposePricesFetcher();
    _initPricesFetcher();
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

  Map<DateTime, History> get _history {
    if (!_historiesInitialized) {
      return null;
    }
    final dates =
        _histories[widget.portfolio.assets.first.currency.id].keys.toList();

    final prices = widget.portfolio.assets.map((asset) {
      final prices = _histories[asset.currency.id];
      return prices.entries
          .map((entry) => entry.value.price * asset.amount)
          .toList();
    }).toList();
    final nbElements = prices.fold<int>(prices.first.length,
        (currentMin, prices) => min(prices.length, currentMin));
    final history = <DateTime, History>{};
    for (var i = 0; i < nbElements; i++) {
      history[dates[i]] = History(
          price: prices.fold(0.0, (value, element) => value + element[i]));
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
    final currencies = Provider.of<Currencies>(context);
    final holdingsFiat =
        currencies.getCurrency(widget.userPreferences.holdingsFiatId);
    return PriceCard(
      title: Text('Total value'),
      variation: _variation,
      priceText: formatPrice(_totalValue, currency: holdingsFiat),
      history: _history,
      fiat: currencies.getCurrency(widget.userPreferences.holdingsFiatId),
    );
  }
}
