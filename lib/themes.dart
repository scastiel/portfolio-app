import 'package:flutter/material.dart';

final MaterialColor _lightThemeColor = Colors.blue;
final lightTheme = ThemeData(
  primaryColor: _lightThemeColor,
  accentColor: _lightThemeColor,
  backgroundColor: _lightThemeColor.withOpacity(0.2),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: _lightThemeColor,
    brightness: Brightness.light,
  ).copyWith(secondary: _lightThemeColor),
);

final MaterialColor _darkThemeColor = Colors.blueGrey;
final darkTheme = ThemeData.dark().copyWith(
  primaryColor: _darkThemeColor,
  accentColor: _darkThemeColor,
  backgroundColor: _darkThemeColor.withOpacity(0.2),
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.grey[900],
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: _darkThemeColor,
    brightness: Brightness.dark,
  ).copyWith(secondary: _darkThemeColor),
);
