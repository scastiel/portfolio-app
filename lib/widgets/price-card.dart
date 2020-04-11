import 'package:flutter/material.dart';

import 'price-chart.dart';
import 'variation-text.dart';

class PriceCard extends StatelessWidget {
  final Widget title;
  final double variation;
  final String priceText;
  final PriceChart chart;
  final String holdingText;

  const PriceCard({
    @required this.title,
    @required this.variation,
    @required this.priceText,
    @required this.chart,
    this.holdingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Card(
        elevation: 3.0,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [title, VariationText(variation)],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    priceText,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                ...(holdingText != null
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 20),
                          child: Text(
                            holdingText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Theme.of(context).hintColor),
                          ),
                        )
                      ]
                    : []),
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: chart,
              ),
              height: 98,
            )
          ],
        ),
      ),
    );
  }
}
