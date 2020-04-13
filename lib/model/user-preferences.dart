import 'package:flutter/material.dart';
import 'package:portfolio/model/history-duration.dart';

class UserPreferences {
  final String pricesFiatId;
  final String holdingsFiatId;
  final HistoryDuration historyDuration;

  const UserPreferences({
    @required this.pricesFiatId,
    @required this.holdingsFiatId,
    @required this.historyDuration,
  });

  UserPreferences copyWith({
    String pricesFiatId,
    String holdingsFiatId,
    HistoryDuration historyDuration,
  }) {
    return UserPreferences(
      pricesFiatId: pricesFiatId ?? this.pricesFiatId,
      holdingsFiatId: holdingsFiatId ?? this.holdingsFiatId,
      historyDuration: historyDuration ?? this.historyDuration,
    );
  }
}
