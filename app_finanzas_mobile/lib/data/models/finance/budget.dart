class Budget {
  final String id;
  final String name;
  final double limit; // 'budget' in previous map
  final double spent;
  final double percent;

  Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    required this.percent,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Presupuesto',
      limit: double.tryParse(json['budget']?.toString() ?? '') ?? 0.0,
      spent: double.tryParse(json['spent']?.toString() ?? '') ?? 0.0,
      percent: double.tryParse(json['percent']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget': limit,
      'spent': spent,
      'percent': percent,
    };
  }
}
