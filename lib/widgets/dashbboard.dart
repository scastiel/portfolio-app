import 'package:flutter/material.dart';
import 'package:portfolio/model/history-duration.dart';
import 'package:portfolio/widgets/asset-card.dart';

import '../model/currencies.dart';
import '../model/user-preferences.dart';
import '../model/portfolio.dart';
import '../prices-fetcher.dart';
import 'duration-button-bar.dart';
import 'portfolio-app-bar.dart';
import 'prices-refresh-indicator.dart';
import 'summary-card.dart';

class Dashboard extends StatelessWidget {
  final Portfolio portfolio;
  final UserPreferences userPreferences;
  final Currencies currencies;
  final Currencies fiats;
  final PricesFetcher pricesFetcher;
  final void Function(HistoryDuration) setHistoryDuration;

  const Dashboard({
    @required this.portfolio,
    @required this.userPreferences,
    @required this.currencies,
    @required this.fiats,
    @required this.pricesFetcher,
    @required this.setHistoryDuration,
  });

  @override
  Widget build(BuildContext context) {
    return PricesRefreshIndicator(
      pricesFetcher: pricesFetcher,
      child: CustomScrollView(
        slivers: [
          PortfolioAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              Summary(
                portfolio: portfolio,
                userPreferences: userPreferences,
                currencies: currencies,
                fiats: fiats,
                pricesFetcher: pricesFetcher,
              ),
              DurationButtonBar(
                selectedHistoryDuration: userPreferences.historyDuration,
                selectHistoryDuration: setHistoryDuration,
              ),
              ...portfolio.assets.map(
                (asset) => AssetCard(
                  asset: asset,
                  userPreferences: userPreferences,
                  fiats: fiats,
                  pricesFetcher: pricesFetcher,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
