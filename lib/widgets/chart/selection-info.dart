import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'time-series-price.dart';

class SelectionInfo extends StatelessWidget {
  final TimeSeriesPrice timeSeriesPrice;

  const SelectionInfo({
    Key key,
    this.timeSeriesPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.fromBorderSide(
            BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.Hm().format(timeSeriesPrice.date),
                style: TextStyle(fontSize: 10),
              ),
              Text(
                timeSeriesPrice.price.toStringAsFixed(2),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
