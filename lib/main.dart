import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/portfolio-app.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({
    Key key,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // @override
  // void initState() {
  //   super.initState();
  //   SharedPreferences.getInstance().then((prefs) {
  //     prefs.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return PortfolioApp();
  }
}
