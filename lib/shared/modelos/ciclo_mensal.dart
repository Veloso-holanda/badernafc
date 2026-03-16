class CicloMensal {
  final String id;
  final DateTime dataInicial;
  final DateTime dataFinal;
  final int diaSemana;
  final String horario;
  final double valorMensal;
  final int qtdPartidas;

  const CicloMensal({
    required this.id,
    required this.dataInicial,
    required this.dataFinal,
    required this.diaSemana,
    required this.horario,
    required this.valorMensal,
    required this.qtdPartidas,
  });

  factory CicloMensal.fromJson(Map<String, dynamic> json) {
    return CicloMensal(
      id: json['_id'] as String,
      dataInicial: DateTime.parse(json['dataInicial'] as String),
      dataFinal: DateTime.parse(json['dataFinal'] as String),
      diaSemana: json['diaSemana'] as int,
      horario: json['horario'] as String,
      valorMensal: (json['valorMensal'] as num).toDouble(),
      qtdPartidas: json['qtdPartidas'] as int,
    );
  }
}
