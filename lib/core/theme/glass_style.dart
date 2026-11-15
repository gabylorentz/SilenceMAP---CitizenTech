import 'package:flutter/material.dart';

/// Cores do visual "vidro" (cartões translúcidos sobre degradê).
@immutable
class GlassStyle extends ThemeExtension<GlassStyle> {
  final List<Color> gradient;
  final Color card; // preenchimento translúcido do cartão
  final Color cardBorder;
  final Color cardOpaque; // cor opaca aproximada, só para cálculo de contraste
  final Color solid; // fundo liso do alto contraste
  final bool highContrast;

  const GlassStyle({
    required this.gradient,
    required this.card,
    required this.cardBorder,
    required this.cardOpaque,
    required this.solid,
    required this.highContrast,
  });

  @override
  GlassStyle copyWith({
    List<Color>? gradient,
    Color? card,
    Color? cardBorder,
    Color? cardOpaque,
    Color? solid,
    bool? highContrast,
  }) =>
      GlassStyle(
        gradient: gradient ?? this.gradient,
        card: card ?? this.card,
        cardBorder: cardBorder ?? this.cardBorder,
        cardOpaque: cardOpaque ?? this.cardOpaque,
        solid: solid ?? this.solid,
        highContrast: highContrast ?? this.highContrast,
      );

  @override
  GlassStyle lerp(ThemeExtension<GlassStyle>? other, double t) =>
      other is GlassStyle ? (t < 0.5 ? this : other) : this;
}

/// Fundo de cada tela: degradê suave (ou fundo liso no alto contraste).
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).extension<GlassStyle>();
    if (estilo == null) return child;
    if (estilo.highContrast) {
      return ColoredBox(color: estilo.solid, child: child);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: estilo.gradient,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}