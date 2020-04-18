import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../prices-fetcher.dart';

class PricesRefreshIndicator extends StatefulWidget {
  final Widget child;

  const PricesRefreshIndicator({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _PricesRefreshIndicatorState createState() => _PricesRefreshIndicatorState();
}

class _PricesRefreshIndicatorState extends State<PricesRefreshIndicator> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_isRefreshing) return;
        final pricesFetcher =
            Provider.of<PricesFetcher>(context, listen: false);
        setState(() {
          _isRefreshing = true;
        });
        await pricesFetcher.refresh(context);
        setState(() {
          _isRefreshing = false;
        });
      },
      child: widget.child,
    );
  }
}
