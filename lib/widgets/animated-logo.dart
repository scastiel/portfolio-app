import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({
    Key key,
  }) : super(key: key);

  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> {
  static const animationDuration = Duration(milliseconds: 500);

  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _switch();
  }

  _switch() {
    if (!mounted) return;
    setState(() {
      _visible = !_visible;
    });
    Future.delayed(animationDuration).then((_) => _switch());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.7,
      duration: animationDuration,
      curve: Curves.easeInSine,
      child: AnimatedContainer(
        duration: animationDuration,
        width: _visible ? 100 : 90,
        height: _visible ? 100 : 90,
        child: Image.asset(
          'assets/abacus_white_x3.png',
        ),
      ),
    );
  }
}
