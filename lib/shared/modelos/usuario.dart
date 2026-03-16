class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? apelido;
  final String? telefone;
  final String perfil;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.apelido,
    this.telefone,
    required this.perfil,
  });

  String get nomeExibicao => apelido ?? nome;

  bool get ehAdmin => perfil == 'admin';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      apelido: json['apelido'] as String?,
      telefone: json['telefone'] as String?,
      perfil: json['perfil'] as String? ?? 'usuario',
    );
  }
}
