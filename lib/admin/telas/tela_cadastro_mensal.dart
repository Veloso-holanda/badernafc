import 'package:flutter/material.dart';
import '../../shared/shared.dart';

class TelaCadastroMensal extends StatefulWidget {
  const TelaCadastroMensal({super.key});

  @override
  State<TelaCadastroMensal> createState() => _TelaCadastroMensalState();
}

class _TelaCadastroMensalState extends State<TelaCadastroMensal> {
  DateTime? _dataInicial;
  bool _carregando = false;
  ConfiguracoesGerais? _config;
  bool _carregandoConfig = true;

  static const _diasSemana = [
    'Domingo',
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
  ];

  @override
  void initState() {
    super.initState();
    _carregarConfig();
  }

  Future<void> _carregarConfig() async {
    try {
      final config = await ServicoApi.obterConfiguracoesGerais();
      if (!mounted) return;
      setState(() {
        _config = config;
        _carregandoConfig = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoConfig = false);
    }
  }

  // Calcula data final (dataInicial + 1 mês)
  DateTime? get _dataFinal {
    if (_dataInicial == null) return null;
    return DateTime(
      _dataInicial!.year,
      _dataInicial!.month + 1,
      _dataInicial!.day,
    );
  }

  // Conta quantas vezes o diaFutebol aparece no período
  int get _qtdPartidas {
    if (_dataInicial == null || _config == null) return 0;
    final fim = _dataFinal!;
    int count = 0;
    var d = _dataInicial!;
    while (d.isBefore(fim)) {
      if (d.weekday % 7 == _config!.diaFutebol) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicial ?? DateTime.now(),
      firstDate: DateTime.now(),
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
      setState(() => _dataInicial = data);
    }
  }

  Future<void> _salvar() async {
    if (_config == null) {
      _mostrarErro('Configurações gerais não encontradas. Cadastre as configurações primeiro.');
      return;
    }
    if (_dataInicial == null) {
      _mostrarErro('Selecione a data de início');
      return;
    }

    setState(() => _carregando = true);

    try {
      await ServicoApi.criarCicloMensal(
        dataInicial: _dataInicial!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ciclo mensal criado com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar ciclo: $e')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
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
                'images/baderna-ico-sembg.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: SingleChildScrollView(
              padding: AppSizes.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (fora do card)
                  Row(
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
                      Text(
                        'Cadastro Mensal',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.sectionGap),

                  // Info das configurações gerais
                  if (_carregandoConfig)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  else if (_config == null)
                    Container(
                      width: double.infinity,
                      padding: AppSizes.cardAdminPadding,
                      decoration: BoxDecoration(
                        color: AppColors.cardAdminBg,
                        borderRadius: AppSizes.borderRadiusCardAdmin,
                        border: Border.all(color: AppColors.cardAdminBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.warning_amber, color: AppColors.star, size: 32),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'Configurações gerais não cadastradas.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'Cadastre as configurações antes de criar um ciclo.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Card com info da config
                    Container(
                      width: double.infinity,
                      padding: AppSizes.cardAdminPadding,
                      decoration: BoxDecoration(
                        color: AppColors.cardAdminBg.withValues(alpha: 0.5),
                        borderRadius: AppSizes.borderRadiusCardAdmin,
                        border: Border.all(color: AppColors.cardAdminBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Configurações do Futebol', style: AppTypography.labelSmall),
                          const SizedBox(height: AppSizes.md),
                          _buildInfoLinha(Icons.event, '${_config!.diaFutebol < _diasSemana.length ? _diasSemana[_config!.diaFutebol] : "—"} às ${_config!.horaFutebol}'),
                          const SizedBox(height: AppSizes.sm),
                          _buildInfoLinha(Icons.attach_money, 'Mensal: R\$ ${_config!.valorMensalista.toStringAsFixed(2).replaceAll('.', ',')}  •  Diária: R\$ ${_config!.diaria.toStringAsFixed(2).replaceAll('.', ',')}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.sectionGap),

                    // Card formulário
                    Container(
                      padding: AppSizes.cardAdminPadding,
                      decoration: BoxDecoration(
                        color: AppColors.cardAdminBg,
                        borderRadius: AppSizes.borderRadiusCardAdmin,
                        border: Border.all(color: AppColors.cardAdminBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCampo(
                            label: 'Data de início',
                            child: _buildCampoInput(
                              onTap: _selecionarData,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: AppColors.star, size: AppSizes.iconForm),
                                  const SizedBox(width: AppSizes.md + 2),
                                  Text(
                                    _dataInicial != null
                                        ? _formatarData(_dataInicial!)
                                        : 'Selecionar data',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: _dataInicial != null
                                          ? AppColors.textWhite
                                          : AppColors.inputPlaceholder,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSizes.xxl),

                          _buildCampo(
                            label: 'Data final',
                            child: _buildCampoInput(
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: AppColors.star, size: AppSizes.iconForm),
                                  const SizedBox(width: AppSizes.md + 2),
                                  Text(
                                    _dataFinal != null
                                        ? _formatarData(_dataFinal!)
                                        : 'Calculado automaticamente',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: _dataFinal != null
                                          ? AppColors.textMuted
                                          : AppColors.inputPlaceholder,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSizes.xxl),

                          _buildCampo(
                            label: 'Quantidade de partidas',
                            child: _buildCampoInput(
                              child: Row(
                                children: [
                                  const Icon(Icons.tag, color: AppColors.star, size: AppSizes.iconForm),
                                  const SizedBox(width: AppSizes.md + 2),
                                  Text(
                                    _qtdPartidas > 0 ? '$_qtdPartidas' : 'Calculado automaticamente',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: _qtdPartidas > 0
                                          ? AppColors.textMuted
                                          : AppColors.inputPlaceholder,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSizes.sectionGap),

                          // Botão Salvar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: AppButtons.primaryForm,
                              onPressed: _carregando ? null : _salvar,
                              icon: _carregando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.textWhite,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save, size: AppSizes.iconMd),
                              label: const Text('Salvar mensal'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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

  Widget _buildCampo({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
        const SizedBox(height: AppSizes.fieldLabelGap),
        child,
      ],
    );
  }

  Widget _buildCampoInput({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: AppSizes.fieldContentPadding,
        decoration: BoxDecoration(
          color: AppColors.formFieldBg,
          borderRadius: AppSizes.borderRadiusField,
          border: Border.all(color: AppColors.formFieldBorder),
        ),
        child: child,
      ),
    );
  }
}
