/// Fonte predominante do ruído.
enum NoiseSource {
  transito('Trânsito'),
  obras('Obras'),
  eventos('Eventos'),
  comercio('Comércio'),
  outros('Outros');

  final String rotulo;
  const NoiseSource(this.rotulo);
}

/// Uma medição de ruído em uma região.
class NoiseReading {
  final String regionId;
  final DateTime dataHora;
  final double decibeis;
  final NoiseSource fonte;

  const NoiseReading({
    required this.regionId,
    required this.dataHora,
    required this.decibeis,
    required this.fonte,
  });

  /// Período noturno da NBR 10151: 22h às 7h.
  bool get isNoturno => dataHora.hour >= 22 || dataHora.hour < 7;

  factory NoiseReading.fromJson(Map<String, dynamic> json) => NoiseReading(
        regionId: json['regionId'] as String,
        dataHora: DateTime.parse(json['dataHora'] as String),
        decibeis: (json['decibeis'] as num).toDouble(),
        fonte: NoiseSource.values.byName(json['fonte'] as String),
      );

  Map<String, dynamic> toJson() => {
        'regionId': regionId,
        'dataHora': dataHora.toIso8601String(),
        'decibeis': decibeis,
        'fonte': fonte.name,
      };
}