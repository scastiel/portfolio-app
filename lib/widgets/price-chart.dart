import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

charts.Color convertColor(Color color) {
  return charts.Color(
    r: color.red,
    g: color.green,
    b: color.blue,
    a: color.alpha,
  );
}

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
      )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
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
  charts.TimeSeriesChart _chart;

  PriceChartState({
    @required this.values,
    @required this.seriesList,
    @required this.detailed,
  });

  @override
  initState() {
    super.initState();
    _chart = null;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangePlatformBrightness() {
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      setState(() {
        _chart = null;
      });
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _buildChart(context) {
    if (_chart == null) {
      _chart = charts.TimeSeriesChart(
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
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
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
                  minimumPaddingBetweenLabelsPx: 5,
                )
              : new charts.NoneRenderSpec(),
          viewport: detailed ? null : getViewport(values),
        ),
        domainAxis: new charts.DateTimeAxisSpec(
          showAxisLine: false,
          renderSpec: detailed
              ? new charts.SmallTickRendererSpec(
                  labelOffsetFromAxisPx: 10,
                  tickLengthPx: 5,
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
        selectionModels: detailed
            ? [
                new charts.SelectionModelConfig(
                  type: charts.SelectionModelType.info,
                  changedListener: _onSelectionChanged,
                )
              ]
            : null,
        behaviors: [
          new charts.SelectNearest(
            eventTrigger: charts.SelectionTrigger.tapAndDrag,
          ),
        ],
      );
    }
    return _chart;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: _buildChart(context),
        ),
        ...(_selectedTimeSeriesPrice != null
            ? [_buildSelectionInfo(context)]
            : []),
      ],
    );
  }

  _buildSelectionInfo(context) {
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
                DateFormat.Hm().format(_selectedTimeSeriesPrice.date),
                style: TextStyle(fontSize: 10),
              ),
              Text(
                _selectedTimeSeriesPrice.price.toStringAsFixed(2),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onSelectionChanged(charts.SelectionModel model) {
    setState(() {
      _selectedTimeSeriesPrice = model.selectedDatum.first?.datum;
    });
  }

  charts.NumericExtents getViewport(List<double> values) {
    var viewport = charts.NumericExtents.fromValues(values);
    return charts.NumericExtents(
        viewport.min - 0.05 * (viewport.max - viewport.min), viewport.max);
  }
}

class TimeSeriesPrice {
  final DateTime date;
  final double price;

  TimeSeriesPrice(this.date, this.price);
}
