import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final List<String>? autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.inputFillDark : AppTheme.inputFillLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.inputBorderDark : AppTheme.inputBorderLight,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            size: 22,
          ),
          suffixIcon: isPassword
              ? Tooltip(
                  message: isPasswordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                  child: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      size: 22,
                    ),
                    onPressed: onTogglePassword,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
