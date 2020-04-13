import 'package:flutter/material.dart';

class PortfolioAppBar extends StatefulWidget {
  const PortfolioAppBar({
    Key key,
  }) : super(key: key);

  @override
  _PortfolioAppBarState createState() => _PortfolioAppBarState();
}

class _PortfolioAppBarState extends State<PortfolioAppBar>
    with WidgetsBindingObserver {
  Brightness _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = WidgetsBinding.instance.window.platformBrightness;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        'My portfolio',
        style: Theme.of(context).textTheme.headline4,
      ),
      centerTitle: false,
      brightness: _brightness,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
