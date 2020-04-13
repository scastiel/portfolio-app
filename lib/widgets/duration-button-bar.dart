import 'package:flutter/material.dart';

import '../model/history-duration.dart';

class DurationButtonBar extends StatelessWidget {
  final HistoryDuration selectedHistoryDuration;
  final void Function(HistoryDuration) selectHistoryDuration;

  const DurationButtonBar({
    Key key,
    @required this.selectedHistoryDuration,
    @required this.selectHistoryDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Transform(
        transform: new Matrix4.identity()..scale(0.75),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: HistoryDuration.values
              .map(
                (historyDuration) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: HistoryDurationChip(
                    historyDuration: historyDuration,
                    selected: selectedHistoryDuration == historyDuration,
                    setSelected: () {
                      selectHistoryDuration(historyDuration);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class HistoryDurationChip extends StatelessWidget {
  final HistoryDuration historyDuration;
  final bool selected;
  final void Function() setSelected;

  const HistoryDurationChip({
    Key key,
    @required this.historyDuration,
    @required this.selected,
    @required this.setSelected,
  }) : super(key: key);

  String _getLabel() {
    switch (historyDuration) {
      case HistoryDuration.day:
        return '24h';
      case HistoryDuration.threeDays:
        return '3d';
      case HistoryDuration.month:
        return '1m';
      case HistoryDuration.threeMonths:
        return '3m';
      case HistoryDuration.sixMonths:
        return '6m';
      case HistoryDuration.year:
        return '1y';
      case HistoryDuration.twoYears:
        return '2y';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(_getLabel()),
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).accentColor
            : Theme.of(context).hintColor,
      ),
      // selectedColor: Theme.of(context).primaryColor,
      selected: selected,
      onSelected: (_) {
        setSelected();
      },
    );
  }
}
