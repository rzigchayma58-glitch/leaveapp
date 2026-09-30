import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: MaterialColor(
        AppConstants.primaryOrange.value,
        <int, Color>{
          50: AppConstants.primaryOrange.withValues(alpha: 0.1),
          100: AppConstants.primaryOrange.withValues(alpha: 0.2),
          200: AppConstants.primaryOrange.withValues(alpha: 0.3),
          300: AppConstants.primaryOrange.withValues(alpha: 0.4),
          400: AppConstants.primaryOrange.withValues(alpha: 0.5),
          500: AppConstants.primaryOrange,
          600: AppConstants.primaryOrange.withValues(alpha: 0.7),
          700: AppConstants.primaryOrange.withValues(alpha: 0.8),
          800: AppConstants.primaryOrange.withValues(alpha: 0.9),
          900: AppConstants.darkOrange,
        },
      ),
      primaryColor: AppConstants.primaryOrange,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      cardColor: AppConstants.whiteColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryOrange,
        secondary: AppConstants.lightOrange,
        surface: AppConstants.whiteColor,
        background: AppConstants.backgroundColor,
        onPrimary: AppConstants.whiteColor,
        onSecondary: AppConstants.whiteColor,
        onSurface: AppConstants.darkGreyColor,
        onBackground: AppConstants.darkGreyColor,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.darkGreyColor),
        titleTextStyle: TextStyle(
          color: AppConstants.darkGreyColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.whiteColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.textFieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.textFieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppConstants.greyColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: AppConstants.greyColor,
          fontSize: 16,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryOrange,
          foregroundColor: AppConstants.whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryOrange,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.whiteColor,
        selectedItemColor: AppConstants.primaryOrange,
        unselectedItemColor: AppConstants.greyColor,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(
        AppConstants.primaryOrange.value,
        <int, Color>{
          50: AppConstants.primaryOrange.withValues(alpha: 0.1),
          100: AppConstants.primaryOrange.withValues(alpha: 0.2),
          200: AppConstants.primaryOrange.withValues(alpha: 0.3),
          300: AppConstants.primaryOrange.withValues(alpha: 0.4),
          400: AppConstants.primaryOrange.withValues(alpha: 0.5),
          500: AppConstants.primaryOrange,
          600: AppConstants.primaryOrange.withValues(alpha: 0.7),
          700: AppConstants.primaryOrange.withValues(alpha: 0.8),
          800: AppConstants.primaryOrange.withValues(alpha: 0.9),
          900: AppConstants.darkOrange,
        },
      ),
      primaryColor: AppConstants.primaryOrange,
      scaffoldBackgroundColor: AppConstants.darkBackgroundColor,
      cardColor: AppConstants.darkCardColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryOrange,
        secondary: AppConstants.lightOrange,
        surface: AppConstants.darkSurfaceColor,
        background: AppConstants.darkBackgroundColor,
        onPrimary: AppConstants.whiteColor,
        onSecondary: AppConstants.whiteColor,
        onSurface: AppConstants.darkTextColor,
        onBackground: AppConstants.darkTextColor,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkSurfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppConstants.darkTextColor),
        titleTextStyle: TextStyle(
          color: AppConstants.darkTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF0A0A0A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppConstants.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppConstants.darkSecondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFC8C8C8),
          fontSize: 16,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryOrange,
          foregroundColor: AppConstants.whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryOrange,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.darkSurfaceColor,
        selectedItemColor: AppConstants.primaryOrange,
        unselectedItemColor: AppConstants.darkSecondaryTextColor,
        elevation: 8,
      ),
    );
  }
}