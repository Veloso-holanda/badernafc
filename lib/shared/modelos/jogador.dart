class Jogador {
  final String id;
  final String nome;
  final String? apelido;
  final int nivel;
  final int? nota;
  final bool mensalista;
  final bool pago;
  final bool ehGoleiro;
  final String? fotoUrl;
  final String? codigoVincular;
  final String? usuarioId;

  const Jogador({
    required this.id,
    required this.nome,
    this.apelido,
    required this.nivel,
    this.nota,
    this.mensalista = false,
    this.pago = false,
    this.ehGoleiro = false,
    this.fotoUrl,
    this.codigoVincular,
    this.usuarioId,
  });

  String get nomeExibicao => apelido ?? nome;

  bool get vinculado => usuarioId != null;

  static String? _stringOuNull(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    return valor;
  }

  static String? _extrairFotoUrl(dynamic usuario) {
    if (usuario == null) return null;
    if (usuario is Map) return _stringOuNull(usuario['fotoUrl'] as String?);
    return null;
  }

  static String? _extrairUsuarioId(dynamic usuario) {
    if (usuario == null) return null;
    if (usuario is String) return usuario;
    if (usuario is Map) return usuario['_id'] as String?;
    return null;
  }

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      id: (json['_id'] as String?) ?? '',
      nome: (json['nome'] as String?) ?? '',
      apelido: json['apelido'] as String?,
      nivel: (json['nivel'] as num?)?.toInt() ?? 1,
      ehGoleiro: json['ehGoleiro'] as bool? ?? false,
      fotoUrl: _extrairFotoUrl(json['usuario']),
      codigoVincular: json['codigoVincular'] as String?,
      usuarioId: _extrairUsuarioId(json['usuario']),
    );
  }

  factory Jogador.fromPartidaJson(Map<String, dynamic> json) {
    final jogadorData = json['jogador'] as Map<String, dynamic>;
    return Jogador(
      id: jogadorData['_id'] as String,
      nome: jogadorData['nome'] as String,
      apelido: jogadorData['apelido'] as String?,
      nivel: (jogadorData['nivel'] as num?)?.toInt() ?? 1,
      nota: (json['nota'] as num?)?.toInt(),
      mensalista: json['mensalista'] as bool? ?? false,
      pago: json['pago'] as bool? ?? false,
      ehGoleiro: jogadorData['ehGoleiro'] as bool? ?? false,
      fotoUrl: _extrairFotoUrl(jogadorData['usuario']),
      codigoVincular: jogadorData['codigoVincular'] as String?,
      usuarioId: _extrairUsuarioId(jogadorData['usuario']),
    );
  }
}
