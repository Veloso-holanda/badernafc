class Jogador {
  final String id;
  final String nome;
  final String? apelido;
  final int nivel;
  final int? nota;
  final bool mensalista;

  const Jogador({
    required this.id,
    required this.nome,
    this.apelido,
    required this.nivel,
    this.nota,
    this.mensalista = false,
  });

  String get nomeExibicao => apelido ?? nome;

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      id: json['_id'] as String,
      nome: json['nome'] as String,
      apelido: json['apelido'] as String?,
      nivel: json['nivel'] as int,
    );
  }

  factory Jogador.fromPartidaJson(Map<String, dynamic> json) {
    final jogadorData = json['jogador'] as Map<String, dynamic>;
    return Jogador(
      id: jogadorData['_id'] as String,
      nome: jogadorData['nome'] as String,
      apelido: jogadorData['apelido'] as String?,
      nivel: jogadorData['nivel'] as int,
      nota: json['nota'] as int?,
      mensalista: json['mensalista'] as bool? ?? false,
    );
  }
}
