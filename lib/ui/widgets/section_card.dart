import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Descrição em texto do conteúdo (usada para gráficos).
  /// Quando informada, o leitor de tela lê ela no lugar do conteúdo.
  final String? semanticsLabel;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.semanticsLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final conteudo = semanticsLabel == null
        ? child
        : Semantics(
            label: semanticsLabel,
            child: ExcludeSemantics(child: child),
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: text.bodySmall),
            ],
            const SizedBox(height: 12),
            conteudo,
          ],
        ),
      ),
    );
  }
}