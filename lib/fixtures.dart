import 'package:portfolio/types.dart';

final currencies = {
  'btc': Currency(id: 'btc', name: 'Bitcoin', symbol: 'BTC'),
  'eth': Currency(id: 'eth', name: 'Ethereum', symbol: 'ETH'),
};

final prices = {
  'btc': Price(usd: 6000, cad: 9000, variation: 1.5),
  'eth': Price(usd: 150, cad: 225, variation: -3.25),
};

final portfolio = Portfolio(assets: [
  Asset(currency: currencies['btc'], amount: 5.4),
  Asset(currency: currencies['eth'], amount: 32.9),
]);
