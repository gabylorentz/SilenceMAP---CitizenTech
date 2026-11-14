/// Sensibilidade dos alertas, ajustável pelo usuário.
/// Os limites em dB (NBR 10151) não entram aqui: eles não mudam.
class AlertConfig {
  static const List<double> inclinacoes = [0.05, 0.10, 0.20]; // dB por dia
  static const List<int> horizontes = [7, 14, 21]; // dias de antecedência
  static const padrao = AlertConfig();

  final double inclinacaoMinima;
  final int horizonteDias;

  const AlertConfig({this.inclinacaoMinima = 0.10, this.horizonteDias = 14});

  AlertConfig copyWith({double? inclinacaoMinima, int? horizonteDias}) =>
      AlertConfig(
        inclinacaoMinima: inclinacaoMinima ?? this.inclinacaoMinima,
        horizonteDias: horizonteDias ?? this.horizonteDias,
      );

  @override
  bool operator ==(Object other) =>
      other is AlertConfig &&
      other.inclinacaoMinima == inclinacaoMinima &&
      other.horizonteDias == horizonteDias;

  @override
  int get hashCode => Object.hash(inclinacaoMinima, horizonteDias);
}