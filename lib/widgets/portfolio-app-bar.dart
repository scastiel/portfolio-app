import 'package:flutter/material.dart';
import 'package:portfolio/model/user-preferences.dart';

import '../model/currencies.dart';
import 'settings-screen.dart';

class PortfolioAppBar extends StatefulWidget {
  final Currencies fiats;
  final UserPreferences userPreferences;
  final void Function(UserPreferences) updatePreferences;

  const PortfolioAppBar({
    Key key,
    @required this.fiats,
    @required this.userPreferences,
    @required this.updatePreferences,
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'My portfolio',
            style: Theme.of(context).textTheme.headline4,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).hintColor),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SettingsScreen(
                    fiats: widget.fiats,
                    userPreferences: widget.userPreferences,
                    updatePreferences: widget.updatePreferences,
                  ),
                  transitionsBuilder: modalTransitionBuilder,
                ),
              );
            },
          ),
        ],
      ),
      centerTitle: false,
      brightness: _brightness,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
