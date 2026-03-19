import 'jogador.dart';

class CicloMensal {
  final String id;
  final DateTime dataInicial;
  final DateTime dataFinal;
  final int qtdPartidas;
  final List<Jogador> mensalistas;

  const CicloMensal({
    required this.id,
    required this.dataInicial,
    required this.dataFinal,
    required this.qtdPartidas,
    this.mensalistas = const [],
  });

  factory CicloMensal.fromJson(Map<String, dynamic> json) {
    final mensalistasJson = json['mensalistas'] as List? ?? [];
    return CicloMensal(
      id: json['_id'] as String,
      dataInicial: DateTime.parse(json['dataInicial'] as String),
      dataFinal: DateTime.parse(json['dataFinal'] as String),
      qtdPartidas: (json['quantidadePartidas'] as num?)?.toInt() ?? 0,
      mensalistas: mensalistasJson
          .whereType<Map<String, dynamic>>()
          .map(Jogador.fromJson)
          .toList(),
    );
  }
}
