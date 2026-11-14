import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/noise_repository.dart';
import 'data/services/mock_noise_api_service.dart';
import 'providers/noise_provider.dart';
import 'ui/widgets/metric_card.dart';
import 'ui/widgets/section_card.dart';
import 'ui/widgets/state_views.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          NoiseProvider(NoiseRepository(MockNoiseApiService()))..init(),
      child: const SilenceMapApp(),
    ),
  );
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
      home: const _StateScreen(),
    );
  }
}

/// Tela temporária para validar o estado global. Será substituída na etapa 5.
class _StateScreen extends StatelessWidget {
  const _StateScreen();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('SilenceMAP')),
      body: switch (p.status) {
        LoadStatus.loading => const LoadingView(),
        LoadStatus.error => ErrorView(
            message: p.errorMessage ?? 'Erro desconhecido.',
            onRetry: p.refresh,
          ),
        LoadStatus.loaded => _LoadedView(provider: p),
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  final NoiseProvider provider;
  const _LoadedView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final p = provider;
    final formato = DateFormat('dd/MM HH:mm');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (p.fromCache)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.cloud_off),
              title: const Text('Sem conexão'),
              subtitle: Text(
                'Mostrando dados salvos em ${formato.format(p.updatedAt!)}',
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.location_city,
                label: 'Regiões',
                value: '${p.regions.length}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.graphic_eq,
                label: 'Leituras',
                value: '${p.totalLeituras}',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Última leitura por região',
          child: Column(
            children: [
              for (final r in p.regions)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.nome),
                  subtitle: Text(r.zona.rotulo),
                  trailing: Text(
                    '${p.latestOf(r.id)?.decibeis.toStringAsFixed(1) ?? '-'} dB',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Ferramentas de teste',
          subtitle: 'Só para validar a etapa 4',
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Simular sem internet'),
                value: p.simulandoOffline,
                onChanged: p.setSimularOffline,
              ),
              OutlinedButton(
                onPressed: p.limparCacheERecarregar,
                child: const Text('Limpar cache e recarregar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}