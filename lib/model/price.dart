import 'package:flutter/material.dart';

class Price {
  final Map<String, double> fiatPrices;
  final double variation;

  const Price({
    @required this.fiatPrices,
    @required this.variation,
  });

  double getInFiat(String fiatId) {
    if (fiatPrices.containsKey(fiatId)) {
      return fiatPrices[fiatId];
    }
    throw ArgumentError('Invalid fiat currency ID: $fiatId');
  }
}
