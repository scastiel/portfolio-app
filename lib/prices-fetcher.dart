import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:portfolio/model/currencies.dart';
import 'package:portfolio/model/portfolio.dart';
import 'package:portfolio/model/user-preferences.dart';

import 'fixtures.dart';
import 'model/price.dart';

abstract class PricesFetcher {
  subscribeForCurrency(Currency currency, void Function(Price) onUpdate);
}

class CoinGeckoPricesFetcher extends PricesFetcher {
  static const currenciesMapping = {'btc': 'bitcoin', 'eth': 'ethereum'};

  final Set<String> currencyIds;
  final Set<String> fiatIds;

  final Map<String, Price> _prices = {};
  bool _isListening = false;
  Map<String, Set<Function(Price)>> _observers = {};

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

  _fetchPrices() async {
    final apiCurrencyIds =
        currencyIds.map((currencyId) => currenciesMapping[currencyId]);
    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': apiCurrencyIds.join(','),
      'vs_currencies': fiatIds.join(','),
      'include_24hr_change': 'true'
    });
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    final json = await response.transform(Utf8Decoder()).first;
    final result = JsonCodec().decode(json);
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

  _startListening() {
    _isListening = true;
    _fetchPrices();
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

  subscribeForCurrency(Currency currency, void Function(Price) onUpdate) {
    if (!_isListening) {
      _startListening();
    }
    _addObserver(currency.id, onUpdate);
  }
}

class MockPricesFetcher extends PricesFetcher {
  final Map<String, Price> _prices = {};
  static final random = Random();

  subscribeForCurrency(Currency currency, void Function(Price) onUpdate) {
    void _updatePrice() {
      if (_prices[currency.id] == null) {
        _prices[currency.id] = prices[currency.id];
      } else {
        final factor = (1 + 0.0001 * (random.nextDouble() - 0.5));
        _prices[currency.id] = Price(fiatPrices: {
          'usd': _prices[currency.id].fiatPrices['usd'] * factor,
          'cad': _prices[currency.id].fiatPrices['cad'] * factor
        }, variation: _prices[currency.id].variation * factor);
      }
      Future.delayed(Duration(milliseconds: 300))
          .then((_) => onUpdate(_prices[currency.id]));
      Future.delayed(Duration(seconds: 5)).then((_) => _updatePrice());
    }

    _updatePrice();
  }
}
