import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class PriceChart extends StatelessWidget {
  final List<charts.Series<TimeSeriesPrice, DateTime>> seriesList;
  final bool animate;

  const PriceChart(this.seriesList, {this.animate});

  factory PriceChart.withSampleData({@required double end}) {
    return new PriceChart(_createSampleData(end: end), animate: false);
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      defaultRenderer:
          charts.LineRendererConfig(includeArea: true, includeLine: false),
      layoutConfig: charts.LayoutConfig(
        bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
        topMarginSpec: charts.MarginSpec.fixedPixel(0),
        rightMarginSpec: charts.MarginSpec.fixedPixel(0),
        leftMarginSpec: charts.MarginSpec.fixedPixel(0),
      ),
      defaultInteractions: false,
      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
      domainAxis:
          new charts.DateTimeAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }

  static List<charts.Series<TimeSeriesPrice, DateTime>> _createSampleData({
    @required double end,
    int nb = 60,
  }) {
    final timeSeries = <TimeSeriesPrice>[];
    var date = DateTime.now();
    var value = end;
    final random = Random();
    for (var i = 0; i < nb; i++) {
      timeSeries.add(TimeSeriesPrice(date, value));
      date = date.subtract(Duration(minutes: 1));
      value = value * (1 + 0.5 * (random.nextDouble() - 0.5));
    }

    return [
      new charts.Series<TimeSeriesPrice, DateTime>(
        id: 'Prices',
        domainFn: (TimeSeriesPrice sales, _) => sales.date,
        measureFn: (TimeSeriesPrice sales, _) => sales.price,
        data: timeSeries,
      )
    ];
  }
}

class TimeSeriesPrice {
  final DateTime date;
  final double price;

  TimeSeriesPrice(this.date, this.price);
}
