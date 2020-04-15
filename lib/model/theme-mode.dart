import 'package:flutter/material.dart';

String themeToString(ThemeMode theme) {
  switch (theme) {
    case ThemeMode.system:
      return 'system';
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
  }
}

ThemeMode themeFromString(String str) {
  switch (str) {
    case 'system':
      return ThemeMode.system;
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
  }
}
