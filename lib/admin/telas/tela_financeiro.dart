import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/shared.dart';

class TelaFinanceiro extends StatefulWidget {
  const TelaFinanceiro({super.key});

  @override
  State<TelaFinanceiro> createState() => _TelaFinanceiroState();
}

class _TelaFinanceiroState extends State<TelaFinanceiro> {
  ResumoFinanceiro? _resumo;
  List<Despesa> _despesas = [];
  CicloMensal? _ciclo;
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
      final ciclo = await ServicoApi.obterCicloAtual();
      if (ciclo == null) {
        if (!mounted) return;
        setState(() {
          _ciclo = null;
          _resumo = null;
          _despesas = [];
          _carregando = false;
        });
        return;
      }

      final resultados = await Future.wait([
        ServicoApi.obterResumoFinanceiro(ciclo.id),
        ServicoApi.obterDespesasDoCiclo(ciclo.id),
      ]);

      if (!mounted) return;
      setState(() {
        _ciclo = ciclo;
        _resumo = resultados[0] as ResumoFinanceiro;
        _despesas = resultados[1] as List<Despesa>;
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

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _mostrarDialogDespesa() async {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    DateTime? dataSelecionada;

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
              title: Text('Registrar Despesa', style: AppTypography.titleMedium),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descricaoController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.inputPlaceholder),
                        filled: true,
                        fillColor: AppColors.formFieldBg,
                        border: OutlineInputBorder(
                          borderRadius: AppSizes.borderRadiusField,
                          borderSide: BorderSide(color: AppColors.formFieldBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppSizes.borderRadiusField,
                          borderSide: BorderSide(color: AppColors.formFieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppSizes.borderRadiusField,
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.formGap),
                    TextField(
                      controller: valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                      ],
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Valor (R\$)',
                        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.inputPlaceholder),
                        filled: true,
                        fillColor: AppColors.formFieldBg,
                        border: OutlineInputBorder(
                          borderRadius: AppSizes.borderRadiusField,
                          borderSide: BorderSide(color: AppColors.formFieldBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppSizes.borderRadiusField,
                          borderSide: BorderSide(color: AppColors.formFieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppSizes.borderRadiusField,
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.formGap),
                    GestureDetector(
                      onTap: () async {
                        final data = await showDatePicker(
                          context: ctx,
                          initialDate: dataSelecionada ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  surface: AppColors.background,
                                  onSurface: AppColors.textWhite,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (data != null) {
                          setDialogState(() => dataSelecionada = data);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: AppSizes.fieldContentPadding,
                        decoration: BoxDecoration(
                          color: AppColors.formFieldBg,
                          borderRadius: AppSizes.borderRadiusField,
                          border: Border.all(color: AppColors.formFieldBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.star, size: AppSizes.iconForm),
                            const SizedBox(width: AppSizes.md),
                            Text(
                              dataSelecionada != null
                                  ? _formatarData(dataSelecionada!)
                                  : 'Data (opcional)',
                              style: AppTypography.bodySmall.copyWith(
                                color: dataSelecionada != null
                                    ? AppColors.textWhite
                                    : AppColors.inputPlaceholder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != true) return;

    final descricao = descricaoController.text.trim();
    final valorTexto = valorController.text.trim().replaceAll(',', '.');
    final valor = double.tryParse(valorTexto);

    if (descricao.isEmpty || valor == null || valor <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe descrição e valor válidos')),
      );
      return;
    }

    try {
      await ServicoApi.criarDespesa(
        cicloMensalId: _ciclo!.id,
        descricao: descricao,
        valor: valor,
        data: dataSelecionada,
      );
      if (!mounted) return;
      _carregarDados();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar despesa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _ciclo != null
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _mostrarDialogDespesa,
              child: const Icon(Icons.add, color: AppColors.textWhite),
            )
          : null,
      body: Stack(
        children: [
          // Fundo P&B
          Positioned.fill(
            child: Opacity(
              opacity: AppSizes.bgImageOpacidade,
              child: Image.asset(
                'images/baderna-ico-sembg.png',
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
              Text('Erro ao carregar finanças', style: AppTypography.titleMedium),
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

    if (_ciclo == null || _resumo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textMuted, size: 64),
            const SizedBox(height: AppSizes.md),
            Text('Nenhum ciclo ativo', style: AppTypography.titleMedium),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Crie um ciclo mensal para ver o resumo financeiro.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card resumo
            _buildCardResumo(),

            const SizedBox(height: AppSizes.sectionGap),

            // Despesas
            Text('Despesas', style: AppTypography.titleMedium),
            const SizedBox(height: AppSizes.md),

            if (_despesas.isEmpty)
              _buildDespesasVazio()
            else
              _buildTabelaDespesas(),

            const SizedBox(height: AppSizes.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildCardResumo() {
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
          Text('Resumo do Ciclo', style: AppTypography.titleMedium),
          const SizedBox(height: AppSizes.xl),

          _buildLinhaResumo(
            'Mensalistas (${_resumo!.quantidadeMensalistas}x ${_formatarValor(_resumo!.valorMensalista)})',
            _resumo!.receitaMensalistas,
          ),
          const SizedBox(height: AppSizes.md),
          _buildLinhaResumo(
            'Diaristas (${_resumo!.quantidadeDiaristasPagos}x ${_formatarValor(_resumo!.diaria)})',
            _resumo!.receitaDiaristas,
          ),

          const SizedBox(height: AppSizes.lg),
          Divider(color: AppColors.textMuted.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: AppSizes.lg),

          _buildLinhaResumo('Receita Total', _resumo!.receitaTotal, destaque: true),
          const SizedBox(height: AppSizes.md),
          _buildLinhaResumo('Ciclo Mensal', -_resumo!.valorCicloMensal, negativo: true),
          const SizedBox(height: AppSizes.md),
          _buildLinhaResumo('Despesas Manuais', -_resumo!.despesasManuais, negativo: true),
          const SizedBox(height: AppSizes.md),
          _buildLinhaResumo('Total Despesas', -_resumo!.despesasTotal, negativo: true, destaque: true),

          const SizedBox(height: AppSizes.lg),
          Divider(color: AppColors.textMuted.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: AppSizes.lg),

          _buildLinhaResumo(
            'Saldo',
            _resumo!.saldo,
            destaque: true,
            corValor: _resumo!.saldo >= 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaResumo(
    String label,
    double valor, {
    bool destaque = false,
    bool negativo = false,
    Color? corValor,
  }) {
    final textoValor = negativo
        ? '- ${_formatarValor(valor.abs())}'
        : _formatarValor(valor);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: destaque
                ? AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)
                : AppTypography.bodySmall.copyWith(color: AppColors.textWhite),
          ),
        ),
        Text(
          textoValor,
          style: destaque
              ? AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: corValor ?? AppColors.textWhite,
                )
              : AppTypography.bodySmall.copyWith(
                  color: corValor ?? (negativo ? AppColors.error : AppColors.textWhite),
                ),
        ),
      ],
    );
  }

  Widget _buildTabelaDespesas() {
    return ClipRRect(
      borderRadius: AppSizes.borderRadiusMd,
      child: Column(
        children: [
          // Header
          Container(
            height: AppSizes.tableHeaderHeight,
            padding: AppSizes.tableCellPadding,
            color: AppColors.tableHeaderBg,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Descrição', style: AppTypography.tableHeader),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Valor', style: AppTypography.tableHeader, textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Data', style: AppTypography.tableHeader, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.tableGap),

          // Linhas
          ...List.generate(_despesas.length, (i) {
            final despesa = _despesas[i];
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? AppSizes.tableGap : 0),
              child: Container(
                height: AppSizes.tableRowHeight,
                padding: AppSizes.tableCellPadding,
                color: i.isOdd ? AppColors.tableRowAltBg : AppColors.tableRowBg,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        despesa.descricao,
                        style: AppTypography.tableRow,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatarValor(despesa.valor),
                        style: AppTypography.tableRow,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        despesa.data != null ? _formatarData(despesa.data!) : '-',
                        style: AppTypography.tableRow,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDespesasVazio() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppSizes.xl),
          const Icon(Icons.receipt_long_outlined, color: AppColors.textMuted, size: 48),
          const SizedBox(height: AppSizes.md),
          Text(
            'Nenhuma despesa registrada',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
