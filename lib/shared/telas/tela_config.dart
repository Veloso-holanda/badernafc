import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../shared.dart';
import '../../usuarios/telas/tela_login.dart';
import '../../admin/telas/tela_cadastro_mensal.dart';
import '../../admin/telas/tela_configuracoes_gerais.dart';
import '../../admin/telas/tela_financeiro.dart';

class TelaConfig extends StatefulWidget {
  final Usuario usuario;

  const TelaConfig({super.key, required this.usuario});

  @override
  State<TelaConfig> createState() => _TelaConfigState();
}

class _TelaConfigState extends State<TelaConfig> {
  late String? _fotoUrl;
  bool _enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    _fotoUrl = widget.usuario.fotoPerfilUrl;
  }

  @override
  void didUpdateWidget(TelaConfig oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usuario.id != widget.usuario.id) {
      _fotoUrl = widget.usuario.fotoPerfilUrl;
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

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (imagem == null || !mounted) return;

    setState(() => _enviandoFoto = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${widget.usuario.id}.jpg');

      await ref.putFile(
        File(imagem.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await ServicoApi.atualizarMeuPerfil(fotoUrl: url);

      if (!mounted) return;
      setState(() {
        _fotoUrl = url;
        _enviandoFoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviandoFoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.screenPadding,
      child: Column(
        children: [
          _buildPerfilSection(),
          const SizedBox(height: AppSizes.sectionGap),
          _buildMenuSection(context),
          const SizedBox(height: AppSizes.sectionGap),
          _buildBotaoSair(context),
        ],
      ),
    );
  }

  Widget _buildPerfilSection() {
    return Column(
      children: [
        // Avatar com ícone de câmera
        Stack(
          children: [
            GestureDetector(
              onTap: _fotoUrl != null ? () => _abrirFotoDialog(_fotoUrl!) : null,
              child: _buildAvatar(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _enviandoFoto ? null : _selecionarFoto,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Icon(
                    _enviandoFoto ? Icons.hourglass_top : Icons.camera_alt,
                    color: AppColors.textWhite,
                    size: AppSizes.iconSm,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.lg),

        // Nome
        Text(
          widget.usuario.nomeExibicao,
          style: AppTypography.titleLarge,
        ),

        const SizedBox(height: AppSizes.sm),

        // Email
        Text(
          widget.usuario.email,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSizes.md),

        // Badge
        if (widget.usuario.ehAdmin) _buildBadgeAdmin() else _buildBadgeNivel(),
      ],
    );
  }

  Widget _buildAvatar() {
    if (_enviandoFoto) {
      return CircleAvatar(
        radius: AppSizes.avatarXl / 2,
        backgroundColor: AppColors.tableHeaderBg,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.star,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_fotoUrl != null) {
      return CircleAvatar(
        radius: AppSizes.avatarXl / 2,
        backgroundColor: AppColors.tableHeaderBg,
        backgroundImage: NetworkImage(_fotoUrl!),
      );
    }

    return CircleAvatar(
      radius: AppSizes.avatarXl / 2,
      backgroundColor: AppColors.tableHeaderBg,
      child: Text(
        widget.usuario.iniciais,
        style: AppTypography.headerTitle.copyWith(
          color: AppColors.star,
        ),
      ),
    );
  }

  Widget _buildBadgeAdmin() {
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: AppColors.adminBadgeBg,
        borderRadius: BorderRadius.circular(AppSizes.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield,
            color: AppColors.adminBadge,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Administrador',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.adminBadge,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeNivel() {
    final nivel = widget.usuario.jogador?.nivel ?? 1;
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: AppColors.levelBadgeBg,
        borderRadius: BorderRadius.circular(AppSizes.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (i) {
            return Text(
              '\u2605',
              style: AppTypography.starRating.copyWith(
                color: i < nivel ? AppColors.star : AppColors.starInactive,
              ),
            );
          }),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Nivel $nivel',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.star,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final itens = widget.usuario.ehAdmin
        ? [
            _ItemMenu(
              icone: Icons.tune,
              label: 'Configuracoes Gerais',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaConfiguracoesGerais()),
              ),
            ),
            _ItemMenu(
              icone: Icons.calendar_today,
              label: 'Mensal',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaCadastroMensal()),
              ),
            ),
            _ItemMenu(
              icone: Icons.account_balance_wallet,
              label: 'Financas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaFinanceiro()),
              ),
            ),
          ]
        : [
            _ItemMenu(
              icone: Icons.person,
              label: 'Perfil',
              onTap: () => _mostrarEmBreve(context),
            ),
            _ItemMenu(
              icone: Icons.notifications_outlined,
              label: 'Notificacoes',
              onTap: () => _mostrarEmBreve(context),
            ),
          ];

    return ClipRRect(
      borderRadius: AppSizes.borderRadiusCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itens.length, (i) {
          return Column(
            children: [
              if (i > 0) const SizedBox(height: AppSizes.tableGap),
              itens[i],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBotaoSair(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await ServicoAuth.sair();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaLogin()),
          (_) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: AppSizes.exitButtonPadding,
        decoration: BoxDecoration(
          color: AppColors.exitBg,
          borderRadius: AppSizes.borderRadiusCard,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: AppColors.error, size: AppSizes.iconMd),
            const SizedBox(width: AppSizes.md + 2),
            Text(
              'Sair do app',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarEmBreve(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve...')),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String label;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSizes.menuItemPadding,
        color: AppColors.menuItemBg,
        child: Row(
          children: [
            Icon(icone, color: AppColors.star, size: AppSizes.iconMd),
            SizedBox(width: AppSizes.menuItemGap),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: AppSizes.iconForm,
            ),
          ],
        ),
      ),
    );
  }
}
