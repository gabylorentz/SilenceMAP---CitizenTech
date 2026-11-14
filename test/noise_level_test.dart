import 'package:flutter_test/flutter_test.dart';
import 'package:silencemap/logic/noise_level.dart';
import 'package:silencemap/models/noise_reading.dart';
import 'package:silencemap/models/region.dart';

void main() {
  // Zona sensível: limite 50 dB de dia e 45 dB à noite.
  const regiao = Region(
    id: 'x',
    nome: 'X',
    zona: ZoneType.sensivel,
    escolas: 1,
    hospitais: 1,
    reclamacoesMes: 0,
    latitude: 0,
    longitude: 0,
  );

  NoiseReading leitura(double db, int hora) => NoiseReading(
        regionId: 'x',
        dataHora: DateTime(2026, 11, 12, hora),
        decibeis: db,
        fonte: NoiseSource.transito,
      );

  test('classifica pelo limite diurno', () {
    expect(NoiseLevel.of(regiao, leitura(40, 10)), NoiseLevel.normal);
    expect(NoiseLevel.of(regiao, leitura(47, 10)), NoiseLevel.atencao);
    expect(NoiseLevel.of(regiao, leitura(52, 10)), NoiseLevel.alerta);
    expect(NoiseLevel.of(regiao, leitura(60, 10)), NoiseLevel.critico);
  });

  test('à noite usa o limite noturno (mais rígido)', () {
    // 52 dB: de dia é alerta, de noite (limite 45) é crítico.
    expect(NoiseLevel.of(regiao, leitura(52, 10)), NoiseLevel.alerta);
    expect(NoiseLevel.of(regiao, leitura(52, 23)), NoiseLevel.critico);
  });
}