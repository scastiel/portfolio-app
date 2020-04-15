import 'package:flutter/material.dart';
import 'package:portfolio/model/history-duration.dart';
import 'package:provider/provider.dart';

import '../model/price.dart';
import '../model/portfolio.dart';
import '../model/user-preferences.dart';
import '../prices-fetcher.dart';
import 'currency-card.dart';

class AssetCardWrapper extends StatelessWidget {
  final Asset asset;

  const AssetCardWrapper({
    @required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PricesFetcher>(
      builder: (_, pricesFetcher, __) => Consumer<UserPreferences>(
        builder: (_, userPreferences, __) => _AssetCard(
          asset: asset,
          pricesFetcher: pricesFetcher,
          userPreferences: userPreferences,
        ),
      ),
    );
  }
}

class _AssetCard extends StatefulWidget {
  final Asset asset;
  final PricesFetcher pricesFetcher;
  final UserPreferences userPreferences;

  const _AssetCard({
    @required this.asset,
    @required this.pricesFetcher,
    @required this.userPreferences,
  });

  @override
  _AssetCardState createState() => _AssetCardState();
}

class _AssetCardState extends State<_AssetCard> {
  Price _price;
  Map<DateTime, double> _history;
  HistoryDuration _historyDuration;
  bool _pricesFetcherInitialized = false;
  void Function() _unsubscribeFromCurrency;
  void Function() _unsubscribeFromHistoryForCurrency;

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
  void didUpdateWidget(_AssetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userPreferences.historyDuration != _historyDuration) {
      _disposePricesFetcher();
      setState(() {
        _history = null;
      });
      _initPricesFetcher();
    }
  }

  void _initPricesFetcher() {
    setState(() {
      _historyDuration = widget.userPreferences.historyDuration;
    });
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

  void _disposePricesFetcher() {
    if (_unsubscribeFromHistoryForCurrency != null) {
      _unsubscribeFromHistoryForCurrency();
    }
    if (_unsubscribeFromCurrency != null) {
      _unsubscribeFromCurrency();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _disposePricesFetcher();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CurrencyCard(
      asset: widget.asset,
      price: _price,
      history: _history,
      userPreferences: widget.userPreferences,
    );
  }
}
