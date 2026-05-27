class Account {
  final String id;
  final String name;
  final String type; // 'cash', 'bank', 'credit_card', 'investment'
  final String currency;
  final double initialBalance;
  final double currentBalance;
  final String? workspaceId;
  final DateTime? createdAt;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.initialBalance,
    double? currentBalance,
    this.workspaceId,
    this.createdAt,
  }) : currentBalance = currentBalance ?? initialBalance;

  factory Account.fromJson(Map<String, dynamic> json) {
    final initialBalance =
        double.tryParse(json['initial_balance']?.toString() ?? '0') ?? 0.0;
    final currentBalance =
        double.tryParse(
          json['current_balance']?.toString() ??
              json['balance']?.toString() ??
              '',
        ) ??
        initialBalance;

    return Account(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'cash',
      currency: json['currency']?.toString() ?? 'USD',
      initialBalance: initialBalance,
      currentBalance: currentBalance,
      workspaceId: json['workspace'] != null
          ? (json['workspace'] is Map
                    ? json['workspace']['id']
                    : json['workspace'])
                .toString()
          : null,
      createdAt: DateTime.tryParse(json['date_created']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && id != '0') 'id': id,
      'name': name,
      'type': type,
      'currency': currency,
      'initial_balance': initialBalance,
      if (workspaceId != null) 'workspace': workspaceId,
    };
  }
}
