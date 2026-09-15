import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const Color forestGreen = Color(0xFF2D5016);
    const Color secondaryGreen = Color(0xFF3D7E2E);
    const Color hoverGreen = Color(0xFF234010);
    const Color textPrimary = Color(0xFF333333);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: forestGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: forestGreen,
      secondary: secondaryGreen,
      onSurface: textPrimary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: forestGreen,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: forestGreen,
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      iconTheme: const IconThemeData(color: forestGreen),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return forestGreen.withValues(alpha: 0.35);
            }
            if (states.contains(WidgetState.hovered)) {
              return hoverGreen;
            }
              return forestGreen;
          }),
          foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
          elevation: const WidgetStatePropertyAll<double>(0),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          textStyle: const WidgetStatePropertyAll<TextStyle>(
            TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: forestGreen,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: forestGreen,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: forestGreen,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, height: 1.35),
        bodyMedium: TextStyle(color: textPrimary, height: 1.35),
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color forestGreen = Color(0xFF7CBF62);
    const Color secondaryGreen = Color(0xFF6FAF5D);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: forestGreen,
      brightness: Brightness.dark,
    ).copyWith(primary: forestGreen, secondary: secondaryGreen);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121712),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: forestGreen,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: const Color(0xFF1C241C),
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(forestGreen),
          foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
          elevation: WidgetStatePropertyAll<double>(0),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(height: 1.35),
      ),
    );
  }
}
