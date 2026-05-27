class Category {
  final String id;
  final String name;
  final String? icon;
  final String type; // 'income', 'expense', 'both'
  final String? workspaceId;
  final String? color;

  Category({
    required this.id,
    required this.name,
    this.icon,
    required this.type,
    this.workspaceId,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sin nombre',
      icon: json['icon']?.toString(),
      type: json['type']?.toString() ?? 'expense',
      workspaceId: json['workspace'] is Map
          ? json['workspace']['id']
          : json['workspace']?.toString(),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'workspace': workspaceId,
      'color': color,
    };
  }
}
