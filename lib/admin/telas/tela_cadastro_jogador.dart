import 'package:flutter/material.dart';
import '../../shared/shared.dart';

class TelaCadastroJogador extends StatefulWidget {
  const TelaCadastroJogador({super.key});

  @override
  State<TelaCadastroJogador> createState() => _TelaCadastroJogadorState();
}

class _TelaCadastroJogadorState extends State<TelaCadastroJogador> {
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  int _nivel = 3;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      _mostrarErro('Informe o nome do jogador');
      return;
    }

    setState(() => _carregando = true);

    try {
      await ServicoApi.criarJogador(
        nome: nome,
        apelido: _apelidoController.text.trim().isEmpty
            ? null
            : _apelidoController.text.trim(),
        nivel: _nivel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jogador cadastrado com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cadastrar Jogador', style: AppTypography.titleMedium),
        centerTitle: true,
      ),
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
          SingleChildScrollView(
            padding: AppSizes.screenPadding,
            child: Container(
              padding: AppSizes.cardAdminPadding,
              decoration: BoxDecoration(
                color: AppColors.cardAdminBg,
                borderRadius: AppSizes.borderRadiusCardAdmin,
                border: Border.all(color: AppColors.cardAdminBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  AppTextField(
                    label: 'Nome',
                    hint: 'Nome completo',
                    prefixIcon: Icons.person_outline,
                    controller: _nomeController,
                  ),

                  const SizedBox(height: AppSizes.formGap),

                  // Apelido
                  AppTextField(
                    label: 'Apelido',
                    hint: 'Apelido (opcional)',
                    prefixIcon: Icons.badge_outlined,
                    controller: _apelidoController,
                  ),

                  const SizedBox(height: AppSizes.formGap),

                  // Nível
                  Text('Nível', style: AppTypography.inputLabel),
                  const SizedBox(height: AppSizes.fieldLabelGap),
                  Container(
                    padding: AppSizes.fieldContentPadding,
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: AppSizes.borderRadiusPill,
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final estrela = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _nivel = estrela),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                            child: Text(
                              '★',
                              style: AppTypography.starRating.copyWith(
                                fontSize: 28,
                                color: estrela <= _nivel
                                    ? AppColors.star
                                    : AppColors.starInactive,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxxl),

                  // Botão salvar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtons.primary,
                      onPressed: _carregando ? null : _salvar,
                      child: _carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textWhite,
                              ),
                            )
                          : const Text('Cadastrar'),
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
}
