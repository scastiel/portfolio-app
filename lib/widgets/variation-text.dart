import 'package:flutter/material.dart';

class VariationText extends StatelessWidget {
  final double variation;
  final double fontSize;

  const VariationText(this.variation, {this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(2)}% ${variation >= 0 ? '▲' : '▼'}',
      style: TextStyle(
        fontSize: fontSize,
        color: variation >= 0 ? Colors.green : Colors.red,
      ),
    );
  }
}
