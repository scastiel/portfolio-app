import 'package:flutter/material.dart';

import 'currencies.dart';

class Asset {
  final Currency currency;
  final double amount;

  const Asset({@required this.currency, @required this.amount});

  Asset copyWith({Currency currency, double amount}) {
    return Asset(
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
    );
  }
}

class Portfolio extends ChangeNotifier {
  List<Asset> _assets;

  Portfolio({@required List<Asset> assets}) {
    _assets = assets;
  }

  List<Asset> get assets => _assets;

  void updateAsset(Asset asset) {
    final index = _assets.indexWhere(
      (element) => element.currency == asset.currency,
    );
    _assets[index] = asset;
    notifyListeners();
  }

  void removeAsset(Asset asset) {
    final index = _assets.indexWhere(
      (element) => element.currency == asset.currency,
    );
    _assets.removeAt(index);
    notifyListeners();
  }
}
