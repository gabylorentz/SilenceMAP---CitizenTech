import '../models/noise_reading.dart';

class DailyPoint {
  final DateTime dia;
  final double media;
  const DailyPoint(this.dia, this.media);
}

class NoiseStats {
  NoiseStats._();

  static double _media(List<double> valores) =>
      valores.reduce((a, b) => a + b) / valores.length;

  /// Média diária usando só as leituras diurnas (7h às 22h),
  /// para comparar com o limite diurno da NBR 10151.
  /// Dias com menos de [minLeituras] leituras diurnas são descartados.
  static List<DailyPoint> mediaDiariaDiurna(
    List<NoiseReading> leituras, {
    int minLeituras = 1,
  }) {
    final porDia = <DateTime, List<double>>{};
    for (final l in leituras) {
      if (l.isNoturno) continue;
      final dia = DateTime(l.dataHora.year, l.dataHora.month, l.dataHora.day);
      porDia.putIfAbsent(dia, () => []).add(l.decibeis);
    }
    final dias = porDia.keys
        .where((d) => porDia[d]!.length >= minLeituras)
        .toList()
      ..sort();
    return [for (final d in dias) DailyPoint(d, _media(porDia[d]!))];
  }

  /// Média de dB por horário do dia (1h, 4h, 7h...), somando todas as regiões.
  /// Devolve um mapa ordenado pelo horário.
  static Map<int, double> mediaPorHorario(Iterable<List<NoiseReading>> listas) {
    final porHora = <int, List<double>>{};
    for (final lista in listas) {
      for (final l in lista) {
        porHora.putIfAbsent(l.dataHora.hour, () => []).add(l.decibeis);
      }
    }
    final horas = porHora.keys.toList()..sort();
    return {for (final h in horas) h: _media(porHora[h]!)};
  }

  /// Quantas leituras cada fonte de ruído teve, somando todas as regiões.
  static Map<NoiseSource, int> contagemPorFonte(
      Iterable<List<NoiseReading>> listas) {
    final contagem = <NoiseSource, int>{};
    for (final lista in listas) {
      for (final l in lista) {
        contagem[l.fonte] = (contagem[l.fonte] ?? 0) + 1;
      }
    }
    return contagem;
  }
}