import 'model/currencies.dart';
import 'model/prices.dart';

const currencies = {
  'btc': Currency(id: 'btc', name: 'Bitcoin', symbol: 'BTC'),
  'eth': Currency(id: 'eth', name: 'Ethereum', symbol: 'ETH'),
};

const fiats = {
  'usd': Currency(id: 'usd', name: 'US Dollar', symbol: 'USD'),
  'cad': Currency(id: 'cad', name: 'Canadian Dollar', symbol: 'CAD'),
};

const prices = {
  'btc': Price(fiatPrices: {'usd': 6000, 'cad': 9000}, variation: 1.5),
  'eth': Price(fiatPrices: {'usd': 150, 'cad': 225}, variation: -3.25),
};
