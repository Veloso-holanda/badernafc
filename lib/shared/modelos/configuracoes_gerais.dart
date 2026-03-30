class ConfiguracoesGerais {
  final String id;
  final double valorCicloMensal;
  final double diaria;
  final double valorMensalista;
  final int diaFutebol;
  final String horaFutebol;

  const ConfiguracoesGerais({
    required this.id,
    required this.valorCicloMensal,
    required this.diaria,
    required this.valorMensalista,
    required this.diaFutebol,
    required this.horaFutebol,
  });

  factory ConfiguracoesGerais.fromJson(Map<String, dynamic> json) {
    return ConfiguracoesGerais(
      id: (json['_id'] as String?) ?? '',
      valorCicloMensal: (json['valorCicloMensal'] as num?)?.toDouble() ?? 0,
      diaria: (json['diaria'] as num?)?.toDouble() ?? 0,
      valorMensalista: (json['valorMensalista'] as num?)?.toDouble() ?? 0,
      diaFutebol: (json['diaFutebol'] as num?)?.toInt() ?? 0,
      horaFutebol: (json['horaFutebol'] as String?) ?? '21:00',
    );
  }
}
