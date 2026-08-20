import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider()
    : _isDark =
          Hive.box('settings').get('darkMode', defaultValue: false) as bool;

  bool _isDark;

  bool get isDark => _isDark;

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    await Hive.box('settings').put('darkMode', _isDark);
  }
}
