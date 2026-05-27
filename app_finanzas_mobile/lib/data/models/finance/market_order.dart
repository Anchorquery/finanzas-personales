import 'market_item.dart';

class MarketOrder {
  final String id;
  final DateTime date;
  final double totalAmount;
  final String? workspaceId;
  final String? transactionId;
  final List<MarketItem> items;

  MarketOrder({
    required this.id,
    required this.date,
    required this.totalAmount,
    this.workspaceId,
    this.transactionId,
    this.items = const [],
  });

  factory MarketOrder.fromJson(Map<String, dynamic> json) {
    return MarketOrder(
      id: json['id']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '') ?? 0.0,
      workspaceId: json['workspace']?.toString(),
      transactionId: json['transaction']?.toString(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => MarketItem.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'workspace': workspaceId,
      'transaction': transactionId,
    };
  }
}
