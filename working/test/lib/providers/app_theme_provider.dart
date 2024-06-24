import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_theme_provider.g.dart';

@riverpod
class AppTheme extends _$AppTheme {
  final darkTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.grey,
    primaryColor: Colors.black,
    brightness: Brightness.dark,
    dividerColor: Colors.black12,
    appBarTheme: AppBarTheme(
      color: Colors.grey[800],
    ),
  );

  final lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    primaryColor: Colors.white,
    brightness: Brightness.light,
    dividerColor: Colors.white54,
    appBarTheme: const AppBarTheme(
      color: Colors.blue,
    ),
  );

  @override
  ThemeData build() {
    return true;
  }

  void changeToDarkTheme() {
    state = darkTheme;
  }

  void changeToLightTheme() {
    state = lightTheme;
  }

  void toggleTheme() {
    final isDarkTheme = state.brightness == Brightness.dark;
    switch (isDarkTheme) {
      case true:
        changeToLightTheme();
        break;
      case false:
        changeToDarkTheme();
        break;
    }
  }
}
