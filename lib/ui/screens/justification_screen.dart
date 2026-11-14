import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/section_card.dart';

/// Primeira tela do app: explica por que o SilenceMAP existe.
class JustificationScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const JustificationScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.graphic_eq,
                      size: 56, color: AppColors.primary),
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
                    title: 'O problema',
                    child: Text(
                      'A poluição sonora afeta a qualidade de vida, o sono, a '
                      'produtividade e a saúde mental da população.\n\n'
                      'Hoje, as ações acontecem apenas após reclamações ou quando '
                      'o problema já está instalado.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SectionCard(
                    title: 'A proposta',
                    child: Text(
                      'O SilenceMAP busca antecipar regiões com tendência de '
                      'aumento do ruído urbano.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SectionCard(
                    title: 'Para quem',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Publico(Icons.home_outlined, 'Moradores'),
                        _Publico(Icons.laptop_mac, 'Trabalhadores remotos'),
                        _Publico(Icons.school_outlined, 'Escolas'),
                        _Publico(Icons.local_hospital_outlined, 'Hospitais'),
                        _Publico(
                            Icons.account_balance_outlined, 'Gestores públicos'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SectionCard(
                    title: 'Benefício social',
                    child: Text(
                      'O aplicativo permite identificar áreas com tendência de '
                      'aumento de ruído antes que atinjam níveis críticos, '
                      'apoiando decisões preventivas e melhorando a qualidade de '
                      'vida da população.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SectionCard(
                    title: 'Decisão humana',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Os alertas são um apoio à decisão e trazem a '
                            'justificativa. A decisão final é sempre humana.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: onContinue,
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Publico extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  const _Publico(this.icone, this.rotulo);

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icone, size: 18), label: Text(rotulo));
  }
}