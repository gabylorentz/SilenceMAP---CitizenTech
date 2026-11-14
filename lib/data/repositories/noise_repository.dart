import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/alert_config.dart';
import '../../models/noise_data.dart';
import '../../models/occurrence.dart';
import '../services/mock_noise_api_service.dart';

/// Junta a API simulada com o cache local (shared_preferences).
class NoiseRepository {
  static const _cacheKey = 'silencemap_noise_cache_v1';
  static const _occurrencesKey = 'silencemap_occurrences_v1';
  static const _slopeKey = 'silencemap_alert_slope_v1';
  static const _horizonKey = 'silencemap_alert_horizon_v1';

  final MockNoiseApiService api;
  NoiseRepository(this.api);

  /// Tenta a API. Se der certo, salva no cache.
  /// Se falhar, devolve o último cache salvo. Sem cache, repassa o erro.
  Future<NoiseData> load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final regions = await api.fetchRegions();
      final listas = await Future.wait(
        regions.map((r) => api.fetchReadings(r.id)),
      );
      final data = NoiseData(
        regions: regions,
        readings: {
          for (var i = 0; i < regions.length; i++) regions[i].id: listas[i],
        },
        updatedAt: DateTime.now(),
        fromCache: false,
      );
      await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
      return data;
    } on NoiseApiException {
      final salvo = prefs.getString(_cacheKey);
      if (salvo == null) rethrow; // sem internet e sem cache: mostra o erro
      return NoiseData.fromJson(
        jsonDecode(salvo) as Map<String, dynamic>,
        fromCache: true,
      );
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  // ---- Ocorrências registradas pelo cidadão (ficam só no aparelho) ----

  Future<List<Occurrence>> loadOccurrences() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_occurrencesKey);
    if (salvo == null) return [];
    return (jsonDecode(salvo) as List)
        .map((e) => Occurrence.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveOccurrences(List<Occurrence> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _occurrencesKey,
      jsonEncode(lista.map((o) => o.toJson()).toList()),
    );
  }

  // ---- Sensibilidade dos alertas (preferência do usuário) ----

  Future<AlertConfig> loadAlertConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final inclinacao = prefs.getDouble(_slopeKey);
    final horizonte = prefs.getInt(_horizonKey);
    // Valores fora das opções permitidas voltam para o padrão.
    return AlertConfig(
      inclinacaoMinima: AlertConfig.inclinacoes.contains(inclinacao)
          ? inclinacao!
          : AlertConfig.padrao.inclinacaoMinima,
      horizonteDias: AlertConfig.horizontes.contains(horizonte)
          ? horizonte!
          : AlertConfig.padrao.horizonteDias,
    );
  }

  Future<void> saveAlertConfig(AlertConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_slopeKey, config.inclinacaoMinima);
    await prefs.setInt(_horizonKey, config.horizonteDias);
  }
}