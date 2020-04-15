import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/portfolio.dart';
import 'asset-card.dart';
import 'duration-button-bar.dart';
import 'portfolio-app-bar.dart';
import 'prices-refresh-indicator.dart';
import 'summary-card.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final portfolio = Provider.of<Portfolio>(context);
    return PricesRefreshIndicator(
      child: CustomScrollView(
        slivers: [
          PortfolioAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              SummaryWrapper(),
              DurationButtonBar(),
              ...portfolio.assets.map(
                (asset) => AssetCardWrapper(asset: asset),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
