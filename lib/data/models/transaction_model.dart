import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0) income,
  @HiveField(1) expense,
}

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String title;
  @HiveField(2) late double amount;
  @HiveField(3) late TransactionType type;
  @HiveField(4) late String categoryId;
  @HiveField(5) late String accountId;
  @HiveField(6) late DateTime date;
  @HiveField(7) late String note;
  @HiveField(8) late DateTime createdAt;

  TransactionModel({
    String? id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.note = '',
    DateTime? createdAt,
  }) {
    this.id        = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
  }

  TransactionModel copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? date,
    String? note,
  }) => TransactionModel(
    id:         id,
    title:      title      ?? this.title,
    amount:     amount     ?? this.amount,
    type:       type       ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    accountId:  accountId  ?? this.accountId,
    date:       date       ?? this.date,
    note:       note       ?? this.note,
    createdAt:  createdAt,
  );

  bool get isIncome  => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
}