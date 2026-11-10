import 'package:flutter/material.dart';

/// Palet Warm Editorial Track dengan seluruh pasangan warna terverifikasi WCAG AA
@immutable
class SuhatColors extends ThemeExtension<SuhatColors> {
  final Color canvas;
  final Color surfaceElevated;
  final Color surfaceSubtle;
  final Color inkPrimary;
  final Color inkSecondary;
  final Color hairline;
  final Color controlBorder;
  final Color accentPine;
  final Color onAccentPine;
  final Color statusCaution;
  final Color statusAlert;

  const SuhatColors({
    required this.canvas,
    required this.surfaceElevated,
    required this.surfaceSubtle,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.hairline,
    required this.controlBorder,
    required this.accentPine,
    required this.onAccentPine,
    required this.statusCaution,
    required this.statusAlert,
  });

  static const light = SuhatColors(
    canvas: Color(0xFFF7F5F0),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFEFECE6),
    inkPrimary: Color(0xFF171614),
    inkSecondary: Color(0xFF57534E),
    hairline: Color(0xFFD6D0C4),
    controlBorder: Color(0xFF8A8378),
    accentPine: Color(0xFF166534),
    onAccentPine: Color(0xFFFFFFFF),
    statusCaution: Color(0xFF9A3412),
    statusAlert: Color(0xFF991B1B),
  );

  static const dark = SuhatColors(
    canvas: Color(0xFF141413),
    surfaceElevated: Color(0xFF1E1D1A),
    surfaceSubtle: Color(0xFF262420),
    inkPrimary: Color(0xFFF5F2EB),
    inkSecondary: Color(0xFFA8A29E),
    hairline: Color(0xFF2E2C27),
    controlBorder: Color(0xFF78716C),
    accentPine: Color(0xFF34D399),
    onAccentPine: Color(0xFF141413),
    statusCaution: Color(0xFFFDBA74),
    statusAlert: Color(0xFFFCA5A5),
  );

  @override
  SuhatColors copyWith({
    Color? canvas,
    Color? surfaceElevated,
    Color? surfaceSubtle,
    Color? inkPrimary,
    Color? inkSecondary,
    Color? hairline,
    Color? controlBorder,
    Color? accentPine,
    Color? onAccentPine,
    Color? statusCaution,
    Color? statusAlert,
  }) {
    return SuhatColors(
      canvas: canvas ?? this.canvas,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      inkPrimary: inkPrimary ?? this.inkPrimary,
      inkSecondary: inkSecondary ?? this.inkSecondary,
      hairline: hairline ?? this.hairline,
      controlBorder: controlBorder ?? this.controlBorder,
      accentPine: accentPine ?? this.accentPine,
      onAccentPine: onAccentPine ?? this.onAccentPine,
      statusCaution: statusCaution ?? this.statusCaution,
      statusAlert: statusAlert ?? this.statusAlert,
    );
  }

  @override
  SuhatColors lerp(ThemeExtension<SuhatColors>? other, double t) {
    if (other is! SuhatColors) return this;
    return SuhatColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      inkPrimary: Color.lerp(inkPrimary, other.inkPrimary, t)!,
      inkSecondary: Color.lerp(inkSecondary, other.inkSecondary, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      accentPine: Color.lerp(accentPine, other.accentPine, t)!,
      onAccentPine: Color.lerp(onAccentPine, other.onAccentPine, t)!,
      statusCaution: Color.lerp(statusCaution, other.statusCaution, t)!,
      statusAlert: Color.lerp(statusAlert, other.statusAlert, t)!,
    );
  }
}

extension SuhatThemeContext on BuildContext {
  SuhatColors get suhatColors =>
      Theme.of(this).extension<SuhatColors>() ?? SuhatColors.light;
}

class AppTheme {
  // Referensi konstan untuk model domain dan fallback terang
  static const Color primaryTeal = Color(0xFF166534);
  static const Color primaryDark = Color(0xFF171614);
  static const Color surfaceLight = Color(0xFFEFECE6);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF171614);
  static const Color textMuted = Color(0xFF57534E);
  static const Color accentGreen = Color(0xFF166534);
  static const Color accentRed = Color(0xFF991B1B);
  static const Color accentIndigo = Color(0xFF57534E);
  static const Color accentAmber = Color(0xFF9A3412);
  static const Color borderSubtle = Color(0xFFD6D0C4);

  /// Gaya angka tabular agar kolom metrik sejajar rapi
  static const List<FontFeature> tabularNumbers = [
    FontFeature.tabularFigures(),
  ];

  static ThemeData get lightTheme => _buildTheme(
        colors: SuhatColors.light,
        brightness: Brightness.light,
      );

  static ThemeData get darkTheme => _buildTheme(
        colors: SuhatColors.dark,
        brightness: Brightness.dark,
      );

  static ThemeData _buildTheme({
    required SuhatColors colors,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accentPine,
        onPrimary: colors.onAccentPine,
        secondary: colors.inkSecondary,
        onSecondary: colors.canvas,
        error: colors.statusAlert,
        onError: colors.canvas,
        background: colors.canvas,
        onBackground: colors.inkPrimary,
        surface: colors.surfaceElevated,
        onSurface: colors.inkPrimary,
      ),
      scaffoldBackgroundColor: colors.canvas,
      dividerColor: colors.hairline,
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.inkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: colors.inkPrimary),
      ),
      cardTheme: CardTheme(
        color: colors.surfaceElevated,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.hairline, width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.accentPine.withOpacity(isDark ? 0.18 : 0.12),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: colors.accentPine, size: 22);
          }
          return IconThemeData(color: colors.inkSecondary, size: 22);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.accentPine,
            );
          }
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.inkSecondary,
          );
        }),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: colors.inkPrimary,
          hoverColor: colors.controlBorder.withOpacity(0.14),
          focusColor: colors.controlBorder.withOpacity(0.24),
          highlightColor: colors.controlBorder.withOpacity(0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 46),
          backgroundColor: colors.accentPine,
          foregroundColor: colors.onAccentPine,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: colors.inkPrimary,
          side: BorderSide(color: colors.controlBorder, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: colors.accentPine,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSubtle,
        selectedColor: colors.accentPine,
        side: BorderSide(color: colors.controlBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(fontSize: 12, color: colors.inkPrimary),
      ),
      focusColor: colors.inkPrimary.withOpacity(0.14),
    );
  }
}
