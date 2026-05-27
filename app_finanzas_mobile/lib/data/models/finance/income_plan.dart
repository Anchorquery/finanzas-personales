class IncomePlan {
  final String id;
  final String name;
  final double amount;
  final String? workspaceId;

  IncomePlan({
    required this.id,
    required this.name,
    required this.amount,
    this.workspaceId,
  });

  factory IncomePlan.fromJson(Map<String, dynamic> json) {
    return IncomePlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      workspaceId: json['workspace'] is Map
          ? json['workspace']['id']?.toString()
          : json['workspace']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      if (workspaceId != null) 'workspace': workspaceId,
    };
  }
}
