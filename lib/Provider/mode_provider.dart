// ignore_for_file: prefer_function_declarations_over_variables, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;

class ThemeMode with ChangeNotifier {
  material.ThemeMode currentTheme = material.ThemeMode.light;

  void switchTheme() {
    if (currentTheme == material.ThemeMode.light) {
      currentTheme = material.ThemeMode.dark;
    } else {
      currentTheme = material.ThemeMode.light;
    }

    notifyListeners();
  }
}
