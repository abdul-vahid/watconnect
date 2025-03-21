import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Variable to store the current theme mode
  ThemeMode _themeMode = ThemeMode.light;

  // Getter for the current theme mode
  ThemeMode get themeMode => _themeMode;

  // Method to toggle between light and dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners to rebuild the app with the new theme
  }
}
