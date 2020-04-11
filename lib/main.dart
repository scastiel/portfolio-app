import 'package:flutter/material.dart';
import 'package:portfolio/chart.dart';
import 'package:portfolio/types.dart';
import 'package:portfolio/fixtures.dart';

void main() {
  runApp(PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      home: Scaffold(
        body: Dashboard(portfolio: portfolio),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final Portfolio portfolio;

  Dashboard({@required this.portfolio});

  @override
  Widget build(BuildContext context) {
    var assetsWithPrices = portfolio.assets
        .map(
          (asset) => AssetWithPrice(
            asset: asset,
            price: prices[asset.currency.id],
          ),
        )
        .toList();
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
            Summary(portfolio: portfolio),
            ...assetsWithPrices.map((assetWithPrice) {
              return PriceCard(
                title: Text(assetWithPrice.asset.currency.name),
                variation: assetWithPrice.price.variation,
                priceText: '${assetWithPrice.price.usd.toStringAsFixed(2)} USD',
                chart: PriceChart.withSampleData(end: assetWithPrice.price.cad),
                holdingText:
                    'Holding: ${(assetWithPrice.asset.amount * assetWithPrice.price.cad).toStringAsFixed(2)} CAD (${assetWithPrice.asset.amount.toString()} ${assetWithPrice.asset.currency.symbol})',
              );
            }),
          ]),
        ),
      ],
    );
  }
}

class PriceCard extends StatelessWidget {
  final Widget title;
  final double variation;
  final String priceText;
  final PriceChart chart;
  final String holdingText;

  PriceCard({
    @required this.title,
    @required this.variation,
    @required this.priceText,
    @required this.chart,
    this.holdingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Card(
        elevation: 3.0,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [title, VariationText(variation)],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    priceText,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                ...(holdingText != null
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 20),
                          child: Text(
                            holdingText,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Theme.of(context).hintColor),
                          ),
                        )
                      ]
                    : []),
              ],
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: chart,
              ),
              height: 98,
            )
          ],
        ),
      ),
    );
  }
}

class Summary extends StatelessWidget {
  final Portfolio portfolio;

  Summary({@required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final totalValue = portfolio.assets.fold<double>(0.0,
        (value, asset) => value + asset.amount * prices[asset.currency.id].cad);
    final variation = portfolio.assets.fold<double>(
        0.0,
        (value, asset) =>
            value +
            prices[asset.currency.id].variation *
                asset.amount *
                prices[asset.currency.id].cad /
                totalValue);
    return PriceCard(
      title: Text('Total value'),
      variation: variation,
      priceText: '${totalValue.toStringAsFixed(2)} CAD',
      chart: PriceChart.withSampleData(end: totalValue),
    );
  }
}

class VariationText extends StatelessWidget {
  final double variation;
  final double fontSize;

  VariationText(this.variation, {this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(2)}% ${variation >= 0 ? '▲' : '▼'}',
      style: TextStyle(
        fontSize: fontSize,
        color: variation >= 0 ? Colors.green : Colors.red,
      ),
    );
  }
}
