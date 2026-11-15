import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_style.dart';

class LevelBadge extends StatelessWidget {
  final String label;
  final Color color;

  const LevelBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final superficie =
        tema.extension<GlassStyle>()?.cardOpaque ?? tema.colorScheme.surface;
    final fundo = Color.alphaBlend(color.withValues(alpha: 0.15), superficie);
    // Texto e borda ajustados para ter contraste legível em qualquer tema.
    final corTexto = AppColors.legivel(color, fundo);

    return Semantics(
      label: 'Nível $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: corTexto),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}