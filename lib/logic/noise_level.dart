import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/noise_reading.dart';
import '../models/region.dart';

enum NoiseLevel {
  normal('NORMAL', AppColors.normal),
  atencao('ATENÇÃO', AppColors.atencao),
  alerta('ALERTA', AppColors.alerta),
  critico('CRÍTICO', AppColors.critico);

  final String rotulo;
  final Color cor;
  const NoiseLevel(this.rotulo, this.cor);

  /// Compara a leitura com o limite da zona (dia ou noite).
  /// Mais de 5 dB acima = crítico; acima do limite = alerta;
  /// até 5 dB abaixo do limite = atenção; o resto = normal.
  static NoiseLevel of(Region regiao, NoiseReading leitura) {
    final limite = leitura.isNoturno
        ? regiao.zona.limiteNoturno
        : regiao.zona.limiteDiurno;
    final excesso = leitura.decibeis - limite;
    if (excesso > 5) return critico;
    if (excesso > 0) return alerta;
    if (excesso > -5) return atencao;
    return normal;
  }
}