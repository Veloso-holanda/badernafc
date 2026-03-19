import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared.dart';
import '../../usuarios/telas/tela_login.dart';
import '../../usuarios/telas/tela_home.dart';

class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorAnimacao;
  late final Animation<double> _animacaoEscala;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controladorAnimacao = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animacaoEscala = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacao,
        curve: Curves.easeOutCubic,
      ),
    );

    _controladorAnimacao.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navegar();
      }
    });

    _controladorAnimacao.forward();
  }

  Future<void> _navegar() async {
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
  void dispose() {
    _controladorAnimacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBg,
      body: Center(
        child: AnimatedBuilder(
          animation: _animacaoEscala,
          builder: (context, child) => Transform.scale(
            scale: _animacaoEscala.value,
            child: child,
          ),
          child: Image.asset(
            'images/baderna_icon.jpeg',
            width: 300,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
