import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import 'tela_login.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _apelidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;

  @override
  void dispose() {
    _apelidoController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await ServicoAuth.cadastrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      // Registra o usuário no backend
      await ServicoApi.criarUsuario(
        nome: _apelidoController.text.trim(),
        email: _emailController.text.trim(),
        apelido: _apelidoController.text.trim(),
        telefone: _telefoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ServicoAuth.traduzirErro(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Header
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
                      Expanded(
                        child: Text(
                          'CADASTRAR',
                          style: AppTypography.headerTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: AppSizes.iconXl),
                    ],
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  // Campos do formulário
                  AppTextField(
                    label: 'Apelido',
                    hint: 'Seu apelido',
                    prefixIcon: Icons.person_outline,
                    controller: _apelidoController,
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe seu apelido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.formGap),

                  AppTextField(
                    label: 'Email',
                    hint: 'Insira seu email',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe seu email';
                      }
                      if (!valor.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.formGap),

                  AppTextField(
                    label: 'Telefone',
                    hint: '(00) 00000 - 0000',
                    prefixIcon: Icons.phone_outlined,
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: AppSizes.formGap),

                  AppTextField(
                    label: 'Senha',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted,
                        size: AppSizes.iconMd,
                      ),
                      onPressed: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe sua senha';
                      }
                      if (valor.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.formGap),

                  AppTextField(
                    label: 'Confirmar senha',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    controller: _confirmarSenhaController,
                    obscureText: !_confirmarSenhaVisivel,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmarSenhaVisivel
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textMuted,
                        size: AppSizes.iconMd,
                      ),
                      onPressed: () => setState(
                          () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Confirme sua senha';
                      }
                      if (valor != _senhaController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.sectionGap),

                  // Botão Cadastrar
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _cadastrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Cadastrar'),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  // Link login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já possui uma conta?',
                        style: AppTypography.linkMuted,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TelaLogin(),
                          ),
                        ),
                        child: Text(
                          'Faça login',
                          style: AppTypography.link,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
