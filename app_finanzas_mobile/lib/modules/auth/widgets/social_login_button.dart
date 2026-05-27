import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black,
          backgroundColor: isDark ? AppTheme.inputFillDark : Colors.transparent,
          side: BorderSide(
            color: isDark
                ? AppTheme.inputBorderDark
                : AppTheme.inputBorderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
