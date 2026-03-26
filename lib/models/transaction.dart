import 'package:uuid/uuid.dart';

enum TransactionType {
  income('收入'),
  expense('支出');

  final String label;
  const TransactionType(this.label);
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String note;

  Transaction({
    String? id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String? ?? '',
      );
}
