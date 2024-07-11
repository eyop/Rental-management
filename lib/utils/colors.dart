import 'package:flutter/material.dart';

Color textLabelColor = Colors.grey;

Color themeColor = const Color(0xF5404B60);
Color unselectedIconColor = Colors.grey[500]!;

class CustomTheme {
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: Colors.blue.shade800,
      hintColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      ),
    );
  }
}
