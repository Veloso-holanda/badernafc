import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import '../../admin/telas/tela_cadastro_jogador.dart';

class TelaJogadores extends StatefulWidget {
  final bool ehAdmin;

  const TelaJogadores({super.key, this.ehAdmin = false});

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
        ServicoApi.obterTodosJogadores(),
        ServicoApi.obterCicloAtual(),
        ServicoApi.obterConfiguracoesGerais(),
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

  Future<void> _mostrarDialogMensalista(Jogador jogador) async {
    if (_ciclo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum ciclo ativo para gerenciar mensalistas')),
      );
      return;
    }

    final ehMensalista = _mensalistas.any((m) => m.id == jogador.id);

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
          title: Text(jogador.nomeExibicao, style: AppTypography.titleMedium),
          content: Text(
            ehMensalista
                ? 'Remover ${jogador.nomeExibicao} dos mensalistas do ciclo atual?'
                : 'Adicionar ${jogador.nomeExibicao} como mensalista do ciclo atual?',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              style: AppButtons.text,
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: AppButtons.primaryForm,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ehMensalista ? 'Remover' : 'Adicionar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    try {
      final idsAtuais = _mensalistas.map((m) => m.id).toList();
      if (ehMensalista) {
        idsAtuais.remove(jogador.id);
      } else {
        idsAtuais.add(jogador.id);
      }

      await ServicoApi.atualizarCicloMensal(_ciclo!.id, mensalistas: idsAtuais);
      if (!mounted) return;
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar mensalistas: $e')),
      );
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

    final listaAtual = _mostrandoMensalistas ? _mensalistas : _jogadores;

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
      onTap: widget.ehAdmin ? () => _mostrarDialogMensalista(jogador) : null,
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
                : 'Nenhum jogador cadastrado',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _mostrandoMensalistas
                ? 'Não há ciclo mensal ativo ou nenhum mensalista foi adicionado.'
                : 'O admin precisa cadastrar jogadores.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
