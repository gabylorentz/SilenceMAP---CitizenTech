import 'package:flutter_test/flutter_test.dart';
import 'package:silencemap/logic/alert_engine.dart';
import 'package:silencemap/logic/noise_level.dart';
import 'package:silencemap/models/noise_reading.dart';
import 'package:silencemap/models/region.dart';

void main() {
  // Zona sensível: limite diurno de 50 dB.
  const regiao = Region(
    id: 'x',
    nome: 'X',
    zona: ZoneType.sensivel,
    escolas: 2,
    hospitais: 1,
    reclamacoesMes: 0,
    latitude: 0,
    longitude: 0,
  );

  /// [dias] dias completos (5 leituras diurnas por dia) com valor em dB
  /// dado por [valor].
  List<NoiseReading> serie(int dias, double Function(int dia) valor) => [
        for (var d = 0; d < dias; d++)
          for (final h in [7, 10, 13, 16, 19])
            NoiseReading(
              regionId: 'x',
              dataHora: DateTime(2026, 11, 1 + d, h),
              decibeis: valor(d),
              fonte: NoiseSource.transito,
            ),
      ];

  test('tendência de alta abaixo do limite gera alerta preventivo', () {
    final a = AlertEngine.analisar(regiao, serie(14, (d) => 44 + 0.25 * d));
    expect(a.kind, AlertKind.preventivo);
    expect(a.nivel, NoiseLevel.atencao);
    expect(a.diasAteLimite, inInclusiveRange(10, 12));
    expect(a.confianca, Confidence.alta);
  });

  test('média acima do limite gera alerta de limite excedido', () {
    final a = AlertEngine.analisar(regiao, serie(14, (d) => 53));
    expect(a.kind, AlertKind.excedido);
    expect(a.nivel, NoiseLevel.alerta);
  });

  test('mais de 5 dB acima do limite é crítico', () {
    final a = AlertEngine.analisar(regiao, serie(14, (d) => 58));
    expect(a.nivel, NoiseLevel.critico);
  });

  test('ruído estável abaixo do limite não gera alerta', () {
    final a = AlertEngine.analisar(regiao, serie(14, (d) => 40));
    expect(a.kind, AlertKind.normal);
    expect(a.ativo, false);
  });

  test('tendência de queda não gera alerta', () {
    final a = AlertEngine.analisar(regiao, serie(14, (d) => 49 - 0.3 * d));
    expect(a.kind, AlertKind.normal);
  });

  test('oscilação sem direção clara não gera alerta de tendência', () {
    final a =
        AlertEngine.analisar(regiao, serie(14, (d) => d.isEven ? 45 : 43));
    expect(a.kind, AlertKind.normal);
  });

  test('poucos dias geram "dados insuficientes"', () {
    final a = AlertEngine.analisar(regiao, serie(3, (d) => 60));
    expect(a.kind, AlertKind.insuficiente);
    expect(a.confianca, Confidence.baixa);
  });

  test('dia incompleto é ignorado na análise', () {
    final leituras = [
      ...serie(13, (d) => 40),
      // Hoje só tem a leitura das 7h, com um valor absurdo.
      NoiseReading(
        regionId: 'x',
        dataHora: DateTime(2026, 11, 14, 7),
        decibeis: 90,
        fonte: NoiseSource.transito,
      ),
    ];
    final a = AlertEngine.analisar(regiao, leituras);
    expect(a.kind, AlertKind.normal);
    expect(a.diasAnalisados, 13);
  });

  test('todo alerta traz evidências e limitações', () {
    for (final dias in [3, 14]) {
      final a = AlertEngine.analisar(regiao, serie(dias, (d) => 44 + 0.25 * d));
      expect(a.evidencias, isNotEmpty);
      expect(a.limitacoes, isNotEmpty);
    }
  });
}