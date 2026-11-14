import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../widgets/section_card.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _aceito = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Icon(Icons.graphic_eq, size: 56, color: cores.primary),
                  const SizedBox(height: 12),
                  Text('SilenceMAP',
                      style: text.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Antecipando o impacto da poluição sonora nos territórios urbanos.',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  const SectionCard(
                    title: 'Seus dados e sua privacidade',
                    child: Column(
                      children: [
                        _Item('Não pedimos nome, e-mail nem telefone.'),
                        _Item('As ocorrências que você registrar ficam salvas só neste aparelho.'),
                        _Item('A localização é informada apenas por bairro, nunca o endereço exato.'),
                        _Item('Os dados de ruído deste app são sintéticos, feitos para demonstração.'),
                        _Item('Você pode revogar o consentimento a qualquer momento em Configurações.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SectionCard(
                    title: 'Como usar os alertas',
                    child: Text(
                      'Os alertas são um apoio à decisão e mostram a justificativa. '
                      'A decisão final é sempre humana.',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _aceito,
                    onChanged: (v) => setState(() => _aceito = v ?? false),
                    title: const Text('Li e concordo com o uso dos meus dados como descrito acima.'),
                  ),
                  FilledButton(
                    onPressed: _aceito
                        ? () => context.read<SettingsProvider>().acceptConsent()
                        : null,
                    child: const Text('Aceitar e continuar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String texto;
  const _Item(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}