import 'package:flutter/material.dart';

import 'currencies.dart';

class Asset {
  final Currency currency;
  final double amount;
  const Asset({@required this.currency, @required this.amount});
}

class Portfolio {
  final List<Asset> assets;
  const Portfolio({@required this.assets});
}
