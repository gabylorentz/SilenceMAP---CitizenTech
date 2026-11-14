import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silencemap/data/repositories/noise_repository.dart';
import 'package:silencemap/data/services/mock_noise_api_service.dart';
import 'package:silencemap/logic/occurrence_validator.dart';
import 'package:silencemap/models/noise_reading.dart';
import 'package:silencemap/models/occurrence.dart';
import 'package:silencemap/providers/noise_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('validação da descrição', () {
    test('é opcional quando a fonte não é "Outros"', () {
      expect(OccurrenceValidator.descricao('', fonte: NoiseSource.obras), isNull);
      expect(OccurrenceValidator.descricao(null), isNull);
    });

    test('é obrigatória quando a fonte é "Outros"', () {
      expect(OccurrenceValidator.descricao('', fonte: NoiseSource.outros),
          isNotNull);
    });

    test('rejeita texto muito curto ou muito longo', () {
      expect(OccurrenceValidator.descricao('ok'), isNotNull);
      expect(OccurrenceValidator.descricao('a' * 201), isNotNull);
    });

    test('rejeita e-mail e telefone', () {
      expect(OccurrenceValidator.descricao('fale com ana@email.com'), isNotNull);
      expect(OccurrenceValidator.descricao('ligue 11 98765-4321'), isNotNull);
    });

    test('aceita texto normal com números curtos', () {
      expect(
        OccurrenceValidator.descricao('Obra depois das 22h, 3 caminhões'),
        isNull,
      );
    });
  });

  group('campos obrigatórios', () {
    test('bairro e fonte precisam ser escolhidos', () {
      expect(OccurrenceValidator.regiao(null), isNotNull);
      expect(OccurrenceValidator.regiao('mooca'), isNull);
      expect(OccurrenceValidator.fonte(null), isNotNull);
      expect(OccurrenceValidator.fonte(NoiseSource.obras), isNull);
    });
  });

  test('ocorrência soma nas reclamações e pode ser removida ou apagada',
      () async {
    SharedPreferences.setMockInitialValues({});
    final p = NoiseProvider(
        NoiseRepository(MockNoiseApiService(delay: Duration.zero)));
    await p.init();

    Occurrence nova(String id) => Occurrence(
          id: id,
          regionId: 'mooca',
          fonte: NoiseSource.obras,
          intensidade: 4,
          dataHora: DateTime(2026, 11, 12, 10),
        );

    final mooca = p.regionById('mooca')!;
    final antes = p.reclamacoesOf(mooca);

    await p.addOccurrence(nova('1'));
    expect(p.reclamacoesOf(mooca), antes + 1);

    await p.removeOccurrence('1');
    expect(p.reclamacoesOf(mooca), antes);

    await p.addOccurrence(nova('2'));
    await p.clearOccurrences();
    expect(p.occurrences, isEmpty);
  });
}