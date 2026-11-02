import 'package:flutter/material.dart';

class AppFonts {
  static const regular = 'regular';
  static const medium = 'medium';
  static const semibold = 'semibold';
  static const bold = 'bold';
}

class AppTextStyle {
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.bold,
    fontSize: 24,
    height: 1.35,
    color: ThemeProvider.blackColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.bold,
    fontSize: 18,
    height: 1.35,
    color: ThemeProvider.blackColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: AppFonts.semibold,
    fontSize: 16,
    height: 1.35,
    color: ThemeProvider.blackColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.regular,
    fontSize: 14,
    height: 1.35,
    color: ThemeProvider.blackColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.medium,
    fontSize: 14,
    height: 1.35,
    color: ThemeProvider.blackColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.regular,
    fontSize: 12,
    height: 1.35,
    color: ThemeProvider.greyColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.bold,
    fontSize: 14,
    height: 1.2,
    color: ThemeProvider.whiteColor,
    decoration: TextDecoration.none,
  );

  static const TextStyle appBar = TextStyle(
    fontFamily: AppFonts.bold,
    fontSize: 16,
    height: 1.2,
    color: ThemeProvider.whiteColor,
    decoration: TextDecoration.none,
  );
}

class ThemeProvider {
  static const appColor = Color.fromARGB(219, 0, 0, 0);
  static const secondaryAppColor = Color.fromARGB(255, 35, 74, 214);
  static const whiteColor = Colors.white;
  static const blackColor = Color(0xFF000000);
  static const greyColor = Colors.grey;
  static const backgroundColor = Color(0xFFF3F3F3);
  static const orangeColor = Color(0xFFFF9900);
  static const greenColor = Color(0xFF32CD32);
  static const redColor = Color(0xFFFF0000);
  static const transparent = Color.fromARGB(0, 0, 0, 0);
  static const pinkColor = Color.fromARGB(255, 255, 0, 119);

  static const golden = Color.fromARGB(255, 235, 206, 60);

  static const titleStyle = AppTextStyle.appBar;
}

TextStyle _poppins({
  required String family,
  required double size,
  required Color color,
}) {
  return TextStyle(
    fontFamily: family,
    fontSize: size,
    height: 1.35,
    color: color,
    decoration: TextDecoration.none,
  );
}

TextTheme poppinsTextTheme(Color color) {
  return TextTheme(
    displayLarge: _poppins(family: AppFonts.bold, size: 32, color: color),
    displayMedium: _poppins(family: AppFonts.bold, size: 28, color: color),
    displaySmall: _poppins(family: AppFonts.bold, size: 24, color: color),
    headlineLarge: _poppins(family: AppFonts.bold, size: 22, color: color),
    headlineMedium: _poppins(family: AppFonts.bold, size: 20, color: color),
    headlineSmall: _poppins(family: AppFonts.bold, size: 18, color: color),
    titleLarge: _poppins(family: AppFonts.bold, size: 16, color: color),
    titleMedium: _poppins(family: AppFonts.semibold, size: 16, color: color),
    titleSmall: _poppins(family: AppFonts.semibold, size: 14, color: color),
    bodyLarge: _poppins(family: AppFonts.regular, size: 16, color: color),
    bodyMedium: _poppins(family: AppFonts.regular, size: 14, color: color),
    bodySmall: _poppins(family: AppFonts.regular, size: 12, color: color),
    labelLarge: _poppins(family: AppFonts.bold, size: 14, color: color),
    labelMedium: _poppins(family: AppFonts.medium, size: 12, color: color),
    labelSmall: _poppins(family: AppFonts.medium, size: 11, color: color),
  );
}

ButtonStyle _textButtonStyle(Color foreground) {
  return TextButton.styleFrom(
    foregroundColor: foreground,
    textStyle: AppTextStyle.button.copyWith(color: foreground),
  );
}

ThemeData _buildTheme({
  required Brightness brightness,
  required Color primary,
  required Color secondary,
  required Color scaffold,
  required Color card,
  required Color hint,
  required Color disabled,
  required Color textColor,
  required Color error,
}) {
  final textTheme = poppinsTextTheme(textColor);
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: false,
    fontFamily: AppFonts.regular,
    brightness: brightness,
    primaryColor: primary,
    secondaryHeaderColor: secondary,
    disabledColor: disabled,
    hintColor: hint,
    cardColor: card,
    scaffoldBackgroundColor: scaffold,
    canvasColor: scaffold,
    dividerColor: disabled.withValues(alpha: 0.5),
    textTheme: textTheme,
    primaryTextTheme: poppinsTextTheme(ThemeProvider.whiteColor),
    iconTheme: IconThemeData(color: textColor),
    primaryIconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: ThemeProvider.whiteColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
      titleTextStyle: AppTextStyle.appBar,
      toolbarTextStyle: AppTextStyle.body.copyWith(
        color: ThemeProvider.whiteColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: _textButtonStyle(primary)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeProvider.golden,
        foregroundColor: ThemeProvider.blackColor,
        textStyle: AppTextStyle.button.copyWith(
          color: ThemeProvider.blackColor,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        textStyle: AppTextStyle.button.copyWith(color: textColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: AppTextStyle.body.copyWith(color: hint),
      labelStyle: AppTextStyle.body.copyWith(color: textColor),
      helperStyle: AppTextStyle.caption,
      errorStyle: AppTextStyle.caption.copyWith(color: error),
      prefixStyle: AppTextStyle.body.copyWith(color: textColor),
      suffixStyle: AppTextStyle.body.copyWith(color: textColor),
      counterStyle: AppTextStyle.caption,
      floatingLabelStyle: AppTextStyle.bodyMedium.copyWith(color: textColor),
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: AppTextStyle.title.copyWith(color: textColor),
      contentTextStyle: AppTextStyle.body.copyWith(color: textColor),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: AppTextStyle.body.copyWith(
        color: ThemeProvider.whiteColor,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: AppTextStyle.bodyMedium.copyWith(
        fontFamily: AppFonts.bold,
        color: textColor,
      ),
      unselectedLabelStyle: AppTextStyle.body.copyWith(color: hint),
      labelColor: textColor,
      unselectedLabelColor: hint,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? card : ThemeProvider.whiteColor,
      selectedItemColor: ThemeProvider.golden,
      unselectedItemColor: hint,
      selectedLabelStyle: AppTextStyle.caption.copyWith(
        fontFamily: AppFonts.bold,
        color: ThemeProvider.golden,
      ),
      unselectedLabelStyle: AppTextStyle.caption.copyWith(color: hint),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: AppTextStyle.subtitle.copyWith(color: textColor),
      subtitleTextStyle: AppTextStyle.caption.copyWith(color: hint),
      leadingAndTrailingTextStyle: AppTextStyle.body.copyWith(color: textColor),
    ),
    chipTheme: ChipThemeData(
      labelStyle: AppTextStyle.caption.copyWith(color: textColor),
      secondaryLabelStyle: AppTextStyle.caption.copyWith(color: textColor),
      brightness: brightness,
      selectedColor: ThemeProvider.golden,
      backgroundColor: disabled.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: AppTextStyle.caption.copyWith(color: ThemeProvider.whiteColor),
    ),
    popupMenuTheme: PopupMenuThemeData(
      textStyle: AppTextStyle.body.copyWith(color: textColor),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: textColor),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ThemeProvider.golden
            : textColor,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? ThemeProvider.golden
            : hint,
      ),
    ),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: ThemeProvider.whiteColor,
      secondary: secondary,
      onSecondary: ThemeProvider.whiteColor,
      error: error,
      onError: ThemeProvider.whiteColor,
      surface: isDark ? card : ThemeProvider.whiteColor,
      onSurface: textColor,
    ),
  );
}

ThemeData light = _buildTheme(
  brightness: Brightness.light,
  primary: ThemeProvider.appColor,
  secondary: ThemeProvider.secondaryAppColor,
  scaffold: ThemeProvider.backgroundColor,
  card: ThemeProvider.appColor,
  hint: const Color(0xFF9F9F9F),
  disabled: const Color(0xFFBABFC4),
  textColor: ThemeProvider.blackColor,
  error: const Color(0xFFE84D4F),
);

ThemeData dark = _buildTheme(
  brightness: Brightness.dark,
  primary: ThemeProvider.blackColor,
  secondary: const Color(0xFF009f67),
  scaffold: const Color(0xFF343636),
  card: Colors.black,
  hint: const Color(0xFFbebebe),
  disabled: const Color(0xffa2a7ad),
  textColor: ThemeProvider.whiteColor,
  error: const Color(0xFFdd3135),
);
