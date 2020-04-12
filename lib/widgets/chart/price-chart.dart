import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'chart-with-series.dart';
import 'selection-info.dart';
import 'time-series-price.dart';

class PriceChart extends StatefulWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  final double end;
  final int nb;
  final bool detailed;

  const PriceChart({
    Key key,
    @required this.end,
    this.nb = 60 * 24 ~/ 10,
    this.detailed = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    final values = _getValues();
    final seriesList = [
      new charts.Series<TimeSeriesPrice, DateTime>(
        id: 'Prices',
        domainFn: (TimeSeriesPrice sales, _) => sales.date,
        measureFn: (TimeSeriesPrice sales, _) => sales.price,
        data: _createSeries(values),
      )
        ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
        ..setAttribute(charts.rendererIdKey, 'customArea')
    ];
    return PriceChartState(
        values: values, seriesList: seriesList, detailed: detailed);
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
}

class PriceChartState extends State<PriceChart> with WidgetsBindingObserver {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  final List<double> values;
  final List<charts.Series<TimeSeriesPrice, DateTime>> seriesList;
  final bool detailed;

  TimeSeriesPrice _selectedTimeSeriesPrice;
  Brightness _brightness;

  PriceChartState({
    @required this.values,
    @required this.seriesList,
    @required this.detailed,
  });

  @override
  initState() {
    super.initState();
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: ChartWithSeries(
            seriesList: seriesList,
            viewport: getViewport(values),
            detailed: detailed,
            onSelectionChanged: _onSelectionChanged,
            brightness: _brightness,
          ),
        ),
        ...(_selectedTimeSeriesPrice != null
            ? [SelectionInfo(timeSeriesPrice: _selectedTimeSeriesPrice)]
            : []),
      ],
    );
  }

  _onSelectionChanged(TimeSeriesPrice selectedTimeSeries) {
    setState(() {
      _selectedTimeSeriesPrice = selectedTimeSeries;
    });
  }

  charts.NumericExtents getViewport(List<double> values) {
    var viewport = charts.NumericExtents.fromValues(values);
    return charts.NumericExtents(
        viewport.min - 0.05 * (viewport.max - viewport.min), viewport.max);
  }
}
