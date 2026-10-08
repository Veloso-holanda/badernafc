import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;

  /// Quando `true`, o campo gerencia internamente um botão de mostrar/ocultar
  /// senha (ícone de olho). Centraliza o toggle de visibilidade que antes era
  /// replicado nas telas de login/cadastro.
  final bool obscuravel;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.obscuravel = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscurecido;

  @override
  void initState() {
    super.initState();
    _obscurecido = widget.obscuravel ? true : widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool obscurecer =
        widget.obscuravel ? _obscurecido : widget.obscureText;

    final Widget? sufixo = widget.obscuravel
        ? IconButton(
            icon: Icon(
              _obscurecido ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textMuted,
              size: AppSizes.iconMd,
            ),
            onPressed: () => setState(() => _obscurecido = !_obscurecido),
          )
        : widget.suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.inputLabel),
          const SizedBox(height: AppSizes.inputGap),
        ],
        SizedBox(
          height: AppSizes.inputHeight,
          child: TextFormField(
            controller: widget.controller,
            obscureText: obscurecer,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: AppColors.textMuted,
                      size: AppSizes.iconMd,
                    )
                  : null,
              suffixIcon: sufixo,
            ),
          ),
        ),
      ],
    );
  }
}
