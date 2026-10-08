import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/shared.dart';
import '../../admin/telas/tela_cadastro_jogador.dart';

class TelaJogadores extends StatefulWidget {
  final bool ehAdmin;
  final bool usuarioJaVinculado;

  const TelaJogadores({super.key, this.ehAdmin = false, this.usuarioJaVinculado = false});

  @override
  State<TelaJogadores> createState() => _TelaJogadoresState();
}

class _TelaJogadoresState extends State<TelaJogadores> {
  List<Jogador> _jogadores = [];
  List<Jogador> _mensalistas = [];
  CicloMensal? _ciclo;
  ConfiguracoesGerais? _config;
  bool _carregando = true;
  String? _erro;
  bool _mostrandoMensalistas = false;
  final _pesquisaController = TextEditingController();
  String _termoPesquisa = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  List<Jogador> _filtrarJogadores(List<Jogador> jogadores) {
    if (_termoPesquisa.isEmpty) return jogadores;
    final termo = _termoPesquisa.toLowerCase();
    return jogadores.where((j) {
      return j.nome.toLowerCase().contains(termo) ||
          (j.apelido?.toLowerCase().contains(termo) ?? false);
    }).toList();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final timeId = ContextoTime.timeIdAtivo!;
      final resultados = await Future.wait([
        ServicoApi.obterTodosJogadores(timeId),
        ServicoApi.obterCicloAtual(timeId),
        ServicoApi.obterConfiguracoesGerais(timeId),
      ]);

      final jogadores = resultados[0] as List<Jogador>;
      final ciclo = resultados[1] as CicloMensal?;
      final config = resultados[2] as ConfiguracoesGerais?;
      final mensalistas = ciclo?.mensalistas ?? [];

      if (!mounted) return;
      setState(() {
        _jogadores = jogadores;
        _ciclo = ciclo;
        _config = config;
        _mensalistas = mensalistas;
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
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _abrirPerfilJogador(Jogador jogador) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalPerfilJogador(
        jogador: jogador,
        ehAdmin: widget.ehAdmin,
        ciclo: _ciclo,
        mensalistas: _mensalistas,
        usuarioJaVinculado: widget.usuarioJaVinculado,
      ),
    ).then((resultado) {
      if (resultado == true) _carregarDados();
    });
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
              Text('Erro ao carregar jogadores', style: AppTypography.titleMedium),
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

    final listaBase = _mostrandoMensalistas ? _mensalistas : _jogadores;
    final listaAtual = _filtrarJogadores(listaBase);

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _carregarDados,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSizes.contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Jogadores', style: AppTypography.headerTitle),

                const SizedBox(height: AppSizes.sectionGap),

                // Toggler
                _buildToggler(),

                const SizedBox(height: AppSizes.sectionGap),

                // Pesquisa
                AppTextField(
                  hint: 'Buscar jogador...',
                  prefixIcon: Icons.search,
                  controller: _pesquisaController,
                  onChanged: (valor) => setState(() => _termoPesquisa = valor),
                ),

                const SizedBox(height: AppSizes.sectionGap),

                // Info ciclo (só no toggle mensalistas)
                if (_mostrandoMensalistas && _ciclo != null) ...[
                  _buildInfoCiclo(),
                  const SizedBox(height: AppSizes.sectionGap),
                ],

                // Subtítulo
                _buildTituloSecao(
                  _mostrandoMensalistas ? 'Mensalistas do ciclo' : 'Jogadores do Baderna',
                  '${listaAtual.length} jogadores',
                ),
                const SizedBox(height: AppSizes.md),

                if (listaAtual.isEmpty)
                  _buildVazio()
                else
                  _buildTabela(listaAtual),
              ],
            ),
          ),
        ),

        // FAB cadastrar jogador (admin only)
        if (widget.ehAdmin)
          Positioned(
            bottom: AppSizes.xl,
            right: AppSizes.xxl,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _abrirCadastroJogador,
              child: const Icon(Icons.person_add, color: AppColors.textWhite),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCiclo() {
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
          _buildInfoLinha(Icons.calendar_today, '${_formatarData(ciclo.dataInicial)} — ${_formatarData(ciclo.dataFinal)}'),
          const SizedBox(height: AppSizes.md),
          if (_config != null) ...[
            _buildInfoLinha(Icons.event, '$diaFutebol às ${_config!.horaFutebol}'),
            const SizedBox(height: AppSizes.md),
          ],
          _buildInfoLinha(Icons.sports_soccer, '${ciclo.qtdPartidas} partidas'),
          const SizedBox(height: AppSizes.md),
          if (_config != null) ...[
            _buildInfoLinha(Icons.attach_money, 'Mensal: ${_formatarValor(_config!.valorMensalista)}  •  Diária: ${_formatarValor(_config!.diaria)}'),
            const SizedBox(height: AppSizes.md),
          ],
          _buildInfoLinha(Icons.people, '${_mensalistas.length} mensalistas'),
        ],
      ),
    );
  }

  Widget _buildInfoLinha(IconData icone, String texto) {
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

  Future<void> _abrirCadastroJogador() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TelaCadastroJogador()),
    );
    if (resultado == true) {
      _carregarDados();
    }
  }

  Widget _buildToggler() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: AppSizes.borderRadiusPill,
      ),
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Row(
        children: [
          _buildToggleOption('Jogadores Baderna', !_mostrandoMensalistas, () {
            setState(() => _mostrandoMensalistas = false);
          }),
          _buildToggleOption('Mensalistas', _mostrandoMensalistas, () {
            setState(() => _mostrandoMensalistas = true);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool ativo, VoidCallback aoTocar) {
    return Expanded(
      child: GestureDetector(
        onTap: aoTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          decoration: BoxDecoration(
            color: ativo ? AppColors.primary : Colors.transparent,
            borderRadius: AppSizes.borderRadiusPill,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
              color: ativo ? AppColors.textWhite : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTituloSecao(String titulo, String subtitulo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: AppTypography.titleMedium),
        Text(subtitulo, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTabela(List<Jogador> jogadores) {
    return ClipRRect(
      borderRadius: AppSizes.borderRadiusMd,
      child: Column(
        children: [
          _buildHeaderTabela(),
          const SizedBox(height: AppSizes.tableGap),
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
        ],
      ),
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
            child: Text('Apelido', style: AppTypography.tableHeader),
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
    final ehMensalista = _mensalistas.any((m) => m.id == jogador.id);

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
              child: Row(
                children: [
                  Flexible(
                    child: Text(jogador.nomeExibicao, style: AppTypography.tableRow),
                  ),
                  if (ehMensalista) ...[
                    const SizedBox(width: AppSizes.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: AppSizes.borderRadiusSm,
                      ),
                      child: Text(
                        'M',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.star,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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

  Widget _buildVazio() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSizes.xxxl),
          const Icon(Icons.people_outline, color: AppColors.textMuted, size: 64),
          const SizedBox(height: AppSizes.md),
          Text(
            _mostrandoMensalistas
                ? 'Nenhum mensalista no ciclo'
                : _termoPesquisa.isNotEmpty
                    ? 'Nenhum jogador encontrado'
                    : 'Nenhum jogador cadastrado',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _mostrandoMensalistas
                ? 'Não há ciclo mensal ativo ou nenhum mensalista foi adicionado.'
                : _termoPesquisa.isNotEmpty
                    ? 'Tente buscar por outro nome ou apelido.'
                    : 'O admin precisa cadastrar jogadores.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Modal Perfil Jogador (Carta estilo álbum da Copa) ───────────────────────

class _ModalPerfilJogador extends StatefulWidget {
  final Jogador jogador;
  final bool ehAdmin;
  final CicloMensal? ciclo;
  final List<Jogador> mensalistas;
  final bool usuarioJaVinculado;

  const _ModalPerfilJogador({
    required this.jogador,
    this.ehAdmin = false,
    this.ciclo,
    this.mensalistas = const [],
    this.usuarioJaVinculado = false,
  });

  @override
  State<_ModalPerfilJogador> createState() => _ModalPerfilJogadorState();
}

class _ModalPerfilJogadorState extends State<_ModalPerfilJogador> {
  bool _carregando = false;
  late bool _ehMensalista;
  bool _dadosAlterados = false;

  @override
  void initState() {
    super.initState();
    _ehMensalista = widget.mensalistas.any((m) => m.id == widget.jogador.id);
  }

  Future<void> _toggleMensalista() async {
    if (widget.ciclo == null) return;

    setState(() => _carregando = true);

    try {
      final idsAtuais = widget.mensalistas.map((m) => m.id).toList();
      if (_ehMensalista) {
        idsAtuais.remove(widget.jogador.id);
      } else {
        idsAtuais.add(widget.jogador.id);
      }

      await ServicoApi.atualizarCicloMensal(ContextoTime.timeIdAtivo!, widget.ciclo!.id, mensalistas: idsAtuais);

      if (!mounted) return;
      setState(() {
        _ehMensalista = !_ehMensalista;
        _dadosAlterados = true;
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ehMensalista
                ? '${widget.jogador.nomeExibicao} adicionado como mensalista'
                : '${widget.jogador.nomeExibicao} removido dos mensalistas',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar mensalistas: $e')),
      );
    }
  }

  Future<void> _vincularAMim() async {
    final codigo = widget.jogador.codigoVincular;
    if (codigo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de vinculação não disponível')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await ServicoApi.vincularJogador(ContextoTime.timeIdAtivo!, codigoVincular: codigo);

      if (!mounted) return;
      setState(() {
        _dadosAlterados = true;
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.jogador.nomeExibicao} vinculado a você!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao vincular: $e')),
      );
    }
  }

  void _mostrarCodigoVincular() {
    final codigo = widget.jogador.codigoVincular;
    if (codigo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de vinculação não disponível')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
        title: Text('Código de Vinculação', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartilhe este código com o jogador para que ele vincule sua conta:',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSizes.xl),
            Container(
              width: double.infinity,
              padding: AppSizes.fieldContentPadding,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: AppSizes.borderRadiusCard,
                border: Border.all(color: AppColors.star),
              ),
              child: Text(
                codigo,
                style: AppTypography.titleLarge.copyWith(letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: AppButtons.text,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            style: AppButtons.primaryForm,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: codigo));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado!')),
              );
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _dadosAlterados) {
          Navigator.of(context).maybePop(true);
        }
      },
      child: DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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

            // Conteúdo scrollável
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: AppSizes.cartaScrollPadding,
                child: Column(
                  children: [
                    _buildCartaCopa(),
                    if (widget.ehAdmin) ...[
                      const SizedBox(height: AppSizes.sectionGap),
                      _buildBotoesAdmin(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCartaCopa() {
    final jogador = widget.jogador;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartaGradientClaro,
            AppColors.cartaGradientMedio,
            AppColors.cartaGradientEscuro,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.star, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cartaSombra,
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Padrão decorativo (linhas diagonais sutis)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CustomPaint(painter: _PadraoCartaPainter()),
            ),
          ),

          // Conteúdo da carta
          Padding(
            padding: AppSizes.cartaContentPadding,
            child: Column(
              children: [
                // Topo: nível e badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nível grande estilo FIFA
                    Container(
                      padding: AppSizes.cartaNivelPadding,
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
                    // Badge BADERNA
                    Container(
                      padding: AppSizes.cartaBadgePadding,
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

                // Foto / Avatar
                GestureDetector(
                  onTap: jogador.fotoUrl != null
                      ? () => _abrirFotoDialog(jogador.fotoUrl!)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.star, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cartaSombraLeve,
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

                // Apelido
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
                      padding: AppSizes.cartaEstrelaPadding,
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

                const SizedBox(height: AppSizes.xxl),

                // Badges
                Wrap(
                  spacing: AppSizes.md,
                  runSpacing: AppSizes.md,
                  alignment: WrapAlignment.center,
                  children: [
                    if (_ehMensalista)
                      _buildBadge('Mensalista', AppColors.primary, AppColors.star),
                    _buildBadge(
                      jogador.vinculado ? 'Vinculado' : 'Não vinculado',
                      jogador.vinculado
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.3),
                      jogador.vinculado ? AppColors.success : AppColors.warning,
                      icone: jogador.vinculado ? Icons.check_circle : Icons.warning_amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildBadge(String texto, Color fundo, Color corTexto, {IconData? icone}) {
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: fundo.withValues(alpha: 0.3),
        borderRadius: AppSizes.borderRadiusPill,
        border: Border.all(color: corTexto.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, color: corTexto, size: AppSizes.iconSm),
            const SizedBox(width: AppSizes.sm),
          ],
          Text(
            texto,
            style: AppTypography.labelSmall.copyWith(
              color: corTexto,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesAdmin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.ciclo != null)
          SizedBox(
            height: AppSizes.buttonHeight,
            child: _ehMensalista
                ? OutlinedButton(
                    style: AppButtons.secondary,
                    onPressed: _carregando ? null : _toggleMensalista,
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Remover dos Mensalistas'),
                  )
                : ElevatedButton(
                    style: AppButtons.primary,
                    onPressed: _carregando ? null : _toggleMensalista,
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Adicionar como Mensalista'),
                  ),
          ),
        if (!widget.jogador.vinculado) ...[
          if (!widget.usuarioJaVinculado) ...[
            const SizedBox(height: AppSizes.formGap),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                style: AppButtons.primary,
                onPressed: _carregando ? null : _vincularAMim,
                icon: const Icon(Icons.person_add, size: AppSizes.iconMd),
                label: const Text('Vincular a mim'),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.formGap),
          SizedBox(
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              style: AppButtons.secondary,
              onPressed: _mostrarCodigoVincular,
              icon: const Icon(Icons.link, size: AppSizes.iconMd),
              label: const Text('Ver Código de Vinculação'),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Painter do padrão decorativo da carta ───────────────────────────────────

class _PadraoCartaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.star.withValues(alpha: 0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Linhas diagonais sutis
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
