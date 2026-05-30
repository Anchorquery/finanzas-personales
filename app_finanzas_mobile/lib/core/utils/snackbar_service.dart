import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_finanzas_mobile/core/theme/app_theme.dart';

enum _SnackVariant { error, success, warning, info, ai }

class SnackbarService {
  static const double _maxWidth = 460;
  static const Duration _defaultDuration = Duration(seconds: 4);

  static void showError(String title, String message, {Duration? duration}) =>
      _show(_SnackVariant.error, title, message,
          duration: duration ?? _defaultDuration);

  static void showSuccess(String title, String message, {Duration? duration}) =>
      _show(_SnackVariant.success, title, message,
          duration: duration ?? const Duration(seconds: 3));

  static void showWarning(String title, String message, {Duration? duration}) =>
      _show(_SnackVariant.warning, title, message,
          duration: duration ?? _defaultDuration);

  static void showInfo(String title, String message, {Duration? duration}) =>
      _show(_SnackVariant.info, title, message,
          duration: duration ?? _defaultDuration);

  static void showAI(String title, String message, {Duration? duration}) =>
      _show(_SnackVariant.ai, title, message,
          duration: duration ?? const Duration(seconds: 5));

  static void _show(
    _SnackVariant variant,
    String title,
    String message, {
    required Duration duration,
  }) {
    final spec = _specFor(variant);
    const cardBg = Colors.white;
    const titleColor = Color(0xFF0F172A);
    const bodyColor = Color(0xFF64748B);

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        duration: duration,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        animationDuration: const Duration(milliseconds: 320),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 0,
        maxWidth: _maxWidth,
        messageText: _SnackCard(
          spec: spec,
          title: title,
          message: message,
          bg: cardBg,
          titleColor: titleColor,
          bodyColor: bodyColor,
        ),
      ),
    );
  }

  static _VariantSpec _specFor(_SnackVariant v) {
    switch (v) {
      case _SnackVariant.error:
        return const _VariantSpec(
          accent: AppTheme.accentRed,
          icon: Icons.error_outline_rounded,
        );
      case _SnackVariant.success:
        return const _VariantSpec(
          accent: AppTheme.accentGreen,
          icon: Icons.check_circle_outline_rounded,
        );
      case _SnackVariant.warning:
        return const _VariantSpec(
          accent: AppTheme.accentWarning,
          icon: Icons.warning_amber_rounded,
        );
      case _SnackVariant.info:
        return const _VariantSpec(
          accent: AppTheme.accentBlue,
          icon: Icons.info_outline_rounded,
        );
      case _SnackVariant.ai:
        return const _VariantSpec(
          accent: AppTheme.accentAI,
          icon: Icons.auto_awesome_rounded,
        );
    }
  }
}

class _VariantSpec {
  final Color accent;
  final IconData icon;
  const _VariantSpec({required this.accent, required this.icon});
}

class _SnackCard extends StatelessWidget {
  final _VariantSpec spec;
  final String title;
  final String message;
  final Color bg;
  final Color titleColor;
  final Color bodyColor;

  const _SnackCard({
    required this.spec,
    required this.title,
    required this.message,
    required this.bg,
    required this.titleColor,
    required this.bodyColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: spec.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(spec.icon, color: spec.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkResponse(
                  onTap: () {
                    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                  },
                  radius: 18,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: bodyColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 3, color: spec.accent),
          ),
        ],
      ),
    );
  }
}
