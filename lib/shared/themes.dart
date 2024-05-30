import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  CustomColors({
    required this.primaryText,
    required this.secondaryText,
    required this.hint,
    required this.green,
    required this.pastelOrange,
    required this.pastelPurple,
    required this.pastelBlue,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color hint;
  final Color green;
  final Color pastelOrange;
  final Color pastelPurple;
  final Color pastelBlue;

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? primaryText,
    Color? secondaryText,
    Color? hint,
    Color? green,
    Color? pastelOrange,
    Color? pastelPurple,
    Color? pastelBlue,
  }) {
    return CustomColors(
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      hint: hint ?? this.hint,
      green: green ?? this.green,
      pastelOrange: pastelOrange ?? this.pastelOrange,
      pastelPurple: pastelPurple ?? this.pastelPurple,
      pastelBlue: pastelBlue ?? this.pastelBlue,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
    covariant ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }

    return CustomColors(
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      green: Color.lerp(green, other.green, t)!,
      pastelOrange: Color.lerp(pastelOrange, other.pastelOrange, t)!,
      pastelPurple: Color.lerp(pastelPurple, other.pastelPurple, t)!,
      pastelBlue: Color.lerp(pastelBlue, other.pastelBlue, t)!,
    );
  }
}

class AppTheme {
  static const Color hintLightGrey = Color(0xFF9799AB);

  static final ThemeData mainTheme = ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFDFCFA),
    colorScheme: ColorScheme.fromSeed(
      // https://api.flutter.dev/flutter/material/ColorScheme-class.html
      // https://m3.material.io/styles/color/static/baseline

      // use different seed color to check which is using material baseline colors
      seedColor: Colors.green,
      brightness: Brightness.light,
      primary: const Color(0xFFB01713),
      primaryContainer: Colors.white,
      primaryFixed: Colors.white,
      secondary: const Color(0xFF7B0300),
      secondaryContainer: Colors.white,
      secondaryFixed: Colors.white,
      tertiary: const Color(0xFFE15216),
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.rubik(
        fontSize: 24,
        color: const Color(0xFF7B0300),
      ),
      bodyLarge: GoogleFonts.openSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.openSans(
        fontSize: 12,
      ),
      titleLarge: GoogleFonts.rubik(
        fontSize: 32,
      ),
      titleMedium: GoogleFonts.rubik(
        fontSize: 24,
      ),
      titleSmall: GoogleFonts.rubik(
        fontSize: 18,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.aBeeZee(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: hintLightGrey,
      ),
      hintStyle: GoogleFonts.rubik(
        // fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w200,
        fontSize: 14,
        color: hintLightGrey,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: hintLightGrey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: hintLightGrey),
      ),
      iconColor: hintLightGrey,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFB01713),
    ),
  );

  static final light = mainTheme.copyWith(
    extensions: [
      customColors,
    ],
  );

  static final customColors = CustomColors(
    primaryText: const Color(0xFF000000),
    secondaryText: const Color(0xFF575A88),
    hint: hintLightGrey,
    green: const Color(0xFF3FA856),
    pastelOrange: const Color(0xFFFFAB75),
    pastelPurple: const Color(0xFFA976B8),
    pastelBlue: const Color(0xFF7E99DD),
  );
}
