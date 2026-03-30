import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared.dart';

class TelaPerfilJogador extends StatefulWidget {
  final Jogador jogador;
  final bool ehAdmin;
  final CicloMensal? ciclo;
  final List<Jogador> mensalistas;
  final bool usuarioJaVinculado;

  const TelaPerfilJogador({
    super.key,
    required this.jogador,
    this.ehAdmin = false,
    this.ciclo,
    this.mensalistas = const [],
    this.usuarioJaVinculado = false,
  });

  @override
  State<TelaPerfilJogador> createState() => _TelaPerfilJogadorState();
}

class _TelaPerfilJogadorState extends State<TelaPerfilJogador> {
  bool _carregando = false;
  late bool _ehMensalista;
  bool _dadosAlterados = false;

  @override
  void initState() {
    super.initState();
    _ehMensalista = widget.mensalistas.any((m) => m.id == widget.jogador.id);
  }

  Future<void> _toggleMensalista() async {
    if (widget.ciclo == null) return;

    setState(() => _carregando = true);

    try {
      final idsAtuais = widget.mensalistas.map((m) => m.id).toList();
      if (_ehMensalista) {
        idsAtuais.remove(widget.jogador.id);
      } else {
        idsAtuais.add(widget.jogador.id);
      }

      await ServicoApi.atualizarCicloMensal(ContextoTime.timeIdAtivo!, widget.ciclo!.id, mensalistas: idsAtuais);

      if (!mounted) return;
      setState(() {
        _ehMensalista = !_ehMensalista;
        _dadosAlterados = true;
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _ehMensalista
                ? '${widget.jogador.nomeExibicao} adicionado como mensalista'
                : '${widget.jogador.nomeExibicao} removido dos mensalistas',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar mensalistas: $e')),
      );
    }
  }

  void _abrirFotoDialog(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(32),
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: ClipRRect(
            borderRadius: AppSizes.borderRadiusCardAdmin,
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Future<void> _vincularAMim() async {
    final codigo = widget.jogador.codigoVincular;
    if (codigo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codigo de vinculacao nao disponivel')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await ServicoApi.vincularJogador(ContextoTime.timeIdAtivo!, codigoVincular: codigo);

      if (!mounted) return;
      setState(() {
        _dadosAlterados = true;
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.jogador.nomeExibicao} vinculado a voce!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao vincular: $e')),
      );
    }
  }

  void _mostrarCodigoVincular() {
    final codigo = widget.jogador.codigoVincular;
    if (codigo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codigo de vinculacao nao disponivel')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: AppSizes.borderRadiusCardAdmin),
        title: Text('Codigo de Vinculacao', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartilhe este codigo com o jogador para que ele vincule sua conta:',
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
                style: AppTypography.titleLarge.copyWith(
                  letterSpacing: 2,
                ),
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context, _dadosAlterados ? true : null),
          ),
          title: Text('Perfil do Jogador', style: AppTypography.titleMedium),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              _buildCarta(),
              if (widget.ehAdmin) ...[
                const SizedBox(height: AppSizes.sectionGap),
                _buildBotoesAdmin(),
              ],
            ],
          ),
        ),
    );
  }

  Widget _buildCarta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cartaGradientClaro,
            AppColors.cartaGradientEscuro,
          ],
        ),
        borderRadius: AppSizes.borderRadiusCardAdmin,
        border: Border.all(color: AppColors.star, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cartaSombraLeve,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: widget.jogador.fotoUrl != null
                ? () => _abrirFotoDialog(widget.jogador.fotoUrl!)
                : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.star, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cartaSombraLeve,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: AppSizes.avatarPerfil / 2,
                backgroundColor: AppColors.tableHeaderBg,
                backgroundImage: widget.jogador.fotoUrl != null
                    ? NetworkImage(widget.jogador.fotoUrl!)
                    : null,
                child: widget.jogador.fotoUrl == null
                    ? Text(
                        (widget.jogador.apelido ?? widget.jogador.nome)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: AppTypography.headerTitle.copyWith(
                          color: AppColors.star,
                          fontSize: 40,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          // Nome
          Text(
            widget.jogador.nome,
            style: AppTypography.headerTitle,
            textAlign: TextAlign.center,
          ),

          // Apelido
          if (widget.jogador.apelido != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              '"${widget.jogador.apelido!}"',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSizes.xl),

          // Estrelas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: AppSizes.starPerfil,
                  color: i < widget.jogador.nivel
                      ? AppColors.star
                      : AppColors.starInactive,
                ),
              );
            }),
          ),

          const SizedBox(height: AppSizes.xl),

          // Badges
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.md,
            alignment: WrapAlignment.center,
            children: [
              if (_ehMensalista)
                _buildBadge('Mensalista', AppColors.primary, AppColors.star),
              _buildBadge(
                widget.jogador.vinculado ? 'Vinculado' : 'Nao vinculado',
                widget.jogador.vinculado
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.warning.withValues(alpha: 0.3),
                widget.jogador.vinculado ? AppColors.success : AppColors.warning,
                icone: widget.jogador.vinculado ? Icons.check_circle : Icons.warning_amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String texto, Color fundo, Color corTexto, {IconData? icone}) {
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: fundo.withValues(alpha: 0.3),
        borderRadius: AppSizes.borderRadiusPill,
        border: Border.all(color: corTexto.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, color: corTexto, size: AppSizes.iconSm),
            const SizedBox(width: AppSizes.sm),
          ],
          Text(
            texto,
            style: AppTypography.labelSmall.copyWith(
              color: corTexto,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesAdmin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle mensalista
        if (widget.ciclo != null)
          SizedBox(
            height: AppSizes.buttonHeight,
            child: _ehMensalista
                ? OutlinedButton(
                    style: AppButtons.secondary,
                    onPressed: _carregando ? null : _toggleMensalista,
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Remover dos Mensalistas'),
                  )
                : ElevatedButton(
                    style: AppButtons.primary,
                    onPressed: _carregando ? null : _toggleMensalista,
                    child: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Adicionar como Mensalista'),
                  ),
          ),

        // Ações de vinculação (só se jogador não vinculado)
        if (!widget.jogador.vinculado) ...[
          // Vincular a mim (só se o usuário logado ainda não tem jogador vinculado)
          if (!widget.usuarioJaVinculado) ...[
            const SizedBox(height: AppSizes.formGap),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                style: AppButtons.primary,
                onPressed: _carregando ? null : _vincularAMim,
                icon: const Icon(Icons.person_add, size: AppSizes.iconMd),
                label: const Text('Vincular a mim'),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.formGap),
          SizedBox(
            height: AppSizes.buttonHeight,
            child: OutlinedButton.icon(
              style: AppButtons.secondary,
              onPressed: _mostrarCodigoVincular,
              icon: const Icon(Icons.link, size: AppSizes.iconMd),
              label: const Text('Ver Codigo de Vinculacao'),
            ),
          ),
        ],
      ],
    );
  }
}
