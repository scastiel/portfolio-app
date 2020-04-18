import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:portfolio/coin-gecko-api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/currencies.dart';
import 'model/portfolio.dart';
import 'model/user-preferences.dart';
import 'model/price.dart';

abstract class PricesFetcher {
  void Function() subscribeForCurrency(
      Currency currency, void Function(Price) onUpdate);
  void Function() subscribeToHistoryForCurrency(String currencyId,
      String fiatId, void Function(Map<DateTime, double>) onUpdate);
  Future<void> refresh(BuildContext context);
}

class CoinGeckoPricesFetcher extends PricesFetcher {
  static const currenciesMapping = {'btc': 'bitcoin', 'eth': 'ethereum'};
  final CoinGeckoApi api;

  final UserPreferences userPreferences;
  final Portfolio portfolio;
  final void Function(BuildContext context, {void Function() retry})
      onNetworkError;

  Set<String> get currencyIds =>
      portfolio.assets.map((asset) => asset.currency.id).toSet();
  Set<String> get fiatIds => {
        userPreferences.pricesFiatId,
        userPreferences.holdingsFiatId,
      };

  Map<String, Set<Function(Price)>> _observers = {};
  Set<_HistoryObserver> _historyObservers = {};

  CoinGeckoPricesFetcher({
    @required this.portfolio,
    @required this.userPreferences,
    this.onNetworkError,
  }) : api = CoinGeckoApi();

  Future<bool> _hasPrice(String currencyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().any((key) => key.startsWith('$currencyId-'));
  }

  Future<Price> _getPrice(String currencyId) async {
    final prefs = await SharedPreferences.getInstance();
    final fiatPrices = prefs
        .getKeys()
        .where((key) => key.startsWith('$currencyId-'))
        .fold(
            <String, double>{},
            (fiatPrices, key) => <String, double>{
                  ...fiatPrices,
                  key.split('-').last: prefs.getDouble(key)
                });
    final variation = prefs.getDouble('$currencyId-variation');
    return Price(fiatPrices: fiatPrices, variation: variation);
  }

  Future<void> _setPrice(String currencyId, Price price) async {
    final prefs = await SharedPreferences.getInstance();
    price.fiatPrices.forEach((fiatId, value) {
      prefs.setDouble('$currencyId-$fiatId', value);
    });
    prefs.setDouble('$currencyId-variation', price.variation);
  }

  Future<void> _fetchPrices(BuildContext context) async {
    try {
      final prices = await api.fetchPrices(
        currencyIds: currencyIds,
        fiatIds: fiatIds,
      );
      currencyIds.forEach(
        (currencyId) {
          _setPrice(
            currencyId,
            prices[currencyId],
          );
        },
      );
    } on SocketException catch (_) {
      onNetworkError(context, retry: () {
        refresh(context);
      });
    }
    _notifyObservers();
  }

  Future<void> _fetchHistoryForCurrencyAndFiat(
    BuildContext context,
    String currencyId,
    String fiatId,
  ) async {
    try {
      final history = await api.fetchHistoryForCurrencyAndFiat(
        currencyId: currencyId,
        fiatId: fiatId,
        historyDuration: userPreferences.historyDuration,
      );
      _historyObservers
          .where((o) => o.currencyId == currencyId && o.fiatId == fiatId)
          .forEach(
        (observer) {
          observer.onUpdate(history);
        },
      );
    } on SocketException catch (_) {
      onNetworkError(context, retry: () {
        refresh(context);
      });
    }
  }

  void _fetchHistory(BuildContext context) {
    for (final currencyId in currencyIds) {
      for (final fiatId in fiatIds) {
        _fetchHistoryForCurrencyAndFiat(context, currencyId, fiatId);
      }
    }
  }

  void _notifyObservers() async {
    for (final currencyId in currencyIds) {
      if (_observers.containsKey(currencyId)) {
        for (final callback in _observers[currencyId]) {
          callback(await _getPrice(currencyId));
        }
      }
    }
  }

  void _addObserver(String currencyId, Function(Price) callback) async {
    if (!_observers.containsKey(currencyId)) {
      _observers[currencyId] = {};
    }
    if (await _hasPrice(currencyId)) {
      callback(await _getPrice(currencyId));
    }
    _observers[currencyId].add(callback);
  }

  _removeObserver(String currencyId, Function(Price) callback) {
    if (_observers.containsKey(currencyId)) {
      _observers[currencyId].remove(callback);
    }
  }

  subscribeForCurrency(Currency currency, void Function(Price) onUpdate) {
    _addObserver(currency.id, onUpdate);
    return () => _removeObserver(currency.id, onUpdate);
  }

  @override
  Future<void> refresh(BuildContext context) async {
    await _fetchPrices(context);
    _fetchHistory(context);
  }

  @override
  void Function() subscribeToHistoryForCurrency(
    String currencyId,
    String fiatId,
    void Function(Map<DateTime, double>) onUpdate,
  ) {
    final observer = _HistoryObserver(
      currencyId: currencyId,
      fiatId: fiatId,
      onUpdate: onUpdate,
    );
    _historyObservers.add(observer);
    return () {
      _historyObservers.remove(observer);
    };
  }
}

class _HistoryObserver {
  final String currencyId;
  final String fiatId;
  final void Function(Map<DateTime, double>) onUpdate;

  _HistoryObserver({
    @required this.currencyId,
    @required this.fiatId,
    @required this.onUpdate,
  });
}
