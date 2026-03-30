class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? fotoUrl;
  final String perfil;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.fotoUrl,
    required this.perfil,
  });

  String get nomeExibicao => nome;

  String? get fotoPerfilUrl => fotoUrl;

  String get iniciais {
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }

  static String? _stringOuNull(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    return valor;
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String?,
      fotoUrl: _stringOuNull(json['fotoUrl'] as String?),
      perfil: json['perfil'] as String? ?? 'usuario',
    );
  }
}
