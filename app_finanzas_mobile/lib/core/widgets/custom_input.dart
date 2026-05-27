import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final IconData? icon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const CustomInput({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
