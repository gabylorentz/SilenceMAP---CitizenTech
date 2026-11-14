import 'noise_reading.dart';
import 'region.dart';

/// Conjunto de dados carregado: regiões + leituras de cada região.
class NoiseData {
  final List<Region> regions;
  final Map<String, List<NoiseReading>> readings;
  final DateTime updatedAt;
  final bool fromCache; // true = veio do cache (sem conexão)

  const NoiseData({
    required this.regions,
    required this.readings,
    required this.updatedAt,
    required this.fromCache,
  });

  Map<String, dynamic> toJson() => {
        'updatedAt': updatedAt.toIso8601String(),
        'regions': regions.map((r) => r.toJson()).toList(),
        'readings': readings.map(
          (id, lista) => MapEntry(id, lista.map((l) => l.toJson()).toList()),
        ),
      };

  factory NoiseData.fromJson(Map<String, dynamic> json, {required bool fromCache}) {
    return NoiseData(
      regions: (json['regions'] as List)
          .map((e) => Region.fromJson(e as Map<String, dynamic>))
          .toList(),
      readings: (json['readings'] as Map<String, dynamic>).map(
        (id, lista) => MapEntry(
          id,
          (lista as List)
              .map((e) => NoiseReading.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fromCache: fromCache,
    );
  }
}