import 'package:flutter/material.dart';

class CustomBottomNavBarItem {
  final IconData icon;
  final String? label;
  final bool isAddButton;

  const CustomBottomNavBarItem({
    required this.icon,
    this.label,
    this.isAddButton = false,
  });
}
