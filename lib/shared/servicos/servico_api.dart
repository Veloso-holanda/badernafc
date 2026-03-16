import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api.dart';
import '../modelos/usuario.dart';
import '../modelos/partida.dart';
import '../modelos/ciclo_mensal.dart';
import 'servico_auth.dart';

class ServicoApi {
  static Future<Map<String, String>> _headers() async {
    final token = await ServicoAuth.obterToken();
    if (token == null) throw Exception('Usuário não autenticado');
    return Api.authHeaders(token);
  }

  // Usuarios
  static Future<Usuario> criarUsuario({
    required String nome,
    required String email,
    String? apelido,
    String? telefone,
  }) async {
    final resposta = await http.post(
      Uri.parse('${Api.baseUrl}/usuarios'),
      headers: await _headers(),
      body: jsonEncode({
        'nome': nome,
        'email': email,
        if (apelido != null && apelido.isNotEmpty) 'apelido': apelido,
        if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
      }),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception('Erro ao criar usuário: ${resposta.body}');
    }
    return Usuario.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  static Future<Usuario> obterMeuPerfil() async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/usuarios/eu'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar perfil: ${resposta.statusCode}');
    }
    return Usuario.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  // Ciclos Mensais
  static Future<CicloMensal?> obterCicloAtual() async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/ciclos-mensais/atual'),
      headers: await _headers(),
    );
    if (resposta.statusCode == 404) return null;
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar ciclo: ${resposta.statusCode}');
    }
    return CicloMensal.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  // Partidas
  static Future<List<Partida>> obterPartidasDoCiclo(String cicloId) async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/partidas/ciclo/$cicloId'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar partidas: ${resposta.statusCode}');
    }
    final lista = jsonDecode(resposta.body) as List;
    return lista
        .map((j) => Partida.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  static Future<Partida> obterPartida(String partidaId) async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/partidas/$partidaId'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar partida: ${resposta.statusCode}');
    }
    return Partida.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  static Future<void> confirmarPresenca(String partidaId, String jogadorId) async {
    final resposta = await http.post(
      Uri.parse('${Api.baseUrl}/partidas/$partidaId/confirmar'),
      headers: await _headers(),
      body: jsonEncode({'jogadorId': jogadorId}),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception('Erro ao confirmar presença: ${resposta.body}');
    }
  }
}
