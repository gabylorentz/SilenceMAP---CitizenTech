/// Tipo de área com os limites de ruído (dB) de referência da NBR 10151.
enum ZoneType {
  sensivel('Escolas, hospitais e residencial estrito', 50, 45),
  residencial('Mista predominantemente residencial', 55, 50),
  comercial('Mista comercial/administrativa', 60, 55),
  lazer('Mista cultura e lazer', 65, 55),
  industrial('Predominantemente industrial', 70, 60);

  final String rotulo;
  final double limiteDiurno;
  final double limiteNoturno;

  const ZoneType(this.rotulo, this.limiteDiurno, this.limiteNoturno);
}

/// Região monitorada (bairro).
class Region {
  final String id;
  final String nome;
  final ZoneType zona;
  final int escolas;
  final int hospitais;
  final int reclamacoesMes;
  final double latitude;
  final double longitude;

  const Region({
    required this.id,
    required this.nome,
    required this.zona,
    required this.escolas,
    required this.hospitais,
    required this.reclamacoesMes,
    required this.latitude,
    required this.longitude,
  });

  /// Escolas + hospitais: locais sensíveis ao ruído.
  int get locaisSensiveis => escolas + hospitais;

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as String,
        nome: json['nome'] as String,
        zona: ZoneType.values.byName(json['zona'] as String),
        escolas: json['escolas'] as int,
        hospitais: json['hospitais'] as int,
        reclamacoesMes: json['reclamacoesMes'] as int,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'zona': zona.name,
        'escolas': escolas,
        'hospitais': hospitais,
        'reclamacoesMes': reclamacoesMes,
        'latitude': latitude,
        'longitude': longitude,
      };
}
