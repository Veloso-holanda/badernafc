import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/shared.dart';

class TelaConfiguracoesGerais extends StatefulWidget {
  const TelaConfiguracoesGerais({super.key});

  @override
  State<TelaConfiguracoesGerais> createState() => _TelaConfiguracoesGeraisState();
}

class _TelaConfiguracoesGeraisState extends State<TelaConfiguracoesGerais> {
  final _valorCicloMensalController = TextEditingController();
  final _diariaController = TextEditingController();
  final _valorMensalistaController = TextEditingController();

  int? _diaFutebol;
  TimeOfDay? _horaFutebol;
  bool _carregando = true;
  bool _salvando = false;
  ConfiguracoesGerais? _config;

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

  @override
  void dispose() {
    _valorCicloMensalController.dispose();
    _diariaController.dispose();
    _valorMensalistaController.dispose();
    super.dispose();
  }

  Future<void> _carregarConfig() async {
    try {
      final config = await ServicoApi.obterConfiguracoesGerais();
      if (!mounted) return;
      if (config != null) {
        _config = config;
        _valorCicloMensalController.text = config.valorCicloMensal.toStringAsFixed(2).replaceAll('.', ',');
        _diariaController.text = config.diaria.toStringAsFixed(2).replaceAll('.', ',');
        _valorMensalistaController.text = config.valorMensalista.toStringAsFixed(2).replaceAll('.', ',');
        _diaFutebol = config.diaFutebol;
        final partes = config.horaFutebol.split(':');
        if (partes.length == 2) {
          _horaFutebol = TimeOfDay(
            hour: int.tryParse(partes[0]) ?? 21,
            minute: int.tryParse(partes[1]) ?? 0,
          );
        }
      }
      setState(() => _carregando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar configurações: $e')),
      );
    }
  }

  String _formatarHorario(TimeOfDay horario) {
    return '${horario.hour.toString().padLeft(2, '0')}:'
        '${horario.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horaFutebol ?? const TimeOfDay(hour: 21, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.background,
              onSurface: AppColors.textWhite,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (horario != null) {
      setState(() => _horaFutebol = horario);
    }
  }

  double? _parseValor(String texto) {
    final limpo = texto.trim().replaceAll(',', '.');
    return double.tryParse(limpo);
  }

  Future<void> _salvar() async {
    if (_diaFutebol == null) {
      _mostrarErro('Selecione o dia do futebol');
      return;
    }
    if (_horaFutebol == null) {
      _mostrarErro('Selecione o horário');
      return;
    }

    final valorCicloMensal = _parseValor(_valorCicloMensalController.text);
    if (valorCicloMensal == null || valorCicloMensal < 0) {
      _mostrarErro('Informe um valor de ciclo mensal válido');
      return;
    }

    final diaria = _parseValor(_diariaController.text);
    if (diaria == null || diaria < 0) {
      _mostrarErro('Informe um valor de diária válido');
      return;
    }

    final valorMensalista = _parseValor(_valorMensalistaController.text);
    if (valorMensalista == null || valorMensalista < 0) {
      _mostrarErro('Informe um valor de mensalista válido');
      return;
    }

    setState(() => _salvando = true);

    try {
      if (_config == null) {
        await ServicoApi.criarConfiguracoesGerais(
          valorCicloMensal: valorCicloMensal,
          diaria: diaria,
          valorMensalista: valorMensalista,
          diaFutebol: _diaFutebol!,
          horaFutebol: _formatarHorario(_horaFutebol!),
        );
      } else {
        await ServicoApi.atualizarConfiguracoesGerais(
          valorCicloMensal: valorCicloMensal,
          diaria: diaria,
          valorMensalista: valorMensalista,
          diaFutebol: _diaFutebol!,
          horaFutebol: _formatarHorario(_horaFutebol!),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar configurações: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
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
          Positioned.fill(
            child: Opacity(
              opacity: AppSizes.bgImageOpacidade,
              child: Image.asset(
                'images/baderna_icon_pb.jpeg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: AppSizes.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            Text('Configurações Gerais', style: AppTypography.titleMedium),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sectionGap),
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
                                label: 'Dia do futebol',
                                child: _buildCampoInput(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _diaFutebol,
                                      isExpanded: true,
                                      dropdownColor: AppColors.background,
                                      hint: Text(
                                        'Selecionar dia',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.inputPlaceholder,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      icon: const Icon(Icons.expand_more, color: AppColors.star, size: AppSizes.iconForm),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textWhite,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      items: List.generate(7, (i) {
                                        return DropdownMenuItem(
                                          value: i,
                                          child: Text(_diasSemana[i]),
                                        );
                                      }),
                                      onChanged: (valor) => setState(() => _diaFutebol = valor),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.xxl),
                              _buildCampo(
                                label: 'Horário',
                                child: _buildCampoInput(
                                  onTap: _selecionarHorario,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: AppColors.star, size: AppSizes.iconForm),
                                      const SizedBox(width: AppSizes.md + 2),
                                      Text(
                                        _horaFutebol != null
                                            ? _formatarHorario(_horaFutebol!)
                                            : 'Selecionar horário',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: _horaFutebol != null
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
                              _buildCampoValor(
                                label: 'Valor do ciclo mensal',
                                controller: _valorCicloMensalController,
                              ),
                              const SizedBox(height: AppSizes.xxl),
                              _buildCampoValor(
                                label: 'Valor mensalista',
                                controller: _valorMensalistaController,
                              ),
                              const SizedBox(height: AppSizes.xxl),
                              _buildCampoValor(
                                label: 'Valor diária',
                                controller: _diariaController,
                              ),
                              const SizedBox(height: AppSizes.sectionGap),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: AppButtons.primaryForm,
                                  onPressed: _salvando ? null : _salvar,
                                  icon: _salvando
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: AppColors.textWhite,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save, size: AppSizes.iconMd),
                                  label: Text(_config == null ? 'Cadastrar' : 'Salvar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoValor({
    required String label,
    required TextEditingController controller,
  }) {
    return _buildCampo(
      label: label,
      child: _buildCampoInput(
        child: Row(
          children: [
            Text(
              'R\$',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.star,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSizes.md + 2),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: '0,00',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.inputPlaceholder,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampo({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
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
