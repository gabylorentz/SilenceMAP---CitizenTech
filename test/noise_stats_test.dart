import 'package:flutter_test/flutter_test.dart';
import 'package:silencemap/logic/noise_stats.dart';
import 'package:silencemap/models/noise_reading.dart';

void main() {
  NoiseReading leitura(int dia, int hora, double db, NoiseSource fonte) =>
      NoiseReading(
        regionId: 'x',
        dataHora: DateTime(2026, 11, dia, hora),
        decibeis: db,
        fonte: fonte,
      );

  test('média diária ignora as leituras noturnas', () {
    final pontos = NoiseStats.mediaDiariaDiurna([
      leitura(1, 10, 50, NoiseSource.transito),
      leitura(1, 13, 60, NoiseSource.transito),
      leitura(1, 23, 30, NoiseSource.transito), // noturna: fora da média
      leitura(2, 10, 70, NoiseSource.transito),
    ]);
    expect(pontos.length, 2);
    expect(pontos[0].media, 55);
    expect(pontos[1].media, 70);
  });

  test('média por horário junta várias regiões', () {
    final mapa = NoiseStats.mediaPorHorario([
      [leitura(1, 10, 50, NoiseSource.obras)],
      [leitura(1, 10, 60, NoiseSource.obras), leitura(1, 19, 70, NoiseSource.obras)],
    ]);
    expect(mapa[10], 55);
    expect(mapa[19], 70);
    expect(mapa.keys.toList(), [10, 19]); // ordenado por horário
  });

  test('conta as fontes de ruído', () {
    final contagem = NoiseStats.contagemPorFonte([
      [
        leitura(1, 10, 50, NoiseSource.obras),
        leitura(1, 13, 50, NoiseSource.obras),
        leitura(1, 16, 50, NoiseSource.transito),
      ],
    ]);
    expect(contagem[NoiseSource.obras], 2);
    expect(contagem[NoiseSource.transito], 1);
  });
}