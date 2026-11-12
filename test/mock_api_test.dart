import 'package:flutter_test/flutter_test.dart';
import 'package:silencemap/data/services/mock_noise_api_service.dart';
import 'package:silencemap/models/noise_reading.dart';

void main() {
  final api = MockNoiseApiService(delay: Duration.zero);

  test('retorna as 6 regiões monitoradas', () async {
    final regioes = await api.fetchRegions();
    expect(regioes.length, 6);
  });

  test('gera leituras em faixa realista (30 a 110 dB)', () async {
    final leituras = await api.fetchReadings('vila_mariana');
    expect(leituras, isNotEmpty);
    for (final l in leituras) {
      expect(l.decibeis, inInclusiveRange(30, 110));
    }
  });

  test('dados sintéticos são reproduzíveis', () async {
    final a = await api.fetchReadings('mooca');
    final b = await api.fetchReadings('mooca');
    expect(a.first.decibeis, b.first.decibeis);
  });

  test('região inexistente gera erro', () async {
    expect(api.fetchReadings('xyz'), throwsA(isA<NoiseApiException>()));
  });

  test('simula falha de conexão', () async {
    final offline = MockNoiseApiService(delay: Duration.zero, simularFalha: true);
    expect(offline.fetchRegions(), throwsA(isA<NoiseApiException>()));
  });

  test('toJson/fromJson preserva a leitura', () async {
    final original = (await api.fetchReadings('centro')).first;
    final copia = NoiseReading.fromJson(original.toJson());
    expect(copia.decibeis, original.decibeis);
    expect(copia.fonte, original.fonte);
  });
}