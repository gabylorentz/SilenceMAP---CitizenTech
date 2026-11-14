import 'package:flutter/material.dart';

class DashboardsScreen extends StatelessWidget {
  const DashboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Níveis'),
              Tab(text: 'Fontes'),
              Tab(text: 'Impacto'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _Placeholder(
                  titulo: 'Níveis de ruído',
                  descricao: 'Gráfico de dB por região ao longo do tempo.',
                ),
                _Placeholder(
                  titulo: 'Horários e fontes',
                  descricao: 'Trânsito, obras e eventos por período do dia.',
                ),
                _Placeholder(
                  titulo: 'Impacto social',
                  descricao: 'Escolas e hospitais expostos e reclamações.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String titulo;
  final String descricao;
  const _Placeholder({required this.titulo, required this.descricao});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction, size: 48),
            const SizedBox(height: 12),
            Text(titulo,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(descricao, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Em construção (etapa 6)', style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}