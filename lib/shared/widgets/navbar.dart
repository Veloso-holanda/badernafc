import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_typography.dart';

class ItemNavbar {
  final IconData icone;
  final String label;

  const ItemNavbar({required this.icone, required this.label});
}

class Navbar extends StatelessWidget {
  final int indiceAtual;
  final ValueChanged<int> aoTrocar;
  final List<ItemNavbar> itens;

  const Navbar({
    super.key,
    required this.indiceAtual,
    required this.aoTrocar,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.navbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.navbarBg,
        border: Border(
          top: BorderSide(color: AppColors.navbarBorder, width: 1),
        ),
      ),
      padding: AppSizes.navbarPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(itens.length, (indice) {
          final ativo = indice == indiceAtual;
          final item = itens[indice];
          return Expanded(
            child: GestureDetector(
              onTap: () => aoTrocar(indice),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icone,
                    size: AppSizes.iconLg,
                    color: ativo
                        ? AppColors.navbarActive
                        : AppColors.navbarInactive,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    item.label,
                    style: ativo
                        ? AppTypography.navActive
                        : AppTypography.navInactive,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
