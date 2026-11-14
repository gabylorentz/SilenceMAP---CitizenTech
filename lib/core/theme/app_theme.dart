import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Temas claro e escuro, cada um com versão de alto contraste.
class AppTheme {
  AppTheme._();

  static ThemeData light({bool highContrast = false}) =>
      _build(Brightness.light, highContrast);
  static ThemeData dark({bool highContrast = false}) =>
      _build(Brightness.dark, highContrast);

  static ThemeData _build(Brightness brightness, bool hc) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      contrastLevel: hc ? 1.0 : 0.0,
    );
    final fundo = hc
        ? (brightness == Brightness.light ? Colors.white : Colors.black)
        : scheme.surface;
    final bordaForte = BorderSide(color: scheme.outline, width: 1.5);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: fundo,
      appBarTheme: AppBarTheme(
        backgroundColor: fundo,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: hc ? fundo : scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: hc ? bordaForte : BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(side: hc ? bordaForte : null),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: hc ? bordaForte : const BorderSide(),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // área de toque acessível
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}