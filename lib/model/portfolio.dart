import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _initialized = false;

  Portfolio({List<Asset> assets}) {
    _assets = assets;
  }

  List<Asset> get assets => _assets;
  bool get initialized => _initialized;

  bool get hasHoldings =>
      _initialized && _assets.any((asset) => asset.amount > 0);

  int _indexOfAsset(Asset asset) {
    return _assets.indexWhere(
      (element) => element.key == asset.key,
    );
  }

  void updateAsset(Asset asset) {
    _assets[_indexOfAsset(asset)] = asset;
    notifyListeners();
    saveInPrefs();
  }

  void removeAsset(Asset asset) {
    _assets.removeAt(_indexOfAsset(asset));
    notifyListeners();
    saveInPrefs();
  }

  void reorderAssets(List<Asset> assets) {
    _assets = assets;
    notifyListeners();
    saveInPrefs();
  }

  void addAsset(Asset asset) {
    _assets.add(asset);
    notifyListeners();
    saveInPrefs();
  }

  Map<String, dynamic> toJson() {
    return {
      'assets': assets
          .map((asset) =>
              {'currencyId': asset.currency.id, 'amount': asset.amount})
          .toList()
    };
  }

  _initFromJson(Map<String, dynamic> json, {Currencies currencies}) {
    _assets = (json['assets'] as List<dynamic>)
        .map(
          (assetJson) => Asset(
            currency: currencies.getCurrency(assetJson['currencyId']),
            amount: assetJson['amount'],
          ),
        )
        .toList();
  }

  void saveInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('portfolio', jsonEncode(toJson()));
  }

  void initWithSharedPrefs({Currencies currencies}) async {
    final prefs = await SharedPreferences.getInstance();
    final portfolioString = prefs.getString('portfolio');
    if (portfolioString != null) {
      _initFromJson(jsonDecode(portfolioString), currencies: currencies);
    } else {
      _assets = [];
    }
    _initialized = true;
    notifyListeners();
  }
}
