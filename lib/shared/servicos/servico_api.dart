import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api.dart';
import '../modelos/usuario.dart';
import '../modelos/jogador.dart';
import '../modelos/partida.dart';
import '../modelos/ciclo_mensal.dart';
import '../modelos/configuracoes_gerais.dart';
import '../modelos/despesa.dart';
import '../modelos/resumo_financeiro.dart';
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

  // Jogadores
  static Future<List<Jogador>> obterTodosJogadores() async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/jogadores'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar jogadores: ${resposta.statusCode}');
    }
    final lista = jsonDecode(resposta.body) as List;
    return lista
        .map((j) => Jogador.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  static Future<Jogador> criarJogador({
    required String nome,
    String? apelido,
    required int nivel,
  }) async {
    final resposta = await http.post(
      Uri.parse('${Api.baseUrl}/jogadores'),
      headers: await _headers(),
      body: jsonEncode({
        'nome': nome,
        if (apelido != null && apelido.isNotEmpty) 'apelido': apelido,
        'nivel': nivel,
      }),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception('Erro ao criar jogador: ${resposta.body}');
    }
    return Jogador.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  // Ciclos Mensais
  static Future<CicloMensal> criarCicloMensal({
    required DateTime dataInicial,
    List<String>? mensalistas,
  }) async {
    final resposta = await http.post(
      Uri.parse('${Api.baseUrl}/ciclos-mensais'),
      headers: await _headers(),
      body: jsonEncode({
        'dataInicial': dataInicial.toIso8601String().split('T').first,
        if (mensalistas != null) 'mensalistas': mensalistas,
      }),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception('Erro ao criar ciclo mensal: ${resposta.body}');
    }
    return CicloMensal.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

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

  static Future<CicloMensal> atualizarCicloMensal(String cicloId, {
    List<String>? mensalistas,
  }) async {
    final resposta = await http.put(
      Uri.parse('${Api.baseUrl}/ciclos-mensais/$cicloId'),
      headers: await _headers(),
      body: jsonEncode({
        if (mensalistas != null) 'mensalistas': mensalistas,
      }),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao atualizar ciclo: ${resposta.body}');
    }
    return CicloMensal.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  // Partidas
  static Future<List<Partida>> obterPartidasDoCiclo(String cicloId) async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/partidas/ciclo/$cicloId'),
      headers: await _headers(),
    );
    debugPrint('[API] GET /partidas/ciclo/$cicloId → ${resposta.statusCode}');
    debugPrint('[API] body: ${resposta.body.substring(0, resposta.body.length.clamp(0, 500))}');
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

  static Future<void> marcarPagamentoDiarista(String partidaId, String jogadorId, bool pago) async {
    final resposta = await http.put(
      Uri.parse('${Api.baseUrl}/partidas/$partidaId/pagamento-diarista'),
      headers: await _headers(),
      body: jsonEncode({'jogadorId': jogadorId, 'pago': pago}),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao marcar pagamento: ${resposta.body}');
    }
  }

  // Configurações Gerais
  static Future<ConfiguracoesGerais> criarConfiguracoesGerais({
    required double valorCicloMensal,
    required double diaria,
    required double valorMensalista,
    required int diaFutebol,
    required String horaFutebol,
  }) async {
    final resposta = await http.post(
      Uri.parse('${Api.baseUrl}/configuracoes-gerais'),
      headers: await _headers(),
      body: jsonEncode({
        'valorCicloMensal': valorCicloMensal,
        'diaria': diaria,
        'valorMensalista': valorMensalista,
        'diaFutebol': diaFutebol,
        'horaFutebol': horaFutebol,
      }),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception('Erro ao criar configurações: ${resposta.body}');
    }
    return ConfiguracoesGerais.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  static Future<ConfiguracoesGerais?> obterConfiguracoesGerais() async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/configuracoes-gerais'),
      headers: await _headers(),
    );
    if (resposta.statusCode == 404) return null;
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar configurações: ${resposta.statusCode}');
    }
    return ConfiguracoesGerais.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  static Future<ConfiguracoesGerais> atualizarConfiguracoesGerais({
    double? valorCicloMensal,
    double? diaria,
    double? valorMensalista,
    int? diaFutebol,
    String? horaFutebol,
  }) async {
    final resposta = await http.put(
      Uri.parse('${Api.baseUrl}/configuracoes-gerais'),
      headers: await _headers(),
      body: jsonEncode({
        if (valorCicloMensal != null) 'valorCicloMensal': valorCicloMensal,
        if (diaria != null) 'diaria': diaria,
        if (valorMensalista != null) 'valorMensalista': valorMensalista,
        if (diaFutebol != null) 'diaFutebol': diaFutebol,
        if (horaFutebol != null) 'horaFutebol': horaFutebol,
      }),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao atualizar configurações: ${resposta.body}');
    }
    return ConfiguracoesGerais.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  // Financeiro
  static Future<Despesa> criarDespesa({
    required String cicloMensalId,
    required String descricao,
    required double valor,
    DateTime? data,
  }) async {
    final resposta = await http.post(
      Uri.parse('${Api.baseUrl}/financeiro/despesas'),
      headers: await _headers(),
      body: jsonEncode({
        'cicloMensalId': cicloMensalId,
        'descricao': descricao,
        'valor': valor,
        if (data != null) 'data': data.toIso8601String().split('T').first,
      }),
    );
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      throw Exception('Erro ao criar despesa: ${resposta.body}');
    }
    return Despesa.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  static Future<List<Despesa>> obterDespesasDoCiclo(String cicloMensalId) async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/financeiro/despesas/ciclo/$cicloMensalId'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar despesas: ${resposta.statusCode}');
    }
    final lista = jsonDecode(resposta.body) as List;
    return lista
        .map((d) => Despesa.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  static Future<Despesa> atualizarDespesa(String despesaId, {
    String? descricao,
    double? valor,
    DateTime? data,
  }) async {
    final resposta = await http.put(
      Uri.parse('${Api.baseUrl}/financeiro/despesas/$despesaId'),
      headers: await _headers(),
      body: jsonEncode({
        if (descricao != null) 'descricao': descricao,
        if (valor != null) 'valor': valor,
        if (data != null) 'data': data.toIso8601String().split('T').first,
      }),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao atualizar despesa: ${resposta.body}');
    }
    return Despesa.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  static Future<void> removerDespesa(String despesaId) async {
    final resposta = await http.delete(
      Uri.parse('${Api.baseUrl}/financeiro/despesas/$despesaId'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao remover despesa: ${resposta.statusCode}');
    }
  }

  static Future<ResumoFinanceiro> obterResumoFinanceiro(String cicloMensalId) async {
    final resposta = await http.get(
      Uri.parse('${Api.baseUrl}/financeiro/resumo/$cicloMensalId'),
      headers: await _headers(),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar resumo financeiro: ${resposta.statusCode}');
    }
    return ResumoFinanceiro.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }
}
