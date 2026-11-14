import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/noise_stats.dart';
import '../../models/noise_reading.dart';
import '../../providers/noise_provider.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';

const Map<NoiseSource, Color> _coresFonte = {
  NoiseSource.transito: Color(0xFF3949AB),
  NoiseSource.obras: Color(0xFFEF6C00),
  NoiseSource.eventos: Color(0xFF8E24AA),
  NoiseSource.comercio: Color(0xFF00897B),
  NoiseSource.outros: Color(0xFF757575),
};

class SourcesDashboard extends StatelessWidget {
  const SourcesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();
    final listas = p.regions.map((r) => p.readingsOf(r.id)).toList();

    final contagem = NoiseStats.contagemPorFonte(listas);
    final porHora = NoiseStats.mediaPorHorario(listas);
    if (contagem.isEmpty || porHora.isEmpty) {
      return const EmptyView(message: 'Sem leituras para analisar.');
    }

    final total = contagem.values.reduce((a, b) => a + b);
    final fontes = contagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final horas = porHora.keys.toList();
    final horaPico =
        horas.reduce((a, b) => porHora[a]! >= porHora[b]! ? a : b);

    final text = Theme.of(context).textTheme;

    // Descrições dos gráficos para leitores de tela.
    final partesPizza = fontes
        .map((f) => '${f.key.rotulo} ${(f.value * 100 / total).round()}%')
        .join(', ');
    final descricaoPizza =
        'Gráfico de pizza com as fontes de ruído: $partesPizza.';

    final partesBarras = horas
        .map((h) => '${h}h ${porHora[h]!.toStringAsFixed(0)} dB')
        .join(', ');
    final descricaoBarras =
        'Gráfico de barras com a média de dB por horário: $partesBarras.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        SectionCard(
          title: 'Fontes de ruído',
          semanticsLabel: descricaoPizza,
          subtitle: 'Fonte predominante em cada leitura, todas as regiões.',
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: [
                      for (final f in fontes)
                        PieChartSectionData(
                          value: f.value.toDouble(),
                          color: _coresFonte[f.key],
                          radius: 60,
                          title: '${(f.value * 100 / total).round()}%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  for (final f in fontes)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _coresFonte[f.key],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${f.key.rotulo} (${f.value})',
                            style: text.bodySmall),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Ruído por horário do dia',
          semanticsLabel: descricaoBarras,
          subtitle:
              'Média de dB em todas as regiões. Pico às ${horaPico}h, '
              '${porHora[horaPico]!.toStringAsFixed(1)} dB.',
          child: SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 80,
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
                      interval: 20,
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
                        if (i < 0 || i >= horas.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('${horas[i]}h', style: text.bodySmall),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < horas.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: porHora[horas[i]]!,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          color: horas[i] == horaPico
                              ? AppColors.alerta
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}