class TransactionItem {
  final String id;
  final String name;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? categoryName;
  final String transactionId;
  final DateTime? transactionDate;

  TransactionItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.categoryName,
    required this.transactionId,
    this.transactionDate,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    DateTime? date;
    if (json['transaction'] is Map && json['transaction']['date'] != null) {
      date = DateTime.parse(json['transaction']['date']);
    }

    return TransactionItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      categoryName: json['category_name'],
      transactionId: json['transaction'] is Map ? json['transaction']['id'] : (json['transaction'] ?? ''),
      transactionDate: date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'category_name': categoryName,
      'transaction': transactionId,
      if (transactionDate != null) 'transaction_date': transactionDate?.toIso8601String(),
    };
  }
}
