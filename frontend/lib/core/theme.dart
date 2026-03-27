import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Colors (Nature-Inspired) ───
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentGold = Color(0xFFC5A55A);
  static const Color darkBackground = Color(0xFF1B2E1B);
  static const Color cardSurface = Color(0xFF1E2E1E);
  static const Color cardSurfaceLight = Color(0xFF2A3D2A);
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFFB0C4A8);
  static const Color textTertiary = Color(0xFF6B8A60);

  // ─── Status Colors ───
  static const Color statusDraft = Color(0xFF757575);
  static const Color statusActive = Color(0xFF42A5F5);
  static const Color statusThresholdReached = Color(0xFFFFC107);
  static const Color statusGoConfirmed = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);
  static const Color statusCompleted = Color(0xFF26A69A);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2E1E), Color(0xFF243424)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient natureGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B2E1B), Color(0xFF152015), Color(0xFF1B2E1B)],
  );

  // ─── Shadows ───
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── Border Radius ───
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 28.0;
  static const double radiusRound = 100.0;

  // ─── Theme Data ───
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentGreen,
      tertiary: accentGold,
      surface: cardSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      error: statusCancelled,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: 'Inter',
      // ─── AppBar ───
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      // ─── Cards ───
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      // ─── Elevated Button ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ─── Outlined Button ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: accentGreen.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ─── Text Button ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ─── Input Fields ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurfaceLight.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: accentGreen.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accentGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: statusCancelled),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textTertiary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      // ─── Chips ───
      chipTheme: ChipThemeData(
        backgroundColor: cardSurfaceLight,
        selectedColor: primaryGreen,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      // ─── Bottom Navigation ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardSurface.withValues(alpha: 0.95),
        selectedItemColor: accentGreen,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      // ─── Floating Action Button ───
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: accentGreen.withValues(alpha: 0.12),
        thickness: 1,
      ),
      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
    );
  }

  // ─── Light Theme ───
  static ThemeData get lightTheme {
    const Color bg = Color(0xFFF0F5EC);
    const Color surface = Color(0xFFFFFFFF);
    const Color surfaceLight = Color(0xFFE8F0E4);
    const Color onSurface = Color(0xFF1A2E1A);
    const Color onSurfaceSecondary = Color(0xFF4A6040);

    final colorScheme = ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGreen,
      tertiary: accentGold,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurface,
      error: statusCancelled,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        hintStyle: const TextStyle(fontFamily: 'Inter', color: onSurfaceSecondary, fontSize: 14),
        labelStyle: const TextStyle(fontFamily: 'Inter', color: onSurfaceSecondary, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: onSurfaceSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
    );
  }
}

// ─── Glassmorphism Decoration (Nature-tinted) ───
BoxDecoration glassDecoration({
  double radius = AppTheme.radiusLarge,
  Color? color,
  double alpha = 0.78,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: (color ?? AppTheme.cardSurface).withValues(alpha: alpha),
    border: Border.all(
      color: AppTheme.accentGreen.withValues(alpha: 0.10),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
