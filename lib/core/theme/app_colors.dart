import 'package:flutter/material.dart';

/// Paleta central do SilenceMAP.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF3949AB);   // índigo (marca)
  static const secondary = Color(0xFF00897B); // verde-azulado

  // Níveis de ruído / alerta
  static const normal = Color(0xFF2E7D32);  // verde
  static const atencao = Color(0xFFF9A825); // amarelo
  static const alerta = Color(0xFFEF6C00);  // laranja
  static const critico = Color(0xFFC62828); // vermelho

  /// Razão de contraste entre duas cores (de 1 a 21).
  static double contraste(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final claro = la > lb ? la : lb;
    final escuro = la > lb ? lb : la;
    return (claro + 0.05) / (escuro + 0.05);
  }

  /// Escurece (fundo claro) ou clareia (fundo escuro) a [cor]
  /// até ela atingir o contraste [minimo] sobre o [fundo].
  /// 4,5 é o mínimo da WCAG para texto.
  static Color legivel(Color cor, Color fundo, {double minimo = 4.5}) {
    final alvo = fundo.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    var resultado = cor;
    for (var i = 0; i < 20 && contraste(resultado, fundo) < minimo; i++) {
      resultado = Color.lerp(resultado, alvo, 0.1)!;
    }
    return resultado;
  }
}
