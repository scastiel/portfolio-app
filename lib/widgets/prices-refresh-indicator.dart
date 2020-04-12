import 'package:flutter/material.dart';
import 'package:portfolio/prices-fetcher.dart';

class PricesRefreshIndicator extends StatefulWidget {
  final Widget child;
  final PricesFetcher pricesFetcher;

  const PricesRefreshIndicator({
    Key key,
    @required this.child,
    @required this.pricesFetcher,
  }) : super(key: key);

  @override
  _PricesRefreshIndicatorState createState() => _PricesRefreshIndicatorState();
}

class _PricesRefreshIndicatorState extends State<PricesRefreshIndicator> {
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    await widget.pricesFetcher.refresh();
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // displacement: 70,
      onRefresh: _refresh,
      child: widget.child,
    );
  }
}
