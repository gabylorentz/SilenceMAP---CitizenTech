import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/noise_level.dart';
import '../../models/noise_reading.dart';
import '../../models/region.dart';
import '../../providers/noise_provider.dart';
import '../widgets/level_badge.dart';
import '../widgets/metric_card.dart';
import '../widgets/state_views.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();

    return switch (p.status) {
      LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorView(
          message: p.errorMessage ?? 'Erro desconhecido.',
          onRetry: p.refresh,
        ),
      LoadStatus.loaded => _Loaded(provider: p),
    };
  }
}

class _Loaded extends StatelessWidget {
  final NoiseProvider provider;
  const _Loaded({required this.provider});

  int _emAlerta() => provider.regions.where((r) {
        final leitura = provider.latestOf(r.id);
        if (leitura == null) return false;
        final nivel = NoiseLevel.of(r, leitura);
        return nivel == NoiseLevel.alerta || nivel == NoiseLevel.critico;
      }).length;

  @override
  Widget build(BuildContext context) {
    final p = provider;
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (p.fromCache) ...[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.cloud_off),
              title: const Text('Sem conexão'),
              subtitle: Text(
                'Mostrando dados salvos em ${DateFormat('dd/MM HH:mm').format(p.updatedAt!)}',
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.location_city,
                label: 'Regiões monitoradas',
                value: '${p.regions.length}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.warning_amber_rounded,
                label: 'Regiões em alerta',
                value: '${_emAlerta()}',
                color: AppColors.alerta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Regiões',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (final r in p.regions) ...[
          _RegionCard(regiao: r, leitura: p.latestOf(r.id)),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          'Dados sintéticos para demonstração. Os alertas apoiam a decisão; a decisão final é humana.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _RegionCard extends StatelessWidget {
  final Region regiao;
  final NoiseReading? leitura;
  const _RegionCard({required this.regiao, required this.leitura});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nivel = leitura == null ? null : NoiseLevel.of(regiao, leitura!);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.alertDetail,
          arguments: regiao.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(regiao.nome,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(regiao.zona.rotulo, style: text.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    leitura == null
                        ? '-'
                        : '${leitura!.decibeis.toStringAsFixed(1)} dB',
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (nivel != null)
                    LevelBadge(label: nivel.rotulo, color: nivel.cor),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}