import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeProvider() {
    loadTheme();
  }

  void loadTheme() async {
    final box = await Hive.openBox('settings');
    _isDark = box.get('darkMode', defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() async {
    _isDark = !_isDark;

    final box = await Hive.openBox('settings');
    await box.put('darkMode', _isDark);

    notifyListeners();
  }
}
