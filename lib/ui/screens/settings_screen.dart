import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/noise_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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