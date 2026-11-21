import 'package:flutter/material.dart';

const pine = Color(0xff26382b);
const leaf = Color(0xff4b6247);
const paper = Color(0xfffffcf6);
const lime = Color(0xffe6eddf);
const peach = Color(0xfff6e3d6);
const clay = Color(0xff943f2c);
const line = Color(0xffe6ded1);
const editorial = TextStyle(
  fontFamily: 'Georgia',
  fontFamilyFallback: ['serif'],
  fontWeight: FontWeight.w700,
  height: 1.06,
  color: pine,
);

ThemeData pantryTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: leaf,
      primary: pine,
      surface: paper,
    ),
    scaffoldBackgroundColor: paper,
    useMaterial3: true,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: pine, displayColor: pine),
    appBarTheme: const AppBarTheme(
      backgroundColor: paper,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: line)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: paper,
      indicatorColor: lime,
      height: 70,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: line),
      ),
    ),
  );
}
