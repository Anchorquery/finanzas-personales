class Saving {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime dateCreated;
  final double percent;
  final String? icon;
  final DateTime? targetDate;

  Saving({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.dateCreated,
    required this.percent,
    this.icon,
    this.targetDate,
  });

  factory Saving.fromJson(Map<String, dynamic> json) {
    final target = double.tryParse(json['target_amount']?.toString() ?? '') ?? 0.0;
    final current = double.tryParse(json['current_amount']?.toString() ?? '') ?? 0.0;
    
    return Saving(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Ahorro',
      targetAmount: target,
      currentAmount: current,
      dateCreated:
          DateTime.tryParse(json['date_created']?.toString() ?? '') ??
          DateTime.now(),
      percent: target > 0 ? (current / target) * 100 : 0.0,
      icon: json['icon']?.toString(),
      targetDate: json['target_date'] != null 
          ? DateTime.tryParse(json['target_date'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'date_created': dateCreated.toIso8601String(),
      'percent': percent,
      'icon': icon,
      'target_date': targetDate?.toIso8601String(),
    };
  }
}
