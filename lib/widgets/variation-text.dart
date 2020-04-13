import 'package:flutter/material.dart';

class VariationText extends StatelessWidget {
  final double variation;

  const VariationText(this.variation);

  @override
  Widget build(BuildContext context) {
    return variation != null
        ? Text(
            '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(2)}% ${variation >= 0 ? '▲' : '▼'}',
            style: TextStyle(
              fontSize: 11,
              color: variation >= 0 ? Colors.green : Colors.red,
            ),
          )
        : Text('');
  }
}
