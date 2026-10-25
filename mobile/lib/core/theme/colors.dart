import 'package:flutter/material.dart';

/// DARMAN brand tokens. `textSecondary` is the brand grey darkened slightly so small text meets WCAG AA (4.5:1) on white.
abstract final class DmPalette {
  static const emerald = Color(0xFF17865B);
  static const deepGreen = Color(0xFF126B49);
  static const mint = Color(0xFF43C6AE);
  static const softMint = Color(0xFFEAF8F2);
  static const paleAqua = Color(0xFFF0FBF8);
  static const white = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF17352D);
  static const textSecondary = Color(0xFF5F6F69);
  static const textMuted = Color(0xFF71817B);
  static const divider = Color(0xFFE4ECE8);
  static const warning = Color(0xFFE5A23C);
  static const error = Color(0xFFD94F52);
  static const success = Color(0xFF24875B);

  // dark theme
  static const darkBg = Color(0xFF0F1D19);
  static const darkSurface = Color(0xFF16272F);
  static const darkSurfaceHigh = Color(0xFF1C332B);
  static const darkText = Color(0xFFE6F2EE);
  static const darkTextSecondary = Color(0xFFA5B8B0);
  static const darkDivider = Color(0xFF2A413A);
}

/// Extra semantic colours that Material's ColorScheme has no slot for.
@immutable
class DmColors extends ThemeExtension<DmColors> {
  const DmColors({
    required this.softMint,
    required this.paleAqua,
    required this.textSecondary,
    required this.divider,
    required this.success,
    required this.warning,
    required this.mint,
    required this.cardBorder,
  });

  final Color softMint;
  final Color paleAqua;
  final Color textSecondary;
  final Color divider;
  final Color success;
  final Color warning;
  final Color mint;
  final Color cardBorder;

  static const light = DmColors(
    softMint: DmPalette.softMint,
    paleAqua: DmPalette.paleAqua,
    textSecondary: DmPalette.textSecondary,
    divider: DmPalette.divider,
    success: DmPalette.success,
    warning: DmPalette.warning,
    mint: DmPalette.mint,
    cardBorder: DmPalette.divider,
  );

  static const dark = DmColors(
    softMint: DmPalette.darkSurfaceHigh,
    paleAqua: Color(0xFF13251F),
    textSecondary: DmPalette.darkTextSecondary,
    divider: DmPalette.darkDivider,
    success: Color(0xFF4CC08A),
    warning: DmPalette.warning,
    mint: DmPalette.mint,
    cardBorder: DmPalette.darkDivider,
  );

  @override
  DmColors copyWith({
    Color? softMint,
    Color? paleAqua,
    Color? textSecondary,
    Color? divider,
    Color? success,
    Color? warning,
    Color? mint,
    Color? cardBorder,
  }) => DmColors(
    softMint: softMint ?? this.softMint,
    paleAqua: paleAqua ?? this.paleAqua,
    textSecondary: textSecondary ?? this.textSecondary,
    divider: divider ?? this.divider,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    mint: mint ?? this.mint,
    cardBorder: cardBorder ?? this.cardBorder,
  );

  @override
  DmColors lerp(ThemeExtension<DmColors>? other, double t) {
    if (other is! DmColors) return this;
    return DmColors(
      softMint: Color.lerp(softMint, other.softMint, t)!,
      paleAqua: Color.lerp(paleAqua, other.paleAqua, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
    );
  }
}

extension DmThemeContext on BuildContext {
  DmColors get dm => Theme.of(this).extension<DmColors>() ?? DmColors.light;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
