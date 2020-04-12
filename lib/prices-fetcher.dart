import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:portfolio/model/currencies.dart';
import 'package:portfolio/model/portfolio.dart';
import 'package:portfolio/model/user-preferences.dart';

import 'model/price.dart';

abstract class PricesFetcher {
  void Function() subscribeForCurrency(
      Currency currency, void Function(Price) onUpdate);
  void Function() subscribeToHistoryForCurrency(String currencyId,
      String fiatId, void Function(Map<DateTime, double>) onUpdate);
  Future<void> refresh();
}

class CoinGeckoPricesFetcher extends PricesFetcher {
  static const currenciesMapping = {'btc': 'bitcoin', 'eth': 'ethereum'};

  final Set<String> currencyIds;
  final Set<String> fiatIds;

  final Map<String, Price> _prices = {};
  bool _isListening = false;
  Map<String, Set<Function(Price)>> _observers = {};
  Set<_HistoryObserver> _historyObservers = {};

  CoinGeckoPricesFetcher({@required this.currencyIds, @required this.fiatIds});

  factory CoinGeckoPricesFetcher.forPortfolio({
    @required Portfolio portfolio,
    @required UserPreferences userPreferences,
  }) {
    final currencyIds =
        portfolio.assets.map((asset) => asset.currency.id).toSet();
    final fiatIds = {
      userPreferences.pricesFiatId,
      userPreferences.holdingsFiatId,
    };
    return CoinGeckoPricesFetcher(currencyIds: currencyIds, fiatIds: fiatIds);
  }

  Future<void> _fetchPrices() async {
    final apiCurrencyIds =
        currencyIds.map((currencyId) => currenciesMapping[currencyId]);
    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': apiCurrencyIds.join(','),
      'vs_currencies': fiatIds.join(','),
      'include_24hr_change': 'true'
    });
    final result = await _callApi(uri);
    currencyIds.forEach(
      (currencyId) {
        final apiCurrencyId = currenciesMapping[currencyId];
        final fiatPrices = fiatIds.fold(
          <String, double>{},
          (prices, fiatId) => <String, double>{
            ...prices,
            fiatId: result[apiCurrencyId][fiatId]
          },
        );
        _prices[currencyId] = Price(
          fiatPrices: fiatPrices,
          variation: result[apiCurrencyId]['usd_24h_change'],
        );
      },
    );
    _notifyObservers();
  }

  Future<void> _fetchHistoryForCurrencyAndFiat(
    String currencyId,
    String fiatId,
  ) async {
    final apiCurrencyId = currenciesMapping[currencyId];
    final uri = Uri.https(
      'api.coingecko.com',
      '/api/v3/coins/$apiCurrencyId/market_chart',
      {'vs_currency': fiatId, 'days': '1'},
    );
    final result = await _callApi(uri);
    final history = result['prices'].fold(
      <DateTime, double>{},
      (history, values) => <DateTime, double>{
        ...history,
        DateTime.fromMillisecondsSinceEpoch(values[0]): values[1]
      },
    );
    _historyObservers.forEach((observer) {
      if (observer.currencyId == currencyId && observer.fiatId == fiatId) {
        observer.onUpdate(history);
      }
    });
  }

  Future _callApi(Uri uri) async {
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    var json = '';
    await for (final chunk in response.transform(Utf8Decoder())) {
      json += chunk;
    }
    final result = JsonCodec().decode(json);
    return result;
  }

  void _fetchHistory() {
    for (final currencyId in currencyIds) {
      for (final fiatId in fiatIds) {
        _fetchHistoryForCurrencyAndFiat(currencyId, fiatId);
      }
    }
  }

  _startListening() {
    _isListening = true;
    _fetchPrices();
    _fetchHistory();
  }

  _notifyObservers() {
    currencyIds.forEach((currencyId) {
      if (_observers.containsKey(currencyId)) {
        _observers[currencyId].forEach((callback) {
          callback(_prices[currencyId]);
        });
      }
    });
  }

  _addObserver(String currencyId, Function(Price) callback) {
    if (!_observers.containsKey(currencyId)) {
      _observers[currencyId] = {};
    }
    if (_prices.containsKey(currencyId)) {
      callback(_prices[currencyId]);
    }
    _observers[currencyId].add(callback);
  }

  _removeObserver(String currencyId, Function(Price) callback) {
    if (_observers.containsKey(currencyId)) {
      _observers[currencyId].remove(callback);
    }
  }

  subscribeForCurrency(Currency currency, void Function(Price) onUpdate) {
    if (!_isListening) {
      _startListening();
    }
    _addObserver(currency.id, onUpdate);
    return () => _removeObserver(currency.id, onUpdate);
  }

  @override
  Future<void> refresh() async {
    await _fetchPrices();
    _fetchHistory();
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
    if (!_isListening) {
      _startListening();
    }
    return () => _historyObservers.remove(observer);
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
