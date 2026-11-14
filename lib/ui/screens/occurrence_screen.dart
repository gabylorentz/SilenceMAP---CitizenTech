import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../logic/occurrence_validator.dart';
import '../../models/noise_reading.dart';
import '../../models/occurrence.dart';
import '../../providers/noise_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';

class OccurrenceScreen extends StatefulWidget {
  const OccurrenceScreen({super.key});

  @override
  State<OccurrenceScreen> createState() => _OccurrenceScreenState();
}

class _OccurrenceScreenState extends State<OccurrenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();

  String? _regionId;
  NoiseSource? _fonte;
  double _intensidade = 3;
  bool _salvando = false;

  static const _niveis = [
    'Baixa',
    'Perceptível',
    'Incômoda',
    'Muito alta',
    'Insuportável',
  ];

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final settings = context.read<SettingsProvider>();
    final provider = context.read<NoiseProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // Sem consentimento, nada é salvo.
    if (!settings.consentGiven) {
      messenger.showSnackBar(const SnackBar(
        content: Text(
            'Aceite o consentimento de privacidade para registrar ocorrências.'),
      ));
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _salvando = true);
    final texto = _descricao.text.trim();

    await provider.addOccurrence(Occurrence(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      regionId: _regionId!,
      fonte: _fonte!,
      intensidade: _intensidade.round(),
      dataHora: DateTime.now(),
      descricao: texto.isEmpty ? null : texto,
    ));
    if (!mounted) return;

    _formKey.currentState?.reset();
    _descricao.clear();
    setState(() {
      _salvando = false;
      _regionId = null;
      _fonte = null;
      _intensidade = 3;
    });
    messenger.showSnackBar(const SnackBar(
      content: Text('Ocorrência registrada de forma anônima neste aparelho.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NoiseProvider>();
    final text = Theme.of(context).textTheme;
    final formato = DateFormat('dd/MM HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ruído')),
      body: p.regions.isEmpty
          ? const EmptyView(
              message:
                  'Os bairros ainda não foram carregados. Volte e tente novamente.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionCard(
                  title: 'Registro anônimo',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Não pedimos nome, e-mail nem telefone. A ocorrência '
                          'fica salva só neste aparelho e a localização é '
                          'apenas o bairro.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  title: 'Nova ocorrência',
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ChipsField<String>(
                          label: 'Bairro',
                          opcoes: [for (final r in p.regions) r.id],
                          rotulo: (id) => p.regionById(id)?.nome ?? id,
                          onChanged: (v) => _regionId = v,
                          validator: OccurrenceValidator.regiao,
                        ),
                        const SizedBox(height: 16),
                        _ChipsField<NoiseSource>(
                          label: 'Fonte do ruído',
                          opcoes: NoiseSource.values,
                          rotulo: (f) => f.rotulo,
                          onChanged: (v) => _fonte = v,
                          validator: OccurrenceValidator.fonte,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Intensidade: ${_intensidade.round()} - '
                          '${_niveis[_intensidade.round() - 1]}',
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _intensidade,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _niveis[_intensidade.round() - 1],
                          onChanged: (v) => setState(() => _intensidade = v),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descricao,
                          maxLength: OccurrenceValidator.descricaoMax,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Descrição (opcional)',
                            hintText: 'Ex.: obra com britadeira depois das 22h',
                            helperText: 'Não informe endereço, nome ou telefone.',
                            alignLabelWithHint: true,
                          ),
                          validator: (v) =>
                              OccurrenceValidator.descricao(v, fonte: _fonte),
                        ),
                        const SizedBox(height: 8),
                        _ConfirmField(
                          texto:
                              'Confirmo que não incluí dados pessoais na descrição.',
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: _salvando ? null : _enviar,
                          icon: const Icon(Icons.send),
                          label: const Text('Registrar ocorrência'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (p.occurrences.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Minhas ocorrências (${p.occurrences.length})',
                    style: text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final o in p.occurrences) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.edit_location_alt),
                        title: Text(
                            '${p.regionById(o.regionId)?.nome ?? o.regionId} · ${o.fonte.rotulo}'),
                        subtitle: Text(
                          'Intensidade ${o.intensidade}/5 · ${formato.format(o.dataHora)}'
                          '${o.descricao == null ? '' : '\n${o.descricao}'}',
                        ),
                        isThreeLine: o.descricao != null,
                        trailing: IconButton(
                          tooltip: 'Excluir ocorrência',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => p.removeOccurrence(o.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            ),
    );
  }
}

/// Campo de escolha com chips que também mostra mensagem de erro.
class _ChipsField<T> extends FormField<T> {
  _ChipsField({
    super.key,
    super.validator,
    required String label,
    required List<T> opcoes,
    required String Function(T) rotulo,
    required ValueChanged<T> onChanged,
  }) : super(
          builder: (state) {
            final tema = Theme.of(state.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: tema.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in opcoes)
                      ChoiceChip(
                        label: Text(rotulo(o)),
                        selected: state.value == o,
                        onSelected: (_) {
                          state.didChange(o);
                          onChanged(o);
                        },
                      ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                          color: tema.colorScheme.error, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
}

/// Caixa de confirmação obrigatória.
class _ConfirmField extends FormField<bool> {
  _ConfirmField({ required String texto})
      : super(
          initialValue: false,
          validator: (v) =>
              v == true ? null : 'Confirme para registrar a ocorrência.',
          builder: (state) {
            final tema = Theme.of(state.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: state.value ?? false,
                  onChanged: (v) => state.didChange(v ?? false),
                  title: Text(texto),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                          color: tema.colorScheme.error, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
}