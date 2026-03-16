import 'package:flutter/material.dart';
import '../../shared/shared.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _indiceNavbar = 0;

  Usuario? _usuario;
  Partida? _partida;
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
      final usuario = await ServicoApi.obterMeuPerfil();
      final ciclo = await ServicoApi.obterCicloAtual();

      Partida? partida;
      if (ciclo != null) {
        final partidas = await ServicoApi.obterPartidasDoCiclo(ciclo.id);
        if (partidas.isNotEmpty) {
          partida = partidas.lastWhere(
            (p) => p.status == 'aberta',
            orElse: () => partidas.last,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _usuario = usuario;
        _partida = partida;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(child: _buildConteudo()),
          Navbar(
            indiceAtual: _indiceNavbar,
            aoTrocar: (indice) => setState(() => _indiceNavbar = indice),
            itens: const [
              ItemNavbar(icone: Icons.home, label: 'Home'),
              ItemNavbar(icone: Icons.shield_outlined, label: 'Times'),
              ItemNavbar(icone: Icons.people_outline, label: 'Jogadores'),
              ItemNavbar(icone: Icons.settings_outlined, label: 'Config'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    switch (_indiceNavbar) {
      case 0:
        return _buildHome();
      default:
        return Center(
          child: Text(
            'Em breve...',
            style: AppTypography.titleMedium,
          ),
        );
    }
  }

  Widget _buildHome() {
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
              Text('Erro ao carregar dados', style: AppTypography.titleMedium),
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

    final nomeUsuario = _usuario?.nomeExibicao ?? 'Jogador';
    final jogadores = _partida?.jogadores ?? [];
    final listaEspera = _partida?.listaEspera ?? [];

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _carregarDados,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSizes.contentPadding,
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bem vindo, $nomeUsuario!',
                        style: AppTypography.titleMedium,
                      ),
                    ),
                    CircleAvatar(
                      radius: AppSizes.avatarLg / 2,
                      backgroundColor: AppColors.tableHeaderBg,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textWhite,
                        size: AppSizes.iconMd,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                if (_partida != null) ...[
                  // Info partida
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partida',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Data: ${_partida!.dataFormatada}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Título
                  Text(
                    'Jogadores confirmados',
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Info linha/espera
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirmados: ${jogadores.length}/20',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(width: AppSizes.xl),
                      Text(
                        'Espera: ${listaEspera.length}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Lista de jogadores
                  ClipRRect(
                    borderRadius: AppSizes.borderRadiusMd,
                    child: Column(
                      children: [
                        _buildHeaderTabela(),
                        const SizedBox(height: AppSizes.tableGap),

                        // Jogadores confirmados
                        ...List.generate(jogadores.length, (i) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: i > 0 ? AppSizes.tableGap : 0,
                            ),
                            child: _buildLinhaJogador(
                              i + 1,
                              jogadores[i],
                              alternar: i.isOdd,
                            ),
                          );
                        }),

                        // Lista de espera
                        if (listaEspera.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.tableGap),
                          _buildSeparador('Lista de Espera', AppColors.fabSortear.withValues(alpha: 0.27)),
                          const SizedBox(height: AppSizes.tableGap),
                          ...List.generate(listaEspera.length, (i) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: i > 0 ? AppSizes.tableGap : 0,
                              ),
                              child: _buildLinhaJogador(
                                i + 1,
                                listaEspera[i],
                                alternar: i.isOdd,
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 80),
                  const Icon(Icons.sports_soccer, color: AppColors.textMuted, size: 64),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Nenhuma partida disponível',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Aguarde o admin criar um ciclo e partidas.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // FAB Confirmar presença
        if (_partida != null && _partida!.status == 'aberta')
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 270,
                height: AppSizes.fabHeight,
                child: ElevatedButton.icon(
                  style: AppButtons.fab,
                  onPressed: () {
                    // TODO: confirmar presença com jogadorId do usuário vinculado
                  },
                  icon: const Icon(Icons.check_circle_outline, size: AppSizes.iconMd),
                  label: const Text('Confirmar presença'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderTabela() {
    return Container(
      height: AppSizes.tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.tableHeaderBg,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#', style: AppTypography.tableHeader, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Nome', style: AppTypography.tableHeader),
          ),
          SizedBox(
            width: 80,
            child: Text('Nível', style: AppTypography.tableHeader, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaJogador(int numero, Jogador jogador, {bool alternar = false}) {
    return Container(
      height: AppSizes.tableRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: alternar ? AppColors.tableRowAltBg : AppColors.tableRowBg,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$numero',
              style: AppTypography.tableRow,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(jogador.nomeExibicao, style: AppTypography.tableRow),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Text(
                  '★',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11,
                    color: i < jogador.nivel
                        ? AppColors.star
                        : AppColors.starInactive,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparador(String texto, Color cor) {
    return Container(
      height: AppSizes.separatorHeight,
      color: cor,
      alignment: Alignment.center,
      child: Text(
        texto,
        style: AppTypography.tableRow.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
