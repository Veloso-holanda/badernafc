import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/shared.dart';

class TelaTimes extends StatefulWidget {
  const TelaTimes({super.key});

  @override
  State<TelaTimes> createState() => _TelaTimesState();
}

class _TelaTimesState extends State<TelaTimes> {
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

      if (!mounted) return;
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

  Future<void> _trocarTime(Map<String, dynamic> dados) async {
    try {
      final timeData = dados['time'] as Map<String, dynamic>? ?? dados;
      final time = Time.fromJson(timeData);

      final membros = await ServicoApi.buscarMembros(time.id);
      final usuario = await ServicoApi.obterMeuPerfil();
      final papel = dados['papel'] as String? ?? 'membro';

      final meuMembro = membros.firstWhere(
        (m) => m.usuarioId == usuario.id,
        orElse: () => Membro(
          id: '',
          timeId: time.id,
          usuarioId: usuario.id,
          papel: papel,
        ),
      );

      ContextoTime.definir(time: time, membro: meuMembro);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trocou para ${time.nome}')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao trocar time: $e')),
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

    try {
      await ServicoApi.criarTime(
        nome,
        descricao: descricaoController.text.trim().isEmpty
            ? null
            : descricaoController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time criado com sucesso!')),
      );
      _carregarTimes();
    } catch (e) {
      if (!mounted) return;
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

    try {
      await ServicoApi.entrarNoTime(codigo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrou no time com sucesso!')),
      );
      _carregarTimes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar no time: $e')),
      );
    }
  }

  void _mostrarCodigoConvite(String codigo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
        title: Text('Codigo de Convite', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartilhe este codigo para convidar jogadores:',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSizes.xl),
            Container(
              width: double.infinity,
              padding: AppSizes.fieldContentPadding,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: AppSizes.borderRadiusCard,
                border: Border.all(color: AppColors.star),
              ),
              child: Text(
                codigo,
                style: AppTypography.titleLarge.copyWith(letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: AppButtons.text,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            style: AppButtons.primaryForm,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: codigo));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Codigo copiado!')),
              );
            },
            child: const Text('Copiar'),
          ),
        ],
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

          // Conteudo
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
                      Text('Meus Times', style: AppTypography.headerTitle),
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
              Text('Erro ao carregar times', style: AppTypography.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Text(_erro!, style: AppTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.xl),
              ElevatedButton(
                style: AppButtons.primary,
                onPressed: _carregarTimes,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _carregarTimes,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_timesComPapel.length} time${_timesComPapel.length != 1 ? 's' : ''}',
                  style: AppTypography.bodySmall,
                ),

                const SizedBox(height: AppSizes.sectionGap),

                // Time ativo destacado
                if (ContextoTime.timeAtivo != null) ...[
                  _buildCardTimeAtivo(),
                  const SizedBox(height: AppSizes.sectionGap),
                ],

                // Outros times
                ...List.generate(_timesComPapel.length, (i) {
                  final timeData = _timesComPapel[i]['time'] as Map<String, dynamic>? ?? _timesComPapel[i];
                  final timeId = timeData['_id'] as String?;
                  if (timeId == ContextoTime.timeIdAtivo) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.lg),
                    child: _buildCardTime(_timesComPapel[i]),
                  );
                }),

                const SizedBox(height: AppSizes.xxxl * 2),
              ],
            ),
          ),
        ),

        // FABs
        Positioned(
          bottom: AppSizes.xl,
          right: AppSizes.xxl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'entrar',
                backgroundColor: AppColors.cardAdminBg,
                onPressed: _entrarNoTime,
                child: const Icon(Icons.vpn_key_outlined, color: AppColors.star, size: AppSizes.iconMd),
              ),
              const SizedBox(height: AppSizes.md),
              FloatingActionButton(
                heroTag: 'criar',
                backgroundColor: AppColors.primary,
                onPressed: _criarTime,
                child: const Icon(Icons.add, color: AppColors.textWhite),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgePapel(bool ehAdmin) {
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: ehAdmin
            ? AppColors.adminBadgeBg
            : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.lg),
      ),
      child: Text(
        ehAdmin ? 'Admin' : 'Membro',
        style: AppTypography.labelSmall.copyWith(
          color: ehAdmin ? AppColors.adminBadge : AppColors.star,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildCardTimeAtivo() {
    final time = ContextoTime.timeAtivo!;
    final ehAdmin = ContextoTime.ehAdmin;

    return Container(
      width: double.infinity,
      padding: AppSizes.cardAdminPadding,
      decoration: BoxDecoration(
        color: AppColors.cardAdminBg,
        borderRadius: AppSizes.borderRadiusCardAdmin,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: AppSizes.borderRadiusMd,
                ),
                child: const Icon(Icons.shield, color: AppColors.star, size: AppSizes.iconXl),
              ),
              const SizedBox(width: AppSizes.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            time.nome,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Container(
                          padding: AppSizes.badgePadding,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppSizes.lg),
                          ),
                          child: Text(
                            'Ativo',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.star,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (time.descricao != null && time.descricao!.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        time.descricao!,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSizes.xs),
                    _buildBadgePapel(ehAdmin),
                  ],
                ),
              ),
            ],
          ),

          // Botao codigo convite (admin only)
          if (ehAdmin) ...[
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                style: AppButtons.secondary,
                onPressed: () => _mostrarCodigoConvite(time.codigoConvite),
                icon: const Icon(Icons.share, size: AppSizes.iconMd),
                label: const Text('Compartilhar codigo de convite'),
              ),
            ),
          ],
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
      onTap: () => _trocarTime(dados),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: AppSizes.borderRadiusMd,
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.textMuted, size: AppSizes.iconXl),
            ),
            const SizedBox(width: AppSizes.xl),
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
                  _buildBadgePapel(ehAdmin),
                ],
              ),
            ),
            Text(
              'Trocar',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            const Icon(Icons.swap_horiz, color: AppColors.primary, size: AppSizes.iconMd),
          ],
        ),
      ),
    );
  }
}
