import 'package:flutter/material.dart';

class NumericPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  const NumericPad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildRow(['1', '2', '3'], isDark),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6'], isDark),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9'], isDark),
        const SizedBox(height: 8),
        _buildRow(['.', '0', 'DEL'], isDark),
      ],
    );
  }

  Widget _buildRow(List<String> labels, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => _buildButton(label, isDark)).toList(),
    );
  }

  Widget _buildButton(String label, bool isDark) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (label == 'DEL') {
              onDeletePressed();
            } else {
              onNumberPressed(label);
            }
          },
          onLongPress: label == 'DEL' ? onClearPressed : null,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: _getChildForLabel(label, isDark),
          ),
        ),
      ),
    );
  }

  Widget _getChildForLabel(String label, bool isDark) {
    if (label == 'DEL') {
      return Icon(
        Icons.backspace_outlined,
        size: 24,
        color: isDark ? Colors.white70 : Colors.black54,
      );
    }

    if (label == 'AC') {
      return Text(
        'AC',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.redAccent.withValues(alpha: 0.8),
        ),
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
