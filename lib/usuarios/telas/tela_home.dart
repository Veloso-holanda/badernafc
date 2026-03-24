import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import 'tela_jogadores.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _indiceNavbar = 0;

  Usuario? _usuario;
  Partida? _partida;
  Partida? _proximaPartida;
  CicloMensal? _ciclo;
  ConfiguracoesGerais? _config;
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
      final resultados = await Future.wait([
        ServicoApi.obterMeuPerfil(),
        ServicoApi.obterCicloAtual(),
        ServicoApi.obterConfiguracoesGerais(),
      ]);
      final usuario = resultados[0] as Usuario;
      final ciclo = resultados[1] as CicloMensal?;
      final config = resultados[2] as ConfiguracoesGerais?;
      debugPrint('[Home] ciclo: ${ciclo?.id} | dataInicial: ${ciclo?.dataInicial} | dataFinal: ${ciclo?.dataFinal}');

      Partida? partida;
      Partida? proximaPartida;
      if (ciclo != null) {
        final partidas = await ServicoApi.obterPartidasDoCiclo(ciclo.id);
        debugPrint('[Home] partidas encontradas: ${partidas.length}');
        for (final p in partidas) {
          debugPrint('[Home] partida ${p.id} | status: ${p.status} | data: ${p.data} | abertura: ${p.aberturaLista}');
        }
        if (partidas.isNotEmpty) {
          // Prioridade: aberta > aguardando > próxima por data
          partida = partidas.cast<Partida?>().firstWhere(
            (p) => p!.status == 'aberta',
            orElse: () => null,
          );
          partida ??= partidas.cast<Partida?>().firstWhere(
            (p) => p!.status == 'aguardando' && p.data.isAfter(DateTime.now().subtract(const Duration(days: 1))),
            orElse: () => null,
          );
          partida ??= partidas.last;
        }

        // Próxima partida futura (data >= hoje, status aguardando ou aberta)
        final agora = DateTime.now();
        final futuras = partidas
            .where((p) => p.data.isAfter(agora.subtract(const Duration(days: 1))))
            .toList()
          ..sort((a, b) => a.data.compareTo(b.data));
        proximaPartida = futuras.isNotEmpty ? futuras.first : null;
      }

      if (!mounted) return;
      setState(() {
        _usuario = usuario;
        _ciclo = ciclo;
        _config = config;
        _partida = partida;
        _proximaPartida = proximaPartida;
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

  Future<void> _confirmarPresenca() async {
    final jogadorId = _usuario?.jogadorVinculadoId;
    if (jogadorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa vincular um jogador antes de confirmar presença.')),
      );
      return;
    }

    if (_partida == null) return;

    try {
      await ServicoApi.confirmarPresenca(_partida!.id, jogadorId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Presença confirmada!')),
      );
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar presença: $e')),
      );
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
      case 2:
        return TelaJogadores(
          ehAdmin: _usuario?.ehAdmin ?? false,
          usuarioJaVinculado: _usuario?.temJogadorVinculado ?? false,
        );
      case 3:
        if (_carregando) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (_usuario != null) {
          return TelaConfig(usuario: _usuario!);
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
              const SizedBox(height: AppSizes.md),
              Text('Erro ao carregar perfil', style: AppTypography.titleMedium),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );
      default:
        return Center(
          child: Text(
            'Em breve...',
            style: AppTypography.titleMedium,
          ),
        );
    }
  }

  void _abrirFotoDialog(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(32),
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: ClipRRect(
            borderRadius: AppSizes.borderRadiusCardAdmin,
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
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
                    GestureDetector(
                      onTap: _usuario?.fotoPerfilUrl != null
                          ? () => _abrirFotoDialog(_usuario!.fotoPerfilUrl!)
                          : null,
                      child: CircleAvatar(
                        radius: AppSizes.avatarLg / 2,
                        backgroundColor: AppColors.tableHeaderBg,
                        backgroundImage: _usuario?.fotoPerfilUrl != null
                            ? NetworkImage(_usuario!.fotoPerfilUrl!)
                            : null,
                        child: _usuario?.fotoPerfilUrl == null
                            ? Text(
                                _usuario?.iniciais ?? '?',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.star,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // Card ciclo mensal
                if (_ciclo != null) ...[
                  _buildCardCiclo(),
                  const SizedBox(height: AppSizes.sectionGap),
                ],

                if (_partida != null) ...[
                  // Título
                  Text(
                    _partida!.status == 'aguardando'
                        ? 'Aguardando abertura da lista'
                        : 'Jogadores confirmados',
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
        if (_partida != null && _partida!.listaAberta)
          Positioned(
            bottom: AppSizes.xl,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 270,
                height: AppSizes.fabHeight,
                child: ElevatedButton.icon(
                  style: AppButtons.fab,
                  onPressed: _confirmarPresenca,
                  icon: const Icon(Icons.check_circle_outline, size: AppSizes.iconMd),
                  label: const Text('Confirmar presença'),
                ),
              ),
            ),
          ),

        // FAB Sortear (admin, partida fechada)
        if (_usuario?.ehAdmin == true &&
            _partida != null &&
            _partida!.status == 'fechada')
          Positioned(
            bottom: AppSizes.xl,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 270,
                height: AppSizes.fabHeight,
                child: ElevatedButton.icon(
                  style: AppButtons.fabSortear,
                  onPressed: () {
                    // TODO: navegar para tela de sorteio
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sorteio em breve!')),
                    );
                  },
                  icon: const Icon(Icons.shuffle, size: AppSizes.iconMd),
                  label: const Text('Sortear Times'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static const _diasSemana = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  String _formatarDataCiclo(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Widget _buildCardCiclo() {
    final ciclo = _ciclo!;
    final diaFutebol = _config != null && _config!.diaFutebol < _diasSemana.length
        ? _diasSemana[_config!.diaFutebol]
        : '—';

    return Container(
      width: double.infinity,
      padding: AppSizes.cardAdminPadding,
      decoration: BoxDecoration(
        color: AppColors.cardAdminBg,
        borderRadius: AppSizes.borderRadiusCardAdmin,
        border: Border.all(color: AppColors.cardAdminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ciclo Atual', style: AppTypography.titleMedium),
          const SizedBox(height: AppSizes.lg),
          _buildInfoLinhaCiclo(Icons.calendar_today, '${_formatarDataCiclo(ciclo.dataInicial)} — ${_formatarDataCiclo(ciclo.dataFinal)}'),
          if (_config != null) ...[
            const SizedBox(height: AppSizes.md),
            _buildInfoLinhaCiclo(Icons.event, '$diaFutebol às ${_config!.horaFutebol}'),
          ],
          if (_partida != null) ...[
            const SizedBox(height: AppSizes.lg),
            Divider(color: AppColors.textMuted.withValues(alpha: 0.3), height: 1),
            const SizedBox(height: AppSizes.lg),
            _buildInfoLinhaCiclo(
              Icons.sports_soccer,
              'Partida: ${_partida!.dataFormatada} — ${_partida!.status}',
            ),
          ],
          if (_proximaPartida != null) ...[
            const SizedBox(height: AppSizes.md),
            _buildInfoLinhaCiclo(
              Icons.schedule,
              'Próxima: ${_proximaPartida!.dataFormatada} às ${_proximaPartida!.horario}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoLinhaCiclo(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, color: AppColors.star, size: AppSizes.iconForm),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Text(
            texto,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textWhite),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTabela() {
    return Container(
      height: AppSizes.tableHeaderHeight,
      padding: AppSizes.tableCellPadding,
      color: AppColors.tableHeaderBg,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#', style: AppTypography.tableHeader, textAlign: TextAlign.center),
          ),
          const SizedBox(width: AppSizes.lg),
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

  void _abrirPerfilJogador(Jogador jogador) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalPerfilJogadorHome(
        jogador: jogador,
      ),
    );
  }

  Widget _buildLinhaJogador(int numero, Jogador jogador, {bool alternar = false}) {
    return GestureDetector(
      onTap: () => _abrirPerfilJogador(jogador),
      child: Container(
      height: AppSizes.tableRowHeight,
      padding: AppSizes.tableCellPadding,
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
          const SizedBox(width: AppSizes.lg),
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
                  style: AppTypography.starRating.copyWith(
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

// ─── Modal Perfil Jogador (simplificado, só visualização) ────────────────────

class _ModalPerfilJogadorHome extends StatelessWidget {
  final Jogador jogador;

  const _ModalPerfilJogadorHome({required this.jogador});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.lg, bottom: AppSizes.md),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: AppSizes.borderRadiusPill,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: _buildCarta(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarta() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3D2A0F),
            Color(0xFF2A1A06),
            Color(0xFF1A1208),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.star, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55E8922E),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Padrão decorativo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CustomPaint(painter: _PadraoCartaHomePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Topo: nível e badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.star.withValues(alpha: 0.2),
                        borderRadius: AppSizes.borderRadiusMd,
                        border: Border.all(color: AppColors.star.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${jogador.nivel}',
                        style: AppTypography.headerTitle.copyWith(
                          color: AppColors.star,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: AppSizes.borderRadiusPill,
                        border: Border.all(color: AppColors.star.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'BADERNA FC',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.star,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxl),

                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.star, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44E8922E),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.tableHeaderBg,
                    backgroundImage: jogador.fotoUrl != null
                        ? NetworkImage(jogador.fotoUrl!)
                        : null,
                    child: jogador.fotoUrl == null
                        ? Text(
                            (jogador.apelido ?? jogador.nome)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: AppTypography.headerTitle.copyWith(
                              color: AppColors.star,
                              fontSize: 44,
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),

                // Divisor dourado
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.star.withValues(alpha: 0.6),
                        AppColors.star,
                        AppColors.star.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // Nome
                Text(
                  jogador.nome.toUpperCase(),
                  style: AppTypography.headerTitle.copyWith(
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (jogador.apelido != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '"${jogador.apelido!}"',
                    style: AppTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: AppSizes.xl),

                // Estrelas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        Icons.star_rounded,
                        size: AppSizes.starPerfil,
                        color: i < jogador.nivel
                            ? AppColors.star
                            : AppColors.starInactive,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PadraoCartaHomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.star.withValues(alpha: 0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
