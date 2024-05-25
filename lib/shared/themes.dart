import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  CustomColors({
    required this.primaryText,
    required this.secondaryText,
    required this.textHint,
    required this.green,
    required this.pastelOrange,
    required this.pastelPurple,
    required this.pastelBlue,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color textHint;
  final Color green;
  final Color pastelOrange;
  final Color pastelPurple;
  final Color pastelBlue;

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? primaryText,
    Color? secondaryText,
    Color? textHint,
    Color? green,
    Color? pastelOrange,
    Color? pastelPurple,
    Color? pastelBlue,
  }) {
    return CustomColors(
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      textHint: textHint ?? this.textHint,
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
      textHint: Color.lerp(textHint, other.textHint, t)!,
      green: Color.lerp(green, other.green, t)!,
      pastelOrange: Color.lerp(pastelOrange, other.pastelOrange, t)!,
      pastelPurple: Color.lerp(pastelPurple, other.pastelPurple, t)!,
      pastelBlue: Color.lerp(pastelBlue, other.pastelBlue, t)!,
    );
  }
}

class AppTheme {
  static final ThemeData mainTheme = ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
      primary: const Color(0xFFB01713),
      secondary: const Color(0xFF7B0300),
      tertiary: const Color(0xFFE15216),
      background: const Color(0xFFFDFCFA),
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.rubik(
        fontSize: 23,
        color: const Color(0xFF7B0300),
      ),
      bodyLarge: GoogleFonts.openSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 12,
      ),
      titleMedium: GoogleFonts.rubik(
        fontSize: 32,
      ),
      titleSmall: GoogleFonts.rubik(
        fontSize: 18,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.aBeeZee(
        fontSize: 20,
        color: const Color(0xFF9799AB),
      ),
      hintStyle: GoogleFonts.rubik(
        fontStyle: FontStyle.italic,
        fontSize: 10,
        color: const Color(0xFF9799AB),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF9799AB)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF9799AB)),
      ),
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
    textHint: const Color(0xFF9798AB),
    green: const Color(0xFF3FA856),
    pastelOrange: const Color(0xFFFFAB75),
    pastelPurple: const Color(0xFFA976B8),
    pastelBlue: const Color(0xFF7E99DD),
  );
}
