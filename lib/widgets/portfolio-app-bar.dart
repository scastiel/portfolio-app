import 'package:flutter/material.dart';

import 'settings-screen.dart';

class PortfolioAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('My portfolio'),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {
            openSettings(context);
          },
        ),
      ],
      centerTitle: false,
      pinned: true,
      floating: true,
    );
  }
}
