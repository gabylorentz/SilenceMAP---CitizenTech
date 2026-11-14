import 'package:flutter/material.dart';

import '../widgets/state_views.dart';

class OccurrenceScreen extends StatelessWidget {
  const OccurrenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ruído')),
      body: const EmptyView(
        message: 'Formulário de ocorrência em construção (etapa 8).',
      ),
    );
  }
}