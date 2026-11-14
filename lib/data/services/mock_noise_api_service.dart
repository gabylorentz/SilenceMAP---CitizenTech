import 'dart:math';

import '../../models/noise_reading.dart';
import '../../models/region.dart';

/// Erro de API (usado para mostrar a tela de erro no app).
class NoiseApiException implements Exception {
  final String message;
  NoiseApiException(this.message);

  @override
  String toString() => message;
}

/// Perfil sintético de cada região: nível base, tendência e fontes.
class _Perfil {
  final double base; // dB médio diurno no início do período
  final double tendenciaDia; // quanto o ruído sobe (ou cai) por dia
  final List<NoiseSource> fontes; // a primeira é a predominante

  const _Perfil(this.base, this.tendenciaDia, this.fontes);
}

/// API simulada: gera dados sintéticos e reproduzíveis de ruído urbano.
/// Os dados NÃO são medições reais; servem para demonstrar o app.
class MockNoiseApiService {
  final Duration delay;
  bool simularFalha;

  MockNoiseApiService({
    this.delay = const Duration(milliseconds: 800),
    this.simularFalha = false,
  });

  static const List<Region> _regioes = [
    Region(id: 'pinheiros', nome: 'Pinheiros', zona: ZoneType.lazer,
        escolas: 4, hospitais: 1, reclamacoesMes: 38,
        latitude: -23.5614, longitude: -46.6820),
    Region(id: 'mooca', nome: 'Mooca', zona: ZoneType.residencial,
        escolas: 6, hospitais: 2, reclamacoesMes: 21,
        latitude: -23.5587, longitude: -46.5996),
    Region(id: 'centro', nome: 'Centro', zona: ZoneType.comercial,
        escolas: 3, hospitais: 3, reclamacoesMes: 45,
        latitude: -23.5505, longitude: -46.6333),
    Region(id: 'vila_mariana', nome: 'Vila Mariana', zona: ZoneType.sensivel,
        escolas: 8, hospitais: 4, reclamacoesMes: 12,
        latitude: -23.5891, longitude: -46.6345),
    Region(id: 'santana', nome: 'Santana', zona: ZoneType.residencial,
        escolas: 5, hospitais: 1, reclamacoesMes: 9,
        latitude: -23.5025, longitude: -46.6250),
    Region(id: 'barra_funda', nome: 'Barra Funda', zona: ZoneType.industrial,
        escolas: 1, hospitais: 0, reclamacoesMes: 6,
        latitude: -23.5258, longitude: -46.6667),
  ];

  // Cada região conta uma "história" diferente para os alertas.
  static const Map<String, _Perfil> _perfis = {
    'pinheiros': _Perfil(62, 0.35,
        [NoiseSource.eventos, NoiseSource.comercio, NoiseSource.transito]),
    'mooca': _Perfil(53, 0.45, [NoiseSource.obras, NoiseSource.transito]),
    'centro': _Perfil(63, 0.05, [NoiseSource.transito, NoiseSource.comercio]),
    'vila_mariana': _Perfil(44, 0.25, [NoiseSource.transito, NoiseSource.obras]),
    'santana': _Perfil(50, -0.10, [NoiseSource.transito, NoiseSource.outros]),
    'barra_funda': _Perfil(64, 0.0, [NoiseSource.transito, NoiseSource.obras]),
  };

  // Horários das medições (a cada 3 horas).
  static const List<int> _horarios = [1, 4, 7, 10, 13, 16, 19, 22];

  Future<List<Region>> fetchRegions() async {
    await _simularRede();
    return List.unmodifiable(_regioes);
  }

  Future<List<NoiseReading>> fetchReadings(String regionId, {int dias = 14}) async {
    await _simularRede();
    final indice = _regioes.indexWhere((r) => r.id == regionId);
    if (indice == -1) {
      throw NoiseApiException('Região "$regionId" não encontrada.');
    }
    return _gerarLeituras(regionId, dias, seed: indice + 7);
  }

  Future<void> _simularRede() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (simularFalha) {
      throw NoiseApiException('Não foi possível conectar ao servidor de dados.');
    }
  }

  List<NoiseReading> _gerarLeituras(String regionId, int dias, {required int seed}) {
    final perfil = _perfis[regionId]!;
    final rnd = Random(seed); // seed fixa = dados iguais a cada execução
    final agora = DateTime.now();
    final inicio = DateTime(agora.year, agora.month, agora.day)
        .subtract(Duration(days: dias - 1));

    final leituras = <NoiseReading>[];
    for (var dia = 0; dia < dias; dia++) {
      for (final hora in _horarios) {
        final dataHora = inicio.add(Duration(days: dia, hours: hora));
        if (dataHora.isAfter(agora)) continue; // não gera o futuro

        final ruidoAleatorio = rnd.nextDouble() * 4 - 2; // -2 a +2 dB
        final db = perfil.base +
            perfil.tendenciaDia * dia +
            _efeitoHorario(hora) +
            ruidoAleatorio;

        leituras.add(NoiseReading(
          regionId: regionId,
          dataHora: dataHora,
          decibeis: double.parse(db.clamp(30, 110).toStringAsFixed(1)),
          fonte: _sortearFonte(perfil.fontes, rnd),
        ));
      }
    }
    return leituras;
  }

  /// Madrugada mais silenciosa, pico no fim da tarde (rush).
  double _efeitoHorario(int hora) {
    switch (hora) {
      case 1:
      case 4:
        return -10;
      case 7:
        return -2;
      case 19:
        return 4;
      case 22:
        return -4;
      default:
        return 2; // 10h, 13h, 16h
    }
  }

  /// 60% de chance da fonte predominante, senão uma das outras.
  NoiseSource _sortearFonte(List<NoiseSource> fontes, Random rnd) {
    if (fontes.length == 1 || rnd.nextDouble() < 0.6) return fontes.first;
    return fontes[1 + rnd.nextInt(fontes.length - 1)];
  }
}