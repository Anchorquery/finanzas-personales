/// Lightweight reusable transaction template persisted locally per workspace.
class TransactionTemplate {
  TransactionTemplate({
    required this.id,
    required this.label,
    required this.amount,
    required this.type,
    required this.workspaceId,
    this.concept,
    this.categoryId,
    this.categoryName,
    this.icon,
    this.sortOrder = 0,
  });

  final String id;
  final String label;
  final double amount;
  final String type; // 'income' | 'expense'
  final String workspaceId;
  final String? concept;
  final String? categoryId;
  final String? categoryName;
  final String? icon; // emoji or material icon name
  final int sortOrder;

  TransactionTemplate copyWith({
    String? label,
    double? amount,
    String? type,
    String? concept,
    String? categoryId,
    String? categoryName,
    String? icon,
    int? sortOrder,
  }) =>
      TransactionTemplate(
        id: id,
        label: label ?? this.label,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        workspaceId: workspaceId,
        concept: concept ?? this.concept,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        icon: icon ?? this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'amount': amount,
        'type': type,
        'workspaceId': workspaceId,
        'concept': concept,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'icon': icon,
        'sortOrder': sortOrder,
      };

  factory TransactionTemplate.fromJson(Map<String, dynamic> j) =>
      TransactionTemplate(
        id: j['id'] as String,
        label: j['label'] as String,
        amount: (j['amount'] as num).toDouble(),
        type: j['type'] as String,
        workspaceId: j['workspaceId'] as String,
        concept: j['concept'] as String?,
        categoryId: j['categoryId'] as String?,
        categoryName: j['categoryName'] as String?,
        icon: j['icon'] as String?,
        sortOrder: (j['sortOrder'] as num?)?.toInt() ?? 0,
      );
}
