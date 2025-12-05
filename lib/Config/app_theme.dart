import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rusticgram/Public/app_colors.dart';

class AppTheme {
  static const double _borderRadius = 10.0;
  static const double _buttonHeight = 65.0;

  static ThemeData lightTheme(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return ThemeData(
      fontFamily: "Montserrat",
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor, primary: AppColors.primaryColor, secondary: AppColors.secondaryColor),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.secondaryColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.secondaryColor,
        scrolledUnderElevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: AppColors.secondaryColor,
          statusBarColor: AppColors.secondaryColor,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      textTheme: _buildTextTheme(),
      listTileTheme: _buildListTileTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(width),
      outlinedButtonTheme: _buildOutlinedButtonTheme(width),
      iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.lightBrown))),
      textButtonTheme: _buildTextButtonTheme(),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.secondaryColor),
      dividerColor: AppColors.dividerColor,
      inputDecorationTheme: _buildInputDecorationTheme(),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.secondaryColor),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppColors.fillColor),
    );
  }

  static ListTileThemeData _buildListTileTheme() => ListTileThemeData(selectedTileColor: AppColors.fillColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)));

  static TextTheme _buildTextTheme() {
    return TextTheme(
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.primaryColor),
      bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.body7Color),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
      displaySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.primaryColor),
      displayMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryColor),
      displayLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryColor),
      titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
      titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
      headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primaryColor),
      headlineLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.hint1Color),
      labelMedium: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.body6Color),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.hint1Color),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(double width) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.primaryColor),
        foregroundColor: const WidgetStatePropertyAll(AppColors.white),
        fixedSize: WidgetStatePropertyAll(Size(width, _buttonHeight)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius))),
        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.white)),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(double width) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.secondaryColor),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primaryColor),
        minimumSize: WidgetStatePropertyAll(Size(width, _buttonHeight)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius))),
        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.secondaryColor)),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.body7Color, decoration: TextDecoration.underline, decorationColor: AppColors.body7Color),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.black),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.hint1Color, overflow: TextOverflow.ellipsis),
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.hint1Color, overflow: TextOverflow.ellipsis),
      floatingLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
      errorStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.redColor),
      border: _textFieldBorder(),
      enabledBorder: _textFieldBorder(),
      focusedBorder: _textFieldBorder(),
      disabledBorder: _textFieldBorder(),
      errorBorder: _textFieldBorder(errorStyle: true),
      focusedErrorBorder: _textFieldBorder(errorStyle: true),
    );
  }

  static OutlineInputBorder _textFieldBorder({bool errorStyle = false}) =>
      OutlineInputBorder(borderSide: BorderSide(color: errorStyle ? AppColors.redColor : AppColors.primaryColor, width: 1), borderRadius: BorderRadius.circular(10.0));
}
