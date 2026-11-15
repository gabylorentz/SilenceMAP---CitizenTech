import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'glass_style.dart';

/// Coloca o fundo em degradê em cada tela e faz uma transição suave.
class _GlassTransitions extends PageTransitionsBuilder {
  const _GlassTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
      child: GlassBackground(child: child),
    );
  }
}

/// Temas claro e escuro, cada um com versão de alto contraste.
class AppTheme {
  AppTheme._();

  static ThemeData light({bool highContrast = false}) =>
      _build(Brightness.light, highContrast);
  static ThemeData dark({bool highContrast = false}) =>
      _build(Brightness.dark, highContrast);

  static ThemeData _build(Brightness brightness, bool hc) {
    final claro = brightness == Brightness.light;
    final solido = claro ? Colors.white : Colors.black;

    final primary = claro ? AppColors.primary : AppColors.primaryEscuro;
    final onPrimary = claro ? Colors.white : AppColors.onPrimaryEscuro;
    final texto = hc
        ? (claro ? Colors.black : Colors.white)
        : (claro ? AppColors.textoClaro : AppColors.textoEscuro);
    final textoSec = hc
        ? texto
        : (claro
            ? AppColors.textoSecundarioClaro
            : AppColors.textoSecundarioEscuro);
    final contorno = hc
        ? texto
        : (claro ? AppColors.contornoClaro : AppColors.contornoEscuro);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      contrastLevel: hc ? 1.0 : 0.0,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      onSurface: texto,
      onSurfaceVariant: textoSec,
      outline: contorno,
    );

    final estilo = GlassStyle(
      gradient: claro ? AppColors.gradClaro : AppColors.gradEscuro,
      card: hc
          ? solido
          : Colors.white.withValues(alpha: claro ? 0.60 : 0.08),
      cardBorder: hc
          ? contorno
          : Colors.white.withValues(alpha: claro ? 0.75 : 0.14),
      cardOpaque: hc
          ? solido
          : (claro ? AppColors.cartaoClaro : AppColors.cartaoEscuro),
      solid: solido,
      highContrast: hc,
    );

    final borda = BorderSide(color: contorno, width: hc ? 1.5 : 1);
    const pilula = StadiumBorder();

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: [estilo],
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final plataforma in TargetPlatform.values)
            plataforma: const _GlassTransitions(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: texto,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: estilo.card,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: estilo.cardBorder, width: hc ? 1.5 : 1),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: borda,
        backgroundColor: Colors.transparent,
        selectedColor: primary.withValues(alpha: hc ? 0.35 : 0.22),
        showCheckmark: false,
        labelStyle: TextStyle(color: texto),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: claro ? 0.50 : 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: borda,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: borda,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52), // área de toque acessível
          shape: pilula,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: pilula,
          side: borda,
          foregroundColor: texto,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(pilula),
          side: WidgetStatePropertyAll(borda),
          foregroundColor: WidgetStatePropertyAll(texto),
          backgroundColor: WidgetStateProperty.resolveWith(
            (estados) => estados.contains(WidgetState.selected)
                ? primary.withValues(alpha: hc ? 0.35 : 0.22)
                : Colors.transparent,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: primary.withValues(alpha: hc ? 0.35 : 0.20),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: texto),
        ),
        iconTheme: WidgetStatePropertyAll(IconThemeData(color: texto)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
        shape: pilula,
        extendedTextStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    // Títulos grandes mais leves, como na referência.
    final textos =
        base.textTheme.apply(bodyColor: texto, displayColor: texto);
    return base.copyWith(
      textTheme: textos.copyWith(
        headlineLarge: textos.headlineLarge?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        headlineMedium: textos.headlineMedium?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        headlineSmall: textos.headlineSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}