import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/noise_stats.dart';
import '../../providers/noise_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';

class LevelsDashboard extends StatefulWidget {
  const LevelsDashboard({super.key});

  @override
  State<LevelsDashboard> createState() => _LevelsDashboardState();
}

class _LevelsDashboardState extends State<LevelsDashboard> {
  String? _regionId;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();
    if (p.regions.isEmpty) {
      return const EmptyView(message: 'Nenhuma região disponível.');
    }

    final regiao = p.regionById(_regionId ?? '') ?? p.regions.first;
    final pontos =
        NoiseStats.mediaDiariaDiurna(p.readingsOf(regiao.id), minLeituras: 5);
    if (pontos.isEmpty) {
      return const EmptyView(message: 'Sem leituras para esta região.');
    }

    final limite = regiao.zona.limiteDiurno;
    final medias = pontos.map((e) => e.media).toList();
    final atual = medias.last;
    final variacao = atual - medias.first;

    // Eixo Y em múltiplos de 5, sempre incluindo o limite.
    final menor = min(medias.reduce(min), limite);
    final maior = max(medias.reduce(max), limite);
    final minY = (menor / 5).floor() * 5.0 - 5;
    final maxY = (maior / 5).ceil() * 5.0 + 5;

    final dataFmt = DateFormat('dd/MM');
    final text = Theme.of(context).textTheme;
    final corLinha = Theme.of(context).colorScheme.primary;

    // Descrição do gráfico para leitores de tela.
    final descricaoGrafico =
        'Gráfico de linha de ${regiao.nome}. '
        'Média mais recente de ${atual.toStringAsFixed(1)} dB, '
        'variação de ${variacao.toStringAsFixed(1)} dB em ${pontos.length} dias, '
        'limite de ${limite.toStringAsFixed(0)} dB.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in p.regions)
              ChoiceChip(
                label: Text(r.nome),
                selected: r.id == regiao.id,
                onSelected: (_) => setState(() => _regionId = r.id),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Média diária de ruído: ${regiao.nome}',
          semanticsLabel: descricaoGrafico,
          subtitle:
              'Leituras diurnas (7h às 22h) dos últimos ${pontos.length} dias. '
              'Linha tracejada = limite de ${limite.toStringAsFixed(0)} dB.',
          child: SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
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
                      reservedSize: 36,
                      interval: 5,
                      getTitlesWidget: (valor, meta) => Text(
                        valor.toInt().toString(),
                        style: text.bodySmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 3,
                      getTitlesWidget: (valor, meta) {
                        final i = valor.round();
                        if (i < 0 || i >= pontos.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(dataFmt.format(pontos[i].dia),
                              style: text.bodySmall),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: limite,
                      color: AppColors.critico,
                      strokeWidth: 2,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < pontos.length; i++)
                        FlSpot(i.toDouble(), pontos[i].media),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    color: corLinha,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: corLinha.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.graphic_eq,
                label: 'Média mais recente',
                value: '${atual.toStringAsFixed(1)} dB',
                color: atual > limite ? AppColors.critico : AppColors.normal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: variacao >= 0 ? Icons.trending_up : Icons.trending_down,
                label: 'Variação no período',
                value:
                    '${variacao >= 0 ? '+' : ''}${variacao.toStringAsFixed(1)} dB',
                color: variacao > 0 ? AppColors.alerta : AppColors.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}