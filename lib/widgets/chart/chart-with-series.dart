import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:portfolio/model/currencies.dart';
import 'package:portfolio/widgets/chart/selection-info.dart';

import 'time-series-price.dart';

charts.Color convertColor(Color color) {
  return charts.Color(
    r: color.red,
    g: color.green,
    b: color.blue,
    a: color.alpha,
  );
}

class ChartWithSeries extends StatefulWidget {
  final bool detailed;
  final List<charts.Series<TimeSeriesPrice, DateTime>> seriesList;
  final charts.NumericExtents viewport;
  final Brightness brightness;

  final Currency currency;
  final Currency fiat;

  const ChartWithSeries({
    Key key,
    this.detailed = false,
    @required this.seriesList,
    @required this.viewport,
    this.brightness = Brightness.light,
    @required this.currency,
    @required this.fiat,
  }) : super(key: key);

  static final detailedSeriesRenderer = charts.LineRendererConfig<DateTime>(
    customRendererId: 'customArea',
    includeArea: true,
  );
  static final notDetailedSeriesRenderer = charts.LineRendererConfig<DateTime>(
    customRendererId: 'customArea',
    includeArea: true,
    includeLine: false,
  );

  @override
  _ChartWithSeriesState createState() => _ChartWithSeriesState();
}

class _ChartWithSeriesState extends State<ChartWithSeries> {
  TimeSeriesPrice _selectedTimeSeriesPrice;

  ThemeData get _theme => widget.brightness == Brightness.light
      ? ThemeData.light()
      : ThemeData.dark();

  charts.Color get _labelColor => convertColor(_theme.hintColor);

  charts.Color get _lineColor => convertColor(_theme.dividerColor);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _buildChart(context),
      ...(_selectedTimeSeriesPrice != null
          ? [
              SelectionInfo(
                timeSeriesPrice: _selectedTimeSeriesPrice,
                currency: widget.currency,
                fiat: widget.fiat,
              )
            ]
          : []),
    ]);
  }

  Widget _buildChart(BuildContext context) {
    return charts.TimeSeriesChart(
      widget.seriesList,
      animate: false,
      customSeriesRenderers: [
        widget.detailed
            ? ChartWithSeries.detailedSeriesRenderer
            : ChartWithSeries.notDetailedSeriesRenderer
      ],
      layoutConfig: widget.detailed
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
      defaultInteractions: widget.detailed,
      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
      secondaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec:
            charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
        showAxisLine: false,
        renderSpec: widget.detailed
            ? new charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 8,
                  color: _labelColor,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: _lineColor,
                ),
                minimumPaddingBetweenLabelsPx: 5,
              )
            : new charts.NoneRenderSpec(),
        viewport: widget.viewport,
      ),
      domainAxis: new charts.DateTimeAxisSpec(
        showAxisLine: false,
        renderSpec: widget.detailed
            ? new charts.SmallTickRendererSpec(
                labelOffsetFromAxisPx: 10,
                tickLengthPx: 5,
                labelStyle: charts.TextStyleSpec(
                  fontSize: 8,
                  color: _labelColor,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: _lineColor,
                ),
                minimumPaddingBetweenLabelsPx: 10,
              )
            : new charts.NoneRenderSpec(),
      ),
      selectionModels: widget.detailed
          ? [
              new charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: _onSelectionChanged,
                // changedListener: (_) {},
              )
            ]
          : null,
      behaviors: [
        new charts.LinePointHighlighter(
          showHorizontalFollowLine:
              charts.LinePointHighlighterFollowLineType.none,
          showVerticalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest,
        ),
        new charts.SelectNearest(
          eventTrigger: charts.SelectionTrigger.tapAndDrag,
        ),
      ],
    );
  }

  _onSelectionChanged(charts.SelectionModel model) {
    setState(() {
      _selectedTimeSeriesPrice = model.selectedDatum.first?.datum;
    });
  }
}
