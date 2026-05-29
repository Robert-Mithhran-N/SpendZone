import 'enums.dart';

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final Category category;
  final String? merchant;
  final UpiApp? upiApp;
  final String? referenceNumber;
  final TransactionSource source;
  final DateTime transactionDate;
  final DateTime createdAt;
  final String? rawSmsBody;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.merchant,
    this.upiApp,
    this.referenceNumber,
    required this.source,
    required this.transactionDate,
    required this.createdAt,
    this.rawSmsBody,
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    Category? category,
    String? merchant,
    UpiApp? upiApp,
    String? referenceNumber,
    TransactionSource? source,
    DateTime? transactionDate,
    DateTime? createdAt,
    String? rawSmsBody,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      upiApp: upiApp ?? this.upiApp,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      source: source ?? this.source,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      rawSmsBody: rawSmsBody ?? this.rawSmsBody,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'merchant': merchant,
      'upiApp': upiApp?.name,
      'referenceNumber': referenceNumber,
      'source': source.name,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'rawSmsBody': rawSmsBody,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      category: Category.values.byName(json['category'] as String),
      merchant: json['merchant'] as String?,
      upiApp: json['upiApp'] != null
          ? UpiApp.values.byName(json['upiApp'] as String)
          : null,
      referenceNumber: json['referenceNumber'] as String?,
      source: TransactionSource.values.byName(json['source'] as String),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      rawSmsBody: json['rawSmsBody'] as String?,
    );
  }
}
