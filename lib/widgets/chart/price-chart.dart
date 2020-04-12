import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../model/currencies.dart';
import 'chart-with-series.dart';
import 'selection-info.dart';
import 'time-series-price.dart';

class PriceChart extends StatefulWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  final Map<DateTime, double> history;
  final bool detailed;
  final Currency currency;
  final Currency fiat;

  const PriceChart({
    Key key,
    @required this.history,
    @required this.currency,
    @required this.fiat,
    this.detailed = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PriceChartState();
  }
}

class PriceChartState extends State<PriceChart> with WidgetsBindingObserver {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  TimeSeriesPrice _selectedTimeSeriesPrice;
  Brightness _brightness;

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
    final seriesList = [
      new charts.Series<TimeSeriesPrice, DateTime>(
        id: 'prices',
        domainFn: (TimeSeriesPrice sales, _) => sales.date,
        measureFn: (TimeSeriesPrice sales, _) => sales.price,
        data: widget.history.entries
            .map((entry) => TimeSeriesPrice(entry.key, entry.value))
            .toList(),
      )
        ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
        ..setAttribute(charts.rendererIdKey, 'customArea')
    ];
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: ChartWithSeries(
            seriesList: seriesList,
            viewport: _getViewport(widget.history),
            detailed: widget.detailed,
            onSelectionChanged: _onSelectionChanged,
            brightness: _brightness,
          ),
        ),
        ...(_selectedTimeSeriesPrice != null
            ? [
                SelectionInfo(
                  timeSeriesPrice: _selectedTimeSeriesPrice,
                  currency: widget.currency,
                  fiat: widget.fiat,
                )
              ]
            : []),
      ],
    );
  }

  _onSelectionChanged(TimeSeriesPrice selectedTimeSeries) {
    setState(() {
      _selectedTimeSeriesPrice = selectedTimeSeries;
    });
  }

  charts.NumericExtents _getViewport(Map<DateTime, double> history) {
    var viewport = charts.NumericExtents.fromValues(history.values);
    return charts.NumericExtents(
      viewport.min - 0.05 * (viewport.max - viewport.min),
      viewport.max,
    );
  }
}
