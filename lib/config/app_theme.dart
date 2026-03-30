import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _build();

  static const _scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCCFBF1),
    onPrimaryContainer: Color(0xFF134E4A),
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCFFAFE),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    outline: AppColors.textSecondary,
    outlineVariant: AppColors.border,
    error: AppColors.error,
    onError: Colors.white,
  );

  static ThemeData _build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: AppColors.border.withOpacity(0.6)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFCCFBF1).withOpacity(0.5),
        side: BorderSide.none,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.6,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            height: 1.6,
          );
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.5,
        fontSize: 15,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: AppColors.textTertiary,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}
