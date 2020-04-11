import 'package:flutter/material.dart';

class Currency {
  final String id;
  final String name;
  final String symbol;
  Currency({@required this.id, @required this.name, @required this.symbol});
}

class Price {
  double usd;
  double cad;
  double variation;
  Price({@required this.usd, @required this.cad, @required this.variation});
}

class Asset {
  final Currency currency;
  final double amount;
  Asset({@required this.currency, @required this.amount});
}

class Portfolio {
  final List<Asset> assets;
  Portfolio({@required this.assets});
}

class AssetWithPrice {
  final Asset asset;
  final Price price;
  AssetWithPrice({@required this.asset, @required this.price});
}
