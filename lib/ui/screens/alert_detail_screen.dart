import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/alert_engine.dart';
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
    final alerta = p.alertOf(regionId);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: alerta == null
          ? const EmptyView(message: 'Não há dados para esta região.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alerta.regiao.nome,
                          style: text.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    LevelBadge(
                        label: alerta.nivel.rotulo, color: alerta.nivel.cor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(alerta.regiao.zona.rotulo, style: text.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.graphic_eq,
                        label: 'Média móvel (3 dias)',
                        value: alerta.mediaAtual == null
                            ? '-'
                            : '${AlertEngine.fmt(alerta.mediaAtual!)} dB',
                        color: alerta.nivel.cor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.rule,
                        label: 'Limite diurno (NBR 10151)',
                        value: '${AlertEngine.fmt(alerta.limite, 0)} dB',
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
                        icon: (alerta.tendencia ?? 0) >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        label: 'Tendência',
                        value: alerta.tendencia == null
                            ? '-'
                            : '${AlertEngine.fmtSinal(alerta.tendencia!)} dB/dia',
                        color: (alerta.tendencia ?? 0) >=
                                AlertEngine.inclinacaoMinima
                            ? AppColors.alerta
                            : AppColors.normal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        icon: Icons.verified_outlined,
                        label: 'Confiança',
                        value: alerta.confianca.rotulo,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Justificativa do alerta',
                  subtitle: alerta.titulo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alerta.resumo),
                      const SizedBox(height: 16),
                      _Lista(
                        titulo: 'Evidências',
                        itens: alerta.evidencias,
                        icone: Icons.insights,
                      ),
                      const SizedBox(height: 16),
                      _Lista(
                        titulo: 'Limitações',
                        itens: alerta.limitacoes,
                        icone: Icons.info_outline,
                      ),
                    ],
                  ),
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

class _Lista extends StatelessWidget {
  final String titulo;
  final List<String> itens;
  final IconData icone;
  const _Lista({
    required this.titulo,
    required this.itens,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (final item in itens)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icone, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: text.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}