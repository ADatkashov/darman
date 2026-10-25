import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: DmPalette.emerald,
      onPrimary: Colors.white,
      primaryContainer: DmPalette.softMint,
      onPrimaryContainer: DmPalette.deepGreen,
      secondary: DmPalette.mint,
      onSecondary: DmPalette.textPrimary,
      secondaryContainer: DmPalette.paleAqua,
      onSecondaryContainer: DmPalette.deepGreen,
      tertiary: DmPalette.warning,
      onTertiary: DmPalette.textPrimary,
      error: DmPalette.error,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: DmPalette.textPrimary,
      surfaceContainerHighest: DmPalette.softMint,
      onSurfaceVariant: DmPalette.textSecondary,
      outline: DmPalette.divider,
      outlineVariant: DmPalette.divider,
    ),
    colors: DmColors.light,
    scaffold: Colors.white,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: DmPalette.mint,
      onPrimary: Color(0xFF05241C),
      primaryContainer: Color(0xFF1C4A3B),
      onPrimaryContainer: DmPalette.softMint,
      secondary: DmPalette.emerald,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF1C332B),
      onSecondaryContainer: DmPalette.softMint,
      tertiary: DmPalette.warning,
      onTertiary: Colors.black,
      error: Color(0xFFFF8A8C),
      onError: Colors.black,
      surface: DmPalette.darkBg,
      onSurface: DmPalette.darkText,
      surfaceContainerHighest: DmPalette.darkSurfaceHigh,
      onSurfaceVariant: DmPalette.darkTextSecondary,
      outline: DmPalette.darkDivider,
      outlineVariant: DmPalette.darkDivider,
    ),
    colors: DmColors.dark,
    scaffold: DmPalette.darkBg,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required DmColors colors,
    required Color scaffold,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true, colorScheme: scheme);
    final text = _textTheme(base.textTheme, scheme.onSurface, colors.textSecondary);
    final radius = BorderRadius.circular(Sp.radiusSm + 2);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c, width: w),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      textTheme: text,
      extensions: [colors],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light ? Colors.white : DmPalette.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sp.radiusLg),
          side: BorderSide(color: colors.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.radiusPill)),
          textStyle: text.labelLarge,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.radiusPill)),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.radiusPill)),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary, textStyle: text.labelLarge, minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.paleAqua,
        contentPadding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x4),
        border: border(colors.divider),
        enabledBorder: border(colors.divider),
        focusedBorder: border(scheme.primary, 1.6),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.6),
        labelStyle: text.bodyMedium?.copyWith(color: colors.textSecondary),
        hintStyle: text.bodyMedium?.copyWith(color: colors.textSecondary),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.paleAqua,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: colors.divider),
        labelStyle: text.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.radiusPill)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.light ? Colors.white : DmPalette.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: colors.softMint,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall?.copyWith(
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? scheme.primary : colors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? scheme.primary : colors.textSecondary, size: 24),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.radiusLg + 4)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DmPalette.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.radiusSm)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : colors.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? scheme.primary : colors.divider),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: Sp.x4)),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color primary, Color secondary) {
    TextStyle s(double size, FontWeight w, {double? height, double? ls, Color? color}) =>
        TextStyle(fontSize: size, fontWeight: w, height: height, letterSpacing: ls, color: color ?? primary);
    return base.copyWith(
      displaySmall: s(32, FontWeight.w800, height: 1.15, ls: -0.5),
      headlineMedium: s(26, FontWeight.w800, height: 1.2, ls: -0.3),
      headlineSmall: s(22, FontWeight.w700, height: 1.25),
      titleLarge: s(20, FontWeight.w700, height: 1.3),
      titleMedium: s(16, FontWeight.w700, height: 1.35),
      titleSmall: s(14, FontWeight.w600, height: 1.35),
      bodyLarge: s(16, FontWeight.w400, height: 1.45),
      bodyMedium: s(14, FontWeight.w400, height: 1.45),
      bodySmall: s(12, FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: s(16, FontWeight.w700, height: 1.2),
      labelMedium: s(13, FontWeight.w600, height: 1.2),
      labelSmall: s(11.5, FontWeight.w500, height: 1.2),
    );
  }
}
