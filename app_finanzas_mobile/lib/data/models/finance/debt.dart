class Debt {
  final String id;
  final String name;
  final double totalAmount;
  final double remainingAmount;
  final double? interestRate;
  final DateTime? dueDate;
  final String status; // 'active', 'paid'
  final String? workspaceId;

  Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingAmount,
    this.interestRate,
    this.dueDate,
    required this.status,
    this.workspaceId,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Desconocida',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '') ?? 0.0,
      remainingAmount: double.tryParse(json['remaining_amount']?.toString() ?? '') ?? 0.0,
      interestRate: double.tryParse(json['interest_rate']?.toString() ?? ''),
      dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'active',
      workspaceId: json['workspace']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'interest_rate': interestRate,
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'workspace': workspaceId,
    };
  }
}
