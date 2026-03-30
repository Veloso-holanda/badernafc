import 'package:flutter/material.dart';
import '../shared.dart';
import '../../usuarios/telas/tela_home.dart';
import '../../usuarios/telas/tela_login.dart';

class TelaSelecaoTime extends StatefulWidget {
  const TelaSelecaoTime({super.key});

  @override
  State<TelaSelecaoTime> createState() => _TelaSelecaoTimeState();
}

class _TelaSelecaoTimeState extends State<TelaSelecaoTime> {
  List<Map<String, dynamic>> _timesComPapel = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarTimes();
  }

  Future<void> _carregarTimes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final times = await ServicoApi.buscarMeusTimes();
      debugPrint('[SelecaoTime] buscarMeusTimes retornou ${times.length} times');
      for (final t in times) {
        debugPrint('[SelecaoTime] time raw: $t');
      }

      if (!mounted) return;

      // Se tem exatamente 1 time, vai direto
      if (times.length == 1) {
        await _selecionarTime(times.first);
        return;
      }

      setState(() {
        _timesComPapel = times;
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

  Future<void> _selecionarTime(Map<String, dynamic> dados) async {
    try {
      debugPrint('[SelecaoTime] _selecionarTime dados: $dados');
      final timeData = dados['time'] as Map<String, dynamic>? ?? dados;
      debugPrint('[SelecaoTime] timeData: $timeData');
      final time = Time.fromJson(timeData);
      debugPrint('[SelecaoTime] Time parsed: id=${time.id} nome=${time.nome}');
      final membroData = dados['membro'] as Map<String, dynamic>?;
      final papel = dados['papel'] as String? ?? membroData?['papel'] as String? ?? 'membro';
      debugPrint('[SelecaoTime] papel=$papel');

      // Buscar membros para achar o membro atual
      final membros = await ServicoApi.buscarMembros(time.id);
      debugPrint('[SelecaoTime] membros: ${membros.length}');
      for (final m in membros) {
        debugPrint('[SelecaoTime] membro: id=${m.id} usuarioId=${m.usuarioId} jogadorId=${m.jogadorId} papel=${m.papel}');
      }

      final usuario = await ServicoApi.obterMeuPerfil();
      debugPrint('[SelecaoTime] usuario: id=${usuario.id} nome=${usuario.nome}');

      final meuMembro = membros.firstWhere(
        (m) => m.usuarioId == usuario.id,
        orElse: () {
          debugPrint('[SelecaoTime] WARN: membro nao encontrado para usuario ${usuario.id}, usando fallback');
          return Membro(
            id: '',
            timeId: time.id,
            usuarioId: usuario.id,
            papel: papel,
          );
        },
      );
      debugPrint('[SelecaoTime] meuMembro: id=${meuMembro.id} papel=${meuMembro.papel} jogadorId=${meuMembro.jogadorId}');

      ContextoTime.definir(time: time, membro: meuMembro);
      debugPrint('[SelecaoTime] ContextoTime definido, navegando para TelaHome...');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaHome()),
      );
    } catch (e, stack) {
      debugPrint('[SelecaoTime] ERRO: $e');
      debugPrint('[SelecaoTime] Stack: $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar time: $e')),
      );
    }
  }

  Future<void> _criarTime() async {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
        title: Text('Criar Time', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Nome do time',
              hint: 'Ex: Baderna FC',
              prefixIcon: Icons.shield_outlined,
              controller: nomeController,
            ),
            const SizedBox(height: AppSizes.formGap),
            AppTextField(
              label: 'Descricao',
              hint: 'Opcional',
              prefixIcon: Icons.description_outlined,
              controller: descricaoController,
            ),
          ],
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
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (resultado != true) return;

    final nome = nomeController.text.trim();
    if (nome.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do time')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final time = await ServicoApi.criarTime(
        nome,
        descricao: descricaoController.text.trim().isEmpty
            ? null
            : descricaoController.text.trim(),
      );

      // Buscar membros para pegar meu membro (criador = admin)
      final membros = await ServicoApi.buscarMembros(time.id);
      final usuario = await ServicoApi.obterMeuPerfil();

      final meuMembro = membros.firstWhere(
        (m) => m.usuarioId == usuario.id,
        orElse: () => Membro(
          id: '',
          timeId: time.id,
          usuarioId: usuario.id,
          papel: 'admin',
        ),
      );

      ContextoTime.definir(time: time, membro: meuMembro);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaHome()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar time: $e')),
      );
    }
  }

  Future<void> _entrarNoTime() async {
    final codigoController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
        title: Text('Entrar no Time', style: AppTypography.titleMedium),
        content: AppTextField(
          label: 'Codigo de convite',
          hint: 'Cole o codigo aqui',
          prefixIcon: Icons.vpn_key_outlined,
          controller: codigoController,
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
            child: const Text('Entrar'),
          ),
        ],
      ),
    );

    if (resultado != true) return;

    final codigo = codigoController.text.trim();
    if (codigo.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o codigo de convite')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await ServicoApi.entrarNoTime(codigo);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrou no time com sucesso!')),
      );
      _carregarTimes();
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar no time: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _erro != null
                ? _buildErro()
                : _timesComPapel.isEmpty
                    ? _buildSemTimes()
                    : _buildListaTimes(),
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: AppSizes.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
            const SizedBox(height: AppSizes.md),
            Text('Erro ao carregar times', style: AppTypography.titleMedium),
            const SizedBox(height: AppSizes.sm),
            Text(_erro!, style: AppTypography.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _carregarTimes,
              child: const Text('Tentar novamente'),
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(
              style: AppButtons.text,
              onPressed: () async {
                await ServicoAuth.sair();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaLogin()),
                  (_) => false,
                );
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemTimes() {
    return SingleChildScrollView(
      padding: AppSizes.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Logo
          Image.asset(
            'images/escudo_laranja.png',
            width: 150,
            height: 160,
            errorBuilder: (_, _, _) => const Icon(
              Icons.sports_soccer,
              size: 80,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          Text(
            'Bem vindo!',
            style: AppTypography.headerTitle,
          ),

          const SizedBox(height: AppSizes.md),

          Text(
            'Voce ainda nao faz parte de nenhum time.\nCrie um novo ou entre com um codigo de convite.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.xxxl),

          // Botao criar time
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: _criarTime,
              icon: const Icon(Icons.add, size: AppSizes.iconMd),
              label: const Text('Criar Time'),
            ),
          ),

          const SizedBox(height: AppSizes.formGap),

          // Botao entrar com codigo
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              style: AppButtons.secondary,
              onPressed: _entrarNoTime,
              icon: const Icon(Icons.vpn_key_outlined, size: AppSizes.iconMd),
              label: const Text('Entrar com codigo'),
            ),
          ),

          const SizedBox(height: AppSizes.xxxl),

          TextButton(
            style: AppButtons.text,
            onPressed: () async {
              await ServicoAuth.sair();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const TelaLogin()),
                (_) => false,
              );
            },
            child: Text(
              'Sair do app',
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaTimes() {
    return SingleChildScrollView(
      padding: AppSizes.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.xl),

          Text('Seus Times', style: AppTypography.headerTitle),

          const SizedBox(height: AppSizes.sm),

          Text(
            'Selecione um time para continuar',
            style: AppTypography.bodySmall,
          ),

          const SizedBox(height: AppSizes.sectionGap),

          ...List.generate(_timesComPapel.length, (i) {
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? AppSizes.lg : 0),
              child: _buildCardTime(_timesComPapel[i]),
            );
          }),

          const SizedBox(height: AppSizes.sectionGap),

          // Botoes criar/entrar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: _criarTime,
                    icon: const Icon(Icons.add, size: AppSizes.iconMd),
                    label: const Text('Criar'),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                child: SizedBox(
                  height: AppSizes.buttonHeight,
                  child: OutlinedButton.icon(
                    style: AppButtons.secondary,
                    onPressed: _entrarNoTime,
                    icon: const Icon(Icons.vpn_key_outlined, size: AppSizes.iconMd),
                    label: const Text('Entrar'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTime(Map<String, dynamic> dados) {
    final timeData = dados['time'] as Map<String, dynamic>? ?? dados;
    final nome = timeData['nome'] as String? ?? 'Time';
    final descricao = timeData['descricao'] as String?;
    final papel = dados['papel'] as String? ?? 'membro';
    final ehAdmin = papel == 'admin';

    return GestureDetector(
      onTap: () => _selecionarTime(dados),
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
            // Icone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: AppSizes.borderRadiusMd,
              ),
              child: const Icon(
                Icons.shield,
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
                    nome,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (descricao != null && descricao.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      descricao,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSizes.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ehAdmin
                          ? AppColors.adminBadgeBg
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: AppSizes.borderRadiusSm,
                    ),
                    child: Text(
                      ehAdmin ? 'Admin' : 'Membro',
                      style: AppTypography.labelSmall.copyWith(
                        color: ehAdmin ? AppColors.adminBadge : AppColors.star,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
}
