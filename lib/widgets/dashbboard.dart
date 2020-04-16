import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:portfolio/prices-fetcher.dart';
import 'package:provider/provider.dart';

import '../model/portfolio.dart';
import 'asset-card.dart';
import 'duration-button-bar.dart';
import 'portfolio-app-bar.dart';
import 'prices-refresh-indicator.dart';
import 'summary-card.dart';

class DashboardWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final portfolio = Provider.of<Portfolio>(context);
    return Dashboard(portfolio: portfolio);
  }
}

class Dashboard extends StatefulWidget {
  final Portfolio portfolio;

  const Dashboard({
    Key key,
    @required this.portfolio,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Asset> _assets;

  int _indexOfKey(Key key) {
    return _assets.indexWhere((asset) => Key(asset.currency.id) == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = _assets[draggingIndex];
    setState(() {
      _assets.removeAt(draggingIndex);
      _assets.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key _) {
    widget.portfolio.reorderAssets(_assets);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _assets = [...widget.portfolio.assets];
    });
  }

  @override
  void didUpdateWidget(Dashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _assets = [...widget.portfolio.assets];
    });
    Provider.of<PricesFetcher>(context, listen: false).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PricesRefreshIndicator(
      child: ReorderableList(
        onReorder: this._reorderCallback,
        onReorderDone: this._reorderDone,
        child: CustomScrollView(
          slivers: [
            PortfolioAppBar(),
            SliverList(
              delegate: SliverChildListDelegate([
                SummaryWrapper(),
                DurationButtonBar(),
                ..._assets.map(
                  (asset) => ReorderableItem(
                    key: Key(asset.currency.id),
                    childBuilder: (_, state) {
                      return AssetCardWrapper(
                        asset: asset,
                        placeholderMode:
                            state == ReorderableItemState.dragProxy ||
                                state == ReorderableItemState.dragProxyFinished,
                      );
                    },
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
