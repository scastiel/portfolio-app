import 'package:flutter/material.dart';

void main() {
  runApp(PortfolioApp());
}

class Currency {
  final String id;
  final String name;
  final String symbol;
  Currency({@required this.id, @required this.name, @required this.symbol});
}

final currencies = {
  'btc': Currency(id: 'btc', name: 'Bitcoin', symbol: 'BTC'),
  'eth': Currency(id: 'eth', name: 'Ethereum', symbol: 'ETH'),
};

class Price {
  double usd;
  double cad;
  double variation;
  Price({@required this.usd, @required this.cad, @required this.variation});
}

final prices = {
  'btc': Price(usd: 6000, cad: 9000, variation: 1.5),
  'eth': Price(usd: 150, cad: 225, variation: -3.25),
};

class Asset {
  final Currency currency;
  final double amount;
  Asset({@required this.currency, @required this.amount});
}

class Portfolio {
  final List<Asset> assets;
  Portfolio({@required this.assets});
}

final portfolio = Portfolio(assets: [
  Asset(currency: currencies['btc'], amount: 5.4),
  Asset(currency: currencies['eth'], amount: 32.9),
]);

class PortfolioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Portfolio'),
        ),
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
    return ListView(
      children: [
        AssetTable(
          assetsWithPrices: assetsWithPrices,
        )
      ],
    );
  }
}

class AssetWithPrice {
  final Asset asset;
  final Price price;
  AssetWithPrice({@required this.asset, @required this.price});
}

class AssetTableCell extends StatelessWidget {
  final Widget child;

  AssetTableCell({@required this.child});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      ),
    );
  }
}

class AssetTableHeaderCell extends StatelessWidget {
  final String title;
  final TextAlign textAlign;

  AssetTableHeaderCell({@required this.title, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return AssetTableCell(
      child: Text(
        title,
        style: Theme.of(context).textTheme.overline,
        textAlign: this.textAlign,
      ),
    );
  }
}

class AssetTable extends StatelessWidget {
  final List<AssetWithPrice> assetsWithPrices;

  AssetTable({@required this.assetsWithPrices});

  TableRow buildRowForAsset(BuildContext context, AssetWithPrice asset) {
    return TableRow(children: [
      AssetTableCell(child: Text(asset.asset.currency.name)),
      AssetTableCell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${asset.price.usd.toStringAsFixed(2)} USD',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              '${asset.price.variation}% ${asset.price.variation >= 0 ? '▲' : '▼'}',
              style: TextStyle(
                fontSize: 11,
                color: asset.price.variation >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
      AssetTableCell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(asset.asset.amount * asset.price.cad).toStringAsFixed(2)} CAD',
            ),
            Text(
              '${asset.asset.amount.toString()} ${asset.asset.currency.symbol}',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var borderSide = BorderSide(
      width: 1,
      color: Theme.of(context).dividerColor,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: {1: FlexColumnWidth(2.0), 2: FlexColumnWidth(2.0)},
        border: TableBorder(
          horizontalInside: borderSide,
          bottom: borderSide,
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            AssetTableHeaderCell(title: 'Coin'),
            AssetTableHeaderCell(title: 'Price', textAlign: TextAlign.right),
            AssetTableHeaderCell(title: 'Holdings', textAlign: TextAlign.right),
          ]),
          ...this
              .assetsWithPrices
              .map(
                  (assetWithPrice) => buildRowForAsset(context, assetWithPrice))
              .toList()
        ],
      ),
    );
  }
}

class AssetList extends StatelessWidget {
  final List<AssetWithPrice> assetsWithPrices;

  AssetList({@required this.assetsWithPrices});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        itemCount: assetsWithPrices.length * 2,
        itemBuilder: (_, i) {
          if (i.isOdd) return Divider();
          final assetWithPrice = assetsWithPrices[i ~/ 2];
          return ListTile(
            title: AssetListItem(assetWithPrice: assetWithPrice),
          );
        },
      ),
    );
  }
}

class AssetListItem extends StatelessWidget {
  final AssetWithPrice assetWithPrice;

  AssetListItem({@required this.assetWithPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(assetWithPrice.asset.currency.name),
            Text('${assetWithPrice.price.usd.toString()} USD'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${assetWithPrice.asset.amount.toString()} ${assetWithPrice.asset.currency.symbol} = ${(assetWithPrice.asset.amount * assetWithPrice.price.cad).toString()} CAD',
            ),
            Text('+1.2%'),
          ],
        ),
      ],
    );
  }
}
