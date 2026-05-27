import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconByName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'shopping_cart':
      case 'shopping':
        return Icons.shopping_cart;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'directions_car':
      case 'transport':
      case 'car':
        return Icons.directions_car;
      case 'health_and_safety':
      case 'health':
        return Icons.health_and_safety;
      case 'school':
      case 'education':
        return Icons.school;
      case 'movie':
      case 'entertainment':
        return Icons.movie;
      case 'sports_soccer':
      case 'sports':
        return Icons.sports_soccer;
      case 'attach_money':
      case 'salary':
      case 'income':
        return Icons.attach_money;
      case 'card_giftcard':
      case 'gift':
        return Icons.card_giftcard;
      case 'savings':
      case 'investment':
        return Icons.savings;
      default:
        return Icons.category; // Default icon
    }
  }
}
