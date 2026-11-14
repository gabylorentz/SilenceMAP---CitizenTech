import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../logic/alert_engine.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = provider;
    final text = Theme.of(context).textTheme;

    final alertas = p.alerts;
    final ativos = alertas.where((a) => a.ativo).length;
    // Mais graves primeiro.
    final ordenados = [...alertas]
      ..sort((a, b) => b.nivel.index.compareTo(a.nivel.index));

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
                label: 'Regiões com alerta',
                value: '$ativos',
                color: AppColors.alerta,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Regiões',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text('Média diurna dos últimos 3 dias', style: text.bodySmall),
        const SizedBox(height: 8),
        for (final a in ordenados) ...[
          _RegionCard(alerta: a),
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
  final Alert alerta;
  const _RegionCard({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.alertDetail,
          arguments: alerta.regiao.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alerta.regiao.nome,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(alerta.regiao.zona.rotulo, style: text.bodySmall),
                    const SizedBox(height: 2),
                    Text(alerta.titulo,
                        style: text.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    alerta.mediaAtual == null
                        ? '-'
                        : '${AlertEngine.fmt(alerta.mediaAtual!)} dB',
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  LevelBadge(
                      label: alerta.nivel.rotulo, color: alerta.nivel.cor),
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