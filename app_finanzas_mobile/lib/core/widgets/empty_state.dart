import 'package:flutter/material.dart';

/// Standard empty-state used across list screens.
/// Compatible with [RefreshIndicator] when wrapped in a scrollable parent.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
    this.actionLabel,
    this.iconColor = const Color(0x33FFFFFF),
    this.textColor = const Color(0x8AFFFFFF),
  });

  final IconData icon;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: action,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: textColor.withValues(alpha: 0.3)),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wrap [EmptyState] in a scrollable so [RefreshIndicator] still works.
class PullableEmptyState extends StatelessWidget {
  const PullableEmptyState({
    super.key,
    required this.onRefresh,
    required this.icon,
    required this.message,
    this.action,
    this.actionLabel,
    this.color,
    this.backgroundColor,
  });

  final Future<void> Function() onRefresh;
  final IconData icon;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyState(
              icon: icon,
              message: message,
              action: action,
              actionLabel: actionLabel,
            ),
          ),
        ],
      ),
    );
  }
}
