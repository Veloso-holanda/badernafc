import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../servicos/servico_auth.dart';
import '../../usuarios/telas/tela_login.dart';
import '../../usuarios/telas/tela_home.dart';

class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _navegar();
  }

  Future<void> _navegar() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final destino = ServicoAuth.estaLogado
        ? const TelaHome()
        : const TelaLogin();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(
          'images/baderna_icon.png',
          width: 390,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
