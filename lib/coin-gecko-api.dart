import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'model/history-duration.dart';
import 'model/price.dart';
import 'model/user-preferences.dart';

class CoinGeckoApi {
  static final httpClient = HttpClient();

  final UserPreferences userPreferences;

  Map<Uri, Future> _debouncedApiCalls = {};

  CoinGeckoApi({@required this.userPreferences});

  Future _debounceCallApi(Uri uri) {
    if (_debouncedApiCalls.containsKey(uri)) return _debouncedApiCalls[uri];
    var result = _callApi(uri);
    _debouncedApiCalls[uri] = result;
    Future.delayed(Duration(milliseconds: 100))
        .then((_) => _debouncedApiCalls.remove(uri));
    return result;
  }

  Future _callApi(Uri uri) async {
    print('Calling $uri…');
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

  Future<Map<String, Price>> fetchPrices({
    Set<String> currencyIds,
    Set<String> fiatIds,
  }) async {
    if (currencyIds.length == 0) return <String, Price>{};

    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': currencyIds.join(','),
      'vs_currencies': fiatIds.join(','),
      'include_24hr_change': 'true'
    });
    final result = await _debounceCallApi(uri);

    return currencyIds.fold<Map<String, Price>>(
      <String, Price>{},
      (acc, currencyId) {
        final fiatPrices = fiatIds.fold(
          <String, double>{},
          (prices, fiatId) =>
              <String, double>{...prices, fiatId: result[currencyId][fiatId]},
        );

        return <String, Price>{
          ...acc,
          currencyId: Price(
            fiatPrices: fiatPrices,
            variation: result[currencyId]['usd_24h_change'],
          )
        };
      },
    );
  }

  Future<Map<DateTime, double>> fetchHistoryForCurrencyAndFiat({
    String currencyId,
    String fiatId,
  }) async {
    final uri = Uri.https(
      'api.coingecko.com',
      '/api/v3/coins/$currencyId/market_chart',
      {
        'vs_currency': fiatId,
        'days': getDays(userPreferences.historyDuration).toString()
      },
    );
    final result = await _debounceCallApi(uri);
    return result['prices'].fold(
      <DateTime, double>{},
      (history, values) => <DateTime, double>{
        ...history,
        DateTime.fromMillisecondsSinceEpoch(values[0]): values[1]
      },
    );
  }
}
