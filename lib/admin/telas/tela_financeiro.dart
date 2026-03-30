import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import 'tela_detalhe_financeiro.dart';

class TelaFinanceiro extends StatefulWidget {
  const TelaFinanceiro({super.key});

  @override
  State<TelaFinanceiro> createState() => _TelaFinanceiroState();
}

class _TelaFinanceiroState extends State<TelaFinanceiro> {
  List<CicloMensal> _todosCiclos = [];
  List<int> _anosDisponiveis = [];
  int _anoSelecionado = DateTime.now().year;
  bool _carregando = true;
  String? _erro;

  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

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
      final ciclos = await ServicoApi.obterTodosCiclos(ContextoTime.timeIdAtivo!);

      final anos = ciclos
          .map((c) => c.dataInicial.year)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      if (!mounted) return;
      setState(() {
        _todosCiclos = ciclos;
        _anosDisponiveis = anos;
        if (anos.isNotEmpty && !anos.contains(_anoSelecionado)) {
          _anoSelecionado = anos.first;
        }
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

  List<CicloMensal> get _ciclosFiltrados {
    final filtrados = _todosCiclos
        .where((c) => c.dataInicial.year == _anoSelecionado)
        .toList()
      ..sort((a, b) => b.dataInicial.compareTo(a.dataInicial));
    return filtrados;
  }

  String _nomeCiclo(CicloMensal ciclo) {
    return 'Ciclo ${_meses[ciclo.dataInicial.month - 1]}';
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _abrirDetalhe(CicloMensal ciclo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaDetalheFinanceiro(ciclo: ciclo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fundo P&B
          Positioned.fill(
            child: Opacity(
              opacity: AppSizes.bgImageOpacidade,
              child: Image.asset(
                'images/escudo_preto.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xl, AppSizes.xl, AppSizes.xl, 0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textWhite,
                          size: AppSizes.iconXl,
                        ),
                      ),
                      const SizedBox(width: AppSizes.lg),
                      Text('Finanças', style: AppTypography.headerTitle),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.sectionGap),

                // Body
                Expanded(child: _buildConteudo()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
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
              Text('Erro ao carregar ciclos', style: AppTypography.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Text(_erro!, style: AppTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton(
                style: AppButtons.primary,
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_todosCiclos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textMuted, size: 64),
            const SizedBox(height: AppSizes.md),
            Text('Nenhum ciclo encontrado', style: AppTypography.titleMedium),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Crie um ciclo mensal para ver o financeiro.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final ciclos = _ciclosFiltrados;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de ano
            _buildSeletorAno(),

            const SizedBox(height: AppSizes.sectionGap),

            // Subtítulo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ciclos de $_anoSelecionado', style: AppTypography.titleMedium),
                Text(
                  '${ciclos.length} ciclo${ciclos.length != 1 ? 's' : ''}',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl),

            // Lista de ciclos
            if (ciclos.isEmpty)
              _buildCiclosVazio()
            else
              ...ciclos.map((ciclo) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.lg),
                    child: _buildCardCiclo(ciclo),
                  )),

            const SizedBox(height: AppSizes.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSeletorAno() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: AppSizes.borderRadiusPill,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Seta esquerda
          GestureDetector(
            onTap: () {
              final idx = _anosDisponiveis.indexOf(_anoSelecionado);
              if (idx < _anosDisponiveis.length - 1) {
                setState(() => _anoSelecionado = _anosDisponiveis[idx + 1]);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Icon(
                Icons.chevron_left,
                color: _anosDisponiveis.indexOf(_anoSelecionado) < _anosDisponiveis.length - 1
                    ? AppColors.textWhite
                    : AppColors.textMuted,
                size: AppSizes.iconXl,
              ),
            ),
          ),

          // Ano
          Text(
            '$_anoSelecionado',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          ),

          // Seta direita
          GestureDetector(
            onTap: () {
              final idx = _anosDisponiveis.indexOf(_anoSelecionado);
              if (idx > 0) {
                setState(() => _anoSelecionado = _anosDisponiveis[idx - 1]);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Icon(
                Icons.chevron_right,
                color: _anosDisponiveis.indexOf(_anoSelecionado) > 0
                    ? AppColors.textWhite
                    : AppColors.textMuted,
                size: AppSizes.iconXl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCiclo(CicloMensal ciclo) {
    return GestureDetector(
      onTap: () => _abrirDetalhe(ciclo),
      child: Container(
        width: double.infinity,
        padding: AppSizes.cardAdminPadding,
        decoration: BoxDecoration(
          color: AppColors.cardAdminBg,
          borderRadius: AppSizes.borderRadiusCardAdmin,
          border: Border.all(color: AppColors.cardAdminBorder),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: AppSizes.borderRadiusMd,
              ),
              child: const Icon(
                Icons.calendar_month,
                color: AppColors.star,
                size: AppSizes.iconXl,
              ),
            ),

            const SizedBox(width: AppSizes.xl),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nomeCiclo(ciclo),
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '${_formatarData(ciclo.dataInicial)} — ${_formatarData(ciclo.dataFinal)}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '${ciclo.qtdPartidas} partida${ciclo.qtdPartidas != 1 ? 's' : ''}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Seta
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: AppSizes.iconXl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCiclosVazio() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSizes.xxxl),
          const Icon(Icons.event_busy, color: AppColors.textMuted, size: 48),
          const SizedBox(height: AppSizes.md),
          Text(
            'Nenhum ciclo em $_anoSelecionado',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
