import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history-duration.dart';

class UserPreferences extends ChangeNotifier {
  bool _initialized = false;
  String _pricesFiatId;
  String _holdingsFiatId;
  HistoryDuration _historyDuration;

  bool get initialized => _initialized;
  String get pricesFiatId => _pricesFiatId;
  String get holdingsFiatId => _holdingsFiatId;
  HistoryDuration get historyDuration => _historyDuration;

  void initWithSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _pricesFiatId = prefs.getString('prefs.pricesFiatId') ?? 'usd';
    _holdingsFiatId = prefs.getString('prefs.holdingsFiatId') ?? 'cad';
    _historyDuration =
        historyDurationFromString(prefs.getString('prefs.historyDuration')) ??
            HistoryDuration.threeMonths;
    _initialized = true;
    notifyListeners();
  }

  Future<void> _updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prefs.pricesFiatId', pricesFiatId);
    prefs.setString('prefs.holdingsFiatId', holdingsFiatId);
    prefs.setString(
      'prefs.historyDuration',
      historyDurationToString(historyDuration),
    );
  }

  set pricesFiatId(String value) {
    _pricesFiatId = value;
    notifyListeners();
    _updatePrefs();
  }

  set holdingsFiatId(String value) {
    _holdingsFiatId = value;
    notifyListeners();
    _updatePrefs();
  }

  set historyDuration(HistoryDuration value) {
    _historyDuration = value;
    notifyListeners();
    _updatePrefs();
  }
}
