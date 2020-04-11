import 'package:flutter/material.dart';

import 'price-chart.dart';
import 'variation-text.dart';

class PriceCard extends StatefulWidget {
  final Widget title;
  final double variation;
  final String priceText;
  final double end;
  final String holdingText;

  const PriceCard({
    @required this.title,
    @required this.variation,
    @required this.priceText,
    @required this.end,
    this.holdingText,
  });

  @override
  State<StatefulWidget> createState() {
    return PriceCardState(
      title: title,
      variation: variation,
      priceText: priceText,
      end: end,
      holdingText: holdingText,
    );
  }
}

class PriceCardState extends State<PriceCard> {
  final Widget title;
  final double variation;
  final String priceText;
  final double end;
  final String holdingText;

  bool _isExpanded;

  @override
  initState() {
    super.initState();
    _isExpanded = false;
  }

  PriceCardState({
    @required this.title,
    @required this.variation,
    @required this.priceText,
    @required this.end,
    this.holdingText,
  });

  void onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  _buildBackgroundChart() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: PriceChart(end: end),
      ),
      height: 98,
    );
  }

  _buildDetailedChart() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: PriceChart(end: end, detailed: true),
      ),
      height: 223,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Card(
        elevation: 3.0,
        child: Container(
          height: _isExpanded ? 280 : 98,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  ...(_isExpanded ? [] : [_buildBackgroundChart()]),
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
                      ...(_isExpanded ? [_buildDetailedChart()] : []),
                      ...(!_isExpanded && holdingText != null
                          ? [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 20),
                                child: Text(
                                  holdingText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                          color: Theme.of(context).hintColor),
                                ),
                              )
                            ]
                          : []),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
