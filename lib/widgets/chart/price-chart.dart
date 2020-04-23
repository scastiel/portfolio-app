import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:portfolio/model/history.dart';
import 'package:portfolio/widgets/chart/time-series-volume.dart';

import '../../model/currencies.dart';
import 'chart-with-series.dart';
import 'time-series-price.dart';

class PriceChart extends StatefulWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  final Map<DateTime, History> history;
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

  Brightness _brightness;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Theme.of(context).brightness != _brightness) {
      setState(() {
        _brightness = Theme.of(context).brightness;
      });
    }
  }

  @override
  didChangePlatformBrightness() {
    setState(() {
      _brightness = Theme.of(context).brightness;
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
        domainFn: (TimeSeriesPrice price, _) => price.date,
        measureFn: (TimeSeriesPrice price, _) => price.price,
        data: widget.history.entries
            .map((entry) => TimeSeriesPrice(entry.key, entry.value.price))
            .toList(),
        colorFn: (datum, index) => convertColor(Theme.of(context).primaryColor),
        areaColorFn: (datum, index) =>
            convertColor(Theme.of(context).primaryColor.withOpacity(0.1)),
      )
        ..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
        ..setAttribute(charts.rendererIdKey, 'customArea'),
      new charts.Series<TimeSeriesVolume, DateTime>(
        id: 'volumes',
        domainFn: (TimeSeriesVolume volume, _) => volume.date,
        measureFn: (TimeSeriesVolume volume, _) => volume.volume,
        areaColorFn: (datum, index) =>
            convertColor(Theme.of(context).primaryColor.withOpacity(0.1)),
        data: widget.history.entries
            .map((entry) => TimeSeriesVolume(entry.key, entry.value.volume))
            .toList(),
      )..setAttribute(charts.rendererIdKey, 'bars'),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ChartWithSeries(
        seriesList: seriesList,
        viewport: _getViewport(widget.history),
        volumeViewport: _getVolumeViewport(widget.history),
        detailed: widget.detailed,
        brightness: _brightness,
        fiat: widget.fiat,
        currency: widget.currency,
      ),
    );
  }

  charts.NumericExtents _getVolumeViewport(Map<DateTime, History> history) {
    var viewport =
        charts.NumericExtents.fromValues(history.values.map((h) => h.volume));
    return charts.NumericExtents(
      viewport.min,
      viewport.max * 10,
    );
  }

  charts.NumericExtents _getViewport(Map<DateTime, History> history) {
    var viewport =
        charts.NumericExtents.fromValues(history.values.map((h) => h.price));
    return charts.NumericExtents(
      viewport.min - 0.05 * (viewport.max - viewport.min),
      viewport.max,
    );
  }
}
