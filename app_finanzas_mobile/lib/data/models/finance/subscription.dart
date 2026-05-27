class Subscription {
  final String id;
  final String name;
  final double amount;
  final String billingCycle;
  final DateTime? nextBillingDate;
  final String currency;
  final bool isActive;
  final String? provider;
  final int? day; // Calculated field for UI

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    this.nextBillingDate,
    required this.currency,
    this.isActive = true,
    this.provider,
    this.day,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    DateTime? nextBilling;
    try {
      if (json['next_billing_date'] != null) {
        nextBilling = DateTime.parse(json['next_billing_date'].toString());
      }
    } catch (_) {}

    return Subscription(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Suscripción',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      billingCycle: json['billing_cycle']?.toString() ?? 'monthly',
      nextBillingDate: nextBilling,
      currency: json['currency']?.toString() ?? 'USD',
      isActive: json['is_active'] == true,
      provider: json['provider']?.toString(),
      day: nextBilling?.day,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billing_cycle': billingCycle,
      'next_billing_date': nextBillingDate?.toIso8601String().split('T')[0],
      'currency': currency,
      'is_active': isActive,
      'provider': provider,
    };
  }
}
