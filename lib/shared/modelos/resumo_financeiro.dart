class ResumoFinanceiro {
  final String cicloMensalId;
  final double receitaMensalistas;
  final int quantidadeMensalistas;
  final double valorMensalista;
  final double receitaDiaristas;
  final int quantidadeDiaristasPagos;
  final double diaria;
  final double receitaTotal;
  final double despesasManuais;
  final double valorCicloMensal;
  final double despesasTotal;
  final double saldo;

  const ResumoFinanceiro({
    required this.cicloMensalId,
    required this.receitaMensalistas,
    required this.quantidadeMensalistas,
    required this.valorMensalista,
    required this.receitaDiaristas,
    required this.quantidadeDiaristasPagos,
    required this.diaria,
    required this.receitaTotal,
    required this.despesasManuais,
    required this.valorCicloMensal,
    required this.despesasTotal,
    required this.saldo,
  });

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiro(
      cicloMensalId: json['cicloMensalId'] as String,
      receitaMensalistas: (json['receitaMensalistas'] as num?)?.toDouble() ?? 0,
      quantidadeMensalistas: (json['quantidadeMensalistas'] as num?)?.toInt() ?? 0,
      valorMensalista: (json['valorMensalista'] as num?)?.toDouble() ?? 0,
      receitaDiaristas: (json['receitaDiaristas'] as num?)?.toDouble() ?? 0,
      quantidadeDiaristasPagos: (json['quantidadeDiaristasPagos'] as num?)?.toInt() ?? 0,
      diaria: (json['diaria'] as num?)?.toDouble() ?? 0,
      receitaTotal: (json['receitaTotal'] as num?)?.toDouble() ?? 0,
      despesasManuais: (json['despesasManuais'] as num?)?.toDouble() ?? 0,
      valorCicloMensal: (json['valorCicloMensal'] as num?)?.toDouble() ?? 0,
      despesasTotal: (json['despesasTotal'] as num?)?.toDouble() ?? 0,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0,
    );
  }
}
