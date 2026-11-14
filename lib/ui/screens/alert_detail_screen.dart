import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/noise_level.dart';
import '../../providers/noise_provider.dart';
import '../widgets/level_badge.dart';
import '../widgets/metric_card.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';

class AlertDetailScreen extends StatelessWidget {
  final String regionId;
  const AlertDetailScreen({super.key, required this.regionId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();
    final regiao = p.regionById(regionId);
    final leitura = p.latestOf(regionId);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: (regiao == null || leitura == null)
          ? const EmptyView(message: 'Não há dados para esta região.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(regiao.nome,
                          style: text.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    LevelBadge(
                      label: NoiseLevel.of(regiao, leitura).rotulo,
                      color: NoiseLevel.of(regiao, leitura).cor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(regiao.zona.rotulo, style: text.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.graphic_eq,
                        label: 'Última leitura',
                        value: '${leitura.decibeis.toStringAsFixed(1)} dB',
                        color: NoiseLevel.of(regiao, leitura).cor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: leitura.isNoturno
                            ? Icons.nights_stay
                            : Icons.wb_sunny,
                        label: leitura.isNoturno
                            ? 'Limite noturno'
                            : 'Limite diurno',
                        value:
                            '${(leitura.isNoturno ? regiao.zona.limiteNoturno : regiao.zona.limiteDiurno).toStringAsFixed(0)} dB',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.school,
                        label: 'Escolas',
                        value: '${regiao.escolas}',
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.local_hospital,
                        label: 'Hospitais',
                        value: '${regiao.hospitais}',
                        color: AppColors.critico,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SectionCard(
                  title: 'Justificativa do alerta',
                  subtitle: 'Tendência, evidência e nível de confiança',
                  child: Text('Em construção (etapa 7): o motor de alertas vai explicar aqui por que esta região foi sinalizada.'),
                ),
                const SizedBox(height: 12),
                const SectionCard(
                  title: 'Decisão humana',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person_outline),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Este alerta é um apoio à decisão. A decisão final é sempre humana.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}