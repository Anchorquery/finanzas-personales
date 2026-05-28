import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Campo de auth con etiqueta opcional encima e icono prefix.
/// Estilo violet fintech (bordeado, no `filled`).
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final String? label;
  final bool isDark;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final List<String>? autofillHints;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.isDark,
    this.label,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.autofillHints,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark
        ? const Color(0xFF13161F)
        : Colors.white;
    final border = isDark
        ? const Color(0x22FFFFFF)
        : const Color(0xFFE2E0F7);
    final iconColor = isDark ? Colors.white54 : AppTheme.textHint;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.2),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            autofillHints: autofillHints,
            style: TextStyle(
              color: textColor,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isCollapsed: false,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: iconColor,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, size: 20, color: iconColor),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: iconColor,
                      ),
                      onPressed: onTogglePassword,
                      tooltip: isPasswordVisible
                          ? 'Ocultar'
                          : 'Mostrar',
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
