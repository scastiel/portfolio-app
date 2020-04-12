import 'package:flutter/material.dart';

import 'chart/price-chart.dart';
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
  bool _animating;

  @override
  initState() {
    super.initState();
    _isExpanded = false;
    _animating = false;
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
      _animating = true;
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
      child: PriceChart(end: end, detailed: true),
      height: 215,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Card(
        elevation: 3.0,
        child: AnimatedContainer(
          height: _isExpanded ? 280 : 98,
          duration: Duration(milliseconds: 200),
          onEnd: () {
            setState(() {
              _animating = false;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: InkWell(
              onTap: _isExpanded ? null : onTap,
              child: Stack(
                children: [
                  ...((!_isExpanded && !_animating)
                      ? [_buildBackgroundChart()]
                      : []),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _isExpanded ? onTap : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [title, VariationText(variation)],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, bottom: 8.0),
                              child: Text(
                                priceText,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...(_isExpanded && !_animating
                          ? [_buildDetailedChart()]
                          : []),
                      ...(!_isExpanded && !_animating && holdingText != null
                          ? [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 14),
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
