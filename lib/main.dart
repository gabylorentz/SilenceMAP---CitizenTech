import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'ui/widgets/level_badge.dart';
import 'ui/widgets/metric_card.dart';
import 'ui/widgets/section_card.dart';

void main() {
  runApp(const SilenceMapApp());
}

class SilenceMapApp extends StatelessWidget {
  const SilenceMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SilenceMAP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _PreviewScreen(),
    );
  }
}

/// Tela temporária só para validar o tema e os componentes.
class _PreviewScreen extends StatelessWidget {
  const _PreviewScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SilenceMAP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.graphic_eq,
                  label: 'Média hoje',
                  value: '68 dB',
                  color: AppColors.alerta,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  icon: Icons.school,
                  label: 'Escolas expostas',
                  value: '3',
                  color: AppColors.critico,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SectionCard(
            title: 'Níveis de alerta',
            subtitle: 'Padrão visual usado em todo o app',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LevelBadge(label: 'NORMAL', color: AppColors.normal),
                LevelBadge(label: 'ATENÇÃO', color: AppColors.atencao),
                LevelBadge(label: 'ALERTA', color: AppColors.alerta),
                LevelBadge(label: 'CRÍTICO', color: AppColors.critico),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {}, child: const Text('Botão padrão')),
        ],
      ),
    );
  }
}