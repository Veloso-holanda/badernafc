import 'jogador.dart';

class Partida {
  final String id;
  final String status;
  final DateTime data;
  final String horario;
  final DateTime? aberturaLista;
  final DateTime? fechamentoLista;
  final List<Jogador> jogadores;
  final List<Jogador> listaEspera;

  const Partida({
    required this.id,
    required this.status,
    required this.data,
    required this.horario,
    this.aberturaLista,
    this.fechamentoLista,
    required this.jogadores,
    required this.listaEspera,
  });

  bool get listaAberta {
    final agora = DateTime.now();
    if (aberturaLista != null && agora.isBefore(aberturaLista!)) return false;
    if (fechamentoLista != null && agora.isAfter(fechamentoLista!)) return false;
    return status == 'aberta' || status == 'aguardando';
  }

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
      status: json['status'] as String? ?? 'aguardando',
      data: DateTime.parse(json['data'] as String),
      horario: json['horario'] as String? ?? '',
      aberturaLista: json['aberturaLista'] != null
          ? DateTime.parse(json['aberturaLista'] as String)
          : null,
      fechamentoLista: json['fechamentoLista'] != null
          ? DateTime.parse(json['fechamentoLista'] as String)
          : null,
      jogadores: jogadoresList,
      listaEspera: esperaList,
    );
  }
}
