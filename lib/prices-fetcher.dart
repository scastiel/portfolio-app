import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/currencies.dart';
import 'model/history-duration.dart';
import 'model/portfolio.dart';
import 'model/user-preferences.dart';
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
  static final httpClient = HttpClient();
  static Future<void> _lastCall;

  final UserPreferences userPreferences;
  final Portfolio portfolio;

  Set<String> get currencyIds =>
      portfolio.assets.map((asset) => asset.currency.id).toSet();
  Set<String> get fiatIds => {
        userPreferences.pricesFiatId,
        userPreferences.holdingsFiatId,
      };

  bool _isListening = false;
  Map<String, Set<Function(Price)>> _observers = {};
  Set<_HistoryObserver> _historyObservers = {};

  CoinGeckoPricesFetcher({
    @required this.portfolio,
    @required this.userPreferences,
  });

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
        _setPrice(
            currencyId,
            Price(
              fiatPrices: fiatPrices,
              variation: result[apiCurrencyId]['usd_24h_change'],
            ));
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
      {
        'vs_currency': fiatId,
        'days': getDays(userPreferences.historyDuration).toString()
      },
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
    print('Calling $uri…');
    if (_lastCall != null) {
      await _lastCall;
    }

    Future<void> _makeTheCall() async {
      try {
        final request = await httpClient.getUrl(uri);
        final response = await request.close();
        var json = '';
        await for (final chunk in response.transform(Utf8Decoder())) {
          json += chunk;
        }
        if (json == 'Throttled') {
          await Future.delayed(Duration(seconds: 1));
          return await _callApi(uri);
        }
        final result = JsonCodec().decode(json);
        return result;
      } catch (err) {
        print('Error calling the API at $uri: $err');
      }
    }

    _lastCall = _makeTheCall();
    return _lastCall;
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
