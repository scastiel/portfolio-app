import 'package:flutter/material.dart';
import 'package:portfolio/widgets/chart/time-series-price.dart';
import 'package:charts_flutter/flutter.dart' as charts;

charts.Color convertColor(Color color) {
  return charts.Color(
    r: color.red,
    g: color.green,
    b: color.blue,
    a: color.alpha,
  );
}

class ChartWithSeries extends StatelessWidget {
  final bool detailed;
  final List<charts.Series<TimeSeriesPrice, DateTime>> seriesList;
  final charts.NumericExtents viewport;
  final void Function(TimeSeriesPrice timeSeriesPrice) onSelectionChanged;
  final Brightness brightness;

  const ChartWithSeries({
    Key key,
    this.detailed = false,
    @required this.seriesList,
    @required this.viewport,
    this.onSelectionChanged,
    this.brightness = Brightness.light,
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

  ThemeData get _theme =>
      brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
  charts.Color get _labelColor => convertColor(_theme.hintColor);
  charts.Color get _lineColor => convertColor(_theme.dividerColor);

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      customSeriesRenderers: [
        detailed ? detailedSeriesRenderer : notDetailedSeriesRenderer
      ],
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
                  color: _labelColor,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: _lineColor,
                ),
                minimumPaddingBetweenLabelsPx: 5,
              )
            : new charts.NoneRenderSpec(),
        viewport: viewport,
      ),
      domainAxis: new charts.DateTimeAxisSpec(
        showAxisLine: false,
        renderSpec: detailed
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

  _onSelectionChanged(charts.SelectionModel model) {
    if (onSelectionChanged != null) {
      onSelectionChanged(model.selectedDatum.first?.datum);
    }
  }
}
