import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glass_style.dart';
import '../../logic/alert_engine.dart';
import '../../providers/noise_provider.dart';
import '../widgets/level_badge.dart';
import '../widgets/metric_card.dart';
import '../widgets/state_views.dart';

const _meses = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String _saudacao(int hora) {
  if (hora < 12) return 'Bom dia';
  if (hora < 18) return 'Boa tarde';
  return 'Boa noite';
}

IconData _icone(AlertKind tipo) => switch (tipo) {
      AlertKind.excedido => Icons.warning_amber_rounded,
      AlertKind.preventivo => Icons.trending_up,
      AlertKind.insuficiente => Icons.hourglass_empty,
      AlertKind.normal => Icons.check_rounded,
    };

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
    final agora = DateTime.now();

    final alertas = p.alerts;
    final ativos = alertas.where((a) => a.ativo).length;
    // Mais graves primeiro.
    final ordenados = [...alertas]
      ..sort((a, b) => b.nivel.index.compareTo(a.nivel.index));
    final topo =
        ordenados.isNotEmpty && ordenados.first.ativo ? ordenados.first : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
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
          const SizedBox(height: 16),
        ],
        Text(_saudacao(agora.hour), style: text.bodyLarge),
        const SizedBox(height: 4),
        Text('Onde o ruído está subindo hoje?', style: text.headlineMedium),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DataChip(dia: agora.day, mes: _meses[agora.month - 1]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumo de hoje',
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        topo == null
                            ? 'Nenhuma região com alerta no momento.'
                            : '${topo.regiao.nome} é a região que mais pede atenção agora.',
                        style: text.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w300, height: 1.25),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.updatedAt == null
                            ? 'Dados sintéticos'
                            : 'Atualizado às ${DateFormat('HH:mm').format(p.updatedAt!)} · dados sintéticos',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 28),
        Text('Regiões', style: text.titleLarge),
        const SizedBox(height: 2),
        Text('Média diurna dos últimos 3 dias', style: text.bodySmall),
        const SizedBox(height: 12),
        for (final a in ordenados) ...[
          _RegionCard(alerta: a),
          const SizedBox(height: 10),
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

/// Selo com o dia e o mês (como o "15 Sept" da referência).
class _DataChip extends StatelessWidget {
  final int dia;
  final String mes;
  const _DataChip({required this.dia, required this.mes});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cores.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$dia',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          Text(mes, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  final Alert alerta;
  const _RegionCard({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final text = tema.textTheme;
    final base =
        tema.extension<GlassStyle>()?.cardOpaque ?? tema.colorScheme.surface;
    final circulo =
        Color.alphaBlend(alerta.nivel.cor.withValues(alpha: 0.16), base);
    final corIcone = AppColors.legivel(alerta.nivel.cor, circulo, minimo: 3);

    void abrir() => Navigator.pushNamed(
          context,
          AppRoutes.alertDetail,
          arguments: alerta.regiao.id,
        );
    final media = alerta.mediaAtual == null
        ? 'sem média disponível'
        : 'média de ${AlertEngine.fmt(alerta.mediaAtual!)} decibéis';

    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: abrir,
      label: '${alerta.regiao.nome}. ${alerta.regiao.zona.rotulo}. '
          'Nível ${alerta.nivel.rotulo}: ${alerta.titulo}, $media. '
          'Toque para ver a justificativa.',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: abrir,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(color: circulo, shape: BoxShape.circle),
                  child: Icon(_icone(alerta.kind), color: corIcone, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alerta.regiao.nome,
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(alerta.regiao.zona.rotulo, style: text.bodySmall),
                      const SizedBox(height: 2),
                      Text(alerta.titulo,
                          style: text.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      alerta.mediaAtual == null
                          ? '-'
                          : '${AlertEngine.fmt(alerta.mediaAtual!)} dB',
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 4),
                    LevelBadge(
                        label: alerta.nivel.rotulo, color: alerta.nivel.cor),
                  ],
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}