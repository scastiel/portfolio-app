import 'dart:convert';
import 'dart:io';

import 'package:portfolio/model/currencies.dart';

import 'model/history-duration.dart';
import 'model/price.dart';

class BasicApi {
  static final httpClient = HttpClient();

  Map<Uri, Future> _debouncedApiCalls = {};

  Future call(Uri uri) {
    if (_debouncedApiCalls.containsKey(uri)) return _debouncedApiCalls[uri];
    var result = _rawCall(uri);
    _debouncedApiCalls[uri] = result;
    Future.delayed(Duration(milliseconds: 100))
        .then((_) => _debouncedApiCalls.remove(uri));
    return result;
  }

  Future _rawCall(Uri uri) async {
    print('Calling $uri…');
    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      var json = '';
      await for (final chunk in response.transform(Utf8Decoder())) {
        json += chunk;
      }
      // if (json == 'Throttled') {
      //   await Future.delayed(Duration(seconds: 1));
      //   return await _rawCall(uri);
      // }
      final result = JsonCodec().decode(json);
      return result;
    } catch (err) {
      print('Error calling the API at $uri: $err');
      throw err;
    }
  }
}

class CoinGeckoApi {
  static final baseUri = 'api.coingecko.com';
  static final _api = BasicApi();

  Future<Map<String, Price>> fetchPrices({
    Set<String> currencyIds,
    Set<String> fiatIds,
  }) async {
    if (currencyIds.length == 0) return <String, Price>{};

    final uri = Uri.https(baseUri, '/api/v3/simple/price', {
      'ids': currencyIds.join(','),
      'vs_currencies': fiatIds.join(','),
      'include_24hr_change': 'true'
    });
    final result = await _api.call(uri);

    return currencyIds.fold<Map<String, Price>>(
      <String, Price>{},
      (acc, currencyId) {
        final fiatPrices = fiatIds.fold(
          <String, double>{},
          (prices, fiatId) => <String, double>{
            ...prices,
            fiatId: 1.0 * result[currencyId][fiatId]
          },
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
    HistoryDuration historyDuration,
  }) async {
    final uri = Uri.https(
      baseUri,
      '/api/v3/coins/$currencyId/market_chart',
      {'vs_currency': fiatId, 'days': getDays(historyDuration).toString()},
    );
    final result = await _api.call(uri);
    return result['prices'].fold(
      <DateTime, double>{},
      (history, values) => <DateTime, double>{
        ...history,
        DateTime.fromMillisecondsSinceEpoch(values[0]): values[1]
      },
    );
  }

  Future<Set<Currency>> fetchCurrencies() async {
    final uri = Uri.https(baseUri, '/api/v3/coins/list');
    final List result = await _api.call(uri);
    final currencies = result
        .map(
          (coin) => Currency(
            id: coin['id'],
            symbol: (coin['symbol'] as String).toUpperCase(),
            name: coin['name'],
          ),
        )
        .toSet();
    return currencies;
  }

  Future<Set<Currency>> fetchFiats() async {
    final uri = Uri.https(baseUri, '/api/v3/simple/supported_vs_currencies');
    final List result = await _api.call(uri);
    return result
        .map(
          (symbol) => Currency(
            id: symbol,
            symbol: (symbol as String).toUpperCase(),
            name: fiatNames[symbol] ?? (symbol as String).toUpperCase(),
            fiat: true,
          ),
        )
        .toSet();
  }
}

final fiatNames = {
  'aed': 'United Arab Emirates Dirham',
  'ars': 'Argentine Peso',
  'aud': 'Australian Dollar',
  'bch': 'Bitcoin Cash',
  'bdt': 'Bangladeshi Taka',
  'bhd': 'Bahraini Dinar',
  'bmd': 'Bermudian Dollar',
  'bnb': 'Binance Coin',
  'brl': 'Brazil Real',
  'btc': 'Bitcoin',
  'cad': 'Canadian Dollar',
  'chf': 'Swiss Franc',
  'clp': 'Chilean Peso',
  'cny': 'Chinese Yuan',
  'czk': 'Czech Koruna',
  'dkk': 'Danish Krone',
  'eos': 'EOS',
  'eth': 'Ether',
  'eur': 'Euro',
  'gbp': 'British Pound Sterling',
  'hkd': 'Hong Kong Dollar',
  'huf': 'Hungarian Forint',
  'idr': 'Indonesian Rupiah',
  'ils': 'Israeli New Shekel',
  'inr': 'Indian Rupee',
  'jpy': 'Japanese Yen',
  'krw': 'South Korean Won',
  'kwd': 'Kuwaiti Dinar',
  'lkr': 'Sri Lankan Rupee',
  'ltc': 'Litecoin',
  'mmk': 'Burmese Kyat',
  'mxn': 'Mexican Peso',
  'myr': 'Malaysian Ringgit',
  'nok': 'Norwegian Krone',
  'nzd': 'New Zealand Dollar',
  'php': 'Philippine Peso',
  'pkr': 'Pakistani Rupee',
  'pln': 'Polish Zloty',
  'rub': 'Russian Ruble',
  'sar': 'Saudi Riyal',
  'sek': 'Swedish Krona',
  'sgd': 'Singapore Dollar',
  'thb': 'Thai Baht',
  'try': 'Turkish Lira',
  'twd': 'New Taiwan Dollar',
  'uah': 'Ukrainian hryvnia',
  'usd': 'US Dollar',
  'vef': 'Venezuelan bolívar fuerte',
  'vnd': 'Vietnamese đồng',
  'xdr': 'IMF Special Drawing Rights',
  'xlm': 'Lumens',
  'xrp': 'XRP',
  'zar': 'South African Rand',
};
