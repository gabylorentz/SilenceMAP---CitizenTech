import 'package:flutter/foundation.dart';

import '../logic/alert_engine.dart';
import '../data/repositories/noise_repository.dart';
import '../data/services/mock_noise_api_service.dart';
import '../models/noise_data.dart';
import '../models/noise_reading.dart';
import '../models/occurrence.dart';
import '../models/region.dart';

enum LoadStatus { loading, loaded, error }

class NoiseProvider extends ChangeNotifier {
  final NoiseRepository _repo;
  NoiseProvider(this._repo);

  LoadStatus _status = LoadStatus.loading;
  NoiseData? _data;
  String? _errorMessage;
  List<Occurrence> _occurrences = [];
  bool _simulandoOffline = false;

  // ---- Leitura (as telas usam estes getters) ----
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get fromCache => _data?.fromCache ?? false;
  DateTime? get updatedAt => _data?.updatedAt;
  bool get simulandoOffline => _simulandoOffline;
  List<Region> get regions => _data?.regions ?? const [];
  List<Occurrence> get occurrences => List.unmodifiable(_occurrences);

  int get totalLeituras =>
      _data?.readings.values.fold<int>(0, (soma, l) => soma + l.length) ?? 0;

  List<NoiseReading> readingsOf(String regionId) =>
      _data?.readings[regionId] ?? const [];

  NoiseReading? latestOf(String regionId) {
    final lista = readingsOf(regionId);
    return lista.isEmpty ? null : lista.last;
  }

  Region? regionById(String id) {
    for (final r in regions) {
      if (r.id == id) return r;
    }
    return null;
  }

    /// Alerta (com justificativa) de uma região.
  Alert? alertOf(String regionId) {
    final regiao = regionById(regionId);
    if (regiao == null) return null;
    return AlertEngine.analisar(regiao, readingsOf(regionId));
  }

  /// Alertas de todas as regiões.
  List<Alert> get alerts => [
        for (final r in regions) AlertEngine.analisar(r, readingsOf(r.id)),
      ];

  // ---- Ações ----

  /// Chamado uma vez na abertura do app.
  Future<void> init() async {
    _occurrences = await _repo.loadOccurrences();
    await refresh();
  }

  Future<void> refresh() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _data = await _repo.load();
      _status = LoadStatus.loaded;
    } on NoiseApiException catch (e) {
      _errorMessage = e.message;
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Liga/desliga a falha da API (para demonstrar o modo offline).
  Future<void> setSimularOffline(bool valor) async {
    _simulandoOffline = valor;
    _repo.api.simularFalha = valor;
    await refresh();
  }

  Future<void> limparCacheERecarregar() async {
    await _repo.clearCache();
    _data = null;
    await refresh();
  }

  Future<void> addOccurrence(Occurrence ocorrencia) async {
    _occurrences = [ocorrencia, ..._occurrences];
    notifyListeners();
    await _repo.saveOccurrences(_occurrences);
  }
}