import '../models/noise_reading.dart';

/// Regras de validação do formulário de ocorrência.
class OccurrenceValidator {
  OccurrenceValidator._();

  static const descricaoMin = 5;
  static const descricaoMax = 200;

  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  // 8 ou mais dígitos, mesmo separados por espaço, hífen ou parênteses.
  static final _telefone = RegExp(r'(?:\d[\s().-]*){8,}');

  static String? regiao(String? id) =>
      (id == null || id.isEmpty) ? 'Escolha o bairro.' : null;

  static String? fonte(NoiseSource? fonte) =>
      fonte == null ? 'Escolha a fonte do ruído.' : null;

  static String? descricao(String? texto, {NoiseSource? fonte}) {
    final t = (texto ?? '').trim();

    if (t.isEmpty) {
      return fonte == NoiseSource.outros
          ? 'Descreva o ruído quando a fonte for "Outros".'
          : null; // nos demais casos a descrição é opcional
    }
    if (t.length < descricaoMin) {
      return 'Descreva com pelo menos $descricaoMin caracteres.';
    }
    if (t.length > descricaoMax) {
      return 'Use no máximo $descricaoMax caracteres.';
    }
    if (_email.hasMatch(t) || _telefone.hasMatch(t)) {
      return 'Não inclua e-mail, telefone ou outros dados pessoais.';
    }
    return null;
  }
}