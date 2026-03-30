import 'package:flutter/material.dart';
import '../../shared/shared.dart';

class TelaPartidas extends StatefulWidget {
  const TelaPartidas({super.key});

  @override
  State<TelaPartidas> createState() => _TelaPartidasState();
}

class _TelaPartidasState extends State<TelaPartidas> {
  CicloMensal? _ciclo;
  List<Partida> _partidas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final timeId = ContextoTime.timeIdAtivo!;
      final ciclo = await ServicoApi.obterCicloAtual(timeId);

      List<Partida> partidas = [];
      if (ciclo != null) {
        partidas = await ServicoApi.obterPartidasDoCiclo(timeId, ciclo.id);
        partidas.sort((a, b) => a.data.compareTo(b.data));
      }

      if (!mounted) return;
      setState(() {
        _ciclo = ciclo;
        _partidas = partidas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  static const _diasSemana = [
    'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab',
  ];

  String _statusLabel(String status) {
    switch (status) {
      case 'aguardando':
        return 'Aguardando';
      case 'aberta':
        return 'Lista Aberta';
      case 'fechada':
        return 'Lista Fechada';
      case 'sorteada':
        return 'Sorteada';
      case 'finalizada':
        return 'Finalizada';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'aberta':
        return AppColors.primary;
      case 'fechada':
        return AppColors.star;
      case 'sorteada':
        return AppColors.adminBadge;
      case 'finalizada':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: AppSizes.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
              const SizedBox(height: AppSizes.md),
              Text('Erro ao carregar partidas', style: AppTypography.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Text(_erro!, style: AppTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ciclo == null) {
      return Center(
        child: Padding(
          padding: AppSizes.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, color: AppColors.textMuted, size: 64),
              const SizedBox(height: AppSizes.md),
              Text('Nenhum ciclo ativo', style: AppTypography.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Aguarde o admin criar um ciclo mensal.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partidas', style: AppTypography.headerTitle),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Ciclo: ${_ciclo!.dataInicial.day.toString().padLeft(2, '0')}/${_ciclo!.dataInicial.month.toString().padLeft(2, '0')} — ${_ciclo!.dataFinal.day.toString().padLeft(2, '0')}/${_ciclo!.dataFinal.month.toString().padLeft(2, '0')}  •  ${_partidas.length} partida${_partidas.length != 1 ? 's' : ''}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSizes.sectionGap),

            ...List.generate(_partidas.length, (i) {
              return Padding(
                padding: EdgeInsets.only(top: i > 0 ? AppSizes.lg : 0),
                child: _buildCardPartida(_partidas[i]),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPartida(Partida partida) {
    final diaSemana = _diasSemana[partida.data.weekday % 7];
    final dataStr = '${partida.data.day.toString().padLeft(2, '0')}/${partida.data.month.toString().padLeft(2, '0')}';
    final statusCor = _statusColor(partida.status);
    final ehPassada = partida.data.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return GestureDetector(
      onTap: () => _abrirDetalhePartida(partida),
      child: Container(
        width: double.infinity,
        padding: AppSizes.cardAdminPadding,
        decoration: BoxDecoration(
          color: ehPassada
              ? AppColors.cardAdminBg.withValues(alpha: 0.5)
              : AppColors.cardAdminBg,
          borderRadius: AppSizes.borderRadiusCardAdmin,
          border: Border.all(
            color: partida.status == 'aberta'
                ? AppColors.primary
                : AppColors.cardAdminBorder,
            width: partida.status == 'aberta' ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Data
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusCor.withValues(alpha: 0.2),
                borderRadius: AppSizes.borderRadiusMd,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dataStr,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    diaSemana,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.xl),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${partida.horario}h',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      Icon(Icons.people, color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${partida.jogadores.length} confirmados',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                      ),
                      if (partida.listaEspera.isNotEmpty) ...[
                        const SizedBox(width: AppSizes.md),
                        Text(
                          '${partida.listaEspera.length} espera',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.star),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusCor.withValues(alpha: 0.2),
                borderRadius: AppSizes.borderRadiusSm,
              ),
              child: Text(
                _statusLabel(partida.status),
                style: AppTypography.labelSmall.copyWith(
                  color: statusCor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDetalhePartida(Partida partida) {
    // TODO: navegar para detalhe da partida (lista de presenca, sorteio)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Partida ${partida.dataFormatada} — ${_statusLabel(partida.status)}')),
    );
  }
}
