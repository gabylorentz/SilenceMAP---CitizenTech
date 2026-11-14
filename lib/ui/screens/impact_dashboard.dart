import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/noise_level.dart';
import '../../providers/noise_provider.dart';
import '../widgets/level_badge.dart';
import '../widgets/metric_card.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';

class ImpactDashboard extends StatelessWidget {
  const ImpactDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();
    final regioes = p.regions;
    if (regioes.isEmpty) {
      return const EmptyView(message: 'Nenhuma região disponível.');
    }

    // Regiões com a leitura mais recente acima do limite da zona.
    final expostas = regioes.where((r) {
      final leitura = p.latestOf(r.id);
      if (leitura == null) return false;
      final nivel = NoiseLevel.of(r, leitura);
      return nivel == NoiseLevel.alerta || nivel == NoiseLevel.critico;
    }).toList();

    final escolas = expostas.fold<int>(0, (s, r) => s + r.escolas);
    final hospitais = expostas.fold<int>(0, (s, r) => s + r.hospitais);
    final reclamacoes = regioes.fold<int>(0, (s, r) => s + r.reclamacoesMes);

    final porReclamacao = [...regioes]
      ..sort((a, b) => b.reclamacoesMes.compareTo(a.reclamacoesMes));
    final maxReclamacoes = porReclamacao.first.reclamacoesMes;

    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.school,
                label: 'Escolas expostas',
                value: '$escolas',
                color: AppColors.critico,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                icon: Icons.local_hospital,
                label: 'Hospitais expostos',
                value: '$hospitais',
                color: AppColors.critico,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                icon: Icons.campaign,
                label: 'Reclamações/mês',
                value: '$reclamacoes',
                color: AppColors.alerta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Exposto = escola ou hospital em região com leitura acima do limite da NBR 10151.',
          style: text.bodySmall,
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Reclamações por região',
          subtitle: 'Registros no último mês (dados sintéticos).',
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxReclamacoes + 10).toDouble(),
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (valor, meta) => Text(
                        valor.toInt().toString(),
                        style: text.bodySmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (valor, meta) {
                        final i = valor.toInt();
                        if (i < 0 || i >= porReclamacao.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            porReclamacao[i].nome.split(' ').first,
                            style: text.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < porReclamacao.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: porReclamacao[i].reclamacoesMes.toDouble(),
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.alerta,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Locais sensíveis por região',
          child: Column(
            children: [
              for (final r in regioes)
                Builder(builder: (context) {
                  final leitura = p.latestOf(r.id);
                  final nivel =
                      leitura == null ? null : NoiseLevel.of(r, leitura);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(r.nome),
                    subtitle: Text(
                        '${r.escolas} escolas · ${r.hospitais} hospitais'),
                    trailing: nivel == null
                        ? null
                        : LevelBadge(label: nivel.rotulo, color: nivel.cor),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}