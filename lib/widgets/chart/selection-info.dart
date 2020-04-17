import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolio/model/history-duration.dart';
import 'package:portfolio/model/user-preferences.dart';
import 'package:provider/provider.dart';

import '../../helpers.dart';
import '../../model/currencies.dart';
import 'time-series-price.dart';

class SelectionInfo extends StatelessWidget {
  final TimeSeriesPrice timeSeriesPrice;
  final Currency currency;
  final Currency fiat;

  const SelectionInfo({
    Key key,
    @required this.currency,
    @required this.fiat,
    this.timeSeriesPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final historyDuration =
        Provider.of<UserPreferences>(context).historyDuration;
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
                getDateFormatter(historyDuration).format(timeSeriesPrice.date),
                style: TextStyle(fontSize: 10),
              ),
              Text(
                formatPrice(timeSeriesPrice.price, currency: fiat),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateFormat getDateFormatter(HistoryDuration historyDuration) {
    switch (historyDuration) {
      case HistoryDuration.day:
        return DateFormat.Hm();
      case HistoryDuration.threeDays:
        return DateFormat.Hm();
      case HistoryDuration.month:
        return DateFormat.MMMMd().addPattern('\'at\'').add_Hm();
      case HistoryDuration.threeMonths:
        return DateFormat.MMMMd();
      case HistoryDuration.sixMonths:
        return DateFormat.yMMMMd();
      case HistoryDuration.year:
        return DateFormat.yMMMMd();
      case HistoryDuration.twoYears:
        return DateFormat.yMMMMd();
    }
  }
}
