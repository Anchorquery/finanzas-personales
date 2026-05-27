class Event {
  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double budget;
  final String status;

  Event({
    required this.id,
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    required this.budget,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Evento',
      description: json['description']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? ''),
      budget: double.tryParse(json['budget']?.toString() ?? '') ?? 0.0,
      status: json['status']?.toString() ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'budget': budget,
      'status': status,
    };
  }
}
