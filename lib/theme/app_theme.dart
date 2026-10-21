import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors of the app. Cool grey canvas, white product surfaces, one cobalt accent.
class AppColors {
  static const canvas = Color(0xFFEDEFF3);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A2233);
  static const inkSoft = Color(0xFF5B6577);
  static const line = Color(0xFFDADFE8);
  static const accent = Color(0xFF3347FF);
  static const accentSoft = Color(0xFFE3E6FF);
  static const danger = Color(0xFFD6453D);
  static const success = Color(0xFF1F8A5B);
  static const successSoft = Color(0xFFDDF3E9);
  static const star = Color(0xFFF2A900);
}

/// Text styles. Bricolage Grotesque for headings and prices,
/// Instrument Sans for everything else.
class AppText {
  static TextStyle display(double size, {Color color = AppColors.ink}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.4,
      color: color,
    );
  }
}

class AppTheme {
  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final textTheme = GoogleFonts.instrumentSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        titleTextStyle: AppText.display(22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.inkSoft),
        hintStyle: const TextStyle(color: AppColors.inkSoft),
        border: _border(AppColors.line),
        enabledBorder: _border(AppColors.line),
        focusedBorder: _border(AppColors.accent, 1.6),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, 1.6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.ink : AppColors.inkSoft,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.accent : AppColors.inkSoft,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        actionTextColor: const Color(0xFFB8C0FF),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
