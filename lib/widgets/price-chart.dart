import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

charts.Color convertColor(Color color) {
  return charts.Color(
    r: color.red,
    g: color.green,
    b: color.blue,
    a: color.alpha,
  );
}

class PriceChart extends StatelessWidget {
  final double end;
  final int nb;
  final bool detailed;

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  const PriceChart({
    @required this.end,
    this.nb = 60 * 24 ~/ 10,
    this.detailed = false,
  });

  @override
  Widget build(BuildContext context) {
    var values = _getValues();
    var seriesList = [
      new charts.Series<TimeSeriesPrice, DateTime>(
        id: 'Prices',
        domainFn: (TimeSeriesPrice sales, _) => sales.date,
        measureFn: (TimeSeriesPrice sales, _) => sales.price,
        data: _createSeries(values),
      )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: new charts.TimeSeriesChart(
        seriesList,
        defaultRenderer: charts.LineRendererConfig(
          includeArea: true,
          includeLine: detailed,
        ),
        layoutConfig: detailed
            ? charts.LayoutConfig(
                bottomMarginSpec: charts.MarginSpec.fixedPixel(20),
                topMarginSpec: charts.MarginSpec.fixedPixel(0),
                rightMarginSpec: charts.MarginSpec.fixedPixel(35),
                leftMarginSpec: charts.MarginSpec.fixedPixel(0),
              )
            : charts.LayoutConfig(
                bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
                topMarginSpec: charts.MarginSpec.fixedPixel(0),
                rightMarginSpec: charts.MarginSpec.fixedPixel(0),
                leftMarginSpec: charts.MarginSpec.fixedPixel(0),
              ),
        defaultInteractions: detailed,
        primaryMeasureAxis:
            new charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
        secondaryMeasureAxis: new charts.NumericAxisSpec(
          showAxisLine: false,
          renderSpec: detailed
              ? new charts.SmallTickRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 8,
                    color: convertColor(Theme.of(context).hintColor),
                  ),
                  lineStyle: charts.LineStyleSpec(
                    color: convertColor(Theme.of(context).dividerColor),
                  ),
                  minimumPaddingBetweenLabelsPx: 10,
                )
              : new charts.NoneRenderSpec(),
          viewport: detailed ? null : charts.NumericExtents.fromValues(values),
        ),
        domainAxis: new charts.DateTimeAxisSpec(
          renderSpec: detailed
              ? new charts.SmallTickRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 8,
                    color: convertColor(Theme.of(context).hintColor),
                  ),
                  lineStyle: charts.LineStyleSpec(
                    color: convertColor(Theme.of(context).dividerColor),
                  ),
                  minimumPaddingBetweenLabelsPx: 10,
                )
              : new charts.NoneRenderSpec(),
        ),
      ),
    );
  }

  List<double> _getValues() {
    final values = <double>[];
    var value = end;
    final random = Random();
    for (var i = 0; i < nb; i++) {
      values.add(value);
      final factor = (1 + 0.05 * (random.nextDouble() - 0.5));
      value *= factor;
    }
    return values;
  }

  List<TimeSeriesPrice> _createSeries(List<double> values) {
    final timeSeries = <TimeSeriesPrice>[];
    var date = DateTime.now();
    for (var i = 0; i < values.length; i++) {
      timeSeries.add(TimeSeriesPrice(date, values[i]));
      date = date.subtract(Duration(minutes: 10));
    }
    return timeSeries;
  }
}

class TimeSeriesPrice {
  final DateTime date;
  final double price;

  TimeSeriesPrice(this.date, this.price);
}
