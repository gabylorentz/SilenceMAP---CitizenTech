import 'package:flutter/material.dart';

/// Paleta central do SilenceMAP.
/// Cores dos níveis de ruído ficam aqui para todo o app usar o mesmo padrão.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF3949AB);   // índigo (marca)
  static const secondary = Color(0xFF00897B); // verde-azulado

  // Níveis de ruído / alerta
  static const normal = Color(0xFF2E7D32);  // verde
  static const atencao = Color(0xFFF9A825); // amarelo
  static const alerta = Color(0xFFEF6C00);  // laranja
  static const critico = Color(0xFFC62828); // vermelho
}