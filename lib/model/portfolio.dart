import 'package:flutter/material.dart';

import 'currencies.dart';

class Asset {
  final UniqueKey key;
  final Currency currency;
  final double amount;

  Asset({
    @required this.currency,
    @required this.amount,
    UniqueKey key,
  }) : this.key = key ?? UniqueKey();

  Asset copyWith({Currency currency, double amount}) {
    return Asset(
      key: key,
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

  bool get hasHoldings => _assets.any((asset) => asset.amount > 0);

  int _indexOfAsset(Asset asset) {
    return _assets.indexWhere(
      (element) => element.key == asset.key,
    );
  }

  void updateAsset(Asset asset) {
    _assets[_indexOfAsset(asset)] = asset;
    notifyListeners();
  }

  void removeAsset(Asset asset) {
    _assets.removeAt(_indexOfAsset(asset));
    notifyListeners();
  }

  void reorderAssets(List<Asset> assets) {
    _assets = assets;
    notifyListeners();
  }

  void addAsset(Asset asset) {
    _assets.add(asset);
    notifyListeners();
  }
}
