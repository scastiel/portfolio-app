import 'package:flutter/material.dart';

class VariationText extends StatelessWidget {
  final double variation;

  const VariationText(this.variation);

  @override
  Widget build(BuildContext context) {
    return variation != null
        ? RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).hintColor.withOpacity(0.3),
              ),
              children: [
                TextSpan(
                  text: '24hr ',
                ),
                TextSpan(
                  text:
                      '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(2)}% ${variation >= 0 ? '▲' : '▼'}',
                  style: TextStyle(
                    color: variation >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          )
        : Text('');
  }
}
