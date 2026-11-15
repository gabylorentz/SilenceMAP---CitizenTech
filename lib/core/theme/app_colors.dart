import 'package:flutter/material.dart';

/// Paleta central do SilenceMAP.
class AppColors {
  AppColors._();

  // Marca (verde-acinzentado suave)
  static const primary = Color(0xFF3F574D);
  static const primaryEscuro = Color(0xFFB4CDC1);
  static const onPrimaryEscuro = Color(0xFF12201A);
  static const secondary = Color(0xFF6B5B95); // lavanda

  // Níveis de ruído / alerta (cores semânticas, não mudam)
  static const normal = Color(0xFF2E7D32);  // verde
  static const atencao = Color(0xFFF9A825); // amarelo
  static const alerta = Color(0xFFEF6C00);  // laranja
  static const critico = Color(0xFFC62828); // vermelho

  // Fundo em degradê
  static const gradClaro = [
    Color(0xFFECE7DF),
    Color(0xFFD6DDD4),
    Color(0xFFC3CED2),
  ];
  static const gradEscuro = [
    Color(0xFF2F3534),
    Color(0xFF252B2C),
    Color(0xFF1B2227),
  ];

  // Textos
  static const textoClaro = Color(0xFF1F2624);
  static const textoSecundarioClaro = Color(0xFF3E4945);
  static const textoEscuro = Color(0xFFEEF1EC);
  static const textoSecundarioEscuro = Color(0xFFBCC5C0);

  // Contornos
  static const contornoClaro = Color(0xFF6B7672);
  static const contornoEscuro = Color(0xFF8E9994);

  // Cor opaca aproximada do cartão de vidro (usada para calcular contraste)
  static const cartaoClaro = Color(0xFFEFF1EE);
  static const cartaoEscuro = Color(0xFF363C3D);

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
  /// 4,5 é o mínimo da WCAG para texto; 3 vale para ícones.
  static Color legivel(Color cor, Color fundo, {double minimo = 4.5}) {
    final alvo = fundo.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    var resultado = cor;
    for (var i = 0; i < 20 && contraste(resultado, fundo) < minimo; i++) {
      resultado = Color.lerp(resultado, alvo, 0.1)!;
    }
    return resultado;
  }
}
