class Despesa {
  final String id;
  final String cicloMensalId;
  final String descricao;
  final double valor;
  final DateTime? data;

  const Despesa({
    required this.id,
    required this.cicloMensalId,
    required this.descricao,
    required this.valor,
    this.data,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: json['_id'] as String,
      cicloMensalId: (json['cicloMensal'] ?? json['cicloMensalId']) as String,
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      data: json['data'] != null ? DateTime.parse(json['data'] as String) : null,
    );
  }
}
