import 'package:flutter/material.dart';

class UserPreferences {
  final String pricesFiatId;
  final String holdingsFiatId;
  const UserPreferences({
    @required this.pricesFiatId,
    @required this.holdingsFiatId,
  });
}
