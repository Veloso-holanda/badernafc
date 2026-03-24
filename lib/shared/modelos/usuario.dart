import 'jogador.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? fotoUrl;
  final String perfil;
  final Jogador? jogador;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.fotoUrl,
    required this.perfil,
    this.jogador,
  });

  String get nomeExibicao => jogador?.apelido ?? nome;

  bool get ehAdmin => perfil == 'admin';

  bool get temJogadorVinculado => jogador != null;

  String? get jogadorVinculadoId => jogador?.id;

  String? get fotoPerfilUrl => fotoUrl ?? jogador?.fotoUrl;

  String get iniciais {
    final fonte = jogador?.apelido ?? nome;
    return fonte.isNotEmpty ? fonte[0].toUpperCase() : '?';
  }

  static String? _stringOuNull(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    return valor;
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final jogadorData = json['jogador'];
    return Usuario(
      id: json['_id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String?,
      fotoUrl: _stringOuNull(json['fotoUrl'] as String?),
      perfil: json['perfil'] as String? ?? 'usuario',
      jogador: jogadorData is Map<String, dynamic>
          ? Jogador.fromJson(jogadorData)
          : null,
    );
  }
}
