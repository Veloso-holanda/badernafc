class Membro {
  final String id;
  final String timeId;
  final String usuarioId;
  final String? jogadorId;
  final String papel; // 'admin' | 'membro'
  final bool ativo;

  const Membro({
    required this.id,
    required this.timeId,
    required this.usuarioId,
    this.jogadorId,
    required this.papel,
    this.ativo = true,
  });

  bool get ehAdmin => papel == 'admin';

  /// Extrai o ID de um campo que pode ser String ou Map populado
  static String _extrairId(dynamic valor, [String fallback = '']) {
    if (valor is String) return valor;
    if (valor is Map<String, dynamic>) return valor['_id'] as String? ?? fallback;
    return fallback;
  }

  static String? _extrairIdOuNull(dynamic valor) {
    if (valor is String) return valor;
    if (valor is Map<String, dynamic>) return valor['_id'] as String?;
    return null;
  }

  factory Membro.fromJson(Map<String, dynamic> json) {
    return Membro(
      id: json['_id'] as String,
      timeId: _extrairId(json['timeId'] ?? json['time']),
      usuarioId: _extrairId(json['usuarioId'] ?? json['usuario']),
      jogadorId: _extrairIdOuNull(json['jogadorId'] ?? json['jogador']),
      papel: json['papel'] as String? ?? 'membro',
      ativo: json['ativo'] as bool? ?? true,
    );
  }
}
