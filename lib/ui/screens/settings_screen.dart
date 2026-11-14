import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/alert_config.dart';
import '../../providers/noise_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static String _fmt(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  Future<void> _apagarOcorrencias(
      BuildContext context, NoiseProvider p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar ocorrências?'),
        content: const Text(
            'Todas as ocorrências salvas neste aparelho serão removidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true) await p.clearOccurrences();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();
    final s = context.watch<SettingsProvider>();
    final text = Theme.of(context).textTheme;
    final cfg = p.alertConfig;
    final titulo = text.titleSmall?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Aparência e acessibilidade',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema', style: titulo),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text('Sistema')),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text('Claro')),
                      ButtonSegment(
                          value: ThemeMode.dark, label: Text('Escuro')),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => s.setThemeMode(v.first),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Alto contraste'),
                  subtitle: const Text(
                      'Cores e bordas mais fortes para facilitar a leitura.'),
                  value: s.highContrast,
                  onChanged: s.setHighContrast,
                ),
                const SizedBox(height: 8),
                Text('Tamanho do texto', style: titulo),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<double>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 1.0, label: Text('Normal')),
                      ButtonSegment(value: 1.15, label: Text('Grande')),
                      ButtonSegment(value: 1.3, label: Text('Maior')),
                    ],
                    selected: {s.textScale},
                    onSelectionChanged: (v) => s.setTextScale(v.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Sensibilidade dos alertas',
            subtitle: 'Os limites em dB seguem a NBR 10151 e não mudam. '
                'Aqui você ajusta quando uma tendência de alta vira aviso.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Antecedência do aviso', style: titulo),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      for (final d in AlertConfig.horizontes)
                        ButtonSegment(value: d, label: Text('$d dias')),
                    ],
                    selected: {cfg.horizonteDias},
                    onSelectionChanged: (v) =>
                        p.setAlertConfig(cfg.copyWith(horizonteDias: v.first)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Avisa quando o limite deve ser atingido em até '
                  '${cfg.horizonteDias} dias.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 16),
                Text('Sensibilidade da tendência', style: titulo),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<double>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 0.05, label: Text('Alta')),
                      ButtonSegment(value: 0.10, label: Text('Padrão')),
                      ButtonSegment(value: 0.20, label: Text('Baixa')),
                    ],
                    selected: {cfg.inclinacaoMinima},
                    onSelectionChanged: (v) => p
                        .setAlertConfig(cfg.copyWith(inclinacaoMinima: v.first)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Considera tendência de alta o ruído que sobe pelo menos '
                  '${_fmt(cfg.inclinacaoMinima)} dB por dia. '
                  'Quanto menor o valor, mais sensível.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restaurar padrão'),
                  onPressed: cfg == AlertConfig.padrao
                      ? null
                      : () => p.setAlertConfig(AlertConfig.padrao),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Privacidade',
            subtitle: 'Você controla o uso dos seus dados',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(
                      'Apagar minhas ocorrências (${p.occurrences.length})'),
                  onPressed: p.occurrences.isEmpty
                      ? null
                      : () => _apagarOcorrencias(context, p),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text('Revogar consentimento'),
                  onPressed: () async {
                    await context.read<SettingsProvider>().revokeConsent();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.gate, (_) => false);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Ferramentas de teste',
            subtitle: 'Para demonstrar o modo offline (saem no final)',
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
      ),
    );
  }
}