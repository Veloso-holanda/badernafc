import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../shared/shared.dart';
import 'tela_cadastro.dart';
import 'tela_home.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await ServicoAuth.login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaHome()),
      );
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
          padding: AppSizes.screenPaddingLogin,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                Image.asset(
                  'images/baderna_icon.png',
                  width: 300,
                  height: 310,
                  errorBuilder: (_, _, _) => Container(
                    width: 200,
                    height: 210,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: AppSizes.borderRadiusLg,
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.sectionGap),

                // Form
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

                const SizedBox(height: AppSizes.md),

                // Esqueceu a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Esqueceu sua senha?',
                    style: AppTypography.linkMuted,
                  ),
                ),

                const SizedBox(height: AppSizes.xxl),

                // Botão Entrar
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _fazerLogin,
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                ),

                const SizedBox(height: AppSizes.xxl + 20),

                // Link cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não possui uma conta?',
                      style: AppTypography.linkMuted,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaCadastro(),
                        ),
                      ),
                      child: Text(
                        'Cadastre-se',
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
