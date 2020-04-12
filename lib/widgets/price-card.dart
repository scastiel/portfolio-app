import 'package:flutter/material.dart';

import '../model/currencies.dart';
import 'chart/price-chart.dart';
import 'variation-text.dart';

class PriceCard extends StatefulWidget {
  final Widget title;
  final double variation;
  final String priceText;
  final Map<DateTime, double> history;
  final String holdingText;
  final Currency currency;
  final Currency fiat;

  const PriceCard({
    @required this.title,
    @required this.variation,
    @required this.priceText,
    @required this.history,
    this.currency,
    @required this.fiat,
    this.holdingText,
  });

  @override
  State<StatefulWidget> createState() {
    return PriceCardState();
  }
}

class PriceCardState extends State<PriceCard> {
  bool _isExpanded;
  bool _animating;

  @override
  initState() {
    super.initState();
    _isExpanded = false;
    _animating = false;
  }

  void onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      _animating = true;
    });
  }

  _buildBackgroundChart() {
    if (widget.history == null) return Text('');
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: PriceChart(
          history: widget.history,
          currency: widget.currency,
          fiat: widget.fiat,
        ),
      ),
      height: 98,
    );
  }

  _buildDetailedChart() {
    if (widget.history == null) return Text('');
    return Container(
      child: PriceChart(
        history: widget.history,
        detailed: true,
        currency: widget.currency,
        fiat: widget.fiat,
      ),
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
                                children: [
                                  widget.title,
                                  VariationText(widget.variation)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, bottom: 8.0),
                              child: Text(
                                widget.priceText,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...(_isExpanded && !_animating
                          ? [_buildDetailedChart()]
                          : []),
                      ...(!_isExpanded &&
                              !_animating &&
                              widget.holdingText != null
                          ? [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 14),
                                child: Text(
                                  widget.holdingText,
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
