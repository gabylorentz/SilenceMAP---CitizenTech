import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_style.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final text = tema.textTheme;
    final base =
        tema.extension<GlassStyle>()?.cardOpaque ?? tema.colorScheme.surface;
    final circulo = Color.alphaBlend(color.withValues(alpha: 0.16), base);
    // Ícone ajustado para ter contraste mínimo de 3:1 (WCAG para ícones).
    final corIcone = AppColors.legivel(color, circulo, minimo: 3);

    return Semantics(
      label: '$label: $value', // leitor de tela lê o card inteiro
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: circulo, shape: BoxShape.circle),
                child: Icon(icon, color: corIcone, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 2),
              Text(label, style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}