import 'package:flutter/material.dart';
import '../shared.dart';
import '../../usuarios/telas/tela_login.dart';
import '../../admin/telas/tela_cadastro_mensal.dart';
import '../../admin/telas/tela_configuracoes_gerais.dart';
import '../../admin/telas/tela_financeiro.dart';

class TelaConfig extends StatelessWidget {
  final Usuario usuario;

  const TelaConfig({super.key, required this.usuario});

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
        // Avatar
        CircleAvatar(
          radius: AppSizes.avatarXl / 2,
          backgroundColor: AppColors.tableHeaderBg,
          child: const Icon(
            Icons.person,
            color: AppColors.textMuted,
            size: AppSizes.avatarLg,
          ),
        ),

        const SizedBox(height: AppSizes.lg),

        // Nome
        Text(
          usuario.nomeExibicao,
          style: AppTypography.titleLarge,
        ),

        const SizedBox(height: AppSizes.sm),

        // Email
        Text(
          usuario.email,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSizes.md),

        // Badge
        if (usuario.ehAdmin) _buildBadgeAdmin() else _buildBadgeNivel(),
      ],
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
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: AppColors.levelBadgeBg,
        borderRadius: BorderRadius.circular(AppSizes.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '★' * 5,
            style: AppTypography.starRating,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Nível 5',
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
    final itens = usuario.ehAdmin
        ? [
            _ItemMenu(
              icone: Icons.tune,
              label: 'Configurações Gerais',
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
              label: 'Finanças',
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
              label: 'Notificações',
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
