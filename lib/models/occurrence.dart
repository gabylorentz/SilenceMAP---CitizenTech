import 'noise_reading.dart';

class Occurrence {
  final String id;
  final String regionId;
  final NoiseSource fonte;
  final int intensidade; // 1 (baixa) a 5 (insuportável)
  final DateTime dataHora;
  final String? descricao;

  const Occurrence({
    required this.id,
    required this.regionId,
    required this.fonte,
    required this.intensidade,
    required this.dataHora,
    this.descricao,
  });

  factory Occurrence.fromJson(Map<String, dynamic> json) => Occurrence(
        id: json['id'] as String,
        regionId: json['regionId'] as String,
        fonte: NoiseSource.values.byName(json['fonte'] as String),
        intensidade: json['intensidade'] as int,
        dataHora: DateTime.parse(json['dataHora'] as String),
        descricao: json['descricao'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'regionId': regionId,
        'fonte': fonte.name,
        'intensidade': intensidade,
        'dataHora': dataHora.toIso8601String(),
        'descricao': descricao,
      };
}