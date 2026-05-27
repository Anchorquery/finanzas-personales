class OrganizationSettings {
  final String id;
  final String? organizationId;
  final bool aiEnabled;
  final String? geminiApiKey;
  final double usageLimitUsd;

  OrganizationSettings({
    required this.id,
    this.organizationId,
    required this.aiEnabled,
    this.geminiApiKey,
    required this.usageLimitUsd,
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) {
    return OrganizationSettings(
      id: json['id']?.toString() ?? '',
      organizationId: json['organization_id']?.toString(),
      aiEnabled: json['ai_enabled'] == true,
      geminiApiKey: json['gemini_api_key']?.toString(),
      usageLimitUsd:
          double.tryParse(json['usage_limit_usd']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      'ai_enabled': aiEnabled,
      'gemini_api_key': geminiApiKey,
      'usage_limit_usd': usageLimitUsd,
    };
  }
}
