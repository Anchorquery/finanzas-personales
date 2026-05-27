import 'package:app_finanzas_mobile/data/models/finance/category.dart';
import 'package:app_finanzas_mobile/data/models/finance/transaction_item.dart';
import 'package:app_finanzas_mobile/data/models/user.dart';

class Transaction {
  final String id;
  final double amount;
  final String concept;
  final String? description;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final Category? category;
  final String? receiptImageId;
  final bool isPersonal;
  final String? debtId;
  final String? savingGoalId;
  final List<TransactionItem> items;
  final User? userCreated;
  final String? accountId;
  final String currency;

  Transaction({
    required this.id,
    required this.amount,
    required this.concept,
    this.description,
    required this.date,
    required this.type,
    this.category,
    this.receiptImageId,
    this.isPersonal = true,
    this.debtId,
    this.savingGoalId,
    this.items = const [],
    this.userCreated,
    this.accountId,
    this.currency = 'USD',
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      concept: json['concept']?.toString() ?? '',
      description: json['description']?.toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? 'expense',
      category: json['category'] != null
          ? Category.fromJson(
              json['category'] is Map<String, dynamic> ? json['category'] : {},
            )
          : null,
      receiptImageId: json['receipt_image'] != null 
          ? (json['receipt_image'] is Map ? json['receipt_image']['id'] : json['receipt_image']).toString()
          : null,
      isPersonal: json['is_personal'] == true,
      debtId: json['debt'] != null
          ? (json['debt'] is Map ? json['debt']['id'] : json['debt']).toString()
          : null,
      savingGoalId: json['saving_goal'] != null
          ? (json['saving_goal'] is Map ? json['saving_goal']['id'] : json['saving_goal']).toString()
          : null,
      items: json['items'] is List
          ? (json['items'] as List)
              .map((i) => TransactionItem.fromJson(
                    i is Map<String, dynamic> ? i : <String, dynamic>{},
                  ))
              .toList()
          : const [],
      userCreated: json['user_created'] is Map<String, dynamic>
          ? User.fromJson(json['user_created'] as Map<String, dynamic>)
          : null,
      accountId: json['account'] != null
          ? (json['account'] is Map ? json['account']['id'] : json['account']).toString()
          : null,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && id != '0') 'id': id,
      'amount': amount,
      'concept': concept,
      if (description != null) 'description': description,
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      if (category != null) 'category': category?.id,
      if (receiptImageId != null) 'receipt_image': receiptImageId,
      'is_personal': isPersonal,
      if (debtId != null) 'debt': debtId,
      if (savingGoalId != null) 'saving_goal': savingGoalId,
      if (accountId != null) 'account': accountId,
      'currency': currency,
      // items are usually handled via separate collection in Directus REST or nested in GraphQL
      // For REST creation, we usually do it in two steps unless configured otherwise
    };
  }
}
