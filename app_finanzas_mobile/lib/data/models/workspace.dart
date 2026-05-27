import 'package:flutter/material.dart';

enum WorkspaceType { personal, family, business }

class Workspace {
  final String id;
  final String name;
  final WorkspaceType type;
  final String description;
  final bool isActive;
  final String? userId; // Vínculo con directus_users
  final String? organizationId; // Vínculo con organizations

  final int? colorValue;
  final int? iconCodePoint;

  final bool aiPredictiveAnalysis;
  final bool aiCategorization;
  final String currency;

  // Exchange Rate Fields
  final String exchangeRateMode; // 'manual', 'bcv', etc.
  final String secondaryCurrency;
  final double manualExchangeRate;
  final String accessScope; // 'organization' | 'restricted'
  final List<String> accessMemberIds;

  Workspace({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.isActive = false,
    this.userId,
    this.organizationId,
    this.colorValue,
    this.iconCodePoint,
    this.aiPredictiveAnalysis = false,
    this.aiCategorization = true,
    this.currency = 'USD',
    this.exchangeRateMode = 'manual',
    this.secondaryCurrency = 'VES',
    this.manualExchangeRate = 0.0,
    this.accessScope = 'restricted',
    this.accessMemberIds = const <String>[],
  });

  IconData get icon {
    if (iconCodePoint != null) {
      // ignore: non_const_argument_for_const_parameter
      return IconData(iconCodePoint!, fontFamily: 'MaterialIcons');
    }
    switch (type) {
      case WorkspaceType.personal:
        return Icons.person;
      case WorkspaceType.family:
        return Icons.people;
      case WorkspaceType.business:
        return Icons.business_center;
    }
  }

  Color get iconBackgroundColor {
    if (colorValue != null) {
      return Color(colorValue!);
    }
    switch (type) {
      case WorkspaceType.personal:
        return const Color(0xFF2B4BEE); // Azul primary
      case WorkspaceType.family:
        return const Color(0xFF8B5CF6); // Violeta
      case WorkspaceType.business:
        return const Color(0xFF475569); // Slate
    }
  }

  Workspace copyWith({
    String? id,
    String? name,
    WorkspaceType? type,
    String? description,
    bool? isActive,
    String? userId,
    int? colorValue,
    int? iconCodePoint,
    bool? aiPredictiveAnalysis,
    bool? aiCategorization,
    String? currency,
    String? exchangeRateMode,
    String? secondaryCurrency,
    double? manualExchangeRate,
    String? accessScope,
    List<String>? accessMemberIds,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      aiPredictiveAnalysis: aiPredictiveAnalysis ?? this.aiPredictiveAnalysis,
      aiCategorization: aiCategorization ?? this.aiCategorization,
      currency: currency ?? this.currency,
      exchangeRateMode: exchangeRateMode ?? this.exchangeRateMode,
      secondaryCurrency: secondaryCurrency ?? this.secondaryCurrency,
      manualExchangeRate: manualExchangeRate ?? this.manualExchangeRate,
      accessScope: accessScope ?? this.accessScope,
      accessMemberIds: accessMemberIds ?? this.accessMemberIds,
    );
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      type: WorkspaceType.values.firstWhere(
        (e) => e.toString() == 'WorkspaceType.${json['type']}',
        orElse: () => WorkspaceType.personal,
      ),
      description: json['description'] as String? ?? ' ',
      isActive: json['is_active'] as bool? ?? false,
      userId: json['user'] is Map
          ? json['user']['id']?.toString()
          : json['user']?.toString(),
      organizationId: json['organization'] is Map
          ? json['organization']['id'] as String?
          : json['organization']?.toString(),
      colorValue: json['color_value'] is int
          ? json['color_value'] as int
          : int.tryParse(json['color_value']?.toString() ?? ''),
      iconCodePoint: json['icon_code_point'] is int
          ? json['icon_code_point'] as int
          : int.tryParse(json['icon_code_point']?.toString() ?? ''),
      aiPredictiveAnalysis: json['ai_predictive_analysis'] as bool? ?? false,
      aiCategorization: json['ai_categorization'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'USD',
      exchangeRateMode: json['exchange_rate_mode'] as String? ?? 'manual',
      secondaryCurrency: json['secondary_currency'] as String? ?? 'VES',
      manualExchangeRate:
          double.tryParse(json['manual_exchange_rate']?.toString() ?? '0') ??
          0.0,
      accessScope: json['access_scope']?.toString() ?? 'restricted',
      accessMemberIds: _parseAccessMemberIds(json['access_member_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'is_active': isActive,
      'user': userId,
      'organization': organizationId,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
      'ai_predictive_analysis': aiPredictiveAnalysis,
      'ai_categorization': aiCategorization,
      'currency': currency,
      'exchange_rate_mode': exchangeRateMode,
      'secondary_currency': secondaryCurrency,
      'manual_exchange_rate': manualExchangeRate,
      'access_scope': accessScope,
      'access_member_ids': accessMemberIds,
    };
  }

  static List<String> _parseAccessMemberIds(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed == 'null') {
        return const <String>[];
      }

      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        return trimmed
            .substring(1, trimmed.length - 1)
            .split(',')
            .map((item) => item.replaceAll('"', '').trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      return <String>[trimmed];
    }

    return const <String>[];
  }
}
