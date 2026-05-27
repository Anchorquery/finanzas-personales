class MarketItem {
  final String id;
  final String name;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String? categoryName;
  final String orderId;

  MarketItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.categoryName,
    required this.orderId,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    return MarketItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 1.0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
      categoryName: json['category_name']?.toString(),
      orderId: (json['order'] is Map) 
          ? json['order']['id']?.toString() ?? '' 
          : json['order']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'category_name': categoryName,
      'order': orderId,
    };
  }
}
