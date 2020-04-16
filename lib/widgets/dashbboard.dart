import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:provider/provider.dart';

import '../model/portfolio.dart';
import 'asset-card.dart';
import 'duration-button-bar.dart';
import 'portfolio-app-bar.dart';
import 'prices-refresh-indicator.dart';
import 'summary-card.dart';

class Dashboard extends StatefulWidget {
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
    final portfolio = Provider.of<Portfolio>(context, listen: false);
    portfolio.reorderAssets(_assets);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assets == null) {
      final portfolio = Provider.of<Portfolio>(context, listen: false);
      _assets = [...portfolio.assets];
    }
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
