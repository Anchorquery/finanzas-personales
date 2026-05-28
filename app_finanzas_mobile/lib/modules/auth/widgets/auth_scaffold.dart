import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Fondo común para Login / Registro / Recuperación.
/// - Light: blanco roto con radial violet glow + dos blobs blur.
/// - Dark: backgroundDark con halos primary suaves.
class AuthScaffold extends StatelessWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Radial central
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.85,
                    colors: [
                      AppTheme.primary.withValues(
                        alpha: isDark ? 0.10 : 0.06,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Blob top-left
          Positioned(
            top: -120,
            left: -120,
            child: _Blob(
              size: 360,
              color:
                  AppTheme.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            ),
          ),
          // Blob bottom-right
          Positioned(
            bottom: -140,
            right: -140,
            child: _Blob(
              size: 420,
              color: AppTheme.accentAI
                  .withValues(alpha: isDark ? 0.15 : 0.08),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 140,
              spreadRadius: 60,
            ),
          ],
        ),
      ),
    );
  }
}
