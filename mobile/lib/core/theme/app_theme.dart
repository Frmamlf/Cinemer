import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color _primarySeed = Color(0xFF1A73E8);
  static const Color _amoledBlack = Color(0xFF000000);
  
  // Generate dynamic light theme
  static ThemeData lightTheme([ColorScheme? dynamicColorScheme, Color? seedColor]) {
    final effectiveSeedColor = seedColor ?? _primarySeed;
    final colorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.light,
    );

    return _baseTheme(colorScheme, Brightness.light);
  }

  // Generate dynamic dark theme
  static ThemeData darkTheme([ColorScheme? dynamicColorScheme, Color? seedColor]) {
    final effectiveSeedColor = seedColor ?? _primarySeed;
    final colorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.dark,
    );

    return _baseTheme(colorScheme, Brightness.dark);
  }

  // AMOLED black theme
  static ThemeData amoledTheme([ColorScheme? dynamicColorScheme, Color? seedColor]) {
    final effectiveSeedColor = seedColor ?? _primarySeed;
    final baseColorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.dark,
    );

    final amoledColorScheme = baseColorScheme.copyWith(
      surface: _amoledBlack,
      surfaceContainer: const Color(0xFF141414),
      surfaceContainerHigh: const Color(0xFF1E1E1E),
      surfaceContainerHighest: const Color(0xFF282828),
    );

    return _baseTheme(amoledColorScheme, Brightness.dark, isAmoled: true);
  }

  // High contrast light theme
  static ThemeData lightHighContrastTheme([ColorScheme? dynamicColorScheme, Color? seedColor]) {
    final effectiveSeedColor = seedColor ?? _primarySeed;
    final baseColorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.light,
    );

    final highContrastColorScheme = baseColorScheme.copyWith(
      primary: const Color(0xFF000000),
      onPrimary: const Color(0xFFFFFFFF),
      outline: const Color(0xFF000000),
    );

    return _baseTheme(highContrastColorScheme, Brightness.light, isHighContrast: true);
  }

  // High contrast dark theme
  static ThemeData darkHighContrastTheme([ColorScheme? dynamicColorScheme, Color? seedColor]) {
    final effectiveSeedColor = seedColor ?? _primarySeed;
    final baseColorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: effectiveSeedColor,
      brightness: Brightness.dark,
    );

    final highContrastColorScheme = baseColorScheme.copyWith(
      primary: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFF000000),
      outline: const Color(0xFFFFFFFF),
    );

    return _baseTheme(highContrastColorScheme, Brightness.dark, isHighContrast: true);
  }

  // Base theme with Material 3 expressive design
  static ThemeData _baseTheme(
    ColorScheme colorScheme, 
    Brightness brightness, {
    bool isAmoled = false,
    bool isHighContrast = false,
  }) {
    final textTheme = GoogleFonts.rubikTextTheme(
      brightness == Brightness.light 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: GoogleFonts.rubik().fontFamily,
      textTheme: textTheme,
      
      // Material 3 Expressive App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 3,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700, // Bold for expressiveness
          letterSpacing: -0.5, // Tighter spacing for modern look
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28), // Expressive large radius
          ),
        ),
      ),

      // Material 3 Expressive Cards
      cardTheme: CardThemeData(
        elevation: isHighContrast ? 0 : 1,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Large expressive radius
          side: isHighContrast ? BorderSide(color: colorScheme.outline) : BorderSide.none,
        ),
        margin: const EdgeInsets.all(4),
      ),

      // Material 3 Expressive Filled Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isHighContrast ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Full pill shape
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700, // Bold for emphasis
            fontSize: 16,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Material 3 Expressive Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: isHighContrast ? 0 : 3,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 28, // Larger for expressiveness
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700, // Bold for selected
              letterSpacing: 0.1,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          );
        }),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Full pill indicator
        ),
      ),

      // Material 3 Expressive Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // Expressive radius
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorScheme.primary, 
            width: isHighContrast ? 3 : 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Material 3 Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Material 3 Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: isHighContrast ? 0 : 6,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Extra large for expressiveness
          side: isHighContrast ? BorderSide(color: colorScheme.outline) : BorderSide.none,
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Material 3 Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: isHighContrast ? 0 : 1,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32), // Large expressive radius
          ),
        ),
      ),
    );
  }
}