import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme-mode.dart';
import 'history-duration.dart';

class UserPreferences extends ChangeNotifier {
  bool _initialized = false;
  String _pricesFiatId;
  String _holdingsFiatId;
  HistoryDuration _historyDuration;
  ThemeMode _appTheme;

  bool get initialized => _initialized;
  String get pricesFiatId => _pricesFiatId;
  String get holdingsFiatId => _holdingsFiatId;
  HistoryDuration get historyDuration => _historyDuration;
  ThemeMode get appTheme => _appTheme;

  void initWithSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _pricesFiatId = prefs.getString('prefs.pricesFiatId') ?? 'usd';
    _holdingsFiatId = prefs.getString('prefs.holdingsFiatId') ?? 'usd';
    _historyDuration =
        historyDurationFromString(prefs.getString('prefs.historyDuration')) ??
            HistoryDuration.threeMonths;
    _appTheme =
        themeFromString(prefs.getString('prefs.appTheme')) ?? ThemeMode.system;
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
    prefs.setString(
      'prefs.appTheme',
      themeToString(_appTheme),
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

  set appTheme(ThemeMode value) {
    _appTheme = value;
    notifyListeners();
    _updatePrefs();
  }
}
