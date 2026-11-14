import 'dart:math';

import '../models/alert_config.dart';
import '../models/noise_reading.dart';
import '../models/region.dart';
import 'noise_level.dart';
import 'noise_stats.dart';

enum AlertKind { normal, preventivo, excedido, insuficiente }

enum Confidence {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  final String rotulo;
  const Confidence(this.rotulo);
}

/// Resultado da análise de uma região, com a justificativa completa.
class Alert {
  final Region regiao;
  final AlertKind kind;
  final NoiseLevel nivel;
  final String titulo;
  final String resumo;
  final double limite;
  final double? mediaAtual; // média móvel de 3 dias
  final double? tendencia; // dB por dia (inclinação da reta)
  final double? r2; // quão bem a reta explica os dados (0 a 1)
  final int? diasAteLimite;
  final int diasAnalisados;
  final Confidence confianca;
  final List<String> evidencias;
  final List<String> limitacoes;

  const Alert({
    required this.regiao,
    required this.kind,
    required this.nivel,
    required this.titulo,
    required this.resumo,
    required this.limite,
    this.mediaAtual,
    this.tendencia,
    this.r2,
    this.diasAteLimite,
    required this.diasAnalisados,
    required this.confianca,
    required this.evidencias,
    required this.limitacoes,
  });

  /// Região que merece atenção (limite excedido ou tendência de alta).
  bool get ativo =>
      kind == AlertKind.excedido || kind == AlertKind.preventivo;
}

class _Regressao {
  final double inclinacao;
  final double intercepto;
  final double r2;
  const _Regressao(this.inclinacao, this.intercepto, this.r2);
}

class AlertEngine {
  AlertEngine._();

  static const diasMinimos = 7;
  static const leiturasPorDia = 5; // 7h, 10h, 13h, 16h e 19h
  static const r2Minimo = 0.4;
  static const r2Alto = 0.7;

  // Valores padrão. O usuário pode mudar em Configurações (ver AlertConfig).
  static const inclinacaoMinima = 0.1; // dB por dia
  static const horizonteDias = 14;

  /// Formata número com vírgula (padrão brasileiro).
  static String fmt(double v, [int casas = 1]) =>
      v.toStringAsFixed(casas).replaceAll('.', ',');

  static String fmtSinal(double v, [int casas = 2]) =>
      v >= 0 ? '+${fmt(v, casas)}' : fmt(v, casas);

  static Alert analisar(
    Region regiao,
    List<NoiseReading> leituras, {
    AlertConfig config = AlertConfig.padrao,
  }) {
    final limite = regiao.zona.limiteDiurno;
    final pontos = NoiseStats.mediaDiariaDiurna(
      leituras,
      minLeituras: leiturasPorDia,
    );
    final n = pontos.length;

    if (n < diasMinimos) {
      return Alert(
        regiao: regiao,
        kind: AlertKind.insuficiente,
        nivel: NoiseLevel.normal,
        titulo: 'Dados insuficientes',
        resumo: 'Há poucos dias completos de leitura para estimar uma tendência.',
        limite: limite,
        diasAnalisados: n,
        confianca: Confidence.baixa,
        evidencias: [
          'Apenas $n dias completos de leitura (mínimo: $diasMinimos).',
        ],
        limitacoes: _limitacoesBase(n),
      );
    }

    final medias = [for (final p in pontos) p.media];

    // Média móvel: média dos 3 últimos dias (suaviza o ruído de cada dia).
    final atual = (medias[n - 1] + medias[n - 2] + medias[n - 3]) / 3;
    final excesso = atual - limite;

    // Regressão linear: a inclinação é quanto o ruído sobe por dia.
    final reg = _regressao(medias);
    final ajustadoHoje = reg.intercepto + reg.inclinacao * (n - 1);

    var kind = AlertKind.normal;
    var nivel = NoiseLevel.normal;
    int? dias;
    var altaDistante = false;

    if (excesso > 0) {
      kind = AlertKind.excedido;
      nivel = excesso > 5 ? NoiseLevel.critico : NoiseLevel.alerta;
    } else if (reg.inclinacao >= config.inclinacaoMinima &&
        reg.r2 >= r2Minimo) {
      final previsto =
          max(1, ((limite - ajustadoHoje) / reg.inclinacao).ceil());
      if (previsto <= config.horizonteDias) {
        kind = AlertKind.preventivo;
        nivel = NoiseLevel.atencao;
        dias = previsto;
      } else {
        altaDistante = true;
      }
    }

    final String titulo;
    final String resumo;
    if (kind == AlertKind.excedido) {
      titulo = 'Limite excedido';
      resumo = 'A média diurna dos últimos 3 dias (${fmt(atual)} dB) está '
          '${fmt(excesso)} dB acima do limite de ${fmt(limite, 0)} dB para esta zona.';
    } else if (kind == AlertKind.preventivo) {
      titulo = 'Tendência de alta';
      resumo = 'O ruído sobe cerca de ${fmt(reg.inclinacao)} dB por dia. '
          'Mantido esse ritmo, deve atingir o limite de ${fmt(limite, 0)} dB '
          'em cerca de $dias dias.';
    } else {
      titulo = 'Sem alerta';
      resumo = altaDistante
          ? 'Há tendência de alta, mas o limite só seria atingido em mais de '
              '${config.horizonteDias} dias.'
          : 'Média de ${fmt(atual)} dB, ${fmt(-excesso)} dB abaixo do limite de '
              '${fmt(limite, 0)} dB, sem tendência de alta relevante.';
    }

    final fonte = _fontePredominante(leituras);
    final evidencias = <String>[
      'Média móvel de 3 dias: ${fmt(atual)} dB (limite diurno: ${fmt(limite, 0)} dB).',
      'Regressão linear em $n dias: ${fmtSinal(reg.inclinacao)} dB/dia, '
          'R² = ${fmt(reg.r2, 2)}.',
      if (dias != null)
        'Projeção: limite atingido em cerca de $dias dias se o ritmo se mantiver.',
      if (fonte != null) 'Fonte predominante: $fonte.',
      'Locais sensíveis na região: ${regiao.escolas} escolas e '
          '${regiao.hospitais} hospitais.',
    ];

    final limitacoes = <String>[
      ..._limitacoesBase(n),
      if (reg.r2 < r2Minimo)
        'Tendência inconclusiva (R² = ${fmt(reg.r2, 2)}): os dados oscilam sem direção clara.',
    ];

    // Confiança no diagnóstico: depende da quantidade de dias
    // e, no alerta de tendência, de quão bem a reta se ajusta.
    final confianca = kind == AlertKind.preventivo
        ? (reg.r2 >= r2Alto && n >= 10 ? Confidence.alta : Confidence.media)
        : (n >= 10 ? Confidence.alta : Confidence.media);

    return Alert(
      regiao: regiao,
      kind: kind,
      nivel: nivel,
      titulo: titulo,
      resumo: resumo,
      limite: limite,
      mediaAtual: atual,
      tendencia: reg.inclinacao,
      r2: reg.r2,
      diasAteLimite: dias,
      diasAnalisados: n,
      confianca: confianca,
      evidencias: evidencias,
      limitacoes: limitacoes,
    );
  }

  static List<String> _limitacoesBase(int n) => [
        'Dados sintéticos de demonstração: não são medições reais.',
        'Janela de $n dias: poucos dados para prever mudanças de comportamento.',
        'A projeção é linear e assume que o ritmo atual continua; fim de obra ou de evento não é previsto.',
        'Limites de referência da NBR 10151; uma avaliação formal exige medição técnica conforme a norma.',
      ];

  static _Regressao _regressao(List<double> y) {
    final n = y.length;
    final mediaX = (n - 1) / 2;
    final mediaY = y.reduce((a, b) => a + b) / n;
    var sxy = 0.0, sxx = 0.0, syy = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = i - mediaX;
      final dy = y[i] - mediaY;
      sxy += dx * dy;
      sxx += dx * dx;
      syy += dy * dy;
    }
    final inclinacao = sxy / sxx;
    final r2 = syy == 0 ? 0.0 : (sxy * sxy) / (sxx * syy);
    return _Regressao(inclinacao, mediaY - inclinacao * mediaX, r2);
  }

  /// Fonte mais frequente nos últimos 7 dias de leituras.
  static String? _fontePredominante(List<NoiseReading> leituras) {
    if (leituras.isEmpty) return null;
    final fim =
        leituras.map((l) => l.dataHora).reduce((a, b) => a.isAfter(b) ? a : b);
    final corte = fim.subtract(const Duration(days: 7));
    final contagem = <NoiseSource, int>{};
    var total = 0;
    for (final l in leituras) {
      if (!l.dataHora.isAfter(corte)) continue;
      contagem[l.fonte] = (contagem[l.fonte] ?? 0) + 1;
      total++;
    }
    if (total == 0) return null;
    final topo = contagem.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final pct = (topo.value * 100 / total).round();
    return '${topo.key.rotulo} ($pct% das leituras dos últimos 7 dias)';
  }
}