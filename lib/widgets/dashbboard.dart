import 'package:flutter/material.dart';
import 'package:portfolio/widgets/asset-card.dart';

import '../model/currencies.dart';
import '../model/user-preferences.dart';
import '../model/portfolio.dart';
import 'summary-card.dart';

class Dashboard extends StatelessWidget {
  final Portfolio portfolio;
  final UserPreferences userPreferences;
  final Currencies fiats;

  const Dashboard({
    @required this.portfolio,
    @required this.userPreferences,
    @required this.fiats,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            'My portfolio',
            style: Theme.of(context).textTheme.headline4,
          ),
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Summary(
              portfolio: portfolio,
              userPreferences: userPreferences,
              fiats: fiats,
            ),
            ...portfolio.assets.map(
              (asset) => AssetCard(
                asset: asset,
                userPreferences: userPreferences,
                fiats: fiats,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}