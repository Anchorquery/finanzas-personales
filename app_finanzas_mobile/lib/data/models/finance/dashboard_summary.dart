class DashboardSummary {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double openingBalance;

  DashboardSummary({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    this.openingBalance = 0.0,
  });

  factory DashboardSummary.fromMap(Map<String, double> map) {
    return DashboardSummary(
      currentBalance: map['balance'] ?? 0.0,
      monthlyIncome: map['income'] ?? 0.0,
      monthlyExpenses: map['expense'] ?? 0.0,
      openingBalance: map['openingBalance'] ?? 0.0,
    );
  }
}
