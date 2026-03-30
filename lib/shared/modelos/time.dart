class Time {
  final String id;
  final String nome;
  final String? descricao;
  final String? logoUrl;
  final String codigoConvite;
  final String criadorId;
  final bool ativo;

  const Time({
    required this.id,
    required this.nome,
    this.descricao,
    this.logoUrl,
    required this.codigoConvite,
    required this.criadorId,
    this.ativo = true,
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      id: json['_id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      logoUrl: json['logoUrl'] as String?,
      codigoConvite: json['codigoConvite'] as String,
      criadorId: json['criadorId'] as String? ?? json['criador'] as String? ?? '',
      ativo: json['ativo'] as bool? ?? true,
    );
  }
}
