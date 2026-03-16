import 'jogador.dart';

class Partida {
  final String id;
  final String status;
  final DateTime data;
  final String horario;
  final List<Jogador> jogadores;
  final List<Jogador> listaEspera;

  const Partida({
    required this.id,
    required this.status,
    required this.data,
    required this.horario,
    required this.jogadores,
    required this.listaEspera,
  });

  String get dataFormatada {
    final d = data;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';
  }

  factory Partida.fromJson(Map<String, dynamic> json) {
    final jogadoresList = (json['jogadores'] as List? ?? [])
        .map((j) => Jogador.fromPartidaJson(j as Map<String, dynamic>))
        .toList();

    final esperaList = (json['listaEspera'] as List? ?? [])
        .map((j) => Jogador.fromJson(j as Map<String, dynamic>))
        .toList();

    return Partida(
      id: json['_id'] as String,
      status: json['status'] as String? ?? 'aberta',
      data: DateTime.parse(json['data'] as String),
      horario: json['horario'] as String? ?? '',
      jogadores: jogadoresList,
      listaEspera: esperaList,
    );
  }
}
